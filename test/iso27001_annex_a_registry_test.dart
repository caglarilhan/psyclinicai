import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/iso27001_annex_a_registry.dart';

void main() {
  group('Iso27001AnnexARegistry', () {
    test('exposes a non-empty curated catalogue', () {
      expect(Iso27001AnnexARegistry.controls, isNotEmpty);
      expect(Iso27001AnnexARegistry.total, greaterThanOrEqualTo(20));
    });

    test('every clause matches the canonical A.x.y format', () {
      final re = RegExp(r'^A\.\d+(\.\d+)?$');
      for (final c in Iso27001AnnexARegistry.controls) {
        expect(c.clause, matches(re), reason: 'invalid clause ${c.clause}');
      }
    });

    test('clauses are unique', () {
      final clauses =
          Iso27001AnnexARegistry.controls.map((c) => c.clause).toList();
      expect(clauses.length, clauses.toSet().length);
    });

    test('every entry has a non-empty title + evidence', () {
      for (final c in Iso27001AnnexARegistry.controls) {
        expect(c.title, isNotEmpty);
        expect(c.evidence, isNotEmpty);
      }
    });

    test('lastReviewed is a YYYY-MM stamp', () {
      expect(Iso27001AnnexARegistry.lastReviewed,
          matches(RegExp(r'^\d{4}-\d{2}$')));
    });

    test('byClause resolves known controls and returns null otherwise', () {
      expect(Iso27001AnnexARegistry.byClause('A.5.15')?.title,
          contains('Access control'));
      expect(Iso27001AnnexARegistry.byClause('A.99.99'), isNull);
    });

    test('statusBreakdown sums to the catalogue size', () {
      final breakdown = Iso27001AnnexARegistry.statusBreakdown();
      final total = breakdown.values.fold<int>(0, (a, b) => a + b);
      expect(total, Iso27001AnnexARegistry.total);
      expect(breakdown.keys.toSet(), AnnexAStatus.values.toSet());
    });

    test('themes cover the four Annex A blocks', () {
      final themes =
          Iso27001AnnexARegistry.controls.map((c) => c.theme).toSet();
      expect(themes,
          containsAll(['Organisational', 'People', 'Physical', 'Technological']));
    });
  });
}
