// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_system_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrisisFlag _$CrisisFlagFromJson(Map<String, dynamic> json) => CrisisFlag(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  type: $enumDecode(_$CrisisTypeEnumMap, json['type']),
  severity: $enumDecode(_$CrisisSeverityEnumMap, json['severity']),
  detectedAt: DateTime.parse(json['detectedAt'] as String),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  description: json['description'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  immediateActions: (json['immediateActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  resolutionNotes: json['resolutionNotes'] as String?,
  status: $enumDecode(_$FlagStatusEnumMap, json['status']),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CrisisFlagToJson(CrisisFlag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'type': _$CrisisTypeEnumMap[instance.type]!,
      'severity': _$CrisisSeverityEnumMap[instance.severity]!,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'description': instance.description,
      'symptoms': instance.symptoms,
      'riskFactors': instance.riskFactors,
      'immediateActions': instance.immediateActions,
      'resolutionNotes': instance.resolutionNotes,
      'status': _$FlagStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
    };

const _$CrisisTypeEnumMap = {
  CrisisType.suicidalIdeation: 'suicidal_ideation',
  CrisisType.suicidalAttempt: 'suicidal_attempt',
  CrisisType.homicidalIdeation: 'homicidal_ideation',
  CrisisType.severeAgitation: 'severe_agitation',
  CrisisType.psychoticBreak: 'psychotic_break',
  CrisisType.severeDepression: 'severe_depression',
  CrisisType.manicEpisode: 'manic_episode',
  CrisisType.substanceAbuse: 'substance_abuse',
  CrisisType.selfHarm: 'self_harm',
  CrisisType.violentBehavior: 'violent_behavior',
};

const _$CrisisSeverityEnumMap = {
  CrisisSeverity.low: 'low',
  CrisisSeverity.moderate: 'moderate',
  CrisisSeverity.high: 'high',
  CrisisSeverity.critical: 'critical',
  CrisisSeverity.emergency: 'emergency',
};

const _$FlagStatusEnumMap = {
  FlagStatus.active: 'active',
  FlagStatus.monitoring: 'monitoring',
  FlagStatus.resolved: 'resolved',
  FlagStatus.escalated: 'escalated',
  FlagStatus.dismissed: 'dismissed',
  FlagStatus.archived: 'archived',
};

SuicideRiskAssessment _$SuicideRiskAssessmentFromJson(
  Map<String, dynamic> json,
) => SuicideRiskAssessment(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  assessmentDate: DateTime.parse(json['assessmentDate'] as String),
  suicidalIdeationScore: (json['suicidalIdeationScore'] as num).toInt(),
  suicidalBehaviorScore: (json['suicidalBehaviorScore'] as num).toInt(),
  lethalityScore: (json['lethalityScore'] as num).toInt(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskLevel: json['riskLevel'] as String,
  clinicalImpression: json['clinicalImpression'] as String,
  safetyPlan: (json['safetyPlan'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  followUpActions: (json['followUpActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SuicideRiskAssessmentToJson(
  SuicideRiskAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'suicidalIdeationScore': instance.suicidalIdeationScore,
  'suicidalBehaviorScore': instance.suicidalBehaviorScore,
  'lethalityScore': instance.lethalityScore,
  'riskFactors': instance.riskFactors,
  'protectiveFactors': instance.protectiveFactors,
  'riskLevel': instance.riskLevel,
  'clinicalImpression': instance.clinicalImpression,
  'safetyPlan': instance.safetyPlan,
  'followUpActions': instance.followUpActions,
  'metadata': instance.metadata,
};

AgitationAssessment _$AgitationAssessmentFromJson(Map<String, dynamic> json) =>
    AgitationAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      motorAgitationScore: (json['motorAgitationScore'] as num).toInt(),
      verbalAgitationScore: (json['verbalAgitationScore'] as num).toInt(),
      aggressiveBehaviorScore: (json['aggressiveBehaviorScore'] as num).toInt(),
      impulsivityScore: (json['impulsivityScore'] as num).toInt(),
      agitationLevel: json['agitationLevel'] as String,
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      calmingTechniques: (json['calmingTechniques'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interventionPlan: json['interventionPlan'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AgitationAssessmentToJson(
  AgitationAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'motorAgitationScore': instance.motorAgitationScore,
  'verbalAgitationScore': instance.verbalAgitationScore,
  'aggressiveBehaviorScore': instance.aggressiveBehaviorScore,
  'impulsivityScore': instance.impulsivityScore,
  'agitationLevel': instance.agitationLevel,
  'triggers': instance.triggers,
  'calmingTechniques': instance.calmingTechniques,
  'interventionPlan': instance.interventionPlan,
  'metadata': instance.metadata,
};

SafetyPlan _$SafetyPlanFromJson(Map<String, dynamic> json) => SafetyPlan(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastUpdated: json['lastUpdated'] == null
      ? null
      : DateTime.parse(json['lastUpdated'] as String),
  warningSigns: (json['warningSigns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  internalCopingStrategies: (json['internalCopingStrategies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  socialSupport: (json['socialSupport'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  professionalHelp: (json['professionalHelp'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  environmentalSafety: (json['environmentalSafety'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  crisisIntervention: (json['crisisIntervention'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  emergencyContact: json['emergencyContact'] as String,
  isActive: json['isActive'] as bool,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SafetyPlanToJson(SafetyPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'warningSigns': instance.warningSigns,
      'internalCopingStrategies': instance.internalCopingStrategies,
      'socialSupport': instance.socialSupport,
      'professionalHelp': instance.professionalHelp,
      'environmentalSafety': instance.environmentalSafety,
      'crisisIntervention': instance.crisisIntervention,
      'emergencyContact': instance.emergencyContact,
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };

CrisisInterventionProtocol _$CrisisInterventionProtocolFromJson(
  Map<String, dynamic> json,
) => CrisisInterventionProtocol(
  id: json['id'] as String,
  crisisType: $enumDecode(_$CrisisTypeEnumMap, json['crisisType']),
  severity: $enumDecode(_$CrisisSeverityEnumMap, json['severity']),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => InterventionStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  requiredResources: (json['requiredResources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  teamMembers: (json['teamMembers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  estimatedDuration: (json['estimatedDuration'] as num).toInt(),
  successCriteria: json['successCriteria'] as String,
  escalationTriggers: (json['escalationTriggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CrisisInterventionProtocolToJson(
  CrisisInterventionProtocol instance,
) => <String, dynamic>{
  'id': instance.id,
  'crisisType': _$CrisisTypeEnumMap[instance.crisisType]!,
  'severity': _$CrisisSeverityEnumMap[instance.severity]!,
  'steps': instance.steps,
  'requiredResources': instance.requiredResources,
  'teamMembers': instance.teamMembers,
  'estimatedDuration': instance.estimatedDuration,
  'successCriteria': instance.successCriteria,
  'escalationTriggers': instance.escalationTriggers,
  'metadata': instance.metadata,
};

InterventionStep _$InterventionStepFromJson(Map<String, dynamic> json) =>
    InterventionStep(
      id: json['id'] as String,
      stepNumber: (json['stepNumber'] as num).toInt(),
      description: json['description'] as String,
      action: json['action'] as String,
      responsiblePerson: json['responsiblePerson'] as String,
      estimatedTime: (json['estimatedTime'] as num).toInt(),
      prerequisites: (json['prerequisites'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      successIndicators: (json['successIndicators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      failureIndicators: (json['failureIndicators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$InterventionStepToJson(InterventionStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stepNumber': instance.stepNumber,
      'description': instance.description,
      'action': instance.action,
      'responsiblePerson': instance.responsiblePerson,
      'estimatedTime': instance.estimatedTime,
      'prerequisites': instance.prerequisites,
      'successIndicators': instance.successIndicators,
      'failureIndicators': instance.failureIndicators,
      'metadata': instance.metadata,
    };

FlagHistory _$FlagHistoryFromJson(Map<String, dynamic> json) => FlagHistory(
  id: json['id'] as String,
  flagId: json['flagId'] as String,
  patientId: json['patientId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  previousStatus: $enumDecode(_$FlagStatusEnumMap, json['previousStatus']),
  newStatus: $enumDecode(_$FlagStatusEnumMap, json['newStatus']),
  changeReason: json['changeReason'] as String,
  notes: json['notes'] as String?,
  changedBy: json['changedBy'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$FlagHistoryToJson(FlagHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flagId': instance.flagId,
      'patientId': instance.patientId,
      'timestamp': instance.timestamp.toIso8601String(),
      'previousStatus': _$FlagStatusEnumMap[instance.previousStatus]!,
      'newStatus': _$FlagStatusEnumMap[instance.newStatus]!,
      'changeReason': instance.changeReason,
      'notes': instance.notes,
      'changedBy': instance.changedBy,
      'metadata': instance.metadata,
    };
