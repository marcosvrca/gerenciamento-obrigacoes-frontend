import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';

class ListPagination {
  ListPagination._();

  static const int pageSize = 15;

  static int pageCount(int totalItems) {
    if (totalItems <= 0) return 1;
    return (totalItems / pageSize).ceil();
  }

  static bool shouldShow(int totalItems) => totalItems > pageSize;

  static List<T> slice<T>(List<T> items, int page) {
    if (items.isEmpty) return const [];
    final safePage = page.clamp(0, pageCount(items.length) - 1);
    final start = safePage * pageSize;
    final end = math.min(start + pageSize, items.length);
    return items.sublist(start, end);
  }
}

/// Footer pagination for [Scaffold.bottomNavigationBar].
/// Keeps controls at the bottom and lets the FAB float above (Material).
class ListPaginationBar extends StatelessWidget {
  const ListPaginationBar({
    super.key,
    required this.page,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int page;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (!ListPagination.shouldShow(totalItems)) {
      return const SizedBox.shrink();
    }

    final pages = ListPagination.pageCount(totalItems);
    final safePage = page.clamp(0, pages - 1);
    final start = safePage * ListPagination.pageSize + 1;
    final end = math.min((safePage + 1) * ListPagination.pageSize, totalItems);
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    // Compact footer only — FAB must stay on Scaffold.floatingActionButton.
    return Material(
      color: palette.surface,
      elevation: 0,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xs,
            AppSpacing.page,
            AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: palette.border, width: palette.borderWidth),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$start–$end de $totalItems',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: palette.muted),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Página anterior',
                      visualDensity: VisualDensity.compact,
                      onPressed: safePage > 0
                          ? () => onPageChanged(safePage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        '${safePage + 1} / $pages',
                        style:
                            textTheme.labelLarge?.copyWith(color: palette.ink),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Próxima página',
                      visualDensity: VisualDensity.compact,
                      onPressed: safePage < pages - 1
                          ? () => onPageChanged(safePage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Scrollable page slice only — pagination belongs in [Scaffold.bottomNavigationBar].
class PaginatedEntityList<T> extends StatelessWidget {
  const PaginatedEntityList({
    super.key,
    required this.items,
    required this.page,
    required this.itemBuilder,
    required this.onRefresh,
    this.bottomClearanceForFab = false,
  });

  final List<T> items;
  final int page;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;

  /// Extra list padding when there is no footer and the FAB floats over content.
  final bool bottomClearanceForFab;

  @override
  Widget build(BuildContext context) {
    final pageItems = ListPagination.slice(items, page);
    final bottom = bottomClearanceForFab ? 88.0 : AppSpacing.lg;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          bottom,
        ),
        itemCount: pageItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) =>
            itemBuilder(context, pageItems[index]),
      ),
    );
  }
}
