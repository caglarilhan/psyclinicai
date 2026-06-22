import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// 6-tile feature grid — the differentiating capabilities, not generic EHR.
class FeatureGridSection extends StatelessWidget {
  const FeatureGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final features = <_Feature>[
      _Feature(
        icon: Icons.graphic_eq,
        title: 'Ambient AI Co-Pilot',
        body:
            'On-device transcription on iOS / Android via the platform speech engine; Claude Haiku 4.5 drafts SOAP / DAP / BIRP. No audio leaves the device on mobile.',
      ),
      _Feature(
        icon: Icons.receipt_long,
        title: 'Superbill PDF in one click',
        body:
            'Curated 12 mental-health CPT codes + 35 ICD-10. CMS-1500-aligned PDF clients submit to insurers.',
      ),
      _Feature(
        icon: Icons.show_chart,
        title: 'Measurement-Based Care',
        body:
            'PHQ-9 and GAD-7 with severity bands, self-harm flagging, and longitudinal trend dashboard.',
      ),
      _Feature(
        icon: Icons.warning_amber_rounded,
        title: 'Real-time risk detection',
        body:
            'Suicidal ideation, self-harm, and substance use phrases flagged inside the live session.',
      ),
      _Feature(
        icon: Icons.medication_outlined,
        title: 'E-prescription',
        body:
            'Global drug database + TR Medula / e-Reçete integration + drug-interaction alerts.',
      ),
      _Feature(
        icon: Icons.gavel_outlined,
        title: 'Multi-jurisdiction compliance',
        body:
            'HIPAA, GDPR, KVKK — same product, region-aware audit trail and DPA generator.',
      ),
    ];

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('Capabilities'),
          const SizedBox(height: 12),
          const SectionTitle('Six things legacy EHRs cannot do today.'),
          const SizedBox(height: 12),
          const SectionSubtitle(
            'Pick any of them — we built each one from primary clinical research, not 2010 templates.',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (ctx, c) {
              final cols = c.maxWidth >= 1024
                  ? 3
                  : c.maxWidth >= 640
                  ? 2
                  : 1;
              final cardW = (c.maxWidth - (cols - 1) * 24) / cols;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: features
                    .map(
                      (f) => SizedBox(
                        width: cardW,
                        child: HoverLift(
                          borderRadius: 18,
                          child: _FeatureTile(feature: f, theme: theme, cs: cs),
                        ),
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

class _Feature {
  _Feature({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.feature,
    required this.theme,
    required this.cs,
  });
  final _Feature feature;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: cs.primary, size: 22),
          ),
          const SizedBox(height: 18),
          Text(
            feature.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
