import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';

class ProFadeTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool autoStart;
  final double beginOpacity;
  final double endOpacity;

  const ProFadeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.autoStart = true,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
  });

  @override
  State<ProFadeTransition> createState() => _ProFadeTransitionState();
}

class _ProFadeTransitionState extends State<ProFadeTransition>
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

    _animation = Tween<double>(
      begin: widget.beginOpacity,
      end: widget.endOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void start() {
    _controller.forward();
  }

  void reverse() {
    _controller.reverse();
  }

  void reset() {
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class ProSlideTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool autoStart;
  final Offset beginOffset;
  final Offset endOffset;

  const ProSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.autoStart = true,
    this.beginOffset = const Offset(0, 0.3),
    this.endOffset = Offset.zero,
  });

  @override
  State<ProSlideTransition> createState() => _ProSlideTransitionState();
}

class _ProSlideTransitionState extends State<ProSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void start() {
    _controller.forward();
  }

  void reverse() {
    _controller.reverse();
  }

  void reset() {
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

class ProScaleTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool autoStart;
  final double beginScale;
  final double endScale;

  const ProScaleTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.autoStart = true,
    this.beginScale = 0.0,
    this.endScale = 1.0,
  });

  @override
  State<ProScaleTransition> createState() => _ProScaleTransitionState();
}

class _ProScaleTransitionState extends State<ProScaleTransition>
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

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void start() {
    _controller.forward();
  }

  void reverse() {
    _controller.reverse();
  }

  void reset() {
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class ProShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool enabled;

  const ProShimmerEffect({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<ProShimmerEffect> createState() => _ProShimmerEffectState();
}

class _ProShimmerEffectState extends State<ProShimmerEffect>
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

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? (isDark ? AppColors.neutral800 : AppColors.neutral200);
    final highlightColor = widget.highlightColor ?? (isDark ? AppColors.neutral700 : AppColors.neutral100);

    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class ProShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ProShimmerCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardMargin = margin ?? AppSpacing.paddingAllMD;
    final cardPadding = padding ?? AppSpacing.paddingAllLG;

    return Container(
      width: width,
      height: height ?? 120,
      margin: cardMargin,
      padding: cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSpacing.elevationSm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ProShimmerEffect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSpacing.heightMD,
            Container(
              height: 16,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSpacing.heightSM,
            Container(
              height: 16,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProStaggeredAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool autoStart;
  final ProAnimationType animationType;
  final Offset beginOffset;
  final Offset endOffset;
  final double beginScale;
  final double endScale;
  final double beginOpacity;
  final double endOpacity;

  const ProStaggeredAnimation({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.delay = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
    this.autoStart = true,
    this.animationType = ProAnimationType.fade,
    this.beginOffset = const Offset(0, 0.3),
    this.endOffset = Offset.zero,
    this.beginScale = 0.0,
    this.endScale = 1.0,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
  });

  @override
  State<ProStaggeredAnimation> createState() => _ProStaggeredAnimationState();
}

class _ProStaggeredAnimationState extends State<ProStaggeredAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    if (widget.autoStart) {
      _startStaggeredAnimation();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: widget.beginOpacity,
        end: widget.endOpacity,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: widget.beginOffset,
        end: widget.endOffset,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: widget.beginScale,
        end: widget.endScale,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();
  }

  void _startStaggeredAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: widget.delay.inMilliseconds * i), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  void start() {
    _startStaggeredAnimation();
  }

  void reverse() {
    for (int i = _controllers.length - 1; i >= 0; i--) {
      Future.delayed(Duration(milliseconds: widget.delay.inMilliseconds * (_controllers.length - 1 - i)), () {
        if (mounted) {
          _controllers[i].reverse();
        }
      });
    }
  }

  void reset() {
    for (final controller in _controllers) {
      controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        Widget animatedChild;

        switch (widget.animationType) {
          case ProAnimationType.fade:
            animatedChild = FadeTransition(
              opacity: _opacityAnimations[index],
              child: child,
            );
            break;
          case ProAnimationType.slide:
            animatedChild = SlideTransition(
              position: _slideAnimations[index],
              child: child,
            );
            break;
          case ProAnimationType.scale:
            animatedChild = ScaleTransition(
              scale: _scaleAnimations[index],
              child: child,
            );
            break;
          case ProAnimationType.combined:
            animatedChild = FadeTransition(
              opacity: _opacityAnimations[index],
              child: SlideTransition(
                position: _slideAnimations[index],
                child: ScaleTransition(
                  scale: _scaleAnimations[index],
                  child: child,
                ),
              ),
            );
            break;
        }

        return animatedChild;
      }).toList(),
    );
  }
}

enum ProAnimationType {
  fade,
  slide,
  scale,
  combined,
}

class ProHoverEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double hoverScale;
  final double hoverElevation;
  final Color? hoverColor;
  final VoidCallback? onHoverEnter;
  final VoidCallback? onHoverExit;

  const ProHoverEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.hoverScale = 1.05,
    this.hoverElevation = 8.0,
    this.hoverColor,
    this.onHoverEnter,
    this.onHoverExit,
  });

  @override
  State<ProHoverEffect> createState() => _ProHoverEffectState();
}

class _ProHoverEffectState extends State<ProHoverEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.hoverElevation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (!_isHovered) {
      setState(() {
        _isHovered = true;
      });
      _controller.forward();
      widget.onHoverEnter?.call();
    }
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (_isHovered) {
      setState(() {
        _isHovered = false;
      });
      _controller.reverse();
      widget.onHoverExit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: _elevationAnimation.value,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class ProBounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double bounceHeight;
  final bool autoStart;
  final int repeatCount;

  const ProBounceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.elasticOut,
    this.bounceHeight = 20.0,
    this.autoStart = true,
    this.repeatCount = 1,
  });

  @override
  State<ProBounceAnimation> createState() => _ProBounceAnimationState();
}

class _ProBounceAnimationState extends State<ProBounceAnimation>
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

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.bounceHeight,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart) {
      _startBounce();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startBounce() {
    if (widget.repeatCount == -1) {
      _controller.repeat();
    } else {
      _controller.forward().then((_) {
        if (widget.repeatCount > 1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _startBounce();
            }
          });
        }
      });
    }
  }

  void start() {
    _startBounce();
  }

  void stop() {
    _controller.stop();
  }

  void reset() {
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: widget.child,
        );
      },
    );
  }
}
