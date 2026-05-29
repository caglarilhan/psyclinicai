import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Final CTA — strong closing pitch before the footer.
class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({
    super.key,
    required this.onPrimary,
    required this.onSecondary,
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surfaceContainerLowest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              cs.primary,
              Color.lerp(cs.primary, Colors.black, 0.25) ?? cs.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Reclaim your evenings.',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                'Spend Sunday with your family, not your notes. '
                'Start free, keep your data, cancel anytime.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onPrimary,
                  icon: const Icon(Icons.rocket_launch, size: 18),
                  label: const Text('Start free 14-day trial'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 18),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSecondary,
                  icon: const Icon(Icons.event, size: 18),
                  label: const Text('Book a 20-min demo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 1.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 18),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Wrap(
              spacing: 18,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _Pill('No card required'),
                _Pill('Cancel anytime'),
                _Pill('Your data stays yours'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline,
            color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
