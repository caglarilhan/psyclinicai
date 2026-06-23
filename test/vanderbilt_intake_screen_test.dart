/// Widget coverage for VanderbiltIntakeScreen — respondent toggle
/// hides ODD/conduct/anxiety; live scoring panel reflects state;
/// save flows through the repository.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/vanderbilt_assessment.dart';
import 'package:psyclinicai/screens/assessments/vanderbilt_intake_screen.dart';
import 'package:psyclinicai/services/data/vanderbilt_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  // Narrow viewport so the screen renders the column layout (score
  // panel above the form), avoiding the LayoutBuilder side-by-side
  // Row that the test framework chokes on.
  await tester.binding.setSurfaceSize(const Size(900, 4000));
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(home: screen),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('parent form shows all five symptom sections', (tester) async {
    final repo = VanderbiltRepository(storageKey: 'vb_intake_parent');
    await repo.initialize();
    await _pump(
      tester,
      VanderbiltIntakeScreen(
        patientId: 'p1',
        clinicianId: 'c1',
        repository: repo,
      ),
    );
    expect(find.text('1. Inattention'), findsOneWidget);
    expect(find.text('2. Hyperactivity / Impulsivity'), findsOneWidget);
    expect(find.text('3. Oppositional / Defiant'), findsOneWidget);
    expect(find.text('4. Conduct'), findsOneWidget);
    expect(find.text('5. Anxiety / Depression'), findsOneWidget);
    expect(find.text('Performance (academic + interpersonal)'), findsOneWidget);
  });

  testWidgets('teacher toggle hides ODD / conduct / anxiety sections', (
    tester,
  ) async {
    final repo = VanderbiltRepository(storageKey: 'vb_intake_teacher');
    await repo.initialize();
    await _pump(
      tester,
      VanderbiltIntakeScreen(
        patientId: 'p1',
        clinicianId: 'c1',
        repository: repo,
      ),
    );

    await tester.tap(find.text('Teacher'));
    await tester.pump();

    expect(find.text('1. Inattention'), findsOneWidget);
    expect(find.text('2. Hyperactivity / Impulsivity'), findsOneWidget);
    expect(find.text('3. Oppositional / Defiant'), findsNothing);
    expect(find.text('4. Conduct'), findsNothing);
    expect(find.text('5. Anxiety / Depression'), findsNothing);
  });

  testWidgets('save round-trips through the repository', (tester) async {
    final repo = VanderbiltRepository(storageKey: 'vb_intake_save');
    await repo.initialize();
    await _pump(
      tester,
      VanderbiltIntakeScreen(
        patientId: 'p1',
        clinicianId: 'c1',
        repository: repo,
        initial: VanderbiltAssessment(
          id: 'vb-fixed',
          patientId: 'p1',
          clinicianId: 'c1',
          respondent: VanderbiltRespondent.parent,
          capturedAt: DateTime.utc(2026, 6, 23),
          inattention: const [2, 2, 2, 2, 2, 2, 0, 0, 0],
          performance: const [1, 1, 4, 1, 1, 1, 1, 1],
        ),
      ),
    );

    final save = find.text('Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final rows = repo.forPatient('p1');
    expect(rows, hasLength(1));
    expect(rows.first.subtype, VanderbiltSubtype.inattentive);
  });

  testWidgets('subtype panel reflects assessment state', (tester) async {
    final repo = VanderbiltRepository(storageKey: 'vb_intake_subtype');
    await repo.initialize();
    await _pump(
      tester,
      VanderbiltIntakeScreen(
        patientId: 'p1',
        clinicianId: 'c1',
        repository: repo,
        initial: VanderbiltAssessment(
          id: 'vb-sub',
          patientId: 'p1',
          clinicianId: 'c1',
          respondent: VanderbiltRespondent.parent,
          capturedAt: DateTime.utc(2026, 6, 23),
          inattention: const [2, 2, 2, 2, 2, 2, 0, 0, 0],
          hyperactivity: const [2, 2, 2, 2, 2, 2, 0, 0, 0],
          performance: const [1, 1, 4, 1, 1, 1, 1, 1],
        ),
      ),
    );
    expect(find.text('Combined presentation'), findsOneWidget);
  });
}
