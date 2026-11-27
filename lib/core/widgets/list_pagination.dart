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

  static List<T> slice<T>(List<T> items, int page) {
    if (items.isEmpty) return const [];
    final safePage = page.clamp(0, pageCount(items.length) - 1);
    final start = safePage * pageSize;
    final end = math.min(start + pageSize, items.length);
    return items.sublist(start, end);
  }
}

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
    if (totalItems <= ListPagination.pageSize) {
      return const SizedBox.shrink();
    }

    final pages = ListPagination.pageCount(totalItems);
    final safePage = page.clamp(0, pages - 1);
    final start = safePage * ListPagination.pageSize + 1;
    final end = math.min((safePage + 1) * ListPagination.pageSize, totalItems);
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: palette.border, width: palette.borderWidth),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$start–$end de $totalItems',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: palette.muted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Página anterior',
                onPressed:
                    safePage > 0 ? () => onPageChanged(safePage - 1) : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  '${safePage + 1} / $pages',
                  style: textTheme.labelLarge?.copyWith(color: palette.ink),
                ),
              ),
              IconButton(
                tooltip: 'Próxima página',
                onPressed: safePage < pages - 1
                    ? () => onPageChanged(safePage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaginatedEntityList<T> extends StatelessWidget {
  const PaginatedEntityList({
    super.key,
    required this.items,
    required this.page,
    required this.onPageChanged,
    required this.itemBuilder,
    required this.onRefresh,
  });

  final List<T> items;
  final int page;
  final ValueChanged<int> onPageChanged;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final pageItems = ListPagination.slice(items, page);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              itemCount: pageItems.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) =>
                  itemBuilder(context, pageItems[index]),
            ),
          ),
        ),
        ListPaginationBar(
          page: page,
          totalItems: items.length,
          onPageChanged: onPageChanged,
        ),
        // Clearance for extended FABs (Nova obrigação / empresa / usuário).
        const SizedBox(height: 104),
      ],
    );
  }
}
