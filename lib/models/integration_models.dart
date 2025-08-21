import 'package:json_annotation/json_annotation.dart';
import 'common_enums.dart';

part 'integration_models.g.dart';

// ===== ENTEGRASYON MODELLERİ =====

@JsonSerializable()
class IntegrationProfile {
  final String id;
  final String clinicianId;
  final String institutionId;
  final List<Integration> integrations;
  final IntegrationStatus overallStatus;
  final List<IntegrationAlert> alerts;
  final Map<String, dynamic>? metadata;

  IntegrationProfile({
    required this.id,
    required this.clinicianId,
    required this.institutionId,
    required this.integrations,
    required this.overallStatus,
    required this.alerts,
    this.metadata,
  });

  factory IntegrationProfile.fromJson(Map<String, dynamic> json) =>
      _$IntegrationProfileFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationProfileToJson(this);
}

// ===== EHR ENTEGRASYONU =====

@JsonSerializable()
class EHRIntegration {
  final String id;
  final String name;
  final String vendor; // Epic, Cerner, Medidata, etc.
  final String version;
  final IntegrationType type;
  final IntegrationStatus status;
  final DateTime lastSync;
  final List<String> supportedFeatures;
  final List<String> dataFields;
  final FHIRConfiguration? fhirConfig;
  final HL7Configuration? hl7Config;
  final List<String> alerts;
  final Map<String, dynamic>? metadata;

  EHRIntegration({
    required this.id,
    required this.name,
    required this.vendor,
    required this.version,
    required this.type,
    required this.status,
    required this.lastSync,
    required this.supportedFeatures,
    required this.dataFields,
    this.fhirConfig,
    this.hl7Config,
    required this.alerts,
    this.metadata,
  });

  factory EHRIntegration.fromJson(Map<String, dynamic> json) =>
      _$EHRIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$EHRIntegrationToJson(this);
}



@JsonSerializable()
class FHIRConfiguration {
  final String baseUrl;
  final String version;
  final List<String> resources;
  final AuthenticationConfig authentication;
  final List<String> scopes;
  final RateLimitConfig rateLimit;
  final List<String> customExtensions;

  FHIRConfiguration({
    required this.baseUrl,
    required this.version,
    required this.resources,
    required this.authentication,
    required this.scopes,
    required this.rateLimit,
    required this.customExtensions,
  });

  factory FHIRConfiguration.fromJson(Map<String, dynamic> json) =>
      _$FHIRConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$FHIRConfigurationToJson(this);
}

@JsonSerializable()
class HL7Configuration {
  final String version;
  final String messageType;
  final String encoding;
  final String endpoint;
  final List<String> messageTypes;
  final List<String> customSegments;

  HL7Configuration({
    required this.version,
    required this.messageType,
    required this.encoding,
    required this.endpoint,
    required this.messageTypes,
    required this.customSegments,
  });

  factory HL7Configuration.fromJson(Map<String, dynamic> json) =>
      _$HL7ConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$HL7ConfigurationToJson(this);
}

@JsonSerializable()
class AuthenticationConfig {
  final String type; // OAuth2, Basic, API Key, etc.
  final String clientId;
  final String? clientSecret;
  final String? redirectUri;
  final List<String> scopes;
  final String? tokenEndpoint;
  final DateTime? tokenExpiry;

  AuthenticationConfig({
    required this.type,
    required this.clientId,
    this.clientSecret,
    this.redirectUri,
    required this.scopes,
    this.tokenEndpoint,
    this.tokenExpiry,
  });

  factory AuthenticationConfig.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticationConfigToJson(this);
}

@JsonSerializable()
class RateLimitConfig {
  final int requestsPerMinute;
  final int requestsPerHour;
  final int burstLimit;
  final String? retryAfter;

  RateLimitConfig({
    required this.requestsPerMinute,
    required this.requestsPerHour,
    required this.burstLimit,
    this.retryAfter,
  });

  factory RateLimitConfig.fromJson(Map<String, dynamic> json) =>
      _$RateLimitConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RateLimitConfigToJson(this);
}

// ===== LABORATUAR ENTEGRASYONU =====

@JsonSerializable()
class LabIntegration {
  final String id;
  final String name;
  final String labSystem;
  final IntegrationStatus status;
  final DateTime lastSync;
  final List<String> testTypes;
  final List<String> resultFields;
  final List<String> alertRules;
  final LabDataMapping dataMapping;
  final List<String> supportedTests;
  final Map<String, dynamic>? metadata;

  LabIntegration({
    required this.id,
    required this.name,
    required this.labSystem,
    required this.status,
    required this.lastSync,
    required this.testTypes,
    required this.resultFields,
    required this.alertRules,
    required this.dataMapping,
    required this.supportedTests,
    this.metadata,
  });

  factory LabIntegration.fromJson(Map<String, dynamic> json) =>
      _$LabIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$LabIntegrationToJson(this);
}

@JsonSerializable()
class LabDataMapping {
  final Map<String, String> fieldMappings;
  final Map<String, String> unitConversions;
  final Map<String, String> referenceRanges;
  final List<String> criticalValues;
  final List<String> alertThresholds;

  LabDataMapping({
    required this.fieldMappings,
    required this.unitConversions,
    required this.referenceRanges,
    required this.criticalValues,
    required this.alertThresholds,
  });

  factory LabDataMapping.fromJson(Map<String, dynamic> json) =>
      _$LabDataMappingFromJson(json);

  Map<String, dynamic> toJson() => _$LabDataMappingToJson(this);
}

@JsonSerializable()
class LabResult {
  final String id;
  final String patientId;
  final String testId;
  final String testName;
  final String result;
  final String unit;
  final String referenceRange;
  final ResultFlag flag;
  final DateTime collectionDate;
  final DateTime resultDate;
  final String labId;
  final String? notes;
  final List<String> alerts;

  LabResult({
    required this.id,
    required this.patientId,
    required this.testId,
    required this.testName,
    required this.result,
    required this.unit,
    required this.referenceRange,
    required this.flag,
    required this.collectionDate,
    required this.resultDate,
    required this.labId,
    this.notes,
    required this.alerts,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) =>
      _$LabResultFromJson(json);

  Map<String, dynamic> toJson() => _$LabResultToJson(this);
}

enum ResultFlag {
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('low')
  low,
  @JsonValue('critical_high')
  criticalHigh,
  @JsonValue('critical_low')
  criticalLow,
  @JsonValue('abnormal')
  abnormal,
}

// ===== ECZANE ENTEGRASYONU =====

@JsonSerializable()
class PharmacyIntegration {
  final String id;
  final String name;
  final String pharmacySystem;
  final IntegrationStatus status;
  final DateTime lastSync;
  final List<String> supportedFeatures;
  final List<String> medicationFields;
  final EPrescriptionConfig ePrescription;
  final RefillTrackingConfig refillTracking;
  final List<String> alerts;
  final Map<String, dynamic>? metadata;

  PharmacyIntegration({
    required this.id,
    required this.name,
    required this.pharmacySystem,
    required this.status,
    required this.lastSync,
    required this.supportedFeatures,
    required this.medicationFields,
    required this.ePrescription,
    required this.refillTracking,
    required this.alerts,
    this.metadata,
  });

  factory PharmacyIntegration.fromJson(Map<String, dynamic> json) =>
      _$PharmacyIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$PharmacyIntegrationToJson(this);
}

@JsonSerializable()
class EPrescriptionConfig {
  final bool isEnabled;
  final String standard; // NCPDP, HL7, etc.
  final List<String> supportedMedications;
  final List<String> controlledSubstances;
  final List<String> formulary;
  final List<String> insurancePlans;

  EPrescriptionConfig({
    required this.isEnabled,
    required this.standard,
    required this.supportedMedications,
    required this.controlledSubstances,
    required this.formulary,
    required this.insurancePlans,
  });

  factory EPrescriptionConfig.fromJson(Map<String, dynamic> json) =>
      _$EPrescriptionConfigFromJson(json);

  Map<String, dynamic> toJson() => _$EPrescriptionConfigToJson(this);
}

@JsonSerializable()
class RefillTrackingConfig {
  final bool isEnabled;
  final List<String> trackingFields;
  final List<String> notificationTypes;
  final List<String> refillRules;
  final List<String> approvalWorkflow;

  RefillTrackingConfig({
    required this.isEnabled,
    required this.trackingFields,
    required this.notificationTypes,
    required this.refillRules,
    required this.approvalWorkflow,
  });

  factory RefillTrackingConfig.fromJson(Map<String, dynamic> json) =>
      _$RefillTrackingConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RefillTrackingConfigToJson(this);
}

// ===== SİGORTA / GERİ ÖDEME ENTEGRASYONU =====

@JsonSerializable()
class InsuranceIntegration {
  final String id;
  final String name;
  final String insuranceSystem;
  final String region; // US, EU, TR, etc.
  final IntegrationStatus status;
  final DateTime lastSync;
  final List<String> supportedPlans;
  final List<String> coverageTypes;
  final ClaimAutomationConfig claimAutomation;
  final ReimbursementConfig reimbursement;
  final List<String> alerts;
  final Map<String, dynamic>? metadata;

  InsuranceIntegration({
    required this.id,
    required this.name,
    required this.insuranceSystem,
    required this.region,
    required this.status,
    required this.lastSync,
    required this.supportedPlans,
    required this.coverageTypes,
    required this.claimAutomation,
    required this.reimbursement,
    required this.alerts,
    this.metadata,
  });

  factory InsuranceIntegration.fromJson(Map<String, dynamic> json) =>
      _$InsuranceIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$InsuranceIntegrationToJson(this);
}

@JsonSerializable()
class ClaimAutomationConfig {
  final bool isEnabled;
  final String standard; // X12, HL7, etc.
  final List<String> claimTypes;
  final List<String> requiredFields;
  final List<String> validationRules;
  final List<String> approvalWorkflow;

  ClaimAutomationConfig({
    required this.isEnabled,
    required this.standard,
    required this.claimTypes,
    required this.requiredFields,
    required this.validationRules,
    required this.approvalWorkflow,
  });

  factory ClaimAutomationConfig.fromJson(Map<String, dynamic> json) =>
      _$ClaimAutomationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ClaimAutomationConfigToJson(this);
}

@JsonSerializable()
class ReimbursementConfig {
  final bool isEnabled;
  final String currency;
  final List<String> paymentMethods;
  final List<String> feeSchedules;
  final List<String> billingCodes;
  final List<String> documentationRequirements;

  ReimbursementConfig({
    required this.isEnabled,
    required this.currency,
    required this.paymentMethods,
    required this.feeSchedules,
    required this.billingCodes,
    required this.documentationRequirements,
  });

  factory ReimbursementConfig.fromJson(Map<String, dynamic> json) =>
      _$ReimbursementConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ReimbursementConfigToJson(this);
}

// ===== MOBİL & TELEPSİKİYATRİ =====

@JsonSerializable()
class MobileTelepsychiatryIntegration {
  final String id;
  final String name;
  final String platform; // iOS, Android, Web
  final IntegrationStatus status;
  final DateTime lastSync;
  final List<String> supportedFeatures;
  final OfflineConfig offlineConfig;
  final SecurityConfig securityConfig;
  final List<String> alerts;
  final Map<String, dynamic>? metadata;

  MobileTelepsychiatryIntegration({
    required this.id,
    required this.name,
    required this.platform,
    required this.status,
    required this.lastSync,
    required this.supportedFeatures,
    required this.offlineConfig,
    required this.securityConfig,
    required this.alerts,
    this.metadata,
  });

  factory MobileTelepsychiatryIntegration.fromJson(Map<String, dynamic> json) =>
      _$MobileTelepsychiatryIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$MobileTelepsychiatryIntegrationToJson(this);
}

@JsonSerializable()
class OfflineConfig {
  final bool isEnabled;
  final List<String> offlineFeatures;
  final String syncStrategy;
  final int maxOfflineDays;
  final List<String> dataTypes;
  final List<String> conflictResolution;

  OfflineConfig({
    required this.isEnabled,
    required this.offlineFeatures,
    required this.syncStrategy,
    required this.maxOfflineDays,
    required this.dataTypes,
    required this.conflictResolution,
  });

  factory OfflineConfig.fromJson(Map<String, dynamic> json) =>
      _$OfflineConfigFromJson(json);

  Map<String, dynamic> toJson() => _$OfflineConfigToJson(this);
}

@JsonSerializable()
class SecurityConfig {
  final bool biometricAuth;
  final bool encryption;
  final List<String> securityFeatures;
  final List<String> complianceStandards;
  final List<String> auditLogs;
  final List<String> accessControls;

  SecurityConfig({
    required this.biometricAuth,
    required this.encryption,
    required this.securityFeatures,
    required this.complianceStandards,
    required this.auditLogs,
    required this.accessControls,
  });

  factory SecurityConfig.fromJson(Map<String, dynamic> json) =>
      _$SecurityConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityConfigToJson(this);
}

// ===== ENTEGRASYON ALERT =====

@JsonSerializable()
class IntegrationAlert {
  final String id;
  final String integrationId;
  final String type;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final List<String> actions;

  IntegrationAlert({
    required this.id,
    required this.integrationId,
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.isAcknowledged,
    this.acknowledgedAt,
    this.acknowledgedBy,
    required this.actions,
  });

  factory IntegrationAlert.fromJson(Map<String, dynamic> json) =>
      _$IntegrationAlertFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationAlertToJson(this);
}



// ===== ENTEGRASYON ÖZETİ =====

@JsonSerializable()
class IntegrationSummary {
  final String id;
  final String clinicianId;
  final DateTime summaryDate;
  final IntegrationStatus overallStatus;
  final List<Integration> activeIntegrations;
  final List<Integration> inactiveIntegrations;
  final List<IntegrationAlert> criticalAlerts;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  IntegrationSummary({
    required this.id,
    required this.clinicianId,
    required this.summaryDate,
    required this.overallStatus,
    required this.activeIntegrations,
    required this.inactiveIntegrations,
    required this.criticalAlerts,
    required this.recommendations,
    this.metadata,
  });

  factory IntegrationSummary.fromJson(Map<String, dynamic> json) =>
      _$IntegrationSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationSummaryToJson(this);
}

// ===== GENEL ENTEGRASYON =====

@JsonSerializable()
class Integration {
  final String id;
  final String name;
  final String type;
  final IntegrationStatus status;
  final DateTime lastSync;
  final List<String> features;
  final Map<String, dynamic>? config;
  final List<String> alerts;

  Integration({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.lastSync,
    required this.features,
    this.config,
    required this.alerts,
  });

  factory Integration.fromJson(Map<String, dynamic> json) =>
      _$IntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationToJson(this);
}
