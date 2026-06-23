/// Scott Miller's Feedback-Informed Therapy (FIT) scales:
///   - **ORS (Outcome Rating Scale)** — 4 visual-analog items
///     captured at the start of each session. Tracks the
///     patient's well-being trajectory.
///   - **SRS (Session Rating Scale)** — 4 items captured at the
///     end of the session. Tracks the therapeutic alliance.
///
/// Each item runs 0-10. Total runs 0-40. The empirical "clinical
/// cutoff" for adults is **ORS total ≤ 25** (below = clinical
/// range) and **SRS total ≤ 36** (below = alliance risk that
/// predicts dropout).
///
/// Both records are PROM-style — patient-completed (or
/// clinician-administered, depending on the format). Persisted by
/// `FeedbackRatingRepository`.
library;

import 'dart:convert';

enum FitItem {
  // ORS — 4 items, Miller 2003.
  orsIndividual('ors_individual', 'Individually', 'Personal well-being'),
  orsInterpersonal(
    'ors_interpersonal',
    'Interpersonally',
    'Family, close relationships',
  ),
  orsSocial('ors_social', 'Socially', 'Work, school, friendships'),
  orsOverall('ors_overall', 'Overall', 'General sense of well-being'),

  // SRS — 4 items, Duncan 2003.
  srsRelationship(
    'srs_relationship',
    'Relationship',
    'I felt heard, understood, and respected.',
  ),
  srsGoals(
    'srs_goals',
    'Goals and topics',
    'We worked on and talked about what I wanted.',
  ),
  srsApproach(
    'srs_approach',
    'Approach or method',
    "The therapist's approach is a good fit for me.",
  ),
  srsOverall('srs_overall', 'Overall', 'Today felt about right.');

  const FitItem(this.id, this.shortLabel, this.prompt);
  final String id;
  final String shortLabel;
  final String prompt;

  bool get isOrs => id.startsWith('ors_');
  bool get isSrs => id.startsWith('srs_');

  static FitItem? fromId(String id) {
    for (final v in values) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// The 4 ORS items in the canonical Miller order.
  static List<FitItem> get orsItems => values.where((i) => i.isOrs).toList();

  /// The 4 SRS items in the canonical Duncan order.
  static List<FitItem> get srsItems => values.where((i) => i.isSrs).toList();
}

enum FitKind {
  ors('ors'),
  srs('srs');

  const FitKind(this.id);
  final String id;

  static FitKind? fromId(String? id) {
    for (final k in FitKind.values) {
      if (k.id == id) return k;
    }
    return null;
  }
}

class FeedbackRating {
  FeedbackRating({
    required this.id,
    required this.kind,
    required this.sessionId,
    required this.patientId,
    required this.clinicianId,
    required this.capturedAt,
    required this.scores,
  }) {
    final expected = kind == FitKind.ors ? FitItem.orsItems : FitItem.srsItems;
    for (final item in expected) {
      assert(
        scores.containsKey(item),
        'Missing score for ${item.id} on ${kind.id} rating',
      );
      final v = scores[item];
      assert(v != null && v >= 0 && v <= 10, 'Score out of range');
    }
  }

  factory FeedbackRating.fromJson(Map<String, dynamic> json) {
    final kind = FitKind.fromId(json['kind'] as String?) ?? FitKind.ors;
    final raw = json['scores'];
    final scores = <FitItem, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final item = FitItem.fromId(entry.key.toString());
        final v = entry.value;
        if (item != null && v is num) {
          scores[item] = v.toInt().clamp(0, 10);
        }
      }
    }
    // Fill in any missing items at 0 so the assertion contract holds.
    final expected = kind == FitKind.ors ? FitItem.orsItems : FitItem.srsItems;
    for (final item in expected) {
      scores.putIfAbsent(item, () => 0);
    }
    return FeedbackRating(
      id: json['id'] as String,
      kind: kind,
      sessionId: json['sessionId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      clinicianId: json['clinicianId'] as String? ?? '',
      capturedAt:
          DateTime.tryParse(json['capturedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      scores: scores,
    );
  }

  final String id;
  final FitKind kind;
  final String sessionId;
  final String patientId;
  final String clinicianId;
  final DateTime capturedAt;
  final Map<FitItem, int> scores;

  /// Sum across the 4 items — runs 0-40.
  int get total => scores.values.fold(0, (s, v) => s + v);

  /// ORS clinical-range cutoff is **≤ 25** for adults; SRS
  /// alliance-risk cutoff is **≤ 36**. The cutoffs flip the
  /// caller's "do I escalate / surface this in supervision"
  /// decision.
  bool get isBelowCutoff {
    if (kind == FitKind.ors) return total <= 25;
    return total <= 36;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.id,
    'sessionId': sessionId,
    'patientId': patientId,
    'clinicianId': clinicianId,
    'capturedAt': capturedAt.toIso8601String(),
    'scores': {for (final entry in scores.entries) entry.key.id: entry.value},
  };

  @override
  String toString() => 'FeedbackRating(${jsonEncode(toJson())})';
}
