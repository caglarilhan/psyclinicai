import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/appointments_day_view.dart';

final _day = DateTime.utc(2026, 6, 10);

AppointmentSlot _slot({
  String id = 'a-1',
  int hour = 10,
  int minute = 0,
  String name = 'John Demo',
  String kind = 'therapy',
  int duration = 50,
  bool cancelled = false,
  bool noShow = false,
}) => AppointmentSlot(
  id: id,
  patientName: name,
  startsAt: DateTime.utc(_day.year, _day.month, _day.day, hour, minute),
  durationMinutes: duration,
  kind: kind,
  cancelled: cancelled,
  noShow: noShow,
);

Future<void> _pump(
  WidgetTester tester, {
  required List<AppointmentSlot> slots,
  ValueChanged<AppointmentSlot>? onTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AppointmentsDayView(day: _day, slots: slots, onTap: onTap),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AppointmentsDayView', () {
    testWidgets('renders hour rows including 08:00 and 14:00', (tester) async {
      await _pump(tester, slots: const []);
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('14:00'), findsOneWidget);
    });

    testWidgets('a slot lands on its own hour row', (tester) async {
      await _pump(
        tester,
        slots: [
          _slot(name: 'Maria S.'),
          _slot(hour: 14, kind: 'intake', duration: 90),
        ],
      );
      expect(find.text('Maria S.'), findsOneWidget);
      expect(find.text('John Demo'), findsOneWidget);
      expect(find.text('therapy · 50 min'), findsOneWidget);
      expect(find.text('intake · 90 min'), findsOneWidget);
    });

    testWidgets('cancelled / no-show overrides the tag', (tester) async {
      await _pump(
        tester,
        slots: [
          _slot(hour: 11, name: 'A', cancelled: true),
          _slot(hour: 12, name: 'B', noShow: true),
        ],
      );
      expect(find.text('cancelled · 50 min'), findsOneWidget);
      expect(find.text('no-show · 50 min'), findsOneWidget);
    });

    testWidgets('tapping a slot fires the callback', (tester) async {
      AppointmentSlot? tapped;
      await _pump(
        tester,
        slots: [_slot(name: 'Tap Me')],
        onTap: (s) => tapped = s,
      );
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(tapped?.patientName, 'Tap Me');
    });
  });
}
