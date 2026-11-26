import 'package:flutter/material.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(color: palette.border, width: palette.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: palette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AvatarMark extends StatelessWidget {
  const AvatarMark({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: palette.border, width: palette.borderWidth),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: scheme.primary, size: 20)
          : Text(
              label.trim().isEmpty
                  ? '?'
                  : label.trim().substring(0, 1).toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
    );
  }
}
