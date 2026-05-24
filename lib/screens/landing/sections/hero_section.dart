import 'package:flutter/material.dart';

import '../../../widgets/landing/hero_visual.dart';
import '_landing_tokens.dart';

/// Hero section — first viewport, drives the primary CTA.
class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onPrimaryCta,
    required this.onSecondaryCta,
  });

  final VoidCallback onPrimaryCta;
  final VoidCallback onSecondaryCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 1024;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(40),
            border:
                Border.all(color: cs.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FOUNDING ACCESS · 18 of 30 seats left',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your AI co-pilot\nfor therapy sessions.',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: isWide ? 56 : 38,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Notes drafted in 30 seconds. Superbill PDF in one click. '
          'Audio never leaves the device.',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.78),
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'PsyClinicAI listens on-device, drafts a clinical-grade SOAP / '
          'DAP / BIRP note, and generates the CMS-1500-aligned superbill — '
          'so you spend Sunday with your family, not your notes.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.68),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _TrustChip(
                icon: Icons.verified_user_outlined,
                label: 'HIPAA-aligned'),
            _TrustChip(
                icon: Icons.gavel_outlined, label: 'GDPR Article 28 DPA'),
            _TrustChip(
                icon: Icons.public_outlined, label: 'EU data residency'),
            _TrustChip(
                icon: Icons.mic_off_outlined,
                label: 'Audio stays on-device'),
            _TrustChip(
                icon: Icons.lock_outline, label: 'AES-256 + TLS 1.3'),
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: onPrimaryCta,
              icon: const Icon(Icons.rocket_launch, size: 18),
              label: const Text('Reserve a founding seat'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 26, vertical: 18),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton.icon(
              onPressed: onSecondaryCta,
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: const Text('Watch 90-sec demo'),
              style: TextButton.styleFrom(
                foregroundColor: cs.onSurface,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'No credit card required during pilot · Cancel anytime · '
          'Export every byte as JSON + PDF on demand.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            height: 1.55,
          ),
        ),
      ],
    );

    const visual = HeroVisual();

    return LandingTokens.sectionContainer(
      context: context,
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: copy),
                const SizedBox(width: 48),
                Expanded(flex: 6, child: visual),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 48),
                visual,
              ],
            ),
    );
  }
}

/// Inline trust chip — what Upheal puts SOC2/HIPAA badges for; we use the
/// honest signals we can defend today.
class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}
