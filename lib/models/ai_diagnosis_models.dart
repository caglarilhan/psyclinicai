import 'package:json_annotation/json_annotation.dart';

part 'ai_diagnosis_models.g.dart';

// ===== SEMPTOM MODELLERİ =====

@JsonSerializable()
class Symptom {
  final String id;
  final String name;
  final String description;
  final String category;
  final double severity; // 0-10 scale
  final DateTime onsetDate;
  final Duration duration;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const Symptom({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.severity,
    required this.onsetDate,
    required this.duration,
    this.notes,
    this.metadata,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) => _$SymptomFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomToJson(this);
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
    required this.riskFactors,
    required this.urgency,
    required this.recommendations,
    required this.assessmentDate,
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
  suicidal,
  psychosis,
  violence,
  medication,
  historical,
  environmental,
  social
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

// ===== TANI ÖNERİLERİ MODELLERİ =====

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

enum DiagnosisSeverity {
  mild,
  moderate,
  severe,
  verySevere
}

enum TreatmentPriority {
  low,
  medium,
  high,
  critical
}

// ===== TEDAVİ PLANI MODELLERİ =====

@JsonSerializable()
class TreatmentPlan {
  final String id;
  final List<DiagnosisSuggestion> diagnoses;
  final List<TreatmentIntervention> interventions;
  final List<TreatmentGoal> goals;
  final Duration timeline;
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

// ===== İZLEME MODELLERİ =====

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



// ===== İLERLEME VE UYARI MODELLERİ =====

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
