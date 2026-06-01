import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_record.dart';

void main() {
  group('ConsentRecord', () {
    ConsentRecord build({
      bool dataProcessing = true,
      bool ai = true,
      bool sensitive = true,
      String signature = 'Jane Doe',
      String version = '2026-06',
    }) =>
        ConsentRecord(
          patientId: 'p1',
          policyVersion: version,
          dataProcessingConsent: dataProcessing,
          aiAssistanceConsent: ai,
          sensitiveDataConsent: sensitive,
          signedFullName: signature,
        );

    test('round-trips through JSON without losing fields', () {
      final c = build();
      final r = ConsentRecord.fromJson(c.toJson());
      expect(r.patientId, 'p1');
      expect(r.policyVersion, '2026-06');
      expect(r.dataProcessingConsent, isTrue);
      expect(r.aiAssistanceConsent, isTrue);
      expect(r.sensitiveDataConsent, isTrue);
      expect(r.signedFullName, 'Jane Doe');
      // signedAt is UTC ISO-8601 — within a small drift of build time.
      expect(
          r.signedAt.toUtc().difference(c.signedAt.toUtc()).inSeconds.abs() <=
              1,
          isTrue);
    });

    test('isValid requires data + sensitive consent + non-empty signature',
        () {
      expect(build().isValid, isTrue);
      expect(build(dataProcessing: false).isValid, isFalse);
      expect(build(sensitive: false).isValid, isFalse);
      expect(build(signature: '   ').isValid, isFalse);
      expect(build(version: '').isValid, isFalse);
    });

    test('AI consent is optional — record stays valid when withdrawn', () {
      final r = build(ai: false);
      expect(r.isValid, isTrue,
          reason: 'AI assistance consent is granular; withdrawal must not '
              'block care.');
      expect(r.aiAssistanceConsent, isFalse);
    });

    test('fromJson tolerates missing keys (returns invalid record)', () {
      final r = ConsentRecord.fromJson(const {'patientId': 'p2'});
      expect(r.patientId, 'p2');
      expect(r.dataProcessingConsent, isFalse);
      expect(r.aiAssistanceConsent, isFalse);
      expect(r.sensitiveDataConsent, isFalse);
      expect(r.signedFullName, '');
      expect(r.isValid, isFalse);
    });

    test('copyWith updates only the requested fields', () {
      final base = build(ai: false);
      final next = base.copyWith(aiAssistanceConsent: true);
      expect(next.aiAssistanceConsent, isTrue);
      expect(next.dataProcessingConsent, base.dataProcessingConsent);
      expect(next.signedFullName, base.signedFullName);
      expect(next.patientId, base.patientId);
    });

    test('toJson stores signedAt as UTC ISO-8601', () {
      final json = build().toJson();
      final signedAt = json['signedAt'] as String;
      expect(signedAt, endsWith('Z'),
          reason: 'UTC ISO-8601 timestamps must end with Z');
      expect(DateTime.tryParse(signedAt), isNotNull);
    });
  });
}
