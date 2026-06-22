import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Pricing tiers — solo / practice / group. Founding rates highlighted.
class PricingSection extends StatefulWidget {
  const PricingSection({super.key, required this.onPickTier});

  final void Function(String tier) onPickTier;

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  bool _annual = false;

  int _priceFor(int monthly) => _annual ? (monthly * 0.8).round() : monthly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final period = _annual ? '/month, billed annually' : '/month';
    final tiers = <_Tier>[
      _Tier(
        name: 'Solo Founding',
        price: '\$${_priceFor(49)}',
        period: period,
        followUp: r'$99/mo standard after pilot',
        features: const [
          '1 clinician',
          'Live AI Co-Pilot (BYOK Anthropic Claude)',
          'Auto-generated SOAP / DAP / BIRP',
          'Superbill PDF — 12 CPT + 35 ICD-10',
          'PHQ-9 / GAD-7 outcome dashboard',
          'Email support',
        ],
        highlighted: false,
      ),
      _Tier(
        name: 'Practice Founding',
        price: '\$${_priceFor(149)}',
        period: period,
        followUp: r'$299/mo standard after pilot',
        features: const [
          '2 – 10 clinicians',
          'Everything in Solo',
          'Multi-jurisdiction legal engine (HIPAA + GDPR + KVKK)',
          'Team analytics + outcome trend dashboard',
          'Clinical director risk alerts',
          'Priority email + chat support',
        ],
        highlighted: true,
      ),
      _Tier(
        name: 'Group Founding',
        price: '\$${_priceFor(299)}',
        period: period,
        followUp: r'$599/mo standard after pilot',
        features: const [
          '11+ clinicians',
          'Everything in Practice',
          'White-label option',
          'Custom integrations',
          'BAA + DPA pre-signed',
          'Dedicated success manager',
        ],
        highlighted: false,
      ),
    ];

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surfaceContainerLowest,
      child: Column(
        children: [
          const SectionEyebrow('Founding pricing'),
          const SizedBox(height: 12),
          const SectionTitle(
            'Half price for life of pilot.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const SectionSubtitle(
            'First 30 clinicians lock in the founding rate. No card on file '
            'during onboarding — your trial seat is yours until you say otherwise.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Center(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Monthly')),
                ButtonSegment(value: true, label: Text('Annual · Save 20%')),
              ],
              selected: {_annual},
              onSelectionChanged: (s) => setState(() => _annual = s.first),
              showSelectedIcon: false,
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (ctx, c) {
              final isWide = c.maxWidth >= 980;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: tiers
                    .map(
                      (t) => SizedBox(
                        width: isWide ? 320 : c.maxWidth,
                        child: HoverLift(
                          borderRadius: 16,
                          lift: t.highlighted ? 4 : 2,
                          child: _TierCard(
                            tier: t,
                            theme: theme,
                            cs: cs,
                            onPick: () => widget.onPickTier(t.name),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _MicroChip(cs: cs, text: 'No credit card during pilot'),
              _MicroChip(cs: cs, text: 'Cancel anytime'),
              _MicroChip(cs: cs, text: '30-day money-back, no questions'),
              _MicroChip(cs: cs, text: 'BAA + DPA pre-signed before you pay'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'No surprises: prices switch to standard at month 7 only after we email you a reminder at month 5.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicroChip extends StatelessWidget {
  const _MicroChip({required this.cs, required this.text});
  final ColorScheme cs;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check, size: 14, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: cs.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _Tier {
  _Tier({
    required this.name,
    required this.price,
    required this.period,
    required this.followUp,
    required this.features,
    required this.highlighted,
  });
  final String name;
  final String price;
  final String period;
  final String followUp;
  final List<String> features;
  final bool highlighted;
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.theme,
    required this.cs,
    required this.onPick,
  });
  final _Tier tier;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final isHi = tier.highlighted;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isHi ? cs.primary : cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHi ? cs.primary : cs.outlineVariant,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isHi ? cs.primary : Colors.grey).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHi)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          if (isHi) const SizedBox(height: 14),
          Text(
            tier.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isHi ? Colors.white : cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tier.price,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: isHi ? Colors.white : cs.primary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  tier.period,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: (isHi ? Colors.white : cs.onSurface).withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            tier.followUp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: (isHi ? Colors.white : cs.onSurface).withValues(
                alpha: 0.65,
              ),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          ...tier.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: isHi ? Colors.white : cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isHi ? Colors.white : cs.onSurface,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPick,
              style: FilledButton.styleFrom(
                backgroundColor: isHi ? Colors.white : cs.primary,
                foregroundColor: isHi ? cs.primary : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
