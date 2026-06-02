import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/telehealth_session.dart';
import 'package:psyclinicai/widgets/telehealth_controls.dart';

TelehealthSession _session({
  VisitConsent visit = VisitConsent.notAsked,
  RecordingConsent recording = RecordingConsent.notAsked,
}) =>
    TelehealthSession(
      id: 'tx-1',
      clinicId: 'c-1',
      sessionId: 's-1',
      patientId: 'p-1',
      clinicianId: 'doc-1',
      roomName: 'psy-c1-s1',
      scheduledFor: DateTime.utc(2026, 6, 12, 14),
      visitConsent: visit,
      recordingConsent: recording,
    );

Future<void> _pump(
  WidgetTester tester, {
  required TelehealthSession session,
  VoidCallback? onOpenRoom,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TelehealthControls(
          session: session,
          onOpenRoom: onOpenRoom,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('TelehealthControls', () {
    testWidgets('open-room CTA is disabled until both consents recorded',
        (tester) async {
      await _pump(tester, session: _session());
      final btn = tester.widgetList<Widget>(
        find.byWidgetPredicate((w) => w is FilledButton),
      ).whereType<FilledButton>().first;
      expect(btn.onPressed, isNull);
      expect(find.textContaining('Both consents'), findsOneWidget);
    });

    testWidgets('both consents recorded enables the CTA', (tester) async {
      var called = false;
      await _pump(
        tester,
        session: _session(
          visit: VisitConsent.granted,
          recording: RecordingConsent.declined,
        ),
        onOpenRoom: () => called = true,
      );
      await tester.tap(find.text('Open meeting room'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('safety footer mentions server-side token + recording gate',
        (tester) async {
      await _pump(tester, session: _session());
      expect(
        find.textContaining('minted server-side'),
        findsOneWidget,
      );
    });
  });
}
