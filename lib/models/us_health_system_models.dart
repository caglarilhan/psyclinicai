import 'package:json_annotation/json_annotation.dart';

part 'us_health_system_models.g.dart';

@JsonSerializable()
class USHealthSystemIntegration {
  final String id;
  final String organizationId;
  final List<EHRIntegration> ehrIntegrations; // Epic, Cerner vb.
  final List<PayerIntegration> payerIntegrations; // Medicare/Medicaid, Private
  final List<FHIRSubscription> fhirSubscriptions; // HL7 FHIR R4
  final List<USComplianceRequirement> complianceRequirements; // HIPAA, 42 CFR Part 2
  final List<USReportingRequirement> reportingRequirements; // CMS, State
  final Map<String, dynamic> configuration;

  const USHealthSystemIntegration({
    required this.id,
    required this.organizationId,
    required this.ehrIntegrations,
    required this.payerIntegrations,
    required this.fhirSubscriptions,
    required this.complianceRequirements,
    required this.reportingRequirements,
    required this.configuration,
  });

  factory USHealthSystemIntegration.fromJson(Map<String, dynamic> json) =>
      _$USHealthSystemIntegrationFromJson(json);
  Map<String, dynamic> toJson() => _$USHealthSystemIntegrationToJson(this);
}

@JsonSerializable()
class EHRIntegration {
  final String id;
  final String vendor; // Epic, Cerner, Athena, Allscripts, NextGen, DrChrono
  final String baseUrl;
  final bool isActive;
  final DateTime lastSync;
  final List<String> supportedResources; // Patient, Encounter, Observation, Consent, Claim
  final String authMethod; // OAuth2, SMART on FHIR
  final Map<String, dynamic> metadata;

  const EHRIntegration({
    required this.id,
    required this.vendor,
    required this.baseUrl,
    required this.isActive,
    required this.lastSync,
    required this.supportedResources,
    required this.authMethod,
    required this.metadata,
  });

  factory EHRIntegration.fromJson(Map<String, dynamic> json) => _$EHRIntegrationFromJson(json);
  Map<String, dynamic> toJson() => _$EHRIntegrationToJson(this);
}

@JsonSerializable()
class PayerIntegration {
  final String id;
  final String payerName; // Medicare, Medicaid, Aetna, Cigna, Blue Cross
  final bool isActive;
  final DateTime lastSync;
  final List<ClaimSubmissionRule> claimRules;
  final List<PriorAuthorizationRule> priorAuthRules;
  final Map<String, dynamic> metadata;

  const PayerIntegration({
    required this.id,
    required this.payerName,
    required this.isActive,
    required this.lastSync,
    required this.claimRules,
    required this.priorAuthRules,
    required this.metadata,
  });

  factory PayerIntegration.fromJson(Map<String, dynamic> json) => _$PayerIntegrationFromJson(json);
  Map<String, dynamic> toJson() => _$PayerIntegrationToJson(this);
}

@JsonSerializable()
class ClaimSubmissionRule {
  final String id;
  final String codeSystem; // CPT/HCPCS/ICD-10-CM
  final String code;
  final List<String> requiredModifiers; // -95, -GT, -59 vb.
  final List<String> requiredDocuments; // Progress note, Consent, Telehealth attestation
  final List<String> placeOfService; // 02, 10, 11, 02=Telehealth, 10=Telehealth-Home
  final bool allowedTelehealth;
  final String policyReference;

  const ClaimSubmissionRule({
    required this.id,
    required this.codeSystem,
    required this.code,
    required this.requiredModifiers,
    required this.requiredDocuments,
    required this.placeOfService,
    required this.allowedTelehealth,
    required this.policyReference,
  });

  factory ClaimSubmissionRule.fromJson(Map<String, dynamic> json) => _$ClaimSubmissionRuleFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimSubmissionRuleToJson(this);
}

@JsonSerializable()
class PriorAuthorizationRule {
  final String id;
  final String serviceCode; // 90834, 90837 vb.
  final String payerName;
  final bool required;
  final List<String> criteria;
  final String turnaroundTime; // 24h/48h/5 business days

  const PriorAuthorizationRule({
    required this.id,
    required this.serviceCode,
    required this.payerName,
    required this.required,
    required this.criteria,
    required this.turnaroundTime,
  });

  factory PriorAuthorizationRule.fromJson(Map<String, dynamic> json) => _$PriorAuthorizationRuleFromJson(json);
  Map<String, dynamic> toJson() => _$PriorAuthorizationRuleToJson(this);
}

@JsonSerializable()
class FHIRSubscription {
  final String id;
  final String resourceType; // Patient, Encounter, Observation, Consent
  final String criteria;
  final String endpoint;
  final String channelType; // rest-hook, websocket
  final String status; // active, off
  final DateTime lastDelivery;

  const FHIRSubscription({
    required this.id,
    required this.resourceType,
    required this.criteria,
    required this.endpoint,
    required this.channelType,
    required this.status,
    required this.lastDelivery,
  });

  factory FHIRSubscription.fromJson(Map<String, dynamic> json) => _$FHIRSubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$FHIRSubscriptionToJson(this);
}

@JsonSerializable()
class USComplianceRequirement {
  final String id;
  final String title; // HIPAA Privacy Rule, HIPAA Security Rule, 42 CFR Part 2
  final String description;
  final String regulation;
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final String status; // compliant, pending, non-compliant
  final List<String> controls; // Access control, audit, encryption
  final List<String> evidence;

  const USComplianceRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.regulation,
    required this.effectiveDate,
    this.expiryDate,
    required this.status,
    required this.controls,
    required this.evidence,
  });

  factory USComplianceRequirement.fromJson(Map<String, dynamic> json) => _$USComplianceRequirementFromJson(json);
  Map<String, dynamic> toJson() => _$USComplianceRequirementToJson(this);
}

@JsonSerializable()
class USReportingRequirement {
  final String id;
  final String title; // CMS Quality Reporting, HEDIS measures
  final String description;
  final String authority; // CMS, State Health Dept
  final String frequency; // monthly, quarterly, annually
  final String format; // FHIR MeasureReport, CSV
  final DateTime nextDueDate;

  const USReportingRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.authority,
    required this.frequency,
    required this.format,
    required this.nextDueDate,
  });

  factory USReportingRequirement.fromJson(Map<String, dynamic> json) => _$USReportingRequirementFromJson(json);
  Map<String, dynamic> toJson() => _$USReportingRequirementToJson(this);
}
