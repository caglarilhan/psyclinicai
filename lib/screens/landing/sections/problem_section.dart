import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Problem statement — agitate the pain so the rest of the page has weight.
class ProblemSection extends StatelessWidget {
  const ProblemSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final stats = <_PainStat>[
      _PainStat(
        metric: '64 h',
        detail: 'wasted per clinician per quarter on documentation alone.',
      ),
      _PainStat(
        metric: '25%',
        detail: 'no-show rate — appointment reminders are usually manual.',
      ),
      _PainStat(
        metric: r'$11 k',
        detail:
            'in denied claims per clinician per year because of missing CPT/ICD-10 detail.',
      ),
    ];

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('The problem'),
          const SizedBox(height: 12),
          const SectionTitle(
            'Therapy practices burn out on paperwork,\nnot patients.',
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: const SectionSubtitle(
              'Documentation, insurance, and reporting take a third of every '
              "clinician's working week. Legacy EHRs designed in 2010 don't "
              'fix it — they just digitise the same forms.',
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (ctx, c) {
              final isWide = c.maxWidth >= 800;
              return Wrap(
                spacing: LandingTokens.gridGap,
                runSpacing: LandingTokens.gridGap,
                children: stats
                    .map(
                      (s) => SizedBox(
                        width: isWide ? (c.maxWidth - 48) / 3 : c.maxWidth,
                        child: _StatTile(stat: s, theme: theme, cs: cs),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PainStat {
  _PainStat({required this.metric, required this.detail});
  final String metric;
  final String detail;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat, required this.theme, required this.cs});
  final _PainStat stat;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.metric,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: cs.primary,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stat.detail,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
