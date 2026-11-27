import 'package:material_ui/material_ui.dart';
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
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.muted,
                      height: 1.4,
                    ),
                  ),
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
    this.label = 'Filtro',
  });

  final List<FilterOption> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final String label;

  static const double compactBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final isCompact =
        MediaQuery.sizeOf(context).width < compactBreakpoint;

    if (isCompact) {
      return _FilterDropdown(
        label: label,
        options: options,
        selected: selected,
        onSelected: onSelected,
      );
    }

    return _FilterChipsRow(
      options: options,
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<FilterOption> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fieldRadius = BorderRadius.circular(AppRadii.md);
    final menuRadius = BorderRadius.circular(AppRadii.md);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.lg,
      ),
      child: DropdownButtonFormField<String?>(
        key: ValueKey(selected ?? '__all__'),
        initialValue: selected,
        isExpanded: true,
        borderRadius: menuRadius,
        dropdownColor: palette.surface,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: scheme.primary,
        ),
        style: textTheme.bodyLarge?.copyWith(color: palette.ink),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: palette.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(
              color: palette.border,
              width: palette.borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(
              color: palette.border,
              width: palette.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
        selectedItemBuilder: (context) {
          return options
              .map(
                (option) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option.label,
                    style: textTheme.bodyLarge?.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList();
        },
        items: [
          for (var i = 0; i < options.length; i++)
            DropdownMenuItem<String?>(
              value: options[i].value,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: i == options.length - 1
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: palette.border.withValues(alpha: 0.85),
                            width: palette.borderWidth,
                          ),
                        ),
                ),
                child: Text(
                  options[i].label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: selected == options[i].value
                        ? scheme.primary
                        : palette.ink,
                    fontWeight: selected == options[i].value
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
        onChanged: (value) => onSelected(value),
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.lg,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: options.map((option) {
          final isSelected = selected == option.value;
          return FilterChip(
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : AppSpacing.maxContentWidth;
        final width = maxW < AppSpacing.maxContentWidth
            ? maxW
            : AppSpacing.maxContentWidth;
        // Pass a bounded height so Column+Expanded inside list pages work
        // correctly (Align alone can leave vertical constraints loose).
        final height =
            constraints.maxHeight.isFinite ? constraints.maxHeight : null;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        );
      },
    );
  }
}
