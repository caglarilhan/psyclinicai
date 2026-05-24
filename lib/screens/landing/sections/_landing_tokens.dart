import 'package:flutter/material.dart';

/// Shared spacing / typography tokens for landing-page sections.
/// Centralised so every section has the same rhythm. Sprint 4 moves these
/// under `lib/theme/` as part of the design system.
class LandingTokens {
  const LandingTokens._();

  static const double sectionVerticalPadding = 80;
  static const double sectionHorizontalPaddingDesktop = 64;
  static const double sectionHorizontalPaddingMobile = 24;
  static const double maxContentWidth = 1180;
  static const double gridGap = 24;

  static EdgeInsetsGeometry sectionPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = w >= 768
        ? sectionHorizontalPaddingDesktop
        : sectionHorizontalPaddingMobile;
    return EdgeInsets.symmetric(
      horizontal: h,
      vertical: sectionVerticalPadding,
    );
  }

  static Widget sectionContainer({
    required BuildContext context,
    required Widget child,
    Color? background,
  }) {
    return Container(
      width: double.infinity,
      color: background,
      padding: sectionPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Eyebrow label (small uppercase text above section titles).
class SectionEyebrow extends StatelessWidget {
  const SectionEyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
          ),
    );
  }
}

/// Standard section title (h2-equivalent).
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {this.textAlign, super.key});
  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final size = w >= 768 ? 40.0 : 30.0;
    return Text(
      text,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: size,
            fontWeight: FontWeight.bold,
            height: 1.15,
          ),
    );
  }
}

/// Standard section subtitle (lead paragraph below title).
class SectionSubtitle extends StatelessWidget {
  const SectionSubtitle(this.text, {this.textAlign, super.key});
  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
            height: 1.55,
          ),
    );
  }
}

/// Wraps a child with a subtle lift on hover (web).
///
/// On pointer enter: translate up by [lift] px, scale by [scale], and apply
/// a soft brand-tinted shadow. Animations use a 180 ms easeOut curve so the
/// effect feels responsive rather than springy.
class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.child,
    this.scale = 1.006,
    this.lift = 2,
    this.borderRadius = 12,
  });

  final Widget child;
  final double scale;
  final double lift;
  final double borderRadius;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _hover ? -widget.lift : 0.0)
          ..scale(_hover ? widget.scale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}
