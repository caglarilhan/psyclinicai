import 'package:flutter/material.dart';

import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';

/// Small pill badge — severity / status / count.
enum PsyBadgeTone { neutral, info, success, warning, danger, brand }

class PsyBadge extends StatelessWidget {
  const PsyBadge({
    super.key,
    required this.label,
    this.tone = PsyBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final PsyBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    // Info badge text on the dark surface fails WCAG AA (4.5:1) at
    // PsyColors.info — pick the lighter variant in dark mode so the
    // label clears the threshold (~8.7:1).
    final base = switch (tone) {
      PsyBadgeTone.neutral => cs.onSurface,
      PsyBadgeTone.info => isDark ? PsyColors.infoDark : PsyColors.info,
      PsyBadgeTone.success => PsyColors.success,
      PsyBadgeTone.warning => PsyColors.warning,
      PsyBadgeTone.danger => cs.error,
      PsyBadgeTone.brand => cs.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.md,
        vertical: PsySpacing.xs,
      ),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PsyRadius.full),
        border: Border.all(color: base.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: base),
            const SizedBox(width: PsySpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: base,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
