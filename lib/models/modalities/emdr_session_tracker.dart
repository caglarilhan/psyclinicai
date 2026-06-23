/// EMDR Session Tracker — Francine Shapiro's 8-Phase protocol.
///
/// One record per session. Captures the assessment components (NC /
/// PC / VOC / SUDS / Body location), every bilateral-stimulation
/// (BLS) set the clinician runs in desensitization, the
/// installation re-rate, body-scan and closure notes, and an
/// abreaction safety check.
///
/// Standard scales:
///   - **SUDS** (Subjective Units of Distress): 0 (neutral) → 10
///     (worst imaginable). Closure target: SUDS ≤ 1.
///   - **VOC** (Validity of Cognition): 1 (completely false) →
///     7 (completely true). Installation target: VOC = 6 or 7.
///
/// Persistence: JSON-serialised through
/// `ModalitySessionRepository`.
library;

import 'dart:convert';

class EmdrSessionTracker {
  EmdrSessionTracker({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.createdAt,
    this.updatedAt,
    this.currentPhase = EmdrPhase.threeAssessment,
    this.targetMemory = '',
    this.negativeCognition = '',
    this.positiveCognition = '',
    this.vocStart = 1,
    this.vocEnd,
    this.sudsStart = 0,
    this.sudsEnd,
    this.bodyLocation = '',
    this.blsSets = const [],
    this.bodyScanNotes = '',
    this.closureNotes = '',
    this.abreactionOccurred = false,
    this.abreactionResource,
    this.reevaluationNotes = '',
    this.clinicianNotes = '',
  }) : assert(vocStart >= 1 && vocStart <= 7),
       assert(vocEnd == null || (vocEnd >= 1 && vocEnd <= 7)),
       assert(sudsStart >= 0 && sudsStart <= 10),
       assert(sudsEnd == null || (sudsEnd >= 0 && sudsEnd <= 10));

  factory EmdrSessionTracker.fromJson(Map<String, dynamic> json) {
    final phaseId = json['currentPhase'] as String? ?? '';
    final phase = EmdrPhase.values.where((p) => p.id == phaseId).toList();
    return EmdrSessionTracker(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      clinicianId: json['clinicianId'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      currentPhase: phase.isNotEmpty
          ? phase.first
          : EmdrPhase.threeAssessment,
      targetMemory: json['targetMemory'] as String? ?? '',
      negativeCognition: json['negativeCognition'] as String? ?? '',
      positiveCognition: json['positiveCognition'] as String? ?? '',
      vocStart: ((json['vocStart'] as num?)?.toInt() ?? 1).clamp(1, 7),
      vocEnd: json['vocEnd'] == null
          ? null
          : ((json['vocEnd'] as num?)?.toInt() ?? 1).clamp(1, 7),
      sudsStart: ((json['sudsStart'] as num?)?.toInt() ?? 0).clamp(0, 10),
      sudsEnd: json['sudsEnd'] == null
          ? null
          : ((json['sudsEnd'] as num?)?.toInt() ?? 0).clamp(0, 10),
      bodyLocation: json['bodyLocation'] as String? ?? '',
      blsSets: _decodeBls(json['blsSets']),
      bodyScanNotes: json['bodyScanNotes'] as String? ?? '',
      closureNotes: json['closureNotes'] as String? ?? '',
      abreactionOccurred: json['abreactionOccurred'] as bool? ?? false,
      abreactionResource: json['abreactionResource'] as String?,
      reevaluationNotes: json['reevaluationNotes'] as String? ?? '',
      clinicianNotes: json['clinicianNotes'] as String? ?? '',
    );
  }

  static List<EmdrBlsSet> _decodeBls(Object? raw) {
    if (raw is! List) return const [];
    final out = <EmdrBlsSet>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        out.add(EmdrBlsSet.fromJson(item));
      } else if (item is Map) {
        out.add(EmdrBlsSet.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return out;
  }

  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Current Shapiro phase (the screen highlights this in the
  /// stepper).
  final EmdrPhase currentPhase;

  /// Phase 3 — assessment of the target memory.
  final String targetMemory;
  final String negativeCognition;
  final String positiveCognition;
  final int vocStart;
  final int sudsStart;
  final String bodyLocation;

  /// Phase 4 — desensitization. Each BLS set carries before / after
  /// SUDS so the clinician can see the trajectory.
  final List<EmdrBlsSet> blsSets;

  /// Phase 5 — installation. Re-rated VOC after the PC has been
  /// installed. Target: 6 or 7.
  final int? vocEnd;

  /// Phase 4 → 5 transition. Re-rated SUDS at the end of
  /// desensitization. Target: 0 or 1.
  final int? sudsEnd;

  /// Phase 6 — body scan.
  final String bodyScanNotes;

  /// Phase 7 — closure.
  final String closureNotes;

  /// Abreaction safety. If `true`, the clinician must record the
  /// resource (safe place, RDI installation, container) used to
  /// stabilise the patient before they left the room.
  final bool abreactionOccurred;
  final String? abreactionResource;

  /// Phase 8 — next-session reevaluation notes (filled in the
  /// follow-up session). Lets the team see whether SUDS / VOC held.
  final String reevaluationNotes;

  /// Clinician-only addendum.
  final String clinicianNotes;

  /// Closure-safety gate: the protocol calls for *no patient leaves
  /// in an unresolved abreaction*. We surface this so the panel can
  /// block phase 7 advance until the clinician confirms the resource
  /// was used.
  bool get isClosureSafe {
    if (!abreactionOccurred) return true;
    return (abreactionResource ?? '').trim().isNotEmpty;
  }

  /// SUDS arc from session start → end. Negative = improvement
  /// (lower distress). Returns `null` if the desensitization wasn't
  /// scored at the end yet.
  int? get sudsDelta => sudsEnd == null ? null : sudsEnd! - sudsStart;

  /// VOC arc from start → installation. Positive = belief
  /// strengthened.
  int? get vocDelta => vocEnd == null ? null : vocEnd! - vocStart;

  EmdrSessionTracker copyWith({
    EmdrPhase? currentPhase,
    String? targetMemory,
    String? negativeCognition,
    String? positiveCognition,
    int? vocStart,
    int? vocEnd,
    int? sudsStart,
    int? sudsEnd,
    String? bodyLocation,
    List<EmdrBlsSet>? blsSets,
    String? bodyScanNotes,
    String? closureNotes,
    bool? abreactionOccurred,
    String? abreactionResource,
    String? reevaluationNotes,
    String? clinicianNotes,
    DateTime? updatedAt,
  }) => EmdrSessionTracker(
    id: id,
    patientId: patientId,
    clinicianId: clinicianId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    currentPhase: currentPhase ?? this.currentPhase,
    targetMemory: targetMemory ?? this.targetMemory,
    negativeCognition: negativeCognition ?? this.negativeCognition,
    positiveCognition: positiveCognition ?? this.positiveCognition,
    vocStart: vocStart ?? this.vocStart,
    vocEnd: vocEnd ?? this.vocEnd,
    sudsStart: sudsStart ?? this.sudsStart,
    sudsEnd: sudsEnd ?? this.sudsEnd,
    bodyLocation: bodyLocation ?? this.bodyLocation,
    blsSets: blsSets ?? this.blsSets,
    bodyScanNotes: bodyScanNotes ?? this.bodyScanNotes,
    closureNotes: closureNotes ?? this.closureNotes,
    abreactionOccurred: abreactionOccurred ?? this.abreactionOccurred,
    abreactionResource: abreactionResource ?? this.abreactionResource,
    reevaluationNotes: reevaluationNotes ?? this.reevaluationNotes,
    clinicianNotes: clinicianNotes ?? this.clinicianNotes,
  );

  EmdrSessionTracker withBlsSet(EmdrBlsSet set) =>
      copyWith(blsSets: [...blsSets, set], updatedAt: DateTime.now().toUtc());

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'clinicianId': clinicianId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'currentPhase': currentPhase.id,
    'targetMemory': targetMemory,
    'negativeCognition': negativeCognition,
    'positiveCognition': positiveCognition,
    'vocStart': vocStart,
    'vocEnd': vocEnd,
    'sudsStart': sudsStart,
    'sudsEnd': sudsEnd,
    'bodyLocation': bodyLocation,
    'blsSets': blsSets.map((s) => s.toJson()).toList(),
    'bodyScanNotes': bodyScanNotes,
    'closureNotes': closureNotes,
    'abreactionOccurred': abreactionOccurred,
    'abreactionResource': abreactionResource,
    'reevaluationNotes': reevaluationNotes,
    'clinicianNotes': clinicianNotes,
  };

  @override
  String toString() => 'EmdrSessionTracker(${jsonEncode(toJson())})';
}

class EmdrBlsSet {
  const EmdrBlsSet({
    required this.sequence,
    required this.sudsBefore,
    required this.sudsAfter,
    this.observation = '',
  }) : assert(sudsBefore >= 0 && sudsBefore <= 10),
       assert(sudsAfter >= 0 && sudsAfter <= 10);

  factory EmdrBlsSet.fromJson(Map<String, dynamic> json) => EmdrBlsSet(
    sequence: (json['sequence'] as num?)?.toInt() ?? 0,
    sudsBefore: ((json['sudsBefore'] as num?)?.toInt() ?? 0).clamp(0, 10),
    sudsAfter: ((json['sudsAfter'] as num?)?.toInt() ?? 0).clamp(0, 10),
    observation: json['observation'] as String? ?? '',
  );

  final int sequence;
  final int sudsBefore;
  final int sudsAfter;

  /// Free-text "what came up" — image shifts, body sensations, new
  /// associations. This is the clinical gold for the next channel
  /// of associations.
  final String observation;

  /// True when the set moved SUDS down (or held it stable). Useful
  /// for the panel's per-set trajectory chip.
  bool get movedDown => sudsAfter <= sudsBefore;

  Map<String, dynamic> toJson() => {
    'sequence': sequence,
    'sudsBefore': sudsBefore,
    'sudsAfter': sudsAfter,
    'observation': observation,
  };
}

/// Shapiro's 8 phases. IDs are stable so a partially-decoded JSON
/// record never crashes if a later release renames a phase.
enum EmdrPhase {
  oneHistory(
    'one_history',
    'Client History',
    'Reviewed in the intake phase; surfaced here for completeness.',
  ),
  twoPreparation(
    'two_preparation',
    'Preparation',
    'Resource installation, safe-place exercise, BLS rehearsal.',
  ),
  threeAssessment(
    'three_assessment',
    'Assessment',
    'Target image, NC, PC, baseline VOC + SUDS, body location.',
  ),
  fourDesensitization(
    'four_desensitization',
    'Desensitization',
    'BLS sets until SUDS ≤ 1 (or the channel runs).',
  ),
  fiveInstallation(
    'five_installation',
    'Installation',
    'Install the PC; re-rate VOC. Target VOC 6 or 7.',
  ),
  sixBodyScan(
    'six_body_scan',
    'Body Scan',
    'Hold the target + PC; clear any residual body sensation.',
  ),
  sevenClosure(
    'seven_closure',
    'Closure',
    'Stabilize; no patient leaves the room mid-abreaction.',
  ),
  eightReevaluation(
    'eight_reevaluation',
    'Reevaluation',
    'Next session: check that SUDS held and VOC stayed strong.',
  );

  const EmdrPhase(this.id, this.label, this.description);
  final String id;
  final String label;
  final String description;
}
