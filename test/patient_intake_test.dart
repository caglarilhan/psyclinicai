import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_record.dart';
import 'package:psyclinicai/models/patient_intake.dart';

void main() {
  group('PatientIntake', () {
    ConsentRecord validConsent() => ConsentRecord(
      patientId: 'p1',
      policyVersion: '2026-06',
      dataProcessingConsent: true,
      aiAssistanceConsent: true,
      sensitiveDataConsent: true,
      signedFullName: 'Jane Doe',
    );

    test('round-trips through JSON, preserving all blocks', () {
      final intake = PatientIntake(
        patientId: 'p1',
        fullName: 'Jane Doe',
        dateOfBirth: DateTime.parse('1990-04-12'),
        gender: 'F',
        phone: '+1-555-0101',
        email: 'jane@example.com',
        emergencyContactName: 'Sam Doe',
        emergencyContactPhone: '+1-555-0102',
        presentingConcern: 'Persistent low mood for 3 months',
        allergies: const ['Penicillin'],
        currentMedications: const ['Sertraline 50 mg qD'],
        medicalHistory: 'No chronic conditions',
        mentalHealthHistory: 'Mild MDE in 2022',
        substanceUse: 'Occasional alcohol',
        consent: validConsent(),
      );

      final r = PatientIntake.fromJson(intake.toJson());
      expect(r.patientId, 'p1');
      expect(r.fullName, 'Jane Doe');
      expect(r.dateOfBirth, DateTime.parse('1990-04-12'));
      expect(r.allergies, ['Penicillin']);
      expect(r.currentMedications, ['Sertraline 50 mg qD']);
      expect(r.presentingConcern, 'Persistent low mood for 3 months');
      expect(r.consent, isNotNull);
      expect(r.consent!.isValid, isTrue);
    });

    test('isComplete requires name + presenting concern + valid consent', () {
      final base = PatientIntake(patientId: 'p1');
      expect(base.isComplete, isFalse, reason: 'all blocks empty');

      final withName = base.copyWith(
        fullName: 'Jane',
        presentingConcern: 'Stress',
      );
      expect(
        withName.isComplete,
        isFalse,
        reason: 'consent record still missing',
      );

      final withInvalidConsent = withName.copyWith(
        consent: ConsentRecord(
          patientId: 'p1',
          policyVersion: '2026-06',
          dataProcessingConsent: false, // missing required
          aiAssistanceConsent: true,
          sensitiveDataConsent: true,
          signedFullName: 'Jane',
        ),
      );
      expect(withInvalidConsent.isComplete, isFalse);

      final full = withName.copyWith(consent: validConsent());
      expect(full.isComplete, isTrue);
    });

    test(
      'fromJson tolerates missing keys (returns sparse but valid object)',
      () {
        final r = PatientIntake.fromJson(const {'patientId': 'p2'});
        expect(r.patientId, 'p2');
        expect(r.fullName, '');
        expect(r.allergies, isEmpty);
        expect(r.currentMedications, isEmpty);
        expect(r.priorSuicideAttempt, isFalse);
        expect(r.consent, isNull);
        expect(r.isComplete, isFalse);
      },
    );

    test('allergies and meds strip whitespace-only entries on decode', () {
      final r = PatientIntake.fromJson({
        'patientId': 'p3',
        'allergies': ['Latex', '   ', '', 'Peanuts'],
        'currentMedications': ['Lithium 600 mg BID'],
      });
      expect(r.allergies, ['Latex', 'Peanuts']);
      expect(r.currentMedications, ['Lithium 600 mg BID']);
    });

    test('copyWith preserves untouched fields and refreshes updatedAt', () {
      final before = PatientIntake(
        patientId: 'p4',
        fullName: 'Jane',
        priorSuicideAttempt: true,
      );
      final after = before.copyWith(presentingConcern: 'Stress');
      expect(after.fullName, 'Jane');
      expect(after.priorSuicideAttempt, isTrue);
      expect(after.presentingConcern, 'Stress');
      expect(
        after.updatedAt.isAfter(before.updatedAt) ||
            after.updatedAt.isAtSameMomentAs(before.updatedAt),
        isTrue,
      );
    });

    test('toJson omits null demographic fields to keep the row compact', () {
      final intake = PatientIntake(patientId: 'p5', fullName: 'Jane');
      final json = intake.toJson();
      expect(json.containsKey('gender'), isFalse);
      expect(json.containsKey('phone'), isFalse);
      expect(json.containsKey('email'), isFalse);
      expect(json.containsKey('dateOfBirth'), isFalse);
      // Required fields always present.
      expect(json['patientId'], 'p5');
      expect(json['allergies'], <String>[]);
    });
  });
}
