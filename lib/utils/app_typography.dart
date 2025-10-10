import 'package:flutter/material.dart';

class AppTypography {
  // Font Families
  static const String primaryFont = 'Inter';
  static const String secondaryFont = 'Poppins';
  static const String monoFont = 'JetBrains Mono';

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 57,
    fontWeight: bold,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 45,
    fontWeight: bold,
    height: 1.16,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 36,
    fontWeight: bold,
    height: 1.22,
    letterSpacing: 0,
  );

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: semiBold,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: semiBold,
    height: 1.29,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: 0,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 22,
    fontWeight: semiBold,
    height: 1.27,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: medium,
    height: 1.50,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: regular,
    height: 1.50,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // Custom Styles
  static const TextStyle button = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: primaryFont,
    fontSize: 10,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Card Styles
  static const TextStyle cardTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
  );

  // Dashboard Styles
  static const TextStyle dashboardTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: bold,
    height: 1.29,
    letterSpacing: 0,
  );

  static const TextStyle dashboardSubtitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: regular,
    height: 1.50,
    letterSpacing: 0.5,
  );

  static const TextStyle statValue = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // Form Styles
  static const TextStyle formLabel = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle formHint = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static const TextStyle formError = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Navigation Styles
  static const TextStyle navLabel = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle navTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.50,
    letterSpacing: 0.15,
  );

  // Table Styles
  static const TextStyle tableHeader = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle tableCell = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
  );

  // Status Styles
  static const TextStyle statusBadge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // Chart Styles
  static const TextStyle chartTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.50,
    letterSpacing: 0.15,
  );

  static const TextStyle chartLabel = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Helper Methods
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }

  // Responsive Typography
  static TextStyle responsive({
    required double baseSize,
    required double scaleFactor,
    FontWeight? weight,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: baseSize * scaleFactor,
      fontWeight: weight ?? regular,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Text Theme
  static TextTheme get textTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  // Dark Theme Text Theme
  static TextTheme get darkTextTheme => textTheme.copyWith(
    displayLarge: displayLarge.copyWith(color: Colors.white),
    displayMedium: displayMedium.copyWith(color: Colors.white),
    displaySmall: displaySmall.copyWith(color: Colors.white),
    headlineLarge: headlineLarge.copyWith(color: Colors.white),
    headlineMedium: headlineMedium.copyWith(color: Colors.white),
    headlineSmall: headlineSmall.copyWith(color: Colors.white),
    titleLarge: titleLarge.copyWith(color: Colors.white),
    titleMedium: titleMedium.copyWith(color: Colors.white70),
    titleSmall: titleSmall.copyWith(color: Colors.white70),
    bodyLarge: bodyLarge.copyWith(color: Colors.white70),
    bodyMedium: bodyMedium.copyWith(color: Colors.white60),
    bodySmall: bodySmall.copyWith(color: Colors.white60),
    labelLarge: labelLarge.copyWith(color: Colors.white70),
    labelMedium: labelMedium.copyWith(color: Colors.white60),
    labelSmall: labelSmall.copyWith(color: Colors.white60),
  );
}
