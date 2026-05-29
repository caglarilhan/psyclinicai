import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Design-system button. Replaces ad-hoc FilledButton/OutlinedButton calls
/// with a consistent surface that has size + variant + loading + icon support.
///
/// Tactile by design: filled buttons lift on hover with a soft brand-tinted
/// shadow, ghost/secondary buttons tint their surface, every variant scales
/// down a touch on press, and keyboard focus draws a visible ring. The point
/// is that a click should *feel* like pressing something physical.
enum PsyButtonVariant { primary, secondary, ghost, destructive }

enum PsyButtonSize { sm, md, lg }

class PsyButton extends StatefulWidget {
  const PsyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PsyButtonVariant.primary,
    this.size = PsyButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PsyButtonVariant variant;
  final PsyButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;

  @override
  State<PsyButton> createState() => _PsyButtonState();
}

class _PsyButtonState extends State<PsyButton> {
  bool _hover = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null || widget.loading;

    final pad = switch (widget.size) {
      PsyButtonSize.sm =>
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      PsyButtonSize.md =>
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      PsyButtonSize.lg =>
        const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
    };
    final fontSize = switch (widget.size) {
      PsyButtonSize.sm => 13.0,
      PsyButtonSize.md => 14.0,
      PsyButtonSize.lg => 15.0,
    };
    final iconSize = switch (widget.size) {
      PsyButtonSize.sm => 16.0,
      PsyButtonSize.md => 18.0,
      PsyButtonSize.lg => 20.0,
    };
    final radius = BorderRadius.circular(PsyRadius.md);

    final (baseBg, fg, hasBorder, isFilled) = switch (widget.variant) {
      PsyButtonVariant.primary => (cs.primary, cs.onPrimary, false, true),
      PsyButtonVariant.secondary => (cs.surface, cs.onSurface, true, false),
      PsyButtonVariant.ghost => (Colors.transparent, cs.primary, false, false),
      PsyButtonVariant.destructive => (cs.error, cs.onError, false, true),
    };

    final active = !isDisabled;
    final hovered = active && _hover;

    // Resolve hover-aware surface + border.
    Color bg = baseBg;
    Color borderColor = cs.outlineVariant;
    if (!isFilled && hovered) {
      bg = cs.primary.withValues(
          alpha: widget.variant == PsyButtonVariant.ghost ? 0.08 : 0.05);
      borderColor = cs.primary.withValues(alpha: 0.40);
    }
    if (isDisabled) bg = baseBg.withValues(alpha: 0.5);

    // Filled buttons gain a soft brand-tinted shadow + 1px lift on hover.
    final shadows = (isFilled && hovered)
        ? [
            BoxShadow(
              color: baseBg.withValues(alpha: 0.38),
              blurRadius: 18,
              spreadRadius: -2,
              offset: const Offset(0, 6),
            ),
          ]
        : const <BoxShadow>[];

    final child = AnimatedSwitcher(
      duration: PsyMotion.fast,
      child: widget.loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDisabled ? cs.onSurface.withValues(alpha: 0.4) : fg,
                ),
              ),
            )
          : Row(
              key: const ValueKey('content'),
              mainAxisSize:
                  widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: widget.fullWidth
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: iconSize),
                  const SizedBox(width: PsySpacing.sm),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                if (widget.trailingIcon != null) ...[
                  const SizedBox(width: PsySpacing.sm),
                  Icon(widget.trailingIcon, size: iconSize),
                ],
              ],
            ),
    );

    final surface = AnimatedContainer(
      duration: PsyMotion.fast,
      curve: PsyMotion.standard,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, isFilled && hovered ? -1.0 : 0.0, 0.0, 1.0),
      transformAlignment: Alignment.center,
      padding: pad,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: hasBorder ? Border.all(color: borderColor) : null,
        boxShadow: shadows,
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: fg),
        child: IconTheme(
          data: IconThemeData(color: fg, size: iconSize),
          child: child,
        ),
      ),
    );

    final pressable = AnimatedScale(
      scale: active && _pressed ? 0.97 : 1.0,
      duration: PsyMotion.instant,
      curve: PsyMotion.standard,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          onHover: (h) => setState(() => _hover = h),
          onHighlightChanged: (p) => setState(() => _pressed = p),
          onFocusChange: (f) => setState(() => _focused = f),
          borderRadius: radius,
          // Hover/highlight handled by our own animation; suppress defaults.
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          child: surface,
        ),
      ),
    );

    // Keyboard focus ring (premium a11y) — drawn outside the surface.
    final ringed = AnimatedContainer(
      duration: PsyMotion.fast,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PsyRadius.md + 2),
        border: Border.all(
          color: _focused
              ? cs.primary.withValues(alpha: 0.45)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: pressable,
    );

    return widget.fullWidth
        ? SizedBox(width: double.infinity, child: ringed)
        : ringed;
  }
}
