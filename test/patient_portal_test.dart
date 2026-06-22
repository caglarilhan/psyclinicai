import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/patient_portal/portal_appointments_screen.dart';
import 'package:psyclinicai/patient_portal/portal_inbox_screen.dart';
import 'package:psyclinicai/patient_portal/portal_landing_screen.dart';
import 'package:psyclinicai/patient_portal/portal_prom_screen.dart';

Future<void> _pump(WidgetTester tester, Widget w) async {
  tester.view.physicalSize = const Size(390 * 2, 844 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: w));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('PortalLandingScreen shows the four action cards', (
    tester,
  ) async {
    await _pump(tester, const PortalLandingScreen(firstName: 'Alex'));
    expect(find.text('Welcome back, Alex.'), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Questionnaires'), findsOneWidget);
    expect(find.text('Secure inbox'), findsOneWidget);
    expect(find.text('Intake form'), findsOneWidget);
  });

  testWidgets('PortalAppointmentsScreen renders the supplied rows', (
    tester,
  ) async {
    await _pump(
      tester,
      PortalAppointmentsScreen(
        items: [
          PortalAppointmentRow(
            title: 'Intake',
            when: DateTime.utc(2026, 6, 10, 14),
            location: 'Video',
            clinician: 'Dr. Lee',
          ),
        ],
      ),
    );
    expect(find.text('Intake'), findsOneWidget);
    expect(find.textContaining('Dr. Lee'), findsOneWidget);
  });

  testWidgets('PortalInboxScreen renders subject + preview', (tester) async {
    await _pump(
      tester,
      PortalInboxScreen(
        threads: [
          PortalInboxThread(
            subject: 'Welcome',
            preview: 'Glad you joined the practice.',
            updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
            unread: true,
          ),
        ],
      ),
    );
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.textContaining('Glad you joined'), findsOneWidget);
  });

  testWidgets('PortalPromScreen marks ≤1-day items as warning', (tester) async {
    await _pump(
      tester,
      const PortalPromScreen(
        assignments: [
          PortalPromAssignment(
            scaleId: 'phq9',
            scaleName: 'PHQ-9 — check-in',
            estimatedMinutes: 3,
            dueInDays: 1,
          ),
        ],
      ),
    );
    expect(find.text('Due in 1d'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
