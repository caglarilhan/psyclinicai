/// Coverage for the MedicationDoseLog model + repository +
/// AdherenceSummary math. JSON round-trip, status transitions,
/// adherence ratio, per-patient/day filters, corrupt-record drop.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/medication_dose_log.dart';
import 'package:psyclinicai/services/data/medication_dose_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MedicationDoseLog', () {
    test('round-trips through JSON preserving every field', () {
      final dose = MedicationDoseLog(
        id: 'd1',
        patientId: 'p1',
        medicationId: 'm1',
        scheduledAt: DateTime.utc(2026, 6, 23, 8),
        takenAt: DateTime.utc(2026, 6, 23, 8, 12),
        status: DoseStatus.taken,
        sideEffects: const ['dry mouth', 'drowsiness 4/10'],
        notes: 'took late after breakfast',
      );
      final back = MedicationDoseLog.fromJson(dose.toJson());
      expect(back.id, 'd1');
      expect(back.status, DoseStatus.taken);
      expect(back.takenAt, DateTime.utc(2026, 6, 23, 8, 12));
      expect(back.sideEffects, ['dry mouth', 'drowsiness 4/10']);
      expect(back.notes, 'took late after breakfast');
    });

    test('isOverdue requires pending + past the grace window', () {
      final past = DateTime.now().toUtc().subtract(const Duration(hours: 5));
      final overdue = MedicationDoseLog(
        id: 'd2',
        patientId: 'p1',
        medicationId: 'm1',
        scheduledAt: past,
      );
      expect(overdue.isOverdue, isTrue);

      final fresh = MedicationDoseLog(
        id: 'd3',
        patientId: 'p1',
        medicationId: 'm1',
        scheduledAt: DateTime.now().toUtc(),
      );
      expect(fresh.isOverdue, isFalse);

      final taken = overdue.copyWith(status: DoseStatus.taken);
      expect(taken.isOverdue, isFalse);
    });
  });

  group('AdherenceSummary.compute', () {
    final start = DateTime.utc(2026, 6, 17);
    final end = DateTime.utc(2026, 6, 23, 23, 59);

    MedicationDoseLog d(
      String id,
      DateTime at, {
      DoseStatus status = DoseStatus.pending,
    }) => MedicationDoseLog(
      id: id,
      patientId: 'p1',
      medicationId: 'm1',
      scheduledAt: at,
      status: status,
    );

    test('returns 100% when nothing scheduled', () {
      final s = AdherenceSummary.compute(
        start: start,
        end: end,
        doses: const [],
      );
      expect(s.scheduled, 0);
      expect(s.adherencePct, 100);
    });

    test('counts taken / missed / skipped properly', () {
      final doses = [
        d('1', start.add(const Duration(days: 1)), status: DoseStatus.taken),
        d('2', start.add(const Duration(days: 2)), status: DoseStatus.taken),
        d('3', start.add(const Duration(days: 3)), status: DoseStatus.missed),
        d('4', start.add(const Duration(days: 4)), status: DoseStatus.skipped),
      ];
      final s = AdherenceSummary.compute(start: start, end: end, doses: doses);
      expect(s.scheduled, 4);
      expect(s.taken, 2);
      expect(s.missed, 1);
      expect(s.skipped, 1);
      // adherence = taken / (scheduled - skipped) = 2/3 ~= 67%
      expect(s.adherencePct, 67);
    });

    test('out-of-window doses ignored', () {
      final doses = [
        d(
          '1',
          start.subtract(const Duration(days: 1)),
          status: DoseStatus.taken,
        ),
        d('2', start.add(const Duration(days: 2)), status: DoseStatus.taken),
      ];
      final s = AdherenceSummary.compute(start: start, end: end, doses: doses);
      expect(s.scheduled, 1);
      expect(s.taken, 1);
      expect(s.adherencePct, 100);
    });

    test('overdue-pending counts as missed', () {
      final past = DateTime.now().toUtc().subtract(const Duration(hours: 5));
      final s = AdherenceSummary.compute(
        start: past.subtract(const Duration(days: 1)),
        end: DateTime.now().toUtc(),
        doses: [d('1', past)],
      );
      expect(s.scheduled, 1);
      expect(s.missed, 1);
    });
  });

  group('MedicationDoseRepository', () {
    test('upsert idempotent by id and forPatientOnDate filters', () async {
      final repo = MedicationDoseRepository(storageKey: 'mar_test_upsert');
      await repo.initialize();
      final dose = MedicationDoseLog(
        id: 'd1',
        patientId: 'p1',
        medicationId: 'm1',
        scheduledAt: DateTime.utc(2026, 6, 23, 8),
      );
      await repo.upsert(dose);
      await repo.upsert(dose.copyWith(status: DoseStatus.taken));
      expect(repo.all.length, 1);
      final list = repo.forPatientOnDate('p1', DateTime.utc(2026, 6, 23));
      expect(list, hasLength(1));
      expect(list.single.status, DoseStatus.taken);
    });

    test('seed skips known ids and counts only the new ones', () async {
      final repo = MedicationDoseRepository(storageKey: 'mar_test_seed');
      await repo.initialize();
      final base = [
        for (var i = 0; i < 3; i++)
          MedicationDoseLog(
            id: 'd$i',
            patientId: 'p1',
            medicationId: 'm1',
            scheduledAt: DateTime.utc(2026, 6, 23, 8 + i),
          ),
      ];
      final firstSeed = await repo.seed(base);
      final secondSeed = await repo.seed(base);
      expect(firstSeed, 3);
      expect(secondSeed, 0);
      expect(repo.all.length, 3);
    });

    test('initialize drops corrupt records but keeps the valid ones', () async {
      SharedPreferences.setMockInitialValues({
        'mar_test_corrupt': <String>[
          '{"id":"good","patientId":"p1","medicationId":"m1","scheduledAt":"2026-06-23T08:00:00Z","status":"taken"}',
          'not valid json',
        ],
      });
      final repo = MedicationDoseRepository(storageKey: 'mar_test_corrupt');
      await repo.initialize();
      expect(repo.all.length, 1);
      expect(repo.all.first.id, 'good');
      expect(repo.all.first.status, DoseStatus.taken);
    });

    test('forPatientInRange returns newest-first', () async {
      final repo = MedicationDoseRepository(storageKey: 'mar_test_range');
      await repo.initialize();
      await repo.upsert(
        MedicationDoseLog(
          id: 'a',
          patientId: 'p1',
          medicationId: 'm1',
          scheduledAt: DateTime.utc(2026, 6, 20, 8),
        ),
      );
      await repo.upsert(
        MedicationDoseLog(
          id: 'b',
          patientId: 'p1',
          medicationId: 'm1',
          scheduledAt: DateTime.utc(2026, 6, 23, 8),
        ),
      );
      final list = repo.forPatientInRange(
        'p1',
        DateTime.utc(2026, 6, 19),
        DateTime.utc(2026, 6, 24),
      );
      expect(list.map((d) => d.id).toList(), ['b', 'a']);
    });
  });
}
