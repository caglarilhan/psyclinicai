import 'package:flutter/material.dart';

/// Material 3 responsive tasarım yardımcı sınıfı
class Material3Responsive {
  // Breakpoint'ler
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  /// Ekran boyutuna göre breakpoint döndürür
  static Breakpoint getBreakpoint(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width <= mobileBreakpoint) {
      return Breakpoint.mobile;
    } else if (width <= tabletBreakpoint) {
      return Breakpoint.tablet;
    } else if (width <= desktopBreakpoint) {
      return Breakpoint.desktop;
    } else {
      return Breakpoint.largeDesktop;
    }
  }
  
  /// Mobile cihaz kontrolü
  static bool isMobile(BuildContext context) {
    return getBreakpoint(context) == Breakpoint.mobile;
  }
  
  /// Tablet cihaz kontrolü
  static bool isTablet(BuildContext context) {
    return getBreakpoint(context) == Breakpoint.tablet;
  }
  
  /// Desktop cihaz kontrolü
  static bool isDesktop(BuildContext context) {
    return getBreakpoint(context) == Breakpoint.desktop;
  }
  
  /// Large desktop cihaz kontrolü
  static bool isLargeDesktop(BuildContext context) {
    return getBreakpoint(context) == Breakpoint.largeDesktop;
  }
  
  /// Breakpoint'e göre değer döndürür
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final breakpoint = getBreakpoint(context);
    
    switch (breakpoint) {
      case Breakpoint.mobile:
        return mobile;
      case Breakpoint.tablet:
        return tablet ?? mobile;
      case Breakpoint.desktop:
        return desktop ?? tablet ?? mobile;
      case Breakpoint.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
  
  /// Responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
      vertical: responsiveValue(
        context,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
        largeDesktop: 32.0,
      ),
    );
  }
  
  /// Responsive gap
  static double responsiveGap(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    );
  }
  
  /// Responsive grid columns
  static int responsiveColumns(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }
  
  /// Responsive card aspect ratio
  static double responsiveCardAspectRatio(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 1.2,
      tablet: 1.3,
      desktop: 1.4,
      largeDesktop: 1.5,
    );
  }
  
  /// Responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
  
  /// Responsive icon size
  static double responsiveIconSize(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
      largeDesktop: 36.0,
    );
  }
  
  /// Responsive border radius
  static double responsiveBorderRadius(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
      largeDesktop: 24.0,
    );
  }
  
  /// Responsive elevation
  static double responsiveElevation(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 1.0,
      tablet: 2.0,
      desktop: 3.0,
      largeDesktop: 4.0,
    );
  }
}

/// Breakpoint enum
enum Breakpoint {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive widget wrapper
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  
  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material3Responsive.responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  });
  
  @override
  Widget build(BuildContext context) {
    final columns = Material3Responsive.responsiveColumns(context);
    final aspectRatio = childAspectRatio ?? 
        Material3Responsive.responsiveCardAspectRatio(context);
    final spacing = Material3Responsive.responsiveGap(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: crossAxisSpacing ?? spacing,
        mainAxisSpacing: mainAxisSpacing ?? spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive layout builder
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Breakpoint breakpoint) builder;
  
  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    final breakpoint = Material3Responsive.getBreakpoint(context);
    return builder(context, breakpoint);
  }
}

/// Responsive navigation widget
class ResponsiveNavigation extends StatelessWidget {
  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  
  const ResponsiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobile: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
      tablet: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((dest) => NavigationRailDestination(
          icon: dest.icon,
          label: Text(dest.label),
        )).toList(),
      ),
      desktop: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((dest) => NavigationRailDestination(
          icon: dest.icon,
          label: Text(dest.label),
        )).toList(),
        extended: true,
      ),
    );
  }
}

/// Responsive card widget
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = Material3Responsive.responsivePadding(context);
    final responsiveElevation = elevation ?? Material3Responsive.responsiveElevation(context);
    final responsiveBorderRadius = borderRadius ?? 
        BorderRadius.circular(Material3Responsive.responsiveBorderRadius(context));
    
    return Card(
      elevation: responsiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: responsiveBorderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: responsiveBorderRadius,
        child: Padding(
          padding: padding ?? responsivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveStyle = style?.copyWith(
      fontSize: style?.fontSize != null 
          ? Material3Responsive.responsiveFontSize(
              context, 
              mobile: style!.fontSize!,
            )
          : null,
    );
    
    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final Widget child;
  final double? horizontal;
  final double? vertical;
  final double? all;
  
  const ResponsiveSpacing({
    super.key,
    required this.child,
    this.horizontal,
    this.vertical,
    this.all,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveGap = Material3Responsive.responsiveGap(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ?? all ?? responsiveGap,
        vertical: vertical ?? all ?? responsiveGap,
      ),
      child: child,
    );
  }
}
