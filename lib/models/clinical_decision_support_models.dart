import 'package:json_annotation/json_annotation.dart';

part 'clinical_decision_support_models.g.dart';

// ===== TEMEL KLİNİK MODELLER =====

@JsonSerializable()
class MentalDisorder {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<String> symptoms;
  final List<String> criteria;
  final List<String> treatments;
  final Map<String, dynamic> metadata;

  const MentalDisorder({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.symptoms,
    required this.criteria,
    required this.treatments,
    required this.metadata,
  });

  factory MentalDisorder.fromJson(Map<String, dynamic> json) =>
      _$MentalDisorderFromJson(json);

  Map<String, dynamic> toJson() => _$MentalDisorderToJson(this);
}

@JsonSerializable()
class DiagnosticCriteria {
  final String id;
  final String disorderId;
  final String criteria;
  final int requiredCount;
  final List<String> symptoms;
  final Map<String, dynamic> metadata;

  const DiagnosticCriteria({
    required this.id,
    required this.disorderId,
    required this.criteria,
    required this.requiredCount,
    required this.symptoms,
    required this.metadata,
  });

  factory DiagnosticCriteria.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosticCriteriaToJson(this);
}

@JsonSerializable()
class TreatmentGuideline {
  final String id;
  final String disorderId;
  final String title;
  final String description;
  final List<String> recommendations;
  final List<String> medications;
  final List<String> therapies;
  final Map<String, dynamic> metadata;

  const TreatmentGuideline({
    required this.id,
    required this.disorderId,
    required this.title,
    required this.description,
    required this.recommendations,
    required this.medications,
    required this.therapies,
    required this.metadata,
  });

  factory TreatmentGuideline.fromJson(Map<String, dynamic> json) =>
      _$TreatmentGuidelineFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentGuidelineToJson(this);
}

// ===== BELİRTİ MODELLERİ =====

@JsonSerializable()
class Symptom {
  final String id;
  final String name;
  final SymptomType type;
  final SymptomSeverity severity;
  final String description;
  final List<String> relatedSymptoms;
  final Map<String, dynamic> metadata;

  const Symptom({
    required this.id,
    required this.name,
    required this.type,
    required this.severity,
    required this.description,
    required this.relatedSymptoms,
    required this.metadata,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) =>
      _$SymptomFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomToJson(this);
}

enum SymptomType {
  @JsonValue('mood')
  mood,
  @JsonValue('anxiety')
  anxiety,
  @JsonValue('psychotic')
  psychotic,
  @JsonValue('cognitive')
  cognitive,
  @JsonValue('behavioral')
  behavioral,
  @JsonValue('physical')
  physical,
  @JsonValue('sleep')
  sleep,
  @JsonValue('appetite')
  appetite,
}

enum SymptomSeverity {
  @JsonValue('none')
  none,
  @JsonValue('mild')
  mild,
  @JsonValue('moderate')
  moderate,
  @JsonValue('severe')
  severe,
  @JsonValue('extreme')
  extreme,
}

// ===== TEDAVİ SÜRE VE SIKLIK MODELLERİ =====

enum TreatmentDuration {
  @JsonValue('acute')
  acute,
  @JsonValue('episodic')
  episodic,
  @JsonValue('chronic')
  chronic,
  @JsonValue('maintenance')
  maintenance,
}

enum Frequency {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('as_needed')
  asNeeded,
}
