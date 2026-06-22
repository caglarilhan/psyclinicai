/// CI #6 close — smoke coverage for the mood-tracker screen.
/// Daily mood / sleep / anxiety check-in feeds the longitudinal
/// outcomes story (PHQ-9 + GAD-7 dashboard relies on these
/// inputs). A silent render failure would break MBC ("Measurement-
/// Based Care") capture for every patient in the cohort.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/mood_tracking/mood_tracking_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wide(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('renders the daily check-in shell + the three sliders', (
    tester,
  ) async {
    await wide(tester);
    await tester.pumpWidget(const MaterialApp(home: MoodTrackingScreen()));
    await tester.pumpAndSettle();

    // Page title + subtitle copy: regression on these strings would
    // mean the AppShell wiring drifted.
    expect(find.text('Mood tracker'), findsWidgets);
    expect(find.textContaining('Daily mood'), findsWidgets);

    // Three labelled sliders — Mood, Sleep quality, Anxiety. These
    // are the MBC inputs; the underlying widget is _Slider in the
    // screen but its visible label is what we assert on.
    expect(find.text('Mood'), findsWidgets);
    expect(find.text('Sleep quality'), findsWidgets);
    expect(find.text('Anxiety'), findsWidgets);
  });
}
