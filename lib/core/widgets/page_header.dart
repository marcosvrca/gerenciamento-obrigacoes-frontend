import 'package:flutter/material.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!, style: textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions,
            ),
        ],
      ),
    );
  }
}

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<FilterOption> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = selected == option.value;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(option.label),
              onSelected: (_) => onSelected(option.value),
              selectedColor: scheme.primaryContainer,
              backgroundColor: palette.surface,
              side: BorderSide(
                color: isSelected ? scheme.primary : palette.border,
                width: palette.borderWidth,
              ),
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? palette.ink : palette.muted,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterOption {
  const FilterOption({required this.label, this.value});

  final String label;
  final String? value;
}

class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: child,
      ),
    );
  }
}
