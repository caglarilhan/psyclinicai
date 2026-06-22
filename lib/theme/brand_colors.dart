import 'package:flutter/material.dart';

/// PsyClinicAI brand color palette.
///
/// Single source of truth for every UI color. Every screen should resolve
/// colors via `Theme.of(context).colorScheme.X` rather than hard-coding
/// hex values — but the raw tokens live here for places that need the
/// brand independent of theme (illustrations, gradients, charts).
class PsyColors {
  const PsyColors._();

  // --- Brand ---
  static const Color primary = Color(0xFF0F766E); // deep teal — calm + clinical
  static const Color primaryDim = Color(0xFF115E59);
  static const Color primarySoft = Color(0xFFCCFBF1);
  static const Color accent = Color(0xFF4F46E5); // indigo — CTA + highlights
  static const Color accentSoft = Color(0xFFE0E7FF);

  // --- Neutrals (8-step) ---
  static const Color n0 = Color(0xFFFFFFFF);
  static const Color n50 = Color(0xFFF8FAFC);
  static const Color n100 = Color(0xFFF1F5F9);
  static const Color n200 = Color(0xFFE2E8F0);
  static const Color n400 = Color(0xFF94A3B8);
  static const Color n600 = Color(0xFF475569);
  static const Color n800 = Color(0xFF1E293B);
  static const Color n900 = Color(0xFF0F172A);

  // --- Semantic ---
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // --- Risk severity (PHQ-9 / GAD-7 trend bands) ---
  static const Color riskMinimal = Color(0xFF16A34A);
  static const Color riskMild = Color(0xFFCA8A04);
  static const Color riskModerate = Color(0xFFEA580C);
  static const Color riskSevere = Color(0xFFDC2626);

  // --- Schemes ---
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: n0,
    primaryContainer: primarySoft,
    onPrimaryContainer: primaryDim,
    secondary: accent,
    onSecondary: n0,
    secondaryContainer: accentSoft,
    onSecondaryContainer: Color(0xFF312E81),
    tertiary: Color(0xFFDB2777),
    onTertiary: n0,
    error: danger,
    onError: n0,
    surface: n0,
    onSurface: n900,
    surfaceContainerLowest: n0,
    surfaceContainerLow: n50,
    surfaceContainer: n50,
    surfaceContainerHigh: n100,
    surfaceContainerHighest: n200,
    outline: n400,
    outlineVariant: n200,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: n900,
    onInverseSurface: n100,
    inversePrimary: primarySoft,
  );

  // Dark palette — landing reference (#34D399 emerald CTA on a deep
  // slate-900 canvas). AppShell, AppBar, cards and primary buttons
  // now read consistent with the marketing landing dark theme.
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF34D399),
    onPrimary: Color(0xFF052E1F),
    primaryContainer: Color(0xFF065F46),
    onPrimaryContainer: Color(0xFFD1FAE5),
    secondary: Color(0xFFA5F3FC),
    onSecondary: Color(0xFF0E2A33),
    secondaryContainer: Color(0xFF155E75),
    onSecondaryContainer: Color(0xFFCFFAFE),
    tertiary: Color(0xFFC4B5FD),
    onTertiary: Color(0xFF2E1065),
    error: Color(0xFFFCA5A5),
    onError: Color(0xFF7F1D1D),
    surface: Color(0xFF0B1220),
    onSurface: Color(0xFFE2E8F0),
    surfaceContainerLowest: Color(0xFF070D17),
    surfaceContainerLow: Color(0xFF0F172A),
    surfaceContainer: Color(0xFF111A2E),
    surfaceContainerHigh: Color(0xFF172033),
    surfaceContainerHighest: Color(0xFF1E293B),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF1E293B),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: n50,
    onInverseSurface: n800,
    inversePrimary: primary,
  );
}
