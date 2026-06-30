import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/screens/mbc/mbc_patient_form_screen.dart';
import 'package:psyclinicai/services/mbc/mbc_client.dart';

void main() {
  testWidgets('renders PHQ-9 title + question prompts + disabled submit',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final client = MbcPublicClient(
      submitUrl: 'https://example.test/mbcSubmitAssessment',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MbcPatientFormScreen(
          client: client,
          scaleId: 'phq9',
          token: 'tok-test',
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('Patient Health Questionnaire-9'),
      findsOneWidget,
    );
    final submit = find.widgetWithText(FilledButton, 'Submit');
    expect(submit, findsOneWidget);
    final btn = tester.widget<FilledButton>(submit);
    expect(btn.onPressed, isNull);
  });

  testWidgets('shows result panel after successful submit', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final client = MbcPublicClient(
      submitUrl: 'https://example.test/mbcSubmitAssessment',
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'scaleId': 'gad7',
            'score': 5,
            'maxScore': 21,
            'severity': 'mild',
            'alarmTriggered': false,
            'clinicianAction': 'Watchful waiting.',
          }),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MbcPatientFormScreen(
          client: client,
          scaleId: 'gad7',
          token: 'tok-test',
        ),
      ),
    );
    await tester.pump();

    // Tap "Not at all" for all 7 GAD-7 questions (first radio for each).
    final notAtAll = find.text('Not at all');
    expect(notAtAll, findsNWidgets(7));
    for (var i = 0; i < 7; i++) {
      await tester.tap(notAtAll.at(i));
      await tester.pump();
    }

    final submit = find.widgetWithText(FilledButton, 'Submit');
    await tester.tap(submit);
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Thank you'), findsOneWidget);
    expect(find.textContaining('5 / 21'), findsOneWidget);
  });
}
