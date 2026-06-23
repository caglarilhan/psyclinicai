/// Coverage for the medication side-effect model + repo.
/// Severity / Naranjo bucketing, summary roll-up, JSON round-trip,
/// per-patient + per-medication queries, corrupt-record drop.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/medication_side_effect.dart';
import 'package:psyclinicai/services/data/medication_side_effect_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

MedicationSideEffect _make({
  String id = 'se1',
  String patientId = 'p1',
  String medicationId = 'm1',
  String symptom = 'Nausea',
  SideEffectSystem system = SideEffectSystem.gastrointestinal,
  SideEffectSeverity severity = SideEffectSeverity.mild,
  int? naranjo,
  DateTime? onset,
  DateTime? resolved,
  DateTime? reportedAt,
}) => MedicationSideEffect(
  id: id,
  patientId: patientId,
  medicationId: medicationId,
  clinicianId: 'c1',
  reportedAt: reportedAt ?? DateTime.utc(2026, 6, 23, 10),
  symptom: symptom,
  system: system,
  severity: severity,
  naranjoScore: naranjo,
  onsetAt: onset,
  resolvedAt: resolved,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MedicationSideEffect model', () {
    test('isClinicallySignificant fires at moderate', () {
      expect(_make().isClinicallySignificant, isFalse);
      expect(
        _make(severity: SideEffectSeverity.moderate).isClinicallySignificant,
        isTrue,
      );
      expect(
        _make(severity: SideEffectSeverity.severe).isClinicallySignificant,
        isTrue,
      );
    });

    test('isOngoing flips false when resolvedAt is set', () {
      final ongoing = _make(onset: DateTime.utc(2026, 6, 20));
      expect(ongoing.isOngoing, isTrue);
      final resolved = ongoing.copyWith(resolvedAt: DateTime.utc(2026, 6, 22));
      expect(resolved.isOngoing, isFalse);
      expect(resolved.durationIfResolved, const Duration(days: 2));
    });

    test('Naranjo category bucketing', () {
      expect(NaranjoCategory.fromScore(-1), NaranjoCategory.doubtful);
      expect(NaranjoCategory.fromScore(0), NaranjoCategory.doubtful);
      expect(NaranjoCategory.fromScore(1), NaranjoCategory.possible);
      expect(NaranjoCategory.fromScore(4), NaranjoCategory.possible);
      expect(NaranjoCategory.fromScore(5), NaranjoCategory.probable);
      expect(NaranjoCategory.fromScore(8), NaranjoCategory.probable);
      expect(NaranjoCategory.fromScore(9), NaranjoCategory.definite);
      expect(NaranjoCategory.fromScore(13), NaranjoCategory.definite);
    });

    test('naranjoCategory follows naranjoScore when present', () {
      expect(_make().naranjoCategory, isNull);
      expect(_make(naranjo: 6).naranjoCategory, NaranjoCategory.probable);
    });

    test('JSON round-trip preserves system / severity / Naranjo / dates', () {
      final e = _make(
        symptom: 'Tremor',
        system: SideEffectSystem.neurological,
        severity: SideEffectSeverity.moderate,
        naranjo: 7,
        onset: DateTime.utc(2026, 6, 21, 9),
        resolved: DateTime.utc(2026, 6, 22, 11),
      );
      final back = MedicationSideEffect.fromJson(e.toJson());
      expect(back.symptom, 'Tremor');
      expect(back.system, SideEffectSystem.neurological);
      expect(back.severity, SideEffectSeverity.moderate);
      expect(back.naranjoScore, 7);
      expect(back.naranjoCategory, NaranjoCategory.probable);
      expect(back.onsetAt, DateTime.utc(2026, 6, 21, 9));
      expect(back.resolvedAt, DateTime.utc(2026, 6, 22, 11));
    });
  });

  group('SideEffectSummary', () {
    test('compute totals ongoing + significant + bySystem', () {
      final summary = SideEffectSummary.compute([
        _make(id: 'a'),
        _make(
          id: 'b',
          system: SideEffectSystem.cardiovascular,
          severity: SideEffectSeverity.moderate,
        ),
        _make(
          id: 'c',
          system: SideEffectSystem.cardiovascular,
          severity: SideEffectSeverity.severe,
          resolved: DateTime.utc(2026, 6, 22),
        ),
      ]);
      expect(summary.total, 3);
      expect(summary.ongoing, 2);
      expect(summary.clinicallySignificant, 2);
      expect(summary.bySystem[SideEffectSystem.cardiovascular], 2);
      expect(summary.bySystem[SideEffectSystem.gastrointestinal], 1);
    });
  });

  group('MedicationSideEffectRepository', () {
    test('upsert + forPatient orders newest first', () async {
      final repo = MedicationSideEffectRepository(storageBucket: 'mse_rt');
      await repo.initialize();
      await repo.upsert(
        _make(id: 'old', reportedAt: DateTime.utc(2026, 6, 20)),
      );
      await repo.upsert(
        _make(id: 'new', reportedAt: DateTime.utc(2026, 6, 22)),
      );
      final fresh = MedicationSideEffectRepository(storageBucket: 'mse_rt');
      await fresh.initialize();
      final list = fresh.forPatient('p1');
      expect(list.map((e) => e.id), ['new', 'old']);
    });

    test('forMedication filters by med id', () async {
      final repo = MedicationSideEffectRepository(storageBucket: 'mse_med');
      await repo.initialize();
      await repo.upsert(_make(id: 'a'));
      await repo.upsert(_make(id: 'b', medicationId: 'm2'));
      await repo.upsert(_make(id: 'c'));
      final list = repo.forMedication('p1', 'm1');
      expect(list, hasLength(2));
      expect(list.every((e) => e.medicationId == 'm1'), isTrue);
    });

    test('summaryForPatient delegates to SideEffectSummary.compute', () async {
      final repo = MedicationSideEffectRepository(storageBucket: 'mse_sum');
      await repo.initialize();
      await repo.upsert(_make(id: 'a'));
      await repo.upsert(
        _make(
          id: 'b',
          severity: SideEffectSeverity.severe,
          resolved: DateTime.utc(2026, 6, 22),
        ),
      );
      final s = repo.summaryForPatient('p1');
      expect(s.total, 2);
      expect(s.ongoing, 1);
      expect(s.clinicallySignificant, 1);
    });

    test('initialize drops corrupt records', () async {
      SharedPreferences.setMockInitialValues({
        'mse_corrupt': <String>[
          '{"id":"good","patientId":"p1","medicationId":"m1","clinicianId":"c1","reportedAt":"2026-06-23T10:00:00Z","symptom":"Headache","system":"neurological","severity":1}',
          'not json',
        ],
      });
      final repo = MedicationSideEffectRepository(storageBucket: 'mse_corrupt');
      await repo.initialize();
      expect(repo.all, hasLength(1));
      expect(repo.all.first.id, 'good');
    });
  });
}
