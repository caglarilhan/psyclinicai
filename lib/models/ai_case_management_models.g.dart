// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_case_management_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AICaseAnalysis _$AICaseAnalysisFromJson(Map<String, dynamic> json) =>
    AICaseAnalysis(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      type: $enumDecode(_$CaseAnalysisTypeEnumMap, json['type']),
      confidence: (json['confidence'] as num).toDouble(),
      summary: json['summary'] as String,
      insights: (json['insights'] as List<dynamic>)
          .map((e) => CaseInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      data: json['data'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$AICaseAnalysisToJson(AICaseAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'type': _$CaseAnalysisTypeEnumMap[instance.type]!,
      'confidence': instance.confidence,
      'summary': instance.summary,
      'insights': instance.insights,
      'riskFactors': instance.riskFactors,
      'recommendations': instance.recommendations,
      'data': instance.data,
      'notes': instance.notes,
      'isActive': instance.isActive,
    };

const _$CaseAnalysisTypeEnumMap = {
  CaseAnalysisType.initial: 'initial',
  CaseAnalysisType.progress: 'progress',
  CaseAnalysisType.risk: 'risk',
  CaseAnalysisType.outcome: 'outcome',
  CaseAnalysisType.relapse: 'relapse',
  CaseAnalysisType.maintenance: 'maintenance',
  CaseAnalysisType.crisis: 'crisis',
};

CaseInsight _$CaseInsightFromJson(Map<String, dynamic> json) => CaseInsight(
  id: json['id'] as String,
  category: $enumDecode(_$InsightCategoryEnumMap, json['category']),
  title: json['title'] as String,
  description: json['description'] as String,
  importance: (json['importance'] as num).toDouble(),
  evidence: (json['evidence'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActioned: json['isActioned'] as bool,
);

Map<String, dynamic> _$CaseInsightToJson(CaseInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$InsightCategoryEnumMap[instance.category]!,
      'title': instance.title,
      'description': instance.description,
      'importance': instance.importance,
      'evidence': instance.evidence,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActioned': instance.isActioned,
    };

const _$InsightCategoryEnumMap = {
  InsightCategory.behavioral: 'behavioral',
  InsightCategory.emotional: 'emotional',
  InsightCategory.cognitive: 'cognitive',
  InsightCategory.social: 'social',
  InsightCategory.environmental: 'environmental',
  InsightCategory.medical: 'medical',
  InsightCategory.therapeutic: 'therapeutic',
};

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  type: $enumDecode(_$RiskTypeEnumMap, json['type']),
  severity: $enumDecode(_$RiskSeverityEnumMap, json['severity']),
  description: json['description'] as String,
  probability: (json['probability'] as num).toDouble(),
  indicators: (json['indicators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  mitigationStrategies: (json['mitigationStrategies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  identifiedAt: DateTime.parse(json['identifiedAt'] as String),
  isMonitored: json['isMonitored'] as bool,
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$RiskTypeEnumMap[instance.type]!,
      'severity': _$RiskSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'probability': instance.probability,
      'indicators': instance.indicators,
      'mitigationStrategies': instance.mitigationStrategies,
      'identifiedAt': instance.identifiedAt.toIso8601String(),
      'isMonitored': instance.isMonitored,
    };

const _$RiskTypeEnumMap = {
  RiskType.selfHarm: 'selfHarm',
  RiskType.harmToOthers: 'harmToOthers',
  RiskType.substanceAbuse: 'substanceAbuse',
  RiskType.relapse: 'relapse',
  RiskType.nonCompliance: 'nonCompliance',
  RiskType.crisis: 'crisis',
  RiskType.medical: 'medical',
  RiskType.social: 'social',
};

const _$RiskSeverityEnumMap = {
  RiskSeverity.low: 'low',
  RiskSeverity.moderate: 'moderate',
  RiskSeverity.high: 'high',
  RiskSeverity.critical: 'critical',
};

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      id: json['id'] as String,
      type: $enumDecode(_$RecommendationTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      priority: (json['priority'] as num).toDouble(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$RecommendationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'actions': instance.actions,
      'dueDate': instance.dueDate.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$RecommendationTypeEnumMap = {
  RecommendationType.assessment: 'assessment',
  RecommendationType.intervention: 'intervention',
  RecommendationType.referral: 'referral',
  RecommendationType.monitoring: 'monitoring',
  RecommendationType.education: 'education',
  RecommendationType.support: 'support',
  RecommendationType.crisis: 'crisis',
};

ProgressTracking _$ProgressTrackingFromJson(Map<String, dynamic> json) =>
    ProgressTracking(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      metrics: (json['metrics'] as List<dynamic>)
          .map((e) => ProgressMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$ProgressStatusEnumMap, json['status']),
      overallProgress: (json['overallProgress'] as num).toDouble(),
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ProgressTrackingToJson(ProgressTracking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'metrics': instance.metrics,
      'goals': instance.goals,
      'milestones': instance.milestones,
      'status': _$ProgressStatusEnumMap[instance.status]!,
      'overallProgress': instance.overallProgress,
      'data': instance.data,
    };

const _$ProgressStatusEnumMap = {
  ProgressStatus.improving: 'improving',
  ProgressStatus.stable: 'stable',
  ProgressStatus.declining: 'declining',
  ProgressStatus.crisis: 'crisis',
  ProgressStatus.maintenance: 'maintenance',
};

ProgressMetric _$ProgressMetricFromJson(Map<String, dynamic> json) =>
    ProgressMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      baselineValue: (json['baselineValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      targetValue: (json['targetValue'] as num).toDouble(),
      unit: json['unit'] as String,
      trend: $enumDecode(_$MetricTrendEnumMap, json['trend']),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$ProgressMetricToJson(ProgressMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'baselineValue': instance.baselineValue,
      'currentValue': instance.currentValue,
      'targetValue': instance.targetValue,
      'unit': instance.unit,
      'trend': _$MetricTrendEnumMap[instance.trend]!,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

const _$MetricTrendEnumMap = {
  MetricTrend.improving: 'improving',
  MetricTrend.stable: 'stable',
  MetricTrend.declining: 'declining',
  MetricTrend.fluctuating: 'fluctuating',
};

Goal _$GoalFromJson(Map<String, dynamic> json) => Goal(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$GoalTypeEnumMap, json['type']),
  priority: $enumDecode(_$GoalPriorityEnumMap, json['priority']),
  targetDate: DateTime.parse(json['targetDate'] as String),
  status: $enumDecode(_$GoalStatusEnumMap, json['status']),
  completionPercentage: (json['completionPercentage'] as num).toDouble(),
  subGoals: (json['subGoals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$GoalTypeEnumMap[instance.type]!,
  'priority': _$GoalPriorityEnumMap[instance.priority]!,
  'targetDate': instance.targetDate.toIso8601String(),
  'status': _$GoalStatusEnumMap[instance.status]!,
  'completionPercentage': instance.completionPercentage,
  'subGoals': instance.subGoals,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$GoalTypeEnumMap = {
  GoalType.symptom: 'symptom',
  GoalType.functional: 'functional',
  GoalType.behavioral: 'behavioral',
  GoalType.cognitive: 'cognitive',
  GoalType.social: 'social',
  GoalType.occupational: 'occupational',
  GoalType.qualityOfLife: 'qualityOfLife',
};

const _$GoalPriorityEnumMap = {
  GoalPriority.low: 'low',
  GoalPriority.medium: 'medium',
  GoalPriority.high: 'high',
  GoalPriority.critical: 'critical',
};

const _$GoalStatusEnumMap = {
  GoalStatus.notStarted: 'notStarted',
  GoalStatus.inProgress: 'inProgress',
  GoalStatus.completed: 'completed',
  GoalStatus.onHold: 'onHold',
  GoalStatus.cancelled: 'cancelled',
};

Milestone _$MilestoneFromJson(Map<String, dynamic> json) => Milestone(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  targetDate: DateTime.parse(json['targetDate'] as String),
  achievedDate: json['achievedDate'] == null
      ? null
      : DateTime.parse(json['achievedDate'] as String),
  status: $enumDecode(_$MilestoneStatusEnumMap, json['status']),
  criteria: (json['criteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  importance: (json['importance'] as num).toDouble(),
);

Map<String, dynamic> _$MilestoneToJson(Milestone instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'targetDate': instance.targetDate.toIso8601String(),
  'achievedDate': instance.achievedDate?.toIso8601String(),
  'status': _$MilestoneStatusEnumMap[instance.status]!,
  'criteria': instance.criteria,
  'importance': instance.importance,
};

const _$MilestoneStatusEnumMap = {
  MilestoneStatus.pending: 'pending',
  MilestoneStatus.inProgress: 'inProgress',
  MilestoneStatus.achieved: 'achieved',
  MilestoneStatus.overdue: 'overdue',
  MilestoneStatus.cancelled: 'cancelled',
};

DevelopmentReport _$DevelopmentReportFromJson(Map<String, dynamic> json) =>
    DevelopmentReport(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      executiveSummary: json['executiveSummary'] as String,
      keyMetrics: (json['keyMetrics'] as List<dynamic>)
          .map((e) => ProgressMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      keyInsights: (json['keyInsights'] as List<dynamic>)
          .map((e) => CaseInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeRisks: (json['activeRisks'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextSteps: (json['nextSteps'] as List<dynamic>)
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallProgress: (json['overallProgress'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DevelopmentReportToJson(DevelopmentReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'reportDate': instance.reportDate.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'executiveSummary': instance.executiveSummary,
      'keyMetrics': instance.keyMetrics,
      'keyInsights': instance.keyInsights,
      'activeRisks': instance.activeRisks,
      'nextSteps': instance.nextSteps,
      'overallProgress': instance.overallProgress,
      'notes': instance.notes,
    };

SecurityAudit _$SecurityAuditFromJson(Map<String, dynamic> json) =>
    SecurityAudit(
      id: json['id'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      resource: json['resource'] as String,
      ipAddress: json['ipAddress'] as String,
      userAgent: json['userAgent'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: $enumDecode(_$AuditSeverityEnumMap, json['severity']),
      isSuccessful: json['isSuccessful'] as bool,
      failureReason: json['failureReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SecurityAuditToJson(SecurityAudit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'action': instance.action,
      'resource': instance.resource,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'timestamp': instance.timestamp.toIso8601String(),
      'severity': _$AuditSeverityEnumMap[instance.severity]!,
      'isSuccessful': instance.isSuccessful,
      'failureReason': instance.failureReason,
      'metadata': instance.metadata,
    };

const _$AuditSeverityEnumMap = {
  AuditSeverity.info: 'info',
  AuditSeverity.warning: 'warning',
  AuditSeverity.error: 'error',
  AuditSeverity.critical: 'critical',
};

EncryptionKey _$EncryptionKeyFromJson(Map<String, dynamic> json) =>
    EncryptionKey(
      id: json['id'] as String,
      keyId: json['keyId'] as String,
      algorithm: json['algorithm'] as String,
      keySize: (json['keySize'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EncryptionKeyToJson(EncryptionKey instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyId': instance.keyId,
      'algorithm': instance.algorithm,
      'keySize': instance.keySize,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isActive': instance.isActive,
      'description': instance.description,
      'metadata': instance.metadata,
    };

BiometricAuth _$BiometricAuthFromJson(Map<String, dynamic> json) =>
    BiometricAuth(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$BiometricTypeEnumMap, json['type']),
      identifier: json['identifier'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      isActive: json['isActive'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$BiometricAuthToJson(BiometricAuth instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$BiometricTypeEnumMap[instance.type]!,
      'identifier': instance.identifier,
      'registeredAt': instance.registeredAt.toIso8601String(),
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };

const _$BiometricTypeEnumMap = {
  BiometricType.fingerprint: 'fingerprint',
  BiometricType.face: 'face',
  BiometricType.iris: 'iris',
  BiometricType.voice: 'voice',
  BiometricType.gait: 'gait',
  BiometricType.heartbeat: 'heartbeat',
};

BlockchainRecord _$BlockchainRecordFromJson(Map<String, dynamic> json) =>
    BlockchainRecord(
      id: json['id'] as String,
      hash: json['hash'] as String,
      previousHash: json['previousHash'] as String,
      data: json['data'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      recordType: json['recordType'] as String,
      isImmutable: json['isImmutable'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$BlockchainRecordToJson(BlockchainRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hash': instance.hash,
      'previousHash': instance.previousHash,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
      'userId': instance.userId,
      'recordType': instance.recordType,
      'isImmutable': instance.isImmutable,
      'metadata': instance.metadata,
    };

ComplianceCheck _$ComplianceCheckFromJson(Map<String, dynamic> json) =>
    ComplianceCheck(
      id: json['id'] as String,
      standard: json['standard'] as String,
      requirement: json['requirement'] as String,
      status: $enumDecode(_$ComplianceStatusEnumMap, json['status']),
      lastChecked: DateTime.parse(json['lastChecked'] as String),
      nextCheck: json['nextCheck'] == null
          ? null
          : DateTime.parse(json['nextCheck'] as String),
      notes: json['notes'] as String?,
      violations: (json['violations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      remediationSteps: (json['remediationSteps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ComplianceCheckToJson(ComplianceCheck instance) =>
    <String, dynamic>{
      'id': instance.id,
      'standard': instance.standard,
      'requirement': instance.requirement,
      'status': _$ComplianceStatusEnumMap[instance.status]!,
      'lastChecked': instance.lastChecked.toIso8601String(),
      'nextCheck': instance.nextCheck?.toIso8601String(),
      'notes': instance.notes,
      'violations': instance.violations,
      'remediationSteps': instance.remediationSteps,
    };

const _$ComplianceStatusEnumMap = {
  ComplianceStatus.compliant: 'compliant',
  ComplianceStatus.nonCompliant: 'nonCompliant',
  ComplianceStatus.partiallyCompliant: 'partiallyCompliant',
  ComplianceStatus.underReview: 'underReview',
  ComplianceStatus.pending: 'pending',
};

PrivacyConsent _$PrivacyConsentFromJson(Map<String, dynamic> json) =>
    PrivacyConsent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      consentType: json['consentType'] as String,
      isGranted: json['isGranted'] as bool,
      grantedAt: DateTime.parse(json['grantedAt'] as String),
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
      revocationReason: json['revocationReason'] as String?,
      purposes: (json['purposes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PrivacyConsentToJson(PrivacyConsent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'consentType': instance.consentType,
      'isGranted': instance.isGranted,
      'grantedAt': instance.grantedAt.toIso8601String(),
      'revokedAt': instance.revokedAt?.toIso8601String(),
      'revocationReason': instance.revocationReason,
      'purposes': instance.purposes,
      'metadata': instance.metadata,
    };

RegionConfig _$RegionConfigFromJson(Map<String, dynamic> json) => RegionConfig(
  id: json['id'] as String,
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  language: json['language'] as String,
  currency: json['currency'] as String,
  timezone: json['timezone'] as String,
  supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  healthcareStandards: json['healthcareStandards'] as Map<String, dynamic>,
  privacyLaws: json['privacyLaws'] as Map<String, dynamic>,
  drugDatabases: json['drugDatabases'] as Map<String, dynamic>,
  culturalNorms: json['culturalNorms'] as Map<String, dynamic>,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$RegionConfigToJson(RegionConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'countryCode': instance.countryCode,
      'countryName': instance.countryName,
      'language': instance.language,
      'currency': instance.currency,
      'timezone': instance.timezone,
      'supportedLanguages': instance.supportedLanguages,
      'healthcareStandards': instance.healthcareStandards,
      'privacyLaws': instance.privacyLaws,
      'drugDatabases': instance.drugDatabases,
      'culturalNorms': instance.culturalNorms,
      'isActive': instance.isActive,
    };

CulturalSensitivity _$CulturalSensitivityFromJson(Map<String, dynamic> json) =>
    CulturalSensitivity(
      id: json['id'] as String,
      regionId: json['regionId'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      level: $enumDecode(_$SensitivityLevelEnumMap, json['level']),
      guidelines: (json['guidelines'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      taboos: (json['taboos'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CulturalSensitivityToJson(
  CulturalSensitivity instance,
) => <String, dynamic>{
  'id': instance.id,
  'regionId': instance.regionId,
  'category': instance.category,
  'description': instance.description,
  'level': _$SensitivityLevelEnumMap[instance.level]!,
  'guidelines': instance.guidelines,
  'taboos': instance.taboos,
  'metadata': instance.metadata,
};

const _$SensitivityLevelEnumMap = {
  SensitivityLevel.low: 'low',
  SensitivityLevel.medium: 'medium',
  SensitivityLevel.high: 'high',
  SensitivityLevel.critical: 'critical',
};

CaseSummary _$CaseSummaryFromJson(Map<String, dynamic> json) => CaseSummary(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$CaseStatusEnumMap, json['status']),
  openedAt: DateTime.parse(json['openedAt'] as String),
  closedAt: json['closedAt'] == null
      ? null
      : DateTime.parse(json['closedAt'] as String),
  diagnoses: (json['diagnoses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  keyIssues: (json['keyIssues'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  progressPercentage: (json['progressPercentage'] as num).toDouble(),
  recentInsights: (json['recentInsights'] as List<dynamic>)
      .map((e) => CaseInsight.fromJson(e as Map<String, dynamic>))
      .toList(),
  activeRisks: (json['activeRisks'] as List<dynamic>)
      .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CaseSummaryToJson(CaseSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'title': instance.title,
      'description': instance.description,
      'status': _$CaseStatusEnumMap[instance.status]!,
      'openedAt': instance.openedAt.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'diagnoses': instance.diagnoses,
      'medications': instance.medications,
      'keyIssues': instance.keyIssues,
      'progressPercentage': instance.progressPercentage,
      'recentInsights': instance.recentInsights,
      'activeRisks': instance.activeRisks,
      'metadata': instance.metadata,
    };

const _$CaseStatusEnumMap = {
  CaseStatus.active: 'active',
  CaseStatus.onHold: 'onHold',
  CaseStatus.closed: 'closed',
  CaseStatus.transferred: 'transferred',
  CaseStatus.archived: 'archived',
};

CasePriority _$CasePriorityFromJson(Map<String, dynamic> json) => CasePriority(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  caseTitle: json['caseTitle'] as String,
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
  aiConfidence: (json['aiConfidence'] as num).toDouble(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CasePriorityToJson(CasePriority instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'caseTitle': instance.caseTitle,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'aiConfidence': instance.aiConfidence,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'notes': instance.notes,
    };

const _$PriorityEnumMap = {
  Priority.high: 'high',
  Priority.medium: 'medium',
  Priority.low: 'low',
};

const _$RiskLevelEnumMap = {
  RiskLevel.high: 'high',
  RiskLevel.medium: 'medium',
  RiskLevel.low: 'low',
};
