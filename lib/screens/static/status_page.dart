import 'package:flutter/material.dart';

import '../../services/data/telemetry_service.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/status` — manual system-status board (Sprint E auto-syncs this from
/// the uptime probe). Until then, the lights stay green and the page is
/// updated by hand whenever an incident occurs.
class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  static const List<_System> _systems = [
    _System(name: 'Public web (psyclinicai.com)', status: _Status.operational),
    _System(name: 'Firebase Authentication', status: _Status.operational),
    _System(
      name: 'Firestore — EU tenants (eur3, Frankfurt)',
      status: _Status.operational,
    ),
    _System(
      name: 'Firestore — US tenants (us-central1, Iowa)',
      status: _Status.operational,
    ),
    _System(name: 'Anthropic API (BYOK)', status: _Status.operational),
    _System(
      name: 'Hetzner static host (Frankfurt)',
      status: _Status.operational,
    ),
    _System(
      name: 'Outbound email (Firebase / Postmark)',
      status: _Status.operational,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final allGreen = _systems.every((s) => s.status == _Status.operational);
    return StaticPageShell(
      eyebrow: 'System status',
      title: allGreen ? 'All systems operational.' : 'Investigating issue.',
      lede:
          'PsyClinicAI publishes the live state of every sub-system. If '
          'anything turns yellow or red here, expect a follow-up email from '
          'founders@psyclinicai.com within an hour.',
      lastUpdated: DateTime(2026, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryBanner(allGreen: allGreen),
          const SizedBox(height: PsySpacing.xl),
          ..._systems.map((s) => _SystemRow(system: s)),
          const SizedBox(height: PsySpacing.xxl),
          const StaticH2('Data residency'),
          const StaticP(
            'Each tenant is pinned to a single Firestore region — EU '
            'tenants stay in eur3 (Frankfurt), US tenants stay in '
            'us-central1 (Iowa). We do not cross-replicate clinical '
            'records between regions. KMS keys, audit logs and '
            'transactional email pipelines follow the tenant region.',
          ),
          const SizedBox(height: PsySpacing.xxl),
          const StaticH2('Observability'),
          _TelemetryHealthRow(health: TelemetryService.instance.health),
          const SizedBox(height: PsySpacing.xxl),
          const StaticH2('Recent incidents'),
          const StaticP('No incidents in the last 90 days.'),
        ],
      ),
    );
  }
}

class _TelemetryHealthRow extends StatelessWidget {
  const _TelemetryHealthRow({required this.health});
  final TelemetryHealth health;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final wired = health.sentryReady;
    final misconfigured = health.dsnConfigured && !health.sentryReady;
    final color = wired
        ? PsyColors.success
        : (misconfigured ? cs.error : cs.onSurface.withValues(alpha: 0.55));

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.xl,
        vertical: PsySpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentry crash + error pipeline',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'env=${health.environment} · dsn=${health.dsnConfigured ? "configured" : "not set"}'
                  ' · state=${health.label}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          Text(
            health.label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

enum _Status { operational, degraded, outage }

class _System {
  const _System({required this.name, required this.status});
  final String name;
  final _Status status;

  Color color(ColorScheme cs) => switch (status) {
    _Status.operational => PsyColors.success,
    _Status.degraded => PsyColors.warning,
    _Status.outage => cs.error,
  };

  String label() => switch (status) {
    _Status.operational => 'Operational',
    _Status.degraded => 'Degraded',
    _Status.outage => 'Outage',
  };
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.allGreen});
  final bool allGreen;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = allGreen ? PsyColors.success : cs.error;
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            allGreen ? Icons.check_circle : Icons.error_outline,
            color: color,
            size: 28,
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Text(
              allGreen
                  ? 'Every system is green. No active incidents.'
                  : 'At least one system is degraded. See list below for detail.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemRow extends StatelessWidget {
  const _SystemRow({required this.system});
  final _System system;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = system.color(cs);
    return Container(
      margin: const EdgeInsets.only(bottom: PsySpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.xl,
        vertical: PsySpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Text(
              system.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            system.label(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
