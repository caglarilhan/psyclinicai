import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Signature entrance: content fades in and rises a few pixels once, on mount.
/// Stagger a group by passing increasing [delay]s. Honors the platform
/// reduced-motion setting (renders instantly), so the polish never fights
/// accessibility.
class PsyReveal extends StatefulWidget {
  const PsyReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 10,
  });

  final Widget child;
  final Duration delay;

  /// Vertical travel in logical pixels (starts [offset] below, settles at 0).
  final double offset;

  @override
  State<PsyReveal> createState() => _PsyRevealState();
}

class _PsyRevealState extends State<PsyReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: PsyMotion.slow,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: PsyMotion.emphasized,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _c.value = 1.0;
      return;
    }
    if (widget.delay == Duration.zero) {
      unawaited(_c.forward());
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) unawaited(_c.forward());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FadeTransition composites opacity (no per-frame child repaint the way
    // Opacity does); the small vertical rise stays on Transform.translate.
    // _t is easeOutCubic (no overshoot), so it stays within [0,1] for fade.
    return FadeTransition(
      opacity: _t,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - _t.value) * widget.offset),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
