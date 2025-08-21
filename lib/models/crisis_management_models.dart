import 'package:json_annotation/json_annotation.dart';

part 'crisis_management_models.g.dart';

// ===== KRİZ YÖNETİMİ & GÜVENLİK MODELLERİ =====

@JsonSerializable()
class CrisisManagementProfile {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final CrisisStatus status;
  final List<CrisisAlert> alerts;
  final List<CrisisIntervention> interventions;
  final SafetyContract? safetyContract;
  final List<GeoFencingRule> geoFencingRules;
  final CrisisPlaybook playbook;
  final Map<String, dynamic>? metadata;

  CrisisManagementProfile({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.createdDate,
    required this.lastUpdated,
    required this.status,
    required this.alerts,
    required this.interventions,
    this.safetyContract,
    required this.geoFencingRules,
    required this.playbook,
    this.metadata,
  });

  factory CrisisManagementProfile.fromJson(Map<String, dynamic> json) =>
      _$CrisisManagementProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisManagementProfileToJson(this);
}

enum CrisisStatus {
  @JsonValue('stable')
  stable,
  @JsonValue('monitoring')
  monitoring,
  @JsonValue('elevated_risk')
  elevatedRisk,
  @JsonValue('crisis')
  crisis,
  @JsonValue('intervention')
  intervention,
  @JsonValue('post_crisis')
  postCrisis,
}

// ===== DİNAMİK İNTİHAR RİSK SKORU =====

@JsonSerializable()
class DynamicSuicideRiskScore {
  final String id;
  final String patientId;
  final DateTime assessmentDate;
  final double currentScore;
  final double previousScore;
  final double changeRate;
  final RiskLevel riskLevel;
  final List<RiskFactor> riskFactors;
  final List<ProtectiveFactor> protectiveFactors;
  final List<String> warningSigns;
  final List<String> recommendations;
  final double confidence;
  final String? notes;

  DynamicSuicideRiskScore({
    required this.id,
    required this.patientId,
    required this.assessmentDate,
    required this.currentScore,
    required this.previousScore,
    required this.changeRate,
    required this.riskLevel,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.warningSigns,
    required this.recommendations,
    required this.confidence,
    this.notes,
  });

  factory DynamicSuicideRiskScore.fromJson(Map<String, dynamic> json) =>
      _$DynamicSuicideRiskScoreFromJson(json);

  Map<String, dynamic> toJson() => _$DynamicSuicideRiskScoreToJson(this);
}

enum RiskLevel {
  @JsonValue('minimal')
  minimal,
  @JsonValue('low')
  low,
  @JsonValue('moderate')
  moderate,
  @JsonValue('high')
  high,
  @JsonValue('severe')
  severe,
  @JsonValue('immediate')
  immediate,
}

@JsonSerializable()
class RiskFactor {
  final String id;
  final String name;
  final String category;
  final double weight;
  final bool isActive;
  final DateTime onsetDate;
  final DateTime? resolutionDate;
  final String? notes;

  RiskFactor({
    required this.id,
    required this.name,
    required this.category,
    required this.weight,
    required this.isActive,
    required this.onsetDate,
    this.resolutionDate,
    this.notes,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);

  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

@JsonSerializable()
class ProtectiveFactor {
  final String id;
  final String name;
  final String category;
  final double strength;
  final bool isActive;
  final DateTime identifiedDate;
  final String? notes;

  ProtectiveFactor({
    required this.id,
    required this.name,
    required this.category,
    required this.strength,
    required this.isActive,
    required this.identifiedDate,
    this.notes,
  });

  factory ProtectiveFactor.fromJson(Map<String, dynamic> json) =>
      _$ProtectiveFactorFromJson(json);

  Map<String, dynamic> toJson() => _$ProtectiveFactorToJson(this);
}

// ===== KRİZ PLAYBOOK'LARI =====

@JsonSerializable()
class CrisisPlaybook {
  final String id;
  final String name;
  final String region; // TR, US, EU, etc.
  final String version;
  final DateTime lastUpdated;
  final List<CrisisScenario> scenarios;
  final List<EmergencyContact> emergencyContacts;
  final List<InterventionProtocol> protocols;
  final Map<String, dynamic>? metadata;

  CrisisPlaybook({
    required this.id,
    required this.name,
    required this.region,
    required this.version,
    required this.lastUpdated,
    required this.scenarios,
    required this.emergencyContacts,
    required this.protocols,
    this.metadata,
  });

  factory CrisisPlaybook.fromJson(Map<String, dynamic> json) =>
      _$CrisisPlaybookFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisPlaybookToJson(this);
}

@JsonSerializable()
class CrisisScenario {
  final String id;
  final String name;
  final String description;
  final CrisisType type;
  final double severity;
  final List<String> triggers;
  final List<String> warningSigns;
  final List<String> immediateActions;
  final List<String> followUpActions;
  final List<String> resources;

  CrisisScenario({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.severity,
    required this.triggers,
    required this.warningSigns,
    required this.immediateActions,
    required this.followUpActions,
    required this.resources,
  });

  factory CrisisScenario.fromJson(Map<String, dynamic> json) =>
      _$CrisisScenarioFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisScenarioToJson(this);
}

enum CrisisType {
  @JsonValue('suicide_risk')
  suicideRisk,
  @JsonValue('self_harm')
  selfHarm,
  @JsonValue('violent_behavior')
  violentBehavior,
  @JsonValue('psychotic_episode')
  psychoticEpisode,
  @JsonValue('manic_episode')
  manicEpisode,
  @JsonValue('severe_depression')
  severeDepression,
  @JsonValue('substance_abuse')
  substanceAbuse,
  @JsonValue('domestic_violence')
  domesticViolence,
}

@JsonSerializable()
class EmergencyContact {
  final String id;
  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;
  final String? address;
  final bool isPrimary;
  final bool isAvailable;
  final DateTime lastContact;
  final String? notes;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    this.address,
    required this.isPrimary,
    required this.isAvailable,
    required this.lastContact,
    this.notes,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);
}

@JsonSerializable()
class InterventionProtocol {
  final String id;
  final String name;
  final CrisisType crisisType;
  final double severityThreshold;
  final List<String> immediateSteps;
  final List<String> assessmentSteps;
  final List<String> interventionSteps;
  final List<String> followUpSteps;
  final List<String> requiredResources;
  final String? notes;

  InterventionProtocol({
    required this.id,
    required this.name,
    required this.crisisType,
    required this.severityThreshold,
    required this.immediateSteps,
    required this.assessmentSteps,
    required this.interventionSteps,
    required this.followUpSteps,
    required this.requiredResources,
    this.notes,
  });

  factory InterventionProtocol.fromJson(Map<String, dynamic> json) =>
      _$InterventionProtocolFromJson(json);

  Map<String, dynamic> toJson() => _$InterventionProtocolToJson(this);
}

// ===== DİJİTAL GÜVENLİK SÖZLEŞMELERİ =====

@JsonSerializable()
class SafetyContract {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final ContractStatus status;
  final List<SafetyCommitment> commitments;
  final List<CopingStrategy> copingStrategies;
  final List<EmergencyPlan> emergencyPlans;
  final List<String> warningSigns;
  final List<String> actions;
  final String? notes;

  SafetyContract({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.createdDate,
    required this.lastUpdated,
    required this.status,
    required this.commitments,
    required this.copingStrategies,
    required this.emergencyPlans,
    required this.warningSigns,
    required this.actions,
    this.notes,
  });

  factory SafetyContract.fromJson(Map<String, dynamic> json) =>
      _$SafetyContractFromJson(json);

  Map<String, dynamic> toJson() => _$SafetyContractToJson(this);
}

enum ContractStatus {
  @JsonValue('active')
  active,
  @JsonValue('suspended')
  suspended,
  @JsonValue('violated')
  violated,
  @JsonValue('expired')
  expired,
  @JsonValue('renewed')
  renewed,
}

@JsonSerializable()
class SafetyCommitment {
  final String id;
  final String commitment;
  final DateTime date;
  final bool isKept;
  final DateTime? violationDate;
  final String? violationNotes;

  SafetyCommitment({
    required this.id,
    required this.commitment,
    required this.date,
    required this.isKept,
    this.violationDate,
    this.violationNotes,
  });

  factory SafetyCommitment.fromJson(Map<String, dynamic> json) =>
      _$SafetyCommitmentFromJson(json);

  Map<String, dynamic> toJson() => _$SafetyCommitmentToJson(this);
}

@JsonSerializable()
class CopingStrategy {
  final String id;
  final String name;
  final String description;
  final String category;
  final double effectiveness;
  final List<String> steps;
  final bool isActive;

  CopingStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.effectiveness,
    required this.steps,
    required this.isActive,
  });

  factory CopingStrategy.fromJson(Map<String, dynamic> json) =>
      _$CopingStrategyFromJson(json);

  Map<String, dynamic> toJson() => _$CopingStrategyToJson(this);
}

@JsonSerializable()
class EmergencyPlan {
  final String id;
  final String name;
  final String description;
  final List<String> steps;
  final List<String> contacts;
  final List<String> resources;
  final bool isActive;

  EmergencyPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.contacts,
    required this.resources,
    required this.isActive,
  });

  factory EmergencyPlan.fromJson(Map<String, dynamic> json) =>
      _$EmergencyPlanFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyPlanToJson(this);
}

// ===== GEO-FENCING ALERT'LERİ =====

@JsonSerializable()
class GeoFencingRule {
  final String id;
  final String name;
  final String description;
  final GeoFencingType type;
  final double latitude;
  final double longitude;
  final double radius; // meters
  final List<String> restrictedAreas;
  final List<String> safeAreas;
  final bool isActive;
  final List<String> actions;
  final List<String> contacts;

  GeoFencingRule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.restrictedAreas,
    required this.safeAreas,
    required this.isActive,
    required this.actions,
    required this.contacts,
  });

  factory GeoFencingRule.fromJson(Map<String, dynamic> json) =>
      _$GeoFencingRuleFromJson(json);

  Map<String, dynamic> toJson() => _$GeoFencingRuleToJson(this);
}

enum GeoFencingType {
  @JsonValue('restricted')
  restricted,
  @JsonValue('safe_zone')
  safeZone,
  @JsonValue('monitoring')
  monitoring,
  @JsonValue('intervention')
  intervention,
}

@JsonSerializable()
class GeoFencingAlert {
  final String id;
  final String ruleId;
  final String patientId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String location;
  final String type;
  final double severity;
  final List<String> actions;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  GeoFencingAlert({
    required this.id,
    required this.ruleId,
    required this.patientId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.type,
    required this.severity,
    required this.actions,
    required this.isAcknowledged,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  factory GeoFencingAlert.fromJson(Map<String, dynamic> json) =>
      _$GeoFencingAlertFromJson(json);

  Map<String, dynamic> toJson() => _$GeoFencingAlertToJson(this);
}

// ===== KRİZ MÜDAHALE =====

@JsonSerializable()
class CrisisIntervention {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime interventionDate;
  final CrisisType crisisType;
  final double severity;
  final String description;
  final List<String> actions;
  final List<String> outcomes;
  final InterventionStatus status;
  final DateTime? completionDate;
  final String? notes;

  CrisisIntervention({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.interventionDate,
    required this.crisisType,
    required this.severity,
    required this.description,
    required this.actions,
    required this.outcomes,
    required this.status,
    this.completionDate,
    this.notes,
  });

  factory CrisisIntervention.fromJson(Map<String, dynamic> json) =>
      _$CrisisInterventionFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisInterventionToJson(this);
}

enum InterventionStatus {
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('escalated')
  escalated,
  @JsonValue('transferred')
  transferred,
}

// ===== KRİZ ALERT =====

@JsonSerializable()
class CrisisAlert {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final String type;
  final String message;
  final double severity;
  final List<String> actions;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final List<String> escalations;

  CrisisAlert({
    required this.id,
    required this.patientId,
    required this.timestamp,
    required this.type,
    required this.message,
    required this.severity,
    required this.actions,
    required this.isAcknowledged,
    this.acknowledgedAt,
    this.acknowledgedBy,
    required this.escalations,
  });

  factory CrisisAlert.fromJson(Map<String, dynamic> json) =>
      _$CrisisAlertFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisAlertToJson(this);
}

// ===== KRİZ YÖNETİMİ ÖZETİ =====

@JsonSerializable()
class CrisisManagementSummary {
  final String id;
  final String patientId;
  final DateTime summaryDate;
  final CrisisStatus currentStatus;
  final double currentRiskScore;
  final List<CrisisAlert> activeAlerts;
  final List<CrisisIntervention> recentInterventions;
  final SafetyContract? activeContract;
  final List<GeoFencingRule> activeGeoFencing;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  CrisisManagementSummary({
    required this.id,
    required this.patientId,
    required this.summaryDate,
    required this.currentStatus,
    required this.currentRiskScore,
    required this.activeAlerts,
    required this.recentInterventions,
    this.activeContract,
    required this.activeGeoFencing,
    required this.recommendations,
    this.metadata,
  });

  factory CrisisManagementSummary.fromJson(Map<String, dynamic> json) =>
      _$CrisisManagementSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisManagementSummaryToJson(this);
}
