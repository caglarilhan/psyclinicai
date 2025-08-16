import 'package:json_annotation/json_annotation.dart';

part 'ai_diagnosis_models.g.dart';

// AI Teşhis Sonucu
@JsonSerializable()
class AIDiagnosisResult {
  final String id;
  final String clientId;
  final DateTime timestamp;
  final DiagnosisConfidence confidence;
  final List<DiagnosisCode> primaryDiagnoses;
  final List<DiagnosisCode> differentialDiagnoses;
  final List<RiskFactor> riskFactors;
  final List<ProtectiveFactor> protectiveFactors;
  final TreatmentRecommendation treatmentRecommendation;
  final CulturalContext culturalContext;
  final Map<String, dynamic> metadata;

  AIDiagnosisResult({
    required this.id,
    required this.clientId,
    required this.timestamp,
    required this.confidence,
    required this.primaryDiagnoses,
    required this.differentialDiagnoses,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.treatmentRecommendation,
    required this.culturalContext,
    required this.metadata,
  });

  factory AIDiagnosisResult.fromJson(Map<String, dynamic> json) =>
      _$AIDiagnosisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AIDiagnosisResultToJson(this);
}

// Teşhis Güven Seviyesi
enum DiagnosisConfidence {
  @JsonValue('very_low')
  veryLow,
  @JsonValue('low')
  low,
  @JsonValue('moderate')
  moderate,
  @JsonValue('high')
  high,
  @JsonValue('very_high')
  veryHigh,
}

// Teşhis Kodu (ICD-11, DSM-5-TR)
@JsonSerializable()
class DiagnosisCode {
  final String code;
  final String name;
  final String classification; // ICD-11, DSM-5-TR, etc.
  final String category;
  final String description;
  final List<String> symptoms;
  final List<String> criteria;
  final double confidence;

  DiagnosisCode({
    required this.code,
    required this.name,
    required this.classification,
    required this.category,
    required this.description,
    required this.symptoms,
    required this.criteria,
    required this.confidence,
  });

  factory DiagnosisCode.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisCodeFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisCodeToJson(this);
}

// Risk Faktörü
@JsonSerializable()
class RiskFactor {
  final String id;
  final String name;
  final RiskLevel level;
  final String description;
  final String category; // biological, psychological, social
  final double impactScore;
  final List<String> interventions;

  RiskFactor({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.category,
    required this.impactScore,
    required this.interventions,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);

  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

// Koruyucu Faktör
@JsonSerializable()
class ProtectiveFactor {
  final String id;
  final String name;
  final String description;
  final String category;
  final double strengthScore;
  final List<String> enhancementStrategies;

  ProtectiveFactor({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.strengthScore,
    required this.enhancementStrategies,
  });

  factory ProtectiveFactor.fromJson(Map<String, dynamic> json) =>
      _$ProtectiveFactorFromJson(json);

  Map<String, dynamic> toJson() => _$ProtectiveFactorToJson(this);
}

// Tedavi Önerisi
@JsonSerializable()
class TreatmentRecommendation {
  final String id;
  final List<TreatmentModality> modalities;
  final List<MedicationRecommendation> medications;
  final List<TherapyRecommendation> therapies;
  final List<LifestyleRecommendation> lifestyleChanges;
  final List<FollowUpPlan> followUpPlans;
  final String rationale;
  final double expectedEfficacy;

  TreatmentRecommendation({
    required this.id,
    required this.modalities,
    required this.medications,
    required this.therapies,
    required this.lifestyleChanges,
    required this.followUpPlans,
    required this.rationale,
    required this.expectedEfficacy,
  });

  factory TreatmentRecommendation.fromJson(Map<String, dynamic> json) =>
      _$TreatmentRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentRecommendationToJson(this);
}

// Tedavi Modalitesi
@JsonSerializable()
class TreatmentModality {
  final String id;
  final String name;
  final String description;
  final TreatmentType type;
  final String intensity; // low, moderate, high
  final int durationWeeks;
  final double successRate;
  final List<String> contraindications;

  TreatmentModality({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.intensity,
    required this.durationWeeks,
    required this.successRate,
    required this.contraindications,
  });

  factory TreatmentModality.fromJson(Map<String, dynamic> json) =>
      _$TreatmentModalityFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentModalityToJson(this);
}

// Tedavi Türü
enum TreatmentType {
  @JsonValue('psychotherapy')
  psychotherapy,
  @JsonValue('pharmacotherapy')
  pharmacotherapy,
  @JsonValue('neuromodulation')
  neuromodulation,
  @JsonValue('lifestyle')
  lifestyle,
  @JsonValue('alternative')
  alternative,
  @JsonValue('combination')
  combination,
}

// İlaç Önerisi
@JsonSerializable()
class MedicationRecommendation {
  final String id;
  final String medicationName;
  final String genericName;
  final String classification;
  final String mechanism;
  final String dosage;
  final String frequency;
  final int durationDays;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> contraindications;
  final double efficacyScore;
  final String countryCode; // US, TR, DE, etc.

  MedicationRecommendation({
    required this.id,
    required this.medicationName,
    required this.genericName,
    required this.classification,
    required this.mechanism,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.sideEffects,
    required this.interactions,
    required this.contraindications,
    required this.efficacyScore,
    required this.countryCode,
  });

  factory MedicationRecommendation.fromJson(Map<String, dynamic> json) =>
      _$MedicationRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationRecommendationToJson(this);
}

// Terapi Önerisi
@JsonSerializable()
class TherapyRecommendation {
  final String id;
  final String therapyName;
  final String approach; // CBT, DBT, Psychodynamic, etc.
  final String description;
  final int sessionCount;
  final int sessionDurationMinutes;
  final String frequency;
  final double evidenceLevel;
  final List<String> techniques;
  final List<String> goals;

  TherapyRecommendation({
    required this.id,
    required this.therapyName,
    required this.approach,
    required this.description,
    required this.sessionCount,
    required this.sessionDurationMinutes,
    required this.frequency,
    required this.evidenceLevel,
    required this.techniques,
    required this.goals,
  });

  factory TherapyRecommendation.fromJson(Map<String, dynamic> json) =>
      _$TherapyRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$TherapyRecommendationToJson(this);
}

// Yaşam Tarzı Değişikliği
@JsonSerializable()
class LifestyleRecommendation {
  final String id;
  final String category; // exercise, nutrition, sleep, stress
  final String recommendation;
  final String rationale;
  final int frequencyPerWeek;
  final int durationMinutes;
  final double impactScore;
  final List<String> resources;

  LifestyleRecommendation({
    required this.id,
    required this.category,
    required this.recommendation,
    required this.rationale,
    required this.frequencyPerWeek,
    required this.durationMinutes,
    required this.impactScore,
    required this.resources,
  });

  factory LifestyleRecommendation.fromJson(Map<String, dynamic> json) =>
      _$LifestyleRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$LifestyleRecommendationToJson(this);
}

// Takip Planı
@JsonSerializable()
class FollowUpPlan {
  final String id;
  final String type; // assessment, medication, therapy
  final int frequencyDays;
  final String description;
  final List<String> metrics;
  final List<String> actions;

  FollowUpPlan({
    required this.id,
    required this.type,
    required this.frequencyDays,
    required this.description,
    required this.metrics,
    required this.actions,
  });

  factory FollowUpPlan.fromJson(Map<String, dynamic> json) =>
      _$FollowUpPlanFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUpPlanToJson(this);
}

// Kültürel Bağlam
@JsonSerializable()
class CulturalContext {
  final String countryCode;
  final String culture;
  final Map<String, dynamic> culturalNorms;
  final List<String> taboos;
  final Map<String, String> communicationStyles;
  final List<String> traditionalHealing;
  final Map<String, dynamic> stigmaFactors;
  final List<String> familyStructures;
  final Map<String, dynamic> religiousConsiderations;

  CulturalContext({
    required this.countryCode,
    required this.culture,
    required this.culturalNorms,
    required this.taboos,
    required this.communicationStyles,
    required this.traditionalHealing,
    required this.stigmaFactors,
    required this.familyStructures,
    required this.religiousConsiderations,
  });

  factory CulturalContext.fromJson(Map<String, dynamic> json) =>
      _$CulturalContextFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalContextToJson(this);
}

// Risk Seviyesi
enum RiskLevel {
  @JsonValue('none')
  none,
  @JsonValue('low')
  low,
  @JsonValue('moderate')
  moderate,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
  @JsonValue('emergency')
  emergency,
}
