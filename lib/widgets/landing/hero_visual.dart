import 'package:flutter/material.dart';

/// 3-pane product mockup for the hero. A primary "browser window" carries
/// the live session screen; two smaller windows (dashboard + superbill)
/// float behind to communicate breadth at a glance.
///
/// Subtle entrance + idle float animations give a polished "alive" feel
/// without depending on a third-party motion library.
class HeroVisual extends StatefulWidget {
  const HeroVisual({super.key});

  @override
  State<HeroVisual> createState() => _HeroVisualState();
}

class _HeroVisualState extends State<HeroVisual>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entry.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 5 / 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.20),
              cs.primaryContainer.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.22),
              blurRadius: 56,
              offset: const Offset(0, 32),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (ctx, c) {
            // Compact mobile (< 480px) → single full-bleed panel.
            // Anything wider keeps the 3-panel mockup.
            if (c.maxWidth < 480) {
              return Center(
                child: _floatedSlide(
                  delay: 0,
                  dx: 0,
                  floatY: 4,
                  elevated: true,
                  child: _BrowserWindow(
                    title: 'psyclinicai.com/session/live',
                    asset: 'assets/landing/session.png',
                    cs: cs,
                    pulseDot: true,
                  ),
                ),
              );
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: c.maxWidth * 0.55,
                  child: _floatedSlide(
                    delay: 200,
                    dx: -28,
                    floatY: 6,
                    child: _BrowserWindow(
                      title: 'psyclinicai.com/dashboard',
                      asset: 'assets/landing/dashboard.png',
                      cs: cs,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 12,
                  width: c.maxWidth * 0.58,
                  child: _floatedSlide(
                    delay: 350,
                    dx: 32,
                    floatY: -8,
                    child: _BrowserWindow(
                      title: 'psyclinicai.com/superbill',
                      asset: 'assets/landing/superbill.png',
                      cs: cs,
                    ),
                  ),
                ),
                Positioned(
                  left: c.maxWidth * 0.12,
                  top: c.maxHeight * 0.12,
                  width: c.maxWidth * 0.78,
                  child: _floatedSlide(
                    delay: 0,
                    dx: 0,
                    floatY: 4,
                    elevated: true,
                    child: _BrowserWindow(
                      title: 'psyclinicai.com/session/live',
                      asset: 'assets/landing/session.png',
                      cs: cs,
                      pulseDot: true,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _floatedSlide({
    required Widget child,
    required int delay,
    required double dx,
    required double floatY,
    bool elevated = false,
  }) {
    final entryCurve = CurvedAnimation(
      parent: _entry,
      curve: Interval(
        delay / 900,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _float]),
      builder: (_, c) {
        final entryT = entryCurve.value;
        final floatT = (_float.value - 0.5) * 2;
        return Opacity(
          opacity: entryT,
          child: Transform.translate(
            offset: Offset(
              dx * (1 - entryT),
              16 * (1 - entryT) + floatT * floatY,
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              scale: elevated ? 1.0 : 0.97,
              child: c,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _BrowserWindow extends StatelessWidget {
  const _BrowserWindow({
    required this.title,
    required this.asset,
    required this.cs,
    this.pulseDot = false,
  });

  final String title;
  final String asset;
  final ColorScheme cs;
  final bool pulseDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chrome(title: title, cs: cs, pulseDot: pulseDot),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              semanticLabel:
                  'Product screenshot showing the $title interface',
              errorBuilder: (_, __, ___) => Container(
                color: cs.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Text(
                  asset.split('/').last,
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chrome extends StatelessWidget {
  const _Chrome(
      {required this.title, required this.cs, required this.pulseDot});
  final String title;
  final ColorScheme cs;
  final bool pulseDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          _dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 6),
          _dot(const Color(0xFFFEBC2E)),
          const SizedBox(width: 6),
          _dot(const Color(0xFF28C840)),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline,
                      size: 12,
                      color: cs.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  if (pulseDot) ...[
                    const SizedBox(width: 6),
                    const _LiveDot(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444)
                    .withValues(alpha: 0.55 + 0.45 * _c.value),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'LIVE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
                letterSpacing: 0.6,
              ),
            ),
          ],
        );
      },
    );
  }
}
