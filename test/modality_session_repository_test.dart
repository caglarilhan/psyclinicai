/// Coverage for the three modality model JSON round-trips plus the
/// envelope repository (`ModalitySessionRepository`) — corrupt
/// records dropped, per-patient filter, upsert idempotence.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/modalities/cbt_thought_record.dart';
import 'package:psyclinicai/models/modalities/dbt_diary_card.dart';
import 'package:psyclinicai/models/modalities/emdr_session_tracker.dart';
import 'package:psyclinicai/services/data/modality_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CbtThoughtRecord', () {
    test('round-trips through JSON preserving every field', () {
      final r = CbtThoughtRecord(
        id: 'cbt-1',
        patientId: 'p1',
        clinicianId: 'c1',
        recordedAt: DateTime.utc(2026, 6, 23, 10),
        situation: 'Boss returned my draft with red marks.',
        thoughts: const [
          CbtAutomaticThought(text: "I'm going to be fired", beliefPct: 80),
          CbtAutomaticThought(text: 'I am a fraud', beliefPct: 65),
        ],
        emotionsBefore: const [
          CbtEmotionRating(emotion: 'anxiety', intensity: 75),
          CbtEmotionRating(emotion: 'shame', intensity: 60),
        ],
        distortions: const [
          CbtCognitiveDistortion.allOrNothing,
          CbtCognitiveDistortion.labeling,
        ],
        evidenceFor: 'Three rounds of red marks last month.',
        evidenceAgainst: 'Boss kept the line about scope; not all bad.',
        balancedThought: 'Feedback is normal; one round is not failing.',
        balancedBeliefPct: 70,
        emotionsAfter: const [
          CbtEmotionRating(emotion: 'anxiety', intensity: 35),
          CbtEmotionRating(emotion: 'shame', intensity: 20),
        ],
        clinicianNotes: 'Defended labeling hard.',
      );
      final restored = CbtThoughtRecord.fromJson(r.toJson());
      expect(restored.id, r.id);
      expect(restored.thoughts.length, 2);
      expect(restored.thoughts.first.beliefPct, 80);
      expect(restored.distortions, contains(CbtCognitiveDistortion.labeling));
      expect(restored.emotionsAfter.first.intensity, 35);
      expect(restored.balancedBeliefPct, 70);
    });

    test('intensityDelta sums before minus after across emotions', () {
      final r = CbtThoughtRecord(
        id: 'cbt-2',
        patientId: 'p1',
        clinicianId: 'c1',
        recordedAt: DateTime.utc(2026, 6, 23),
        emotionsBefore: const [
          CbtEmotionRating(emotion: 'sad', intensity: 80),
          CbtEmotionRating(emotion: 'angry', intensity: 60),
        ],
        emotionsAfter: const [
          CbtEmotionRating(emotion: 'sad', intensity: 40),
          CbtEmotionRating(emotion: 'angry', intensity: 30),
        ],
      );
      expect(r.intensityDelta, 70);
    });

    test('toPlainText renders the columns in order', () {
      final r = CbtThoughtRecord(
        id: 'cbt-3',
        patientId: 'p1',
        clinicianId: 'c1',
        recordedAt: DateTime.utc(2026, 6, 23),
        situation: 'X',
        thoughts: const [CbtAutomaticThought(text: 'T', beliefPct: 50)],
        emotionsBefore: const [
          CbtEmotionRating(emotion: 'fear', intensity: 50),
        ],
        balancedThought: 'B',
        balancedBeliefPct: 60,
      );
      final text = r.toPlainText();
      expect(text, contains('Situation:'));
      expect(text, contains('Automatic thoughts:'));
      expect(text, contains('Emotions before:'));
      expect(text, contains('Balanced thought:'));
      expect(text, contains('B  (belief 60%)'));
    });
  });

  group('DbtDiaryCard', () {
    test('blank card snaps to Monday and creates 7 daily entries', () {
      // 2026-06-23 is a Tuesday — Monday should be 2026-06-22.
      final c = DbtDiaryCard.blank(
        id: 'w1',
        patientId: 'p1',
        clinicianId: 'c1',
        weekOf: DateTime.utc(2026, 6, 23),
      );
      expect(c.weekStart, DateTime.utc(2026, 6, 22));
      expect(c.days.length, 7);
      expect(c.days.last.date, DateTime.utc(2026, 6, 28));
      // Defaults: 5 target behaviours.
      expect(c.targetBehaviors.length, DbtTargetBehavior.defaults.length);
    });

    test('round-trips through JSON preserving every layer', () {
      final c = DbtDiaryCard.blank(
        id: 'w2',
        patientId: 'p1',
        clinicianId: 'c1',
        weekOf: DateTime.utc(2026, 6, 23),
      );
      final mon = c.days.first.copyWith(
        targetBehaviorRatings: const {'si': 3, 'sh_urge': 4, 'sh_act': 1},
        emotionRatings: const {DbtEmotion.sadness: 4, DbtEmotion.anger: 2},
        skillsUsed: const {DbtSkill.radicalAcceptance, DbtSkill.dearMan},
        notes: 'Hard morning.',
      );
      final updated = c.withDay(mon);
      final restored = DbtDiaryCard.fromJson(updated.toJson());
      expect(restored.days.first.targetBehaviorRatings['si'], 3);
      expect(restored.days.first.emotionRatings[DbtEmotion.sadness], 4);
      expect(restored.days.first.skillsUsed, contains(DbtSkill.dearMan));
      expect(restored.days.first.notes, 'Hard morning.');
      expect(restored.selfHarmActOccurred, isTrue);
      expect(restored.suicidalIdeationPeakOfWeek, 3);
      expect(restored.filledDays, 1);
    });
  });

  group('EmdrSessionTracker', () {
    test('round-trips through JSON preserving BLS sets + scales', () {
      final e = EmdrSessionTracker(
        id: 'e1',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23, 10),
        currentPhase: EmdrPhase.fourDesensitization,
        targetMemory: 'Car accident at 17',
        negativeCognition: "I'm not safe",
        positiveCognition: 'I can protect myself',
        vocStart: 2,
        sudsStart: 8,
        bodyLocation: 'chest',
        blsSets: const [
          EmdrBlsSet(
            sequence: 1,
            sudsBefore: 8,
            sudsAfter: 6,
            observation: 'Slight nausea',
          ),
          EmdrBlsSet(sequence: 2, sudsBefore: 6, sudsAfter: 4),
        ],
      );
      final restored = EmdrSessionTracker.fromJson(e.toJson());
      expect(restored.currentPhase, EmdrPhase.fourDesensitization);
      expect(restored.blsSets.length, 2);
      expect(restored.blsSets.first.observation, 'Slight nausea');
      expect(restored.blsSets.last.movedDown, isTrue);
    });

    test('isClosureSafe blocks closure on unresolved abreaction', () {
      final base = EmdrSessionTracker(
        id: 'e2',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23),
        abreactionOccurred: true,
      );
      expect(base.isClosureSafe, isFalse);
      expect(
        base.copyWith(abreactionResource: 'safe place').isClosureSafe,
        isTrue,
      );
    });

    test('sudsDelta and vocDelta compute when end values populated', () {
      final e = EmdrSessionTracker(
        id: 'e3',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 23),
        vocStart: 2,
        vocEnd: 6,
        sudsStart: 8,
        sudsEnd: 1,
      );
      expect(e.sudsDelta, -7);
      expect(e.vocDelta, 4);
    });
  });

  group('ModalitySessionRepository', () {
    test('upsert is idempotent by id (replace, not append)', () async {
      final repo = ModalitySessionRepository(storageKey: 'mod_test_upsert');
      await repo.initialize();
      final r1 = CbtThoughtRecord(
        id: 'cbt-x',
        patientId: 'p1',
        clinicianId: 'c1',
        recordedAt: DateTime.utc(2026, 6, 23),
        situation: 'v1',
      );
      await repo.upsert(ModalityRecord(kind: ModalityKind.cbt, payload: r1));
      final r2 = r1.copyWith(situation: 'v2 updated');
      await repo.upsert(ModalityRecord(kind: ModalityKind.cbt, payload: r2));
      expect(repo.all.length, 1);
      expect(repo.byId('cbt-x')?.cbtRecord?.situation, 'v2 updated');
    });

    test(
      'forPatient + forPatientOfKind filter and sort newest-first',
      () async {
        final repo = ModalitySessionRepository(storageKey: 'mod_test_filter');
        await repo.initialize();
        await repo.upsert(
          ModalityRecord(
            kind: ModalityKind.cbt,
            payload: CbtThoughtRecord(
              id: 'cbt-1',
              patientId: 'p1',
              clinicianId: 'c1',
              recordedAt: DateTime.utc(2026, 6, 20),
            ),
          ),
        );
        await repo.upsert(
          ModalityRecord(
            kind: ModalityKind.dbt,
            payload: DbtDiaryCard.blank(
              id: 'dbt-1',
              patientId: 'p1',
              clinicianId: 'c1',
              weekOf: DateTime.utc(2026, 6, 22),
            ),
          ),
        );
        await repo.upsert(
          ModalityRecord(
            kind: ModalityKind.emdr,
            payload: EmdrSessionTracker(
              id: 'emdr-1',
              patientId: 'p2',
              clinicianId: 'c1',
              createdAt: DateTime.utc(2026, 6, 23),
            ),
          ),
        );
        final p1All = repo.forPatient('p1');
        expect(p1All.length, 2);
        expect(p1All.first.kind, ModalityKind.dbt); // newer weekStart
        final p1Cbt = repo.forPatientOfKind('p1', ModalityKind.cbt);
        expect(p1Cbt.single.id, 'cbt-1');
        final p2 = repo.forPatient('p2');
        expect(p2.single.kind, ModalityKind.emdr);
      },
    );

    test(
      'initialize drops corrupt records but loads the valid ones',
      () async {
        // Pre-seed with one valid + one corrupt entry under the same
        // key.
        SharedPreferences.setMockInitialValues({
          'mod_test_corrupt': <String>[
            '{"type":"cbt","payload":{"id":"good","patientId":"p1","clinicianId":"c1","recordedAt":"2026-06-23T10:00:00Z"}}',
            'not valid json',
          ],
        });
        final repo = ModalitySessionRepository(
          storageKey: 'mod_test_corrupt',
        );
        await repo.initialize();
        expect(repo.all.length, 1);
        expect(repo.all.first.id, 'good');
      },
    );
  });
}
