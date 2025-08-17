// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'real_time_crisis_intervention.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealTimeCrisisIntervention _$RealTimeCrisisInterventionFromJson(
  Map<String, dynamic> json,
) => RealTimeCrisisIntervention(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  version: json['version'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  crisisFeatures: json['crisisFeatures'] as Map<String, dynamic>,
  interventionFeatures: json['interventionFeatures'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RealTimeCrisisInterventionToJson(
  RealTimeCrisisIntervention instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'version': instance.version,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'crisisFeatures': instance.crisisFeatures,
  'interventionFeatures': instance.interventionFeatures,
  'metadata': instance.metadata,
};

AIRiskDetection _$AIRiskDetectionFromJson(Map<String, dynamic> json) =>
    AIRiskDetection(
      id: json['id'] as String,
      detectionId: json['detectionId'] as String,
      patientId: json['patientId'] as String,
      detectionTime: DateTime.parse(json['detectionTime'] as String),
      riskType: json['riskType'] as String,
      riskLevel: json['riskLevel'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      warningSigns: (json['warningSigns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskMetrics: json['riskMetrics'] as Map<String, dynamic>,
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AIRiskDetectionToJson(AIRiskDetection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'detectionId': instance.detectionId,
      'patientId': instance.patientId,
      'detectionTime': instance.detectionTime.toIso8601String(),
      'riskType': instance.riskType,
      'riskLevel': instance.riskLevel,
      'confidenceScore': instance.confidenceScore,
      'riskFactors': instance.riskFactors,
      'warningSigns': instance.warningSigns,
      'riskMetrics': instance.riskMetrics,
      'status': instance.status,
      'metadata': instance.metadata,
    };

EmergencyProtocols _$EmergencyProtocolsFromJson(Map<String, dynamic> json) =>
    EmergencyProtocols(
      id: json['id'] as String,
      protocolId: json['protocolId'] as String,
      protocolName: json['protocolName'] as String,
      description: json['description'] as String,
      emergencyType: json['emergencyType'] as String,
      severity: json['severity'] as String,
      immediateActions: (json['immediateActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      requiredResources: (json['requiredResources'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contactPersons: (json['contactPersons'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      escalationSteps: (json['escalationSteps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      protocolDetails: json['protocolDetails'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EmergencyProtocolsToJson(EmergencyProtocols instance) =>
    <String, dynamic>{
      'id': instance.id,
      'protocolId': instance.protocolId,
      'protocolName': instance.protocolName,
      'description': instance.description,
      'emergencyType': instance.emergencyType,
      'severity': instance.severity,
      'immediateActions': instance.immediateActions,
      'requiredResources': instance.requiredResources,
      'contactPersons': instance.contactPersons,
      'escalationSteps': instance.escalationSteps,
      'protocolDetails': instance.protocolDetails,
      'metadata': instance.metadata,
    };

GlobalCrisisHotlines _$GlobalCrisisHotlinesFromJson(
  Map<String, dynamic> json,
) => GlobalCrisisHotlines(
  id: json['id'] as String,
  hotlineId: json['hotlineId'] as String,
  hotlineName: json['hotlineName'] as String,
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  website: json['website'] as String,
  services: (json['services'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  languages: (json['languages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  operatingHours: json['operatingHours'] as Map<String, dynamic>,
  status: json['status'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$GlobalCrisisHotlinesToJson(
  GlobalCrisisHotlines instance,
) => <String, dynamic>{
  'id': instance.id,
  'hotlineId': instance.hotlineId,
  'hotlineName': instance.hotlineName,
  'countryCode': instance.countryCode,
  'countryName': instance.countryName,
  'phoneNumber': instance.phoneNumber,
  'website': instance.website,
  'services': instance.services,
  'languages': instance.languages,
  'operatingHours': instance.operatingHours,
  'status': instance.status,
  'metadata': instance.metadata,
};

RealTimeMonitoring _$RealTimeMonitoringFromJson(Map<String, dynamic> json) =>
    RealTimeMonitoring(
      id: json['id'] as String,
      monitoringId: json['monitoringId'] as String,
      patientId: json['patientId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      monitoringType: json['monitoringType'] as String,
      monitoredParameters: (json['monitoredParameters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      baselineData: json['baselineData'] as Map<String, dynamic>,
      currentData: json['currentData'] as Map<String, dynamic>,
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RealTimeMonitoringToJson(RealTimeMonitoring instance) =>
    <String, dynamic>{
      'id': instance.id,
      'monitoringId': instance.monitoringId,
      'patientId': instance.patientId,
      'startTime': instance.startTime.toIso8601String(),
      'monitoringType': instance.monitoringType,
      'monitoredParameters': instance.monitoredParameters,
      'baselineData': instance.baselineData,
      'currentData': instance.currentData,
      'alerts': instance.alerts,
      'interventions': instance.interventions,
      'status': instance.status,
      'metadata': instance.metadata,
    };

CrisisInterventionTeam _$CrisisInterventionTeamFromJson(
  Map<String, dynamic> json,
) => CrisisInterventionTeam(
  id: json['id'] as String,
  teamId: json['teamId'] as String,
  teamName: json['teamName'] as String,
  teamType: json['teamType'] as String,
  teamMembers: (json['teamMembers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  teamLeader: json['teamLeader'] as String,
  specializations: (json['specializations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contactMethods: (json['contactMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  availabilityStatus: json['availabilityStatus'] as String,
  responseMetrics: json['responseMetrics'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CrisisInterventionTeamToJson(
  CrisisInterventionTeam instance,
) => <String, dynamic>{
  'id': instance.id,
  'teamId': instance.teamId,
  'teamName': instance.teamName,
  'teamType': instance.teamType,
  'teamMembers': instance.teamMembers,
  'teamLeader': instance.teamLeader,
  'specializations': instance.specializations,
  'contactMethods': instance.contactMethods,
  'availabilityStatus': instance.availabilityStatus,
  'responseMetrics': instance.responseMetrics,
  'metadata': instance.metadata,
};

EmergencyInterventionPlan _$EmergencyInterventionPlanFromJson(
  Map<String, dynamic> json,
) => EmergencyInterventionPlan(
  id: json['id'] as String,
  planId: json['planId'] as String,
  patientId: json['patientId'] as String,
  crisisType: json['crisisType'] as String,
  creationTime: DateTime.parse(json['creationTime'] as String),
  severity: json['severity'] as String,
  immediateActions: (json['immediateActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  shortTermActions: (json['shortTermActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  longTermActions: (json['longTermActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiredResources: (json['requiredResources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contactPersons: (json['contactPersons'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$EmergencyInterventionPlanToJson(
  EmergencyInterventionPlan instance,
) => <String, dynamic>{
  'id': instance.id,
  'planId': instance.planId,
  'patientId': instance.patientId,
  'crisisType': instance.crisisType,
  'creationTime': instance.creationTime.toIso8601String(),
  'severity': instance.severity,
  'immediateActions': instance.immediateActions,
  'shortTermActions': instance.shortTermActions,
  'longTermActions': instance.longTermActions,
  'requiredResources': instance.requiredResources,
  'contactPersons': instance.contactPersons,
  'status': instance.status,
  'metadata': instance.metadata,
};

RiskAlertSystem _$RiskAlertSystemFromJson(Map<String, dynamic> json) =>
    RiskAlertSystem(
      id: json['id'] as String,
      alertId: json['alertId'] as String,
      patientId: json['patientId'] as String,
      alertType: json['alertType'] as String,
      alertTime: DateTime.parse(json['alertTime'] as String),
      severity: json['severity'] as String,
      description: json['description'] as String,
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendedActions: (json['recommendedActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RiskAlertSystemToJson(RiskAlertSystem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alertId': instance.alertId,
      'patientId': instance.patientId,
      'alertType': instance.alertType,
      'alertTime': instance.alertTime.toIso8601String(),
      'severity': instance.severity,
      'description': instance.description,
      'riskFactors': instance.riskFactors,
      'recommendedActions': instance.recommendedActions,
      'status': instance.status,
      'metadata': instance.metadata,
    };

SafetyPlan _$SafetyPlanFromJson(Map<String, dynamic> json) => SafetyPlan(
  id: json['id'] as String,
  planId: json['planId'] as String,
  patientId: json['patientId'] as String,
  creationDate: DateTime.parse(json['creationDate'] as String),
  warningSigns: (json['warningSigns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  copingStrategies: (json['copingStrategies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  supportContacts: (json['supportContacts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  professionalContacts: (json['professionalContacts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  emergencyContacts: (json['emergencyContacts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SafetyPlanToJson(SafetyPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'patientId': instance.patientId,
      'creationDate': instance.creationDate.toIso8601String(),
      'warningSigns': instance.warningSigns,
      'copingStrategies': instance.copingStrategies,
      'supportContacts': instance.supportContacts,
      'professionalContacts': instance.professionalContacts,
      'emergencyContacts': instance.emergencyContacts,
      'status': instance.status,
      'metadata': instance.metadata,
    };

PostCrisisFollowUp _$PostCrisisFollowUpFromJson(Map<String, dynamic> json) =>
    PostCrisisFollowUp(
      id: json['id'] as String,
      followUpId: json['followUpId'] as String,
      patientId: json['patientId'] as String,
      crisisId: json['crisisId'] as String,
      crisisDate: DateTime.parse(json['crisisDate'] as String),
      followUpDate: DateTime.parse(json['followUpDate'] as String),
      followUpType: json['followUpType'] as String,
      assessmentAreas: (json['assessmentAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      assessmentResults: json['assessmentResults'] as Map<String, dynamic>,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextFollowUpDate: DateTime.parse(json['nextFollowUpDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PostCrisisFollowUpToJson(PostCrisisFollowUp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'followUpId': instance.followUpId,
      'patientId': instance.patientId,
      'crisisId': instance.crisisId,
      'crisisDate': instance.crisisDate.toIso8601String(),
      'followUpDate': instance.followUpDate.toIso8601String(),
      'followUpType': instance.followUpType,
      'assessmentAreas': instance.assessmentAreas,
      'assessmentResults': instance.assessmentResults,
      'recommendations': instance.recommendations,
      'nextFollowUpDate': instance.nextFollowUpDate.toIso8601String(),
      'metadata': instance.metadata,
    };

CrisisInterventionTraining _$CrisisInterventionTrainingFromJson(
  Map<String, dynamic> json,
) => CrisisInterventionTraining(
  id: json['id'] as String,
  trainingId: json['trainingId'] as String,
  trainingName: json['trainingName'] as String,
  description: json['description'] as String,
  targetAudience: json['targetAudience'] as String,
  learningObjectives: (json['learningObjectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  trainingModules: (json['trainingModules'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  durationHours: (json['durationHours'] as num).toInt(),
  format: json['format'] as String,
  completionRate: (json['completionRate'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CrisisInterventionTrainingToJson(
  CrisisInterventionTraining instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainingId': instance.trainingId,
  'trainingName': instance.trainingName,
  'description': instance.description,
  'targetAudience': instance.targetAudience,
  'learningObjectives': instance.learningObjectives,
  'trainingModules': instance.trainingModules,
  'durationHours': instance.durationHours,
  'format': instance.format,
  'completionRate': instance.completionRate,
  'metadata': instance.metadata,
};

CrisisInterventionPerformanceMetrics
_$CrisisInterventionPerformanceMetricsFromJson(Map<String, dynamic> json) =>
    CrisisInterventionPerformanceMetrics(
      id: json['id'] as String,
      metricId: json['metricId'] as String,
      metricName: json['metricName'] as String,
      description: json['description'] as String,
      measurementDate: DateTime.parse(json['measurementDate'] as String),
      responseTime: (json['responseTime'] as num).toDouble(),
      interventionSuccessRate: (json['interventionSuccessRate'] as num)
          .toDouble(),
      patientSatisfactionScore: (json['patientSatisfactionScore'] as num)
          .toDouble(),
      improvementAreas: (json['improvementAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CrisisInterventionPerformanceMetricsToJson(
  CrisisInterventionPerformanceMetrics instance,
) => <String, dynamic>{
  'id': instance.id,
  'metricId': instance.metricId,
  'metricName': instance.metricName,
  'description': instance.description,
  'measurementDate': instance.measurementDate.toIso8601String(),
  'responseTime': instance.responseTime,
  'interventionSuccessRate': instance.interventionSuccessRate,
  'patientSatisfactionScore': instance.patientSatisfactionScore,
  'improvementAreas': instance.improvementAreas,
  'metadata': instance.metadata,
};
