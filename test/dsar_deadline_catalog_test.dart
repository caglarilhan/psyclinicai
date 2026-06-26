import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/dsar_deadline_catalog.dart';

void main() {
  group('DsarDeadlineCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(DsarDeadlineCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = DsarDeadlineCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in DsarDeadlineCatalog.records) {
        expect(DsarDeadlineCatalog.byId(r.id), same(r));
      }
      expect(DsarDeadlineCatalog.byId('does-not-exist'), isNull);
    });

    test('every DataSubjectRight has exactly one pinned record', () {
      for (final r in DataSubjectRight.values) {
        final matches = DsarDeadlineCatalog.records
            .where((rec) => rec.right == r)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${r.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors + positive numbers', () {
      for (final r in DsarDeadlineCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
        expect(r.defaultDeadlineDays, greaterThan(0), reason: r.id);
        expect(r.maxExtensionDays, greaterThanOrEqualTo(0), reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'every record default deadline MUST be 30 days (Art. 12(3) 1-month default)',
      () {
        for (final r in DsarDeadlineCatalog.records) {
          expect(
            r.defaultDeadlineDays,
            30,
            reason:
                '${r.id}: Art. 12(3) sets a hard 1-month default; deviating without national-law basis invites supervisory blowback',
          );
        }
      },
    );

    test(
      'every record max extension MUST be 0 or 60 days (Art. 12(3) one-shot 2-month extension)',
      () {
        for (final r in DsarDeadlineCatalog.records) {
          expect(
            r.maxExtensionDays == 0 || r.maxExtensionDays == 60,
            isTrue,
            reason:
                '${r.id}: Art. 12(3) extension is one-shot 2-month; values other than 0 or 60 are not regulator-defensible',
          );
        }
      },
    );

    test(
      'objection-to-direct-marketing MUST have ZERO extension (Art. 21(2) immediate)',
      () {
        final r = DsarDeadlineCatalog.byRight(DataSubjectRight.objection)!;
        expect(
          r.maxExtensionDays,
          0,
          reason:
              'Art. 21(2) — controller must STOP direct-marketing processing immediately; no extension permitted',
        );
      },
    );

    test(
      'every right MUST be refusable for manifestly unfounded (Art. 12(5)(b) safety valve)',
      () {
        for (final r in DsarDeadlineCatalog.records) {
          expect(
            r.refusableForManifestlyUnfounded,
            isTrue,
            reason:
                '${r.id}: Art. 12(5)(b) refusal/fee right protects the controller from abusive requests; pinning otherwise removes the safety valve',
          );
        }
      },
    );

    test(
      'access + rectification MUST be hipaaEquivalent (HIPAA §164.524 + §164.526 mapping)',
      () {
        for (final right in [
          DataSubjectRight.access,
          DataSubjectRight.rectification,
        ]) {
          final r = DsarDeadlineCatalog.byRight(right)!;
          expect(
            r.hipaaEquivalent,
            isTrue,
            reason:
                '${right.name}: HIPAA §164.524/526 has a directly equivalent deadline — bridge must surface to US tenants',
          );
        }
      },
    );

    test(
      'GDPR-only rights MUST NOT claim hipaaEquivalent (no US bridge for erasure/restriction/portability/objection)',
      () {
        for (final right in [
          DataSubjectRight.erasure,
          DataSubjectRight.restriction,
          DataSubjectRight.portability,
          DataSubjectRight.objection,
        ]) {
          final r = DsarDeadlineCatalog.byRight(right)!;
          expect(
            r.hipaaEquivalent,
            isFalse,
            reason:
                '${right.name}: no direct HIPAA equivalent — over-claiming would mislead US compliance officers',
          );
        }
      },
    );

    test('every record MUST cite GDPR Art. 12(3) (deadline anchor)', () {
      for (final r in DsarDeadlineCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('GDPR Art. 12(3)'),
          isTrue,
          reason:
              '${r.id}: GDPR Art. 12(3) deadline anchor is mandatory across every right',
        );
      }
    });

    test('access record MUST cite HIPAA §164.524', () {
      final r = DsarDeadlineCatalog.byRight(DataSubjectRight.access)!;
      final blob = r.regulatoryRefs.join(' | ');
      expect(blob.contains('HIPAA §164.524'), isTrue);
    });

    test('rectification record MUST cite HIPAA §164.526', () {
      final r = DsarDeadlineCatalog.byRight(DataSubjectRight.rectification)!;
      final blob = r.regulatoryRefs.join(' | ');
      expect(blob.contains('HIPAA §164.526'), isTrue);
    });

    test(
      'erasure record MUST cite Art. 17 exceptions ((3)(b) legal obligation, (3)(c) public-health)',
      () {
        final r = DsarDeadlineCatalog.byRight(DataSubjectRight.erasure)!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('Art. 17(3)(b)'),
          isTrue,
          reason:
              'erasure needs legal-obligation exception anchor (HIPAA retention)',
        );
        expect(
          blob.contains('Art. 17(3)(c)'),
          isTrue,
          reason: 'erasure needs public-health exception anchor',
        );
      },
    );
  });

  group('maxDeadlineDays helper', () {
    test(
      'access + rectification + erasure + restriction + portability = 30 + 60 = 90 days',
      () {
        for (final right in [
          DataSubjectRight.access,
          DataSubjectRight.rectification,
          DataSubjectRight.erasure,
          DataSubjectRight.restriction,
          DataSubjectRight.portability,
        ]) {
          expect(maxDeadlineDays(right), 90, reason: right.name);
        }
      },
    );

    test('objection = 30 + 0 = 30 days (no extension allowed)', () {
      expect(maxDeadlineDays(DataSubjectRight.objection), 30);
    });
  });
}
