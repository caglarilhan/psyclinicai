// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crisis_management_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrisisManagementProfile _$CrisisManagementProfileFromJson(
  Map<String, dynamic> json,
) => CrisisManagementProfile(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  createdDate: DateTime.parse(json['createdDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: $enumDecode(_$CrisisStatusEnumMap, json['status']),
  alerts: (json['alerts'] as List<dynamic>)
      .map((e) => CrisisAlert.fromJson(e as Map<String, dynamic>))
      .toList(),
  interventions: (json['interventions'] as List<dynamic>)
      .map((e) => CrisisIntervention.fromJson(e as Map<String, dynamic>))
      .toList(),
  safetyContract: json['safetyContract'] == null
      ? null
      : SafetyContract.fromJson(json['safetyContract'] as Map<String, dynamic>),
  geoFencingRules: (json['geoFencingRules'] as List<dynamic>)
      .map((e) => GeoFencingRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  playbook: CrisisPlaybook.fromJson(json['playbook'] as Map<String, dynamic>),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CrisisManagementProfileToJson(
  CrisisManagementProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'createdDate': instance.createdDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': _$CrisisStatusEnumMap[instance.status]!,
  'alerts': instance.alerts,
  'interventions': instance.interventions,
  'safetyContract': instance.safetyContract,
  'geoFencingRules': instance.geoFencingRules,
  'playbook': instance.playbook,
  'metadata': instance.metadata,
};

const _$CrisisStatusEnumMap = {
  CrisisStatus.stable: 'stable',
  CrisisStatus.monitoring: 'monitoring',
  CrisisStatus.elevatedRisk: 'elevated_risk',
  CrisisStatus.crisis: 'crisis',
  CrisisStatus.intervention: 'intervention',
  CrisisStatus.postCrisis: 'post_crisis',
};

DynamicSuicideRiskScore _$DynamicSuicideRiskScoreFromJson(
  Map<String, dynamic> json,
) => DynamicSuicideRiskScore(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  assessmentDate: DateTime.parse(json['assessmentDate'] as String),
  currentScore: (json['currentScore'] as num).toDouble(),
  previousScore: (json['previousScore'] as num).toDouble(),
  changeRate: (json['changeRate'] as num).toDouble(),
  riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
      .toList(),
  protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
      .map((e) => ProtectiveFactor.fromJson(e as Map<String, dynamic>))
      .toList(),
  warningSigns: (json['warningSigns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$DynamicSuicideRiskScoreToJson(
  DynamicSuicideRiskScore instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'currentScore': instance.currentScore,
  'previousScore': instance.previousScore,
  'changeRate': instance.changeRate,
  'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
  'riskFactors': instance.riskFactors,
  'protectiveFactors': instance.protectiveFactors,
  'warningSigns': instance.warningSigns,
  'recommendations': instance.recommendations,
  'confidence': instance.confidence,
  'notes': instance.notes,
};

const _$RiskLevelEnumMap = {
  RiskLevel.minimal: 'minimal',
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.severe: 'severe',
  RiskLevel.immediate: 'immediate',
};

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  weight: (json['weight'] as num).toDouble(),
  isActive: json['isActive'] as bool,
  onsetDate: DateTime.parse(json['onsetDate'] as String),
  resolutionDate: json['resolutionDate'] == null
      ? null
      : DateTime.parse(json['resolutionDate'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'weight': instance.weight,
      'isActive': instance.isActive,
      'onsetDate': instance.onsetDate.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'notes': instance.notes,
    };

ProtectiveFactor _$ProtectiveFactorFromJson(Map<String, dynamic> json) =>
    ProtectiveFactor(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      strength: (json['strength'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      identifiedDate: DateTime.parse(json['identifiedDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ProtectiveFactorToJson(ProtectiveFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'strength': instance.strength,
      'isActive': instance.isActive,
      'identifiedDate': instance.identifiedDate.toIso8601String(),
      'notes': instance.notes,
    };

CrisisPlaybook _$CrisisPlaybookFromJson(Map<String, dynamic> json) =>
    CrisisPlaybook(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      version: json['version'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      scenarios: (json['scenarios'] as List<dynamic>)
          .map((e) => CrisisScenario.fromJson(e as Map<String, dynamic>))
          .toList(),
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>)
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      protocols: (json['protocols'] as List<dynamic>)
          .map((e) => InterventionProtocol.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CrisisPlaybookToJson(CrisisPlaybook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'region': instance.region,
      'version': instance.version,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'scenarios': instance.scenarios,
      'emergencyContacts': instance.emergencyContacts,
      'protocols': instance.protocols,
      'metadata': instance.metadata,
    };

CrisisScenario _$CrisisScenarioFromJson(Map<String, dynamic> json) =>
    CrisisScenario(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$CrisisTypeEnumMap, json['type']),
      severity: (json['severity'] as num).toDouble(),
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      warningSigns: (json['warningSigns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      immediateActions: (json['immediateActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      followUpActions: (json['followUpActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      resources: (json['resources'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CrisisScenarioToJson(CrisisScenario instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$CrisisTypeEnumMap[instance.type]!,
      'severity': instance.severity,
      'triggers': instance.triggers,
      'warningSigns': instance.warningSigns,
      'immediateActions': instance.immediateActions,
      'followUpActions': instance.followUpActions,
      'resources': instance.resources,
    };

const _$CrisisTypeEnumMap = {
  CrisisType.suicideRisk: 'suicide_risk',
  CrisisType.selfHarm: 'self_harm',
  CrisisType.violentBehavior: 'violent_behavior',
  CrisisType.psychoticEpisode: 'psychotic_episode',
  CrisisType.manicEpisode: 'manic_episode',
  CrisisType.severeDepression: 'severe_depression',
  CrisisType.substanceAbuse: 'substance_abuse',
  CrisisType.domesticViolence: 'domestic_violence',
};

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      isPrimary: json['isPrimary'] as bool,
      isAvailable: json['isAvailable'] as bool,
      lastContact: DateTime.parse(json['lastContact'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$EmergencyContactToJson(EmergencyContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'relationship': instance.relationship,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'address': instance.address,
      'isPrimary': instance.isPrimary,
      'isAvailable': instance.isAvailable,
      'lastContact': instance.lastContact.toIso8601String(),
      'notes': instance.notes,
    };

InterventionProtocol _$InterventionProtocolFromJson(
  Map<String, dynamic> json,
) => InterventionProtocol(
  id: json['id'] as String,
  name: json['name'] as String,
  crisisType: $enumDecode(_$CrisisTypeEnumMap, json['crisisType']),
  severityThreshold: (json['severityThreshold'] as num).toDouble(),
  immediateSteps: (json['immediateSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  assessmentSteps: (json['assessmentSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interventionSteps: (json['interventionSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  followUpSteps: (json['followUpSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiredResources: (json['requiredResources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$InterventionProtocolToJson(
  InterventionProtocol instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'crisisType': _$CrisisTypeEnumMap[instance.crisisType]!,
  'severityThreshold': instance.severityThreshold,
  'immediateSteps': instance.immediateSteps,
  'assessmentSteps': instance.assessmentSteps,
  'interventionSteps': instance.interventionSteps,
  'followUpSteps': instance.followUpSteps,
  'requiredResources': instance.requiredResources,
  'notes': instance.notes,
};

SafetyContract _$SafetyContractFromJson(Map<String, dynamic> json) =>
    SafetyContract(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      status: $enumDecode(_$ContractStatusEnumMap, json['status']),
      commitments: (json['commitments'] as List<dynamic>)
          .map((e) => SafetyCommitment.fromJson(e as Map<String, dynamic>))
          .toList(),
      copingStrategies: (json['copingStrategies'] as List<dynamic>)
          .map((e) => CopingStrategy.fromJson(e as Map<String, dynamic>))
          .toList(),
      emergencyPlans: (json['emergencyPlans'] as List<dynamic>)
          .map((e) => EmergencyPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      warningSigns: (json['warningSigns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$SafetyContractToJson(SafetyContract instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'createdDate': instance.createdDate.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'status': _$ContractStatusEnumMap[instance.status]!,
      'commitments': instance.commitments,
      'copingStrategies': instance.copingStrategies,
      'emergencyPlans': instance.emergencyPlans,
      'warningSigns': instance.warningSigns,
      'actions': instance.actions,
      'notes': instance.notes,
    };

const _$ContractStatusEnumMap = {
  ContractStatus.active: 'active',
  ContractStatus.suspended: 'suspended',
  ContractStatus.violated: 'violated',
  ContractStatus.expired: 'expired',
  ContractStatus.renewed: 'renewed',
};

SafetyCommitment _$SafetyCommitmentFromJson(Map<String, dynamic> json) =>
    SafetyCommitment(
      id: json['id'] as String,
      commitment: json['commitment'] as String,
      date: DateTime.parse(json['date'] as String),
      isKept: json['isKept'] as bool,
      violationDate: json['violationDate'] == null
          ? null
          : DateTime.parse(json['violationDate'] as String),
      violationNotes: json['violationNotes'] as String?,
    );

Map<String, dynamic> _$SafetyCommitmentToJson(SafetyCommitment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'commitment': instance.commitment,
      'date': instance.date.toIso8601String(),
      'isKept': instance.isKept,
      'violationDate': instance.violationDate?.toIso8601String(),
      'violationNotes': instance.violationNotes,
    };

CopingStrategy _$CopingStrategyFromJson(Map<String, dynamic> json) =>
    CopingStrategy(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      effectiveness: (json['effectiveness'] as num).toDouble(),
      steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$CopingStrategyToJson(CopingStrategy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'effectiveness': instance.effectiveness,
      'steps': instance.steps,
      'isActive': instance.isActive,
    };

EmergencyPlan _$EmergencyPlanFromJson(Map<String, dynamic> json) =>
    EmergencyPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
      contacts: (json['contacts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      resources: (json['resources'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$EmergencyPlanToJson(EmergencyPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'steps': instance.steps,
      'contacts': instance.contacts,
      'resources': instance.resources,
      'isActive': instance.isActive,
    };

GeoFencingRule _$GeoFencingRuleFromJson(Map<String, dynamic> json) =>
    GeoFencingRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$GeoFencingTypeEnumMap, json['type']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      restrictedAreas: (json['restrictedAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      safeAreas: (json['safeAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool,
      actions: (json['actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contacts: (json['contacts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GeoFencingRuleToJson(GeoFencingRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$GeoFencingTypeEnumMap[instance.type]!,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius': instance.radius,
      'restrictedAreas': instance.restrictedAreas,
      'safeAreas': instance.safeAreas,
      'isActive': instance.isActive,
      'actions': instance.actions,
      'contacts': instance.contacts,
    };

const _$GeoFencingTypeEnumMap = {
  GeoFencingType.restricted: 'restricted',
  GeoFencingType.safeZone: 'safe_zone',
  GeoFencingType.monitoring: 'monitoring',
  GeoFencingType.intervention: 'intervention',
};

GeoFencingAlert _$GeoFencingAlertFromJson(Map<String, dynamic> json) =>
    GeoFencingAlert(
      id: json['id'] as String,
      ruleId: json['ruleId'] as String,
      patientId: json['patientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      location: json['location'] as String,
      type: json['type'] as String,
      severity: (json['severity'] as num).toDouble(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isAcknowledged: json['isAcknowledged'] as bool,
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.parse(json['acknowledgedAt'] as String),
      acknowledgedBy: json['acknowledgedBy'] as String?,
    );

Map<String, dynamic> _$GeoFencingAlertToJson(GeoFencingAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ruleId': instance.ruleId,
      'patientId': instance.patientId,
      'timestamp': instance.timestamp.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'location': instance.location,
      'type': instance.type,
      'severity': instance.severity,
      'actions': instance.actions,
      'isAcknowledged': instance.isAcknowledged,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': instance.acknowledgedBy,
    };

CrisisIntervention _$CrisisInterventionFromJson(Map<String, dynamic> json) =>
    CrisisIntervention(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      interventionDate: DateTime.parse(json['interventionDate'] as String),
      crisisType: $enumDecode(_$CrisisTypeEnumMap, json['crisisType']),
      severity: (json['severity'] as num).toDouble(),
      description: json['description'] as String,
      actions: (json['actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      outcomes: (json['outcomes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$InterventionStatusEnumMap, json['status']),
      completionDate: json['completionDate'] == null
          ? null
          : DateTime.parse(json['completionDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CrisisInterventionToJson(CrisisIntervention instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'interventionDate': instance.interventionDate.toIso8601String(),
      'crisisType': _$CrisisTypeEnumMap[instance.crisisType]!,
      'severity': instance.severity,
      'description': instance.description,
      'actions': instance.actions,
      'outcomes': instance.outcomes,
      'status': _$InterventionStatusEnumMap[instance.status]!,
      'completionDate': instance.completionDate?.toIso8601String(),
      'notes': instance.notes,
    };

const _$InterventionStatusEnumMap = {
  InterventionStatus.active: 'active',
  InterventionStatus.completed: 'completed',
  InterventionStatus.escalated: 'escalated',
  InterventionStatus.transferred: 'transferred',
};

CrisisAlert _$CrisisAlertFromJson(Map<String, dynamic> json) => CrisisAlert(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  type: json['type'] as String,
  message: json['message'] as String,
  severity: (json['severity'] as num).toDouble(),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  isAcknowledged: json['isAcknowledged'] as bool,
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  acknowledgedBy: json['acknowledgedBy'] as String?,
  escalations: (json['escalations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CrisisAlertToJson(CrisisAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': instance.type,
      'message': instance.message,
      'severity': instance.severity,
      'actions': instance.actions,
      'isAcknowledged': instance.isAcknowledged,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': instance.acknowledgedBy,
      'escalations': instance.escalations,
    };

CrisisManagementSummary _$CrisisManagementSummaryFromJson(
  Map<String, dynamic> json,
) => CrisisManagementSummary(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  summaryDate: DateTime.parse(json['summaryDate'] as String),
  currentStatus: $enumDecode(_$CrisisStatusEnumMap, json['currentStatus']),
  currentRiskScore: (json['currentRiskScore'] as num).toDouble(),
  activeAlerts: (json['activeAlerts'] as List<dynamic>)
      .map((e) => CrisisAlert.fromJson(e as Map<String, dynamic>))
      .toList(),
  recentInterventions: (json['recentInterventions'] as List<dynamic>)
      .map((e) => CrisisIntervention.fromJson(e as Map<String, dynamic>))
      .toList(),
  activeContract: json['activeContract'] == null
      ? null
      : SafetyContract.fromJson(json['activeContract'] as Map<String, dynamic>),
  activeGeoFencing: (json['activeGeoFencing'] as List<dynamic>)
      .map((e) => GeoFencingRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CrisisManagementSummaryToJson(
  CrisisManagementSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'summaryDate': instance.summaryDate.toIso8601String(),
  'currentStatus': _$CrisisStatusEnumMap[instance.currentStatus]!,
  'currentRiskScore': instance.currentRiskScore,
  'activeAlerts': instance.activeAlerts,
  'recentInterventions': instance.recentInterventions,
  'activeContract': instance.activeContract,
  'activeGeoFencing': instance.activeGeoFencing,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
