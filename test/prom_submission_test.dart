import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/prom_submission.dart';

void main() {
  group('PromSubmission', () {
    test('refuses a negative score at construction', () {
      expect(
        () => PromSubmission(
          id: 'p-x',
          patientId: 'pt-1',
          instrument: 'phq9',
          score: -1,
          severity: 'minimal',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('JSON round-trip preserves responses + clinician id', () {
      final row = PromSubmission(
        id: 'p-1',
        patientId: 'pt-1',
        instrument: 'phq9',
        score: 12,
        severity: 'moderate',
        requestedByClinicianId: 'doc-1',
        responses: const {'phq9_1': 2, 'phq9_9': 1},
        completedAt: DateTime.utc(2026, 6, 10),
      );
      final round = PromSubmission.fromJson(row.toJson());
      expect(round.id, row.id);
      expect(round.instrument, 'phq9');
      expect(round.score, 12);
      expect(round.severity, 'moderate');
      expect(round.requestedByClinicianId, 'doc-1');
      expect(round.responses, {'phq9_1': 2, 'phq9_9': 1});
      expect(round.completedAt, row.completedAt);
    });

    test('patient self-initiated submission omits clinician id', () {
      final row = PromSubmission(
        id: 'p-2',
        patientId: 'pt-2',
        instrument: 'gad7',
        score: 5,
        severity: 'mild',
      );
      final json = row.toJson();
      expect(json.containsKey('requestedByClinicianId'), isFalse);
    });

    test('PHQ-9 item 9 positive triggers a high-risk follow-up', () {
      final row = PromSubmission(
        id: 'p-3',
        patientId: 'pt-1',
        instrument: 'phq9',
        score: 11,
        severity: 'moderate',
        responses: const {'phq9_1': 2, 'phq9_9': 2},
      );
      expect(row.phq9Item9Positive, isTrue);
      expect(row.triggersHighRiskFollowUp, isTrue);
    });

    test('PHQ-9 item 9 zero does NOT trigger follow-up', () {
      final row = PromSubmission(
        id: 'p-4',
        patientId: 'pt-1',
        instrument: 'phq9',
        score: 8,
        severity: 'mild',
        responses: const {'phq9_1': 2, 'phq9_9': 0},
      );
      expect(row.phq9Item9Positive, isFalse);
      expect(row.triggersHighRiskFollowUp, isFalse);
    });

    test('non-PHQ-9 instruments never flag PHQ-9 item 9', () {
      final row = PromSubmission(
        id: 'p-5',
        patientId: 'pt-1',
        instrument: 'gad7',
        score: 10,
        severity: 'moderate',
        responses: const {'gad7_2': 2},
      );
      expect(row.phq9Item9Positive, isNull);
      expect(row.triggersHighRiskFollowUp, isFalse);
    });

    test('PHQ-9 without raw responses cannot derive the flag', () {
      final row = PromSubmission(
        id: 'p-6',
        patientId: 'pt-1',
        instrument: 'phq9',
        score: 11,
        severity: 'moderate',
      );
      expect(row.phq9Item9Positive, isNull);
      expect(row.triggersHighRiskFollowUp, isFalse);
    });
  });
}
