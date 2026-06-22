import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Trust bar — small honest signals immediately under the hero.
/// Pre-launch, so we lead with credibility (compliance + tech) rather than
/// fake customer logos.
class TrustBarSection extends StatelessWidget {
  const TrustBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final items = <_TrustItem>[
      _TrustItem(icon: Icons.verified_user_outlined, label: 'HIPAA-aligned'),
      _TrustItem(icon: Icons.gavel_outlined, label: 'GDPR Article 28 DPA'),
      _TrustItem(icon: Icons.public, label: 'EU data residency'),
      _TrustItem(icon: Icons.lock_outline, label: 'AES-256 + TLS 1.3'),
      _TrustItem(icon: Icons.mic_off, label: 'On-device audio'),
      _TrustItem(icon: Icons.key, label: 'BYOK · keys stay with you'),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border.symmetric(
          horizontal: BorderSide(color: cs.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LandingTokens.maxContentWidth,
          ),
          child: Wrap(
            spacing: 36,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: items
                .map(
                  (it) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        it.icon,
                        size: 18,
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        it.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _TrustItem {
  _TrustItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
