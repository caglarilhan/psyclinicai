import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/l10n/app_localizations.dart';
import 'package:psyclinicai/models/supervision_review.dart';
import 'package:psyclinicai/screens/supervision/supervision_queue_screen.dart';
import 'package:psyclinicai/services/supervision_review_repository.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SupervisionQueueScreen(supervisorId: 'sup-1'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    InMemorySupervisionReviewRepository.instance.clearForTesting();
  });

  group('SupervisionQueueScreen', () {
    testWidgets(
        'empty open + closed state — both sections show the no-data hint',
        (tester) async {
      await _pump(tester);
      expect(find.text('No notes are waiting on you.'), findsOneWidget);
      expect(find.text('No decisions on the record yet.'), findsOneWidget);
    });

    testWidgets(
        'co-sign disclaimer is always visible (legal binding warning)',
        (tester) async {
      await _pump(tester);
      expect(
          find.textContaining('NOT yet a legally binding'), findsOneWidget);
    });

    testWidgets('submitted review appears in the open section',
        (tester) async {
      InMemorySupervisionReviewRepository.instance.submit(
        clinicId: 'c1',
        traineeId: 't1',
        supervisorId: 'sup-1',
        sessionNoteId: 'note-x',
      );
      await _pump(tester);
      expect(find.textContaining('Note note-x'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Co-sign'), findsOneWidget);
    });

    testWidgets('co-signed reviews move to the closed section',
        (tester) async {
      final row =
          InMemorySupervisionReviewRepository.instance.submit(
        clinicId: 'c1',
        traineeId: 't1',
        supervisorId: 'sup-1',
        sessionNoteId: 'note-z',
      );
      InMemorySupervisionReviewRepository.instance.decide(
        id: row.id,
        next: SupervisionReviewStatus.coSigned,
      );
      await _pump(tester);
      expect(find.text('Co-signed'), findsOneWidget);
      // Closed cards must NOT expose action buttons.
      expect(find.text('Approve'), findsNothing);
      expect(find.text('Co-sign'), findsNothing);
    });
  });
}
