import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// `/dpa` — GDPR Article 28 Data Processing Agreement summary + the
/// "request your signed copy" CTA. Renders an executive abstract of
/// `docs/GDPR-DPA.md`; the signed PDF is mailed on request so the
/// landing build doesn't ship a 30-page legal annex.
class DpaPage extends StatelessWidget {
  const DpaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/dpa',
      title: 'GDPR DPA',
      subtitle:
          'EU General Data Protection Regulation — Article 28 (Processor).',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('GDPR DPA', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Summary(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          _FactsCard(theme: theme, cs: cs, rows: const [
            _Fact('Controller', 'Clinic / clinician'),
            _Fact('Processor', 'PsyClinic Software GmbH'),
            _Fact('Data residency', 'Frankfurt, EU-Central'),
            _Fact('Audio handling', 'On-device by default'),
            _Fact('Breach notice', '≤ 24 h policy (Art. 33 ceiling 72 h)'),
          ]),
          const SizedBox(height: PsySpacing.xl),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Roles',
            body:
                'You (the clinic / clinician) are the Controller. PsyClinic '
                'Software GmbH is the Processor. Patients are Data Subjects.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Sub-processors',
            body:
                'Hetzner Online GmbH (DE-Frankfurt) · Firebase Auth (eu-multi) · '
                'Anthropic — only when you supply your own API key (BYOK). A live '
                'list is at /subprocessors with 30-day change notice.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Data residency',
            body:
                'All clinical data stored in EU-Central (Frankfurt). Audio is '
                'transcribed on-device by default — never uploaded.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Sub-processor changes',
            body:
                'We email you 30 days before adding or replacing any sub-processor. '
                'You can object during that window without penalty.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Breach notification',
            body:
                'GDPR Art. 33 sets a 72-hour ceiling — our policy notifies you '
                'within ≤ 24 hours of becoming aware so your team still has '
                '≥ 48 hours to file with the supervisory authority. Each '
                'notice carries the Art. 33(3) content (scope, affected data, '
                'remediation) and follow-ups as facts develop.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Data subject rights',
            body:
                'Self-serve export and erasure are surfaced in Settings → Account. '
                'For complex requests we respond within 30 days.',
          ),
          const SizedBox(height: PsySpacing.xl),
          _Article30Card(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          _RetentionCard(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          _InternationalTransfersCard(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          _DownloadCard(theme: theme, cs: cs),
        ],
      ),
    );
  }
}

// ─── Article 30 register ──────────────────────────────────────────────
// GDPR Art. 30(1) requires every Controller (and 30(2) every Processor)
// to maintain a record of processing activities. Surfacing the live
// register here turns a regulatory checkbox into a customer trust signal.
class _Article30Card extends StatelessWidget {
  const _Article30Card({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Article 30 register',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: PsySpacing.sm),
        Text(
          'Live record of every processing activity — purpose, data '
          'category, retention, and legal basis.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.72),
            height: 1.5,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        for (final r in _activities) ...[
          _ActivityRow(row: r, theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.sm),
        ],
      ],
    );
  }
}

class _Activity {
  const _Activity({
    required this.purpose,
    required this.category,
    required this.retention,
    required this.legalBasis,
  });
  final String purpose;
  final String category;
  final String retention;
  final String legalBasis;
}

const _activities = <_Activity>[
  _Activity(
    purpose: 'Deliver the clinical workspace',
    category: 'Account data, session notes, assessments',
    retention: '7 years after last session (clinical record law)',
    legalBasis: 'Contract (GDPR Art. 6(1)(b)) · special-category Art. 9(2)(h)',
  ),
  _Activity(
    purpose: 'AI co-pilot generation (BYOK)',
    category: 'Session transcript text · no audio',
    retention: 'Not retained by us — sent live to clinician-owned key',
    legalBasis: 'Contract · Anthropic processes under EU SCCs',
  ),
  _Activity(
    purpose: 'Audit logging',
    category: 'Actor, action, resource, IP, device, result',
    retention: '6 years (HIPAA §164.316(b)(2)(i))',
    legalBasis: 'Legal obligation (Art. 6(1)(c))',
  ),
  _Activity(
    purpose: 'Crash + error capture (Sentry)',
    category: 'Stack traces, opaque user id · PII scrub on',
    retention: '90 days rolling',
    legalBasis: 'Legitimate interest (Art. 6(1)(f))',
  ),
  _Activity(
    purpose: 'Billing + payments',
    category: 'Email, plan, invoice, tax id',
    retention: '10 years (EU tax record law)',
    legalBasis: 'Contract + legal obligation',
  ),
];

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.row, required this.theme, required this.cs});
  final _Activity row;
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return PsyCard(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.lg, vertical: PsySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.purpose,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          _kv(theme, cs, 'Category', row.category),
          _kv(theme, cs, 'Retention', row.retention),
          _kv(theme, cs, 'Legal basis', row.legalBasis),
        ],
      ),
    );
  }

  Widget _kv(ThemeData theme, ColorScheme cs, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                )),
          ),
          Expanded(
            child: Text(v,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.88),
                  height: 1.45,
                )),
          ),
        ],
      ),
    );
  }
}

// ─── Retention summary ────────────────────────────────────────────────
class _RetentionCard extends StatelessWidget {
  const _RetentionCard({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    const rows = [
      _Retention('Clinical session notes',
          '7 years after last session', 'Clinical record law'),
      _Retention('Patient demographic record',
          '7 years after last session', 'Clinical record law'),
      _Retention('Audit logs', '6 years',
          'HIPAA §164.316(b)(2)(i)'),
      _Retention('Deleted patient (grace)',
          '30 days, then hard delete', 'GDPR Art. 17 · clinic policy'),
      _Retention('Crash / error events',
          '90 days rolling', 'Legitimate interest'),
      _Retention('Invoices + billing',
          '10 years', 'EU tax record law'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Retention policy',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: PsySpacing.md),
        PsyCard(
          padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.lg, vertical: PsySpacing.sm),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                      height: 1,
                      color:
                          cs.outlineVariant.withValues(alpha: 0.6)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: PsySpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(rows[i].label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(rows[i].period,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface
                                    .withValues(alpha: 0.78),
                                height: 1.4)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(rows[i].source,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurface
                                    .withValues(alpha: 0.55),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Retention {
  const _Retention(this.label, this.period, this.source);
  final String label;
  final String period;
  final String source;
}

// ─── International transfers / SCCs ───────────────────────────────────
class _InternationalTransfersCard extends StatelessWidget {
  const _InternationalTransfersCard(
      {required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('International transfers',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: PsySpacing.md),
        PsyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.public, color: cs.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('EU Standard Contractual Clauses',
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: PsySpacing.sm),
              Text(
                'Every sub-processor outside the EU/EEA that touches '
                'personal data has executed the 2021 EU SCCs Module 2 '
                '(Controller-to-Processor) with us. The live list lives '
                'at /trust/subprocessors with 30-day change notice.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  height: 1.55,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: PsySpacing.md),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed('/trust/subprocessors'),
                icon: const Icon(Icons.lan_outlined, size: 16),
                label: const Text('Open subprocessor list'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return PsyCard(
      // Info notice (no action) — neutral surface keeps the teal palette
      // reserved for primary CTAs and active states, per critique.
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: cs.primary, size: 22),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Text(
              'This is an executive summary. The signed DPA — countersigned, '
              'PDF, with full Annex I/II/III — is emailed on request.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.theme,
    required this.cs,
    required this.title,
    required this.body,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          Text(body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
                height: 1.55,
                fontSize: 13.5,
              )),
        ],
      ),
    );
  }
}

// Quick facts strip — the 5 questions every clinic asks before signing.
// Scannable in 5 seconds, while the narrative _Section below carries
// the full legal language.
class _Fact {
  const _Fact(this.label, this.value);
  final String label;
  final String value;
}

class _FactsCard extends StatelessWidget {
  const _FactsCard(
      {required this.theme, required this.cs, required this.rows});
  final ThemeData theme;
  final ColorScheme cs;
  final List<_Fact> rows;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.lg, vertical: PsySpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Divider(
                    height: 1, color: cs.outlineVariant.withValues(alpha: 0.6)),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      rows[i].label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rows[i].value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request a signed copy',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Email legal@psyclinicai.com with your clinic name and we will '
            'return a counter-signed DPA within 1 business day.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
              height: 1.55,
            ),
          ),
          const SizedBox(height: PsySpacing.lg),
          PsyButton(
            label: 'Email legal@psyclinicai.com',
            icon: Icons.email_outlined,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Email client opens in your local mail handler — demo skips this in web.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
