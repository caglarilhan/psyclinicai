import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Denial Shield spotlight — the revenue-protection story. Lands right after
/// the problem section ("$11k/yr in denied claims") as the answer to it.
class DenialShieldSection extends StatelessWidget {
  const DenialShieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final points = <_Point>[
      _Point(
        icon: Icons.fact_check_outlined,
        title: 'Catches the CPT mismatch before you bill',
        body: '90837 (60 min) needs documented time + a medical-necessity '
            'reason. We flag the mismatch at save-time — not 45 days later in '
            'a denial letter.',
      ),
      _Point(
        icon: Icons.account_balance_outlined,
        title: 'Audited by each payer’s own rules',
        body: 'Medicare, Medicaid, Blue Cross, UnitedHealthcare/Optum, Aetna '
            'and Cigna each reject claims differently. The note is checked '
            'against the one you’re billing.',
      ),
      _Point(
        icon: Icons.attach_money,
        title: 'Quantified, with the exact fix',
        body: 'See the dollars at risk and the one sentence that clears the '
            'denial — paste it in and submit with confidence.',
      ),
    ];

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('Denial Shield'),
          const SizedBox(height: 12),
          const SectionTitle('Get paid for the work you already did.'),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: const SectionSubtitle(
              'US payers reject roughly \$580M a year in psychotherapy claims '
              'for documentation reasons — not fraud. PsyClinicAI audits every '
              'note against the payer’s criteria and the billed CPT the moment '
              'you finish, and hands you the exact sentence to add before you '
              'submit.',
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (ctx, c) {
              final wide = c.maxWidth >= 900;
              final card = _DenialMock(theme: theme, cs: cs);
              final list = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < points.length; i++) ...[
                    _PointRow(point: points[i], theme: theme, cs: cs),
                    if (i < points.length - 1) const SizedBox(height: 24),
                  ],
                ],
              );
              if (!wide) {
                return Column(children: [
                  card,
                  const SizedBox(height: 32),
                  list,
                ]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: card),
                  const SizedBox(width: 48),
                  Expanded(flex: 6, child: list),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Point {
  _Point({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

class _PointRow extends StatelessWidget {
  const _PointRow(
      {required this.point, required this.theme, required this.cs});
  final _Point point;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(point.icon, color: cs.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(point.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(point.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                      height: 1.55)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A faithful, static mock of the in-app Denial Shield banner — shows the real
/// product, not a generic illustration.
class _DenialMock extends StatelessWidget {
  const _DenialMock({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 18, color: danger),
              const SizedBox(width: 8),
              Expanded(
                child: Text('High denial risk · 90837 · ~\$175 at risk',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: danger, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('UHC/Optum',
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.7))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, size: 16, color: danger),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '90837 lacks a medical-necessity reason for the extended '
                  'session.',
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.add_circle_outline, size: 15, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Add: “53+ minutes were medically necessary for trauma '
                    'processing given symptom severity.”',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.primary, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Decision-support — estimates denial risk, not a guarantee.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
