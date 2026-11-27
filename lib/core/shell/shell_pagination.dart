import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Pagination state owned by list pages, rendered by [HomeShell] as a thin
/// full-bleed bar under the Expanded shell (sidebar + content stay visible).
class ShellPaginationConfig {
  ShellPaginationConfig({
    required this.page,
    required this.totalItems,
    required this.onPageChanged,
    required this.owner,
  });

  final int page;
  final int totalItems;
  final Object owner;
  ValueChanged<int> onPageChanged;
}

final shellPaginationProvider =
    StateProvider<ShellPaginationConfig?>((ref) => null);

/// Publishes pagination to the shell footer; clears on dispose only if still owner.
class ShellPaginationBinder extends ConsumerStatefulWidget {
  const ShellPaginationBinder({
    super.key,
    required this.enabled,
    required this.page,
    required this.totalItems,
    required this.onPageChanged,
  });

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
  final Object _owner = Object();

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
    final owner = _owner;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = container?.read(shellPaginationProvider);
      // Only clear if we still own the footer (avoids wiping the next page).
      if (current != null && identical(current.owner, owner)) {
        container?.read(shellPaginationProvider.notifier).state = null;
      }
    });
    super.dispose();
  }

  void _publish() {
    if (!mounted) return;
    final notifier = ref.read(shellPaginationProvider.notifier);
    final current = ref.read(shellPaginationProvider);

    if (!widget.enabled) {
      if (current != null && identical(current.owner, _owner)) {
        notifier.state = null;
      }
      return;
    }

    if (current != null &&
        identical(current.owner, _owner) &&
        current.page == widget.page &&
        current.totalItems == widget.totalItems) {
      current.onPageChanged = widget.onPageChanged;
      return;
    }

    notifier.state = ShellPaginationConfig(
      page: widget.page,
      totalItems: widget.totalItems,
      onPageChanged: widget.onPageChanged,
      owner: _owner,
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
