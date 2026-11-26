import 'package:flutter/material.dart';

enum AppVisualTheme {
  light,
  dark,
  highContrast;

  String get label => switch (this) {
        AppVisualTheme.light => 'Claro',
        AppVisualTheme.dark => 'Escuro',
        AppVisualTheme.highContrast => 'Alto contraste',
      };

  IconData get icon => switch (this) {
        AppVisualTheme.light => Icons.light_mode_outlined,
        AppVisualTheme.dark => Icons.dark_mode_outlined,
        AppVisualTheme.highContrast => Icons.contrast,
      };

  static AppVisualTheme fromStorage(String? value) {
    return AppVisualTheme.values.firstWhere(
      (theme) => theme.name == value,
      orElse: () => AppVisualTheme.light,
    );
  }
}
