import 'package:flutter/material.dart';

import '../../services/assessments/assessment_severity_engine.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';

/// `/assessments/result` — renders the result of a submitted scale
/// (plan §C). The screen is stateless against the engine: it takes
/// an instrument + score (+ optional previous score) and renders the
/// band card, recommendation list, full band table, and the delta
/// chip.
class AssessmentResultScreenArgs {
  const AssessmentResultScreenArgs({
    required this.instrument,
    required this.score,
    this.previousScore,
    this.patientName = 'John Demo',
  });

  final AssessmentInstrument instrument;
  final int score;
  final int? previousScore;
  final String patientName;
}

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({super.key, required this.args});

  final AssessmentResultScreenArgs args;

  static const _engine = AssessmentSeverityEngine();

  @override
  Widget build(BuildContext context) {
    final result = _engine.evaluate(
      instrument: args.instrument,
      score: args.score,
      previousScore: args.previousScore,
    );
    final bands = _engine.bandsFor(args.instrument);

    return AppShell(
      routeName: '/assessments/result',
      title: '${_label(args.instrument)} result',
      subtitle: '${args.patientName} · score ${result.score}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ScoreCard(result: result),
          const SizedBox(height: PsySpacing.md),
          _BandTable(bands: bands, currentLabel: result.band.label),
          const SizedBox(height: PsySpacing.md),
          _RecommendationsCard(recommendations: result.recommendations),
        ],
      ),
    );
  }

  String _label(AssessmentInstrument i) {
    switch (i) {
      case AssessmentInstrument.phq9:
        return 'PHQ-9';
      case AssessmentInstrument.cssrs:
        return 'C-SSRS';
      case AssessmentInstrument.pcl5:
        return 'PCL-5';
      case AssessmentInstrument.audit:
        return 'AUDIT';
    }
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});
  final AssessmentResult result;

  Color _bandColor(BuildContext ctx) {
    if (!result.band.isClinicalConcern) return PsyColors.success;
    if (result.score >= 20) return PsyColors.danger;
    if (result.score >= 15) return PsyColors.warning;
    return PsyColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = _bandColor(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score', style: t.labelMedium),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${result.score}',
                  style: t.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(width: PsySpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: PsySpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PsySpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      result.band.label,
                      style: t.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (result.deltaVsPrevious != null) ...[
                  Icon(
                    result.isImproving
                        ? Icons.trending_down
                        : result.isWorsening
                        ? Icons.trending_up
                        : Icons.trending_flat,
                    color: result.isImproving
                        ? PsyColors.success
                        : result.isWorsening
                        ? PsyColors.warning
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${result.deltaVsPrevious! >= 0 ? '+' : ''}'
                    '${result.deltaVsPrevious}',
                    style: t.titleMedium,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BandTable extends StatelessWidget {
  const _BandTable({required this.bands, required this.currentLabel});
  final List<SeverityBand> bands;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Severity bands', style: t.titleSmall),
            const SizedBox(height: PsySpacing.sm),
            for (final b in bands)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 18,
                      decoration: BoxDecoration(
                        color: b.label == currentLabel
                            ? cs.primary
                            : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: PsySpacing.sm),
                    Expanded(
                      child: Text(
                        '${b.label}  (${b.minInclusive}–${b.maxInclusive})',
                        style: b.label == currentLabel
                            ? t.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              )
                            : t.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.recommendations});
  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recommendations', style: t.titleSmall),
            const SizedBox(height: PsySpacing.sm),
            for (final r in recommendations)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.fiber_manual_record, size: 8),
                    const SizedBox(width: PsySpacing.sm),
                    Expanded(child: Text(r, style: t.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
