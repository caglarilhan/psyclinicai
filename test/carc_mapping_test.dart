import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/billing/carc_mapping.dart';

void main() {
  group('CARC mapping — Sprint 27 W2', () {
    test('top-50 table is fully populated', () {
      expect(carcMappingSize(), 50);
    });

    test('canonical lookup', () {
      final e = carcLookup('CO-50');
      expect(e, isNotNull);
      expect(e!.category, CarcCategory.medicalNecessity);
      expect(e.reason, contains('medically necessary'));
      expect(e.hint, contains('PHQ-9'));
    });

    test('lookup tolerates spacing, casing, and missing hyphen', () {
      expect(carcLookup('co-50'), isNotNull);
      expect(carcLookup('CO50'), isNotNull);
      expect(carcLookup('  CO 50  '), isNotNull);
      expect(carcLookup('co-50')!.code, 'CO-50');
    });

    test('unknown code returns null (no silent default)', () {
      expect(carcLookup('CO-9999'), isNull);
      expect(carcLookup(''), isNull);
      expect(carcLookup(null), isNull);
    });

    test('every entry has a non-empty hint (no blanks on the chip)', () {
      for (final e in carcAllEntries()) {
        expect(
          e.hint.trim(),
          isNotEmpty,
          reason: 'code ${e.code} has an empty hint',
        );
        expect(e.reason.trim(), isNotEmpty);
      }
    });

    test('common authorisation + medical necessity codes are mapped', () {
      for (final code in const [
        'CO-15',
        'CO-39',
        'CO-62',
        'CO-197',
        'CO-252',
        'CO-49',
        'CO-50',
        'CO-150',
        'CO-151',
        'CO-152',
      ]) {
        expect(
          carcLookup(code),
          isNotNull,
          reason: 'expected $code in the top-50 mental-health set',
        );
      }
    });
  });
}
