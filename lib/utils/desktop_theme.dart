import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class DesktopTheme {
  // Masaüstü için özel renkler
  static const Color desktopPrimary = Color(0xFF1E40AF);
  static const Color desktopSecondary = Color(0xFF6366F1);
  static const Color desktopAccent = Color(0xFF059669);
  static const Color desktopSurface = Color(0xFFF8FAFC);
  static const Color desktopSurfaceVariant = Color(0xFFF1F5F9);
  static const Color desktopBorder = Color(0xFFE2E8F0);
  static const Color desktopShadow = Color(0xFF1E293B);

  // Masaüstü boyutları
  static const double desktopMinWidth = 1200.0;
  static const double desktopMaxWidth = 1920.0;
  static const double sidebarWidth = 280.0;
  static const double topBarHeight = 64.0;
  static const double panelMinWidth = 400.0;
  static const double panelMaxWidth = 600.0;

  // Masaüstü tema
  static ThemeData get desktopTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: desktopPrimary,
        brightness: Brightness.light,
        primary: desktopPrimary,
        secondary: desktopSecondary,
        tertiary: desktopAccent,
        surface: desktopSurface,
        surfaceVariant: desktopSurfaceVariant,
        outline: desktopBorder,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: desktopSurface,
        foregroundColor: Color(0xFF1E293B),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        shadowColor: desktopShadow.withOpacity(0.08),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: desktopPrimary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: desktopSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: desktopBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: desktopBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: desktopPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: desktopBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF64748B),
        size: 20,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF64748B),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF1E293B),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF475569),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  // Masaüstü boyutları için yardımcı metodlar
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }

  static bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1600;
  }

  static bool isUltraWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 2000;
  }

  static double getSidebarWidth(BuildContext context) {
    if (isUltraWideScreen(context)) return 320;
    if (isWideScreen(context)) return 300;
    return sidebarWidth;
  }

  static double getPanelWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = getSidebarWidth(context);
    final availableWidth = screenWidth - sidebarWidth - 32; // padding
    
    if (availableWidth >= 1200) return 600;
    if (availableWidth >= 800) return 500;
    return panelMinWidth;
  }

  // Masaüstü için özel widget'lar
  static Widget desktopCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? elevation,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: desktopBorder),
        boxShadow: [
          BoxShadow(
            color: desktopShadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }

  static Widget desktopButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? desktopPrimary,
          foregroundColor: textColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static Widget desktopInput({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool isMultiline = false,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: isMultiline ? (maxLines ?? 4) : 1,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: desktopSurfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: desktopBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: desktopBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: desktopPrimary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Masaüstü için responsive layout
  static Widget responsiveLayout({
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
    required BuildContext context,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= desktopMinWidth) {
      return desktop;
    } else if (width >= 768) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Masaüstü için grid layout
  static Widget desktopGrid({
    required List<Widget> children,
    required BuildContext context,
    int? crossAxisCount,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) {
    final width = MediaQuery.of(context).size.width;
    final sidebarWidth = getSidebarWidth(context);
    final availableWidth = width - sidebarWidth - 32;
    
    int columns = crossAxisCount ?? 2;
    if (availableWidth >= 1600) columns = 3;
    if (availableWidth >= 2000) columns = 4;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio ?? 1.5,
        crossAxisSpacing: crossAxisSpacing ?? 16,
        mainAxisSpacing: mainAxisSpacing ?? 16,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  // Masaüstü için sidebar
  static Widget desktopSidebar({
    required List<Widget> children,
    required BuildContext context,
    Color? backgroundColor,
  }) {
    return Container(
      width: getSidebarWidth(context),
      color: backgroundColor ?? desktopSurface,
      child: Column(
        children: children,
      ),
    );
  }

  // Masaüstü için top bar
  static Widget desktopTopBar({
    required String title,
    required List<Widget> actions,
    Widget? leading,
    Color? backgroundColor,
  }) {
    return Container(
      height: topBarHeight,
      color: backgroundColor ?? desktopSurface,
      child: Row(
        children: [
          if (leading != null) leading,
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }

  // Masaüstü için panel
  static Widget desktopPanel({
    required Widget child,
    required BuildContext context,
    String? title,
    List<Widget>? actions,
    Color? backgroundColor,
  }) {
    return Container(
      width: getPanelWidth(context),
      color: backgroundColor ?? Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (actions != null) ...actions,
                ],
              ),
            ),
            const Divider(),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}
