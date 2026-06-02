import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/screens/patients/consent_center_screen.dart';
import 'package:psyclinicai/services/data/consent_entry_repository.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: ConsentCenterScreen(patientId: 'p-1')),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    InMemoryConsentEntryRepository.instance.clearForTesting();
  });

  group('ConsentCenterScreen', () {
    testWidgets('renders six category cards in not-given state by default',
        (tester) async {
      await _pump(tester);
      expect(find.text('Not given'),
          findsNWidgets(ConsentKind.values.length));
      expect(find.text('Record consent'),
          findsNWidgets(ConsentKind.values.length));
    });

    testWidgets('recording consent flips the row to active + revoke CTA',
        (tester) async {
      InMemoryConsentEntryRepository.instance.record(
        ConsentEntry(
          id: 'ce-1',
          patientId: 'p-1',
          kind: ConsentKind.aiProcessing,
          policyVersion: '2026-06',
          signature: 'typed:John',
        ),
      );
      await _pump(tester);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Revoke'), findsOneWidget);
      expect(find.textContaining('AI processing'), findsOneWidget);
    });

    testWidgets('revoke button opens a confirm dialog with effect copy',
        (tester) async {
      InMemoryConsentEntryRepository.instance.record(
        ConsentEntry(
          id: 'ce-2',
          patientId: 'p-1',
          kind: ConsentKind.audioRecording,
          policyVersion: '2026-06',
          signature: 'typed:John',
        ),
      );
      await _pump(tester);
      await tester.tap(find.text('Revoke'));
      await tester.pumpAndSettle();
      expect(find.text('Revoke this consent?'), findsOneWidget);
      expect(find.textContaining('disable session recording'),
          findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Revoke'));
      await tester.pumpAndSettle();
      expect(
        InMemoryConsentEntryRepository.instance
            .activeOf('p-1', ConsentKind.audioRecording),
        isNull,
      );
    });
  });
}
