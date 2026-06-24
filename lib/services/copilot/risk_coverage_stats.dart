/// Pure aggregator over the persisted risk-signal ledger. Backs the
/// upcoming "risk coverage" leadership panel: were the signals
/// raised during this week / month / quarter acted on?
///
/// Lives next to the [RiskSignalService] so the coverage maths and
/// the signal vocabulary stay together. No I/O — the screen layer
/// feeds in a snapshot from [RiskSignalRepository] and renders the
/// returned [RiskCoverageReport].
library;

import '../data/risk_signal_repository.dart';
import 'risk_signal_service.dart';

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.category,
    required this.total,
    required this.acknowledged,
  });

  final RiskCategory category;
  final int total;
  final int acknowledged;

  int get unacknowledged => total - acknowledged;

  /// 0.0 – 1.0. Returns 1.0 for zero-total buckets so the panel
  /// can collapse them as "no work to do" rather than showing a
  /// divide-by-zero NaN.
  double get coverageRate => total == 0 ? 1.0 : acknowledged / total;
}

class RiskCoverageReport {
  const RiskCoverageReport({
    required this.total,
    required this.acknowledged,
    required this.breakdown,
    required this.unacknowledgedHighSeverity,
    required this.sessionsImpacted,
  });

  final int total;
  final int acknowledged;
  final List<CategoryBreakdown> breakdown;

  /// Unacknowledged signals at [RiskSeverity.elevated] or
  /// [RiskSeverity.high]. These are the rows the leadership panel
  /// hoists to the top of the "still open" list.
  final List<PersistedRiskSignal> unacknowledgedHighSeverity;

  /// Distinct session ids that surfaced at least one signal.
  final Set<String> sessionsImpacted;

  int get unacknowledged => total - acknowledged;

  double get coverageRate => total == 0 ? 1.0 : acknowledged / total;
}

class RiskCoverageStats {
  RiskCoverageStats._();

  /// Build a coverage report from a snapshot. Pure — caller decides
  /// which window (this week / month / all-time) to feed in by
  /// filtering [signals] first.
  static RiskCoverageReport summarise(List<PersistedRiskSignal> signals) {
    final byCategory = <RiskCategory, List<PersistedRiskSignal>>{};
    for (final s in signals) {
      byCategory.putIfAbsent(s.category, () => []).add(s);
    }
    final breakdown = <CategoryBreakdown>[
      for (final cat in RiskCategory.values)
        CategoryBreakdown(
          category: cat,
          total: byCategory[cat]?.length ?? 0,
          acknowledged: (byCategory[cat] ?? const [])
              .where((s) => s.acknowledged)
              .length,
        ),
    ];
    final unackHigh =
        signals
            .where(
              (s) =>
                  !s.acknowledged &&
                  (s.severity == RiskSeverity.high ||
                      s.severity == RiskSeverity.elevated),
            )
            .toList()
          ..sort((a, b) => b.at.compareTo(a.at));
    final acknowledged = signals.where((s) => s.acknowledged).length;
    return RiskCoverageReport(
      total: signals.length,
      acknowledged: acknowledged,
      breakdown: breakdown,
      unacknowledgedHighSeverity: unackHigh,
      sessionsImpacted: signals.map((s) => s.sessionId).toSet(),
    );
  }
}
