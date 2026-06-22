import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/appointment_model.dart';
import 'package:psyclinicai/utils/appointment_conflict.dart';

void main() {
  Appointment make({
    required String id,
    required DateTime start,
    required DateTime end,
    String clientName = 'Test',
  }) => Appointment(
    id: id,
    clientId: 'c-$id',
    clientName: clientName,
    startTime: start,
    endTime: end,
    type: 'Therapy',
    status: 'Scheduled',
    notes: '',
    location: 'Office',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('Appointment model', () {
    test('round-trips through JSON without losing fields', () {
      final a = make(
        id: 'a1',
        start: DateTime(2026, 6, 1, 10),
        end: DateTime(2026, 6, 1, 11),
      );
      final r = Appointment.fromJson(a.toJson());
      expect(r.id, 'a1');
      expect(r.startTime, DateTime(2026, 6, 1, 10));
      expect(r.endTime, DateTime(2026, 6, 1, 11));
      expect(r.duration, const Duration(hours: 1));
    });

    test('duration is endTime - startTime', () {
      final a = make(
        id: 'd1',
        start: DateTime(2026, 6, 1, 9),
        end: DateTime(2026, 6, 1, 10, 30),
      );
      expect(a.duration, const Duration(hours: 1, minutes: 30));
    });

    test('isUpcoming distinguishes future vs past appointments', () {
      final future = make(
        id: 'f',
        start: DateTime.now().add(const Duration(hours: 2)),
        end: DateTime.now().add(const Duration(hours: 3)),
      );
      final past = make(
        id: 'p',
        start: DateTime.now().subtract(const Duration(hours: 3)),
        end: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(future.isUpcoming, isTrue);
      expect(past.isUpcoming, isFalse);
      expect(past.isPast, isTrue);
    });

    test('copyWith keeps untouched fields and updates supplied ones', () {
      final a = make(
        id: 'cw',
        start: DateTime(2026, 6, 1, 10),
        end: DateTime(2026, 6, 1, 11),
      );
      final b = a.copyWith(status: 'Completed', notes: 'Good session');
      expect(b.id, a.id);
      expect(b.startTime, a.startTime);
      expect(b.status, 'Completed');
      expect(b.notes, 'Good session');
    });
  });

  group('intervalsOverlap', () {
    test('full overlap returns true', () {
      expect(
        intervalsOverlap(
          DateTime(2026, 6, 1, 10),
          DateTime(2026, 6, 1, 11),
          DateTime(2026, 6, 1, 10, 30),
          DateTime(2026, 6, 1, 10, 45),
        ),
        isTrue,
      );
    });

    test('partial overlap returns true', () {
      expect(
        intervalsOverlap(
          DateTime(2026, 6, 1, 10),
          DateTime(2026, 6, 1, 11),
          DateTime(2026, 6, 1, 10, 30),
          DateTime(2026, 6, 1, 11, 30),
        ),
        isTrue,
      );
    });

    test('back-to-back is NOT a conflict (half-open intervals)', () {
      expect(
        intervalsOverlap(
          DateTime(2026, 6, 1, 10),
          DateTime(2026, 6, 1, 11),
          DateTime(2026, 6, 1, 11),
          DateTime(2026, 6, 1, 12),
        ),
        isFalse,
      );
    });

    test('non-overlapping with a gap returns false', () {
      expect(
        intervalsOverlap(
          DateTime(2026, 6, 1, 10),
          DateTime(2026, 6, 1, 11),
          DateTime(2026, 6, 1, 13),
          DateTime(2026, 6, 1, 14),
        ),
        isFalse,
      );
    });
  });

  group('findConflictingAppointment / hasAppointmentConflict', () {
    final morning = DateTime(2026, 6, 1, 10);
    final existing = [
      make(
        id: 'a1',
        start: morning,
        end: morning.add(const Duration(hours: 1)),
      ),
      make(
        id: 'a2',
        start: morning.add(const Duration(hours: 2)),
        end: morning.add(const Duration(hours: 3)),
      ),
    ];

    test('detects a conflict with the first appointment', () {
      final candidate = make(
        id: 'new',
        start: morning.add(const Duration(minutes: 30)),
        end: morning.add(const Duration(minutes: 90)),
      );
      final hit = findConflictingAppointment(candidate, existing);
      expect(hit?.id, 'a1');
      expect(hasAppointmentConflict(candidate, existing), isTrue);
    });

    test('no conflict when slotting between two appointments', () {
      final candidate = make(
        id: 'new',
        start: morning.add(const Duration(hours: 1)),
        end: morning.add(const Duration(hours: 2)),
      );
      expect(findConflictingAppointment(candidate, existing), isNull);
      expect(hasAppointmentConflict(candidate, existing), isFalse);
    });

    test('excludeId skips the appointment being edited', () {
      // Edit a1 in place — the same id must not flag itself.
      final edited = existing.first.copyWith(notes: 'edited');
      expect(
        hasAppointmentConflict(edited, existing, excludeId: edited.id),
        isFalse,
      );
    });

    test('empty existing list yields no conflict', () {
      final c = make(
        id: 'x',
        start: morning,
        end: morning.add(const Duration(hours: 1)),
      );
      expect(hasAppointmentConflict(c, const <Appointment>[]), isFalse);
    });
  });
}
