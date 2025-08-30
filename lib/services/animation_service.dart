import 'package:flutter/material.dart';

class AnimationService {
  static const Duration _defaultDuration = Duration(milliseconds: 300);
  static const Curve _defaultCurve = Curves.easeInOut;

  // Sayfa geçiş animasyonları
  static PageRouteBuilder<T> createPageRoute<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = _defaultDuration,
    Curve curve = _defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Fade animasyonu
  static Widget fadeIn({
    required Widget child,
    Duration duration = _defaultDuration,
    Curve curve = _defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide animasyonu
  static Widget slideIn({
    required Widget child,
    Duration duration = _defaultDuration,
    Curve curve = _defaultCurve,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale animasyonu
  static Widget scaleIn({
    required Widget child,
    Duration duration = _defaultDuration,
    Curve curve = _defaultCurve,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Loading animasyonu
  static Widget loadingAnimation({
    double size = 40,
    Color? color,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.blue,
        ),
      ),
    );
  }

  // Pulse animasyonu
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 1.0, end: 1.1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Shake animasyonu
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double intensity = 10,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final shake = intensity * (1 - value) * (value * 2 - 1);
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Bounce animasyonu
  static Widget bounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered animasyonlar için
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = _defaultDuration,
    Curve curve = _defaultCurve,
  }) {
    return List.generate(children.length, (index) {
      return TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: children[index],
      );
    });
  }

  // Hover efekti
  static Widget hoverEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
    double hoverScale = 1.05,
    double hoverElevation = 8,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: duration,
            transform: Matrix4.identity()
              ..scale(isHovered ? hoverScale : 1.0),
            child: AnimatedContainer(
              duration: duration,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isHovered ? 0.2 : 0.1),
                    blurRadius: isHovered ? hoverElevation : 4,
                    offset: Offset(0, isHovered ? 4 : 2),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // Skeleton loading
  static Widget skeletonLoading({
    double width = double.infinity,
    double height = 20,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1500),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: null,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.grey[400]!,
            ),
          );
        },
      ),
    );
  }

  // Success animasyonu
  static Widget successAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Error animasyonu
  static Widget errorAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(10 * (value * 2 - 1), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
