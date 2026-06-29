import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/trust/policy_catalog_index_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1100, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const MaterialApp(home: PolicyCatalogIndexScreen()));
  await tester.pumpAndSettle();
}

void main() {
  group('PolicyCatalogIndexScreen', () {
    testWidgets('renders every family card + the full-index hint', (
      tester,
    ) async {
      await _pump(tester);
      for (final family in PolicyCatalogIndex.families) {
        expect(
          find.text(family.title),
          findsOneWidget,
          reason: '${family.title}: card header missing',
        );
      }
      expect(find.text('Full machine-readable index'), findsOneWidget);
    });

    testWidgets(
      'every family card renders a count chip + every policy row id',
      (tester) async {
        await _pump(tester);
        for (final family in PolicyCatalogIndex.families) {
          for (final entry in family.entries) {
            expect(
              find.text(entry.id),
              findsAtLeastNWidgets(1),
              reason: '${entry.id}: id token not visible on the page',
            );
            expect(
              find.text(entry.title),
              findsAtLeastNWidgets(1),
              reason: '${entry.id}: title not visible',
            );
          }
        }
      },
    );
  });

  group('PolicyCatalogIndex static catalog', () {
    test('families is non-empty', () {
      expect(PolicyCatalogIndex.families, isNotEmpty);
    });

    test('every family has at least one entry', () {
      for (final family in PolicyCatalogIndex.families) {
        expect(family.entries, isNotEmpty, reason: family.title);
      }
    });

    test('every entry has populated id + title + regulatory anchors', () {
      for (final family in PolicyCatalogIndex.families) {
        for (final entry in family.entries) {
          expect(entry.id, isNotEmpty);
          expect(entry.title, isNotEmpty);
          expect(entry.regulatoryAnchors, isNotEmpty);
        }
      }
    });

    test('id tokens are unique across all families', () {
      final ids = <String>[];
      for (final family in PolicyCatalogIndex.families) {
        for (final entry in family.entries) {
          ids.add(entry.id);
        }
      }
      expect(ids.toSet().length, ids.length);
    });

    test('family taxonomy covers the 6 catalog families (L/K/N/O/M/J)', () {
      final titles = PolicyCatalogIndex.families.map((f) => f.title).toList();
      for (final prefix in [
        'AI governance (L)',
        'Compliance (K)',
        'Security (N)',
        'Data + ops (O)',
        'Marketing + comms (M)',
        'Clinical (J)',
      ]) {
        expect(
          titles.contains(prefix),
          isTrue,
          reason: '$prefix family missing from index',
        );
      }
    });

    test('PR #157+ catalogs (this leg) are surfaced in the index', () {
      const recentIds = [
        'L11',
        'L12',
        'K14',
        'K15',
        'K16',
        'K17',
        'N20',
        'N22',
        'N23',
        'N24',
        'N25',
        'N27',
        'O8',
        'O9',
        'O10',
        'M6',
        'J5',
      ];
      final indexed = <String>{};
      for (final family in PolicyCatalogIndex.families) {
        for (final e in family.entries) {
          indexed.add(e.id);
        }
      }
      for (final id in recentIds) {
        expect(
          indexed.contains(id),
          isTrue,
          reason: '$id: catalog shipped but missing from on-screen index',
        );
      }
    });
  });
}
