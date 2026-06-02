import 'package:flutter/material.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../utils/pii_redaction.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/mfa` — Two-factor authentication setup hub.
///
/// At the moment this is a transparency-first surface: a real Firebase
/// MFA TOTP enrolment is on the roadmap (P0 in the security backlog).
/// We deliberately do *not* fake a working enrolment — that would give
/// clinicians a false sense of security. Instead we explain what's
/// coming, let admins register for early access, and reuse this screen
/// once the backend wiring lands.
///
/// HIPAA §164.312(d) and SOC 2 CC6.1 both expect MFA for accounts with
/// access to ePHI. This screen exists so the requirement is visible and
/// trackable, not buried in a backlog ticket.
class MfaSetupScreen extends StatefulWidget {
  const MfaSetupScreen({super.key});

  @override
  State<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

class _MfaSetupScreenState extends State<MfaSetupScreen> {
  bool _requestSent = false;

  void _requestEarlyAccess() {
    TelemetryService.instance.capture(
      'security.mfa_early_access_requested',
      properties: {
        // PHI redaction (B4) — telemetry never sees the raw inbox.
        'email': redactEmail(
                FirebaseAuthService.instance.profile?.email) ??
            'anonymous',
      },
    );
    setState(() => _requestSent = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppShell(
      routeName: '/settings',
      title: 'Two-factor authentication',
      subtitle: 'Add a second factor to your sign-in.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Two-factor authentication', null),
      ],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PsyCard(
            tinted: true,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(PsySpacing.md),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(PsyRadius.md),
                ),
                child: Icon(Icons.shield_outlined,
                    color: cs.primary, size: 24),
              ),
              const SizedBox(width: PsySpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Status',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(width: PsySpacing.sm),
                      const PsyBadge(
                        label: 'Not enabled',
                        tone: PsyBadgeTone.warning,
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      'Your account is currently protected by your password '
                      'and Firebase Auth session controls.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72)),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text('What we are building',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.md),
          PsyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Bullet(
                  icon: Icons.smartphone_outlined,
                  title: 'Authenticator app (TOTP)',
                  body: 'One-time codes from Google Authenticator, '
                      'Authy, 1Password, or any RFC 6238 app.',
                ),
                _Divider(cs: cs),
                const _Bullet(
                  icon: Icons.key_outlined,
                  title: 'Recovery codes',
                  body: 'Ten single-use codes you can store in your '
                      'password manager — for when you lose your phone.',
                ),
                _Divider(cs: cs),
                const _Bullet(
                  icon: Icons.fingerprint,
                  title: 'Device biometrics',
                  body: 'Touch ID, Face ID, Windows Hello, or Android '
                      'fingerprint as a fast second factor on trusted '
                      'devices.',
                ),
                _Divider(cs: cs),
                const _Bullet(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin enforcement',
                  body: 'Practice admins can require MFA across the '
                      'workspace — needed for HIPAA §164.312(d) and '
                      'SOC 2 CC6.1.',
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text('Early access',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.md),
          PsyCard(
            child: _requestSent
                ? _RequestedState(cs: cs, theme: theme)
                : _RequestForm(
                    cs: cs, theme: theme, onRequest: _requestEarlyAccess),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text(
            'Until MFA ships, treat shared devices as if they were not '
            'authenticated — sign out at the end of every clinical shift '
            'and never save your password in a browser on a shared machine.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontStyle: FontStyle.italic,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 22),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
        child: Divider(height: 1, color: cs.outlineVariant),
      );
}

class _RequestForm extends StatelessWidget {
  const _RequestForm(
      {required this.cs, required this.theme, required this.onRequest});
  final ColorScheme cs;
  final ThemeData theme;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We are wiring Firebase Auth multi-factor with TOTP enrolment '
          'and recovery codes. If you handle PHI and need MFA today, ask '
          'to join the early-access cohort — we will reach out within one '
          'business day.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: cs.onSurface.withValues(alpha: 0.78)),
        ),
        const SizedBox(height: PsySpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onRequest,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Request early access'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          ),
        ),
      ],
    );
  }
}

class _RequestedState extends StatelessWidget {
  const _RequestedState({required this.cs, required this.theme});
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(PsySpacing.sm),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(PsyRadius.md),
        ),
        child: Icon(Icons.check_circle_outline, color: cs.primary),
      ),
      const SizedBox(width: PsySpacing.lg),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are on the early-access list',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'We will email setup instructions once the build clears '
              'our security review. No action needed from you.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65), height: 1.45),
            ),
          ],
        ),
      ),
    ]);
  }
}
