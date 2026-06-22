import 'package:flutter/material.dart';

import '../services/analytics/dashboard_metrics.dart';
import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// 4 metric cards + "next appointment" strip rendered above the
/// dashboard agenda (plan §B).
///
/// Stateless: the parent computes [DashboardMetrics] via
/// `DashboardMetricsBuilder.build(...)` and passes it in. Tapping a
/// card fires [onTap] with the card identifier so the parent can
/// navigate (e.g. `/sessions?status=pending`).
class DashboardMetricsCards extends StatelessWidget {
  const DashboardMetricsCards({
    super.key,
    required this.metrics,
    this.currency = 'EUR',
    this.onTap,
  });

  final DashboardMetrics metrics;
  final String currency;
  final ValueChanged<DashboardCardKind>? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 720;
        final cards = <Widget>[
          _MetricCard(
            kind: DashboardCardKind.todaysSessions,
            title: "Today's sessions",
            value: '${metrics.todaysSessionCount}',
            hint: metrics.nextAppointment == null
                ? 'No upcoming today'
                : 'Next ${_clock(metrics.nextAppointment!.startsAt)} · '
                      '${metrics.nextAppointment!.patientName}',
            color: PsyColors.primary,
            icon: Icons.event,
            onTap: onTap,
          ),
          _MetricCard(
            kind: DashboardCardKind.pendingNotes,
            title: 'Pending notes',
            value: '${metrics.pendingNotesCount}',
            hint: 'Unsigned > 24h',
            color: PsyColors.warning,
            icon: Icons.edit_note,
            onTap: onTap,
          ),
          _MetricCard(
            kind: DashboardCardKind.atRisk,
            title: 'At-risk patients',
            value: '${metrics.atRiskCount}',
            hint: 'Last 7 days',
            color: PsyColors.danger,
            icon: Icons.priority_high,
            onTap: onTap,
          ),
          _MetricCard(
            kind: DashboardCardKind.outstanding,
            title: 'Outstanding',
            value: _money(metrics.outstandingTotalCents, currency),
            hint: metrics.oldestOutstandingAgeDays == 0
                ? 'None outstanding'
                : 'Oldest ${metrics.oldestOutstandingAgeDays}d',
            color: PsyColors.info,
            icon: Icons.payments_outlined,
            onTap: onTap,
          ),
        ];
        return Wrap(
          spacing: PsySpacing.md,
          runSpacing: PsySpacing.md,
          children: cards
              .map(
                (c) => SizedBox(
                  width: wide
                      ? (constraints.maxWidth - PsySpacing.md * 3) / 4
                      : constraints.maxWidth,
                  child: c,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  static String _clock(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  static String _money(int cents, String currency) {
    final units = (cents / 100).toStringAsFixed(2);
    return '$currency $units';
  }
}

enum DashboardCardKind { todaysSessions, pendingNotes, atRisk, outstanding }

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.kind,
    required this.title,
    required this.value,
    required this.hint,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final DashboardCardKind kind;
  final String title;
  final String value;
  final String hint;
  final Color color;
  final IconData icon;
  final ValueChanged<DashboardCardKind>? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(kind),
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(PsySpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: t.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(hint, style: t.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
