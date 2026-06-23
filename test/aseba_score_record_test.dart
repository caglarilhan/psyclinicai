/// Coverage for the ASEBA score-only record + repo. Cutoff
/// bands (subscale + composite), JSON round-trip, per-patient
/// queries, latestByForm pairing, corrupt-record drop.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/aseba_score_record.dart';
import 'package:psyclinicai/services/data/aseba_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

AsebaScoreRecord _rec({
  String id = 'a1',
  AsebaForm form = AsebaForm.cbclParent,
  Map<AsebaSyndromeScale, int>? syndromeT,
  Map<AsebaDsmScale, int>? dsmT,
  Map<AsebaCompositeScale, int>? compositeT,
  DateTime? at,
}) => AsebaScoreRecord(
  id: id,
  patientId: 'p1',
  clinicianId: 'c1',
  form: form,
  capturedAt: at ?? DateTime.utc(2026, 6, 23),
  syndromeT: syndromeT,
  dsmT: dsmT,
  compositeT: compositeT,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AsebaScoreRecord cutoffs', () {
    test('subscale band thresholds: 64 normal, 65 borderline, 70 clinical', () {
      expect(AsebaScoreRecord.subscaleBand(64), AsebaBand.normal);
      expect(AsebaScoreRecord.subscaleBand(65), AsebaBand.borderline);
      expect(AsebaScoreRecord.subscaleBand(69), AsebaBand.borderline);
      expect(AsebaScoreRecord.subscaleBand(70), AsebaBand.clinical);
      expect(AsebaScoreRecord.subscaleBand(85), AsebaBand.clinical);
    });

    test(
      'composite band thresholds: 59 normal, 60 borderline, 64 clinical',
      () {
        expect(AsebaScoreRecord.compositeBand(59), AsebaBand.normal);
        expect(AsebaScoreRecord.compositeBand(60), AsebaBand.borderline);
        expect(AsebaScoreRecord.compositeBand(63), AsebaBand.borderline);
        expect(AsebaScoreRecord.compositeBand(64), AsebaBand.clinical);
      },
    );

    test('syndromeClinicalCount counts scales at or above 70', () {
      final r = _rec(
        syndromeT: const {
          AsebaSyndromeScale.anxiousDepressed: 71,
          AsebaSyndromeScale.attentionProblems: 70,
          AsebaSyndromeScale.aggressive: 69,
          AsebaSyndromeScale.withdrawn: 50,
        },
      );
      expect(r.syndromeClinicalCount, 2);
    });

    test('totalProblemsClinical fires only when total problems T >= 64', () {
      final low = _rec(
        compositeT: const {AsebaCompositeScale.totalProblems: 63},
      );
      final high = _rec(
        compositeT: const {AsebaCompositeScale.totalProblems: 65},
      );
      expect(low.totalProblemsClinical, isFalse);
      expect(high.totalProblemsClinical, isTrue);
    });
  });

  group('AsebaScoreRecord JSON', () {
    test('round-trip preserves form + all three score maps', () {
      final r = _rec(
        form: AsebaForm.trfTeacher,
        syndromeT: const {
          AsebaSyndromeScale.attentionProblems: 72,
          AsebaSyndromeScale.aggressive: 68,
        },
        dsmT: const {AsebaDsmScale.adhd: 75},
        compositeT: const {
          AsebaCompositeScale.externalising: 66,
          AsebaCompositeScale.totalProblems: 64,
        },
      );
      final back = AsebaScoreRecord.fromJson(r.toJson());
      expect(back.form, AsebaForm.trfTeacher);
      expect(back.syndromeT[AsebaSyndromeScale.attentionProblems], 72);
      expect(back.dsmT[AsebaDsmScale.adhd], 75);
      expect(back.compositeT[AsebaCompositeScale.externalising], 66);
      expect(back.totalProblemsClinical, isTrue);
    });

    test('fromJson clamps out-of-range T-scores to 0-100', () {
      final back = AsebaScoreRecord.fromJson({
        'id': 'clamp',
        'patientId': 'p1',
        'clinicianId': 'c1',
        'form': 'cbcl_parent_6_18',
        'capturedAt': '2026-06-23T10:00:00Z',
        'syndromeT': {'anxious_depressed': 250},
        'dsmT': <String, dynamic>{},
        'compositeT': <String, dynamic>{},
      });
      expect(back.syndromeT[AsebaSyndromeScale.anxiousDepressed], 100);
    });

    test('AsebaForm.fromId falls back to CBCL parent on unknown id', () {
      expect(AsebaForm.fromId('bogus'), AsebaForm.cbclParent);
      expect(AsebaForm.fromId('ysr_11_18'), AsebaForm.ysrYouth);
    });
  });

  group('AsebaRepository', () {
    test('upsert + forPatient ordering oldest-first', () async {
      final repo = AsebaRepository(storageBucket: 'aseba_test_rt');
      await repo.initialize();
      await repo.upsert(_rec(id: 'old', at: DateTime.utc(2026, 6, 2)));
      await repo.upsert(_rec(id: 'new', at: DateTime.utc(2026, 6, 22)));
      final fresh = AsebaRepository(storageBucket: 'aseba_test_rt');
      await fresh.initialize();
      final list = fresh.forPatient('p1');
      expect(list.map((r) => r.id), ['old', 'new']);
    });

    test('latestByForm picks the most recent record per form', () async {
      final repo = AsebaRepository(storageBucket: 'aseba_test_pair');
      await repo.initialize();
      await repo.upsert(_rec(id: 'cbcl-old', at: DateTime.utc(2026, 6, 2)));
      await repo.upsert(_rec(id: 'cbcl-new', at: DateTime.utc(2026, 6, 20)));
      await repo.upsert(
        _rec(
          id: 'trf',
          form: AsebaForm.trfTeacher,
          at: DateTime.utc(2026, 6, 15),
        ),
      );
      final pair = repo.latestByForm('p1');
      expect(pair[AsebaForm.cbclParent]?.id, 'cbcl-new');
      expect(pair[AsebaForm.trfTeacher]?.id, 'trf');
      expect(pair[AsebaForm.ysrYouth], isNull);
    });

    test('initialize drops corrupt records', () async {
      SharedPreferences.setMockInitialValues({
        'aseba_test_corrupt': <String>[
          '{"id":"good","patientId":"p1","clinicianId":"c1","form":"cbcl_parent_6_18","capturedAt":"2026-06-23T10:00:00Z","syndromeT":{},"dsmT":{},"compositeT":{}}',
          'not valid json',
        ],
      });
      final repo = AsebaRepository(storageBucket: 'aseba_test_corrupt');
      await repo.initialize();
      expect(repo.all, hasLength(1));
      expect(repo.all.first.id, 'good');
    });
  });
}
