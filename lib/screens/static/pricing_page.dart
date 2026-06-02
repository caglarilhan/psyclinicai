import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/pricing` — addresses the seo-audit + cpo-advisor finding in
/// rapor 12: no public pricing closes a major conversion path.
class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Plans',
      title: 'Simple pricing. No per-patient surprise.',
      lede:
          'Every plan ships AI-drafted notes, CMS-1500 superbills, audit '
          'log, GDPR DPA and HIPAA BAA on request. You scale by clinicians '
          'and AI throughput — never by chart count.',
      lastUpdated: DateTime(2026, 6, 2),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaticH2('Plans'),
          _PlanRow(
            name: 'Solo',
            price: '\$49 / clinician / month',
            blurb: 'For a single licensed clinician with up to 60 active '
                'patients. Includes BYOK Anthropic + Daily.co telehealth '
                'early access.',
            included: [
              'AI session notes (SOAP / DAP / BIRP)',
              'CMS-1500 superbill PDF',
              'PHQ-9 / GAD-7 / C-SSRS / PCL-5 / AUDIT scales',
              'Audit log with 6-year retention',
              'EU + US data residency choice',
            ],
          ),
          SizedBox(height: PsySpacing.lg),
          _PlanRow(
            name: 'Practice',
            price: '\$39 / clinician / month (min 3)',
            blurb: 'Multi-clinician practices with supervision, group '
                'therapy and pre-authorisation workflows.',
            included: [
              'Everything in Solo',
              'Supervision queue + trainee co-sign',
              'Group session rosters',
              'Insurance pre-auth tracking',
              'Outcomes dashboard caseload roll-up',
            ],
          ),
          SizedBox(height: PsySpacing.lg),
          _PlanRow(
            name: 'Enterprise',
            price: 'Custom — talk to us',
            blurb: 'Larger groups, hospitals, training programmes.',
            included: [
              'Everything in Practice',
              'Multi-tenant org switcher + SSO (SAML / OIDC)',
              'Dedicated CISO + DPO contact',
              'Custom SLA + on-call rotation',
              'BAA + DPA + RoPA bundles',
            ],
          ),
          SizedBox(height: PsySpacing.xxl),
          StaticH2('What is NOT a hidden cost'),
          StaticBullet(
              'BYOK: you pay Anthropic directly for AI tokens '
              '(~\$0.001 per 5-minute session on Haiku 4.5).'),
          StaticBullet(
              'Stripe fees pass through; we do not mark them up.'),
          StaticBullet(
              'No per-patient, per-note, per-superbill micro-charges.'),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.name,
    required this.price,
    required this.blurb,
    required this.included,
  });

  final String name;
  final String price;
  final String blurb;
  final List<String> included;

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
          Row(children: [
            Text(name,
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(price,
                style: t.titleMedium?.copyWith(color: cs.primary)),
          ]),
          const SizedBox(height: PsySpacing.sm),
          Text(blurb, style: t.bodyMedium),
          const SizedBox(height: PsySpacing.md),
          for (final i in included) StaticBullet(i),
        ],
      ),
    );
  }
}
