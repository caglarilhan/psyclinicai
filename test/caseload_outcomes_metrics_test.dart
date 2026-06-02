import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/analytics/caseload_outcomes_metrics.dart';

void main() {
  group('buildCaseloadMetrics', () {
    test('returns an empty roll-up when no series has 2+ points', () {
      final m = buildCaseloadMetrics(
        instrument: 'phq9',
        series: const [
          PatientOutcomeSeries(
              patientId: 'p1', instrument: 'phq9', scores: [12]),
        ],
      );
      expect(m.hasData, isFalse);
      expect(m.patientCount, 0);
      expect(m.avgFirstScore, 0);
      expect(m.avgLastScore, 0);
      expect(m.responseRate, 0);
    });

    test('ignores series for other instruments', () {
      final m = buildCaseloadMetrics(
        instrument: 'phq9',
        series: const [
          PatientOutcomeSeries(
              patientId: 'p1',
              instrument: 'gad7',
              scores: [16, 14, 10]),
        ],
      );
      expect(m.patientCount, 0);
    });

    test('averages first / last scores across qualifying patients', () {
      final m = buildCaseloadMetrics(
        instrument: 'phq9',
        series: const [
          PatientOutcomeSeries(
              patientId: 'p1', instrument: 'phq9', scores: [20, 14, 9]),
          PatientOutcomeSeries(
              patientId: 'p2', instrument: 'phq9', scores: [10, 8]),
        ],
      );
      expect(m.patientCount, 2);
      expect(m.avgFirstScore, (20 + 10) / 2);
      expect(m.avgLastScore, (9 + 8) / 2);
      expect(m.avgDelta, lessThan(0));
    });

    test('responseRate uses the 50%-reduction convention', () {
      final m = buildCaseloadMetrics(
        instrument: 'phq9',
        series: const [
          // Responder: 20 → 8 (-60%).
          PatientOutcomeSeries(
              patientId: 'p1', instrument: 'phq9', scores: [20, 8]),
          // Non-responder: 14 → 12 (-14%).
          PatientOutcomeSeries(
              patientId: 'p2', instrument: 'phq9', scores: [14, 12]),
          // Exact 50% — counts as responder (≤ first/2).
          PatientOutcomeSeries(
              patientId: 'p3', instrument: 'phq9', scores: [10, 5]),
        ],
      );
      expect(m.responseRate, closeTo(2 / 3, 1e-9));
    });

    test('zero-baseline patients are NOT counted as responders', () {
      final m = buildCaseloadMetrics(
        instrument: 'phq9',
        series: const [
          PatientOutcomeSeries(
              patientId: 'p1', instrument: 'phq9', scores: [0, 0]),
          PatientOutcomeSeries(
              patientId: 'p2', instrument: 'phq9', scores: [20, 8]),
        ],
      );
      expect(m.patientCount, 2);
      expect(m.responseRate, 0.5);
    });
  });
}
