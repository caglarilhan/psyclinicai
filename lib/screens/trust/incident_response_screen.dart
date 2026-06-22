import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_card.dart';

/// `/trust/incident_response` — IR program at a glance.
///
/// What auditors look for: a documented playbook, named owners,
/// notification timelines that satisfy HIPAA §164.410 + GDPR Art. 33,
/// and an honest record of past exercises. Numbers below are the
/// commitments we publish; the full IRP is available under NDA.
class IncidentResponseScreen extends StatelessWidget {
  const IncidentResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/trust/incident_response',
      title: 'Incident response',
      subtitle:
          'Detection → containment → notification → post-mortem, with named owners.',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('Trust Center', '/trust'),
        Crumb('Incident response', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PsyCard(
            child: Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: cs.primary,
                  size: 20,
                ),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Text(
                    'Suspect a security incident? Email '
                    'security@psyclinicai.com or PGP 0xA1B2C3D4 — we triage '
                    '24/7 and reply within 30 minutes.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          ..._phases.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: _PhaseCard(phase: p, theme: theme, cs: cs),
            ),
          ),
          const SizedBox(height: PsySpacing.lg),
          Text(
            'Notification commitments — HIPAA §164.410 (60 days) + GDPR '
            'Art. 33 (72 hours). We aim for 72 hours on both fronts.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Phase {
  const _Phase({
    required this.label,
    required this.icon,
    required this.target,
    required this.owner,
    required this.body,
  });
  final String label;
  final IconData icon;
  final String target;
  final String owner;
  final String body;
}

const _phases = <_Phase>[
  _Phase(
    label: '1 · Detect',
    icon: Icons.search,
    target: '< 5 min',
    owner: 'On-call engineer',
    body:
        'Sentry alerts, Hetzner anomaly monitors, customer reports, and '
        'audit-log triggers. PagerDuty escalates within 5 minutes.',
  ),
  _Phase(
    label: '2 · Triage & contain',
    icon: Icons.shield_outlined,
    target: '< 30 min',
    owner: 'Incident commander',
    body:
        'Severity classified (SEV1–SEV4). For SEV1/2 we isolate the affected '
        'tenant, rotate keys, and freeze writes if integrity is at risk.',
  ),
  _Phase(
    label: '3 · Eradicate & recover',
    icon: Icons.healing_outlined,
    target: 'Until clean',
    owner: 'Engineering',
    body:
        'Root-cause identified, fix deployed, integrity re-verified against '
        'the hash-chain audit log, and service restored from a clean backup '
        'when needed.',
  ),
  _Phase(
    label: '4 · Notify',
    icon: Icons.mail_outline,
    target: '< 72 h',
    owner: 'Legal + DPO',
    body:
        'Affected customers contacted with scope, timeline, and remediation. '
        'Regulators (HHS, EU DPA) notified per HIPAA §164.410 and GDPR '
        'Art. 33 within the stricter of the two clocks.',
  ),
  _Phase(
    label: '5 · Post-mortem',
    icon: Icons.fact_check_outlined,
    target: '< 10 days',
    owner: 'Engineering + IC',
    body:
        'Blameless RCA published internally and to affected customers, with '
        'preventive actions tracked in the security backlog and revisited '
        'at the next quarterly review.',
  ),
];

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.phase,
    required this.theme,
    required this.cs,
  });
  final _Phase phase;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.lg,
        vertical: PsySpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(PsyRadius.md),
                ),
                child: Icon(phase.icon, color: cs.primary, size: 18),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${phase.target} · ${phase.owner}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            phase.body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.78),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
