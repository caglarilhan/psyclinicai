/// CBT Thought Record — Beck Institute / Greenberger & Padesky
/// 7-column model.
///
/// Order of columns: Situation → Automatic Thoughts (with belief %)
/// → Emotions (with intensity 0-100) → Cognitive Distortions →
/// Evidence For → Evidence Against → Balanced/Alternative Thought
/// (with belief %) → Re-rated Emotions (intensity 0-100).
///
/// Cognitive-distortion taxonomy follows Burns' 10 distortions from
/// *Feeling Good*. Clinicians can tag multiple distortions per
/// automatic thought.
///
/// Persistence: JSON-serialised through
/// `ModalitySessionRepository` (offline SharedPreferences + future
/// Firestore mirror).
library;

import 'dart:convert';

class CbtThoughtRecord {
  CbtThoughtRecord({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.recordedAt,
    this.situation = '',
    this.thoughts = const [],
    this.emotionsBefore = const [],
    this.distortions = const [],
    this.evidenceFor = '',
    this.evidenceAgainst = '',
    this.balancedThought = '',
    this.balancedBeliefPct = 0,
    this.emotionsAfter = const [],
    this.clinicianNotes = '',
  });

  factory CbtThoughtRecord.fromJson(Map<String, dynamic> json) =>
      CbtThoughtRecord(
        id: json['id'] as String,
        patientId: json['patientId'] as String? ?? '',
        clinicianId: json['clinicianId'] as String? ?? '',
        recordedAt:
            DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
            DateTime.now().toUtc(),
        situation: json['situation'] as String? ?? '',
        thoughts: _decodeThoughts(json['thoughts']),
        emotionsBefore: _decodeEmotions(json['emotionsBefore']),
        distortions: _decodeDistortions(json['distortions']),
        evidenceFor: json['evidenceFor'] as String? ?? '',
        evidenceAgainst: json['evidenceAgainst'] as String? ?? '',
        balancedThought: json['balancedThought'] as String? ?? '',
        balancedBeliefPct: (json['balancedBeliefPct'] as num?)?.toInt() ?? 0,
        emotionsAfter: _decodeEmotions(json['emotionsAfter']),
        clinicianNotes: json['clinicianNotes'] as String? ?? '',
      );

  static List<CbtAutomaticThought> _decodeThoughts(Object? raw) {
    if (raw is! List) return const [];
    final out = <CbtAutomaticThought>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        out.add(CbtAutomaticThought.fromJson(item));
      } else if (item is Map) {
        out.add(CbtAutomaticThought.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return out;
  }

  static List<CbtEmotionRating> _decodeEmotions(Object? raw) {
    if (raw is! List) return const [];
    final out = <CbtEmotionRating>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        out.add(CbtEmotionRating.fromJson(item));
      } else if (item is Map) {
        out.add(CbtEmotionRating.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return out;
  }

  static List<CbtCognitiveDistortion> _decodeDistortions(Object? raw) {
    if (raw is! List) return const [];
    final out = <CbtCognitiveDistortion>[];
    for (final v in raw) {
      if (v is String) {
        final hit = CbtCognitiveDistortion.values
            .where((d) => d.id == v)
            .toList();
        if (hit.isNotEmpty) out.add(hit.first);
      }
    }
    return out;
  }

  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime recordedAt;

  /// Column 1 — Trigger: what happened, where, with whom.
  final String situation;

  /// Column 2 — automatic thoughts (each with belief % 0-100). The
  /// clinician usually surfaces the *hottest* thought (highest
  /// belief) before challenging it.
  final List<CbtAutomaticThought> thoughts;

  /// Column 3 — emotion + intensity *before* the cognitive work
  /// (0-100). Each emotion is named so trauma-informed clinicians can
  /// avoid forcing a discrete primary-emotion taxonomy.
  final List<CbtEmotionRating> emotionsBefore;

  /// Column 4 — Burns' 10 distortions tagged on the automatic
  /// thought(s). Multi-select; an "all-or-nothing" thought commonly
  /// also tags "labeling".
  final List<CbtCognitiveDistortion> distortions;

  /// Column 5/6 — evidence both directions for the hot thought.
  /// Keep separate so the patient sees the asymmetry on paper.
  final String evidenceFor;
  final String evidenceAgainst;

  /// Column 7 — alternative / balanced thought + the patient's new
  /// belief in it (0-100). The Beck model insists this is the
  /// *patient's* thought, not the clinician's rewrite.
  final String balancedThought;
  final int balancedBeliefPct;

  /// Column 8 — re-rated emotion intensity. Delta = primary outcome
  /// signal for the session; plotted on the trend chart.
  final List<CbtEmotionRating> emotionsAfter;

  /// Clinician-only addendum (rapport notes, supervisor flag, etc.)
  /// — not surfaced to the patient PWA.
  final String clinicianNotes;

  /// Sum of `emotionsBefore` intensities minus sum of `emotionsAfter`
  /// — positive delta = patient felt better post-record.
  int get intensityDelta {
    final before = emotionsBefore.fold<int>(0, (s, e) => s + e.intensity);
    final after = emotionsAfter.fold<int>(0, (s, e) => s + e.intensity);
    return before - after;
  }

  /// "Complete" = the 4 minimum-viable fields are populated. The Beck
  /// model treats partial records as legitimate (the cognitive work
  /// can land in pieces), so we don't gate persistence on this flag.
  bool get isComplete =>
      situation.trim().isNotEmpty &&
      thoughts.isNotEmpty &&
      emotionsBefore.isNotEmpty &&
      balancedThought.trim().isNotEmpty;

  CbtThoughtRecord copyWith({
    String? situation,
    List<CbtAutomaticThought>? thoughts,
    List<CbtEmotionRating>? emotionsBefore,
    List<CbtCognitiveDistortion>? distortions,
    String? evidenceFor,
    String? evidenceAgainst,
    String? balancedThought,
    int? balancedBeliefPct,
    List<CbtEmotionRating>? emotionsAfter,
    String? clinicianNotes,
  }) => CbtThoughtRecord(
    id: id,
    patientId: patientId,
    clinicianId: clinicianId,
    recordedAt: recordedAt,
    situation: situation ?? this.situation,
    thoughts: thoughts ?? this.thoughts,
    emotionsBefore: emotionsBefore ?? this.emotionsBefore,
    distortions: distortions ?? this.distortions,
    evidenceFor: evidenceFor ?? this.evidenceFor,
    evidenceAgainst: evidenceAgainst ?? this.evidenceAgainst,
    balancedThought: balancedThought ?? this.balancedThought,
    balancedBeliefPct: balancedBeliefPct ?? this.balancedBeliefPct,
    emotionsAfter: emotionsAfter ?? this.emotionsAfter,
    clinicianNotes: clinicianNotes ?? this.clinicianNotes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'clinicianId': clinicianId,
    'recordedAt': recordedAt.toIso8601String(),
    'situation': situation,
    'thoughts': thoughts.map((t) => t.toJson()).toList(),
    'emotionsBefore': emotionsBefore.map((e) => e.toJson()).toList(),
    'distortions': distortions.map((d) => d.id).toList(),
    'evidenceFor': evidenceFor,
    'evidenceAgainst': evidenceAgainst,
    'balancedThought': balancedThought,
    'balancedBeliefPct': balancedBeliefPct,
    'emotionsAfter': emotionsAfter.map((e) => e.toJson()).toList(),
    'clinicianNotes': clinicianNotes,
  };

  /// Plain-text export — useful for the patient-facing PDF and the
  /// session-note appendix. Reads top-to-bottom like a written
  /// record.
  String toPlainText() {
    final buf = StringBuffer();
    buf.writeln('Situation:');
    buf.writeln(situation.isEmpty ? '—' : situation);
    buf.writeln();
    buf.writeln('Automatic thoughts:');
    if (thoughts.isEmpty) {
      buf.writeln('—');
    } else {
      for (final t in thoughts) {
        buf.writeln('  • ${t.text}  (belief ${t.beliefPct}%)');
      }
    }
    buf.writeln();
    if (distortions.isNotEmpty) {
      buf.writeln('Distortions tagged:');
      for (final d in distortions) {
        buf.writeln('  • ${d.label}');
      }
      buf.writeln();
    }
    buf.writeln('Emotions before:');
    if (emotionsBefore.isEmpty) {
      buf.writeln('—');
    } else {
      for (final e in emotionsBefore) {
        buf.writeln('  • ${e.emotion}  (${e.intensity}/100)');
      }
    }
    buf.writeln();
    if (evidenceFor.trim().isNotEmpty || evidenceAgainst.trim().isNotEmpty) {
      buf.writeln('Evidence for:');
      buf.writeln(evidenceFor.isEmpty ? '—' : evidenceFor);
      buf.writeln();
      buf.writeln('Evidence against:');
      buf.writeln(evidenceAgainst.isEmpty ? '—' : evidenceAgainst);
      buf.writeln();
    }
    buf.writeln('Balanced thought:');
    if (balancedThought.isEmpty) {
      buf.writeln('—');
    } else {
      buf.writeln('$balancedThought  (belief $balancedBeliefPct%)');
    }
    buf.writeln();
    buf.writeln('Emotions after:');
    if (emotionsAfter.isEmpty) {
      buf.writeln('—');
    } else {
      for (final e in emotionsAfter) {
        buf.writeln('  • ${e.emotion}  (${e.intensity}/100)');
      }
    }
    return buf.toString().trimRight();
  }

  @override
  String toString() => 'CbtThoughtRecord(${jsonEncode(toJson())})';
}

/// One automatic thought + the patient's belief in it (0-100).
class CbtAutomaticThought {
  const CbtAutomaticThought({required this.text, required this.beliefPct})
    : assert(beliefPct >= 0 && beliefPct <= 100);

  factory CbtAutomaticThought.fromJson(Map<String, dynamic> json) =>
      CbtAutomaticThought(
        text: json['text'] as String? ?? '',
        beliefPct: (json['beliefPct'] as num?)?.toInt().clamp(0, 100) ?? 0,
      );

  final String text;
  final int beliefPct;

  Map<String, dynamic> toJson() => {'text': text, 'beliefPct': beliefPct};
}

/// One emotion + intensity (0-100). Emotion is free-text so the
/// clinician can name nuanced affect (e.g. "loneliness", "envy") that
/// a discrete enum would gate-keep.
class CbtEmotionRating {
  const CbtEmotionRating({required this.emotion, required this.intensity})
    : assert(intensity >= 0 && intensity <= 100);

  factory CbtEmotionRating.fromJson(Map<String, dynamic> json) =>
      CbtEmotionRating(
        emotion: json['emotion'] as String? ?? '',
        intensity: (json['intensity'] as num?)?.toInt().clamp(0, 100) ?? 0,
      );

  final String emotion;
  final int intensity;

  Map<String, dynamic> toJson() => {'emotion': emotion, 'intensity': intensity};
}

/// Burns' 10 cognitive distortions (the field-standard taxonomy from
/// *Feeling Good*, 1980 / revised editions). Order kept stable so
/// the chip-grid layout in the panel UI is predictable.
enum CbtCognitiveDistortion {
  allOrNothing(
    'all_or_nothing',
    'All-or-Nothing Thinking',
    'Seeing things in black-or-white categories. "If I am not perfect, I am a failure."',
  ),
  overgeneralization(
    'overgeneralization',
    'Overgeneralization',
    'A single negative event seen as a never-ending pattern of defeat.',
  ),
  mentalFilter(
    'mental_filter',
    'Mental Filter',
    'Dwelling on one negative detail until the whole situation is darkened.',
  ),
  disqualifyingPositive(
    'disqualifying_positive',
    'Disqualifying the Positive',
    'Rejecting positive experiences ("they don\'t count") to keep a negative belief intact.',
  ),
  jumpingToConclusions(
    'jumping_to_conclusions',
    'Jumping to Conclusions',
    'Mind-reading or fortune-telling without facts ("they think I\'m incompetent").',
  ),
  magnification(
    'magnification',
    'Magnification / Minimization',
    'Catastrophising the negative or shrinking the positive.',
  ),
  emotionalReasoning(
    'emotional_reasoning',
    'Emotional Reasoning',
    '"I feel it, therefore it must be true." Mistaking feelings for facts.',
  ),
  shouldStatements(
    'should_statements',
    'Should Statements',
    '"Shoulds", "musts", "oughts" — guilt-inducing internal demands.',
  ),
  labeling(
    'labeling',
    'Labeling / Mislabeling',
    'Attaching a global negative label ("I\'m a loser") instead of describing the event.',
  ),
  personalization(
    'personalization',
    'Personalization / Blame',
    'Assigning self-blame for events not entirely within one\'s control.',
  );

  const CbtCognitiveDistortion(this.id, this.label, this.description);
  final String id;
  final String label;
  final String description;
}
