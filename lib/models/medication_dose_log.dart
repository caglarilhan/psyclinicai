/// One scheduled dose of a medication and what happened to it.
///
/// Bridges the regimen ([Medication]) to the day-by-day reality of
/// taking it. Psychiatry uses MAR (Medication Administration
/// Record) language for this — every dose is either taken,
/// missed, or skipped (with a reason). Optional `sideEffects`
/// list lets the patient flag adverse events without the
/// clinician having to spin up a separate visit.
///
/// Persistence: SharedPreferences via
/// `MedicationDoseRepository`. Mirror to Firestore when the
/// tenant flips to managed sync.
library;

import 'dart:convert';

enum DoseStatus {
  pending('pending'),
  taken('taken'),
  missed('missed'),
  skipped('skipped');

  const DoseStatus(this.id);
  final String id;

  static DoseStatus fromId(String? id) => DoseStatus.values.firstWhere(
    (s) => s.id == id,
    orElse: () => DoseStatus.pending,
  );
}

class MedicationDoseLog {
  MedicationDoseLog({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.scheduledAt,
    this.takenAt,
    this.status = DoseStatus.pending,
    this.sideEffects = const [],
    this.notes = '',
  });

  factory MedicationDoseLog.fromJson(Map<String, dynamic> json) {
    final rawSe = json['sideEffects'];
    final sideEffects = <String>[
      if (rawSe is List)
        for (final s in rawSe)
          if (s is String && s.trim().isNotEmpty) s.trim(),
    ];
    return MedicationDoseLog(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      medicationId: json['medicationId'] as String? ?? '',
      scheduledAt:
          DateTime.tryParse(json['scheduledAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      takenAt: DateTime.tryParse(json['takenAt'] as String? ?? ''),
      status: DoseStatus.fromId(json['status'] as String?),
      sideEffects: sideEffects,
      notes: json['notes'] as String? ?? '',
    );
  }

  final String id;
  final String patientId;

  /// FK to [Medication.id]. The MAR screen joins the regimen on
  /// this id to render the medication name + dose alongside the
  /// scheduled time.
  final String medicationId;

  /// When the dose was scheduled (clinician-defined window). UTC.
  final DateTime scheduledAt;

  /// When the patient actually took the dose. `null` for
  /// pending/missed/skipped statuses.
  final DateTime? takenAt;

  final DoseStatus status;

  /// Patient-reported side effects (free text per entry — no
  /// fixed taxonomy because adverse-event vocabularies are
  /// regional). Example entries: "dry mouth", "drowsiness 4/10",
  /// "AIMS movement noted at chin".
  final List<String> sideEffects;

  /// Optional context — "took late after lunch", "vomited within
  /// 20 min, skipped re-dose per Dr. order", etc.
  final String notes;

  /// Adherence-grace window. A dose is "missed" if pending after
  /// this many hours past `scheduledAt`. Default 4h — matches
  /// what most psychotropic schedules tolerate before the next
  /// dose stacks. Adjust per-drug via the regimen if needed.
  static const Duration adherenceGrace = Duration(hours: 4);

  bool get isOverdue =>
      status == DoseStatus.pending &&
      DateTime.now().toUtc().isAfter(scheduledAt.add(adherenceGrace));

  MedicationDoseLog copyWith({
    DateTime? takenAt,
    DoseStatus? status,
    List<String>? sideEffects,
    String? notes,
  }) => MedicationDoseLog(
    id: id,
    patientId: patientId,
    medicationId: medicationId,
    scheduledAt: scheduledAt,
    takenAt: takenAt ?? this.takenAt,
    status: status ?? this.status,
    sideEffects: sideEffects ?? this.sideEffects,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'medicationId': medicationId,
    'scheduledAt': scheduledAt.toIso8601String(),
    'takenAt': takenAt?.toIso8601String(),
    'status': status.id,
    'sideEffects': sideEffects,
    'notes': notes,
  };

  @override
  String toString() => 'MedicationDoseLog(${jsonEncode(toJson())})';
}

/// Adherence summary across a window — surfaced in the MAR
/// screen header + telemetry.
class AdherenceSummary {
  const AdherenceSummary({
    required this.windowStart,
    required this.windowEnd,
    required this.scheduled,
    required this.taken,
    required this.missed,
    required this.skipped,
  });

  final DateTime windowStart;
  final DateTime windowEnd;
  final int scheduled;
  final int taken;
  final int missed;
  final int skipped;

  /// Adherence ratio: taken / (scheduled - skipped). Returns 1.0
  /// when nothing was scheduled. Skipped doses don't count
  /// against the patient (clinician-authorised pauses, GI upset
  /// after dose, etc.).
  double get adherenceRatio {
    final denom = scheduled - skipped;
    if (denom <= 0) return 1;
    return taken / denom;
  }

  /// Percentage 0-100 rounded for display.
  int get adherencePct => (adherenceRatio * 100).round().clamp(0, 100);

  /// Compute over a list of dose logs scoped to the window.
  static AdherenceSummary compute({
    required DateTime start,
    required DateTime end,
    required List<MedicationDoseLog> doses,
  }) {
    var scheduled = 0;
    var taken = 0;
    var missed = 0;
    var skipped = 0;
    for (final d in doses) {
      final at = d.scheduledAt;
      if (at.isBefore(start) || at.isAfter(end)) continue;
      scheduled++;
      switch (d.status) {
        case DoseStatus.taken:
          taken++;
        case DoseStatus.missed:
          missed++;
        case DoseStatus.skipped:
          skipped++;
        case DoseStatus.pending:
          if (d.isOverdue) missed++;
      }
    }
    return AdherenceSummary(
      windowStart: start,
      windowEnd: end,
      scheduled: scheduled,
      taken: taken,
      missed: missed,
      skipped: skipped,
    );
  }
}
