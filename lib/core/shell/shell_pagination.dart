import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Per-tab pagination kept warm so [HomeShell] can show the active tab's bar
/// in the same frame as the module switch (no separate footer mount delay).
class ShellPaginationConfig {
  ShellPaginationConfig({
    required this.page,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int page;
  final int totalItems;
  ValueChanged<int> onPageChanged;
}

final shellPaginationSlotsProvider =
    StateProvider<Map<int, ShellPaginationConfig>>((ref) => const {});

/// Publishes this tab's pagination into the unified shell chrome.
class ShellPaginationBinder extends ConsumerStatefulWidget {
  const ShellPaginationBinder({
    super.key,
    required this.tabIndex,
    required this.enabled,
    required this.page,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int tabIndex;
  final bool enabled;
  final int page;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  @override
  ConsumerState<ShellPaginationBinder> createState() =>
      _ShellPaginationBinderState();
}

class _ShellPaginationBinderState extends ConsumerState<ShellPaginationBinder> {
  ProviderContainer? _container;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
  }

  @override
  void didUpdateWidget(covariant ShellPaginationBinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
  }

  @override
  void dispose() {
    final container = _container;
    final tabIndex = widget.tabIndex;
    // Remove only this tab's slot (other tabs stay warm for instant switch).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current =
          container?.read(shellPaginationSlotsProvider) ?? const {};
      if (current.containsKey(tabIndex)) {
        final next = Map<int, ShellPaginationConfig>.from(current)
          ..remove(tabIndex);
        container?.read(shellPaginationSlotsProvider.notifier).state = next;
      }
    });
    super.dispose();
  }

  void _publish() {
    if (!mounted) return;
    final notifier = ref.read(shellPaginationSlotsProvider.notifier);
    final current = ref.read(shellPaginationSlotsProvider);

    if (!widget.enabled) {
      if (current.containsKey(widget.tabIndex)) {
        notifier.state = Map<int, ShellPaginationConfig>.from(current)
          ..remove(widget.tabIndex);
      }
      return;
    }

    final existing = current[widget.tabIndex];
    if (existing != null &&
        existing.page == widget.page &&
        existing.totalItems == widget.totalItems) {
      existing.onPageChanged = widget.onPageChanged;
      return;
    }

    notifier.state = {
      ...current,
      widget.tabIndex: ShellPaginationConfig(
        page: widget.page,
        totalItems: widget.totalItems,
        onPageChanged: widget.onPageChanged,
      ),
    };
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
