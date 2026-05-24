import 'package:flutter/material.dart';

class Material3Animations {
  // Animated Icon
  static Widget animatedIcon({
    required IconData icon,
    required Color color,
    required double size,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            icon,
            color: color,
            size: size,
          ),
        );
      },
    );
  }

  // Animated Counter
  static Widget animatedCounter({
    required int value,
    required TextStyle? style,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<int>(
      duration: duration,
      tween: Tween(begin: 0, end: value),
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }

  // Scale In Animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Animated Card
  static Widget animatedCard({
    required Widget child,
    VoidCallback? onTap,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  // Staggered List Animation
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }

  // Material 3 Bottom Sheet
  static void showMaterial3BottomSheet({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool showDragHandle = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      useSafeArea: true,
      builder: (context) => child,
    );
  }

  // Fade In Animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
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

  // Slide In Animation
  static Widget slideIn({
    required Widget child,
    Offset offset = const Offset(0, 1),
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween(begin: offset, end: Offset.zero),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Bounce Animation
  static Widget bounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Rotation Animation
  static Widget rotate({
    required Widget child,
    double turns = 1.0,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: turns),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }
}