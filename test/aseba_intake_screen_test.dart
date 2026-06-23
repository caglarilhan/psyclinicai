/// Widget coverage for AsebaIntakeScreen — renders the form
/// picker + three score sections, summary card reflects state,
/// save round-trips through the repository.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/aseba_score_record.dart';
import 'package:psyclinicai/screens/assessments/aseba_intake_screen.dart';
import 'package:psyclinicai/services/data/aseba_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  await tester.binding.setSurfaceSize(const Size(1200, 3000));
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

  testWidgets('renders form picker + three score sections + summary', (
    tester,
  ) async {
    final repo = AsebaRepository(storageBucket: 'aseba_intake_render');
    await repo.initialize();
    await _pump(
      tester,
      AsebaIntakeScreen(patientId: 'p1', clinicianId: 'c1', repository: repo),
    );
    expect(find.text('Form'), findsOneWidget);
    expect(find.text('8 syndrome scales'), findsOneWidget);
    expect(find.text('6 DSM-oriented scales'), findsOneWidget);
    expect(find.text('3 broad-band composites'), findsOneWidget);
    expect(find.text('Live summary'), findsOneWidget);
  });

  testWidgets(
    'summary card flips when total-problems composite enters clinical band',
    (tester) async {
      final repo = AsebaRepository(storageBucket: 'aseba_intake_summary');
      await repo.initialize();
      await _pump(
        tester,
        AsebaIntakeScreen(
          patientId: 'p1',
          clinicianId: 'c1',
          repository: repo,
          initial: AsebaScoreRecord(
            id: 'rec',
            patientId: 'p1',
            clinicianId: 'c1',
            form: AsebaForm.cbclParent,
            capturedAt: DateTime.utc(2026, 6, 23),
            compositeT: const {AsebaCompositeScale.totalProblems: 70},
          ),
        ),
      );
      expect(find.text('Total problems: clinical'), findsOneWidget);
    },
  );

  testWidgets('save round-trips through the repository', (tester) async {
    final repo = AsebaRepository(storageBucket: 'aseba_intake_save');
    await repo.initialize();
    await _pump(
      tester,
      AsebaIntakeScreen(
        patientId: 'p1',
        clinicianId: 'c1',
        repository: repo,
        initial: AsebaScoreRecord(
          id: 'rec-save',
          patientId: 'p1',
          clinicianId: 'c1',
          form: AsebaForm.trfTeacher,
          capturedAt: DateTime.utc(2026, 6, 23),
          syndromeT: const {AsebaSyndromeScale.attentionProblems: 72},
        ),
      ),
    );

    final save = find.text('Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final list = repo.forPatient('p1');
    expect(list, hasLength(1));
    expect(list.first.form, AsebaForm.trfTeacher);
    expect(list.first.syndromeT[AsebaSyndromeScale.attentionProblems], 72);
  });
}
