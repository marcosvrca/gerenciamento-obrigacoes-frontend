import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_pagination.dart';

/// Pagination state owned by list pages, rendered by [HomeShell] as a thin
/// full-bleed bar under the Expanded shell (sidebar + content stay visible).
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

final shellPaginationProvider =
    StateProvider<ShellPaginationConfig?>((ref) => null);

/// Publishes pagination to the shell footer; clears on dispose.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      container?.read(shellPaginationProvider.notifier).state = null;
    });
    super.dispose();
  }

  void _publish() {
    if (!mounted) return;
    final notifier = ref.read(shellPaginationProvider.notifier);
    final current = ref.read(shellPaginationProvider);

    if (!widget.enabled || !ListPagination.shouldShow(widget.totalItems)) {
      if (current != null) notifier.state = null;
      return;
    }

    // Avoid notify loops: only replace when page/count change; refresh callback.
    if (current != null &&
        current.page == widget.page &&
        current.totalItems == widget.totalItems) {
      current.onPageChanged = widget.onPageChanged;
      return;
    }

    notifier.state = ShellPaginationConfig(
      page: widget.page,
      totalItems: widget.totalItems,
      onPageChanged: widget.onPageChanged,
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
