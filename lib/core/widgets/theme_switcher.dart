import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_visual_theme.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/theme_controller.dart';

class ThemeSwitcherButton extends ConsumerWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeControllerProvider);

    return PopupMenuButton<AppVisualTheme>(
      tooltip: 'Tema',
      initialValue: current,
      onSelected: (theme) =>
          ref.read(themeControllerProvider.notifier).setTheme(theme),
      itemBuilder: (context) => AppVisualTheme.values
          .map(
            (theme) => CheckedPopupMenuItem<AppVisualTheme>(
              value: theme,
              checked: theme == current,
              child: Row(
                children: [
                  Icon(theme.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(theme.label),
                ],
              ),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(current.icon, size: 20),
            const SizedBox(width: 8),
            Text(
              current.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
