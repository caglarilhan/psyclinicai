import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/trust/security_controls` — the auditor-facing security posture.
///
/// Mirrors the layout enterprise procurement uses to map controls to
/// the HIPAA Security Rule (Administrative / Physical / Technical
/// Safeguards), plus the operational controls IT teams ask about even
/// when a framework doesn't strictly require them: MFA, backup, RPO/
/// RTO, geo-redundancy, access review.
class SecurityControlsScreen extends StatelessWidget {
  const SecurityControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/trust/security_controls',
      title: 'Security controls',
      subtitle:
          'HIPAA Security Rule mapping + the operational controls auditors expect.',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('Trust Center', '/trust'),
        Crumb('Security controls', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Group(
            theme: theme,
            cs: cs,
            heading: 'Administrative safeguards · 45 CFR §164.308',
            rows: const [
              _Row('Security management',
                  'Annual risk assessment + tracked remediation backlog.'),
              _Row('Workforce security',
                  'Background checks for engineers with prod access; least-privilege roles.'),
              _Row('Access management',
                  'Role-based access · quarterly review · departure deactivation ≤ 24 h.'),
              _Row('Security awareness',
                  'HIPAA + secure-code training on hire and yearly thereafter.'),
              _Row('Contingency planning',
                  'Documented IR playbook + tabletop exercise twice a year.'),
            ],
          ),
          const SizedBox(height: PsySpacing.xl),
          _Group(
            theme: theme,
            cs: cs,
            heading: 'Physical safeguards · §164.310',
            rows: const [
              _Row('Facility access',
                  'Hetzner DE-Frankfurt ISO 27001 + SOC 2 certified data centres.'),
              _Row('Device controls',
                  'Engineer laptops: disk encryption, MDM, remote wipe.'),
              _Row('Media disposal',
                  'Storage decommissioning per NIST 800-88 (sub-processor handled).'),
            ],
          ),
          const SizedBox(height: PsySpacing.xl),
          _Group(
            theme: theme,
            cs: cs,
            heading: 'Technical safeguards · §164.312',
            rows: const [
              _Row('Access control',
                  'Unique user ID · MFA required for staff · session timeout 30 min idle.'),
              _Row('Audit controls',
                  'Append-only, hash-chained event log — 6-year retention.'),
              _Row('Integrity',
                  'Versioned writes + SHA-256 chain prevents silent tampering.'),
              _Row('Person/entity authentication',
                  'Email + password + MFA · WebAuthn passkeys supported.'),
              _Row('Transmission security',
                  'TLS 1.3 end-to-end · HSTS preload · perfect forward secrecy.'),
            ],
          ),
          const SizedBox(height: PsySpacing.xl),
          _Group(
            theme: theme,
            cs: cs,
            heading: 'Cryptography',
            rows: const [
              _Row('At rest', 'AES-256 (LUKS) on every database volume.'),
              _Row('In transit', 'TLS 1.3 with mandatory PFS ciphersuites.'),
              _Row('Key management',
                  'Hetzner KMS for storage keys · BYOK Anthropic key in OS keychain.'),
              _Row('Secrets', 'GitHub Actions OIDC + per-env secret rotation.'),
            ],
          ),
          const SizedBox(height: PsySpacing.xl),
          _Group(
            theme: theme,
            cs: cs,
            heading: 'Backup & disaster recovery',
            rows: const [
              _Row('RPO', '≤ 15 minutes (Postgres WAL streaming to standby).'),
              _Row('RTO', '≤ 1 hour (warm standby + DNS failover).'),
              _Row('Geo-redundancy',
                  'Daily encrypted snapshot to a second EU region.'),
              _Row('Restore tests',
                  'Quarterly restore drill against a fresh database snapshot.'),
            ],
          ),
          const SizedBox(height: PsySpacing.xl),
          _Group(
            theme: theme,
            cs: cs,
            heading: 'Access lifecycle',
            rows: const [
              _Row('MFA', 'TOTP + WebAuthn passkey supported.'),
              _Row('Single sign-on',
                  'SAML 2.0 + Okta-tested (paid plans, Q3 2026).'),
              _Row('Session timeout',
                  '30 minutes idle (configurable per clinic).'),
              _Row('Access review',
                  'Quarterly attestation by clinic owner · audit log entry on change.'),
              _Row('Deactivation', 'Departing user disabled within 24 hours.'),
            ],
          ),
          const SizedBox(height: PsySpacing.xl),
          PsyCard(
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, color: cs.primary, size: 20),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Text(
                    'A penetration test summary and the full risk register are '
                    'available under NDA. Email legal@psyclinicai.com.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.5,
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

class _Row {
  const _Row(this.label, this.body);
  final String label;
  final String body;
}

class _Group extends StatelessWidget {
  const _Group({
    required this.theme,
    required this.cs,
    required this.heading,
    required this.rows,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final String heading;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                heading,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const PsyBadge(label: 'Live', tone: PsyBadgeTone.success),
          ],
        ),
        const SizedBox(height: PsySpacing.sm),
        PsyCard(
          padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.lg, vertical: PsySpacing.sm),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.6),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: cs.primary),
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
      ],
    );
  }
}
