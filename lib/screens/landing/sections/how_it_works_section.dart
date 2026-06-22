import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// "How it works" — 3-step explainer with numbered tiles.
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final steps = <_Step>[
      _Step(
        number: 1,
        icon: Icons.mic_none,
        title: 'Open a session on iPhone or Android, press Start',
        body:
            "On the iOS and Android apps, PsyClinicAI uses your operating system's on-device speech-to-text — no audio leaves the device. The Live AI panel shows the running transcript in real time. The web app is for review and manual entry.",
      ),
      _Step(
        number: 2,
        icon: Icons.auto_awesome,
        title: 'AI drafts your clinical note',
        body:
            'Press Stop. Claude Haiku 4.5 turns the transcript into a SOAP, DAP, or BIRP note in under 30 seconds, with risk language flagged.',
      ),
      _Step(
        number: 3,
        icon: Icons.task_alt,
        title: 'Review, save, bill',
        body:
            'Edit anything you want, save to the patient chart, then generate the superbill with one click — CPT + ICD-10 + provider info auto-filled.',
      ),
    ];

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('How it works'),
          const SizedBox(height: 12),
          const SectionTitle('Three steps. One workflow.'),
          const SizedBox(height: 12),
          const SectionSubtitle(
            'From a live session to an insurance-ready document, without leaving the app.',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (ctx, c) {
              final isWide = c.maxWidth >= 900;
              return Wrap(
                spacing: LandingTokens.gridGap,
                runSpacing: LandingTokens.gridGap,
                children: steps
                    .map(
                      (s) => SizedBox(
                        width: isWide ? (c.maxWidth - 48) / 3 : c.maxWidth,
                        child: _StepTile(step: s, theme: theme, cs: cs),
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

class _Step {
  _Step({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });
  final int number;
  final IconData icon;
  final String title;
  final String body;
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.theme, required this.cs});
  final _Step step;
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${step.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(step.icon, color: cs.primary, size: 22),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            step.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
