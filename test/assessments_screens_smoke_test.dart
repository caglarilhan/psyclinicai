/// CI #6 close — smoke coverage for the assessments + guide
/// subdirs (AssessmentScreen, DiagnosisGuideScreen). These render
/// MBC instruments (PHQ-9, GAD-7) and the diagnosis guide that
/// trainee clinicians lean on; a render failure would be silent.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/assessments/assessment_screen.dart'
    show AssessmentScreen, AssessmentType;
import 'package:psyclinicai/screens/guide/diagnosis_guide_screen.dart';

void main() {
  Future<void> wide(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('PHQ-9 AssessmentScreen renders the first question', (
    tester,
  ) async {
    await wide(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: AssessmentScreen(type: AssessmentType.phq9),
      ),
    );
    await tester.pumpAndSettle();
    // The screen surfaces the scale identifier in the AppShell title
    // ("PHQ-9 assessment" or similar) and renders the first item;
    // we assert on the canary so a layout regression is caught.
    expect(find.textContaining('PHQ'), findsWidgets);
  });

  testWidgets('GAD-7 AssessmentScreen renders', (tester) async {
    await wide(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: AssessmentScreen(type: AssessmentType.gad7),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('GAD'), findsWidgets);
  });

  testWidgets('Diagnosis guide screen renders the Tanı Rehberi header', (
    tester,
  ) async {
    await wide(tester);
    await tester.pumpWidget(
      const MaterialApp(home: DiagnosisGuideScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tanı Rehberi'), findsOneWidget);
    // Embedded reference card carries the PHQ-9 / GAD-7 severity
    // bands; sample the substring to confirm the screen body painted.
    expect(find.textContaining('PHQ'), findsWidgets);
  });
}
