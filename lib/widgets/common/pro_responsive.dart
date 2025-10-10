import 'package:flutter/material.dart';
import '../../utils/app_spacing.dart';

class ProResponsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ProResponsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ProBreakpoints.largeDesktop) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ProBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ProBreakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ProResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ProScreenSize screenSize) builder;

  const ProResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = _getScreenSize(constraints.maxWidth);
        return builder(context, screenSize);
      },
    );
  }

  ProScreenSize _getScreenSize(double width) {
    if (width >= ProBreakpoints.largeDesktop) {
      return ProScreenSize.largeDesktop;
    } else if (width >= ProBreakpoints.desktop) {
      return ProScreenSize.desktop;
    } else if (width >= ProBreakpoints.tablet) {
      return ProScreenSize.tablet;
    } else {
      return ProScreenSize.mobile;
    }
  }
}

class ProBreakpointBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile) mobileBuilder;
  final Widget Function(BuildContext context, bool isTablet)? tabletBuilder;
  final Widget Function(BuildContext context, bool isDesktop)? desktopBuilder;
  final Widget Function(BuildContext context, bool isLargeDesktop)? largeDesktopBuilder;

  const ProBreakpointBuilder({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
    this.largeDesktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        if (width >= ProBreakpoints.largeDesktop) {
          return largeDesktopBuilder?.call(context, true) ?? 
                 desktopBuilder?.call(context, false) ?? 
                 tabletBuilder?.call(context, false) ?? 
                 mobileBuilder(context, false);
        } else if (width >= ProBreakpoints.desktop) {
          return desktopBuilder?.call(context, true) ?? 
                 tabletBuilder?.call(context, false) ?? 
                 mobileBuilder(context, false);
        } else if (width >= ProBreakpoints.tablet) {
          return tabletBuilder?.call(context, true) ?? 
                 mobileBuilder(context, false);
        } else {
          return mobileBuilder(context, true);
        }
      },
    );
  }
}

class ProResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ProResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = mobileColumns;

        if (width >= ProBreakpoints.largeDesktop) {
          columns = largeDesktopColumns ?? desktopColumns ?? tabletColumns ?? mobileColumns;
        } else if (width >= ProBreakpoints.desktop) {
          columns = desktopColumns ?? tabletColumns ?? mobileColumns;
        } else if (width >= ProBreakpoints.tablet) {
          columns = tabletColumns ?? mobileColumns;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          crossAxisAlignment: crossAxisAlignment,
          alignment: mainAxisAlignment,
          children: children.map((child) {
            return SizedBox(
              width: (width - (spacing * (columns - 1))) / columns,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

class ProResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? largeDesktopWidth;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final EdgeInsets? largeDesktopPadding;
  final Alignment alignment;

  const ProResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.largeDesktopWidth,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.largeDesktopPadding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double? containerWidth;
        EdgeInsets? containerPadding;

        if (width >= ProBreakpoints.largeDesktop) {
          containerWidth = largeDesktopWidth ?? desktopWidth ?? tabletWidth ?? mobileWidth;
          containerPadding = largeDesktopPadding ?? desktopPadding ?? tabletPadding ?? mobilePadding;
        } else if (width >= ProBreakpoints.desktop) {
          containerWidth = desktopWidth ?? tabletWidth ?? mobileWidth;
          containerPadding = desktopPadding ?? tabletPadding ?? mobilePadding;
        } else if (width >= ProBreakpoints.tablet) {
          containerWidth = tabletWidth ?? mobileWidth;
          containerPadding = tabletPadding ?? mobilePadding;
        } else {
          containerWidth = mobileWidth;
          containerPadding = mobilePadding;
        }

        return Align(
          alignment: alignment,
          child: Container(
            width: containerWidth,
            padding: containerPadding,
            child: child,
          ),
        );
      },
    );
  }
}

class ProResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? mobileStyle;
  final TextStyle? tabletStyle;
  final TextStyle? desktopStyle;
  final TextStyle? largeDesktopStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ProResponsiveText({
    super.key,
    required this.text,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.largeDesktopStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        TextStyle? textStyle;

        if (width >= ProBreakpoints.largeDesktop) {
          textStyle = largeDesktopStyle ?? desktopStyle ?? tabletStyle ?? mobileStyle;
        } else if (width >= ProBreakpoints.desktop) {
          textStyle = desktopStyle ?? tabletStyle ?? mobileStyle;
        } else if (width >= ProBreakpoints.tablet) {
          textStyle = tabletStyle ?? mobileStyle;
        } else {
          textStyle = mobileStyle;
        }

        return Text(
          text,
          style: textStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

class ProResponsiveSpacing extends StatelessWidget {
  final Widget child;
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final double? largeDesktopSpacing;
  final ProSpacingDirection direction;

  const ProResponsiveSpacing({
    super.key,
    required this.child,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.largeDesktopSpacing,
    this.direction = ProSpacingDirection.all,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double? spacing;

        if (width >= ProBreakpoints.largeDesktop) {
          spacing = largeDesktopSpacing ?? desktopSpacing ?? tabletSpacing ?? mobileSpacing;
        } else if (width >= ProBreakpoints.desktop) {
          spacing = desktopSpacing ?? tabletSpacing ?? mobileSpacing;
        } else if (width >= ProBreakpoints.tablet) {
          spacing = tabletSpacing ?? mobileSpacing;
        } else {
          spacing = mobileSpacing;
        }

        if (spacing == null) return child;

        switch (direction) {
          case ProSpacingDirection.all:
            return Padding(
              padding: EdgeInsets.all(spacing),
              child: child,
            );
          case ProSpacingDirection.horizontal:
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: child,
            );
          case ProSpacingDirection.vertical:
            return Padding(
              padding: EdgeInsets.symmetric(vertical: spacing),
              child: child,
            );
          case ProSpacingDirection.top:
            return Padding(
              padding: EdgeInsets.only(top: spacing),
              child: child,
            );
          case ProSpacingDirection.bottom:
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: child,
            );
          case ProSpacingDirection.left:
            return Padding(
              padding: EdgeInsets.only(left: spacing),
              child: child,
            );
          case ProSpacingDirection.right:
            return Padding(
              padding: EdgeInsets.only(right: spacing),
              child: child,
            );
        }
      },
    );
  }
}

class ProResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget? desktopLayout;
  final Widget? largeDesktopLayout;
  final bool maintainAspectRatio;
  final double? aspectRatio;

  const ProResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.desktopLayout,
    this.largeDesktopLayout,
    this.maintainAspectRatio = false,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        Widget layout;

        if (width >= ProBreakpoints.largeDesktop) {
          layout = largeDesktopLayout ?? desktopLayout ?? tabletLayout ?? mobileLayout;
        } else if (width >= ProBreakpoints.desktop) {
          layout = desktopLayout ?? tabletLayout ?? mobileLayout;
        } else if (width >= ProBreakpoints.tablet) {
          layout = tabletLayout ?? mobileLayout;
        } else {
          layout = mobileLayout;
        }

        if (maintainAspectRatio && aspectRatio != null) {
          return AspectRatio(
            aspectRatio: aspectRatio!,
            child: layout,
          );
        }

        return layout;
      },
    );
  }
}

class ProResponsiveNavigation extends StatelessWidget {
  final List<ProNavigationItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final ProNavigationType mobileType;
  final ProNavigationType? tabletType;
  final ProNavigationType? desktopType;
  final ProNavigationType? largeDesktopType;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double? elevation;

  const ProResponsiveNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.mobileType = ProNavigationType.bottom,
    this.tabletType,
    this.desktopType,
    this.largeDesktopType,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        ProNavigationType navigationType = mobileType;

        if (width >= ProBreakpoints.largeDesktop) {
          navigationType = largeDesktopType ?? desktopType ?? tabletType ?? mobileType;
        } else if (width >= ProBreakpoints.desktop) {
          navigationType = desktopType ?? tabletType ?? mobileType;
        } else if (width >= ProBreakpoints.tablet) {
          navigationType = tabletType ?? mobileType;
        }

        switch (navigationType) {
          case ProNavigationType.bottom:
            return _buildBottomNavigation();
          case ProNavigationType.drawer:
            return _buildDrawerNavigation();
          case ProNavigationType.rail:
            return _buildRailNavigation();
          case ProNavigationType.tabs:
            return _buildTabsNavigation();
        }
      },
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      elevation: elevation,
      type: BottomNavigationBarType.fixed,
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: item.icon,
          activeIcon: item.activeIcon,
          label: item.label,
        );
      }).toList(),
    );
  }

  Widget _buildDrawerNavigation() {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;

          return ListTile(
            leading: isSelected ? item.activeIcon : item.icon,
            title: Text(
              item.label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedTileColor: selectedColor?.withValues(alpha: 0.1),
            onTap: () => onTap(index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRailNavigation() {
    return NavigationRail(
      backgroundColor: backgroundColor,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      selectedIconTheme: IconThemeData(color: selectedColor),
      unselectedIconTheme: IconThemeData(color: unselectedColor),
      selectedLabelTextStyle: TextStyle(color: selectedColor),
      unselectedLabelTextStyle: TextStyle(color: unselectedColor),
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: item.icon,
          selectedIcon: item.activeIcon,
          label: Text(item.label),
        );
      }).toList(),
    );
  }

  Widget _buildTabsNavigation() {
    return TabBar(
      controller: TabController(length: items.length, initialIndex: currentIndex),
      onTap: onTap,
      labelColor: selectedColor,
      unselectedLabelColor: unselectedColor,
      indicatorColor: selectedColor,
      tabs: items.map((item) {
        return Tab(
          icon: item.icon,
          text: item.label,
        );
      }).toList(),
    );
  }
}

class ProBreakpoints {
  static const double mobile = 0;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

enum ProScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

enum ProSpacingDirection {
  all,
  horizontal,
  vertical,
  top,
  bottom,
  left,
  right,
}

enum ProNavigationType {
  bottom,
  drawer,
  rail,
  tabs,
}

class ProNavigationItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;

  ProNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
