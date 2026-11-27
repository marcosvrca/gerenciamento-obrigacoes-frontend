import 'package:material_ui/material_ui.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_visual_theme.dart';

/// Loaded via CSS in web/index.html to avoid a blocking google_fonts fetch
/// on the first Flutter frame.
const String _brandFontFamily = 'Plus Jakarta Sans';

class AppTheme {
  static ThemeData of(AppVisualTheme visualTheme) {
    return switch (visualTheme) {
      AppVisualTheme.light => _build(
          brightness: Brightness.light,
          palette: AppPalette.light,
          scheme: _lightScheme,
        ),
      AppVisualTheme.dark => _build(
          brightness: Brightness.dark,
          palette: AppPalette.dark,
          scheme: _darkScheme,
        ),
      AppVisualTheme.highContrast => _build(
          brightness: Brightness.dark,
          palette: AppPalette.highContrast,
          scheme: _highContrastScheme,
          highContrast: true,
        ),
    };
  }

  /// Kept for tests / callers that expect the light theme directly.
  static ThemeData light() => of(AppVisualTheme.light);
  static ThemeData dark() => of(AppVisualTheme.dark);
  static ThemeData highContrast() => of(AppVisualTheme.highContrast);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0F4C5C),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD7E8EC),
    onPrimaryContainer: Color(0xFF0A2E36),
    secondary: Color(0xFFC9782B),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFF1E3),
    onSecondaryContainer: Color(0xFF5C3408),
    tertiary: Color(0xFF1E6B8A),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFE3F2F8),
    onTertiaryContainer: Color(0xFF0A3A4D),
    error: Color(0xFFB42318),
    onError: Colors.white,
    errorContainer: Color(0xFFFEECEC),
    onErrorContainer: Color(0xFF7A160F),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF142126),
    surfaceContainerHighest: Color(0xFFF3F6F7),
    onSurfaceVariant: Color(0xFF5B6B73),
    outline: Color(0xFFB7C5CB),
    outlineVariant: Color(0xFFD5DEE2),
    shadow: Color(0x1A0A2E36),
    scrim: Color(0x990A2E36),
    inverseSurface: Color(0xFF0A2E36),
    onInverseSurface: Color(0xFFF3F6F7),
    inversePrimary: Color(0xFF8DCCD8),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5EB4C4),
    onPrimary: Color(0xFF00313C),
    primaryContainer: Color(0xFF0F4C5C),
    onPrimaryContainer: Color(0xFFD7E8EC),
    secondary: Color(0xFFF0B45A),
    onSecondary: Color(0xFF3A2200),
    secondaryContainer: Color(0xFF5C3408),
    onSecondaryContainer: Color(0xFFFFF1E3),
    tertiary: Color(0xFF6EC3DE),
    onTertiary: Color(0xFF003344),
    tertiaryContainer: Color(0xFF1E6B8A),
    onTertiaryContainer: Color(0xFFE3F2F8),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF152228),
    onSurface: Color(0xFFE8F2F4),
    surfaceContainerHighest: Color(0xFF1C2E36),
    onSurfaceVariant: Color(0xFF9BB0B8),
    outline: Color(0xFF6E838C),
    outlineVariant: Color(0xFF2C4149),
    shadow: Color(0xFF000000),
    scrim: Color(0xCC000000),
    inverseSurface: Color(0xFFE8F2F4),
    onInverseSurface: Color(0xFF0B1418),
    inversePrimary: Color(0xFF0F4C5C),
  );

  static const _highContrastScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFFF00),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFFFFFF00),
    onPrimaryContainer: Color(0xFF000000),
    secondary: Color(0xFF66CCFF),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF66CCFF),
    onSecondaryContainer: Color(0xFF000000),
    tertiary: Color(0xFF00FF66),
    onTertiary: Color(0xFF000000),
    tertiaryContainer: Color(0xFF00FF66),
    onTertiaryContainer: Color(0xFF000000),
    error: Color(0xFFFF5555),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFFFF5555),
    onErrorContainer: Color(0xFF000000),
    surface: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFF000000),
    onSurfaceVariant: Color(0xFFFFFFFF),
    outline: Color(0xFFFFFFFF),
    outlineVariant: Color(0xFFFFFFFF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFFFFFFF),
    onInverseSurface: Color(0xFF000000),
    inversePrimary: Color(0xFF000000),
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppPalette palette,
    required ColorScheme scheme,
    bool highContrast = false,
  }) {
    final baseText = ThemeData(brightness: brightness).textTheme.apply(
          fontFamily: _brandFontFamily,
          bodyColor: scheme.onSurface,
          displayColor: palette.ink,
        );

    final textTheme = baseText
        .apply(
          fontFamily: _brandFontFamily,
        )
        .copyWith(
          headlineLarge: baseText.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: palette.ink,
          ),
          headlineMedium: baseText.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: palette.ink,
          ),
          headlineSmall: baseText.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: palette.ink,
          ),
          titleLarge: baseText.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: palette.ink,
          ),
          titleMedium: baseText.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: palette.ink,
          ),
          titleSmall: baseText.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: palette.muted,
          ),
          bodyLarge: baseText.bodyLarge?.copyWith(
            height: 1.45,
            color: scheme.onSurface,
          ),
          bodyMedium: baseText.bodyMedium?.copyWith(
            height: 1.45,
            color: palette.muted,
          ),
          bodySmall: baseText.bodySmall?.copyWith(
            color: palette.muted,
            height: 1.4,
          ),
          labelLarge: baseText.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );

    final radius = BorderRadius.circular(
      highContrast ? AppRadii.sm : AppRadii.md,
    );
    final borderSide = BorderSide(
      color: palette.border,
      width: palette.borderWidth,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _brandFontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.canvas,
      extensions: [palette],
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: palette.canvas,
        foregroundColor: palette.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.primary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: borderSide,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: palette.borderWidth,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(
            color: scheme.primary,
            width: highContrast ? 3 : 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: palette.danger, width: palette.borderWidth),
        ),
        labelStyle: TextStyle(color: palette.muted),
        hintStyle: TextStyle(color: palette.muted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceMuted,
        selectedColor: scheme.primaryContainer,
        disabledColor: palette.canvas,
        side: borderSide,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            side: highContrast
                ? BorderSide(color: scheme.onPrimary, width: 2)
                : BorderSide.none,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(
            color: highContrast ? palette.border : scheme.outline,
            width: palette.borderWidth,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: highContrast ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: highContrast
              ? BorderSide(color: scheme.onPrimary, width: 2)
              : BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : palette.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : palette.muted,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: palette.muted),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: palette.muted,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: highContrast ? borderSide : BorderSide.none,
        ),
        titleTextStyle: textTheme.titleLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: highContrast ? Colors.white : palette.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: highContrast ? Colors.black : palette.canvas,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: highContrast
              ? const BorderSide(color: Colors.black, width: 2)
              : BorderSide.none,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        iconColor: scheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: borderSide,
        ),
      ),
    );
  }
}
