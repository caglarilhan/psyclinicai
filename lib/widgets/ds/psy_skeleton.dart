/// Animated placeholder primitives for loading states.
///
/// A clinician opening PatientList, Caseload, Outcomes, or the
/// dashboard activity feed should never see a blank canvas before
/// the data lands. Skeleton blocks tell them "the layout is here,
/// rows are loading" without the jarring jump from spinner →
/// content that a bare CircularProgressIndicator creates.
///
/// All variants share a single pulse animation so the page reads
/// as one unit instead of a row of mismatched blinkers. The
/// animation respects `MediaQuery.disableAnimationsOf` (WCAG 2.3.3):
/// when reduce-motion is on, the placeholder freezes at the
/// neutral midpoint instead of pulsing.
///
/// Usage:
/// ```dart
/// const PsySkeletonLine(width: 180, height: 14);          // text line
/// const PsySkeletonBlock(height: 72);                     // tile
/// const PsySkeletonCircle(size: 44);                      // avatar
/// PsySkeletonList(itemBuilder: (_) => const _PatientPlaceholder());
/// ```
library;

import 'dart:async';

import 'package:flutter/material.dart';

/// Heartbeat that drives every visible PsySkeleton on the screen so
/// they pulse in unison. Pulled into its own controller so the
/// whole list is one repaint, not N independent animations.
class _PulseController extends ChangeNotifier {
  _PulseController({required TickerProvider vsync}) {
    _ctrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1100),
    );
    _anim = Tween<double>(begin: 0.4, end: 0.85).animate(_ctrl);
    _anim.addListener(notifyListeners);
    unawaited(_ctrl.repeat(reverse: true));
  }

  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  double get value => _anim.value;

  void pause() => _ctrl.stop();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

/// Wraps a subtree so every nested [PsySkeletonLine] /
/// [PsySkeletonBlock] / [PsySkeletonCircle] gets the same pulse
/// alpha — without each one owning its own AnimationController.
///
/// You usually do NOT need to wrap manually; [PsySkeletonList]
/// inserts one for you.
class PsySkeletonGroup extends StatefulWidget {
  const PsySkeletonGroup({super.key, required this.child});
  final Widget child;

  @override
  State<PsySkeletonGroup> createState() => _PsySkeletonGroupState();

  static double? alphaOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_PsySkeletonPulseScope>()
        ?.alpha;
  }
}

class _PsySkeletonGroupState extends State<PsySkeletonGroup>
    with SingleTickerProviderStateMixin {
  late final _PulseController _pulse = _PulseController(vsync: this);
  bool _frozen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && !_frozen) {
      _pulse.pause();
      _frozen = true;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading content',
      container: true,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => _PsySkeletonPulseScope(
          alpha: _frozen ? 0.6 : _pulse.value,
          child: widget.child,
        ),
      ),
    );
  }
}

class _PsySkeletonPulseScope extends InheritedWidget {
  const _PsySkeletonPulseScope({required this.alpha, required super.child});
  final double alpha;

  @override
  bool updateShouldNotify(_PsySkeletonPulseScope oldWidget) =>
      alpha != oldWidget.alpha;
}

/// Solid skeleton shape with a pulse-driven alpha. Falls back to a
/// flat alpha when not inside a [PsySkeletonGroup] so individual
/// blocks still render reasonably outside a group context.
class _SkeletonShape extends StatelessWidget {
  const _SkeletonShape({
    required this.width,
    required this.height,
    required this.shape,
  });
  final double? width;
  final double height;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final alpha = PsySkeletonGroup.alphaOf(context) ?? 0.6;
    // Pulse opacity range bumped from 0.18 to 0.28 so a fully-skeleton
    // screen is still perceivable for low-vision clinicians (WCAG
    // 1.3.1 — loading state must remain detectable).
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: alpha * 0.28),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(6)
            : null,
      ),
    );
  }
}

/// Single short line — text placeholder. Default height matches
/// `bodyMedium`'s line-box, but pass explicit [height] to align with
/// titleLarge, displaySmall, etc.
class PsySkeletonLine extends StatelessWidget {
  const PsySkeletonLine({super.key, this.width = 120, this.height = 14});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      _SkeletonShape(width: width, height: height, shape: BoxShape.rectangle);
}

/// Filled rectangle — card/tile placeholder. Default [height] sits
/// at the same vertical rhythm as a `PsyCard` row.
class PsySkeletonBlock extends StatelessWidget {
  const PsySkeletonBlock({super.key, this.width, this.height = 72});
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      _SkeletonShape(width: width, height: height, shape: BoxShape.rectangle);
}

/// Circular placeholder — for avatars / profile dots. [size] is
/// both width and height (CircleAvatar uses a radius, this uses a
/// diameter — divide by 2 if you're matching an avatar radius).
class PsySkeletonCircle extends StatelessWidget {
  const PsySkeletonCircle({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) =>
      _SkeletonShape(width: size, height: size, shape: BoxShape.circle);
}

/// Ready-made skeleton list — wraps [count] copies of [itemBuilder]
/// inside a [PsySkeletonGroup] so every block pulses together.
/// Use it as the "waiting" return inside a `StreamBuilder` /
/// `FutureBuilder` to replace bare CircularProgressIndicators.
class PsySkeletonList extends StatelessWidget {
  const PsySkeletonList({
    super.key,
    required this.itemBuilder,
    this.count = 6,
    this.separator = const SizedBox(height: 12),
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });
  final Widget Function(BuildContext context) itemBuilder;
  final int count;
  final Widget separator;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return PsySkeletonGroup(
      child: ListView.separated(
        padding: padding,
        itemCount: count,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => separator,
        itemBuilder: (ctx, _) => itemBuilder(ctx),
      ),
    );
  }
}
