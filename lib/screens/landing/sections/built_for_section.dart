import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// "Built for" — segment the audience early so the visitor self-identifies.
class BuiltForSection extends StatelessWidget {
  const BuiltForSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final cards = <_AudienceCard>[
      _AudienceCard(
        icon: Icons.person_outline,
        title: 'Solo therapists',
        bullets: const [
          'Reclaim 1–2 evening hours per day',
          'Generate insurance-ready superbills',
          'No IT team required',
        ],
      ),
      _AudienceCard(
        icon: Icons.medical_services_outlined,
        title: 'Psychiatrists',
        bullets: const [
          'DSM-5 / ICD-11 drafted from the conversation',
          'E-prescription with drug-interaction alerts',
          'Risk flag escalation in real time',
        ],
      ),
      _AudienceCard(
        icon: Icons.groups_outlined,
        title: 'Group practices',
        bullets: const [
          'Multi-clinician roles + RBAC',
          'Outcome dashboards across the panel',
          'Single-tenant billing + Stripe live mode',
        ],
      ),
    ];

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('Built for'),
          const SizedBox(height: 12),
          const SectionTitle('One product, three workflows.'),
          const SizedBox(height: 12),
          const SectionSubtitle(
              'PsyClinicAI adapts to your role — same data, different surface.'),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (ctx, c) {
              final isWide = c.maxWidth >= 900;
              return Wrap(
                spacing: LandingTokens.gridGap,
                runSpacing: LandingTokens.gridGap,
                children: cards
                    .map((card) => SizedBox(
                          width:
                              isWide ? (c.maxWidth - 48) / 3 : c.maxWidth,
                          child: _AudienceCardView(
                              card: card, theme: theme, cs: cs),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AudienceCard {
  _AudienceCard(
      {required this.icon, required this.title, required this.bullets});
  final IconData icon;
  final String title;
  final List<String> bullets;
}

class _AudienceCardView extends StatelessWidget {
  const _AudienceCardView(
      {required this.card, required this.theme, required this.cs});
  final _AudienceCard card;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(card.icon, color: cs.primary, size: 24),
          ),
          const SizedBox(height: 18),
          Text(card.title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...card.bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(b,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
