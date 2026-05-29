import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Founding-member testimonials placeholder. Honest pre-launch framing.
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key, required this.onCta});

  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surface,
      child: Column(
        children: [
          const SectionEyebrow('Founding members'),
          const SizedBox(height: 12),
          const SectionTitle('Your name belongs here.'),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const SectionSubtitle(
                'We are admitting the first 30 clinicians as founding members. '
                'You get six months at half price, a permanent founding rate, '
                'and a direct line to product decisions. We will quote you here '
                'when you are ready.',
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.12),
                  cs.primaryContainer.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Icon(Icons.format_quote, color: cs.primary, size: 36),
                const SizedBox(height: 12),
                Text(
                  'I review and edit the AI note in under 5 minutes.\n'
                  'That used to take me 45.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '— Reserved for founding member #1',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onCta,
            icon: const Icon(Icons.star_outline, size: 18),
            label: const Text('Claim a founding seat'),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
