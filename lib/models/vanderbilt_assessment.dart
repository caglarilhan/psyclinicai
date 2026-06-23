/// NICHQ Vanderbilt Assessment Scale — ADHD screening for
/// children 6-12. Parent + teacher versions. Public-domain
/// instrument (NICHQ + American Academy of Pediatrics, 2002),
/// so we can ship the full item set unlike licensed Conners /
/// ASEBA scales.
///
/// Each rating runs 0 (Never) / 1 (Occasionally) / 2 (Often) /
/// 3 (Very Often). DSM-5 ADHD criteria require **≥ 6 items
/// scored 2 or 3** in the relevant section + at least one
/// performance-impairment item. The clinician interprets — this
/// model just exposes the symptom-count helpers so the panel
/// renders DSM-correct cutoff badges instead of inventing
/// thresholds.
///
/// Section item counts (parent form — teacher form omits ODD/
/// conduct/anxiety subsets per NICHQ guidance):
///   - **Inattention** items 1-9 (9 items)
///   - **Hyperactivity / Impulsivity** items 10-18 (9 items)
///   - **ODD** items 19-26 (8 items, parent)
///   - **Conduct** items 27-40 (14 items, parent)
///   - **Anxiety / Depression** items 41-47 (7 items, parent)
///   - **Performance** P1-P8 (school + interpersonal,
///     1=above average → 5=problematic)
library;

import 'dart:convert';

enum VanderbiltRespondent {
  parent('parent'),
  teacher('teacher');

  const VanderbiltRespondent(this.id);
  final String id;

  static VanderbiltRespondent fromId(String? id) => VanderbiltRespondent.values
      .firstWhere((r) => r.id == id, orElse: () => VanderbiltRespondent.parent);
}

/// DSM-5 ADHD presentation subtypes derivable from the cutoff
/// helper. The official tool reports inattentive / hyperactive /
/// combined; "none" is what the helper returns when neither side
/// meets the 6-item bar.
enum VanderbiltSubtype {
  none('none'),
  inattentive('inattentive'),
  hyperactiveImpulsive('hyperactive_impulsive'),
  combined('combined');

  const VanderbiltSubtype(this.id);
  final String id;
}

class VanderbiltAssessment {
  VanderbiltAssessment({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.respondent,
    required this.capturedAt,
    this.inattention = const [],
    this.hyperactivity = const [],
    this.oppositional = const [],
    this.conduct = const [],
    this.anxietyDepression = const [],
    this.performance = const [],
    this.notes = '',
  }) : assert(inattention.isEmpty || inattention.length == 9),
       assert(hyperactivity.isEmpty || hyperactivity.length == 9),
       assert(oppositional.isEmpty || oppositional.length == 8),
       assert(conduct.isEmpty || conduct.length == 14),
       assert(anxietyDepression.isEmpty || anxietyDepression.length == 7),
       assert(performance.isEmpty || performance.length == 8);

  factory VanderbiltAssessment.fromJson(Map<String, dynamic> json) {
    List<int> ints(Object? raw, int expectedLen) {
      if (raw is! List) return const [];
      final out = <int>[];
      for (final v in raw) {
        if (v is num) out.add(v.toInt().clamp(0, 5));
      }
      if (out.isEmpty) return const [];
      // Resize to the expected length so the assertion contract
      // holds. Pad with zeros (sane default = "Never"); trim
      // surplus.
      if (out.length < expectedLen) {
        return [...out, ...List<int>.filled(expectedLen - out.length, 0)];
      }
      return out.sublist(0, expectedLen);
    }

    return VanderbiltAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      clinicianId: json['clinicianId'] as String? ?? '',
      respondent: VanderbiltRespondent.fromId(json['respondent'] as String?),
      capturedAt:
          DateTime.tryParse(json['capturedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      inattention: ints(json['inattention'], 9),
      hyperactivity: ints(json['hyperactivity'], 9),
      oppositional: ints(json['oppositional'], 8),
      conduct: ints(json['conduct'], 14),
      anxietyDepression: ints(json['anxietyDepression'], 7),
      performance: ints(json['performance'], 8),
      notes: json['notes'] as String? ?? '',
    );
  }

  final String id;
  final String patientId;
  final String clinicianId;
  final VanderbiltRespondent respondent;
  final DateTime capturedAt;

  /// 9 inattention items, each 0-3. Symptomatic = scored 2 or 3
  /// per the DSM-5 / Vanderbilt instructions.
  final List<int> inattention;
  final List<int> hyperactivity;
  final List<int> oppositional;
  final List<int> conduct;
  final List<int> anxietyDepression;

  /// 8 performance items (academic + interpersonal). 1 = above
  /// average, 5 = problematic. DSM-5 functional-impairment
  /// criterion: at least one item scored 4 or 5.
  final List<int> performance;

  final String notes;

  static int _symptomCount(List<int> items) =>
      items.where((v) => v >= 2).length;

  /// DSM-5: ≥ 6 inattention items rated 2/3.
  int get inattentionSymptomCount => _symptomCount(inattention);
  bool get meetsInattentionThreshold => inattentionSymptomCount >= 6;

  /// DSM-5: ≥ 6 hyperactive/impulsive items rated 2/3.
  int get hyperactivitySymptomCount => _symptomCount(hyperactivity);
  bool get meetsHyperactivityThreshold => hyperactivitySymptomCount >= 6;

  /// Vanderbilt ODD positive screen — ≥ 4 items at 2/3.
  int get oppositionalSymptomCount => _symptomCount(oppositional);
  bool get oppositionalPositiveScreen => oppositionalSymptomCount >= 4;

  /// Vanderbilt conduct positive screen — ≥ 3 items at 2/3.
  int get conductSymptomCount => _symptomCount(conduct);
  bool get conductPositiveScreen => conductSymptomCount >= 3;

  /// Vanderbilt anxiety/depression positive screen — ≥ 3 items
  /// at 2/3.
  int get anxietyDepressionSymptomCount => _symptomCount(anxietyDepression);
  bool get anxietyDepressionPositiveScreen =>
      anxietyDepressionSymptomCount >= 3;

  /// At least one performance domain rated 4 or 5 — required for
  /// any positive ADHD subtype.
  bool get hasFunctionalImpairment => performance.any((v) => v >= 4);

  /// DSM-5 / NICHQ subtype call. Returns `none` when functional
  /// impairment is missing (DSM requires both symptom count AND
  /// impairment to call a subtype).
  VanderbiltSubtype get subtype {
    if (!hasFunctionalImpairment) return VanderbiltSubtype.none;
    final inattn = meetsInattentionThreshold;
    final hyper = meetsHyperactivityThreshold;
    if (inattn && hyper) return VanderbiltSubtype.combined;
    if (inattn) return VanderbiltSubtype.inattentive;
    if (hyper) return VanderbiltSubtype.hyperactiveImpulsive;
    return VanderbiltSubtype.none;
  }

  VanderbiltAssessment copyWith({
    List<int>? inattention,
    List<int>? hyperactivity,
    List<int>? oppositional,
    List<int>? conduct,
    List<int>? anxietyDepression,
    List<int>? performance,
    String? notes,
  }) => VanderbiltAssessment(
    id: id,
    patientId: patientId,
    clinicianId: clinicianId,
    respondent: respondent,
    capturedAt: capturedAt,
    inattention: inattention ?? this.inattention,
    hyperactivity: hyperactivity ?? this.hyperactivity,
    oppositional: oppositional ?? this.oppositional,
    conduct: conduct ?? this.conduct,
    anxietyDepression: anxietyDepression ?? this.anxietyDepression,
    performance: performance ?? this.performance,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'clinicianId': clinicianId,
    'respondent': respondent.id,
    'capturedAt': capturedAt.toIso8601String(),
    'inattention': inattention,
    'hyperactivity': hyperactivity,
    'oppositional': oppositional,
    'conduct': conduct,
    'anxietyDepression': anxietyDepression,
    'performance': performance,
    'notes': notes,
  };

  @override
  String toString() => 'VanderbiltAssessment(${jsonEncode(toJson())})';
}
