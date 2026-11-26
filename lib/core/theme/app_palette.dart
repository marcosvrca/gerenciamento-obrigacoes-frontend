import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Semantic tokens that complement [ColorScheme] across themes.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.muted,
    required this.border,
    required this.brandMark,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.info,
    required this.infoSoft,
    required this.danger,
    required this.borderWidth,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color muted;
  final Color border;
  final Color brandMark;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color info;
  final Color infoSoft;
  final Color danger;
  final double borderWidth;

  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>()!;
  }

  static const light = AppPalette(
    canvas: Color(0xFFF3F6F7),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEF5F7),
    ink: Color(0xFF0A2E36),
    muted: Color(0xFF5B6B73),
    border: Color(0xFFD5DEE2),
    brandMark: Color(0xFF0F4C5C),
    success: Color(0xFF1F7A4C),
    successSoft: Color(0xFFE4F5EC),
    warning: Color(0xFFB56A12),
    warningSoft: Color(0xFFFFF3E0),
    info: Color(0xFF1E6B8A),
    infoSoft: Color(0xFFE3F2F8),
    danger: Color(0xFFB42318),
    borderWidth: 1,
  );

  static const dark = AppPalette(
    canvas: Color(0xFF0B1418),
    surface: Color(0xFF152228),
    surfaceMuted: Color(0xFF1C2E36),
    ink: Color(0xFFE8F2F4),
    muted: Color(0xFF9BB0B8),
    border: Color(0xFF2C4149),
    brandMark: Color(0xFF5EB4C4),
    success: Color(0xFF5ED39A),
    successSoft: Color(0xFF163528),
    warning: Color(0xFFF0B45A),
    warningSoft: Color(0xFF3A2A12),
    info: Color(0xFF6EC3DE),
    infoSoft: Color(0xFF16303A),
    danger: Color(0xFFFF8A80),
    borderWidth: 1,
  );

  static const highContrast = AppPalette(
    canvas: Color(0xFF000000),
    surface: Color(0xFF000000),
    surfaceMuted: Color(0xFF000000),
    ink: Color(0xFFFFFFFF),
    muted: Color(0xFFFFFFFF),
    border: Color(0xFFFFFFFF),
    brandMark: Color(0xFFFFFF00),
    success: Color(0xFF00FF66),
    successSoft: Color(0xFF00331A),
    warning: Color(0xFFFFCC00),
    warningSoft: Color(0xFF332900),
    info: Color(0xFF66CCFF),
    infoSoft: Color(0xFF002233),
    danger: Color(0xFFFF5555),
    borderWidth: 2,
  );

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? ink,
    Color? muted,
    Color? border,
    Color? brandMark,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? info,
    Color? infoSoft,
    Color? danger,
    double? borderWidth,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      brandMark: brandMark ?? this.brandMark,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      danger: danger ?? this.danger,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      brandMark: Color.lerp(brandMark, other.brandMark, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
    );
  }
}
