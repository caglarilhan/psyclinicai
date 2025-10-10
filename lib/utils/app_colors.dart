import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Professional Purple
  static const Color primary = Color(0xFF6B46C1); // Deep purple
  static const Color primaryLight = Color(0xFF9F7AEA); // Light purple
  static const Color primaryDark = Color(0xFF553C9A); // Dark purple
  static const Color primaryContainer = Color(0xFFF3F0FF); // Very light purple

  // Secondary Colors - Elegant Pink
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color secondaryLight = Color(0xFFF472B6); // Light pink
  static const Color secondaryDark = Color(0xFFDB2777); // Dark pink
  static const Color secondaryContainer = Color(0xFFFDF2F8); // Very light pink

  // Accent Colors - Violet
  static const Color accent = Color(0xFF8B5CF6); // Violet
  static const Color accentLight = Color(0xFFA78BFA); // Light violet
  static const Color accentDark = Color(0xFF7C3AED); // Dark violet
  static const Color accentContainer = Color(0xFFF5F3FF); // Very light violet

  // Neutral Colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successContainer = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFEFF6FF);

  // Background Colors - Clean White Theme
  static const Color background = Color(0xFFFAFAFA); // Off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFF9FAFB); // Very light gray
  static const Color surfaceContainer = Color(0xFFF3F4F6); // Light gray

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E1);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surfaceVariant],
  );

  // Status Colors
  static const Color statusActive = success;
  static const Color statusInactive = neutral400;
  static const Color statusPending = warning;
  static const Color statusCompleted = primary;
  static const Color statusCancelled = error;

  // Chart Colors - Purple & Pink Palette
  static const List<Color> chartColors = [
    primary, // Deep purple
    secondary, // Pink
    accent, // Violet
    Color(0xFF7C3AED), // Dark violet
    Color(0xFFA855F7), // Medium purple
    Color(0xFFC084FC), // Light purple
    Color(0xFFF472B6), // Light pink
    Color(0xFFEC4899), // Pink
  ];

  // Department Colors - Purple Theme
  static const Color psychiatry = Color(0xFF6B46C1); // Deep purple
  static const Color psychology = Color(0xFF8B5CF6); // Violet
  static const Color therapy = Color(0xFFA855F7); // Medium purple
  static const Color administration = Color(0xFFEC4899); // Pink
  static const Color support = Color(0xFFF472B6); // Light pink

  // Priority Colors
  static const Color priorityHigh = error;
  static const Color priorityMedium = warning;
  static const Color priorityLow = success;
  static const Color priorityCritical = Color(0xFF7C2D12);

  // Rating Colors
  static const Color ratingExcellent = success;
  static const Color ratingGood = Color(0xFF22C55E);
  static const Color ratingAverage = warning;
  static const Color ratingPoor = error;
  static const Color ratingVeryPoor = Color(0xFF7C2D12);

  // Helper Methods
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'success':
        return statusActive;
      case 'pending':
      case 'in_progress':
        return statusPending;
      case 'cancelled':
      case 'failed':
      case 'error':
        return statusCancelled;
      case 'inactive':
      case 'disabled':
        return statusInactive;
      default:
        return neutral500;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return priorityHigh;
      case 'medium':
      case 'normal':
        return priorityMedium;
      case 'low':
        return priorityLow;
      case 'critical':
        return priorityCritical;
      default:
        return neutral500;
    }
  }

  static Color getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'psychiatry':
        return psychiatry;
      case 'psychology':
        return psychology;
      case 'therapy':
        return therapy;
      case 'administration':
        return administration;
      case 'support':
        return support;
      default:
        return primary;
    }
  }

  static Color getRatingColor(double rating) {
    if (rating >= 4.5) return ratingExcellent;
    if (rating >= 3.5) return ratingGood;
    if (rating >= 2.5) return ratingAverage;
    if (rating >= 1.5) return ratingPoor;
    return ratingVeryPoor;
  }
}
