/// DBT Diary Card — Marsha Linehan's adult standard card,
/// 7-day weekly format.
///
/// Captures three layers per day:
///   1. **Target behaviors** — clinician-configured per patient
///      (suicidal ideation 0-5, NSSI urge 0-5, NSSI acts y/n,
///      substance use, eating issues, treatment-interfering
///      behavior). Stored as a Map keyed by behaviour id so the
///      list can grow without breaking older records.
///   2. **Emotions** — 6 core emotions rated 0-5 (sadness, anger,
///      fear, shame, joy, love). Optional discrete extras
///      (guilt / disgust / envy / jealousy) live as
///      free-text-keyed entries.
///   3. **Skills used** — 15 DBT skills across the four modules
///      (Mindfulness, Distress Tolerance, Emotion Regulation,
///      Interpersonal Effectiveness). Skill `Set` semantics —
///      either the skill was practised that day or it wasn't.
///
/// Persistence: JSON-serialised through
/// `ModalitySessionRepository`. The weekly view is the unit of
/// reflection — clinicians flip back to last week to coach the
/// pattern, not just yesterday.
library;

import 'dart:convert';

class DbtDiaryCard {
  DbtDiaryCard({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.weekStart,
    required this.days,
    this.targetBehaviors = const [],
    this.clinicianNotes = '',
  }) : assert(
         days.length == 7,
         'Diary card must hold exactly 7 daily entries',
       );

  factory DbtDiaryCard.fromJson(Map<String, dynamic> json) => DbtDiaryCard(
    id: json['id'] as String,
    patientId: json['patientId'] as String? ?? '',
    clinicianId: json['clinicianId'] as String? ?? '',
    weekStart:
        DateTime.tryParse(json['weekStart'] as String? ?? '') ??
        _mondayOf(DateTime.now().toUtc()),
    days: _decodeDays(json['days'], json['weekStart']),
    targetBehaviors: _decodeTargets(json['targetBehaviors']),
    clinicianNotes: json['clinicianNotes'] as String? ?? '',
  );

  /// Empty 7-day card for a fresh week, with default target
  /// behaviours from `DbtTargetBehavior.defaults`. Use this when the
  /// clinician opens a brand-new card.
  factory DbtDiaryCard.blank({
    required String id,
    required String patientId,
    required String clinicianId,
    DateTime? weekOf,
  }) {
    final start = _mondayOf((weekOf ?? DateTime.now()).toUtc());
    return DbtDiaryCard(
      id: id,
      patientId: patientId,
      clinicianId: clinicianId,
      weekStart: start,
      days: List.generate(
        7,
        (i) => DbtDailyEntry.blank(start.add(Duration(days: i))),
      ),
      targetBehaviors: DbtTargetBehavior.defaults,
    );
  }

  /// Linehan's card runs Monday → Sunday for clinical
  /// consistency. We snap any provided date back to its week's
  /// Monday, UTC, midnight.
  static DateTime _mondayOf(DateTime d) {
    final utc = d.toUtc();
    final delta = (utc.weekday - DateTime.monday) % 7;
    final monday = utc.subtract(Duration(days: delta));
    return DateTime.utc(monday.year, monday.month, monday.day);
  }

  static List<DbtDailyEntry> _decodeDays(Object? raw, Object? weekStartRaw) {
    final weekStart =
        DateTime.tryParse(weekStartRaw as String? ?? '') ??
        _mondayOf(DateTime.now().toUtc());
    if (raw is! List) {
      return List.generate(
        7,
        (i) => DbtDailyEntry.blank(weekStart.add(Duration(days: i))),
      );
    }
    final out = <DbtDailyEntry>[];
    for (var i = 0; i < raw.length && i < 7; i++) {
      final entry = raw[i];
      if (entry is Map<String, dynamic>) {
        out.add(DbtDailyEntry.fromJson(entry));
      } else if (entry is Map) {
        out.add(DbtDailyEntry.fromJson(Map<String, dynamic>.from(entry)));
      } else {
        out.add(DbtDailyEntry.blank(weekStart.add(Duration(days: i))));
      }
    }
    while (out.length < 7) {
      out.add(DbtDailyEntry.blank(weekStart.add(Duration(days: out.length))));
    }
    return out;
  }

  static List<DbtTargetBehavior> _decodeTargets(Object? raw) {
    if (raw is! List) return DbtTargetBehavior.defaults;
    final out = <DbtTargetBehavior>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        out.add(DbtTargetBehavior.fromJson(item));
      } else if (item is Map) {
        out.add(DbtTargetBehavior.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return out.isEmpty ? DbtTargetBehavior.defaults : out;
  }

  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime weekStart;
  final List<DbtDailyEntry> days;
  final List<DbtTargetBehavior> targetBehaviors;
  final String clinicianNotes;

  /// Days the patient logged anything (used to compute the
  /// "completion %" pill in the panel).
  int get filledDays => days.where((d) => d.hasAnyData).length;

  /// 7-day SI peak (highest suicidal-ideation rating across the
  /// week). Anchored to behaviour id `si` — Linehan's standard
  /// label.
  int get suicidalIdeationPeakOfWeek {
    var peak = 0;
    for (final d in days) {
      final v = d.targetBehaviorRatings['si'] ?? 0;
      if (v > peak) peak = v;
    }
    return peak;
  }

  /// Has the patient logged a self-harm act this week?
  bool get selfHarmActOccurred =>
      days.any((d) => (d.targetBehaviorRatings['sh_act'] ?? 0) > 0);

  DbtDiaryCard copyWith({
    List<DbtDailyEntry>? days,
    List<DbtTargetBehavior>? targetBehaviors,
    String? clinicianNotes,
  }) => DbtDiaryCard(
    id: id,
    patientId: patientId,
    clinicianId: clinicianId,
    weekStart: weekStart,
    days: days ?? this.days,
    targetBehaviors: targetBehaviors ?? this.targetBehaviors,
    clinicianNotes: clinicianNotes ?? this.clinicianNotes,
  );

  /// Replace a single day's entry by date (atomic; preserves order).
  DbtDiaryCard withDay(DbtDailyEntry updated) {
    final next = [
      for (final d in days)
        if (d.date.toUtc().year == updated.date.toUtc().year &&
            d.date.toUtc().month == updated.date.toUtc().month &&
            d.date.toUtc().day == updated.date.toUtc().day)
          updated
        else
          d,
    ];
    return copyWith(days: next);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'clinicianId': clinicianId,
    'weekStart': weekStart.toIso8601String(),
    'days': days.map((d) => d.toJson()).toList(),
    'targetBehaviors': targetBehaviors.map((t) => t.toJson()).toList(),
    'clinicianNotes': clinicianNotes,
  };

  @override
  String toString() => 'DbtDiaryCard(${jsonEncode(toJson())})';
}

class DbtDailyEntry {
  const DbtDailyEntry({
    required this.date,
    this.targetBehaviorRatings = const {},
    this.emotionRatings = const {},
    this.skillsUsed = const {},
    this.notes = '',
  });

  factory DbtDailyEntry.blank(DateTime date) => DbtDailyEntry(date: date);

  factory DbtDailyEntry.fromJson(Map<String, dynamic> json) {
    final targets = <String, int>{};
    final rawTargets = json['targetBehaviorRatings'];
    if (rawTargets is Map) {
      for (final entry in rawTargets.entries) {
        final v = entry.value;
        if (v is num) targets[entry.key.toString()] = v.toInt().clamp(0, 5);
      }
    }
    final emotions = <DbtEmotion, int>{};
    final rawEmotions = json['emotionRatings'];
    if (rawEmotions is Map) {
      for (final entry in rawEmotions.entries) {
        final hit = DbtEmotion.values
            .where((e) => e.id == entry.key.toString())
            .toList();
        final v = entry.value;
        if (hit.isNotEmpty && v is num) {
          emotions[hit.first] = v.toInt().clamp(0, 5);
        }
      }
    }
    final skills = <DbtSkill>{};
    final rawSkills = json['skillsUsed'];
    if (rawSkills is List) {
      for (final v in rawSkills) {
        final hit = DbtSkill.values.where((s) => s.id == v).toList();
        if (hit.isNotEmpty) skills.add(hit.first);
      }
    }
    return DbtDailyEntry(
      date:
          DateTime.tryParse(json['date'] as String? ?? '') ??
          DateTime.now().toUtc(),
      targetBehaviorRatings: targets,
      emotionRatings: emotions,
      skillsUsed: skills,
      notes: json['notes'] as String? ?? '',
    );
  }

  final DateTime date;
  final Map<String, int> targetBehaviorRatings;
  final Map<DbtEmotion, int> emotionRatings;
  final Set<DbtSkill> skillsUsed;
  final String notes;

  bool get hasAnyData =>
      targetBehaviorRatings.isNotEmpty ||
      emotionRatings.isNotEmpty ||
      skillsUsed.isNotEmpty ||
      notes.trim().isNotEmpty;

  DbtDailyEntry copyWith({
    Map<String, int>? targetBehaviorRatings,
    Map<DbtEmotion, int>? emotionRatings,
    Set<DbtSkill>? skillsUsed,
    String? notes,
  }) => DbtDailyEntry(
    date: date,
    targetBehaviorRatings:
        targetBehaviorRatings ?? this.targetBehaviorRatings,
    emotionRatings: emotionRatings ?? this.emotionRatings,
    skillsUsed: skillsUsed ?? this.skillsUsed,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'targetBehaviorRatings': targetBehaviorRatings,
    'emotionRatings': {
      for (final entry in emotionRatings.entries) entry.key.id: entry.value,
    },
    'skillsUsed': skillsUsed.map((s) => s.id).toList(),
    'notes': notes,
  };
}

class DbtTargetBehavior {
  const DbtTargetBehavior({
    required this.id,
    required this.label,
    required this.isUrge,
    this.helpText = '',
  });

  factory DbtTargetBehavior.fromJson(Map<String, dynamic> json) =>
      DbtTargetBehavior(
        id: json['id'] as String,
        label: json['label'] as String? ?? '',
        isUrge: json['isUrge'] as bool? ?? true,
        helpText: json['helpText'] as String? ?? '',
      );

  final String id;
  final String label;

  /// `true` for ratable urges (0-5 intensity), `false` for
  /// y/n action checks (still stored 0/1).
  final bool isUrge;
  final String helpText;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'isUrge': isUrge,
    'helpText': helpText,
  };

  /// Linehan's default adult-card targets — clinician can add/remove
  /// per patient (e.g. add "Binge eating" for BED, "Purging" for BN).
  static const defaults = <DbtTargetBehavior>[
    DbtTargetBehavior(
      id: 'si',
      label: 'Suicidal ideation',
      isUrge: true,
      helpText:
          'Rate 0-5 — fleeting through to specific plan with intent.',
    ),
    DbtTargetBehavior(
      id: 'sh_urge',
      label: 'Self-harm urge',
      isUrge: true,
      helpText: 'NSSI urge intensity, regardless of whether acted upon.',
    ),
    DbtTargetBehavior(
      id: 'sh_act',
      label: 'Self-harm act',
      isUrge: false,
      helpText: 'Did NSSI happen today? 0 = no, 1 = yes.',
    ),
    DbtTargetBehavior(
      id: 'substance',
      label: 'Substance use',
      isUrge: true,
      helpText: '0 = none, 5 = severe / intoxication.',
    ),
    DbtTargetBehavior(
      id: 'tib',
      label: 'Treatment-interfering behaviour',
      isUrge: true,
      helpText:
          'Late / missed session, withholding, attacking the therapy frame.',
    ),
  ];
}

/// Linehan's 6 core emotions + a small extension set for clinicians
/// who want finer granularity. Order is stable for the panel grid.
enum DbtEmotion {
  sadness('sadness', 'Sadness'),
  anger('anger', 'Anger'),
  fear('fear', 'Fear'),
  shame('shame', 'Shame'),
  guilt('guilt', 'Guilt'),
  joy('joy', 'Joy'),
  love('love', 'Love');

  const DbtEmotion(this.id, this.label);
  final String id;
  final String label;
}

/// 15 DBT skills across Linehan's four modules. ID is stable; label
/// matches the skills-manual short name. Module groupings live in
/// [module] so the panel can render them as section chips.
enum DbtSkill {
  // Mindfulness
  observe('observe', 'Observe', DbtSkillModule.mindfulness),
  describe('describe', 'Describe', DbtSkillModule.mindfulness),
  participate('participate', 'Participate', DbtSkillModule.mindfulness),
  oneMindfully('one_mindfully', 'One-mindfully', DbtSkillModule.mindfulness),

  // Distress Tolerance
  tip('tip', 'TIP', DbtSkillModule.distressTolerance),
  selfSoothe('self_soothe', 'Self-soothe', DbtSkillModule.distressTolerance),
  improve('improve', 'IMPROVE', DbtSkillModule.distressTolerance),
  radicalAcceptance(
    'radical_acceptance',
    'Radical Acceptance',
    DbtSkillModule.distressTolerance,
  ),

  // Emotion Regulation
  oppositeAction(
    'opposite_action',
    'Opposite Action',
    DbtSkillModule.emotionRegulation,
  ),
  checkTheFacts(
    'check_the_facts',
    'Check the Facts',
    DbtSkillModule.emotionRegulation,
  ),
  problemSolving(
    'problem_solving',
    'Problem Solving',
    DbtSkillModule.emotionRegulation,
  ),
  please('please', 'PLEASE', DbtSkillModule.emotionRegulation),

  // Interpersonal Effectiveness
  dearMan('dear_man', 'DEAR MAN', DbtSkillModule.interpersonal),
  give('give', 'GIVE', DbtSkillModule.interpersonal),
  fast('fast', 'FAST', DbtSkillModule.interpersonal);

  const DbtSkill(this.id, this.label, this.module);
  final String id;
  final String label;
  final DbtSkillModule module;
}

enum DbtSkillModule {
  mindfulness('Mindfulness'),
  distressTolerance('Distress Tolerance'),
  emotionRegulation('Emotion Regulation'),
  interpersonal('Interpersonal Effectiveness');

  const DbtSkillModule(this.label);
  final String label;
}
