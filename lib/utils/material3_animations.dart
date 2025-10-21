import 'package:flutter/material.dart';

/// Material 3 animasyon yardımcı sınıfı
class Material3Animations {
  // Standart Material 3 animasyon süreleri
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration mediumDuration = Duration(milliseconds: 200);
  static const Duration longDuration = Duration(milliseconds: 300);
  
  // Material 3 easing curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve emphasizedCurve = Curves.easeOutCubic;
  static const Curve emphasizedDecelerateCurve = Curves.easeOutQuart;
  
  /// Kart hover animasyonu
  static Widget animatedCard({
    required Widget child,
    Duration duration = shortDuration,
    Curve curve = standardCurve,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
    );
  }
  
  /// Fade in animasyonu
  static Widget fadeIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = emphasizedCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Slide in animasyonu
  static Widget slideIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = emphasizedCurve,
    Offset beginOffset = const Offset(0, 0.3),
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: beginOffset, end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * MediaQuery.of(context).size.width,
            value.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Scale animasyonu
  static Widget scaleIn({
    required Widget child,
    Duration duration = shortDuration,
    Curve curve = emphasizedCurve,
    double beginScale = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: beginScale, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Staggered animasyon (sıralı animasyonlar)
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = mediumDuration,
    Curve curve = emphasizedCurve,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          duration: itemDuration + (staggerDelay * index),
          curve: curve,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, _) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
  
  /// Hero animasyonu için tag oluşturucu
  static String createHeroTag(String baseTag, String identifier) {
    return '${baseTag}_$identifier';
  }
  
  /// Page transition animasyonu
  static Route<T> createPageRoute<T extends Object?>(
    Widget page, {
    Duration duration = mediumDuration,
    Curve curve = emphasizedCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
  /// Modal bottom sheet animasyonu
  static Future<T?> showMaterial3BottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: child,
      ),
    );
  }
  
  /// Floating action button animasyonu
  static Widget animatedFAB({
    required Widget child,
    required VoidCallback? onPressed,
    Duration duration = shortDuration,
    Curve curve = emphasizedCurve,
  }) {
    return AnimatedScale(
      duration: duration,
      curve: curve,
      scale: onPressed != null ? 1.0 : 0.0,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
  
  /// Progress indicator animasyonu
  static Widget animatedProgress({
    required double value,
    Duration duration = mediumDuration,
    Curve curve = emphasizedCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: value),
      builder: (context, progress, child) {
        return LinearProgressIndicator(
          value: progress,
        );
      },
    );
  }
  
  /// Counter animasyonu
  static Widget animatedCounter({
    required int value,
    Duration duration = shortDuration,
    Curve curve = emphasizedCurve,
    TextStyle? style,
  }) {
    return TweenAnimationBuilder<int>(
      duration: duration,
      curve: curve,
      tween: IntTween(begin: 0, end: value),
      builder: (context, count, child) {
        return Text(
          count.toString(),
          style: style,
        );
      },
    );
  }
  
  /// Icon animasyonu
  static Widget animatedIcon({
    required IconData icon,
    Duration duration = shortDuration,
    Curve curve = emphasizedCurve,
    double? size,
    Color? color,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        );
      },
    );
  }
}

/// Material 3 transition mixin
mixin Material3Transitions<T extends StatefulWidget> on State<T> {
  /// Page transition için route oluşturucu
  Route<T> createTransitionRoute(Widget page) {
    return Material3Animations.createPageRoute(page);
  }
  
  /// Bottom sheet gösterici
  Future<T?> showBottomSheet(Widget child) {
    return Material3Animations.showMaterial3BottomSheet<T>(
      context: context,
      child: child,
    );
  }
}

/// Material 3 animasyonlu widget wrapper
class Material3AnimatedWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool animateOnMount;
  final VoidCallback? onAnimationComplete;
  
  const Material3AnimatedWidget({
    super.key,
    required this.child,
    this.duration = Material3Animations.mediumDuration,
    this.curve = Material3Animations.emphasizedCurve,
    this.animateOnMount = true,
    this.onAnimationComplete,
  });
  
  @override
  State<Material3AnimatedWidget> createState() => _Material3AnimatedWidgetState();
}

class _Material3AnimatedWidgetState extends State<Material3AnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    if (widget.animateOnMount) {
      _controller.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_animation),
            child: widget.child,
          ),
        );
      },
    );
  }
}
