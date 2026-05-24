import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Typography scale built around Inter (display + body) and JetBrains Mono
/// (code). Font files are loaded via Google Fonts CSS in `web/index.html`
/// for web builds; for native builds the system fall-back kicks in until
/// the `google_fonts` package is wired.
class PsyTypography {
  const PsyTypography._();

  static const String displayFamily = 'Inter';
  static const String bodyFamily = 'Inter';
  static const String monoFamily = 'JetBrains Mono';

  static const List<String> displayFallback = [
    '-apple-system',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static TextTheme buildTextTheme(Brightness brightness) {
    final onSurface =
        brightness == Brightness.light ? PsyColors.n900 : PsyColors.n100;
    final muted = onSurface.withValues(alpha: 0.72);

    TextStyle base(double size, FontWeight weight,
        {double? height, double letterSpacing = 0, Color? color}) {
      return TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: displayFallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color ?? onSurface,
      );
    }

    return TextTheme(
      displayLarge:
          base(56, FontWeight.w800, height: 1.05, letterSpacing: -1.5),
      displayMedium:
          base(44, FontWeight.w800, height: 1.1, letterSpacing: -1.0),
      displaySmall:
          base(36, FontWeight.w700, height: 1.15, letterSpacing: -0.6),
      headlineLarge: base(30, FontWeight.w700, height: 1.2),
      headlineMedium: base(24, FontWeight.w700, height: 1.25),
      headlineSmall: base(20, FontWeight.w600, height: 1.3),
      titleLarge: base(18, FontWeight.w600, height: 1.35),
      titleMedium: base(16, FontWeight.w600, height: 1.4),
      titleSmall: base(14, FontWeight.w600, height: 1.4),
      bodyLarge: base(16, FontWeight.w400, height: 1.6, color: muted),
      bodyMedium: base(14, FontWeight.w400, height: 1.55, color: muted),
      bodySmall: base(12.5, FontWeight.w400, height: 1.5, color: muted),
      labelLarge: base(14, FontWeight.w600, height: 1.3),
      labelMedium:
          base(12, FontWeight.w600, height: 1.3, letterSpacing: 0.6),
      labelSmall:
          base(11, FontWeight.w600, height: 1.3, letterSpacing: 0.8),
    );
  }
}
