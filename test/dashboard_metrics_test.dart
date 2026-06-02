import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/analytics/dashboard_metrics.dart';

DateTime _at(int hour, [int minute = 0]) =>
    DateTime.utc(2026, 6, 10, hour, minute);

void main() {
  const builder = DashboardMetricsBuilder();
  final now = _at(9);

  group('DashboardMetricsBuilder', () {
    test('empty inputs render an empty-but-valid dashboard', () {
      final m = builder.build(
        DashboardInputs(
          now: now,
          appointmentsToday: const [],
          sessions: const [],
          atRiskPatientIds: const [],
          superbills: const [],
        ),
      );
      expect(m.todaysSessionCount, 0);
      expect(m.nextAppointment, isNull);
      expect(m.pendingNotesCount, 0);
      expect(m.atRiskCount, 0);
      expect(m.outstandingTotalCents, 0);
      expect(m.hasAnythingToShow, isFalse);
    });

    test("today's sessions exclude cancelled appointments", () {
      final m = builder.build(
        DashboardInputs(
          now: now,
          appointmentsToday: [
            DashboardAppointment(
              id: 'a-1',
              patientName: 'John',
              startsAt: _at(10),
              kind: 'therapy',
            ),
            DashboardAppointment(
              id: 'a-2',
              patientName: 'Sara',
              startsAt: _at(11),
              kind: 'intake',
              cancelled: true,
            ),
          ],
          sessions: const [],
          atRiskPatientIds: const [],
          superbills: const [],
        ),
      );
      expect(m.todaysSessionCount, 1);
      expect(m.nextAppointment?.id, 'a-1');
    });

    test('nextAppointment ignores past appointments', () {
      final m = builder.build(
        DashboardInputs(
          now: _at(12),
          appointmentsToday: [
            DashboardAppointment(
              id: 'past',
              patientName: 'P',
              startsAt: _at(10),
              kind: 'therapy',
            ),
            DashboardAppointment(
              id: 'next',
              patientName: 'N',
              startsAt: _at(14),
              kind: 'therapy',
            ),
          ],
          sessions: const [],
          atRiskPatientIds: const [],
          superbills: const [],
        ),
      );
      expect(m.nextAppointment?.id, 'next');
    });

    test('pendingNotes counts sessions > 24h unsigned only', () {
      final m = builder.build(
        DashboardInputs(
          now: now,
          appointmentsToday: const [],
          sessions: [
            DashboardSession(
              id: 'fresh',
              endedAt: now.subtract(const Duration(hours: 4)),
            ),
            DashboardSession(
              id: 'stale',
              endedAt: now.subtract(const Duration(hours: 36)),
            ),
            DashboardSession(
              id: 'already-signed',
              endedAt: now.subtract(const Duration(days: 5)),
              signedAt: now.subtract(const Duration(days: 3)),
            ),
          ],
          atRiskPatientIds: const [],
          superbills: const [],
        ),
      );
      expect(m.pendingNotesCount, 1);
    });

    test('atRiskCount de-duplicates patient ids', () {
      final m = builder.build(
        DashboardInputs(
          now: now,
          appointmentsToday: const [],
          sessions: const [],
          atRiskPatientIds: const ['p-1', 'p-1', 'p-2'],
          superbills: const [],
        ),
      );
      expect(m.atRiskCount, 2);
    });

    test('outstanding sums unpaid + partial; oldestAge is max', () {
      final m = builder.build(
        DashboardInputs(
          now: now,
          appointmentsToday: const [],
          sessions: const [],
          atRiskPatientIds: const [],
          superbills: [
            DashboardSuperbill(
              id: 'a',
              amountCents: 5000,
              status: 'unpaid',
              issuedAt: now.subtract(const Duration(days: 22)),
            ),
            DashboardSuperbill(
              id: 'b',
              amountCents: 3000,
              status: 'partial',
              issuedAt: now.subtract(const Duration(days: 5)),
            ),
            DashboardSuperbill(
              id: 'c',
              amountCents: 7000,
              status: 'paid',
              issuedAt: now.subtract(const Duration(days: 60)),
            ),
          ],
        ),
      );
      expect(m.outstandingTotalCents, 8000);
      expect(m.oldestOutstandingAgeDays, 22);
    });

    test('hasAnythingToShow is true if any metric > 0', () {
      final m = builder.build(
        DashboardInputs(
          now: now,
          appointmentsToday: const [],
          sessions: const [],
          atRiskPatientIds: const ['p-1'],
          superbills: const [],
        ),
      );
      expect(m.hasAnythingToShow, isTrue);
    });
  });
}
