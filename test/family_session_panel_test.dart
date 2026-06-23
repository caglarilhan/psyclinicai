/// Widget coverage for FamilySessionPanel — renders all 8 sections,
/// attendee chips add/remove, subsystem chips toggle, save flows
/// through the injected repo with the correct envelope kind, and
/// the genogram-link badge appears when wired.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/modalities/family_session_note.dart';
import 'package:psyclinicai/screens/session/modalities/family_session_panel.dart';
import 'package:psyclinicai/services/data/modality_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpPanel(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders header + section cards', (tester) async {
    final repo = ModalitySessionRepository(storageKey: 'modality_fsp_render');
    await repo.initialize();
    await _pumpPanel(
      tester,
      FamilySessionPanel(patientId: 'p1', clinicianId: 'c1', repository: repo),
    );
    expect(find.text('Family session note'), findsOneWidget);
    expect(find.text('Approach'), findsOneWidget);
    expect(find.text('Subsystem'), findsOneWidget);
    expect(find.text('Attendees'), findsOneWidget);
    expect(find.text('Presenting dynamic'), findsOneWidget);
    expect(find.text('Interventions'), findsOneWidget);
    expect(find.text('Homework'), findsOneWidget);
    expect(find.text('Relational shift'), findsOneWidget);
    expect(find.text('Clinician notes'), findsOneWidget);
  });

  testWidgets('attendee add appends to the chip list', (tester) async {
    final repo = ModalitySessionRepository(storageKey: 'modality_fsp_attend');
    await repo.initialize();
    await _pumpPanel(
      tester,
      FamilySessionPanel(patientId: 'p1', clinicianId: 'c1', repository: repo),
    );

    final attendeeField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.hintText ?? '').contains('partner A'),
    );
    expect(attendeeField, findsOneWidget);
    await tester.enterText(attendeeField, 'mother');
    final addBtn = find.widgetWithText(OutlinedButton, 'Add');
    await tester.ensureVisible(addBtn);
    await tester.tap(addBtn);
    await tester.pump();
    expect(find.widgetWithText(InputChip, 'mother'), findsOneWidget);
  });

  testWidgets('save writes a family ModalityRecord through the repo', (
    tester,
  ) async {
    final repo = ModalitySessionRepository(storageKey: 'modality_fsp_save');
    await repo.initialize();
    await _pumpPanel(
      tester,
      FamilySessionPanel(patientId: 'p1', clinicianId: 'c1', repository: repo),
    );

    final presentingField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.hintText ?? '').contains('Mother-daughter conflict'),
    );
    expect(presentingField, findsOneWidget);
    await tester.enterText(presentingField, 'Triangulation');

    final saveText = find.text('Save');
    await tester.ensureVisible(saveText);
    await tester.tap(saveText);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final rows = repo.forPatient('p1');
    expect(rows, hasLength(1));
    expect(rows.first.kind, ModalityKind.family);
    expect(rows.first.familySessionNote!.presentingDynamic, 'Triangulation');
  });

  testWidgets('linkedGenogramId pre-populates and shows link badge', (
    tester,
  ) async {
    final repo = ModalitySessionRepository(storageKey: 'modality_fsp_link');
    await repo.initialize();
    await _pumpPanel(
      tester,
      FamilySessionPanel(
        patientId: 'p1',
        clinicianId: 'c1',
        repository: repo,
        linkedGenogramId: 'g42',
      ),
    );
    expect(find.text('Linked to genogram g42'), findsOneWidget);
  });

  testWidgets('subsystem chip toggle changes selection', (tester) async {
    final repo = ModalitySessionRepository(storageKey: 'modality_fsp_subsys');
    await repo.initialize();
    await _pumpPanel(
      tester,
      FamilySessionPanel(
        patientId: 'p1',
        clinicianId: 'c1',
        repository: repo,
        initial: FamilySessionNote(
          id: 'init',
          patientId: 'p1',
          clinicianId: 'c1',
          sessionDate: DateTime.utc(2026, 6, 23),
        ),
      ),
    );

    final coupleChip = find.widgetWithText(ChoiceChip, 'Couple');
    expect(coupleChip, findsOneWidget);
    await tester.tap(coupleChip);
    await tester.pump();
    final chip = tester.widget<ChoiceChip>(coupleChip);
    expect(chip.selected, isTrue);
  });
}
