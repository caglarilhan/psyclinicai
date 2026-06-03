import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/no_show_predictor.dart';

void main() {
  final p = NoShowPredictor();
  final nowAt = DateTime.utc(2026, 6, 2, 10);

  NoShowPredictionInput input({
    int attended = 10,
    int noShow = 1,
    int daysSinceLast = 14,
    bool isNew = false,
    bool monday = false,
    bool storm = false,
    int hour = 14,
  }) =>
      NoShowPredictionInput(
        patientId: 'p-1',
        scheduledFor: DateTime.utc(2026, 6, 3, hour),
        now: nowAt,
        historicalNoShowCount: noShow,
        historicalAttendedCount: attended,
        daysSinceLastVisit: daysSinceLast,
        isNewPatient: isNew,
        isMonday: monday,
        isWinterStormForecast: storm,
      );

  group('NoShowPredictor', () {
    test('reliable patient with mid-day slot is low risk', () {
      final r = p.predict(input(attended: 20, noShow: 1, daysSinceLast: 7));
      expect(r.risk, NoShowRisk.low);
    });

    test('high historical rate + Monday + off-peak → high risk', () {
      final r = p.predict(input(
        attended: 5,
        noShow: 5,
        monday: true,
        hour: 19,
        daysSinceLast: 90,
      ));
      expect(r.risk, NoShowRisk.high);
      expect(r.reasons, isNotEmpty);
    });

    test('new patient gets first-visit reason + raises score over prior',
        () {
      final reliable = p.predict(input(attended: 0, noShow: 0));
      final isNew = p.predict(input(attended: 0, noShow: 0, isNew: true));
      expect(isNew.score, greaterThan(reliable.score));
      expect(isNew.reasons,
          contains('First visit (no history to anchor on)'));
    });

    test('score clamped to [0, 1]', () {
      final r = p.predict(input(
        attended: 0,
        noShow: 50,
        isNew: true,
        monday: true,
        storm: true,
        daysSinceLast: 120,
        hour: 6,
      ));
      expect(r.score, lessThanOrEqualTo(1.0));
      expect(r.score, greaterThan(0.0));
    });

    test('historicalNoShowRate defaults to 15% prior when no history', () {
      final inp = input(attended: 0, noShow: 0);
      expect(inp.historicalNoShowRate, closeTo(0.15, 0.0001));
    });
  });
}
