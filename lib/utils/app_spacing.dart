import 'package:flutter/material.dart';

class AppSpacing {
  // Base spacing unit (8px)
  static const double baseUnit = 8.0;

  // Spacing Scale
  static const double xs = baseUnit * 0.5; // 4px
  static const double sm = baseUnit * 1; // 8px
  static const double md = baseUnit * 2; // 16px
  static const double lg = baseUnit * 3; // 24px
  static const double xl = baseUnit * 4; // 32px
  static const double xxl = baseUnit * 6; // 48px
  static const double xxxl = baseUnit * 8; // 64px

  // Component Spacing
  static const double componentPadding = md;
  static const double componentMargin = sm;
  static const double componentGap = sm;

  // Layout Spacing
  static const double sectionSpacing = xl;
  static const double pagePadding = lg;
  static const double cardPadding = md;
  static const double cardMargin = sm;

  // Form Spacing
  static const double formFieldSpacing = md;
  static const double formSectionSpacing = lg;
  static const double formLabelSpacing = xs;

  // Button Spacing
  static const double buttonPadding = md;
  static const double buttonSpacing = sm;
  static const double buttonGroupSpacing = sm;

  // List Spacing
  static const double listItemSpacing = sm;
  static const double listSectionSpacing = md;
  static const double listPadding = md;

  // Grid Spacing
  static const double gridSpacing = md;
  static const double gridPadding = lg;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusRound = 9999.0;

  // Component Border Radius
  static const double buttonRadius = radiusMd;
  static const double cardRadius = radiusLg;
  static const double inputRadius = radiusMd;
  static const double chipRadius = radiusRound;
  static const double avatarRadius = radiusRound;

  // Elevation/Shadow
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
  static const double elevationXxl = 24.0;

  // Component Elevation
  static const double cardElevation = elevationSm;
  static const double buttonElevation = elevationXs;
  static const double dialogElevation = elevationLg;
  static const double bottomSheetElevation = elevationMd;

  // Icon Sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // Avatar Sizes
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 48.0;
  static const double avatarXl = 64.0;
  static const double avatarXxl = 80.0;

  // Button Heights
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  static const double buttonHeightXl = 56.0;

  // Input Heights
  static const double inputHeightSm = 36.0;
  static const double inputHeightMd = 44.0;
  static const double inputHeightLg = 52.0;

  // Card Dimensions
  static const double cardMinHeight = 120.0;
  static const double cardMaxWidth = 400.0;

  // Breakpoints
  static const double breakpointXs = 480.0;
  static const double breakpointSm = 640.0;
  static const double breakpointMd = 768.0;
  static const double breakpointLg = 1024.0;
  static const double breakpointXl = 1280.0;
  static const double breakpointXxl = 1536.0;

  // Helper Methods
  static EdgeInsets paddingAll(double value) => EdgeInsets.all(value);
  static EdgeInsets paddingHorizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets paddingVertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  static EdgeInsets marginAll(double value) => EdgeInsets.all(value);
  static EdgeInsets marginHorizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets marginVertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // Common Padding Combinations
  static EdgeInsets get pagePadding => paddingAll(pagePadding);
  static EdgeInsets get cardPadding => paddingAll(cardPadding);
  static EdgeInsets get componentPadding => paddingAll(componentPadding);
  static EdgeInsets get formPadding => paddingAll(md);
  static EdgeInsets get listPadding => paddingAll(listPadding);

  // Common Margin Combinations
  static EdgeInsets get cardMargin => marginAll(cardMargin);
  static EdgeInsets get componentMargin => marginAll(componentMargin);
  static EdgeInsets get sectionMargin => marginAll(sectionSpacing);

  // Responsive Spacing
  static double responsive({
    required double baseValue,
    required double scaleFactor,
  }) => baseValue * scaleFactor;

  // Screen-based Spacing
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static double responsivePadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < breakpointSm) return sm;
    if (width < breakpointMd) return md;
    if (width < breakpointLg) return lg;
    return xl;
  }

  static double responsiveMargin(BuildContext context) {
    final width = screenWidth(context);
    if (width < breakpointSm) return xs;
    if (width < breakpointMd) return sm;
    if (width < breakpointLg) return md;
    return lg;
  }

  // Grid Spacing
  static double gridSpacingForColumns(BuildContext context, int columns) {
    final width = screenWidth(context);
    if (width < breakpointSm) return xs;
    if (width < breakpointMd) return sm;
    if (width < breakpointLg) return md;
    return lg;
  }

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Animation Curves
  static const Curve animationCurve = Curves.easeInOut;
  static const Curve animationCurveFast = Curves.easeOut;
  static const Curve animationCurveSlow = Curves.easeIn;

  // Z-Index Values
  static const int zIndexDropdown = 1000;
  static const int zIndexModal = 1050;
  static const int zIndexTooltip = 1100;
  static const int zIndexToast = 1150;
}
