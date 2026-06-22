/// Patient-reported outcome measure submission (Sprint 13).
///
/// One row per PROM completion by a patient through the portal.
/// Separate from `clinical_scale.dart` (which holds the scoring
/// algorithm + canonical bands); this model tracks WHO completed
/// WHICH instrument WHEN, and the resulting score.
///
/// The score itself is computed elsewhere (e.g. `ClinicalScales.phq9`)
/// and recorded here as an integer + severity label so the patient's
/// outcomes dashboard can plot trends without re-running the scorer.
class PromSubmission {
  PromSubmission({
    required this.id,
    required this.patientId,
    required this.instrument,
    required this.score,
    required this.severity,
    this.requestedByClinicianId,
    this.responses,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now().toUtc() {
    if (score < 0) {
      throw ArgumentError('PROM score cannot be negative (got $score).');
    }
  }

  factory PromSubmission.fromJson(Map<String, dynamic> json) => PromSubmission(
    id: json['id'] as String? ?? '',
    patientId: json['patientId'] as String? ?? '',
    instrument: json['instrument'] as String? ?? '',
    score: (json['score'] as num? ?? 0).toInt(),
    severity: json['severity'] as String? ?? '',
    requestedByClinicianId: json['requestedByClinicianId'] as String?,
    responses: (json['responses'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    ),
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
  );

  final String id;
  final String patientId;

  /// Canonical instrument id (`phq9`, `gad7`, `pcl5`, `audit`, ...).
  final String instrument;
  final int score;

  /// Human band ("minimal" / "moderate" / "severe") — denormalised
  /// so the outcomes dashboard does not re-derive on each render.
  final String severity;

  /// When the clinician explicitly assigned this PROM. Null when the
  /// patient self-initiated from the portal.
  final String? requestedByClinicianId;

  /// Per-item raw responses, keyed by item id (e.g. `phq9_1`).
  /// Optional — the dashboard only needs `score`; raw responses help
  /// the clinician spot a specific symptom (e.g. PHQ-9 item 9).
  final Map<String, int>? responses;

  final DateTime completedAt;

  /// True when this submission is a PHQ-9 row AND item 9
  /// ("thoughts that you would be better off dead, or of hurting
  /// yourself") scored ≥ 1. This is the highest-priority single-item
  /// patient-safety signal in the PHQ-9; the dashboard must surface
  /// it within minutes even when the total score sits in a "moderate"
  /// band. The flag is derived from raw responses, so it is null
  /// when [responses] is null.
  bool? get phq9Item9Positive {
    if (instrument != 'phq9') return null;
    final r = responses;
    if (r == null) return null;
    final v = r['phq9_9'] ?? r['item_9'] ?? r['q9'];
    if (v == null) return null;
    return v >= 1;
  }

  /// Convenience for the EscalationSoftLockRecord pipeline — any PROM
  /// row that should auto-create a soft-lock for follow-up.
  bool get triggersHighRiskFollowUp => phq9Item9Positive == true;

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'instrument': instrument,
    'score': score,
    'severity': severity,
    if (requestedByClinicianId != null)
      'requestedByClinicianId': requestedByClinicianId,
    if (responses != null) 'responses': responses,
    'completedAt': completedAt.toIso8601String(),
  };
}
