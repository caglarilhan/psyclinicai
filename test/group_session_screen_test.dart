import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/group_session.dart';
import 'package:psyclinicai/screens/group_session/group_session_screen.dart';

Future<void> _pump(WidgetTester tester, {GroupSession? session}) async {
  await tester.pumpWidget(
    MaterialApp(home: GroupSessionScreen(session: session)),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('GroupSessionScreen', () {
    testWidgets('renders the demo facilitator note when no session passed',
        (tester) async {
      await _pump(tester);
      expect(find.text('Facilitator note'), findsOneWidget);
      expect(
        find.textContaining('grounding exercise'),
        findsOneWidget,
      );
    });

    testWidgets('roster rows expose patient id + attendance tag',
        (tester) async {
      await _pump(tester);
      expect(find.text('p-001'), findsOneWidget);
      expect(find.text('p-002'), findsOneWidget);
      expect(find.text('attended'), findsAtLeastNWidgets(1));
      expect(find.text('absent'), findsAtLeastNWidgets(1));
    });

    testWidgets('capacity chip surfaces "cap" when at max', (tester) async {
      final atCap = GroupSession(
        id: 'gs-full',
        clinicId: 'c-1',
        modalityLabel: 'Full house',
        scheduledAt: DateTime.utc(2026, 6, 11, 17),
        roster: List.generate(
          GroupSession.maxRosterSize,
          (i) => GroupSessionAttendance(
            patientId: 'p-$i',
            subNoteId: 'n-$i',
          ),
        ),
      );
      await _pump(tester, session: atCap);
      expect(find.textContaining('cap'), findsAtLeastNWidgets(1));
    });

    testWidgets('HIPAA note surfaces the per-patient sub-note rule',
        (tester) async {
      await _pump(tester);
      expect(
        find.textContaining(RegExp('per-patient subjective notes',
            caseSensitive: false)),
        findsOneWidget,
      );
    });
  });
}
