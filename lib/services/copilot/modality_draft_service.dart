/// Heuristic + LLM-ready modality draft service.
///
/// Goal: take a free-text session transcript and produce a
/// modality-specific skeleton the clinician can accept and edit
/// inside the panel — so the AI is doing the **first draft**, not
/// the clinical work.
///
/// MVP ships with a local heuristic that does:
///   - Sentence segmentation on `.`/`!`/`?` boundaries.
///   - "I thought / I felt / I believed" pattern matching to
///     surface candidate automatic thoughts.
///   - Emotion-keyword scan to seed `emotionsBefore` with a
///     default intensity (60/100 — clinician adjusts in-panel).
///   - Cognitive-distortion tagging by trigger words ("always",
///     "never", "should", "must", "all of them", "fault").
///
/// The interface ([ModalityDraftService]) is stable so a future
/// LLM-backed implementation can swap in without touching panel
/// code — same input transcript, same output skeleton. The local
/// heuristic stays as the offline fallback even after the LLM
/// path is wired (e.g. when the BACKEND_URL is unset).
///
/// **Telemetry-clean**: all logged properties are counts (number
/// of thoughts / emotions / distortions extracted) — never the
/// transcript text or the extracted snippets.
library;

import 'dart:async';

import '../../models/modalities/cbt_thought_record.dart';
import '../data/telemetry_service.dart';

/// Stable interface for whichever backend produces the draft.
abstract class ModalityDraftService {
  /// Produce a CBT thought-record skeleton from a free-text
  /// transcript. Returns a record with `patientId` and
  /// `clinicianId` provided by the caller; the AI fills the
  /// remaining fields. Returning a partially-populated record is
  /// fine — the panel surfaces the draft and the clinician edits.
  Future<CbtThoughtRecord> draftCbtThoughtRecord({
    required String transcript,
    required String id,
    required String patientId,
    required String clinicianId,
  });
}

/// Offline heuristic implementation. Pure text in, pure record
/// out. Useful as a baseline + a fallback when the LLM proxy is
/// not configured. No network calls; safe to run in tests.
class LocalHeuristicModalityDraftService implements ModalityDraftService {
  const LocalHeuristicModalityDraftService();

  @override
  Future<CbtThoughtRecord> draftCbtThoughtRecord({
    required String transcript,
    required String id,
    required String patientId,
    required String clinicianId,
  }) async {
    final sentences = _splitSentences(transcript);
    final thoughts = _extractThoughts(sentences);
    final emotions = _extractEmotions(transcript);
    final distortions = _tagDistortions(transcript);
    final situation = _firstSituation(sentences);

    unawaited(
      TelemetryService.instance.capture(
        'modality_draft.cbt_heuristic',
        properties: {
          'transcript_chars': transcript.length,
          'thoughts': thoughts.length,
          'emotions': emotions.length,
          'distortions': distortions.length,
        },
      ),
    );

    return CbtThoughtRecord(
      id: id,
      patientId: patientId,
      clinicianId: clinicianId,
      recordedAt: DateTime.now().toUtc(),
      situation: situation,
      thoughts: thoughts,
      emotionsBefore: emotions,
      distortions: distortions,
    );
  }
}

// ---------------------------------------------------------------------------
// Pure helpers — exposed for direct unit-testing via DraftHeuristics.

List<String> _splitSentences(String text) {
  final out = <String>[];
  final buffer = StringBuffer();
  for (final ch in text.split('')) {
    buffer.write(ch);
    if (ch == '.' || ch == '!' || ch == '?') {
      final s = buffer.toString().trim();
      if (s.isNotEmpty) out.add(s);
      buffer.clear();
    }
  }
  final tail = buffer.toString().trim();
  if (tail.isNotEmpty) out.add(tail);
  return out;
}

/// "I thought / I felt / I believed / I'm a / I am" patterns +
/// belief defaulted to 70%. Each candidate trimmed to one sentence.
List<CbtAutomaticThought> _extractThoughts(List<String> sentences) {
  final patterns = <RegExp>[
    RegExp(r'\bI thought\b', caseSensitive: false),
    RegExp(r'\bI felt that\b', caseSensitive: false),
    RegExp(r'\bI believed\b', caseSensitive: false),
    RegExp(r"\bI'?m a\b", caseSensitive: false),
    RegExp(r'\bI am a\b', caseSensitive: false),
    RegExp(r'\beveryone (?:will|thinks|knows)\b', caseSensitive: false),
    RegExp(r'\bnobody (?:cares|likes|wants)\b', caseSensitive: false),
  ];
  final out = <CbtAutomaticThought>[];
  for (final s in sentences) {
    if (patterns.any((p) => p.hasMatch(s))) {
      out.add(CbtAutomaticThought(text: s.trim(), beliefPct: 70));
    }
  }
  return out;
}

/// Maps trigger words to the named emotion with default intensity
/// 60. One emotion per occurrence; de-duplicated.
List<CbtEmotionRating> _extractEmotions(String transcript) {
  final lc = transcript.toLowerCase();
  final triggers = <String, String>{
    'anxious': 'anxiety',
    'anxiety': 'anxiety',
    'panic': 'anxiety',
    'sad': 'sadness',
    'depressed': 'sadness',
    'down': 'sadness',
    'angry': 'anger',
    'furious': 'anger',
    'irritated': 'anger',
    'guilty': 'guilt',
    'shame': 'shame',
    'ashamed': 'shame',
    'scared': 'fear',
    'afraid': 'fear',
    'lonely': 'loneliness',
    'hopeless': 'hopelessness',
    'worthless': 'worthlessness',
  };
  final seen = <String>{};
  final out = <CbtEmotionRating>[];
  for (final entry in triggers.entries) {
    if (lc.contains(entry.key) && seen.add(entry.value)) {
      out.add(CbtEmotionRating(emotion: entry.value, intensity: 60));
    }
  }
  return out;
}

/// Burns 10 trigger words. We only tag the obvious ones; the
/// clinician adds the subtler distortions in-panel.
List<CbtCognitiveDistortion> _tagDistortions(String transcript) {
  final lc = transcript.toLowerCase();
  final out = <CbtCognitiveDistortion>[];
  void tagIf(bool cond, CbtCognitiveDistortion d) {
    if (cond && !out.contains(d)) out.add(d);
  }

  tagIf(
    RegExp(r'\b(always|never)\b').hasMatch(lc),
    CbtCognitiveDistortion.allOrNothing,
  );
  tagIf(
    RegExp(r'\b(should|must|ought to)\b').hasMatch(lc),
    CbtCognitiveDistortion.shouldStatements,
  );
  tagIf(
    RegExp(r'\b(everyone|everybody|all of them|nobody)\b').hasMatch(lc),
    CbtCognitiveDistortion.overgeneralization,
  );
  tagIf(
    RegExp(r'\b(disaster|catastrophe|terrible|awful|ruined)\b').hasMatch(lc),
    CbtCognitiveDistortion.magnification,
  );
  tagIf(
    RegExp(r"\b(my fault|all my fault|it's me|because of me)\b").hasMatch(lc),
    CbtCognitiveDistortion.personalization,
  );
  tagIf(
    RegExp(r'\b(I feel it|it must be true|I know it)\b').hasMatch(lc),
    CbtCognitiveDistortion.emotionalReasoning,
  );
  tagIf(
    RegExp(r'\b(loser|failure|idiot|stupid|worthless)\b').hasMatch(lc),
    CbtCognitiveDistortion.labeling,
  );
  return out;
}

/// First sentence that names a concrete trigger (location, time,
/// person). Falls back to the first sentence of the transcript.
String _firstSituation(List<String> sentences) {
  final triggers = RegExp(
    r'\b(at work|at home|in the meeting|on the phone|yesterday|today|'
    r'last night|this morning|with (?:my|the) )\b',
    caseSensitive: false,
  );
  for (final s in sentences) {
    if (triggers.hasMatch(s)) return s.trim();
  }
  return sentences.isEmpty ? '' : sentences.first.trim();
}

/// Re-export the helpers so tests don't import the private names.
class DraftHeuristics {
  const DraftHeuristics._();
  static List<String> splitSentences(String text) => _splitSentences(text);
  static List<CbtAutomaticThought> extractThoughts(List<String> sentences) =>
      _extractThoughts(sentences);
  static List<CbtEmotionRating> extractEmotions(String transcript) =>
      _extractEmotions(transcript);
  static List<CbtCognitiveDistortion> tagDistortions(String transcript) =>
      _tagDistortions(transcript);
  static String firstSituation(List<String> sentences) =>
      _firstSituation(sentences);
}
