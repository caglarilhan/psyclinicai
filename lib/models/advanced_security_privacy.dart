import 'package:json_annotation/json_annotation.dart';

part 'advanced_security_privacy.g.dart';

// Gelişmiş Güvenlik ve Gizlilik
@JsonSerializable()
class AdvancedSecurityPrivacy {
  final String id;
  final String name;
  final String description;
  final String version;
  final DateTime lastUpdated;
  final String status;
  final Map<String, dynamic> securityFeatures;
  final Map<String, dynamic> privacyFeatures;
  final Map<String, dynamic> complianceFeatures;
  final Map<String, dynamic> metadata;

  AdvancedSecurityPrivacy({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.lastUpdated,
    required this.status,
    required this.securityFeatures,
    required this.privacyFeatures,
    required this.complianceFeatures,
    required this.metadata,
  });

  factory AdvancedSecurityPrivacy.fromJson(Map<String, dynamic> json) =>
      _$AdvancedSecurityPrivacyFromJson(json);

  Map<String, dynamic> toJson() => _$AdvancedSecurityPrivacyToJson(this);
}

// HIPAA Compliance
@JsonSerializable()
class HIPAACompliance {
  final String id;
  final String organizationId;
  final String organizationName;
  final DateTime assessmentDate;
  final String complianceStatus; // compliant, non_compliant, partially_compliant
  final double complianceScore; // 0.0 - 1.0
  final List<String> privacyRuleCompliance;
  final List<String> securityRuleCompliance;
  final List<String> breachNotificationCompliance;
  final List<String> compliantAreas;
  final List<String> nonCompliantAreas;
  final List<String> recommendations;
  final DateTime nextAssessmentDate;
  final Map<String, dynamic> metadata;

  HIPAACompliance({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.assessmentDate,
    required this.complianceStatus,
    required this.complianceScore,
    required this.privacyRuleCompliance,
    required this.securityRuleCompliance,
    required this.breachNotificationCompliance,
    required this.compliantAreas,
    required this.nonCompliantAreas,
    required this.recommendations,
    required this.nextAssessmentDate,
    required this.metadata,
  });

  factory HIPAACompliance.fromJson(Map<String, dynamic> json) =>
      _$HIPAAComplianceFromJson(json);

  Map<String, dynamic> toJson() => _$HIPAAComplianceToJson(this);
}

// GDPR Compliance
@JsonSerializable()
class GDPRCompliance {
  final String id;
  final String organizationId;
  final String organizationName;
  final DateTime assessmentDate;
  final String complianceStatus;
  final double complianceScore;
  final List<String> dataProcessingPrinciples;
  final List<String> dataSubjectRights;
  final List<String> dataProtectionMeasures;
  final List<String> breachNotificationProcedures;
  final List<String> compliantAreas;
  final List<String> nonCompliantAreas;
  final List<String> recommendations;
  final DateTime nextAssessmentDate;
  final Map<String, dynamic> metadata;

  GDPRCompliance({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.assessmentDate,
    required this.complianceStatus,
    required this.complianceScore,
    required this.dataProcessingPrinciples,
    required this.dataSubjectRights,
    required this.dataProtectionMeasures,
    required this.breachNotificationProcedures,
    required this.compliantAreas,
    required this.nonCompliantAreas,
    required this.recommendations,
    required this.nextAssessmentDate,
    required this.metadata,
  });

  factory GDPRCompliance.fromJson(Map<String, dynamic> json) =>
      _$GDPRComplianceFromJson(json);

  Map<String, dynamic> toJson() => _$GDPRComplianceToJson(this);
}

// KVKK Compliance (Türkiye)
@JsonSerializable()
class KVKKCompliance {
  final String id;
  final String organizationId;
  final String organizationName;
  final DateTime assessmentDate;
  final String complianceStatus;
  final double complianceScore;
  final List<String> veriIslemeKurallari;
  final List<String> veriGuvenligiOnlemleri;
  final List<String> acikRizaGereklilikleri;
  final List<String> veriSahibiHaklari;
  final List<String> compliantAreas;
  final List<String> nonCompliantAreas;
  final List<String> recommendations;
  final DateTime nextAssessmentDate;
  final Map<String, dynamic> metadata;

  KVKKCompliance({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.assessmentDate,
    required this.complianceStatus,
    required this.complianceScore,
    required this.veriIslemeKurallari,
    required this.veriGuvenligiOnlemleri,
    required this.acikRizaGereklilikleri,
    required this.veriSahibiHaklari,
    required this.compliantAreas,
    required this.nonCompliantAreas,
    required this.recommendations,
    required this.nextAssessmentDate,
    required this.metadata,
  });

  factory KVKKCompliance.fromJson(Map<String, dynamic> json) =>
      _$KVKKComplianceFromJson(json);

  Map<String, dynamic> toJson() => _$KVKKComplianceToJson(this);
}

// End-to-End Encryption
@JsonSerializable()
class EndToEndEncryption {
  final String id;
  final String encryptionType; // AES-256, RSA-4096, etc.
  final String keyManagement;
  final String algorithm;
  final int keyLength;
  final String keyRotationPolicy;
  final DateTime lastKeyRotation;
  final List<String> encryptionLayers;
  final Map<String, dynamic> encryptionMetrics;
  final List<String> securityFeatures;
  final Map<String, dynamic> metadata;

  EndToEndEncryption({
    required this.id,
    required this.encryptionType,
    required this.keyManagement,
    required this.algorithm,
    required this.keyLength,
    required this.keyRotationPolicy,
    required this.lastKeyRotation,
    required this.encryptionLayers,
    required this.encryptionMetrics,
    required this.securityFeatures,
    required this.metadata,
  });

  factory EndToEndEncryption.fromJson(Map<String, dynamic> json) =>
      _$EndToEndEncryptionFromJson(json);

  Map<String, dynamic> toJson() => _$EndToEndEncryptionToJson(this);
}

// Biometric Authentication
@JsonSerializable()
class BiometricAuthentication {
  final String id;
  final String biometricType; // fingerprint, face, iris, voice
  final String authenticationMethod;
  final double accuracyRate;
  final double falseAcceptanceRate;
  final double falseRejectionRate;
  final List<String> securityFeatures;
  final List<String> fallbackMethods;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> metadata;

  BiometricAuthentication({
    required this.id,
    required this.biometricType,
    required this.authenticationMethod,
    required this.accuracyRate,
    required this.falseAcceptanceRate,
    required this.falseRejectionRate,
    required this.securityFeatures,
    required this.fallbackMethods,
    required this.performanceMetrics,
    required this.metadata,
  });

  factory BiometricAuthentication.fromJson(Map<String, dynamic> json) =>
      _$BiometricAuthenticationFromJson(json);

  Map<String, dynamic> toJson() => _$BiometricAuthenticationToJson(this);
}

// Blockchain Medical Records
@JsonSerializable()
class BlockchainMedicalRecords {
  final String id;
  final String blockchainType; // public, private, consortium
  final String consensusMechanism;
  final String hashAlgorithm;
  final int blockSize;
  final double blockTime;
  final List<String> smartContracts;
  final List<String> dataTypes;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> securityFeatures;
  final Map<String, dynamic> metadata;

  BlockchainMedicalRecords({
    required this.id,
    required this.blockchainType,
    required this.consensusMechanism,
    required this.hashAlgorithm,
    required this.blockSize,
    required this.blockTime,
    required this.smartContracts,
    required this.dataTypes,
    required this.performanceMetrics,
    required this.securityFeatures,
    required this.metadata,
  });

  factory BlockchainMedicalRecords.fromJson(Map<String, dynamic> json) =>
      _$BlockchainMedicalRecordsFromJson(json);

  Map<String, dynamic> toJson() => _$BlockchainMedicalRecordsToJson(this);
}

// Access Control System
@JsonSerializable()
class AccessControlSystem {
  final String id;
  final String systemName;
  final String accessModel; // RBAC, ABAC, MAC, DAC
  final List<String> userRoles;
  final List<String> permissions;
  final List<String> accessLevels;
  final Map<String, dynamic> accessPolicies;
  final List<String> securityFeatures;
  final Map<String, dynamic> auditTrail;
  final Map<String, dynamic> metadata;

  AccessControlSystem({
    required this.id,
    required this.systemName,
    required this.accessModel,
    required this.userRoles,
    required this.permissions,
    required this.accessLevels,
    required this.accessPolicies,
    required this.securityFeatures,
    required this.auditTrail,
    required this.metadata,
  });

  factory AccessControlSystem.fromJson(Map<String, dynamic> json) =>
      _$AccessControlSystemFromJson(json);

  Map<String, dynamic> toJson() => _$AccessControlSystemFromJson(this);
}

// Multi-Factor Authentication
@JsonSerializable()
class MultiFactorAuthentication {
  final String id;
  final String systemName;
  final List<String> factors;
  final String authenticationFlow;
  final double successRate;
  final double falsePositiveRate;
  final List<String> securityFeatures;
  final List<String> fallbackMethods;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> metadata;

  MultiFactorAuthentication({
    required this.id,
    required this.systemName,
    required this.factors,
    required this.authenticationFlow,
    required this.successRate,
    required this.falsePositiveRate,
    required this.securityFeatures,
    required this.fallbackMethods,
    required this.performanceMetrics,
    required this.metadata,
  });

  factory MultiFactorAuthentication.fromJson(Map<String, dynamic> json) =>
      _$MultiFactorAuthenticationFromJson(json);

  Map<String, dynamic> toJson() => _$MultiFactorAuthenticationToJson(this);
}

// Session Management
@JsonSerializable()
class SessionManagement {
  final String id;
  final String systemName;
  final int sessionTimeout;
  final int maxConcurrentSessions;
  final String sessionStorage;
  final List<String> securityFeatures;
  final Map<String, dynamic> sessionMetrics;
  final Map<String, dynamic> metadata;

  SessionManagement({
    required this.id,
    required this.systemName,
    required this.sessionTimeout,
    required this.maxConcurrentSessions,
    required this.sessionStorage,
    required this.securityFeatures,
    required this.sessionMetrics,
    required this.metadata,
  });

  factory SessionManagement.fromJson(Map<String, dynamic> json) =>
      _$SessionManagementFromJson(json);

  Map<String, dynamic> toJson() => _$SessionManagementFromJson(this);
}

// Audit Trail System
@JsonSerializable()
class AuditTrailSystem {
  final String id;
  final String systemName;
  final String loggingLevel;
  final List<String> loggedEvents;
  final String storageFormat;
  final int retentionPeriod;
  final List<String> securityFeatures;
  final Map<String, dynamic> auditMetrics;
  final Map<String, dynamic> metadata;

  AuditTrailSystem({
    required this.id,
    required this.systemName,
    required this.loggingLevel,
    required this.loggedEvents,
    required this.storageFormat,
    required this.retentionPeriod,
    required this.securityFeatures,
    required this.auditMetrics,
    required this.metadata,
  });

  factory AuditTrailSystem.fromJson(Map<String, dynamic> json) =>
      _$AuditTrailSystemFromJson(json);

  Map<String, dynamic> toJson() => _$AuditTrailSystemFromJson(this);
}

// Data Loss Prevention
@JsonSerializable()
class DataLossPrevention {
  final String id;
  final String systemName;
  final List<String> preventionMethods;
  final List<String> detectionTechniques;
  final List<String> responseActions;
  final Map<String, dynamic> preventionMetrics;
  final List<String> securityFeatures;
  final Map<String, dynamic> metadata;

  DataLossPrevention({
    required this.id,
    required this.systemName,
    required this.preventionMethods,
    required this.detectionTechniques,
    required this.responseActions,
    required this.preventionMetrics,
    required this.securityFeatures,
    required this.metadata,
  });

  factory DataLossPrevention.fromJson(Map<String, dynamic> json) =>
      _$DataLossPreventionFromJson(json);

  Map<String, dynamic> toJson() => _$DataLossPreventionFromJson(this);
}

// Threat Detection & Response
@JsonSerializable()
class ThreatDetectionResponse {
  final String id;
  final String systemName;
  final List<String> detectionMethods;
  final List<String> threatTypes;
  final List<String> responseActions;
  final Map<String, dynamic> detectionMetrics;
  final List<String> securityFeatures;
  final Map<String, dynamic> metadata;

  ThreatDetectionResponse({
    required this.id,
    required this.systemName,
    required this.detectionMethods,
    required this.threatTypes,
    required this.responseActions,
    required this.detectionMetrics,
    required this.securityFeatures,
    required this.metadata,
  });

  factory ThreatDetectionResponse.fromJson(Map<String, dynamic> json) =>
      _$ThreatDetectionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ThreatDetectionResponseFromJson(this);
}

// Privacy by Design
@JsonSerializable()
class PrivacyByDesign {
  final String id;
  final String systemName;
  final List<String> privacyPrinciples;
  final List<String> implementationMethods;
  final List<String> privacyFeatures;
  final Map<String, dynamic> privacyMetrics;
  final Map<String, dynamic> metadata;

  PrivacyByDesign({
    required this.id,
    required this.systemName,
    required this.privacyPrinciples,
    required this.implementationMethods,
    required this.privacyFeatures,
    required this.privacyMetrics,
    required this.metadata,
  });

  factory PrivacyByDesign.fromJson(Map<String, dynamic> json) =>
      _$PrivacyByDesignFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacyByDesignFromJson(this);
}

// Data Anonymization
@JsonSerializable()
class DataAnonymization {
  final String id;
  final String systemName;
  final List<String> anonymizationMethods;
  final List<String> dataTypes;
  final double anonymizationLevel;
  final Map<String, dynamic> anonymizationMetrics;
  final List<String> securityFeatures;
  final Map<String, dynamic> metadata;

  DataAnonymization({
    required this.id,
    required this.systemName,
    required this.anonymizationMethods,
    required this.dataTypes,
    required this.anonymizationLevel,
    required this.anonymizationMetrics,
    required this.securityFeatures,
    required this.metadata,
  });

  factory DataAnonymization.fromJson(Map<String, dynamic> json) =>
      _$DataAnonymizationFromJson(json);

  Map<String, dynamic> toJson() => _$DataAnonymizationFromJson(this);
}

// Secure Communication
@JsonSerializable()
class SecureCommunication {
  final String id;
  final String systemName;
  final String protocol; // TLS, SSL, SSH
  final String version;
  final List<String> cipherSuites;
  final List<String> securityFeatures;
  final Map<String, dynamic> securityMetrics;
  final Map<String, dynamic> metadata;

  SecureCommunication({
    required this.id,
    required this.systemName,
    required this.protocol,
    required this.version,
    required this.cipherSuites,
    required this.securityFeatures,
    required this.securityMetrics,
    required this.metadata,
  });

  factory SecureCommunication.fromJson(Map<String, dynamic> json) =>
      _$SecureCommunicationFromJson(json);

  Map<String, dynamic> toJson() => _$SecureCommunicationFromJson(this);
}

// Security Assessment
@JsonSerializable()
class SecurityAssessment {
  final String id;
  final String assessmentType; // penetration_test, vulnerability_assessment, security_audit
  final DateTime assessmentDate;
  final String assessor;
  final String scope;
  final List<String> findings;
  final List<String> recommendations;
  final String riskLevel; // low, medium, high, critical
  final Map<String, dynamic> assessmentMetrics;
  final Map<String, dynamic> metadata;

  SecurityAssessment({
    required this.id,
    required this.assessmentType,
    required this.assessmentDate,
    required this.assessor,
    required this.scope,
    required this.findings,
    required this.recommendations,
    required this.riskLevel,
    required this.assessmentMetrics,
    required this.metadata,
  });

  factory SecurityAssessment.fromJson(Map<String, dynamic> json) =>
      _$SecurityAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityAssessmentFromJson(this);
}
