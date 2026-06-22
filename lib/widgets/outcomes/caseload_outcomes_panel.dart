import 'package:flutter/material.dart';

import '../../services/analytics/caseload_outcomes_metrics.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../ds/psy_card.dart';

/// 3-card caseload outcomes roll-up that lives above the per-patient
/// chart on `/outcomes`. Pure-presentation — takes a finished
/// [CaseloadOutcomeMetrics] from [buildCaseloadMetrics].
class CaseloadOutcomesPanel extends StatelessWidget {
  const CaseloadOutcomesPanel({
    super.key,
    required this.instrumentLabel,
    required this.metrics,
  });

  /// Human label for the instrument these metrics summarise
  /// (e.g. `PHQ-9 caseload trend`).
  final String instrumentLabel;
  final CaseloadOutcomeMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (!metrics.hasData) {
      return PsyCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: PsySpacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.insights_outlined,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Text(
                  '$instrumentLabel · not enough datapoints to roll up '
                  '(need ≥2 per patient).',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final improving = metrics.avgDelta < 0;
    final deltaColor = improving ? PsyColors.success : PsyColors.warning;

    return PsyCard(
      padding: const EdgeInsets.all(PsySpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(instrumentLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Patients',
                  value: '${metrics.patientCount}',
                  hint: 'with ≥2 datapoints',
                  color: cs.primary,
                  icon: Icons.group_outlined,
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: _MetricTile(
                  label: 'Avg change',
                  value:
                      '${metrics.avgDelta >= 0 ? '+' : ''}${metrics.avgDelta.toStringAsFixed(1)} pts',
                  hint: improving
                      ? '${metrics.avgFirstScore.toStringAsFixed(1)} → '
                            '${metrics.avgLastScore.toStringAsFixed(1)}'
                      : 'increase across the caseload',
                  color: deltaColor,
                  icon: improving ? Icons.trending_down : Icons.trending_up,
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: _MetricTile(
                  label: 'Response rate',
                  value: '${(metrics.responseRate * 100).toStringAsFixed(0)}%',
                  hint: '≥50% drop from baseline',
                  color: cs.tertiary,
                  icon: Icons.workspace_premium_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          // Clinical safety disclaimer — PHQ-9 cannot distinguish
          // unipolar depression from bipolar spectrum (a "responder"
          // here might actually be switching into hypomania). The
          // outcomes view must point clinicians at the right
          // companion scale before they make any rostering decision.
          Container(
            padding: const EdgeInsets.all(PsySpacing.sm),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(PsyRadius.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'PHQ-9 alone does not detect bipolar spectrum. '
                    'Pair with MDQ or ASRM before treating a '
                    '"response" as evidence of recovery.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String hint;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(PsySpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(PsyRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(hint, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
