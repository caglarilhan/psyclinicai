// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_security_privacy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvancedSecurityPrivacy _$AdvancedSecurityPrivacyFromJson(
  Map<String, dynamic> json,
) => AdvancedSecurityPrivacy(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  version: json['version'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  securityFeatures: json['securityFeatures'] as Map<String, dynamic>,
  privacyFeatures: json['privacyFeatures'] as Map<String, dynamic>,
  complianceFeatures: json['complianceFeatures'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AdvancedSecurityPrivacyToJson(
  AdvancedSecurityPrivacy instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'version': instance.version,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'securityFeatures': instance.securityFeatures,
  'privacyFeatures': instance.privacyFeatures,
  'complianceFeatures': instance.complianceFeatures,
  'metadata': instance.metadata,
};

HIPAACompliance _$HIPAAComplianceFromJson(Map<String, dynamic> json) =>
    HIPAACompliance(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      complianceStatus: json['complianceStatus'] as String,
      complianceScore: (json['complianceScore'] as num).toDouble(),
      privacyRuleCompliance: (json['privacyRuleCompliance'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      securityRuleCompliance: (json['securityRuleCompliance'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      breachNotificationCompliance:
          (json['breachNotificationCompliance'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      compliantAreas: (json['compliantAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nonCompliantAreas: (json['nonCompliantAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextAssessmentDate: DateTime.parse(json['nextAssessmentDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$HIPAAComplianceToJson(HIPAACompliance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'organizationName': instance.organizationName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'complianceStatus': instance.complianceStatus,
      'complianceScore': instance.complianceScore,
      'privacyRuleCompliance': instance.privacyRuleCompliance,
      'securityRuleCompliance': instance.securityRuleCompliance,
      'breachNotificationCompliance': instance.breachNotificationCompliance,
      'compliantAreas': instance.compliantAreas,
      'nonCompliantAreas': instance.nonCompliantAreas,
      'recommendations': instance.recommendations,
      'nextAssessmentDate': instance.nextAssessmentDate.toIso8601String(),
      'metadata': instance.metadata,
    };

GDPRCompliance _$GDPRComplianceFromJson(Map<String, dynamic> json) =>
    GDPRCompliance(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      complianceStatus: json['complianceStatus'] as String,
      complianceScore: (json['complianceScore'] as num).toDouble(),
      dataProcessingPrinciples:
          (json['dataProcessingPrinciples'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      dataSubjectRights: (json['dataSubjectRights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dataProtectionMeasures: (json['dataProtectionMeasures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      breachNotificationProcedures:
          (json['breachNotificationProcedures'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      compliantAreas: (json['compliantAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nonCompliantAreas: (json['nonCompliantAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextAssessmentDate: DateTime.parse(json['nextAssessmentDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GDPRComplianceToJson(GDPRCompliance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'organizationName': instance.organizationName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'complianceStatus': instance.complianceStatus,
      'complianceScore': instance.complianceScore,
      'dataProcessingPrinciples': instance.dataProcessingPrinciples,
      'dataSubjectRights': instance.dataSubjectRights,
      'dataProtectionMeasures': instance.dataProtectionMeasures,
      'breachNotificationProcedures': instance.breachNotificationProcedures,
      'compliantAreas': instance.compliantAreas,
      'nonCompliantAreas': instance.nonCompliantAreas,
      'recommendations': instance.recommendations,
      'nextAssessmentDate': instance.nextAssessmentDate.toIso8601String(),
      'metadata': instance.metadata,
    };

KVKKCompliance _$KVKKComplianceFromJson(Map<String, dynamic> json) =>
    KVKKCompliance(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      complianceStatus: json['complianceStatus'] as String,
      complianceScore: (json['complianceScore'] as num).toDouble(),
      veriIslemeKurallari: (json['veriIslemeKurallari'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      veriGuvenligiOnlemleri: (json['veriGuvenligiOnlemleri'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      acikRizaGereklilikleri: (json['acikRizaGereklilikleri'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      veriSahibiHaklari: (json['veriSahibiHaklari'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      compliantAreas: (json['compliantAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nonCompliantAreas: (json['nonCompliantAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextAssessmentDate: DateTime.parse(json['nextAssessmentDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$KVKKComplianceToJson(KVKKCompliance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'organizationName': instance.organizationName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'complianceStatus': instance.complianceStatus,
      'complianceScore': instance.complianceScore,
      'veriIslemeKurallari': instance.veriIslemeKurallari,
      'veriGuvenligiOnlemleri': instance.veriGuvenligiOnlemleri,
      'acikRizaGereklilikleri': instance.acikRizaGereklilikleri,
      'veriSahibiHaklari': instance.veriSahibiHaklari,
      'compliantAreas': instance.compliantAreas,
      'nonCompliantAreas': instance.nonCompliantAreas,
      'recommendations': instance.recommendations,
      'nextAssessmentDate': instance.nextAssessmentDate.toIso8601String(),
      'metadata': instance.metadata,
    };

EndToEndEncryption _$EndToEndEncryptionFromJson(Map<String, dynamic> json) =>
    EndToEndEncryption(
      id: json['id'] as String,
      encryptionType: json['encryptionType'] as String,
      keyManagement: json['keyManagement'] as String,
      algorithm: json['algorithm'] as String,
      keyLength: (json['keyLength'] as num).toInt(),
      keyRotationPolicy: json['keyRotationPolicy'] as String,
      lastKeyRotation: DateTime.parse(json['lastKeyRotation'] as String),
      encryptionLayers: (json['encryptionLayers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      encryptionMetrics: json['encryptionMetrics'] as Map<String, dynamic>,
      securityFeatures: (json['securityFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EndToEndEncryptionToJson(EndToEndEncryption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'encryptionType': instance.encryptionType,
      'keyManagement': instance.keyManagement,
      'algorithm': instance.algorithm,
      'keyLength': instance.keyLength,
      'keyRotationPolicy': instance.keyRotationPolicy,
      'lastKeyRotation': instance.lastKeyRotation.toIso8601String(),
      'encryptionLayers': instance.encryptionLayers,
      'encryptionMetrics': instance.encryptionMetrics,
      'securityFeatures': instance.securityFeatures,
      'metadata': instance.metadata,
    };

BiometricAuthentication _$BiometricAuthenticationFromJson(
  Map<String, dynamic> json,
) => BiometricAuthentication(
  id: json['id'] as String,
  biometricType: json['biometricType'] as String,
  authenticationMethod: json['authenticationMethod'] as String,
  accuracyRate: (json['accuracyRate'] as num).toDouble(),
  falseAcceptanceRate: (json['falseAcceptanceRate'] as num).toDouble(),
  falseRejectionRate: (json['falseRejectionRate'] as num).toDouble(),
  securityFeatures: (json['securityFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  fallbackMethods: (json['fallbackMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$BiometricAuthenticationToJson(
  BiometricAuthentication instance,
) => <String, dynamic>{
  'id': instance.id,
  'biometricType': instance.biometricType,
  'authenticationMethod': instance.authenticationMethod,
  'accuracyRate': instance.accuracyRate,
  'falseAcceptanceRate': instance.falseAcceptanceRate,
  'falseRejectionRate': instance.falseRejectionRate,
  'securityFeatures': instance.securityFeatures,
  'fallbackMethods': instance.fallbackMethods,
  'performanceMetrics': instance.performanceMetrics,
  'metadata': instance.metadata,
};

BlockchainMedicalRecords _$BlockchainMedicalRecordsFromJson(
  Map<String, dynamic> json,
) => BlockchainMedicalRecords(
  id: json['id'] as String,
  blockchainType: json['blockchainType'] as String,
  consensusMechanism: json['consensusMechanism'] as String,
  hashAlgorithm: json['hashAlgorithm'] as String,
  blockSize: (json['blockSize'] as num).toInt(),
  blockTime: (json['blockTime'] as num).toDouble(),
  smartContracts: (json['smartContracts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dataTypes: (json['dataTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
  securityFeatures: json['securityFeatures'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$BlockchainMedicalRecordsToJson(
  BlockchainMedicalRecords instance,
) => <String, dynamic>{
  'id': instance.id,
  'blockchainType': instance.blockchainType,
  'consensusMechanism': instance.consensusMechanism,
  'hashAlgorithm': instance.hashAlgorithm,
  'blockSize': instance.blockSize,
  'blockTime': instance.blockTime,
  'smartContracts': instance.smartContracts,
  'dataTypes': instance.dataTypes,
  'performanceMetrics': instance.performanceMetrics,
  'securityFeatures': instance.securityFeatures,
  'metadata': instance.metadata,
};

AccessControlSystem _$AccessControlSystemFromJson(Map<String, dynamic> json) =>
    AccessControlSystem(
      id: json['id'] as String,
      systemName: json['systemName'] as String,
      accessModel: json['accessModel'] as String,
      userRoles: (json['userRoles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      accessLevels: (json['accessLevels'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      accessPolicies: json['accessPolicies'] as Map<String, dynamic>,
      securityFeatures: (json['securityFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      auditTrail: json['auditTrail'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AccessControlSystemToJson(
  AccessControlSystem instance,
) => <String, dynamic>{
  'id': instance.id,
  'systemName': instance.systemName,
  'accessModel': instance.accessModel,
  'userRoles': instance.userRoles,
  'permissions': instance.permissions,
  'accessLevels': instance.accessLevels,
  'accessPolicies': instance.accessPolicies,
  'securityFeatures': instance.securityFeatures,
  'auditTrail': instance.auditTrail,
  'metadata': instance.metadata,
};

MultiFactorAuthentication _$MultiFactorAuthenticationFromJson(
  Map<String, dynamic> json,
) => MultiFactorAuthentication(
  id: json['id'] as String,
  systemName: json['systemName'] as String,
  factors: (json['factors'] as List<dynamic>).map((e) => e as String).toList(),
  authenticationFlow: json['authenticationFlow'] as String,
  successRate: (json['successRate'] as num).toDouble(),
  falsePositiveRate: (json['falsePositiveRate'] as num).toDouble(),
  securityFeatures: (json['securityFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  fallbackMethods: (json['fallbackMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MultiFactorAuthenticationToJson(
  MultiFactorAuthentication instance,
) => <String, dynamic>{
  'id': instance.id,
  'systemName': instance.systemName,
  'factors': instance.factors,
  'authenticationFlow': instance.authenticationFlow,
  'successRate': instance.successRate,
  'falsePositiveRate': instance.falsePositiveRate,
  'securityFeatures': instance.securityFeatures,
  'fallbackMethods': instance.fallbackMethods,
  'performanceMetrics': instance.performanceMetrics,
  'metadata': instance.metadata,
};

SessionManagement _$SessionManagementFromJson(Map<String, dynamic> json) =>
    SessionManagement(
      id: json['id'] as String,
      systemName: json['systemName'] as String,
      sessionTimeout: (json['sessionTimeout'] as num).toInt(),
      maxConcurrentSessions: (json['maxConcurrentSessions'] as num).toInt(),
      sessionStorage: json['sessionStorage'] as String,
      securityFeatures: (json['securityFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sessionMetrics: json['sessionMetrics'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionManagementToJson(SessionManagement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'systemName': instance.systemName,
      'sessionTimeout': instance.sessionTimeout,
      'maxConcurrentSessions': instance.maxConcurrentSessions,
      'sessionStorage': instance.sessionStorage,
      'securityFeatures': instance.securityFeatures,
      'sessionMetrics': instance.sessionMetrics,
      'metadata': instance.metadata,
    };

AuditTrailSystem _$AuditTrailSystemFromJson(Map<String, dynamic> json) =>
    AuditTrailSystem(
      id: json['id'] as String,
      systemName: json['systemName'] as String,
      loggingLevel: json['loggingLevel'] as String,
      loggedEvents: (json['loggedEvents'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      storageFormat: json['storageFormat'] as String,
      retentionPeriod: (json['retentionPeriod'] as num).toInt(),
      securityFeatures: (json['securityFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      auditMetrics: json['auditMetrics'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AuditTrailSystemToJson(AuditTrailSystem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'systemName': instance.systemName,
      'loggingLevel': instance.loggingLevel,
      'loggedEvents': instance.loggedEvents,
      'storageFormat': instance.storageFormat,
      'retentionPeriod': instance.retentionPeriod,
      'securityFeatures': instance.securityFeatures,
      'auditMetrics': instance.auditMetrics,
      'metadata': instance.metadata,
    };

DataLossPrevention _$DataLossPreventionFromJson(Map<String, dynamic> json) =>
    DataLossPrevention(
      id: json['id'] as String,
      systemName: json['systemName'] as String,
      preventionMethods: (json['preventionMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      detectionTechniques: (json['detectionTechniques'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      responseActions: (json['responseActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      preventionMetrics: json['preventionMetrics'] as Map<String, dynamic>,
      securityFeatures: (json['securityFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DataLossPreventionToJson(DataLossPrevention instance) =>
    <String, dynamic>{
      'id': instance.id,
      'systemName': instance.systemName,
      'preventionMethods': instance.preventionMethods,
      'detectionTechniques': instance.detectionTechniques,
      'responseActions': instance.responseActions,
      'preventionMetrics': instance.preventionMetrics,
      'securityFeatures': instance.securityFeatures,
      'metadata': instance.metadata,
    };

ThreatDetectionResponse _$ThreatDetectionResponseFromJson(
  Map<String, dynamic> json,
) => ThreatDetectionResponse(
  id: json['id'] as String,
  systemName: json['systemName'] as String,
  detectionMethods: (json['detectionMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  threatTypes: (json['threatTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  responseActions: (json['responseActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  detectionMetrics: json['detectionMetrics'] as Map<String, dynamic>,
  securityFeatures: (json['securityFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ThreatDetectionResponseToJson(
  ThreatDetectionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'systemName': instance.systemName,
  'detectionMethods': instance.detectionMethods,
  'threatTypes': instance.threatTypes,
  'responseActions': instance.responseActions,
  'detectionMetrics': instance.detectionMetrics,
  'securityFeatures': instance.securityFeatures,
  'metadata': instance.metadata,
};

PrivacyByDesign _$PrivacyByDesignFromJson(Map<String, dynamic> json) =>
    PrivacyByDesign(
      id: json['id'] as String,
      systemName: json['systemName'] as String,
      privacyPrinciples: (json['privacyPrinciples'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      implementationMethods: (json['implementationMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      privacyFeatures: (json['privacyFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      privacyMetrics: json['privacyMetrics'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PrivacyByDesignToJson(PrivacyByDesign instance) =>
    <String, dynamic>{
      'id': instance.id,
      'systemName': instance.systemName,
      'privacyPrinciples': instance.privacyPrinciples,
      'implementationMethods': instance.implementationMethods,
      'privacyFeatures': instance.privacyFeatures,
      'privacyMetrics': instance.privacyMetrics,
      'metadata': instance.metadata,
    };

DataAnonymization _$DataAnonymizationFromJson(Map<String, dynamic> json) =>
    DataAnonymization(
      id: json['id'] as String,
      systemName: json['systemName'] as String,
      anonymizationMethods: (json['anonymizationMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dataTypes: (json['dataTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      anonymizationLevel: (json['anonymizationLevel'] as num).toDouble(),
      anonymizationMetrics:
          json['anonymizationMetrics'] as Map<String, dynamic>,
      securityFeatures: (json['securityFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DataAnonymizationToJson(DataAnonymization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'systemName': instance.systemName,
      'anonymizationMethods': instance.anonymizationMethods,
      'dataTypes': instance.dataTypes,
      'anonymizationLevel': instance.anonymizationLevel,
      'anonymizationMetrics': instance.anonymizationMetrics,
      'securityFeatures': instance.securityFeatures,
      'metadata': instance.metadata,
    };

SecureCommunication _$SecureCommunicationFromJson(Map<String, dynamic> json) =>
    SecureCommunication(
      id: json['id'] as String,
      systemName: json['systemName'] as String,
      protocol: json['protocol'] as String,
      version: json['version'] as String,
      cipherSuites: (json['cipherSuites'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      securityFeatures: (json['securityFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      securityMetrics: json['securityMetrics'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SecureCommunicationToJson(
  SecureCommunication instance,
) => <String, dynamic>{
  'id': instance.id,
  'systemName': instance.systemName,
  'protocol': instance.protocol,
  'version': instance.version,
  'cipherSuites': instance.cipherSuites,
  'securityFeatures': instance.securityFeatures,
  'securityMetrics': instance.securityMetrics,
  'metadata': instance.metadata,
};

SecurityAssessment _$SecurityAssessmentFromJson(Map<String, dynamic> json) =>
    SecurityAssessment(
      id: json['id'] as String,
      assessmentType: json['assessmentType'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      assessor: json['assessor'] as String,
      scope: json['scope'] as String,
      findings: (json['findings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskLevel: json['riskLevel'] as String,
      assessmentMetrics: json['assessmentMetrics'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SecurityAssessmentToJson(SecurityAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assessmentType': instance.assessmentType,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'assessor': instance.assessor,
      'scope': instance.scope,
      'findings': instance.findings,
      'recommendations': instance.recommendations,
      'riskLevel': instance.riskLevel,
      'assessmentMetrics': instance.assessmentMetrics,
      'metadata': instance.metadata,
    };
