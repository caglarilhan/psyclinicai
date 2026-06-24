/// Coverage for RiskCoverageStats — total / acknowledged counts,
/// per-category breakdown, unacknowledged-high-severity short list,
/// sessions-impacted set, and the empty / divide-by-zero case.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/risk_coverage_stats.dart';
import 'package:psyclinicai/services/copilot/risk_signal_service.dart';
import 'package:psyclinicai/services/data/risk_signal_repository.dart';

PersistedRiskSignal _sig({
  String id = 's',
  String sessionId = 'sess-1',
  RiskCategory category = RiskCategory.suicidalIdeation,
  RiskSeverity severity = RiskSeverity.elevated,
  bool acknowledged = false,
  DateTime? at,
}) => PersistedRiskSignal(
  id: id,
  sessionId: sessionId,
  category: category,
  severity: severity,
  matchedText: 'x',
  snippet: 'y',
  source: RiskSource.lexicon,
  at: at ?? DateTime.utc(2026, 6, 24, 14),
  acknowledged: acknowledged,
);

void main() {
  test('empty input → zero total, full coverage rate, empty buckets', () {
    final report = RiskCoverageStats.summarise(const []);
    expect(report.total, 0);
    expect(report.acknowledged, 0);
    expect(report.coverageRate, 1.0);
    expect(report.unacknowledged, 0);
    expect(report.unacknowledgedHighSeverity, isEmpty);
    expect(report.sessionsImpacted, isEmpty);
    expect(report.breakdown, hasLength(RiskCategory.values.length));
    expect(report.breakdown.every((b) => b.total == 0), isTrue);
    expect(report.breakdown.every((b) => b.coverageRate == 1.0), isTrue);
  });

  test('counts total + acknowledged + coverage rate', () {
    final report = RiskCoverageStats.summarise([
      _sig(id: 'a', acknowledged: true),
      _sig(id: 'b'),
      _sig(id: 'c', acknowledged: true),
      _sig(id: 'd'),
    ]);
    expect(report.total, 4);
    expect(report.acknowledged, 2);
    expect(report.unacknowledged, 2);
    expect(report.coverageRate, closeTo(0.5, 1e-9));
  });

  test('per-category breakdown splits acknowledged vs total', () {
    final report = RiskCoverageStats.summarise([
      _sig(id: 'a', acknowledged: true),
      _sig(id: 'b'),
      _sig(id: 'c', category: RiskCategory.selfHarm, acknowledged: true),
    ]);
    final suicide = report.breakdown.firstWhere(
      (b) => b.category == RiskCategory.suicidalIdeation,
    );
    final selfHarm = report.breakdown.firstWhere(
      (b) => b.category == RiskCategory.selfHarm,
    );
    expect(suicide.total, 2);
    expect(suicide.acknowledged, 1);
    expect(suicide.unacknowledged, 1);
    expect(suicide.coverageRate, closeTo(0.5, 1e-9));
    expect(selfHarm.total, 1);
    expect(selfHarm.acknowledged, 1);
    expect(selfHarm.coverageRate, 1.0);
  });

  test('unacknowledgedHighSeverity surfaces high + elevated only', () {
    final report = RiskCoverageStats.summarise([
      _sig(id: 'a', severity: RiskSeverity.high),
      _sig(id: 'b'),
      _sig(id: 'c', severity: RiskSeverity.info),
      _sig(id: 'd', severity: RiskSeverity.high, acknowledged: true),
    ]);
    final ids = report.unacknowledgedHighSeverity.map((s) => s.id).toSet();
    expect(ids, {'a', 'b'});
  });

  test('unacknowledgedHighSeverity is newest-first', () {
    final report = RiskCoverageStats.summarise([
      _sig(
        id: 'old',
        severity: RiskSeverity.high,
        at: DateTime.utc(2026, 6, 2),
      ),
      _sig(
        id: 'new',
        severity: RiskSeverity.high,
        at: DateTime.utc(2026, 6, 23),
      ),
      _sig(
        id: 'mid',
        severity: RiskSeverity.high,
        at: DateTime.utc(2026, 6, 12),
      ),
    ]);
    expect(report.unacknowledgedHighSeverity.map((s) => s.id).toList(), [
      'new',
      'mid',
      'old',
    ]);
  });

  test('sessionsImpacted deduplicates by session id', () {
    final report = RiskCoverageStats.summarise([
      _sig(id: 'a'),
      _sig(id: 'b'),
      _sig(id: 'c', sessionId: 's2'),
    ]);
    expect(report.sessionsImpacted, {'sess-1', 's2'});
  });
}
