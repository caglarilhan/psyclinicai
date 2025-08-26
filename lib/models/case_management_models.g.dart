// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_management_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaseManagement _$CaseManagementFromJson(Map<String, dynamic> json) =>
    CaseManagement(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$CaseStatusEnumMap, json['status']),
      priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      primaryDiagnosis: json['primaryDiagnosis'] as String?,
      secondaryDiagnoses: (json['secondaryDiagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatmentGoals: (json['treatmentGoals'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clientInfo: json['clientInfo'] as Map<String, dynamic>,
      treatmentPlan: json['treatmentPlan'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
      supervisorId: json['supervisorId'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CaseManagementToJson(CaseManagement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'title': instance.title,
      'description': instance.description,
      'status': _$CaseStatusEnumMap[instance.status]!,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'primaryDiagnosis': instance.primaryDiagnosis,
      'secondaryDiagnoses': instance.secondaryDiagnoses,
      'treatmentGoals': instance.treatmentGoals,
      'interventions': instance.interventions,
      'clientInfo': instance.clientInfo,
      'treatmentPlan': instance.treatmentPlan,
      'metadata': instance.metadata,
      'supervisorId': instance.supervisorId,
      'notes': instance.notes,
    };

const _$CaseStatusEnumMap = {
  CaseStatus.active: 'active',
  CaseStatus.onHold: 'on_hold',
  CaseStatus.completed: 'completed',
  CaseStatus.transferred: 'transferred',
  CaseStatus.discontinued: 'discontinued',
};

const _$PriorityLevelEnumMap = {
  PriorityLevel.low: 'low',
  PriorityLevel.medium: 'medium',
  PriorityLevel.high: 'high',
  PriorityLevel.urgent: 'urgent',
};

CaseAssessment _$CaseAssessmentFromJson(Map<String, dynamic> json) =>
    CaseAssessment(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      type: $enumDecode(_$AssessmentTypeEnumMap, json['type']),
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      assessorId: json['assessorId'] as String,
      assessorName: json['assessorName'] as String?,
      clinicalFindings: json['clinicalFindings'] as Map<String, dynamic>,
      functionalAssessment:
          json['functionalAssessment'] as Map<String, dynamic>,
      riskAssessment: json['riskAssessment'] as Map<String, dynamic>,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      progressIndicator: $enumDecode(
        _$ProgressIndicatorEnumMap,
        json['progressIndicator'],
      ),
      riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
      summary: json['summary'] as String?,
      scores: json['scores'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CaseAssessmentToJson(
  CaseAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'caseId': instance.caseId,
  'type': _$AssessmentTypeEnumMap[instance.type]!,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'assessorId': instance.assessorId,
  'assessorName': instance.assessorName,
  'clinicalFindings': instance.clinicalFindings,
  'functionalAssessment': instance.functionalAssessment,
  'riskAssessment': instance.riskAssessment,
  'strengths': instance.strengths,
  'challenges': instance.challenges,
  'recommendations': instance.recommendations,
  'progressIndicator': _$ProgressIndicatorEnumMap[instance.progressIndicator]!,
  'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
  'summary': instance.summary,
  'scores': instance.scores,
  'metadata': instance.metadata,
  'attachments': instance.attachments,
};

const _$AssessmentTypeEnumMap = {
  AssessmentType.initial: 'initial',
  AssessmentType.progress: 'progress',
  AssessmentType.final_: 'final',
  AssessmentType.crisis: 'crisis',
  AssessmentType.followUp: 'follow_up',
};

const _$ProgressIndicatorEnumMap = {
  ProgressIndicator.improving: 'improving',
  ProgressIndicator.stable: 'stable',
  ProgressIndicator.declining: 'declining',
  ProgressIndicator.fluctuating: 'fluctuating',
};

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

CaseProgress _$CaseProgressFromJson(Map<String, dynamic> json) => CaseProgress(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  progressDate: DateTime.parse(json['progressDate'] as String),
  recordedBy: json['recordedBy'] as String,
  recordedByName: json['recordedByName'] as String?,
  progressNote: json['progressNote'] as String,
  indicator: $enumDecode(_$ProgressIndicatorEnumMap, json['indicator']),
  achievedGoals: (json['achievedGoals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  newGoals: (json['newGoals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interventions: (json['interventions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  measurements: json['measurements'] as Map<String, dynamic>,
  observations: json['observations'] as Map<String, dynamic>,
  nextSteps: json['nextSteps'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>,
  relatedSessions: (json['relatedSessions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CaseProgressToJson(CaseProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'progressDate': instance.progressDate.toIso8601String(),
      'recordedBy': instance.recordedBy,
      'recordedByName': instance.recordedByName,
      'progressNote': instance.progressNote,
      'indicator': _$ProgressIndicatorEnumMap[instance.indicator]!,
      'achievedGoals': instance.achievedGoals,
      'newGoals': instance.newGoals,
      'interventions': instance.interventions,
      'measurements': instance.measurements,
      'observations': instance.observations,
      'nextSteps': instance.nextSteps,
      'metadata': instance.metadata,
      'relatedSessions': instance.relatedSessions,
    };

TreatmentGoal _$TreatmentGoalFromJson(Map<String, dynamic> json) =>
    TreatmentGoal(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      achievedDate: json['achievedDate'] == null
          ? null
          : DateTime.parse(json['achievedDate'] as String),
      isAchieved: json['isAchieved'] as bool,
      priority: (json['priority'] as num).toInt(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      measurements: json['measurements'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TreatmentGoalToJson(TreatmentGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'targetDate': instance.targetDate.toIso8601String(),
      'achievedDate': instance.achievedDate?.toIso8601String(),
      'isAchieved': instance.isAchieved,
      'priority': instance.priority,
      'milestones': instance.milestones,
      'interventions': instance.interventions,
      'measurements': instance.measurements,
      'metadata': instance.metadata,
      'notes': instance.notes,
    };

CaseTimeline _$CaseTimelineFromJson(Map<String, dynamic> json) => CaseTimeline(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  eventDate: DateTime.parse(json['eventDate'] as String),
  eventType: json['eventType'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  performedBy: json['performedBy'] as String?,
  eventData: json['eventData'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CaseTimelineToJson(CaseTimeline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'eventDate': instance.eventDate.toIso8601String(),
      'eventType': instance.eventType,
      'title': instance.title,
      'description': instance.description,
      'performedBy': instance.performedBy,
      'eventData': instance.eventData,
      'metadata': instance.metadata,
    };

CaseSummary _$CaseSummaryFromJson(Map<String, dynamic> json) => CaseSummary(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  generatedBy: json['generatedBy'] as String,
  summary: json['summary'] as String,
  keyMetrics: json['keyMetrics'] as Map<String, dynamic>,
  achievements: (json['achievements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  challenges: (json['challenges'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  statistics: json['statistics'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CaseSummaryToJson(CaseSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'generatedBy': instance.generatedBy,
      'summary': instance.summary,
      'keyMetrics': instance.keyMetrics,
      'achievements': instance.achievements,
      'challenges': instance.challenges,
      'recommendations': instance.recommendations,
      'statistics': instance.statistics,
      'metadata': instance.metadata,
    };

CaseAlert _$CaseAlertFromJson(Map<String, dynamic> json) => CaseAlert(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  alertType: json['alertType'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  acknowledgedBy: json['acknowledgedBy'] as String?,
  isActive: json['isActive'] as bool,
  alertData: json['alertData'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CaseAlertToJson(CaseAlert instance) => <String, dynamic>{
  'id': instance.id,
  'caseId': instance.caseId,
  'alertType': instance.alertType,
  'title': instance.title,
  'message': instance.message,
  'priority': _$PriorityLevelEnumMap[instance.priority]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
  'acknowledgedBy': instance.acknowledgedBy,
  'isActive': instance.isActive,
  'alertData': instance.alertData,
  'metadata': instance.metadata,
};

CaseStatistics _$CaseStatisticsFromJson(Map<String, dynamic> json) =>
    CaseStatistics(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      totalSessions: (json['totalSessions'] as num).toInt(),
      completedSessions: (json['completedSessions'] as num).toInt(),
      totalAssessments: (json['totalAssessments'] as num).toInt(),
      achievedGoals: (json['achievedGoals'] as num).toInt(),
      totalGoals: (json['totalGoals'] as num).toInt(),
      averageProgressScore: (json['averageProgressScore'] as num).toDouble(),
      riskScore: (json['riskScore'] as num).toDouble(),
      progressTrend: json['progressTrend'] as Map<String, dynamic>,
      goalAchievement: json['goalAchievement'] as Map<String, dynamic>,
      interventionEffectiveness:
          json['interventionEffectiveness'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CaseStatisticsToJson(CaseStatistics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'calculatedAt': instance.calculatedAt.toIso8601String(),
      'totalSessions': instance.totalSessions,
      'completedSessions': instance.completedSessions,
      'totalAssessments': instance.totalAssessments,
      'achievedGoals': instance.achievedGoals,
      'totalGoals': instance.totalGoals,
      'averageProgressScore': instance.averageProgressScore,
      'riskScore': instance.riskScore,
      'progressTrend': instance.progressTrend,
      'goalAchievement': instance.goalAchievement,
      'interventionEffectiveness': instance.interventionEffectiveness,
      'metadata': instance.metadata,
    };
