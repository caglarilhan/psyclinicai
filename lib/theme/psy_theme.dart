import 'package:flutter/material.dart';

import 'brand_colors.dart';
import 'tokens.dart';
import 'typography.dart';

/// PsyClinicAI ThemeData factory.
///
/// Replaces the legacy `ThemeService.getLightTheme()` flow with a single
/// brand-driven theme. ThemeService remains in `lib/services/` for theme-
/// mode state (light/dark/system) but no longer owns visual tokens.
class PsyTheme {
  const PsyTheme._();

  static ThemeData light() => _build(PsyColors.lightScheme);
  static ThemeData dark() => _build(PsyColors.darkScheme);

  static ThemeData _build(ColorScheme cs) {
    final text = PsyTypography.buildTextTheme(cs.brightness);

    return ThemeData(
      colorScheme: cs,
      brightness: cs.brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      textTheme: text,
      primaryTextTheme: text,
      visualDensity: VisualDensity.standard,
      // Web-native: kill ripple on web/desktop, keep hover-driven feel.
      splashFactory: NoSplash.splashFactory,
      highlightColor: cs.primary.withValues(alpha: 0.04),
      hoverColor: cs.primary.withValues(alpha: 0.04),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          // Android FadeUpwards smells too mobile. Web/desktop = instant.
          TargetPlatform.android: _NoTransitionsBuilder(),
          TargetPlatform.linux: _NoTransitionsBuilder(),
          TargetPlatform.windows: _NoTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: PsyElevation.flat,
        scrolledUnderElevation: PsyElevation.flat,
        surfaceTintColor: cs.surface,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: cs.outlineVariant)),
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: PsyElevation.flat,
        margin: EdgeInsets.zero,
        color: cs.surface,
        surfaceTintColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PsyRadius.lg),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.xl, vertical: PsySpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PsyRadius.md),
          ),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: PsyElevation.flat,
          padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.xl, vertical: PsySpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PsyRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.xl, vertical: PsySpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PsyRadius.md),
          ),
          side: BorderSide(color: cs.outlineVariant),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.lg, vertical: PsySpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PsyRadius.sm),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.lg, vertical: PsySpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PsyRadius.md),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PsyRadius.md),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PsyRadius.md),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PsyRadius.md),
          borderSide: BorderSide(color: cs.error),
        ),
        labelStyle: text.bodyMedium,
        hintStyle: text.bodyMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.45),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        selectedColor: cs.primary,
        labelStyle: text.labelMedium,
        shape: StadiumBorder(
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: PsySpacing.lg,
      ),
      snackBarTheme: const SnackBarThemeData(
        // Bottom-docked (Slack/Vercel) instead of mobile-floating.
        behavior: SnackBarBehavior.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        elevation: PsyElevation.modal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PsyRadius.xl),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: BorderRadius.circular(PsyRadius.sm),
        ),
        textStyle: text.labelSmall?.copyWith(color: cs.onInverseSurface),
        padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.md, vertical: PsySpacing.sm),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.primary),
      iconTheme: IconThemeData(color: cs.onSurface, size: 20),
    );
  }
}

/// Web-native page transition — instant snap, no Android FadeUpwards.
class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
