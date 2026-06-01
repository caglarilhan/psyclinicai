import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// First screen shown on launch: brand-coloured background with the
/// PsyClinicAI logo + wordmark animating in, then pushes Landing.
/// Keeps the cold-start "feel" branded instead of a white flash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _scale =
      CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: const Interval(0.4, 1.0));

  Timer? _exit;

  @override
  void initState() {
    super.initState();
    _c.forward();
    // Hold the brand for a beat after the animation lands, then transition.
    _exit = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/landing');
    });
  }

  @override
  void dispose() {
    _exit?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.6, end: 1.0).animate(_scale),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: cs.onPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: cs.onPrimary.withValues(alpha: 0.25), width: 1),
                ),
                child: Icon(Icons.psychology,
                    color: cs.onPrimary, size: 52),
              ),
            ),
            const SizedBox(height: PsySpacing.xl),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(
                    'PsyClinicAI',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                  ),
                  const SizedBox(height: PsySpacing.xs),
                  Text(
                    'AI co-pilot for therapy sessions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.78),
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
