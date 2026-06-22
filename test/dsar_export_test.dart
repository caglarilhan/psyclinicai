import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_record.dart';
import 'package:psyclinicai/models/patient_intake.dart';
import 'package:psyclinicai/models/safety_plan.dart';
import 'package:psyclinicai/models/session_note.dart';
import 'package:psyclinicai/utils/dsar_export.dart';

void main() {
  ConsentRecord goodConsent() => ConsentRecord(
    patientId: 'p1',
    policyVersion: '2026-06',
    dataProcessingConsent: true,
    aiAssistanceConsent: true,
    sensitiveDataConsent: true,
    signedFullName: 'Jane Doe',
    signedAt: DateTime.utc(2026, 6, 1),
  );

  group('buildPatientExport', () {
    test('always carries patient_id, schema_version, generated_at, source', () {
      final bundle = buildPatientExport(
        patientId: 'p1',
        generatedAt: DateTime.utc(2026, 6, 1, 12),
      );
      expect(bundle['patient_id'], 'p1');
      expect(bundle['schema_version'], dsarSchemaVersion);
      expect(bundle['generated_at'], '2026-06-01T12:00:00.000Z');
      expect(bundle['source'], 'psyclinicai');
      expect(bundle['gdpr'], isNotNull);
    });

    test('GDPR pointer block names Article 15 and Article 20', () {
      final bundle = buildPatientExport(
        patientId: 'p',
        generatedAt: DateTime.utc(2026, 6, 1),
      );
      final gdpr = bundle['gdpr'] as Map<String, dynamic>;
      expect(gdpr['article_15'], contains('access'));
      expect(gdpr['article_20'], contains('portability'));
    });

    test('omits sections that are not supplied', () {
      final bundle = buildPatientExport(
        patientId: 'p',
        generatedAt: DateTime.utc(2026, 6, 1),
      );
      expect(bundle.containsKey('intake'), isFalse);
      expect(bundle.containsKey('consent'), isFalse);
      expect(bundle.containsKey('safety_plan'), isFalse);
      // session_notes and assessments are always present (possibly empty).
      expect(bundle['session_notes'], <dynamic>[]);
      expect(bundle['assessments'], <dynamic>[]);
    });

    test('embeds intake + safety plan + notes when supplied', () {
      final intake = PatientIntake(
        patientId: 'p1',
        fullName: 'Jane',
        presentingConcern: 'Anxiety',
        consent: goodConsent(),
      );
      final plan = SafetyPlan(
        patientId: 'p1',
        warningSigns: const ['ruminating'],
      );
      final note = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: 'S: ...',
        format: 'soap',
      );
      final bundle = buildPatientExport(
        patientId: 'p1',
        generatedAt: DateTime.utc(2026, 6, 1),
        intake: intake,
        safetyPlan: plan,
        sessionNotes: [note],
      );
      expect(bundle['intake'], isNotNull);
      expect(bundle['safety_plan'], isNotNull);
      expect((bundle['session_notes'] as List).length, 1);
    });

    test(
      'falls back to intake.consent when no explicit consent is supplied',
      () {
        final intake = PatientIntake(
          patientId: 'p1',
          fullName: 'Jane',
          presentingConcern: 'Anxiety',
          consent: goodConsent(),
        );
        final bundle = buildPatientExport(
          patientId: 'p1',
          generatedAt: DateTime.utc(2026, 6, 1),
          intake: intake,
        );
        expect(bundle['consent'], isNotNull);
        final consent = bundle['consent'] as Map<String, dynamic>;
        expect(consent['signedFullName'], 'Jane Doe');
      },
    );

    test('explicit consent argument wins over intake.consent', () {
      final intake = PatientIntake(
        patientId: 'p1',
        fullName: 'Jane',
        presentingConcern: 'Anxiety',
        consent: goodConsent(),
      );
      final newer = ConsentRecord(
        patientId: 'p1',
        policyVersion: '2026-12',
        dataProcessingConsent: true,
        aiAssistanceConsent: false,
        sensitiveDataConsent: true,
        signedFullName: 'Jane Doe',
        signedAt: DateTime.utc(2026, 12, 1),
      );
      final bundle = buildPatientExport(
        patientId: 'p1',
        generatedAt: DateTime.utc(2027, 1, 1),
        intake: intake,
        consent: newer,
      );
      final consent = bundle['consent'] as Map<String, dynamic>;
      expect(consent['policyVersion'], '2026-12');
      expect(consent['aiAssistanceConsent'], isFalse);
    });
  });

  group('isExportEmpty', () {
    test('true for a bundle with no records', () {
      final bundle = buildPatientExport(
        patientId: 'p',
        generatedAt: DateTime.utc(2026, 6, 1),
      );
      expect(isExportEmpty(bundle), isTrue);
    });

    test('false once any record block is populated', () {
      final intake = PatientIntake(patientId: 'p', fullName: 'A');
      final bundle = buildPatientExport(
        patientId: 'p',
        generatedAt: DateTime.utc(2026, 6, 1),
        intake: intake,
      );
      expect(isExportEmpty(bundle), isFalse);
    });

    test('false when at least one session note is present', () {
      final note = SessionNote(
        id: 'n',
        patientId: 'p',
        markdown: 'x',
        format: 'soap',
      );
      final bundle = buildPatientExport(
        patientId: 'p',
        generatedAt: DateTime.utc(2026, 6, 1),
        sessionNotes: [note],
      );
      expect(isExportEmpty(bundle), isFalse);
    });
  });
}
