import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/billing/icd10_lookup_service.dart';

/// Diagnostic-coding correctness: a wrong ICD-10 code on a submitted claim is a
/// denial. The picker is driven by search(), so its matching rules are pinned.
void main() {
  final svc = Icd10LookupService.instance;

  group('search', () {
    test('empty query returns the full set', () {
      expect(svc.search('').length, svc.all().length);
      expect(svc.search('   ').length, svc.all().length);
    });

    test('synonym match: "ptsd" -> F43.10', () {
      expect(svc.search('ptsd').map((c) => c.code), contains('F43.10'));
    });

    test('code-prefix match: "F32" -> the four single-episode MDD codes', () {
      final codes = svc.search('F32').map((c) => c.code).toSet();
      expect(codes, {'F32.0', 'F32.1', 'F32.2', 'F32.9'});
    });

    test('case-insensitive label match: "DEPRESSION" hits F32.9', () {
      expect(svc.search('DEPRESSION').map((c) => c.code), contains('F32.9'));
    });

    test('no match returns empty', () {
      expect(svc.search('xyz999'), isEmpty);
    });
  });

  group('lookup', () {
    test('byCode resolves a known code and is null for unknown', () {
      expect(svc.byCode('F43.10')?.label, contains('Post-traumatic'));
      expect(svc.byCode('X99.9'), isNull);
    });

    test('byCategory(zCode) returns exactly the curated Z-codes', () {
      final z = svc.byCategory(Icd10Category.zCode).map((c) => c.code).toSet();
      expect(z, {'Z63.0', 'Z63.4', 'Z73.0'});
    });

    test('byCategory(substance) returns the three dependence codes', () {
      expect(svc.byCategory(Icd10Category.substance), hasLength(3));
    });
  });
}
