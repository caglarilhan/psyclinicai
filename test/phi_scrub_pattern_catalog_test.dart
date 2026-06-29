import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/phi_scrub_pattern_catalog.dart';

void main() {
  group('PhiScrubPatternCatalog — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(PhiScrubPatternCatalog.patterns, isNotEmpty);
    });

    test('every pattern has a unique id', () {
      final ids = PhiScrubPatternCatalog.patterns.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final p in PhiScrubPatternCatalog.patterns) {
        expect(PhiScrubPatternCatalog.byId(p.id), same(p));
      }
      expect(PhiScrubPatternCatalog.byId('does-not-exist'), isNull);
    });

    test('every pattern matches its synthetic exampleMatch', () {
      for (final p in PhiScrubPatternCatalog.patterns) {
        expect(
          p.pattern.hasMatch(p.exampleMatch),
          isTrue,
          reason:
              '${p.id}: regex no longer matches its pinned example '
              '`${p.exampleMatch}` — pattern drift',
        );
      }
    });

    test('every category has at least one pinned pattern', () {
      final categories = PhiScrubPatternCatalog.patterns
          .map((p) => p.category)
          .toSet();
      for (final c in PhiCategory.values) {
        expect(
          categories,
          contains(c),
          reason: 'category ${c.name} has no pattern — coverage gap',
        );
      }
    });

    test('Safe Harbor numbers are 0 or in [1, 18]', () {
      for (final p in PhiScrubPatternCatalog.patterns) {
        if (p.safeHarborIdentifierNumber == 0) continue;
        expect(
          p.safeHarborIdentifierNumber,
          inInclusiveRange(1, 18),
          reason:
              '${p.id}: Safe Harbor identifier number must be 0 (out of '
              'scope) or 1..18 per 45 CFR §164.514(b)(2)',
        );
      }
    });

    test('app-minted ids carry no Safe Harbor number', () {
      for (final p in PhiScrubPatternCatalog.byCategory(
        PhiCategory.appMintedId,
      )) {
        expect(
          p.safeHarborIdentifierNumber,
          0,
          reason:
              '${p.id}: app-minted ids are not in the Safe Harbor list; '
              'safeHarborIdentifierNumber MUST be 0',
        );
      }
    });

    test('every Safe Harbor pattern cites the matching subparagraph', () {
      for (final p in PhiScrubPatternCatalog.patterns) {
        if (p.safeHarborIdentifierNumber == 0) continue;
        final blob = p.regulatoryRefs.join(' | ');
        expect(
          blob,
          contains('§164.514(b)(2)'),
          reason:
              '${p.id}: a Safe Harbor pattern must cite §164.514(b)(2) '
              'in its regulatoryRefs',
        );
      }
    });

    test('byCategory slices correctly', () {
      for (final c in PhiCategory.values) {
        final slice = PhiScrubPatternCatalog.byCategory(c);
        for (final p in slice) {
          expect(p.category, c);
        }
      }
    });
  });

  group('detectPhi — synthetic positive cases', () {
    test('catches e164 phone', () {
      expect(detectPhi('call +14155552671')?.category, PhiCategory.phone);
    });

    test('catches US phone', () {
      expect(detectPhi('415-555-2671')?.category, PhiCategory.phone);
    });

    test('catches email', () {
      expect(
        detectPhi('email me at jane.doe@example.com')?.category,
        PhiCategory.email,
      );
    });

    test('catches ISO date', () {
      expect(detectPhi('DOB 1985-04-12')?.category, PhiCategory.date);
    });

    test('catches MRN', () {
      expect(
        detectPhi('Chart MRN: 1234567')?.category,
        PhiCategory.medicalRecordNumber,
      );
    });

    test('catches SSN', () {
      expect(detectPhi('ssn 123-45-6789')?.category, PhiCategory.ssn);
    });

    test('catches KVNR', () {
      expect(
        detectPhi('Karte X123456789 gültig')?.category,
        PhiCategory.insuranceCardNumber,
      );
    });

    test('catches IPv4', () {
      expect(detectPhi('from 203.0.113.42')?.category, PhiCategory.ipAddress);
    });

    test('catches app-minted patient id', () {
      expect(
        detectPhi('chart for pat-abc1234567')?.category,
        PhiCategory.appMintedId,
      );
    });

    test('catches KVKK patient id', () {
      expect(
        detectPhi('hasta kvkk-pat-abc1234567')?.category,
        PhiCategory.appMintedId,
      );
    });
  });

  group('detectPhi — benign clinical phrases (no false positives)', () {
    test('plain clinical note has no PHI hit', () {
      expect(detectPhi('Patient reports improvement in mood + sleep.'), isNull);
    });

    test('Turkish benign note has no PHI hit', () {
      expect(
        detectPhi('Hasta gevşeme egzersizlerini düzenli uyguladı.'),
        isNull,
      );
    });

    test('a Likert-scale score is not a phone', () {
      expect(detectPhi('PHQ-9 score 12 / 27'), isNull);
    });

    test('a bare year is not a date', () {
      expect(detectPhi('Started CBT in 2024.'), isNull);
    });
  });

  group('hasPhi', () {
    test('returns true when text has PHI', () {
      expect(hasPhi('contact +14155552671'), isTrue);
    });

    test('returns false on benign text', () {
      expect(hasPhi('Patient is doing well.'), isFalse);
    });

    test('returns false on empty input', () {
      expect(hasPhi(''), isFalse);
    });
  });
}
