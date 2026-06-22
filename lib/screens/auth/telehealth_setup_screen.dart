import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../utils/pii_redaction.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/telehealth` — Telehealth (video session) setup hub.
///
/// Transparency-first scaffold: we do NOT yet route real WebRTC traffic
/// through Daily.co; surfacing a fake "session connected" toggle would
/// leave clinicians exposed at the first patient call. This screen
/// states what's coming, collects early-access interest, and re-uses
/// itself when the back-end wiring lands in Sprint 7.
class TelehealthSetupScreen extends StatefulWidget {
  const TelehealthSetupScreen({super.key});

  @override
  State<TelehealthSetupScreen> createState() => _TelehealthSetupScreenState();
}

class _TelehealthSetupScreenState extends State<TelehealthSetupScreen> {
  bool _requested = false;

  void _requestEarlyAccess() {
    unawaited(
      TelemetryService.instance.capture(
        'telehealth.early_access_requested',
        properties: {
          // PHI redaction (B4).
          'email':
              redactEmail(FirebaseAuthService.instance.profile?.email) ??
              'anonymous',
        },
      ),
    );
    setState(() => _requested = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/settings',
      title: 'Telehealth video',
      subtitle: 'HIPAA + GDPR-aligned 1:1 sessions powered by Daily.co.',
      scrollable: false,
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Telehealth', null),
      ],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PsyCard(
            tinted: true,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PsySpacing.md),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PsyRadius.md),
                  ),
                  child: Icon(
                    Icons.videocam_outlined,
                    color: cs.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: PsySpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Status',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: PsySpacing.sm),
                          const PsyBadge(
                            label: 'Early access',
                            tone: PsyBadgeTone.info,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Sessions still rely on the practice's existing "
                        'video tooling. Built-in telehealth lands in '
                        'Sprint 7 with EU-only routing.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text(
            'What we are building',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          const PsyCard(
            child: Column(
              children: [
                _Bullet(
                  icon: Icons.videocam_outlined,
                  title: 'EU-routed WebRTC (Daily.co)',
                  body:
                      'Sessions stay inside the EU region; no '
                      'cross-region fallback by default.',
                ),
                _Divider(),
                _Bullet(
                  icon: Icons.lock_clock,
                  title: 'No recording by default',
                  body:
                      'Recording requires an explicit per-session '
                      'patient consent capture before the room can be '
                      'created.',
                ),
                _Divider(),
                _Bullet(
                  icon: Icons.devices_other,
                  title: 'Echo / connectivity self-test',
                  body:
                      'Pre-call check verifies camera, mic, and '
                      'bandwidth so a session does not fail at minute '
                      'one.',
                ),
                _Divider(),
                _Bullet(
                  icon: Icons.policy_outlined,
                  title: 'BAA + DPA covered',
                  body:
                      'Daily.co signs both — see the trust center '
                      'subprocessor list for the entry.',
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text(
            'Early access',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          PsyCard(
            child: _requested
                ? _RequestedNote(theme: theme, cs: cs)
                : _RequestForm(
                    theme: theme,
                    cs: cs,
                    onRequest: _requestEarlyAccess,
                  ),
          ),
          const SizedBox(height: PsySpacing.huge),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.title, required this.body});
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
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    height: 1.45,
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant);
}

class _RequestForm extends StatelessWidget {
  const _RequestForm({
    required this.theme,
    required this.cs,
    required this.onRequest,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'If you need telehealth this quarter, ask to join the early-'
          'access cohort and we will pair you with an engineer for the '
          'first session.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.78),
          ),
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

class _RequestedNote extends StatelessWidget {
  const _RequestedNote({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, color: cs.primary),
        const SizedBox(width: PsySpacing.md),
        Expanded(
          child: Text(
            'You are on the early-access list. We will reach out within '
            'one business day with the first-session checklist.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ),
      ],
    );
  }
}
