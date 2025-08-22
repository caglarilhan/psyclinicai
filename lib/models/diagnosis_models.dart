import 'package:json_annotation/json_annotation.dart';
import 'clinical_decision_support_models.dart';

part 'diagnosis_models.g.dart';

@JsonSerializable()
class DiagnosisSystem {
  final String id;
  final String name; // DSM-5, ICD-11
  final String version;
  final List<DiagnosticCategory> categories;
  final List<DiagnosticCriteria> criteria;
  final List<TreatmentGuideline> guidelines;
  final bool isActive;
  final DateTime lastUpdated;

  const DiagnosisSystem({
    required this.id,
    required this.name,
    required this.version,
    required this.categories,
    required this.criteria,
    required this.guidelines,
    required this.isActive,
    required this.lastUpdated,
  });

  factory DiagnosisSystem.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisSystemFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisSystemToJson(this);
}

@JsonSerializable()
class DiagnosticCategory {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<String> parentCategories;
  final List<String> childCategories;
  final List<String> disorderIds;
  final DiagnosticCategoryType type;
  final Map<String, dynamic> metadata;

  const DiagnosticCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.parentCategories,
    required this.childCategories,
    required this.disorderIds,
    required this.type,
    this.metadata = const {},
  });

  factory DiagnosticCategory.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosticCategoryToJson(this);
}

@JsonSerializable()
class MentalDisorder {
  final String id;
  final String name;
  final String code;
  final String categoryId;
  final String description;
  final List<Symptom> symptoms;
  final List<DiagnosticCriteria> criteria;
  final List<String> differentialDiagnoses;
  final List<String> comorbidities;
  final SeverityLevel severity;
  final List<TreatmentOption> treatmentOptions;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final Prognosis prognosis;
  final Map<String, dynamic> metadata;

  const MentalDisorder({
    required this.id,
    required this.name,
    required this.code,
    required this.categoryId,
    required this.description,
    required this.symptoms,
    required this.criteria,
    required this.differentialDiagnoses,
    required this.comorbidities,
    required this.severity,
    required this.treatmentOptions,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.prognosis,
    this.metadata = const {},
  });

  factory MentalDisorder.fromJson(Map<String, dynamic> json) =>
      _$MentalDisorderFromJson(json);

  Map<String, dynamic> toJson() => _$MentalDisorderToJson(this);
}

@JsonSerializable()
class Symptom {
  final String id;
  final String name;
  final String description;
  final SymptomType type;
  final SymptomSeverity severity;
  final List<String> relatedSymptoms;
  final List<String> triggers;
  final List<String> alleviators;
  final TreatmentDuration duration;
  final Frequency frequency;
  final Map<String, dynamic> metadata;

  const Symptom({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.severity,
    required this.relatedSymptoms,
    required this.triggers,
    required this.alleviators,
    required this.duration,
    required this.frequency,
    this.metadata = const {},
  });

  factory Symptom.fromJson(Map<String, dynamic> json) =>
      _$SymptomFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomToJson(this);
}

@JsonSerializable()
class DiagnosticCriteria {
  final String id;
  final String disorderId;
  final String criterion;
  final int criterionNumber;
  final List<String> requiredSymptoms;
  final int minimumSymptoms;
  final TreatmentDuration minimumDuration;
  final List<String> exclusionCriteria;
  final List<String> specifiers;
  final Map<String, dynamic> metadata;

  const DiagnosticCriteria({
    required this.id,
    required this.disorderId,
    required this.criterion,
    required this.criterionNumber,
    required this.requiredSymptoms,
    required this.minimumSymptoms,
    required this.minimumDuration,
    required this.exclusionCriteria,
    required this.specifiers,
    this.metadata = const {},
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
  final TreatmentLevel level;
  final List<TreatmentModality> modalities;
  final List<MedicationRecommendation> medications;
  final List<PsychotherapyRecommendation> psychotherapies;
  final List<String> contraindications;
  final List<String> sideEffects;
  final TreatmentDuration expectedDuration;
  final List<String> outcomeMeasures;
  final Map<String, dynamic> metadata;

  const TreatmentGuideline({
    required this.id,
    required this.disorderId,
    required this.title,
    required this.description,
    required this.level,
    required this.modalities,
    required this.medications,
    required this.psychotherapies,
    required this.contraindications,
    required this.sideEffects,
    required this.expectedDuration,
    required this.outcomeMeasures,
    this.metadata = const {},
  });

  factory TreatmentGuideline.fromJson(Map<String, dynamic> json) =>
      _$TreatmentGuidelineFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentGuidelineToJson(this);
}

@JsonSerializable()
class TreatmentOption {
  final String id;
  final String name;
  final TreatmentModality modality;
  final String description;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final TreatmentDuration duration;
  final double effectiveness;
  final List<String> alternatives;
  final Map<String, dynamic> metadata;

  const TreatmentOption({
    required this.id,
    required this.name,
    required this.modality,
    required this.description,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.duration,
    required this.effectiveness,
    required this.alternatives,
    this.metadata = const {},
  });

  factory TreatmentOption.fromJson(Map<String, dynamic> json) =>
      _$TreatmentOptionFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentOptionToJson(this);
}

@JsonSerializable()
class MedicationRecommendation {
  final String id;
  final String medicationName;
  final String genericName;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> drugInteractions;
  final List<String> monitoringRequirements;
  final TreatmentDuration treatmentDuration;
  final List<String> alternatives;
  final Map<String, dynamic> metadata;

  const MedicationRecommendation({
    required this.id,
    required this.medicationName,
    required this.genericName,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.drugInteractions,
    required this.monitoringRequirements,
    required this.treatmentDuration,
    required this.alternatives,
    this.metadata = const {},
  });

  factory MedicationRecommendation.fromJson(Map<String, dynamic> json) =>
      _$MedicationRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationRecommendationToJson(this);
}

@JsonSerializable()
class PsychotherapyRecommendation {
  final String id;
  final String therapyName;
  final String description;
  final List<String> indications;
  final List<String> contraindications;
  final DurationPeriod sessionDuration;
  final int totalSessions;
  final double effectiveness;
  final List<String> techniques;
  final Map<String, dynamic> metadata;

  const PsychotherapyRecommendation({
    required this.id,
    required this.therapyName,
    required this.description,
    required this.indications,
    required this.contraindications,
    required this.sessionDuration,
    required this.totalSessions,
    required this.effectiveness,
    required this.techniques,
    this.metadata = const {},
  });

  factory PsychotherapyRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PsychotherapyRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$PsychotherapyRecommendationToJson(this);
}

@JsonSerializable()
class DiagnosisAssessment {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime assessmentDate;
  final List<DiagnosisResult> diagnoses;
  final List<SymptomAssessment> symptoms;
  final SeverityLevel overallSeverity;
  final List<String> differentialDiagnoses;
  final List<String> comorbidities;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final Prognosis prognosis;
  final List<TreatmentRecommendation> treatmentRecommendations;
  final String clinicalNotes;
  final Map<String, dynamic> metadata;

  const DiagnosisAssessment({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.assessmentDate,
    required this.diagnoses,
    required this.symptoms,
    required this.overallSeverity,
    required this.differentialDiagnoses,
    required this.comorbidities,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.prognosis,
    required this.treatmentRecommendations,
    required this.clinicalNotes,
    this.metadata = const {},
  });

  factory DiagnosisAssessment.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisAssessmentToJson(this);
}

@JsonSerializable()
class DiagnosisResult {
  final String id;
  final String clientId;
  final String therapistId;
  final DateTime analysisDate;
  final List<Symptom> symptoms;
  final SymptomAnalysis symptomAnalysis;
  final RiskAssessment riskAssessment;
  final List<DiagnosisSuggestion> diagnosisSuggestions;
  final TreatmentPlan treatmentPlan;
  final double confidence;
  final String aiModel;
  final int processingTime;
  final Map<String, dynamic> metadata;

  const DiagnosisResult({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.analysisDate,
    required this.symptoms,
    required this.symptomAnalysis,
    required this.riskAssessment,
    required this.diagnosisSuggestions,
    required this.treatmentPlan,
    required this.confidence,
    required this.aiModel,
    required this.processingTime,
    this.metadata = const {},
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisResultFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisResultToJson(this);
}

@JsonSerializable()
class SymptomAnalysis {
  final String id;
  final List<Symptom> symptoms;
  final double overallSeverity;
  final List<String> primaryCategories;
  final List<Pattern> patterns;
  final List<String> recommendations;
  final DateTime analysisDate;

  const SymptomAnalysis({
    required this.id,
    required this.symptoms,
    required this.overallSeverity,
    required this.primaryCategories,
    required this.patterns,
    required this.recommendations,
    required this.analysisDate,
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) => _$SymptomAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomAnalysisToJson(this);
}

@JsonSerializable()
class Pattern {
  final String id;
  final PatternType type;
  final String description;
  final double confidence;
  final List<Symptom> symptoms;

  const Pattern({
    required this.id,
    required this.type,
    required this.description,
    required this.confidence,
    required this.symptoms,
  });

  factory Pattern.fromJson(Map<String, dynamic> json) => _$PatternFromJson(json);
  Map<String, dynamic> toJson() => _$PatternToJson(this);
}

enum PatternType {
  mood,
  sleep,
  anxiety,
  cognitive,
  behavioral,
  physical,
  social
}

@JsonSerializable()
class DiagnosisProgress {
  final double progress; // 0.0 - 1.0
  final String message;

  const DiagnosisProgress(this.progress, this.message);

  factory DiagnosisProgress.fromJson(Map<String, dynamic> json) => _$DiagnosisProgressFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisProgressToJson(this);
}

@JsonSerializable()
class RiskAlert {
  final String id;
  final RiskAssessment assessment;
  final DateTime timestamp;
  final AlertPriority priority;

  const RiskAlert({
    required this.id,
    required this.assessment,
    required this.timestamp,
    required this.priority,
  });

  factory RiskAlert.fromJson(Map<String, dynamic> json) => _$RiskAlertFromJson(json);
  Map<String, dynamic> toJson() => _$RiskAlertToJson(this);
}

enum AlertPriority {
  low,
  medium,
  high,
  critical
}

@JsonSerializable()
class SymptomAssessment {
  final String id;
  final String patientId;
  final String clinicianId;
  final String symptomId;
  final String symptomName;
  final SymptomSeverity severity;
  final TreatmentDuration duration;
  final Frequency frequency;
  final List<String> triggers;
  final List<String> alleviators;
  final String impact;
  final Map<String, dynamic> metadata;

  const SymptomAssessment({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.symptomId,
    required this.symptomName,
    required this.severity,
    required this.duration,
    required this.frequency,
    required this.triggers,
    required this.alleviators,
    required this.impact,
    this.metadata = const {},
  });

  factory SymptomAssessment.fromJson(Map<String, dynamic> json) =>
      _$SymptomAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomAssessmentToJson(this);
}

@JsonSerializable()
class TreatmentRecommendation {
  final String id;
  final String treatmentId;
  final String treatmentName;
  final TreatmentModality modality;
  final String rationale;
  final TreatmentDuration duration;
  final List<String> goals;
  final List<String> expectedOutcomes;
  final List<String> monitoringRequirements;
  final Map<String, dynamic> metadata;

  const TreatmentRecommendation({
    required this.id,
    required this.treatmentId,
    required this.treatmentName,
    required this.modality,
    required this.rationale,
    required this.duration,
    required this.goals,
    required this.expectedOutcomes,
    required this.monitoringRequirements,
    this.metadata = const {},
  });

  factory TreatmentRecommendation.fromJson(Map<String, dynamic> json) =>
      _$TreatmentRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentRecommendationToJson(this);
}

// Enums
enum DiagnosticCategoryType {
  neurodevelopmental,
  schizophrenia,
  bipolar,
  depressive,
  anxiety,
  obsessiveCompulsive,
  trauma,
  dissociative,
  somatic,
  feeding,
  elimination,
  sleepWake,
  sexualDysfunction,
  genderDysphoria,
  disruptive,
  substance,
  neurocognitive,
  personality,
  paraphilic,
  clinical,
  other,
}

enum SymptomType {
  mood,
  anxiety,
  psychotic,
  cognitive,
  behavioral,
  somatic,
  sleep,
  appetite,
  energy,
  concentration,
  memory,
  social,
  occupational,
  other,
}

enum SymptomSeverity {
  none,
  mild,
  moderate,
  severe,
  extreme,
}

enum SeverityLevel {
  none,
  mild,
  moderate,
  severe,
  extreme,
}

enum TreatmentLevel {
  firstLine,
  secondLine,
  thirdLine,
  experimental,
  notRecommended,
}

enum TreatmentModality {
  medication,
  psychotherapy,
  brainStimulation,
  lifestyle,
  complementary,
  other,
}

enum Prognosis {
  excellent,
  good,
  fair,
  poor,
  guarded,
}

enum TreatmentDuration {
  acute, // < 1 month
  subacute, // 1-3 months
  chronic, // > 3 months
  episodic,
  continuous,
}

enum Frequency {
  never,
  rarely,
  sometimes,
  often,
  always,
  episodic,
  continuous,
  daily,
  weekly,
  monthly,
}

enum DiagnosisSeverity {
  mild,
  moderate,
  severe,
  verySevere,
}

enum TreatmentPriority {
  low,
  medium,
  high,
  urgent,
}

@JsonSerializable()
class DiagnosisSuggestion {
  final String id;
  final String diagnosis;
  final double confidence;
  final List<String> evidence;
  final List<String> differentialDiagnoses;
  final String icd10Code;
  final DiagnosisSeverity severity;
  final TreatmentPriority treatmentPriority;
  final String? notes;

  const DiagnosisSuggestion({
    required this.id,
    required this.diagnosis,
    required this.confidence,
    required this.evidence,
    required this.differentialDiagnoses,
    required this.icd10Code,
    required this.severity,
    required this.treatmentPriority,
    this.notes,
  });

  factory DiagnosisSuggestion.fromJson(Map<String, dynamic> json) => _$DiagnosisSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisSuggestionToJson(this);
}

// ===== RİSK DEĞERLENDİRME MODELLERİ =====

@JsonSerializable()
class RiskAssessment {
  final String id;
  final RiskLevel riskLevel;
  final List<RiskFactor> riskFactors;
  final Urgency urgency;
  final List<String> recommendations;
  final DateTime assessmentDate;

  const RiskAssessment({
    required this.id,
    required this.riskLevel,
    required this.recommendations,
    required this.assessmentDate,
    required this.riskFactors,
    required this.urgency,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) => _$RiskAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$RiskAssessmentToJson(this);
}

@JsonSerializable()
class RiskFactor {
  final String id;
  final RiskType type;
  final RiskSeverity severity;
  final String description;
  final double probability;
  final String mitigation;

  const RiskFactor({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.probability,
    required this.mitigation,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) => _$RiskFactorFromJson(json);
  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

enum RiskLevel {
  low,
  medium,
  high,
  critical
}

enum RiskType {
  biological,
  psychological,
  social,
  environmental,
  genetic,
  lifestyle,
  medication,
  substance,
  trauma,
  other
}

enum RiskSeverity {
  low,
  medium,
  high,
  critical
}

enum Urgency {
  routine,
  urgent,
  immediate
}

// ===== TEDAVİ PLANI MODELLERİ =====

@JsonSerializable()
class TreatmentPlan {
  final String id;
  final List<DiagnosisSuggestion> diagnoses;
  final List<TreatmentIntervention> interventions;
  final List<TreatmentGoal> goals;
  final DurationPeriod timeline;
  final List<RiskFactor> riskFactors;
  final MonitoringSchedule monitoringSchedule;
  final DateTime planDate;

  const TreatmentPlan({
    required this.id,
    required this.diagnoses,
    required this.interventions,
    required this.goals,
    required this.timeline,
    required this.riskFactors,
    required this.monitoringSchedule,
    required this.planDate,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) => _$TreatmentPlanFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentPlanToJson(this);
}

@JsonSerializable()
class TreatmentIntervention {
  final String id;
  final InterventionType type;
  final String name;
  final String description;
  final String frequency;
  final String duration;
  final InterventionPriority priority;

  const TreatmentIntervention({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.frequency,
    required this.duration,
    required this.priority,
  });

  factory TreatmentIntervention.fromJson(Map<String, dynamic> json) => _$TreatmentInterventionFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentInterventionToJson(this);
}

enum InterventionType {
  psychotherapy,
  medication,
  lifestyle,
  social,
  educational,
  emergency
}

enum InterventionPriority {
  low,
  medium,
  high,
  critical
}

@JsonSerializable()
class TreatmentGoal {
  final String id;
  final String description;
  final String target;
  final String timeline;
  final GoalPriority priority;

  const TreatmentGoal({
    required this.id,
    required this.description,
    required this.target,
    required this.timeline,
    required this.priority,
  });

  factory TreatmentGoal.fromJson(Map<String, dynamic> json) => _$TreatmentGoalFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentGoalToJson(this);
}

enum GoalPriority {
  low,
  medium,
  high,
  critical
}

@JsonSerializable()
class MonitoringEvent {
  final String id;
  final MonitoringType type;
  final String name;
  final String frequency;
  final DateTime nextDue;

  const MonitoringEvent({
    required this.id,
    required this.type,
    required this.name,
    required this.frequency,
    required this.nextDue,
  });

  factory MonitoringEvent.fromJson(Map<String, dynamic> json) => _$MonitoringEventFromJson(json);
  Map<String, dynamic> toJson() => _$MonitoringEventToJson(this);
}

enum MonitoringType {
  assessment,
  safety,
  medication,
  therapy,
  followUp
}

@JsonSerializable()
class MonitoringSchedule {
  final String id;
  final List<MonitoringEvent> events;
  final DateTime createdDate;

  const MonitoringSchedule({
    required this.id,
    required this.events,
    required this.createdDate,
  });

  factory MonitoringSchedule.fromJson(Map<String, dynamic> json) => _$MonitoringScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$MonitoringScheduleToJson(this);
}
