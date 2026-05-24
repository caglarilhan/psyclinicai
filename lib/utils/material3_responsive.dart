import 'package:flutter/material.dart';

enum Breakpoint { mobile, tablet, desktop, largeDesktop }

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Breakpoint breakpoint) builder;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        Breakpoint breakpoint;
        
        if (width <= 600) {
          breakpoint = Breakpoint.mobile;
        } else if (width <= 1024) {
          breakpoint = Breakpoint.tablet;
        } else if (width <= 1440) {
          breakpoint = Breakpoint.desktop;
        } else {
          breakpoint = Breakpoint.largeDesktop;
        }
        
        return builder(context, breakpoint);
      },
    );
  }
}

class Material3Responsive {
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 600) {
      return const EdgeInsets.all(16);
    } else if (width <= 1024) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  static double responsiveGap(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 600) {
      return 8;
    } else if (width <= 1024) {
      return 12;
    } else {
      return 16;
    }
  }

  static double responsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 600) {
      return 24;
    } else if (width <= 1024) {
      return 28;
    } else {
      return 32;
    }
  }

  static double responsiveBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 600) {
      return 12;
    } else if (width <= 1024) {
      return 16;
    } else {
      return 20;
    }
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, breakpoint) {
        int columns = crossAxisCount;
        
        switch (breakpoint) {
          case Breakpoint.mobile:
            columns = 2;
            break;
          case Breakpoint.tablet:
            columns = 3;
            break;
          case Breakpoint.desktop:
          case Breakpoint.largeDesktop:
            columns = 4;
            break;
        }
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          children: children,
        );
      },
    );
  }
}

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
    return ResponsiveLayoutBuilder(
      builder: (context, breakpoint) {
        TextStyle? responsiveStyle = style;
        
        if (style != null) {
          switch (breakpoint) {
            case Breakpoint.mobile:
              responsiveStyle = style!.copyWith(fontSize: (style!.fontSize ?? 14) * 0.9);
              break;
            case Breakpoint.tablet:
              responsiveStyle = style;
              break;
            case Breakpoint.desktop:
            case Breakpoint.largeDesktop:
              responsiveStyle = style!.copyWith(fontSize: (style!.fontSize ?? 14) * 1.1);
              break;
          }
        }
        
        return Text(
          text,
          style: responsiveStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, breakpoint) {
        EdgeInsetsGeometry? responsivePadding = padding;
        EdgeInsetsGeometry? responsiveMargin = margin;
        
        if (padding == null) {
          switch (breakpoint) {
            case Breakpoint.mobile:
              responsivePadding = const EdgeInsets.all(16);
              break;
            case Breakpoint.tablet:
              responsivePadding = const EdgeInsets.all(20);
              break;
            case Breakpoint.desktop:
            case Breakpoint.largeDesktop:
              responsivePadding = const EdgeInsets.all(24);
              break;
          }
        }
        
        if (margin == null) {
          switch (breakpoint) {
            case Breakpoint.mobile:
              responsiveMargin = const EdgeInsets.all(8);
              break;
            case Breakpoint.tablet:
              responsiveMargin = const EdgeInsets.all(12);
              break;
            case Breakpoint.desktop:
            case Breakpoint.largeDesktop:
              responsiveMargin = const EdgeInsets.all(16);
              break;
          }
        }
        
        return Card(
          margin: responsiveMargin,
          color: color,
          elevation: elevation ?? 2,
          child: Padding(
            padding: responsivePadding!,
            child: child,
          ),
        );
      },
    );
  }
}