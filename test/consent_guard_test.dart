import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_record.dart';
import 'package:psyclinicai/services/compliance/consent_guard.dart';

void main() {
  ConsentRecord build({
    bool aiAssistance = true,
    bool dataProcessing = true,
    bool sensitive = true,
    String signature = 'Jane Doe',
    String version = '2026-06',
  }) =>
      ConsentRecord(
        patientId: 'p1',
        policyVersion: version,
        dataProcessingConsent: dataProcessing,
        aiAssistanceConsent: aiAssistance,
        sensitiveDataConsent: sensitive,
        signedFullName: signature,
      );

  group('ConsentGuard.aiAllowed', () {
    test('false when the patient has no consent record on file', () {
      final guard = ConsentGuard.fromMap(const {});
      expect(guard.aiAllowed('p1'), isFalse);
    });

    test('true when a valid record explicitly grants AI consent', () {
      final guard = ConsentGuard.fromMap({'p1': build()});
      expect(guard.aiAllowed('p1'), isTrue);
    });

    test('false when AI consent is explicitly withdrawn', () {
      final guard = ConsentGuard.fromMap(
          {'p1': build(aiAssistance: false)});
      expect(guard.aiAllowed('p1'), isFalse);
    });

    test('false when the consent record itself is invalid (missing sig)',
        () {
      final guard = ConsentGuard.fromMap(
          {'p1': build(signature: '   ')});
      expect(guard.aiAllowed('p1'), isFalse);
    });

    test('false when required data-processing consent is missing', () {
      final guard = ConsentGuard.fromMap(
          {'p1': build(dataProcessing: false)});
      expect(guard.aiAllowed('p1'), isFalse,
          reason: 'AI is denied unless the base consent stack is valid');
    });

    test('default lookup denies every patient (fail-closed)', () {
      final guard = ConsentGuard();
      expect(guard.aiAllowed('p1'), isFalse);
      expect(guard.aiAllowed('anyone'), isFalse);
    });
  });

  group('ConsentGuard.requireAi', () {
    test('throws ConsentDeniedException when AI is denied', () {
      final guard = ConsentGuard.fromMap(
          {'p1': build(aiAssistance: false)});
      expect(() => guard.requireAi('p1'),
          throwsA(isA<ConsentDeniedException>()));
    });

    test('returns silently when AI is allowed', () {
      final guard = ConsentGuard.fromMap({'p1': build()});
      expect(() => guard.requireAi('p1'), returnsNormally);
    });

    test('exception carries the patient id and a reason code', () {
      final guard = ConsentGuard.fromMap(const {});
      try {
        guard.requireAi('p-missing');
        fail('expected throw');
      } on ConsentDeniedException catch (e) {
        expect(e.patientId, 'p-missing');
        expect(e.reason, isNotEmpty);
      }
    });
  });
}
