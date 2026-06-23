/// 3-generation genogram model — McGoldrick / Gerson standard
/// notation, adapted for digital capture.
///
/// A genogram is the family-therapy clinician's working document
/// — it holds people (with mental-health pattern flags), the
/// relationships between them, and the patterns the clinician
/// sees (alcohol misuse on the paternal side, depression in two
/// generations, etc.). Most therapists draw it on paper; this
/// model lets us capture it structurally so the visual canvas
/// (separate sprint) renders it deterministically.
///
/// Persisted by `GenogramRepository` (SharedPreferences).
library;

import 'dart:convert';

enum GenogramSex {
  female('female'),
  male('male'),
  nonBinary('nonbinary'),
  unknown('unknown');

  const GenogramSex(this.id);
  final String id;

  static GenogramSex fromId(String? id) => GenogramSex.values.firstWhere(
    (s) => s.id == id,
    orElse: () => GenogramSex.unknown,
  );
}

/// McGoldrick / Gerson "noteworthy attribute" flags — surfaced
/// as small icons on the canvas next to each person. Multi-select;
/// a person can carry several.
enum GenogramAttribute {
  depression('depression', 'Depression'),
  anxiety('anxiety', 'Anxiety'),
  bipolar('bipolar', 'Bipolar disorder'),
  psychosis('psychosis', 'Psychosis'),
  substanceMisuse('substance_misuse', 'Substance misuse'),
  alcoholMisuse('alcohol_misuse', 'Alcohol misuse'),
  trauma('trauma', 'Trauma history'),
  suicide('suicide', 'Suicide'),
  selfHarm('self_harm', 'Self-harm history'),
  chronicMedical('chronic_medical', 'Chronic medical illness'),
  abuseSurvivor('abuse_survivor', 'Abuse survivor'),
  abusePerpetrator('abuse_perpetrator', 'Abuse perpetrator'),
  closeBond('close_bond', 'Close emotional bond'),
  conflict('conflict', 'Conflicted relationship'),
  estranged('estranged', 'Estranged');

  const GenogramAttribute(this.id, this.label);
  final String id;
  final String label;

  static GenogramAttribute? fromId(String id) {
    for (final a in values) {
      if (a.id == id) return a;
    }
    return null;
  }
}

enum GenogramRelationshipKind {
  parentChild('parent_child'),
  sibling('sibling'),
  marriage('marriage'),
  partnership('partnership'),
  divorce('divorce'),
  separation('separation'),
  adoption('adoption'),
  closeFriend('close_friend'),
  estrangement('estrangement'),
  conflict('conflict');

  const GenogramRelationshipKind(this.id);
  final String id;

  static GenogramRelationshipKind fromId(String? id) =>
      GenogramRelationshipKind.values.firstWhere(
        (k) => k.id == id,
        orElse: () => GenogramRelationshipKind.parentChild,
      );
}

class GenogramPerson {
  const GenogramPerson({
    required this.id,
    required this.label,
    this.sex = GenogramSex.unknown,
    this.birthYear,
    this.deathYear,
    this.isIndexPatient = false,
    this.attributes = const [],
    this.notes = '',
  });

  factory GenogramPerson.fromJson(Map<String, dynamic> json) {
    final raw = json['attributes'];
    final attrs = <GenogramAttribute>[];
    if (raw is List) {
      for (final v in raw) {
        if (v is String) {
          final a = GenogramAttribute.fromId(v);
          if (a != null) attrs.add(a);
        }
      }
    }
    return GenogramPerson(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      sex: GenogramSex.fromId(json['sex'] as String?),
      birthYear: (json['birthYear'] as num?)?.toInt(),
      deathYear: (json['deathYear'] as num?)?.toInt(),
      isIndexPatient: json['isIndexPatient'] as bool? ?? false,
      attributes: attrs,
      notes: json['notes'] as String? ?? '',
    );
  }

  final String id;

  /// Display label — usually the person's first name, sometimes
  /// "father", "maternal grandmother", etc. Not a full name (PHI
  /// minimisation).
  final String label;
  final GenogramSex sex;
  final int? birthYear;
  final int? deathYear;

  /// `true` for the patient at the centre of the genogram — the
  /// canvas renders this person with a doubled outline.
  final bool isIndexPatient;
  final List<GenogramAttribute> attributes;
  final String notes;

  bool get isDeceased => deathYear != null;

  GenogramPerson copyWith({
    String? label,
    GenogramSex? sex,
    int? birthYear,
    int? deathYear,
    bool? isIndexPatient,
    List<GenogramAttribute>? attributes,
    String? notes,
  }) => GenogramPerson(
    id: id,
    label: label ?? this.label,
    sex: sex ?? this.sex,
    birthYear: birthYear ?? this.birthYear,
    deathYear: deathYear ?? this.deathYear,
    isIndexPatient: isIndexPatient ?? this.isIndexPatient,
    attributes: attributes ?? this.attributes,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'sex': sex.id,
    'birthYear': birthYear,
    'deathYear': deathYear,
    'isIndexPatient': isIndexPatient,
    'attributes': attributes.map((a) => a.id).toList(),
    'notes': notes,
  };
}

class GenogramRelationship {
  const GenogramRelationship({
    required this.fromPersonId,
    required this.toPersonId,
    required this.kind,
    this.notes = '',
  });

  factory GenogramRelationship.fromJson(Map<String, dynamic> json) =>
      GenogramRelationship(
        fromPersonId: json['from'] as String? ?? '',
        toPersonId: json['to'] as String? ?? '',
        kind: GenogramRelationshipKind.fromId(json['kind'] as String?),
        notes: json['notes'] as String? ?? '',
      );

  final String fromPersonId;
  final String toPersonId;
  final GenogramRelationshipKind kind;
  final String notes;

  Map<String, dynamic> toJson() => {
    'from': fromPersonId,
    'to': toPersonId,
    'kind': kind.id,
    'notes': notes,
  };
}

class Genogram {
  Genogram({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.createdAt,
    this.updatedAt,
    this.people = const [],
    this.relationships = const [],
    this.clinicianNotes = '',
  });

  factory Genogram.fromJson(Map<String, dynamic> json) {
    final rawPeople = json['people'];
    final people = <GenogramPerson>[];
    if (rawPeople is List) {
      for (final item in rawPeople) {
        if (item is Map<String, dynamic>) {
          people.add(GenogramPerson.fromJson(item));
        } else if (item is Map) {
          people.add(GenogramPerson.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    final rawRel = json['relationships'];
    final relationships = <GenogramRelationship>[];
    if (rawRel is List) {
      for (final item in rawRel) {
        if (item is Map<String, dynamic>) {
          relationships.add(GenogramRelationship.fromJson(item));
        } else if (item is Map) {
          relationships.add(
            GenogramRelationship.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return Genogram(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      clinicianId: json['clinicianId'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      people: people,
      relationships: relationships,
      clinicianNotes: json['clinicianNotes'] as String? ?? '',
    );
  }

  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<GenogramPerson> people;
  final List<GenogramRelationship> relationships;
  final String clinicianNotes;

  GenogramPerson? get indexPatient {
    for (final p in people) {
      if (p.isIndexPatient) return p;
    }
    return null;
  }

  /// Count how many family members carry a given attribute — used
  /// in the canvas footer to call out patterns ("3 family members
  /// with depression history").
  int attributeFrequency(GenogramAttribute attr) {
    var n = 0;
    for (final p in people) {
      if (p.attributes.contains(attr)) n++;
    }
    return n;
  }

  /// Returns relationships touching the given person id (either
  /// direction). Useful for rendering subtrees.
  List<GenogramRelationship> relationshipsFor(String personId) => relationships
      .where((r) => r.fromPersonId == personId || r.toPersonId == personId)
      .toList();

  Genogram copyWith({
    DateTime? updatedAt,
    List<GenogramPerson>? people,
    List<GenogramRelationship>? relationships,
    String? clinicianNotes,
  }) => Genogram(
    id: id,
    patientId: patientId,
    clinicianId: clinicianId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    people: people ?? this.people,
    relationships: relationships ?? this.relationships,
    clinicianNotes: clinicianNotes ?? this.clinicianNotes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'clinicianId': clinicianId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'people': people.map((p) => p.toJson()).toList(),
    'relationships': relationships.map((r) => r.toJson()).toList(),
    'clinicianNotes': clinicianNotes,
  };

  @override
  String toString() => 'Genogram(${jsonEncode(toJson())})';
}
