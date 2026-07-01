import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/pricing` — bootstrap-tier pricing (Sprint 31 PR-K).
///
/// Three tiers mirror `docs/launch/BOOTSTRAP-ROADMAP.md`:
///
/// - **Demo** (\$0) — Groq-backed, synthetic vignettes only.
/// - **BYOK** (\$0 from us) — clinician pastes their own Anthropic
///   key + signs BAA directly with Anthropic.
/// - **Pro** (\$99/mo) — we cover Anthropic + Azure BAA. Locked
///   waitlist until first 10 paying customers fund the switch.
class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Plans',
      title: 'Start free. Bring your own key. Or let us cover the stack.',
      lede:
          'Every plan ships the 4 pillars: ambient scribe, measurement-based '
          'care, no-show recovery, evidence-based plan drafter. You choose '
          'how PHI is protected — synthetic-only demo, BYOK Anthropic (you '
          'sign the BAA), or the managed Pro tier when it opens.',
      lastUpdated: DateTime(2026, 7, 1),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaticH2('Plans'),
          _PlanRow(
            name: 'Demo',
            price: 'Free',
            blurb:
                'Evaluate all four pillars with the pre-built synthetic '
                'vignettes. Runs on Groq + Gemini free tiers. No HIPAA '
                'BAA — synthetic patients only.',
            included: [
              'Ambient scribe (paste transcript → SOAP)',
              'MBC dispatch (PHQ-9 / GAD-7 / PCL-5 / AUDIT)',
              'No-show risk scoring + recovery playbook',
              'Treatment plan drafter (12 protocols)',
              '5 pre-built synthetic patient vignettes',
              '"Synthetic data only" banner enforced',
            ],
          ),
          SizedBox(height: PsySpacing.lg),
          _PlanRow(
            name: 'BYOK',
            price: 'Free from us · you pay Anthropic',
            blurb:
                'Paste your own Anthropic API key in Settings → BYOK LLM '
                'keys. You sign the HIPAA BAA directly with Anthropic; we '
                'never touch your PHI-bearing bytes. Everything in Demo, '
                'plus real PHI use.',
            included: [
              'Everything in Demo',
              'Real PHI on your own Anthropic tier',
              'Anthropic BAA — signed directly with them',
              'Per-request BYOK resolver (Anthropic first)',
              'Anthropic gives \$5 free credit on new accounts',
            ],
            highlight: true,
          ),
          SizedBox(height: PsySpacing.lg),
          _PlanRow(
            name: 'Pro',
            price: '\$99 / clinician / month',
            blurb:
                'Managed tier — we cover Anthropic + Azure OpenAI BAA and '
                'sign the BAA with you. Launches when the first 10 Pro '
                'seats are reserved; the waitlist is open now.',
            included: [
              'Everything in BYOK',
              'We handle Anthropic + Azure OpenAI BAA',
              'psyclinicai signs the BAA with you (not Anthropic)',
              'Per-tenant cost ledger + rate-limit budget',
              'Priority support + monthly outcome-benchmark reports',
              'Waitlist — no card needed to reserve a seat',
            ],
          ),
          SizedBox(height: PsySpacing.xxl),
          StaticH2('Honest scope notes'),
          StaticBullet(
            'Demo + BYOK tiers are live today. Pro tier is under '
            'construction — reservations open, activation when the first '
            '10 seats are locked.',
          ),
          StaticBullet(
            'BYOK: Anthropic sub-\$0.01 per 5-minute session on Haiku 4.5. '
            'You pay Anthropic directly; we never bill you for tokens.',
          ),
          StaticBullet(
            'No per-patient, per-note, per-superbill micro-charges on '
            'any tier.',
          ),
          StaticBullet(
            'Stripe fees pass through when the Pro tier opens; we do not '
            'mark them up.',
          ),
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
    this.highlight = false,
  });

  final String name;
  final String price;
  final String blurb;
  final List<String> included;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: highlight ? cs.primaryContainer : cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(
          color: highlight ? cs.primary : cs.outlineVariant,
          width: highlight ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlight ? cs.onPrimaryContainer : null,
                ),
              ),
              if (highlight) ...[
                const SizedBox(width: PsySpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PsySpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Recommended',
                    style: t.labelSmall?.copyWith(color: cs.onPrimary),
                  ),
                ),
              ],
              const Spacer(),
              Text(price, style: t.titleMedium?.copyWith(color: cs.primary)),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            blurb,
            style: t.bodyMedium?.copyWith(
              color: highlight ? cs.onPrimaryContainer : null,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          for (final i in included) StaticBullet(i),
        ],
      ),
    );
  }
}
