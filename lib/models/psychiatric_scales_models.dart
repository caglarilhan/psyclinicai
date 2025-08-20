import 'package:json_annotation/json_annotation.dart';

part 'psychiatric_scales_models.g.dart';

@JsonSerializable()
class PsychiatricScale {
  final String id;
  final String name;
  final String code;
  final String description;
  final String version;
  final ScaleType type;
  final List<ScaleItem> items;
  final ScoringMethod scoringMethod;
  final List<ScoreRange> scoreRanges;
  final String administrationTime;
  final String targetPopulation;
  final List<String> indications;
  final List<String> contraindications;
  final String reliability;
  final String validity;
  final String sensitivity;
  final String specificity;
  final List<String> languages;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime lastUpdated;

  const PsychiatricScale({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.version,
    required this.type,
    required this.items,
    required this.scoringMethod,
    required this.scoreRanges,
    required this.administrationTime,
    required this.targetPopulation,
    required this.indications,
    required this.contraindications,
    required this.reliability,
    required this.validity,
    required this.sensitivity,
    required this.specificity,
    required this.languages,
    this.metadata = const {},
    required this.isActive,
    required this.lastUpdated,
  });

  factory PsychiatricScale.fromJson(Map<String, dynamic> json) =>
      _$PsychiatricScaleFromJson(json);

  Map<String, dynamic> toJson() => _$PsychiatricScaleToJson(this);
}

@JsonSerializable()
class ScaleItem {
  final String id;
  final String itemNumber;
  final String question;
  final String description;
  final ItemType type;
  final List<ItemResponse> responses;
  final String category;
  final String subcategory;
  final double weight;
  final bool isRequired;
  final String instructions;
  final List<String> examples;
  final Map<String, dynamic> metadata;

  const ScaleItem({
    required this.id,
    required this.itemNumber,
    required this.question,
    required this.description,
    required this.type,
    required this.responses,
    required this.category,
    required this.subcategory,
    required this.weight,
    required this.isRequired,
    required this.instructions,
    required this.examples,
    this.metadata = const {},
  });

  factory ScaleItem.fromJson(Map<String, dynamic> json) =>
      _$ScaleItemFromJson(json);

  Map<String, dynamic> toJson() => _$ScaleItemToJson(this);
}

@JsonSerializable()
class ItemResponse {
  final String id;
  final String responseText;
  final int score;
  final String description;
  final String interpretation;
  final List<String> examples;
  final Map<String, dynamic> metadata;

  const ItemResponse({
    required this.id,
    required this.responseText,
    required this.score,
    required this.description,
    required this.interpretation,
    required this.examples,
    this.metadata = const {},
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ItemResponseToJson(this);
}

@JsonSerializable()
class ScoreRange {
  final String id;
  final int minScore;
  final int maxScore;
  final String severity;
  final String interpretation;
  final String recommendation;
  final List<String> actions;
  final Map<String, dynamic> metadata;

  const ScoreRange({
    required this.id,
    required this.minScore,
    required this.maxScore,
    required this.severity,
    required this.interpretation,
    required this.recommendation,
    required this.actions,
    this.metadata = const {},
  });

  factory ScoreRange.fromJson(Map<String, dynamic> json) =>
      _$ScoreRangeFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreRangeToJson(this);
}

@JsonSerializable()
class ScaleAssessment {
  final String id;
  final String patientId;
  final String clinicianId;
  final String scaleId;
  final String scaleName;
  final DateTime assessmentDate;
  final List<ItemResponse> responses;
  final int totalScore;
  final String severity;
  final String interpretation;
  final List<String> recommendations;
  final String clinicalNotes;
  final String status;
  final Map<String, dynamic> metadata;

  const ScaleAssessment({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.scaleId,
    required this.scaleName,
    required this.assessmentDate,
    required this.responses,
    required this.totalScore,
    required this.severity,
    required this.interpretation,
    required this.recommendations,
    required this.clinicalNotes,
    required this.status,
    this.metadata = const {},
  });

  factory ScaleAssessment.fromJson(Map<String, dynamic> json) =>
      _$ScaleAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$ScaleAssessmentToJson(this);
}

@JsonSerializable()
class ScaleTrend {
  final String id;
  final String patientId;
  final String scaleId;
  final String scaleName;
  final List<ScaleAssessment> assessments;
  final DateTime startDate;
  final DateTime endDate;
  final String trend;
  final String interpretation;
  final List<String> significantChanges;
  final List<String> recommendations;
  final double improvementRate;
  final double responseRate;
  final Map<String, dynamic> metadata;

  const ScaleTrend({
    required this.id,
    required this.patientId,
    required this.scaleId,
    required this.scaleName,
    required this.assessments,
    required this.startDate,
    required this.endDate,
    required this.trend,
    required this.interpretation,
    required this.significantChanges,
    required this.recommendations,
    required this.improvementRate,
    required this.responseRate,
    this.metadata = const {},
  });

  factory ScaleTrend.fromJson(Map<String, dynamic> json) =>
      _$ScaleTrendFromJson(json);

  Map<String, dynamic> toJson() => _$ScaleTrendToJson(this);
}

@JsonSerializable()
class ScaleReport {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime reportDate;
  final List<ScaleAssessment> assessments;
  final List<ScaleTrend> trends;
  final String summary;
  final String interpretation;
  final List<String> recommendations;
  final List<String> followUpAssessments;
  final String status;
  final String notes;
  final Map<String, dynamic> metadata;

  const ScaleReport({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.reportDate,
    required this.assessments,
    required this.trends,
    required this.summary,
    required this.interpretation,
    required this.recommendations,
    required this.followUpAssessments,
    required this.status,
    required this.notes,
    this.metadata = const {},
  });

  factory ScaleReport.fromJson(Map<String, dynamic> json) =>
      _$ScaleReportFromJson(json);

  Map<String, dynamic> toJson() => _$ScaleReportToJson(this);
}

// Specific Scale Models

@JsonSerializable()
class PANSSAssessment extends ScaleAssessment {
  final int positiveScore;
  final int negativeScore;
  final int generalScore;
  final String positiveSeverity;
  final String negativeSeverity;
  final String generalSeverity;
  final List<String> positiveSymptoms;
  final List<String> negativeSymptoms;
  final List<String> generalSymptoms;

  const PANSSAssessment({
    required super.id,
    required super.patientId,
    required super.clinicianId,
    required super.scaleId,
    required super.scaleName,
    required super.assessmentDate,
    required super.responses,
    required super.totalScore,
    required super.severity,
    required super.interpretation,
    required super.recommendations,
    required super.clinicalNotes,
    required super.status,
    required this.positiveScore,
    required this.negativeScore,
    required this.generalScore,
    required this.positiveSeverity,
    required this.negativeSeverity,
    required this.generalSeverity,
    required this.positiveSymptoms,
    required this.negativeSymptoms,
    required this.generalSymptoms,
    super.metadata,
  });

  factory PANSSAssessment.fromJson(Map<String, dynamic> json) =>
      _$PANSSAssessmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PANSSAssessmentToJson(this);
}

@JsonSerializable()
class YMRSAssessment extends ScaleAssessment {
  final int manicScore;
  final String manicSeverity;
  final List<String> manicSymptoms;
  final List<String> riskFactors;
  final List<String> safetyMeasures;

  const YMRSAssessment({
    required super.id,
    required super.patientId,
    required super.clinicianId,
    required super.scaleId,
    required super.scaleName,
    required super.assessmentDate,
    required super.responses,
    required super.totalScore,
    required super.severity,
    required super.interpretation,
    required super.recommendations,
    required super.clinicalNotes,
    required super.status,
    required this.manicScore,
    required this.manicSeverity,
    required this.manicSymptoms,
    required this.riskFactors,
    required this.safetyMeasures,
    super.metadata,
  });

  factory YMRSAssessment.fromJson(Map<String, dynamic> json) =>
      _$YMRSAssessmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$YMRSAssessmentToJson(this);
}

@JsonSerializable()
class HAMDAssessment extends ScaleAssessment {
  final int depressionScore;
  final String depressionSeverity;
  final List<String> coreSymptoms;
  final List<String> somaticSymptoms;
  final List<String> cognitiveSymptoms;
  final List<String> suicideRisk;

  const HAMDAssessment({
    required super.id,
    required super.patientId,
    required super.clinicianId,
    required super.scaleId,
    required super.scaleName,
    required super.assessmentDate,
    required super.responses,
    required super.totalScore,
    required super.severity,
    required super.interpretation,
    required super.recommendations,
    required super.clinicalNotes,
    required super.status,
    required this.depressionScore,
    required this.depressionSeverity,
    required this.coreSymptoms,
    required this.somaticSymptoms,
    required this.cognitiveSymptoms,
    required this.suicideRisk,
    super.metadata,
  });

  factory HAMDAssessment.fromJson(Map<String, dynamic> json) =>
      _$HAMDAssessmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HAMDAssessmentToJson(this);
}

@JsonSerializable()
class HAMAAssessment extends ScaleAssessment {
  final int anxietyScore;
  final String anxietySeverity;
  final List<String> psychicSymptoms;
  final List<String> somaticSymptoms;
  final List<String> avoidanceBehaviors;
  final List<String> triggers;

  const HAMAAssessment({
    required super.id,
    required super.patientId,
    required super.clinicianId,
    required super.scaleId,
    required super.scaleName,
    required super.assessmentDate,
    required super.responses,
    required super.totalScore,
    required super.severity,
    required super.interpretation,
    required super.recommendations,
    required super.clinicalNotes,
    required super.status,
    required this.anxietyScore,
    required this.anxietySeverity,
    required this.psychicSymptoms,
    required this.somaticSymptoms,
    required this.avoidanceBehaviors,
    required this.triggers,
    super.metadata,
  });

  factory HAMAAssessment.fromJson(Map<String, dynamic> json) =>
      _$HAMAAssessmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HAMAAssessmentToJson(this);
}

@JsonSerializable()
class MADRSAssessment extends ScaleAssessment {
  final int depressionScore;
  final String depressionSeverity;
  final List<String> moodSymptoms;
  final List<String> cognitiveSymptoms;
  final List<String> physicalSymptoms;
  final List<String> suicideRisk;

  const MADRSAssessment({
    required super.id,
    required super.patientId,
    required super.clinicianId,
    required super.scaleId,
    required super.scaleName,
    required super.assessmentDate,
    required super.responses,
    required super.totalScore,
    required super.severity,
    required super.interpretation,
    required super.recommendations,
    required super.clinicalNotes,
    required super.status,
    required this.depressionScore,
    required this.depressionSeverity,
    required this.moodSymptoms,
    required this.cognitiveSymptoms,
    required this.physicalSymptoms,
    required this.suicideRisk,
    super.metadata,
  });

  factory MADRSAssessment.fromJson(Map<String, dynamic> json) =>
      _$MADRSAssessmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MADRSAssessmentToJson(this);
}

// Enums
enum ScaleType {
  depression,
  anxiety,
  mania,
  psychosis,
  personality,
  cognitive,
  substance,
  eating,
  sleep,
  other,
}

enum ItemType {
  likert,
  binary,
  multipleChoice,
  openEnded,
  visual,
  other,
}

enum ScoringMethod {
  sum,
  average,
  weighted,
  algorithm,
  other,
}

enum AssessmentStatus {
  pending,
  inProgress,
  completed,
  reviewed,
  archived,
}
