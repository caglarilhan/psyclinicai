import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Design-system button. Replaces ad-hoc FilledButton/OutlinedButton calls
/// with a consistent surface that has size + variant + loading + icon
/// support out of the box.
enum PsyButtonVariant { primary, secondary, ghost, destructive }

enum PsyButtonSize { sm, md, lg }

class PsyButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null || loading;

    final pad = switch (size) {
      PsyButtonSize.sm =>
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      PsyButtonSize.md =>
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      PsyButtonSize.lg =>
        const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
    };
    final fontSize = switch (size) {
      PsyButtonSize.sm => 13.0,
      PsyButtonSize.md => 14.0,
      PsyButtonSize.lg => 15.0,
    };
    final iconSize = switch (size) {
      PsyButtonSize.sm => 16.0,
      PsyButtonSize.md => 18.0,
      PsyButtonSize.lg => 20.0,
    };
    final radius = BorderRadius.circular(PsyRadius.md);

    final (bg, fg, border) = switch (variant) {
      PsyButtonVariant.primary => (cs.primary, cs.onPrimary, null),
      PsyButtonVariant.secondary => (
          cs.surface,
          cs.onSurface,
          BorderSide(color: cs.outlineVariant),
        ),
      PsyButtonVariant.ghost => (Colors.transparent, cs.primary, null),
      PsyButtonVariant.destructive => (cs.error, cs.onError, null),
    };

    final child = AnimatedSwitcher(
      duration: PsyMotion.fast,
      child: loading
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
                  fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: fullWidth
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: iconSize),
                  const SizedBox(width: PsySpacing.sm),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: PsySpacing.sm),
                  Icon(trailingIcon, size: iconSize),
                ],
              ],
            ),
    );

    final button = Material(
      color: isDisabled ? bg.withValues(alpha: 0.5) : bg,
      borderRadius: radius,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: PsyMotion.fast,
          padding: pad,
          decoration: BoxDecoration(
            borderRadius: radius,
            border:
                border != null ? Border.fromBorderSide(border) : null,
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: fg),
            child: IconTheme(
              data: IconThemeData(color: fg, size: iconSize),
              child: child,
            ),
          ),
        ),
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
