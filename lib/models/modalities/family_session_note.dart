/// Family-therapy session note — McGoldrick / Bowen / structural
/// vocabulary, tied to a genogram so the clinician can mark which
/// family members attended, which subsystem they worked with, and
/// what shift (if any) the session produced.
///
/// Captured per-session by the family-therapy panel. Persisted via
/// the modality session repository's tagged envelope (kind:
/// `family`). The clinician picks a `FamilyTherapyApproach` (Bowen,
/// structural, narrative, etc.), records the subsystem worked with,
/// optional homework, and a `relationalShift` rating that mirrors
/// SUDS-style 0-10 self-report ("how different did this session
/// feel?").
library;

import 'dart:convert';

/// Major family-therapy schools — narrow on purpose. The clinician
/// picks the lens that drove this session; downstream outcomes
/// charts can filter by approach.
enum FamilyTherapyApproach {
  bowen('bowen', 'Bowen / multigenerational'),
  structural('structural', 'Structural (Minuchin)'),
  strategic('strategic', 'Strategic (Haley / Madanes)'),
  narrative('narrative', 'Narrative (White / Epston)'),
  emotionallyFocused('eft', 'Emotionally focused (EFT)'),
  systemic('systemic', 'Systemic / Milan'),
  integrative('integrative', 'Integrative / eclectic');

  const FamilyTherapyApproach(this.id, this.label);
  final String id;
  final String label;

  static FamilyTherapyApproach fromId(String? id) =>
      FamilyTherapyApproach.values.firstWhere(
        (a) => a.id == id,
        orElse: () => FamilyTherapyApproach.integrative,
      );
}

/// Which slice of the family system was the focus of this session.
/// Captured for outcomes reporting + because the same family can
/// come back for couple work one week and parent-child the next.
enum FamilySubsystem {
  couple('couple'),
  parentChild('parent_child'),
  sibling('sibling'),
  wholeFamily('whole_family'),
  extended('extended');

  const FamilySubsystem(this.id);
  final String id;

  static FamilySubsystem fromId(String? id) => FamilySubsystem.values
      .firstWhere((s) => s.id == id, orElse: () => FamilySubsystem.wholeFamily);
}

class FamilySessionNote {
  FamilySessionNote({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.sessionDate,
    this.approach = FamilyTherapyApproach.integrative,
    this.subsystem = FamilySubsystem.wholeFamily,
    this.attendees = const [],
    this.genogramId = '',
    this.presentingDynamic = '',
    this.interventions = '',
    this.homework = '',
    this.relationalShift = 0,
    this.notes = '',
  });

  factory FamilySessionNote.fromJson(Map<String, dynamic> json) {
    final rawAttendees = json['attendees'];
    final attendees = <String>[];
    if (rawAttendees is List) {
      for (final a in rawAttendees) {
        if (a is String) attendees.add(a);
      }
    }
    return FamilySessionNote(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      clinicianId: json['clinicianId'] as String? ?? '',
      sessionDate:
          DateTime.tryParse(json['sessionDate'] as String? ?? '') ??
          DateTime.now().toUtc(),
      approach: FamilyTherapyApproach.fromId(json['approach'] as String?),
      subsystem: FamilySubsystem.fromId(json['subsystem'] as String?),
      attendees: attendees,
      genogramId: json['genogramId'] as String? ?? '',
      presentingDynamic: json['presentingDynamic'] as String? ?? '',
      interventions: json['interventions'] as String? ?? '',
      homework: json['homework'] as String? ?? '',
      relationalShift: ((json['relationalShift'] as num?)?.toInt() ?? 0).clamp(
        0,
        10,
      ),
      notes: json['notes'] as String? ?? '',
    );
  }

  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime sessionDate;

  final FamilyTherapyApproach approach;
  final FamilySubsystem subsystem;

  /// IDs of the `GenogramPerson` rows that physically attended
  /// this session (subset of `Genogram.people`). When the note
  /// stands alone (no genogram yet), the list can hold ad-hoc
  /// strings — UI shows them as plain chips.
  final List<String> attendees;

  /// Pointer to the family's `Genogram` document. Empty string
  /// when no genogram has been built yet.
  final String genogramId;

  /// One-line summary of the dynamic the family arrived with.
  /// Free-text — the clinician's lens drives this.
  final String presentingDynamic;
  final String interventions;
  final String homework;

  /// 0-10 self-reported relational shift at session end ("how
  /// different does the family feel vs. session start?"). Mirrors
  /// SUDS-style 0-10 so dashboards can chart it next to EMDR /
  /// FIT scores.
  final int relationalShift;

  final String notes;

  /// "Complete enough to keep" — gate the save indicator. We want
  /// at least an approach, a subsystem, and either presenting
  /// dynamic or interventions documented. Stays loose on purpose.
  bool get isComplete =>
      presentingDynamic.trim().isNotEmpty || interventions.trim().isNotEmpty;

  /// True when a relational shift was actually recorded
  /// (clinician moved the slider). Used by outcomes to filter out
  /// zero-default rows.
  bool get hasShiftRecorded => relationalShift > 0;

  FamilySessionNote copyWith({
    FamilyTherapyApproach? approach,
    FamilySubsystem? subsystem,
    List<String>? attendees,
    String? genogramId,
    String? presentingDynamic,
    String? interventions,
    String? homework,
    int? relationalShift,
    String? notes,
  }) => FamilySessionNote(
    id: id,
    patientId: patientId,
    clinicianId: clinicianId,
    sessionDate: sessionDate,
    approach: approach ?? this.approach,
    subsystem: subsystem ?? this.subsystem,
    attendees: attendees ?? this.attendees,
    genogramId: genogramId ?? this.genogramId,
    presentingDynamic: presentingDynamic ?? this.presentingDynamic,
    interventions: interventions ?? this.interventions,
    homework: homework ?? this.homework,
    relationalShift: relationalShift ?? this.relationalShift,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'clinicianId': clinicianId,
    'sessionDate': sessionDate.toIso8601String(),
    'approach': approach.id,
    'subsystem': subsystem.id,
    'attendees': attendees,
    'genogramId': genogramId,
    'presentingDynamic': presentingDynamic,
    'interventions': interventions,
    'homework': homework,
    'relationalShift': relationalShift,
    'notes': notes,
  };

  @override
  String toString() => 'FamilySessionNote(${jsonEncode(toJson())})';
}
