// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_diagnosis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Symptom _$SymptomFromJson(Map<String, dynamic> json) => Symptom(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  severity: (json['severity'] as num).toDouble(),
  onsetDate: DateTime.parse(json['onsetDate'] as String),
  duration: Duration(microseconds: (json['duration'] as num).toInt()),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SymptomToJson(Symptom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': instance.category,
  'severity': instance.severity,
  'onsetDate': instance.onsetDate.toIso8601String(),
  'duration': instance.duration.inMicroseconds,
  'notes': instance.notes,
  'metadata': instance.metadata,
};

SymptomAnalysis _$SymptomAnalysisFromJson(Map<String, dynamic> json) =>
    SymptomAnalysis(
      id: json['id'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => Symptom.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallSeverity: (json['overallSeverity'] as num).toDouble(),
      primaryCategories: (json['primaryCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => Pattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      analysisDate: DateTime.parse(json['analysisDate'] as String),
    );

Map<String, dynamic> _$SymptomAnalysisToJson(SymptomAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symptoms': instance.symptoms,
      'overallSeverity': instance.overallSeverity,
      'primaryCategories': instance.primaryCategories,
      'patterns': instance.patterns,
      'recommendations': instance.recommendations,
      'analysisDate': instance.analysisDate.toIso8601String(),
    };

Pattern _$PatternFromJson(Map<String, dynamic> json) => Pattern(
  id: json['id'] as String,
  type: $enumDecode(_$PatternTypeEnumMap, json['type']),
  description: json['description'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => Symptom.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PatternToJson(Pattern instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$PatternTypeEnumMap[instance.type]!,
  'description': instance.description,
  'confidence': instance.confidence,
  'symptoms': instance.symptoms,
};

const _$PatternTypeEnumMap = {
  PatternType.mood: 'mood',
  PatternType.sleep: 'sleep',
  PatternType.anxiety: 'anxiety',
  PatternType.cognitive: 'cognitive',
  PatternType.behavioral: 'behavioral',
  PatternType.physical: 'physical',
  PatternType.social: 'social',
};

RiskAssessment _$RiskAssessmentFromJson(Map<String, dynamic> json) =>
    RiskAssessment(
      id: json['id'] as String,
      riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      urgency: $enumDecode(_$UrgencyEnumMap, json['urgency']),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
    );

Map<String, dynamic> _$RiskAssessmentToJson(RiskAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'riskFactors': instance.riskFactors,
      'urgency': _$UrgencyEnumMap[instance.urgency]!,
      'recommendations': instance.recommendations,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

const _$UrgencyEnumMap = {
  Urgency.routine: 'routine',
  Urgency.urgent: 'urgent',
  Urgency.immediate: 'immediate',
};

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  type: $enumDecode(_$RiskTypeEnumMap, json['type']),
  severity: $enumDecode(_$RiskSeverityEnumMap, json['severity']),
  description: json['description'] as String,
  probability: (json['probability'] as num).toDouble(),
  mitigation: json['mitigation'] as String,
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$RiskTypeEnumMap[instance.type]!,
      'severity': _$RiskSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'probability': instance.probability,
      'mitigation': instance.mitigation,
    };

const _$RiskTypeEnumMap = {
  RiskType.suicidal: 'suicidal',
  RiskType.psychosis: 'psychosis',
  RiskType.violence: 'violence',
  RiskType.medication: 'medication',
  RiskType.historical: 'historical',
  RiskType.environmental: 'environmental',
  RiskType.social: 'social',
};

const _$RiskSeverityEnumMap = {
  RiskSeverity.low: 'low',
  RiskSeverity.medium: 'medium',
  RiskSeverity.high: 'high',
  RiskSeverity.critical: 'critical',
};

DiagnosisSuggestion _$DiagnosisSuggestionFromJson(Map<String, dynamic> json) =>
    DiagnosisSuggestion(
      id: json['id'] as String,
      diagnosis: json['diagnosis'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      evidence: (json['evidence'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      differentialDiagnoses: (json['differentialDiagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      icd10Code: json['icd10Code'] as String,
      severity: $enumDecode(_$DiagnosisSeverityEnumMap, json['severity']),
      treatmentPriority: $enumDecode(
        _$TreatmentPriorityEnumMap,
        json['treatmentPriority'],
      ),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DiagnosisSuggestionToJson(
  DiagnosisSuggestion instance,
) => <String, dynamic>{
  'id': instance.id,
  'diagnosis': instance.diagnosis,
  'confidence': instance.confidence,
  'evidence': instance.evidence,
  'differentialDiagnoses': instance.differentialDiagnoses,
  'icd10Code': instance.icd10Code,
  'severity': _$DiagnosisSeverityEnumMap[instance.severity]!,
  'treatmentPriority': _$TreatmentPriorityEnumMap[instance.treatmentPriority]!,
  'notes': instance.notes,
};

const _$DiagnosisSeverityEnumMap = {
  DiagnosisSeverity.mild: 'mild',
  DiagnosisSeverity.moderate: 'moderate',
  DiagnosisSeverity.severe: 'severe',
  DiagnosisSeverity.verySevere: 'verySevere',
};

const _$TreatmentPriorityEnumMap = {
  TreatmentPriority.low: 'low',
  TreatmentPriority.medium: 'medium',
  TreatmentPriority.high: 'high',
  TreatmentPriority.critical: 'critical',
};

TreatmentPlan _$TreatmentPlanFromJson(Map<String, dynamic> json) =>
    TreatmentPlan(
      id: json['id'] as String,
      diagnoses: (json['diagnoses'] as List<dynamic>)
          .map((e) => DiagnosisSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => TreatmentIntervention.fromJson(e as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>)
          .map((e) => TreatmentGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeline: Duration(microseconds: (json['timeline'] as num).toInt()),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      monitoringSchedule: MonitoringSchedule.fromJson(
        json['monitoringSchedule'] as Map<String, dynamic>,
      ),
      planDate: DateTime.parse(json['planDate'] as String),
    );

Map<String, dynamic> _$TreatmentPlanToJson(TreatmentPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'diagnoses': instance.diagnoses,
      'interventions': instance.interventions,
      'goals': instance.goals,
      'timeline': instance.timeline.inMicroseconds,
      'riskFactors': instance.riskFactors,
      'monitoringSchedule': instance.monitoringSchedule,
      'planDate': instance.planDate.toIso8601String(),
    };

TreatmentIntervention _$TreatmentInterventionFromJson(
  Map<String, dynamic> json,
) => TreatmentIntervention(
  id: json['id'] as String,
  type: $enumDecode(_$InterventionTypeEnumMap, json['type']),
  name: json['name'] as String,
  description: json['description'] as String,
  frequency: json['frequency'] as String,
  duration: json['duration'] as String,
  priority: $enumDecode(_$InterventionPriorityEnumMap, json['priority']),
);

Map<String, dynamic> _$TreatmentInterventionToJson(
  TreatmentIntervention instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$InterventionTypeEnumMap[instance.type]!,
  'name': instance.name,
  'description': instance.description,
  'frequency': instance.frequency,
  'duration': instance.duration,
  'priority': _$InterventionPriorityEnumMap[instance.priority]!,
};

const _$InterventionTypeEnumMap = {
  InterventionType.psychotherapy: 'psychotherapy',
  InterventionType.medication: 'medication',
  InterventionType.lifestyle: 'lifestyle',
  InterventionType.social: 'social',
  InterventionType.educational: 'educational',
  InterventionType.emergency: 'emergency',
};

const _$InterventionPriorityEnumMap = {
  InterventionPriority.low: 'low',
  InterventionPriority.medium: 'medium',
  InterventionPriority.high: 'high',
  InterventionPriority.critical: 'critical',
};

TreatmentGoal _$TreatmentGoalFromJson(Map<String, dynamic> json) =>
    TreatmentGoal(
      id: json['id'] as String,
      description: json['description'] as String,
      target: json['target'] as String,
      timeline: json['timeline'] as String,
      priority: $enumDecode(_$GoalPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$TreatmentGoalToJson(TreatmentGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'target': instance.target,
      'timeline': instance.timeline,
      'priority': _$GoalPriorityEnumMap[instance.priority]!,
    };

const _$GoalPriorityEnumMap = {
  GoalPriority.low: 'low',
  GoalPriority.medium: 'medium',
  GoalPriority.high: 'high',
  GoalPriority.critical: 'critical',
};

MonitoringSchedule _$MonitoringScheduleFromJson(Map<String, dynamic> json) =>
    MonitoringSchedule(
      id: json['id'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => MonitoringEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdDate: DateTime.parse(json['createdDate'] as String),
    );

Map<String, dynamic> _$MonitoringScheduleToJson(MonitoringSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'events': instance.events,
      'createdDate': instance.createdDate.toIso8601String(),
    };

MonitoringEvent _$MonitoringEventFromJson(Map<String, dynamic> json) =>
    MonitoringEvent(
      id: json['id'] as String,
      type: $enumDecode(_$MonitoringTypeEnumMap, json['type']),
      name: json['name'] as String,
      frequency: json['frequency'] as String,
      nextDue: DateTime.parse(json['nextDue'] as String),
    );

Map<String, dynamic> _$MonitoringEventToJson(MonitoringEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MonitoringTypeEnumMap[instance.type]!,
      'name': instance.name,
      'frequency': instance.frequency,
      'nextDue': instance.nextDue.toIso8601String(),
    };

const _$MonitoringTypeEnumMap = {
  MonitoringType.assessment: 'assessment',
  MonitoringType.safety: 'safety',
  MonitoringType.medication: 'medication',
  MonitoringType.therapy: 'therapy',
  MonitoringType.followUp: 'followUp',
};

DiagnosisProgress _$DiagnosisProgressFromJson(Map<String, dynamic> json) =>
    DiagnosisProgress(
      (json['progress'] as num).toDouble(),
      json['message'] as String,
    );

Map<String, dynamic> _$DiagnosisProgressToJson(DiagnosisProgress instance) =>
    <String, dynamic>{
      'progress': instance.progress,
      'message': instance.message,
    };

RiskAlert _$RiskAlertFromJson(Map<String, dynamic> json) => RiskAlert(
  id: json['id'] as String,
  assessment: RiskAssessment.fromJson(
    json['assessment'] as Map<String, dynamic>,
  ),
  timestamp: DateTime.parse(json['timestamp'] as String),
  priority: $enumDecode(_$AlertPriorityEnumMap, json['priority']),
);

Map<String, dynamic> _$RiskAlertToJson(RiskAlert instance) => <String, dynamic>{
  'id': instance.id,
  'assessment': instance.assessment,
  'timestamp': instance.timestamp.toIso8601String(),
  'priority': _$AlertPriorityEnumMap[instance.priority]!,
};

const _$AlertPriorityEnumMap = {
  AlertPriority.low: 'low',
  AlertPriority.medium: 'medium',
  AlertPriority.high: 'high',
  AlertPriority.critical: 'critical',
};
