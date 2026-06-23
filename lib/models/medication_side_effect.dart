/// Patient-reported (or clinician-observed) medication side
/// effect log. Each row is a single adverse event tied to a
/// prescribed medication. The clinician records severity, the
/// body system involved, onset / resolution, and — optionally —
/// the Naranjo Adverse Drug Reaction Probability Scale score
/// (Naranjo et al., 1981).
///
/// Why a dedicated model: MAR (`medication_dose_log.dart`) covers
/// "did the patient take it?". SE covers "what happened when they
/// did?". Two different clinical questions — psychiatry needs both
/// because tolerability is what drives adherence, and adherence is
/// what drives outcomes.
library;

import 'dart:convert';

/// Coarse organ-system bucket. Used for filtering side-effect
/// history ("show me anything cardiovascular before we add the
/// next stimulant") and for the outcomes dashboard. Stays small
/// on purpose — finer-grained MedDRA codes are out of scope.
enum SideEffectSystem {
  gastrointestinal('gastrointestinal'),
  neurological('neurological'),
  cardiovascular('cardiovascular'),
  metabolic('metabolic'),
  dermatologic('dermatologic'),
  sexual('sexual'),
  psychiatric('psychiatric'),
  sleep('sleep'),
  other('other');

  const SideEffectSystem(this.id);
  final String id;

  static SideEffectSystem fromId(String? id) => SideEffectSystem.values
      .firstWhere((s) => s.id == id, orElse: () => SideEffectSystem.other);
}

/// Severity scale — short, intuitive ordinal that maps onto
/// CTCAE-style language without claiming to be CTCAE. The MAR
/// sheet renders these as labelled chips so the patient (or
/// clinician documenting at the visit) picks one without typing.
enum SideEffectSeverity {
  none(0, 'None'),
  mild(1, 'Mild'),
  moderate(2, 'Moderate'),
  severe(3, 'Severe'),
  lifeThreatening(4, 'Life-threatening');

  const SideEffectSeverity(this.value, this.label);
  final int value;
  final String label;

  static SideEffectSeverity fromValue(int? v) => SideEffectSeverity.values
      .firstWhere((s) => s.value == v, orElse: () => SideEffectSeverity.none);
}

/// Naranjo ADR causality bucket. Computed from the 10-question
/// Naranjo scale (sum −4..+13) at evaluation time. Bucket only —
/// we don't store the per-question answers here, so the clinician
/// can revise the bucket without us being prescriptive about the
/// scoring path.
enum NaranjoCategory {
  doubtful('doubtful'),
  possible('possible'),
  probable('probable'),
  definite('definite');

  const NaranjoCategory(this.id);
  final String id;

  /// Naranjo scale cutoffs (Naranjo et al., 1981):
  /// ≤0 = doubtful, 1-4 = possible, 5-8 = probable, ≥9 = definite.
  static NaranjoCategory fromScore(int score) {
    if (score >= 9) return NaranjoCategory.definite;
    if (score >= 5) return NaranjoCategory.probable;
    if (score >= 1) return NaranjoCategory.possible;
    return NaranjoCategory.doubtful;
  }

  static NaranjoCategory? fromId(String? id) {
    if (id == null) return null;
    for (final c in values) {
      if (c.id == id) return c;
    }
    return null;
  }
}

class MedicationSideEffect {
  MedicationSideEffect({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.clinicianId,
    required this.reportedAt,
    required this.symptom,
    this.system = SideEffectSystem.other,
    this.severity = SideEffectSeverity.mild,
    this.naranjoScore,
    this.onsetAt,
    this.resolvedAt,
    this.actionTaken = '',
    this.notes = '',
  });

  factory MedicationSideEffect.fromJson(Map<String, dynamic> json) {
    final naranjo = json['naranjoScore'];
    return MedicationSideEffect(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      medicationId: json['medicationId'] as String? ?? '',
      clinicianId: json['clinicianId'] as String? ?? '',
      reportedAt:
          DateTime.tryParse(json['reportedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      symptom: json['symptom'] as String? ?? '',
      system: SideEffectSystem.fromId(json['system'] as String?),
      severity: SideEffectSeverity.fromValue(
        (json['severity'] as num?)?.toInt(),
      ),
      naranjoScore: naranjo is num ? naranjo.toInt() : null,
      onsetAt: DateTime.tryParse(json['onsetAt'] as String? ?? ''),
      resolvedAt: DateTime.tryParse(json['resolvedAt'] as String? ?? ''),
      actionTaken: json['actionTaken'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  final String id;
  final String patientId;
  final String medicationId;
  final String clinicianId;

  /// When the clinician (or patient via portal) entered this row.
  final DateTime reportedAt;

  /// Free-text symptom label. Kept free-text on purpose — the
  /// SE button hands the patient a chip rail of common SEs (per
  /// drug class) but they can type their own.
  final String symptom;

  final SideEffectSystem system;
  final SideEffectSeverity severity;

  /// Naranjo 10-question total, range −4..+13. Null when not
  /// scored yet (early entry, patient-reported via portal).
  final int? naranjoScore;

  /// First-noticed time. May predate the report time.
  final DateTime? onsetAt;
  final DateTime? resolvedAt;

  /// What did the clinician do — dose reduction, discontinuation,
  /// counter-medication, watchful waiting. Free-text by design.
  final String actionTaken;
  final String notes;

  bool get isOngoing => resolvedAt == null;

  /// Anything moderate-or-worse fires the dashboard's
  /// "tolerability flag" — i.e., shows up in the patient pulse
  /// next to adherence.
  bool get isClinicallySignificant =>
      severity.value >= SideEffectSeverity.moderate.value;

  NaranjoCategory? get naranjoCategory =>
      naranjoScore == null ? null : NaranjoCategory.fromScore(naranjoScore!);

  Duration? get durationIfResolved => resolvedAt == null || onsetAt == null
      ? null
      : resolvedAt!.difference(onsetAt!);

  MedicationSideEffect copyWith({
    String? symptom,
    SideEffectSystem? system,
    SideEffectSeverity? severity,
    int? naranjoScore,
    DateTime? onsetAt,
    DateTime? resolvedAt,
    String? actionTaken,
    String? notes,
  }) => MedicationSideEffect(
    id: id,
    patientId: patientId,
    medicationId: medicationId,
    clinicianId: clinicianId,
    reportedAt: reportedAt,
    symptom: symptom ?? this.symptom,
    system: system ?? this.system,
    severity: severity ?? this.severity,
    naranjoScore: naranjoScore ?? this.naranjoScore,
    onsetAt: onsetAt ?? this.onsetAt,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    actionTaken: actionTaken ?? this.actionTaken,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'medicationId': medicationId,
    'clinicianId': clinicianId,
    'reportedAt': reportedAt.toIso8601String(),
    'symptom': symptom,
    'system': system.id,
    'severity': severity.value,
    'naranjoScore': naranjoScore,
    'onsetAt': onsetAt?.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
    'actionTaken': actionTaken,
    'notes': notes,
  };

  @override
  String toString() => 'MedicationSideEffect(${jsonEncode(toJson())})';
}

/// Roll-up over a window — the patient header card shows
/// "3 ongoing side effects, 1 moderate+" so the clinician can
/// prioritise tolerability questions at the next visit.
class SideEffectSummary {
  const SideEffectSummary({
    required this.total,
    required this.ongoing,
    required this.clinicallySignificant,
    required this.bySystem,
  });

  final int total;
  final int ongoing;
  final int clinicallySignificant;
  final Map<SideEffectSystem, int> bySystem;

  static SideEffectSummary compute(Iterable<MedicationSideEffect> events) {
    final by = <SideEffectSystem, int>{};
    var ongoing = 0;
    var sig = 0;
    var total = 0;
    for (final e in events) {
      total++;
      if (e.isOngoing) ongoing++;
      if (e.isClinicallySignificant) sig++;
      by[e.system] = (by[e.system] ?? 0) + 1;
    }
    return SideEffectSummary(
      total: total,
      ongoing: ongoing,
      clinicallySignificant: sig,
      bySystem: Map.unmodifiable(by),
    );
  }
}
