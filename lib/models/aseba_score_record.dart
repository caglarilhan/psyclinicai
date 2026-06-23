/// ASEBA (Achenbach System of Empirically Based Assessment)
/// score-only record. The CBCL / TRF / YSR forms are proprietary
/// — we cannot ship the items — but clinicians routinely score
/// the paper / official-tool output externally and bring the
/// T-scores back into the chart for trending. This model captures
/// just the T-scores so the dashboard can chart change over time
/// without infringing on the licensed item set.
///
/// Three form variants: CBCL/6-18 (parent), TRF (teacher), YSR
/// (youth self-report 11-18). Each form produces:
///   - 8 syndrome scale T-scores (anxious-depressed, withdrawn,
///     somatic complaints, social problems, thought problems,
///     attention problems, rule-breaking behaviour, aggressive
///     behaviour),
///   - 6 DSM-oriented scale T-scores (depressive, anxiety,
///     somatic, ADHD, oppositional defiant, conduct),
///   - 3 broad-band composites (internalising, externalising,
///     total problems).
///
/// Cutoff bands per Achenbach & Rescorla (2001):
///   T < 65 = normal
///   T 65-69 = borderline
///   T >= 70 = clinical (subscales)
///   T < 60 normal, 60-63 borderline, >= 64 clinical (composites)
library;

import 'dart:convert';

/// Which paper-form the externally-computed T-scores came from.
enum AsebaForm {
  cbclParent('cbcl_parent_6_18', 'CBCL / 6-18 (parent)'),
  trfTeacher('trf_teacher', 'TRF (teacher)'),
  ysrYouth('ysr_11_18', 'YSR (youth self-report)');

  const AsebaForm(this.id, this.label);
  final String id;
  final String label;

  static AsebaForm fromId(String? id) => AsebaForm.values.firstWhere(
    (f) => f.id == id,
    orElse: () => AsebaForm.cbclParent,
  );
}

/// 8 syndrome scales — the empirically-derived dimensions ASEBA
/// is best known for. Same set across all three forms.
enum AsebaSyndromeScale {
  anxiousDepressed('anxious_depressed', 'Anxious/Depressed'),
  withdrawn('withdrawn', 'Withdrawn/Depressed'),
  somaticComplaints('somatic_complaints', 'Somatic Complaints'),
  socialProblems('social_problems', 'Social Problems'),
  thoughtProblems('thought_problems', 'Thought Problems'),
  attentionProblems('attention_problems', 'Attention Problems'),
  ruleBreaking('rule_breaking', 'Rule-Breaking Behavior'),
  aggressive('aggressive', 'Aggressive Behavior');

  const AsebaSyndromeScale(this.id, this.label);
  final String id;
  final String label;

  static AsebaSyndromeScale? fromId(String id) {
    for (final s in values) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// 6 DSM-oriented scales — items regrouped to map onto DSM-5
/// categories. Useful when reading the chart against a working
/// diagnosis.
enum AsebaDsmScale {
  depressive('depressive', 'Depressive Problems'),
  anxiety('anxiety', 'Anxiety Problems'),
  somaticDsm('somatic_dsm', 'Somatic Problems'),
  adhd('adhd', 'ADHD Problems'),
  oppositionalDefiant('odd', 'Oppositional Defiant Problems'),
  conduct('conduct', 'Conduct Problems');

  const AsebaDsmScale(this.id, this.label);
  final String id;
  final String label;

  static AsebaDsmScale? fromId(String id) {
    for (final s in values) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// Broad-band composites. Different cutoff bands than the
/// subscales (60-63 borderline, 64+ clinical).
enum AsebaCompositeScale {
  internalising('internalising', 'Internalising'),
  externalising('externalising', 'Externalising'),
  totalProblems('total_problems', 'Total Problems');

  const AsebaCompositeScale(this.id, this.label);
  final String id;
  final String label;

  static AsebaCompositeScale? fromId(String id) {
    for (final s in values) {
      if (s.id == id) return s;
    }
    return null;
  }
}

enum AsebaBand { normal, borderline, clinical }

class AsebaScoreRecord {
  AsebaScoreRecord({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.form,
    required this.capturedAt,
    Map<AsebaSyndromeScale, int>? syndromeT,
    Map<AsebaDsmScale, int>? dsmT,
    Map<AsebaCompositeScale, int>? compositeT,
    this.notes = '',
  }) : syndromeT = Map.unmodifiable(syndromeT ?? const {}),
       dsmT = Map.unmodifiable(dsmT ?? const {}),
       compositeT = Map.unmodifiable(compositeT ?? const {});

  factory AsebaScoreRecord.fromJson(Map<String, dynamic> json) {
    Map<T, int> readMap<T>(Object? raw, T? Function(String) lookup) {
      final out = <T, int>{};
      if (raw is Map) {
        for (final entry in raw.entries) {
          final v = entry.value;
          if (v is! num) continue;
          final t = lookup(entry.key.toString());
          if (t == null) continue;
          out[t] = v.toInt().clamp(0, 100);
        }
      }
      return out;
    }

    return AsebaScoreRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      clinicianId: json['clinicianId'] as String? ?? '',
      form: AsebaForm.fromId(json['form'] as String?),
      capturedAt:
          DateTime.tryParse(json['capturedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      syndromeT: readMap(json['syndromeT'], AsebaSyndromeScale.fromId),
      dsmT: readMap(json['dsmT'], AsebaDsmScale.fromId),
      compositeT: readMap(json['compositeT'], AsebaCompositeScale.fromId),
      notes: json['notes'] as String? ?? '',
    );
  }

  final String id;
  final String patientId;
  final String clinicianId;
  final AsebaForm form;
  final DateTime capturedAt;

  /// T-scores per syndrome scale. Standardised 0-100 with mean 50
  /// and SD 10 by ASEBA convention. Missing scales = "not entered".
  final Map<AsebaSyndromeScale, int> syndromeT;
  final Map<AsebaDsmScale, int> dsmT;
  final Map<AsebaCompositeScale, int> compositeT;
  final String notes;

  /// Achenbach & Rescorla (2001) cutoffs for the 8 syndrome scales
  /// and the 6 DSM-oriented scales: T < 65 normal, 65-69 borderline,
  /// >= 70 clinical.
  static AsebaBand subscaleBand(int t) {
    if (t >= 70) return AsebaBand.clinical;
    if (t >= 65) return AsebaBand.borderline;
    return AsebaBand.normal;
  }

  /// Composite bands use a tighter cutoff: T < 60 normal,
  /// 60-63 borderline, >= 64 clinical.
  static AsebaBand compositeBand(int t) {
    if (t >= 64) return AsebaBand.clinical;
    if (t >= 60) return AsebaBand.borderline;
    return AsebaBand.normal;
  }

  /// Counts how many syndrome scales sit at or above clinical
  /// cutoff. Used by the outcomes dashboard to flag "elevated".
  int get syndromeClinicalCount => syndromeT.values
      .where((t) => subscaleBand(t) == AsebaBand.clinical)
      .length;

  int get dsmClinicalCount =>
      dsmT.values.where((t) => subscaleBand(t) == AsebaBand.clinical).length;

  bool get totalProblemsClinical {
    final t = compositeT[AsebaCompositeScale.totalProblems];
    return t != null && compositeBand(t) == AsebaBand.clinical;
  }

  AsebaScoreRecord copyWith({
    Map<AsebaSyndromeScale, int>? syndromeT,
    Map<AsebaDsmScale, int>? dsmT,
    Map<AsebaCompositeScale, int>? compositeT,
    String? notes,
  }) => AsebaScoreRecord(
    id: id,
    patientId: patientId,
    clinicianId: clinicianId,
    form: form,
    capturedAt: capturedAt,
    syndromeT: syndromeT ?? this.syndromeT,
    dsmT: dsmT ?? this.dsmT,
    compositeT: compositeT ?? this.compositeT,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'clinicianId': clinicianId,
    'form': form.id,
    'capturedAt': capturedAt.toIso8601String(),
    'syndromeT': {for (final e in syndromeT.entries) e.key.id: e.value},
    'dsmT': {for (final e in dsmT.entries) e.key.id: e.value},
    'compositeT': {for (final e in compositeT.entries) e.key.id: e.value},
    'notes': notes,
  };

  @override
  String toString() => 'AsebaScoreRecord(${jsonEncode(toJson())})';
}
