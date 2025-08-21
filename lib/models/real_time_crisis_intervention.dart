import 'package:json_annotation/json_annotation.dart';

part 'real_time_crisis_intervention.g.dart';

// Gerçek Zamanlı Kriz Müdahalesi
@JsonSerializable()
class RealTimeCrisisIntervention {
  final String id;
  final String name;
  final String description;
  final String version;
  final DateTime lastUpdated;
  final String status;
  final Map<String, dynamic> crisisFeatures;
  final Map<String, dynamic> interventionFeatures;
  final Map<String, dynamic> metadata;

  RealTimeCrisisIntervention({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.lastUpdated,
    required this.status,
    required this.crisisFeatures,
    required this.interventionFeatures,
    required this.metadata,
  });

  factory RealTimeCrisisIntervention.fromJson(Map<String, dynamic> json) =>
      _$RealTimeCrisisInterventionFromJson(json);

  Map<String, dynamic> toJson() => _$RealTimeCrisisInterventionToJson(this);
}

// AI Risk Tespiti
@JsonSerializable()
class AIRiskDetection {
  final String id;
  final String detectionId;
  final String patientId;
  final DateTime detectionTime;
  final String riskType;
  final String riskLevel; // low, moderate, high, critical, emergency
  final double confidenceScore;
  final List<String> riskFactors;
  final List<String> warningSigns;
  final Map<String, dynamic> riskMetrics;
  final String status;
  final Map<String, dynamic> metadata;

  AIRiskDetection({
    required this.id,
    required this.detectionId,
    required this.patientId,
    required this.detectionTime,
    required this.riskType,
    required this.riskLevel,
    required this.confidenceScore,
    required this.riskFactors,
    required this.warningSigns,
    required this.riskMetrics,
    required this.status,
    required this.metadata,
  });

  factory AIRiskDetection.fromJson(Map<String, dynamic> json) =>
      _$AIRiskDetectionFromJson(json);

  Map<String, dynamic> toJson() => _$AIRiskDetectionToJson(this);
}

// Acil Durum Protokolleri
@JsonSerializable()
class EmergencyProtocols {
  final String id;
  final String protocolId;
  final String protocolName;
  final String description;
  final String emergencyType;
  final String severity; // low, medium, high, critical
  final List<String> immediateActions;
  final List<String> requiredResources;
  final List<String> contactPersons;
  final List<String> escalationSteps;
  final Map<String, dynamic> protocolDetails;
  final Map<String, dynamic> metadata;

  EmergencyProtocols({
    required this.id,
    required this.protocolId,
    required this.protocolName,
    required this.description,
    required this.emergencyType,
    required this.severity,
    required this.immediateActions,
    required this.requiredResources,
    required this.contactPersons,
    required this.escalationSteps,
    required this.protocolDetails,
    required this.metadata,
  });

  factory EmergencyProtocols.fromJson(Map<String, dynamic> json) =>
      _$EmergencyProtocolsFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyProtocolsToJson(this);
}

// Dünya Çapında Kriz Hatları
@JsonSerializable()
class GlobalCrisisHotlines {
  final String id;
  final String hotlineId;
  final String hotlineName;
  final String countryCode;
  final String countryName;
  final String phoneNumber;
  final String website;
  final List<String> services;
  final List<String> languages;
  final Map<String, dynamic> operatingHours;
  final String status;
  final Map<String, dynamic> metadata;

  GlobalCrisisHotlines({
    required this.id,
    required this.hotlineId,
    required this.hotlineName,
    required this.countryCode,
    required this.countryName,
    required this.phoneNumber,
    required this.website,
    required this.services,
    required this.languages,
    required this.operatingHours,
    required this.status,
    required this.metadata,
  });

  factory GlobalCrisisHotlines.fromJson(Map<String, dynamic> json) =>
      _$GlobalCrisisHotlinesFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalCrisisHotlinesToJson(this);
}

// Gerçek Zamanlı İzleme
@JsonSerializable()
class RealTimeMonitoring {
  final String id;
  final String monitoringId;
  final String patientId;
  final DateTime startTime;
  final String monitoringType;
  final List<String> monitoredParameters;
  final Map<String, dynamic> baselineData;
  final Map<String, dynamic> currentData;
  final List<String> alerts;
  final List<String> interventions;
  final String status;
  final Map<String, dynamic> metadata;

  RealTimeMonitoring({
    required this.id,
    required this.monitoringId,
    required this.patientId,
    required this.startTime,
    required this.monitoringType,
    required this.monitoredParameters,
    required this.baselineData,
    required this.currentData,
    required this.alerts,
    required this.interventions,
    required this.status,
    required this.metadata,
  });

  factory RealTimeMonitoring.fromJson(Map<String, dynamic> json) =>
      _$RealTimeMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$RealTimeMonitoringToJson(this);
}

// Kriz Müdahale Ekibi
@JsonSerializable()
class CrisisInterventionTeam {
  final String id;
  final String teamId;
  final String teamName;
  final String teamType;
  final List<String> teamMembers;
  final String teamLeader;
  final List<String> specializations;
  final List<String> contactMethods;
  final String availabilityStatus;
  final Map<String, dynamic> responseMetrics;
  final Map<String, dynamic> metadata;

  CrisisInterventionTeam({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.teamType,
    required this.teamMembers,
    required this.teamLeader,
    required this.specializations,
    required this.contactMethods,
    required this.availabilityStatus,
    required this.responseMetrics,
    required this.metadata,
  });

  factory CrisisInterventionTeam.fromJson(Map<String, dynamic> json) =>
      _$CrisisInterventionTeamFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisInterventionTeamToJson(this);
}

// Acil Durum Müdahale Planı
@JsonSerializable()
class EmergencyInterventionPlan {
  final String id;
  final String planId;
  final String patientId;
  final String crisisType;
  final DateTime creationTime;
  final String severity;
  final List<String> immediateActions;
  final List<String> shortTermActions;
  final List<String> longTermActions;
  final List<String> requiredResources;
  final List<String> contactPersons;
  final String status;
  final Map<String, dynamic> metadata;

  EmergencyInterventionPlan({
    required this.id,
    required this.planId,
    required this.patientId,
    required this.crisisType,
    required this.creationTime,
    required this.severity,
    required this.immediateActions,
    required this.shortTermActions,
    required this.longTermActions,
    required this.requiredResources,
    required this.contactPersons,
    required this.status,
    required this.metadata,
  });

  factory EmergencyInterventionPlan.fromJson(Map<String, dynamic> json) =>
      _$EmergencyInterventionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyInterventionPlanToJson(this);
}

// Risk Uyarı Sistemi
@JsonSerializable()
class RiskAlertSystem {
  final String id;
  final String alertId;
  final String patientId;
  final String alertType;
  final DateTime alertTime;
  final String severity;
  final String description;
  final List<String> riskFactors;
  final List<String> recommendedActions;
  final String status;
  final Map<String, dynamic> metadata;

  RiskAlertSystem({
    required this.id,
    required this.alertId,
    required this.patientId,
    required this.alertType,
    required this.alertTime,
    required this.severity,
    required this.description,
    required this.riskFactors,
    required this.recommendedActions,
    required this.status,
    required this.metadata,
  });

  factory RiskAlertSystem.fromJson(Map<String, dynamic> json) =>
      _$RiskAlertSystemFromJson(json);

  Map<String, dynamic> toJson() => _$RiskAlertSystemToJson(this);
}

// Güvenlik Planı
@JsonSerializable()
class SafetyPlan {
  final String id;
  final String planId;
  final String patientId;
  final DateTime creationDate;
  final List<String> warningSigns;
  final List<String> copingStrategies;
  final List<String> supportContacts;
  final List<String> professionalContacts;
  final List<String> emergencyContacts;
  final String status;
  final Map<String, dynamic> metadata;

  SafetyPlan({
    required this.id,
    required this.planId,
    required this.patientId,
    required this.creationDate,
    required this.warningSigns,
    required this.copingStrategies,
    required this.supportContacts,
    required this.professionalContacts,
    required this.emergencyContacts,
    required this.status,
    required this.metadata,
  });

  factory SafetyPlan.fromJson(Map<String, dynamic> json) =>
      _$SafetyPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SafetyPlanToJson(this);
}

// Kriz Sonrası Takip
@JsonSerializable()
class PostCrisisFollowUp {
  final String id;
  final String followUpId;
  final String patientId;
  final String crisisId;
  final DateTime crisisDate;
  final DateTime followUpDate;
  final String followUpType;
  final List<String> assessmentAreas;
  final Map<String, dynamic> assessmentResults;
  final List<String> recommendations;
  final DateTime nextFollowUpDate;
  final Map<String, dynamic> metadata;

  PostCrisisFollowUp({
    required this.id,
    required this.followUpId,
    required this.patientId,
    required this.crisisId,
    required this.crisisDate,
    required this.followUpDate,
    required this.followUpType,
    required this.assessmentAreas,
    required this.assessmentResults,
    required this.recommendations,
    required this.nextFollowUpDate,
    required this.metadata,
  });

  factory PostCrisisFollowUp.fromJson(Map<String, dynamic> json) =>
      _$PostCrisisFollowUpFromJson(json);

  Map<String, dynamic> toJson() => _$PostCrisisFollowUpToJson(this);
}

// Kriz Müdahale Eğitimi
@JsonSerializable()
class CrisisInterventionTraining {
  final String id;
  final String trainingId;
  final String trainingName;
  final String description;
  final String targetAudience;
  final List<String> learningObjectives;
  final List<String> trainingModules;
  final int durationHours;
  final String format;
  final double completionRate;
  final Map<String, dynamic> metadata;

  CrisisInterventionTraining({
    required this.id,
    required this.trainingId,
    required this.trainingName,
    required this.description,
    required this.targetAudience,
    required this.learningObjectives,
    required this.trainingModules,
    required this.durationHours,
    required this.format,
    required this.completionRate,
    required this.metadata,
  });

  factory CrisisInterventionTraining.fromJson(Map<String, dynamic> json) =>
      _$CrisisInterventionTrainingFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisInterventionTrainingToJson(this);
}

// Kriz Müdahale Performans Metrikleri
@JsonSerializable()
class CrisisInterventionPerformanceMetrics {
  final String id;
  final String metricId;
  final String metricName;
  final String description;
  final DateTime measurementDate;
  final double responseTime;
  final double interventionSuccessRate;
  final double patientSatisfactionScore;
  final List<String> improvementAreas;
  final Map<String, dynamic> metadata;

  CrisisInterventionPerformanceMetrics({
    required this.id,
    required this.metricId,
    required this.metricName,
    required this.description,
    required this.measurementDate,
    required this.responseTime,
    required this.interventionSuccessRate,
    required this.patientSatisfactionScore,
    required this.improvementAreas,
    required this.metadata,
  });

  factory CrisisInterventionPerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$CrisisInterventionPerformanceMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisInterventionPerformanceMetricsToJson(this);
}
