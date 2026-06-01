import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/caseload_outcomes.dart';

void main() {
  final baseDate = DateTime.utc(2026, 6, 1);
  AppointmentOutcome appt(String status) =>
      AppointmentOutcome(status: status, scheduledFor: baseDate);

  group('AppointmentOutcome flags', () {
    test('completed / no-show / cancelled are correctly recognised', () {
      final completed = appt('Completed');
      final noShow = appt('No-Show');
      final cancel = appt('Cancelled');

      expect(completed.isCompleted, isTrue);
      expect(completed.isFinalised, isTrue);
      expect(noShow.isNoShow, isTrue);
      expect(noShow.isFinalised, isTrue);
      expect(cancel.isFinalised, isTrue);
      expect(cancel.isCompleted, isFalse);
    });

    test('case-insensitive and variant spellings count', () {
      expect(appt('no_show').isNoShow, isTrue);
      expect(appt('NoShow').isNoShow, isTrue);
    });

    test('scheduled / pending statuses are NOT finalised', () {
      expect(appt('Scheduled').isFinalised, isFalse);
    });
  });

  group('buildCaseloadMetrics', () {
    test('returns an empty snapshot when no signals are supplied', () {
      final m = buildCaseloadMetrics();
      expect(m.totalSamples, 0);
      expect(m.totalAppointments, 0);
      expect(m.noShowCount, 0);
      expect(m.noShowRate, 0);
      expect(m.completedGoalsRatio, 0);
      expect(m.firstSample, isNull);
      expect(m.latestSample, isNull);
      expect(m.delta, isNull);
      expect(m.hasReliableImprovement, isFalse);
    });

    test('delta is the signed change from earliest to latest sample', () {
      final m = buildCaseloadMetrics(samples: [
        OutcomeSample(score: 18, takenAt: DateTime.utc(2026, 1, 1)),
        OutcomeSample(score: 12, takenAt: DateTime.utc(2026, 3, 1)),
        OutcomeSample(score: 8, takenAt: DateTime.utc(2026, 5, 1)),
      ]);
      expect(m.totalSamples, 3);
      expect(m.firstSample!.score, 18);
      expect(m.latestSample!.score, 8);
      expect(m.delta, -10);
      expect(m.hasReliableImprovement, isTrue);
    });

    test('reorders samples chronologically before computing delta', () {
      final m = buildCaseloadMetrics(samples: [
        OutcomeSample(score: 8, takenAt: DateTime.utc(2026, 5, 1)),
        OutcomeSample(score: 18, takenAt: DateTime.utc(2026, 1, 1)),
      ]);
      expect(m.firstSample!.score, 18);
      expect(m.latestSample!.score, 8);
      expect(m.delta, -10);
    });

    test('single sample reports null delta and false improvement', () {
      final m = buildCaseloadMetrics(samples: [
        OutcomeSample(score: 14, takenAt: DateTime.utc(2026, 4, 1)),
      ]);
      expect(m.delta, isNull);
      expect(m.hasReliableImprovement, isFalse);
    });

    test('hasReliableImprovement requires at least a -5 delta', () {
      final small = buildCaseloadMetrics(samples: [
        OutcomeSample(score: 14, takenAt: DateTime.utc(2026, 1, 1)),
        OutcomeSample(score: 12, takenAt: DateTime.utc(2026, 5, 1)),
      ]);
      expect(small.delta, -2);
      expect(small.hasReliableImprovement, isFalse);
    });

    test('no-show rate denominator excludes pending future appointments',
        () {
      final m = buildCaseloadMetrics(appointments: [
        appt('Scheduled'),
        appt('Completed'),
        appt('No-Show'),
      ]);
      expect(m.totalAppointments, 3);
      expect(m.finalisedAppointments, 2);
      expect(m.noShowCount, 1);
      expect(m.noShowRate, closeTo(0.5, 1e-9));
    });

    test('completedGoalsRatio counts only fully met goals', () {
      final m = buildCaseloadMetrics(
        goalProgressValues: const [100, 80, 50, 100],
      );
      expect(m.completedGoalsRatio, 0.5);
    });

    test('completedGoalsRatio is 0 when there are no goals', () {
      expect(buildCaseloadMetrics().completedGoalsRatio, 0.0);
    });
  });
}
