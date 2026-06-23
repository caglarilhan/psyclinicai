/// Widget smoke test for GenogramCanvasScreen — empty state when
/// no genogram exists, canvas + pattern footer when populated.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/genogram.dart';
import 'package:psyclinicai/screens/family/genogram_canvas_screen.dart';
import 'package:psyclinicai/services/data/genogram_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1600));
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows empty state when no genogram exists', (tester) async {
    final repo = GenogramRepository(storageKey: 'geno_canvas_empty');
    await repo.initialize();
    await _pump(
      tester,
      GenogramCanvasScreen(
        patientId: 'p1',
        patientName: 'Test',
        repository: repo,
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('No genogram yet'), findsOneWidget);
  });

  testWidgets('renders pattern footer when an attribute repeats', (
    tester,
  ) async {
    final repo = GenogramRepository(storageKey: 'geno_canvas_pattern');
    await repo.initialize();
    await repo.upsert(
      Genogram(
        id: 'g1',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23),
        people: const [
          GenogramPerson(
            id: 'self',
            label: 'Self',
            isIndexPatient: true,
            attributes: [GenogramAttribute.anxiety],
          ),
          GenogramPerson(
            id: 'mom',
            label: 'Mom',
            attributes: [GenogramAttribute.anxiety],
          ),
          GenogramPerson(id: 'dad', label: 'Dad'),
        ],
        relationships: const [
          GenogramRelationship(
            fromPersonId: 'mom',
            toPersonId: 'self',
            kind: GenogramRelationshipKind.parentChild,
          ),
        ],
      ),
    );
    await _pump(
      tester,
      GenogramCanvasScreen(
        patientId: 'p1',
        patientName: 'Test',
        repository: repo,
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Pattern footer'), findsOneWidget);
    expect(find.text('Anxiety x 2'), findsOneWidget);
  });
}
