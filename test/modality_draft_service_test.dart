/// Coverage for the local heuristic modality draft service. Each
/// helper is a pure transcript-text → structured-output function;
/// we exercise them independently and then assert the whole-draft
/// behaviour.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/modalities/cbt_thought_record.dart';
import 'package:psyclinicai/services/copilot/modality_draft_service.dart';

void main() {
  group('DraftHeuristics.splitSentences', () {
    test('splits on . ! ? and trims', () {
      final s = DraftHeuristics.splitSentences(
        'Hello world. Are you sure? Yes! Done.',
      );
      expect(s, ['Hello world.', 'Are you sure?', 'Yes!', 'Done.']);
    });

    test('keeps a trailing fragment without terminator', () {
      final s = DraftHeuristics.splitSentences('one. two without dot');
      expect(s, ['one.', 'two without dot']);
    });
  });

  group('DraftHeuristics.extractThoughts', () {
    test('catches "I thought / I felt that / I am a" patterns', () {
      final s = DraftHeuristics.splitSentences(
        'I thought I would fail. The room was warm. '
        'I felt that everyone judged me. I am a failure.',
      );
      final out = DraftHeuristics.extractThoughts(s);
      expect(out, hasLength(3));
      expect(out.every((t) => t.beliefPct == 70), isTrue);
      expect(out.first.text, contains('I thought'));
    });

    test('ignores plain narration without trigger', () {
      final s = DraftHeuristics.splitSentences(
        'The meeting started. We talked about Q3.',
      );
      expect(DraftHeuristics.extractThoughts(s), isEmpty);
    });
  });

  group('DraftHeuristics.extractEmotions', () {
    test('dedupes mapped emotions and seeds intensity 60', () {
      final out = DraftHeuristics.extractEmotions(
        'I felt anxious and panicked. Then sad. Truly depressed.',
      );
      // anxious + panic both → 'anxiety' (deduped). sad + depressed
      // → 'sadness'.
      final ids = out.map((e) => e.emotion).toList();
      expect(ids, containsAll(['anxiety', 'sadness']));
      expect(out.every((e) => e.intensity == 60), isTrue);
    });

    test('returns empty when no emotion keyword found', () {
      expect(DraftHeuristics.extractEmotions('We ate lunch.'), isEmpty);
    });
  });

  group('DraftHeuristics.tagDistortions', () {
    test('catches all-or-nothing on always/never', () {
      expect(
        DraftHeuristics.tagDistortions('I always mess this up.'),
        contains(CbtCognitiveDistortion.allOrNothing),
      );
    });

    test('catches should-statements + labeling together', () {
      final tags = DraftHeuristics.tagDistortions(
        'I should have done better. I am such a loser.',
      );
      expect(tags, contains(CbtCognitiveDistortion.shouldStatements));
      expect(tags, contains(CbtCognitiveDistortion.labeling));
    });

    test('catches personalization on "my fault"', () {
      expect(
        DraftHeuristics.tagDistortions(
          'It is all my fault that the team missed the deadline.',
        ),
        contains(CbtCognitiveDistortion.personalization),
      );
    });
  });

  group('DraftHeuristics.firstSituation', () {
    test('picks the first sentence with a trigger word', () {
      final s = DraftHeuristics.splitSentences(
        'I felt fine on the bus. At work, my boss handed me red marks.',
      );
      expect(DraftHeuristics.firstSituation(s), contains('At work'));
    });

    test('falls back to first sentence when no trigger', () {
      final s = DraftHeuristics.splitSentences('It happened fast. Then over.');
      expect(DraftHeuristics.firstSituation(s), 'It happened fast.');
    });
  });

  group('LocalHeuristicModalityDraftService.draftCbtThoughtRecord', () {
    test('produces a populated skeleton end-to-end', () async {
      const service = LocalHeuristicModalityDraftService();
      final draft = await service.draftCbtThoughtRecord(
        transcript:
            'At work today my boss returned my draft with red marks. '
            'I thought I would be fired. I felt anxious and ashamed. '
            'I always mess this up. I should have done better.',
        id: 'cbt-draft-1',
        patientId: 'p1',
        clinicianId: 'c1',
      );
      expect(draft.id, 'cbt-draft-1');
      expect(draft.situation, contains('At work'));
      expect(draft.thoughts, isNotEmpty);
      expect(draft.thoughts.first.beliefPct, 70);
      // anxiety + shame both extracted.
      final emoIds = draft.emotionsBefore.map((e) => e.emotion).toSet();
      expect(emoIds, containsAll(['anxiety', 'shame']));
      // all-or-nothing + should-statements both tagged.
      expect(draft.distortions, contains(CbtCognitiveDistortion.allOrNothing));
      expect(
        draft.distortions,
        contains(CbtCognitiveDistortion.shouldStatements),
      );
    });
  });
}
