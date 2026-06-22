import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/compare` — programmatic-SEO landing comparing PsyClinicAI to
/// the categories of competing tools clinicians already evaluate.
class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Compare',
      title: 'How PsyClinicAI compares.',
      lede:
          'Honest, structured trade-offs against the EHRs and AI scribes '
          'mental-health practices already evaluate. We list where the '
          'competitor wins so you do not have to dig for it.',
      lastUpdated: DateTime(2026, 6, 2),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Comparison(
            name: 'vs. legacy EHR (SimplePractice, TherapyNotes)',
            wins: [
              'Audio stays on-device — competitor sends to cloud',
              'BYOK Anthropic — you control the AI model + cost',
              'EU residency baked in (eur3 / Frankfurt)',
              'Open superbill PDF that any clearinghouse can ingest',
            ],
            theyWin: [
              'Mature US claims clearinghouse integration today',
              'In-network insurance billing across all 50 states',
              'On-call US support staff during business hours',
            ],
          ),
          SizedBox(height: PsySpacing.lg),
          _Comparison(
            name: 'vs. AI scribe (Mentalyc, Eleos, Upheal)',
            wins: [
              'Full EHR workflow — scribe → note → superbill in one chart',
              'Region pin choice — competitors are US-only today',
              'GDPR Article 28 DPA + KVKK template ship before contract',
              'Risk escalation chain with audit, not just transcript',
            ],
            theyWin: [
              'Larger US training corpus on therapy-specific notes',
              'Tighter integration with their own scheduling product',
            ],
          ),
          SizedBox(height: PsySpacing.lg),
          _Comparison(
            name: 'vs. paper / generic SaaS (Notion, Google Docs)',
            wins: [
              'PHI-aware: HIPAA Security Rule + GDPR Art. 32 baked in',
              'Audit log with hash-chained integrity (HIPAA §164.312(b))',
              'Subject Access Request portal (GDPR Art. 15/20)',
              'Clinician signature workflow with the audit log entry',
            ],
            theyWin: [
              'Cheaper at zero patients',
              'More flexible for non-clinical workflows',
            ],
          ),
          SizedBox(height: PsySpacing.xxl),
        ],
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({
    required this.name,
    required this.wins,
    required this.theyWin,
  });

  final String name;
  final List<String> wins;
  final List<String> theyWin;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PsySpacing.md),
          Text(
            'Where we win',
            style: t.titleSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          for (final w in wins) StaticBullet(w),
          const SizedBox(height: PsySpacing.md),
          Text(
            'Where they win',
            style: t.titleSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          for (final w in theyWin) StaticBullet(w),
        ],
      ),
    );
  }
}
