import 'package:flutter/material.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final style = _styleFor(status, palette);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: style.foreground.withValues(alpha: 0.35),
          width: palette.borderWidth,
        ),
      ),
      child: Text(
        style.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: style.foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  static _BadgeStyle _styleFor(String status, AppPalette palette) {
    switch (status) {
      case 'PENDENTE':
        return _BadgeStyle(
          label: 'Pendente',
          background: palette.warningSoft,
          foreground: palette.warning,
        );
      case 'EM_ANDAMENTO':
        return _BadgeStyle(
          label: 'Em andamento',
          background: palette.infoSoft,
          foreground: palette.info,
        );
      case 'CONCLUIDA':
        return _BadgeStyle(
          label: 'Concluída',
          background: palette.successSoft,
          foreground: palette.success,
        );
      default:
        return _BadgeStyle(
          label: status,
          background: palette.surfaceMuted,
          foreground: palette.ink,
        );
    }
  }
}

class SituacaoBadge extends StatelessWidget {
  const SituacaoBadge({super.key, required this.ativa, required this.label});

  final bool ativa;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final background = ativa ? palette.successSoft : palette.surfaceMuted;
    final foreground = ativa ? palette.success : palette.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: foreground.withValues(alpha: 0.35),
          width: palette.borderWidth,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}
