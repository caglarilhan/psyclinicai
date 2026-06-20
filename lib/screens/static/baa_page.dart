import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// `/baa` — HIPAA Business Associate Agreement summary + request CTA.
/// Mirrors the structure of [DpaPage]; the binding contract is the
/// signed PDF emailed from legal@psyclinicai.com on request.
class BaaPage extends StatelessWidget {
  const BaaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/baa',
      title: 'HIPAA BAA',
      subtitle:
          'Business Associate Agreement — for US clinicians handling PHI.',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('HIPAA BAA', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PsyCard(
            // Neutral info notice — teal reserved for CTAs per critique.
            child: Row(
              children: [
                Icon(Icons.health_and_safety_outlined,
                    color: cs.primary, size: 22),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Text(
                    'A signed BAA is required before storing US Protected '
                    'Health Information (PHI) on PsyClinicAI. We sign before '
                    'you upload your first patient.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          _FactsCard(theme: theme, cs: cs, rows: const [
            _Fact('Our role', 'Business Associate · 45 CFR §160.103'),
            _Fact('PHI handling', 'AES-256 at rest, TLS 1.3 in transit'),
            _Fact('Access control', 'Role-based + audit-logged'),
            _Fact('Breach notice', '≤ 24 h policy (statutory ceiling 60 days)'),
            _Fact('On termination', 'Return or destroy PHI within 30 days'),
          ]),
          const SizedBox(height: PsySpacing.xl),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Scope',
            body:
                'PsyClinicAI is the Business Associate under 45 CFR §160.103. '
                'We process PHI solely to perform services you instruct.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Safeguards',
            body:
                'Administrative, physical, and technical safeguards meeting '
                'the HIPAA Security Rule, including AES-256 at rest, TLS 1.3 '
                'in transit, role-based access, and audit logging.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Breach notification',
            body:
                'HITECH §13402 / 45 CFR §164.410 sets a 60-day ceiling — our '
                'policy notifies your team within ≤ 24 hours of discovery, '
                'with the §164.410(c) content (affected individuals, scope, '
                'mitigation) and follow-ups as facts develop.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Subcontractors',
            body:
                'No subcontractor receives PHI unless it has executed a written '
                'BAA with terms at least as protective. Live list at /subprocessors.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Termination',
            body:
                'On termination we return or destroy all PHI in our possession '
                'within 30 days, or extend protections if return/destruction is '
                'infeasible, per §164.504(e)(2)(ii)(J).',
          ),
          const SizedBox(height: PsySpacing.xl),
          _OperationalControlsCard(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          PsyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request a signed BAA',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: PsySpacing.sm),
                Text(
                  'Email legal@psyclinicai.com with your NPI and clinic '
                  'address. Counter-signed BAA returns within 1 business day.',
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
          ),
        ],
      ),
    );
  }
}

// Quick facts strip — see [DpaPage] for the mirror version. The pair is
// intentionally duplicated (private classes, no public widget) so each
// page's content stays a single file.
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
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.6)),
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

// Operational controls glance — the questions that come right after
// 'is a BAA available?' on every US procurement call: MFA, backup,
// RPO/RTO, geo-redundancy, access review, session timeout. Full
// HIPAA Security Rule mapping lives at /trust/security_controls.
class _OperationalControlsCard extends StatelessWidget {
  const _OperationalControlsCard({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    const rows = [
      _OpRow(Icons.lock_outline, 'MFA',
          'TOTP + WebAuthn passkey supported for every workforce member.'),
      _OpRow(Icons.cloud_upload_outlined, 'Backup',
          'Encrypted snapshots every 15 min · daily copy to a second EU region.'),
      _OpRow(Icons.timelapse, 'RPO / RTO',
          '≤ 15 min RPO · ≤ 1 h RTO · quarterly restore tests.'),
      _OpRow(Icons.manage_accounts_outlined, 'Access reviews',
          'Quarterly attestation · departure deactivation within 24 h.'),
      _OpRow(Icons.timer_outlined, 'Session timeout',
          '30 minutes idle (configurable per clinic).'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Operational controls',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: PsySpacing.sm),
        Text(
          'The questions that follow "is a BAA available?". Full HIPAA '
          'Security Rule mapping lives in the security controls page.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.72),
            height: 1.5,
            fontSize: 13.5,
          ),
        ),
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
                      color: cs.outlineVariant.withValues(alpha: 0.6)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(rows[i].icon, size: 16, color: cs.primary),
                      const SizedBox(width: PsySpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rows[i].label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              rows[i].body,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.72),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context)
              .pushNamed('/trust/security_controls'),
          icon: const Icon(Icons.shield_outlined, size: 16),
          label: const Text('Open full security controls'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            textStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _OpRow {
  const _OpRow(this.icon, this.label, this.body);
  final IconData icon;
  final String label;
  final String body;
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
