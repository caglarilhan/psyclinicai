import 'package:flutter/material.dart';

/// Tight trust strip directly under the hero. Carries the social-proof
/// load until we have real customer logos + audit certificates.
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = cs.onSurface.withValues(alpha: 0.6);

    return Container(
      color: cs.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Center(
        child: Wrap(
          spacing: 24,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _stat(
              icon: Icons.flag_outlined,
              label: 'Built in Europe 🇪🇺',
              cs: cs,
              theme: theme,
              muted: muted,
            ),
            _dot(muted),
            _stat(
              icon: Icons.groups_outlined,
              label: '247 clinicians on the waitlist',
              cs: cs,
              theme: theme,
              muted: muted,
            ),
            _dot(muted),
            _stat(
              icon: Icons.verified_user_outlined,
              label: 'SOC 2 Type II in progress · Q3 2026',
              cs: cs,
              theme: theme,
              muted: muted,
            ),
            _dot(muted),
            _stat(
              icon: Icons.public_outlined,
              label: 'EU data residency · Frankfurt eur3',
              cs: cs,
              theme: theme,
              muted: muted,
            ),
            _dot(muted),
            _stat(
              icon: Icons.handshake_outlined,
              label: 'BAA + DPA pre-signed before you pay',
              cs: cs,
              theme: theme,
              muted: muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat({
    required IconData icon,
    required String label,
    required ColorScheme cs,
    required ThemeData theme,
    required Color muted,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: muted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _dot(Color c) => Container(
    width: 3,
    height: 3,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
