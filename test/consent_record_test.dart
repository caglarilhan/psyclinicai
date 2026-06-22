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
    }) => ConsentRecord(
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
        r.signedAt.toUtc().difference(c.signedAt.toUtc()).inSeconds.abs() <= 1,
        isTrue,
      );
    });

    test('isValid requires data + sensitive consent + non-empty signature', () {
      expect(build().isValid, isTrue);
      expect(build(dataProcessing: false).isValid, isFalse);
      expect(build(sensitive: false).isValid, isFalse);
      expect(build(signature: '   ').isValid, isFalse);
      expect(build(version: '').isValid, isFalse);
    });

    test('AI consent is optional — record stays valid when withdrawn', () {
      final r = build(ai: false);
      expect(
        r.isValid,
        isTrue,
        reason:
            'AI assistance consent is granular; withdrawal must not '
            'block care.',
      );
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
      expect(
        signedAt,
        endsWith('Z'),
        reason: 'UTC ISO-8601 timestamps must end with Z',
      );
      expect(DateTime.tryParse(signedAt), isNotNull);
    });

    test('withdrawnAt invalidates the record (GDPR Art. 7(3))', () {
      final live = build();
      expect(live.isValid, isTrue);
      expect(live.isWithdrawn, isFalse);

      final withdrawn = live.copyWith(
        withdrawnAt: DateTime.utc(2026, 6, 5, 10),
      );
      expect(withdrawn.isValid, isFalse);
      expect(withdrawn.isWithdrawn, isTrue);
    });

    // L-8 fix coverage — applicable bases let the record carry the
    // legal framework(s) the patient agreed under (GDPR / KVKK /
    // HIPAA) instead of folding every locale into "GDPR".
    group('applicableBases (L-8)', () {
      test('defaults to empty set when no bases supplied', () {
        final r = build();
        expect(r.applicableBases, isEmpty);
        expect(r.coversGdpr, isFalse);
        expect(r.coversKvkk, isFalse);
        expect(r.coversHipaa, isFalse);
      });

      test('KVKK + GDPR + HIPAA detectors fire on the right basis', () {
        final r = build().copyWith(
          applicableBases: {
            ConsentBasis.kvkkMd5Explicit,
            ConsentBasis.gdprArt6Consent,
            ConsentBasis.hipaaAuthorisation,
          },
        );
        expect(r.coversKvkk, isTrue);
        expect(r.coversGdpr, isTrue);
        expect(r.coversHipaa, isTrue);
      });

      test('toJson emits stable wire encoding for each basis', () {
        final json = build()
            .copyWith(applicableBases: {ConsentBasis.kvkkMd6Health})
            .toJson();
        expect(json['applicableBases'], ['kvkk_md_6_health']);
      });

      test('toJson omits the field when empty (back-compat)', () {
        final json = build().toJson();
        expect(json.containsKey('applicableBases'), isFalse);
      });

      test('fromJson round-trips the wire encoding', () {
        final src = build().copyWith(
          applicableBases: {
            ConsentBasis.gdprArt9Explicit,
            ConsentBasis.kvkkMd5Explicit,
          },
        );
        final r = ConsentRecord.fromJson(src.toJson());
        expect(r.applicableBases, src.applicableBases);
      });

      test('fromJson tolerates unknown basis strings (drop, do not throw)', () {
        final r = ConsentRecord.fromJson({
          'patientId': 'p3',
          'applicableBases': ['gdpr_art_6_consent', 'unknown_basis'],
        });
        expect(r.applicableBases, {ConsentBasis.gdprArt6Consent});
      });

      test('ConsentBasis.fromWire returns null for unknown values', () {
        expect(ConsentBasis.fromWire('not_a_basis'), isNull);
        expect(
          ConsentBasis.fromWire('gdpr_art_6_consent'),
          ConsentBasis.gdprArt6Consent,
        );
      });
    });

    test('withdrawnAt survives JSON round-trip', () {
      final src = build().copyWith(withdrawnAt: DateTime.utc(2026, 6, 5, 10));
      final back = ConsentRecord.fromJson(src.toJson());
      expect(back.withdrawnAt?.toUtc(), src.withdrawnAt?.toUtc());
      expect(back.isValid, isFalse);
    });

    test('toJson omits withdrawnAt when the record is still live', () {
      expect(build().toJson().containsKey('withdrawnAt'), isFalse);
    });
  });
}
