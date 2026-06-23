/// Coverage for the Vanderbilt ADHD assessment model + repo.
/// Symptom counts, DSM-5 cutoff helpers, subtype derivation,
/// JSON round-trip, parent/teacher pair lookup, corrupt drop.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/vanderbilt_assessment.dart';
import 'package:psyclinicai/services/data/vanderbilt_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

VanderbiltAssessment _make({
  String id = 'v1',
  VanderbiltRespondent respondent = VanderbiltRespondent.parent,
  List<int>? inattention,
  List<int>? hyperactivity,
  List<int>? oppositional,
  List<int>? conduct,
  List<int>? anxietyDepression,
  List<int>? performance,
  DateTime? at,
}) => VanderbiltAssessment(
  id: id,
  patientId: 'p1',
  clinicianId: 'c1',
  respondent: respondent,
  capturedAt: at ?? DateTime.utc(2026, 6, 23),
  inattention: inattention ?? List<int>.filled(9, 0),
  hyperactivity: hyperactivity ?? List<int>.filled(9, 0),
  oppositional: oppositional ?? List<int>.filled(8, 0),
  conduct: conduct ?? List<int>.filled(14, 0),
  anxietyDepression: anxietyDepression ?? List<int>.filled(7, 0),
  performance: performance ?? List<int>.filled(8, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VanderbiltAssessment cutoffs', () {
    test('symptom count counts items scored 2 or 3 only', () {
      final a = _make(inattention: const [3, 3, 2, 1, 0, 2, 2, 1, 0]);
      expect(a.inattentionSymptomCount, 5);
      expect(a.meetsInattentionThreshold, isFalse);
    });

    test('inattention threshold fires at exactly 6', () {
      final a = _make(inattention: const [2, 2, 2, 2, 2, 2, 0, 0, 0]);
      expect(a.inattentionSymptomCount, 6);
      expect(a.meetsInattentionThreshold, isTrue);
    });

    test('subtype is none without functional impairment', () {
      final a = _make(inattention: const [3, 3, 3, 3, 3, 3, 0, 0, 0]);
      expect(a.meetsInattentionThreshold, isTrue);
      expect(a.hasFunctionalImpairment, isFalse);
      expect(a.subtype, VanderbiltSubtype.none);
    });

    test('combined subtype requires both sides + impairment', () {
      final a = _make(
        inattention: const [2, 2, 2, 2, 2, 2, 0, 0, 0],
        hyperactivity: const [2, 2, 2, 2, 2, 2, 0, 0, 0],
        performance: const [1, 1, 1, 4, 1, 1, 1, 1],
      );
      expect(a.subtype, VanderbiltSubtype.combined);
    });

    test('inattentive only', () {
      final a = _make(
        inattention: const [2, 2, 2, 2, 2, 2, 0, 0, 0],
        hyperactivity: const [0, 0, 0, 0, 0, 0, 0, 0, 0],
        performance: const [1, 1, 1, 5, 1, 1, 1, 1],
      );
      expect(a.subtype, VanderbiltSubtype.inattentive);
    });

    test('hyperactive-impulsive only', () {
      final a = _make(
        inattention: const [0, 0, 0, 0, 0, 0, 0, 0, 0],
        hyperactivity: const [2, 2, 2, 2, 2, 2, 0, 0, 0],
        performance: const [1, 1, 1, 4, 1, 1, 1, 1],
      );
      expect(a.subtype, VanderbiltSubtype.hyperactiveImpulsive);
    });

    test('ODD / conduct / anxiety positive screens', () {
      final a = _make(
        oppositional: const [2, 2, 2, 2, 0, 0, 0, 0],
        conduct: const [2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        anxietyDepression: const [2, 2, 2, 0, 0, 0, 0],
      );
      expect(a.oppositionalPositiveScreen, isTrue);
      expect(a.conductPositiveScreen, isTrue);
      expect(a.anxietyDepressionPositiveScreen, isTrue);
    });
  });

  group('VanderbiltAssessment JSON', () {
    test('round-trip preserves all sections + respondent', () {
      final a = _make(
        respondent: VanderbiltRespondent.teacher,
        inattention: const [3, 2, 3, 2, 3, 2, 1, 0, 0],
        hyperactivity: const [3, 3, 2, 2, 1, 1, 0, 0, 0],
        performance: const [1, 2, 3, 4, 5, 1, 1, 1],
      );
      final back = VanderbiltAssessment.fromJson(a.toJson());
      expect(back.respondent, VanderbiltRespondent.teacher);
      expect(back.inattention, a.inattention);
      expect(back.hyperactivity, a.hyperactivity);
      expect(back.performance, a.performance);
      expect(back.inattentionSymptomCount, 6);
    });

    test('fromJson pads short arrays to the expected length', () {
      final back = VanderbiltAssessment.fromJson({
        'id': 'short',
        'patientId': 'p1',
        'clinicianId': 'c1',
        'respondent': 'parent',
        'capturedAt': '2026-06-23T10:00:00Z',
        'inattention': [3, 3, 3],
        'hyperactivity': <int>[],
      });
      expect(back.inattention, hasLength(9));
      expect(back.inattention.take(3), [3, 3, 3]);
      expect(back.inattention.skip(3), everyElement(0));
    });
  });

  group('VanderbiltRepository', () {
    test('upsert + forPatient round-trip', () async {
      final repo = VanderbiltRepository(storageKey: 'vb_rt');
      await repo.initialize();
      await repo.upsert(
        _make(
          inattention: const [2, 2, 2, 2, 2, 2, 0, 0, 0],
          performance: const [1, 1, 4, 1, 1, 1, 1, 1],
        ),
      );
      final fresh = VanderbiltRepository(storageKey: 'vb_rt');
      await fresh.initialize();
      final list = fresh.forPatient('p1');
      expect(list, hasLength(1));
      expect(list.first.subtype, VanderbiltSubtype.inattentive);
    });

    test('latestPair returns the most recent of each respondent', () async {
      final repo = VanderbiltRepository(storageKey: 'vb_pair');
      await repo.initialize();
      await repo.upsert(_make(id: 'old-parent', at: DateTime.utc(2026, 6, 20)));
      await repo.upsert(_make(id: 'new-parent', at: DateTime.utc(2026, 6, 22)));
      await repo.upsert(
        _make(
          id: 'teacher',
          respondent: VanderbiltRespondent.teacher,
          at: DateTime.utc(2026, 6, 21),
        ),
      );
      final pair = repo.latestPair('p1');
      expect(pair.parent?.id, 'new-parent');
      expect(pair.teacher?.id, 'teacher');
    });

    test('latestPair returns null entries when a form is missing', () async {
      final repo = VanderbiltRepository(storageKey: 'vb_lonely');
      await repo.initialize();
      await repo.upsert(_make(id: 'only-parent'));
      final pair = repo.latestPair('p1');
      expect(pair.parent, isNotNull);
      expect(pair.teacher, isNull);
    });

    test('initialize drops corrupt records', () async {
      SharedPreferences.setMockInitialValues({
        'vb_corrupt': <String>[
          '{"id":"good","patientId":"p1","clinicianId":"c1","respondent":"parent","capturedAt":"2026-06-23T10:00:00Z","inattention":[2,2,2,2,2,2,0,0,0],"performance":[1,1,4,1,1,1,1,1]}',
          'not valid json',
        ],
      });
      final repo = VanderbiltRepository(storageKey: 'vb_corrupt');
      await repo.initialize();
      expect(repo.all, hasLength(1));
      expect(repo.all.first.id, 'good');
    });
  });
}
