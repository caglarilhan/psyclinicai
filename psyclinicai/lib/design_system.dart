import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF4A90E2),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF4A90E2),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Color(0xFF7ED321),
      surface: Colors.white,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.grey[900]),
      headlineSmall: TextStyle(
        color: Colors.grey[900],
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF4A90E2),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1F2A44),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
      secondary: Color(0xFF7ED321),
      surface: Color(0xFF1E1E1E),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Color(0xFF1E1E1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}

class AppColors {
  static const primary = Color(0xFF4A90E2);
  static const secondary = Color(0xFF7ED321);
  static const accent = Color(0xFFFF6B6B);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF333333);
  static const textLight = Color(0xFF666666);
  static const border = Color(0xFFE0E0E0);
  
  // Dark mode colors
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkText = Color(0xFFFFFFFF);
  static const darkTextLight = Color(0xFFB0B0B0);
  static const darkBorder = Color(0xFF333333);
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
