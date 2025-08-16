// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIConfidenceScore _$AIConfidenceScoreFromJson(Map<String, dynamic> json) =>
    AIConfidenceScore(
      score: (json['score'] as num).toDouble(),
      confidence: json['confidence'] as String,
      factors: (json['factors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      explanation: json['explanation'] as String,
    );

Map<String, dynamic> _$AIConfidenceScoreToJson(AIConfidenceScore instance) =>
    <String, dynamic>{
      'score': instance.score,
      'confidence': instance.confidence,
      'factors': instance.factors,
      'explanation': instance.explanation,
    };

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  level: $enumDecode(_$RiskLevelEnumMap, json['level']),
  weight: (json['weight'] as num).toDouble(),
  indicators: (json['indicators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  triggers: (json['triggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'level': _$RiskLevelEnumMap[instance.level]!,
      'weight': instance.weight,
      'indicators': instance.indicators,
      'triggers': instance.triggers,
      'metadata': instance.metadata,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.none: 'none',
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
  RiskLevel.emergency: 'emergency',
};

AIFlagDetection _$AIFlagDetectionFromJson(
  Map<String, dynamic> json,
) => AIFlagDetection(
  id: json['id'] as String,
  type: $enumDecode(_$FlagTypeEnumMap, json['type']),
  riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
  emergencyLevel: $enumDecode(_$EmergencyLevelEnumMap, json['emergencyLevel']),
  confidence: AIConfidenceScore.fromJson(
    json['confidence'] as Map<String, dynamic>,
  ),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: json['summary'] as String,
  detailedAnalysis: json['detailedAnalysis'] as String,
  warningSigns: (json['warningSigns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendedInterventions: (json['recommendedInterventions'] as List<dynamic>)
      .map((e) => $enumDecode(_$InterventionTypeEnumMap, e))
      .toList(),
  aiMetadata: json['aiMetadata'] as Map<String, dynamic>,
  detectedAt: DateTime.parse(json['detectedAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  isActive: json['isActive'] as bool,
  status: json['status'] as String,
);

Map<String, dynamic> _$AIFlagDetectionToJson(AIFlagDetection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$FlagTypeEnumMap[instance.type]!,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'emergencyLevel': _$EmergencyLevelEnumMap[instance.emergencyLevel]!,
      'confidence': instance.confidence,
      'riskFactors': instance.riskFactors,
      'summary': instance.summary,
      'detailedAnalysis': instance.detailedAnalysis,
      'warningSigns': instance.warningSigns,
      'protectiveFactors': instance.protectiveFactors,
      'recommendedInterventions': instance.recommendedInterventions
          .map((e) => _$InterventionTypeEnumMap[e]!)
          .toList(),
      'aiMetadata': instance.aiMetadata,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'isActive': instance.isActive,
      'status': instance.status,
    };

const _$FlagTypeEnumMap = {
  FlagType.suicideRisk: 'suicide_risk',
  FlagType.selfHarm: 'self_harm',
  FlagType.violenceRisk: 'violence_risk',
  FlagType.substanceAbuse: 'substance_abuse',
  FlagType.psychosis: 'psychosis',
  FlagType.manicEpisode: 'manic_episode',
  FlagType.severeDepression: 'severe_depression',
  FlagType.anxietyCrisis: 'anxiety_crisis',
  FlagType.eatingDisorder: 'eating_disorder',
  FlagType.personalityDisorder: 'personality_disorder',
  FlagType.traumaResponse: 'trauma_response',
  FlagType.griefReaction: 'grief_reaction',
  FlagType.medicationIssue: 'medication_issue',
  FlagType.medicalEmergency: 'medical_emergency',
  FlagType.socialCrisis: 'social_crisis',
  FlagType.financialCrisis: 'financial_crisis',
  FlagType.legalIssue: 'legal_issue',
  FlagType.familyCrisis: 'family_crisis',
  FlagType.workCrisis: 'work_crisis',
  FlagType.academicCrisis: 'academic_crisis',
  FlagType.relationshipCrisis: 'relationship_crisis',
  FlagType.other: 'other',
};

const _$EmergencyLevelEnumMap = {
  EmergencyLevel.none: 'none',
  EmergencyLevel.urgent: 'urgent',
  EmergencyLevel.immediate: 'immediate',
  EmergencyLevel.critical: 'critical',
  EmergencyLevel.lifeThreatening: 'life_threatening',
};

const _$InterventionTypeEnumMap = {
  InterventionType.immediateSupport: 'immediate_support',
  InterventionType.crisisIntervention: 'crisis_intervention',
  InterventionType.emergencyServices: 'emergency_services',
  InterventionType.hospitalization: 'hospitalization',
  InterventionType.medicationAdjustment: 'medication_adjustment',
  InterventionType.therapySession: 'therapy_session',
  InterventionType.familyIntervention: 'family_intervention',
  InterventionType.socialSupport: 'social_support',
  InterventionType.legalAssistance: 'legal_assistance',
  InterventionType.financialAssistance: 'financial_assistance',
  InterventionType.other: 'other',
};

CrisisInterventionPlan _$CrisisInterventionPlanFromJson(
  Map<String, dynamic> json,
) => CrisisInterventionPlan(
  id: json['id'] as String,
  flagId: json['flagId'] as String,
  level: $enumDecode(_$EmergencyLevelEnumMap, json['level']),
  interventions: (json['interventions'] as List<dynamic>)
      .map((e) => $enumDecode(_$InterventionTypeEnumMap, e))
      .toList(),
  actionSteps: json['actionSteps'] as Map<String, dynamic>,
  requiredResources: (json['requiredResources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contactPersons: (json['contactPersons'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  emergencyContacts: (json['emergencyContacts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  protocol: json['protocol'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  activatedAt: json['activatedAt'] == null
      ? null
      : DateTime.parse(json['activatedAt'] as String),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  status: json['status'] as String,
  outcomes: json['outcomes'] as Map<String, dynamic>,
  notes: (json['notes'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$CrisisInterventionPlanToJson(
  CrisisInterventionPlan instance,
) => <String, dynamic>{
  'id': instance.id,
  'flagId': instance.flagId,
  'level': _$EmergencyLevelEnumMap[instance.level]!,
  'interventions': instance.interventions
      .map((e) => _$InterventionTypeEnumMap[e]!)
      .toList(),
  'actionSteps': instance.actionSteps,
  'requiredResources': instance.requiredResources,
  'contactPersons': instance.contactPersons,
  'emergencyContacts': instance.emergencyContacts,
  'protocol': instance.protocol,
  'createdAt': instance.createdAt.toIso8601String(),
  'activatedAt': instance.activatedAt?.toIso8601String(),
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'status': instance.status,
  'outcomes': instance.outcomes,
  'notes': instance.notes,
};

EmergencyProtocol _$EmergencyProtocolFromJson(Map<String, dynamic> json) =>
    EmergencyProtocol(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      level: $enumDecode(_$EmergencyLevelEnumMap, json['level']),
      steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
      requiredActions: (json['requiredActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contactPersons: (json['contactPersons'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      emergencyNumbers: (json['emergencyNumbers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      escalationRules: json['escalationRules'] as Map<String, dynamic>,
      countryCode: json['countryCode'] as String,
      region: json['region'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$EmergencyProtocolToJson(EmergencyProtocol instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'level': _$EmergencyLevelEnumMap[instance.level]!,
      'steps': instance.steps,
      'requiredActions': instance.requiredActions,
      'contactPersons': instance.contactPersons,
      'emergencyNumbers': instance.emergencyNumbers,
      'escalationRules': instance.escalationRules,
      'countryCode': instance.countryCode,
      'region': instance.region,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'isActive': instance.isActive,
    };

AIModelPerformance _$AIModelPerformanceFromJson(Map<String, dynamic> json) =>
    AIModelPerformance(
      modelId: json['modelId'] as String,
      version: json['version'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      precision: (json['precision'] as num).toDouble(),
      recall: (json['recall'] as num).toDouble(),
      f1Score: (json['f1Score'] as num).toDouble(),
      falsePositiveRate: (json['falsePositiveRate'] as num).toDouble(),
      falseNegativeRate: (json['falseNegativeRate'] as num).toDouble(),
      totalPredictions: (json['totalPredictions'] as num).toInt(),
      correctPredictions: (json['correctPredictions'] as num).toInt(),
      falsePositives: (json['falsePositives'] as num).toInt(),
      falseNegatives: (json['falseNegatives'] as num).toInt(),
      classAccuracy: (json['classAccuracy'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AIModelPerformanceToJson(AIModelPerformance instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'version': instance.version,
      'accuracy': instance.accuracy,
      'precision': instance.precision,
      'recall': instance.recall,
      'f1Score': instance.f1Score,
      'falsePositiveRate': instance.falsePositiveRate,
      'falseNegativeRate': instance.falseNegativeRate,
      'totalPredictions': instance.totalPredictions,
      'correctPredictions': instance.correctPredictions,
      'falsePositives': instance.falsePositives,
      'falseNegatives': instance.falseNegatives,
      'classAccuracy': instance.classAccuracy,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'metadata': instance.metadata,
    };

FlagHistory _$FlagHistoryFromJson(Map<String, dynamic> json) => FlagHistory(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  detections: (json['detections'] as List<dynamic>)
      .map((e) => AIFlagDetection.fromJson(e as Map<String, dynamic>))
      .toList(),
  interventions: (json['interventions'] as List<dynamic>)
      .map((e) => CrisisInterventionPlan.fromJson(e as Map<String, dynamic>))
      .toList(),
  statistics: json['statistics'] as Map<String, dynamic>,
  patterns: (json['patterns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  trends: (json['trends'] as List<dynamic>).map((e) => e as String).toList(),
  firstDetection: DateTime.parse(json['firstDetection'] as String),
  lastDetection: DateTime.parse(json['lastDetection'] as String),
  totalFlags: (json['totalFlags'] as num).toInt(),
  resolvedFlags: (json['resolvedFlags'] as num).toInt(),
  escalatedFlags: (json['escalatedFlags'] as num).toInt(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$FlagHistoryToJson(FlagHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'detections': instance.detections,
      'interventions': instance.interventions,
      'statistics': instance.statistics,
      'patterns': instance.patterns,
      'trends': instance.trends,
      'firstDetection': instance.firstDetection.toIso8601String(),
      'lastDetection': instance.lastDetection.toIso8601String(),
      'totalFlags': instance.totalFlags,
      'resolvedFlags': instance.resolvedFlags,
      'escalatedFlags': instance.escalatedFlags,
      'metadata': instance.metadata,
    };

AIPredictionModel _$AIPredictionModelFromJson(Map<String, dynamic> json) =>
    AIPredictionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      algorithm: json['algorithm'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      predictionAccuracy: (json['predictionAccuracy'] as num).toDouble(),
      lastTrained: DateTime.parse(json['lastTrained'] as String),
      nextTraining: DateTime.parse(json['nextTraining'] as String),
      isActive: json['isActive'] as bool,
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
      supportedFlagTypes: (json['supportedFlagTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AIPredictionModelToJson(AIPredictionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'algorithm': instance.algorithm,
      'parameters': instance.parameters,
      'features': instance.features,
      'predictionAccuracy': instance.predictionAccuracy,
      'lastTrained': instance.lastTrained.toIso8601String(),
      'nextTraining': instance.nextTraining.toIso8601String(),
      'isActive': instance.isActive,
      'performanceMetrics': instance.performanceMetrics,
      'supportedFlagTypes': instance.supportedFlagTypes,
    };

RealTimeMonitoring _$RealTimeMonitoringFromJson(Map<String, dynamic> json) =>
    RealTimeMonitoring(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      activeFlags: (json['activeFlags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      vitalSigns: json['vitalSigns'] as Map<String, dynamic>,
      behavioralIndicators: (json['behavioralIndicators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      environmentalFactors:
          json['environmentalFactors'] as Map<String, dynamic>,
      riskAlerts: (json['riskAlerts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      isOnline: json['isOnline'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RealTimeMonitoringToJson(RealTimeMonitoring instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'activeFlags': instance.activeFlags,
      'vitalSigns': instance.vitalSigns,
      'behavioralIndicators': instance.behavioralIndicators,
      'environmentalFactors': instance.environmentalFactors,
      'riskAlerts': instance.riskAlerts,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'isOnline': instance.isOnline,
      'metadata': instance.metadata,
    };

InternationalStandards _$InternationalStandardsFromJson(
  Map<String, dynamic> json,
) => InternationalStandards(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  organization: json['organization'] as String,
  country: json['country'] as String,
  version: json['version'] as String,
  publishedDate: DateTime.parse(json['publishedDate'] as String),
  applicableRegions: (json['applicableRegions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  guidelines: json['guidelines'] as Map<String, dynamic>,
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$InternationalStandardsToJson(
  InternationalStandards instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'organization': instance.organization,
  'country': instance.country,
  'version': instance.version,
  'publishedDate': instance.publishedDate.toIso8601String(),
  'applicableRegions': instance.applicableRegions,
  'guidelines': instance.guidelines,
  'references': instance.references,
  'isActive': instance.isActive,
};

MultilingualSupport _$MultilingualSupportFromJson(Map<String, dynamic> json) =>
    MultilingualSupport(
      id: json['id'] as String,
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      nativeName: json['nativeName'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
      culturalAdaptations: Map<String, String>.from(
        json['culturalAdaptations'] as Map,
      ),
      regionalVariations: (json['regionalVariations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isRTL: json['isRTL'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$MultilingualSupportToJson(
  MultilingualSupport instance,
) => <String, dynamic>{
  'id': instance.id,
  'languageCode': instance.languageCode,
  'languageName': instance.languageName,
  'nativeName': instance.nativeName,
  'translations': instance.translations,
  'culturalAdaptations': instance.culturalAdaptations,
  'regionalVariations': instance.regionalVariations,
  'isRTL': instance.isRTL,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'isActive': instance.isActive,
};

CulturalSensitivity _$CulturalSensitivityFromJson(Map<String, dynamic> json) =>
    CulturalSensitivity(
      id: json['id'] as String,
      culture: json['culture'] as String,
      region: json['region'] as String,
      culturalNorms: json['culturalNorms'] as Map<String, dynamic>,
      taboos: (json['taboos'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      preferredPractices: (json['preferredPractices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      communicationStyles: Map<String, String>.from(
        json['communicationStyles'] as Map,
      ),
      familyStructures: (json['familyStructures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      religiousConsiderations:
          json['religiousConsiderations'] as Map<String, dynamic>,
      traditionalHealing: (json['traditionalHealing'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stigmaFactors: json['stigmaFactors'] as Map<String, dynamic>,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$CulturalSensitivityToJson(
  CulturalSensitivity instance,
) => <String, dynamic>{
  'id': instance.id,
  'culture': instance.culture,
  'region': instance.region,
  'culturalNorms': instance.culturalNorms,
  'taboos': instance.taboos,
  'preferredPractices': instance.preferredPractices,
  'communicationStyles': instance.communicationStyles,
  'familyStructures': instance.familyStructures,
  'religiousConsiderations': instance.religiousConsiderations,
  'traditionalHealing': instance.traditionalHealing,
  'stigmaFactors': instance.stigmaFactors,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

PrivacySecurity _$PrivacySecurityFromJson(Map<String, dynamic> json) =>
    PrivacySecurity(
      id: json['id'] as String,
      standard: json['standard'] as String,
      country: json['country'] as String,
      requirements: json['requirements'] as Map<String, dynamic>,
      dataProtectionMeasures: (json['dataProtectionMeasures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      encryptionStandards: (json['encryptionStandards'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      accessControls: (json['accessControls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      auditTrail: json['auditTrail'] as Map<String, dynamic>,
      complianceChecks: (json['complianceChecks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastAudit: DateTime.parse(json['lastAudit'] as String),
      isCompliant: json['isCompliant'] as bool,
    );

Map<String, dynamic> _$PrivacySecurityToJson(PrivacySecurity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'standard': instance.standard,
      'country': instance.country,
      'requirements': instance.requirements,
      'dataProtectionMeasures': instance.dataProtectionMeasures,
      'encryptionStandards': instance.encryptionStandards,
      'accessControls': instance.accessControls,
      'auditTrail': instance.auditTrail,
      'complianceChecks': instance.complianceChecks,
      'lastAudit': instance.lastAudit.toIso8601String(),
      'isCompliant': instance.isCompliant,
    };

PerformanceMonitoring _$PerformanceMonitoringFromJson(
  Map<String, dynamic> json,
) => PerformanceMonitoring(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  systemMetrics: json['systemMetrics'] as Map<String, dynamic>,
  aiMetrics: json['aiMetrics'] as Map<String, dynamic>,
  userMetrics: json['userMetrics'] as Map<String, dynamic>,
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
  recommendations: json['recommendations'] as Map<String, dynamic>,
  isHealthy: json['isHealthy'] as bool,
);

Map<String, dynamic> _$PerformanceMonitoringToJson(
  PerformanceMonitoring instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'systemMetrics': instance.systemMetrics,
  'aiMetrics': instance.aiMetrics,
  'userMetrics': instance.userMetrics,
  'alerts': instance.alerts,
  'recommendations': instance.recommendations,
  'isHealthy': instance.isHealthy,
};
