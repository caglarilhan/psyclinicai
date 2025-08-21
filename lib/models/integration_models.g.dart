// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntegrationProfile _$IntegrationProfileFromJson(Map<String, dynamic> json) =>
    IntegrationProfile(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      institutionId: json['institutionId'] as String,
      integrations: (json['integrations'] as List<dynamic>)
          .map((e) => Integration.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallStatus: $enumDecode(
        _$IntegrationStatusEnumMap,
        json['overallStatus'],
      ),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => IntegrationAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$IntegrationProfileToJson(IntegrationProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clinicianId': instance.clinicianId,
      'institutionId': instance.institutionId,
      'integrations': instance.integrations,
      'overallStatus': _$IntegrationStatusEnumMap[instance.overallStatus]!,
      'alerts': instance.alerts,
      'metadata': instance.metadata,
    };

const _$IntegrationStatusEnumMap = {
  IntegrationStatus.active: 'active',
  IntegrationStatus.partial: 'partial',
  IntegrationStatus.inactive: 'inactive',
  IntegrationStatus.error: 'error',
  IntegrationStatus.maintenance: 'maintenance',
};

EHRIntegration _$EHRIntegrationFromJson(
  Map<String, dynamic> json,
) => EHRIntegration(
  id: json['id'] as String,
  name: json['name'] as String,
  vendor: json['vendor'] as String,
  version: json['version'] as String,
  type: $enumDecode(_$IntegrationTypeEnumMap, json['type']),
  status: $enumDecode(_$IntegrationStatusEnumMap, json['status']),
  lastSync: DateTime.parse(json['lastSync'] as String),
  supportedFeatures: (json['supportedFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dataFields: (json['dataFields'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  fhirConfig: json['fhirConfig'] == null
      ? null
      : FHIRConfiguration.fromJson(json['fhirConfig'] as Map<String, dynamic>),
  hl7Config: json['hl7Config'] == null
      ? null
      : HL7Configuration.fromJson(json['hl7Config'] as Map<String, dynamic>),
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$EHRIntegrationToJson(EHRIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vendor': instance.vendor,
      'version': instance.version,
      'type': _$IntegrationTypeEnumMap[instance.type]!,
      'status': _$IntegrationStatusEnumMap[instance.status]!,
      'lastSync': instance.lastSync.toIso8601String(),
      'supportedFeatures': instance.supportedFeatures,
      'dataFields': instance.dataFields,
      'fhirConfig': instance.fhirConfig,
      'hl7Config': instance.hl7Config,
      'alerts': instance.alerts,
      'metadata': instance.metadata,
    };

const _$IntegrationTypeEnumMap = {
  IntegrationType.fhir: 'fhir',
  IntegrationType.hl7: 'hl7',
  IntegrationType.api: 'api',
  IntegrationType.direct: 'direct',
  IntegrationType.hybrid: 'hybrid',
};

FHIRConfiguration _$FHIRConfigurationFromJson(Map<String, dynamic> json) =>
    FHIRConfiguration(
      baseUrl: json['baseUrl'] as String,
      version: json['version'] as String,
      resources: (json['resources'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      authentication: AuthenticationConfig.fromJson(
        json['authentication'] as Map<String, dynamic>,
      ),
      scopes: (json['scopes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rateLimit: RateLimitConfig.fromJson(
        json['rateLimit'] as Map<String, dynamic>,
      ),
      customExtensions: (json['customExtensions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$FHIRConfigurationToJson(FHIRConfiguration instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'version': instance.version,
      'resources': instance.resources,
      'authentication': instance.authentication,
      'scopes': instance.scopes,
      'rateLimit': instance.rateLimit,
      'customExtensions': instance.customExtensions,
    };

HL7Configuration _$HL7ConfigurationFromJson(Map<String, dynamic> json) =>
    HL7Configuration(
      version: json['version'] as String,
      messageType: json['messageType'] as String,
      encoding: json['encoding'] as String,
      endpoint: json['endpoint'] as String,
      messageTypes: (json['messageTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      customSegments: (json['customSegments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HL7ConfigurationToJson(HL7Configuration instance) =>
    <String, dynamic>{
      'version': instance.version,
      'messageType': instance.messageType,
      'encoding': instance.encoding,
      'endpoint': instance.endpoint,
      'messageTypes': instance.messageTypes,
      'customSegments': instance.customSegments,
    };

AuthenticationConfig _$AuthenticationConfigFromJson(
  Map<String, dynamic> json,
) => AuthenticationConfig(
  type: json['type'] as String,
  clientId: json['clientId'] as String,
  clientSecret: json['clientSecret'] as String?,
  redirectUri: json['redirectUri'] as String?,
  scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
  tokenEndpoint: json['tokenEndpoint'] as String?,
  tokenExpiry: json['tokenExpiry'] == null
      ? null
      : DateTime.parse(json['tokenExpiry'] as String),
);

Map<String, dynamic> _$AuthenticationConfigToJson(
  AuthenticationConfig instance,
) => <String, dynamic>{
  'type': instance.type,
  'clientId': instance.clientId,
  'clientSecret': instance.clientSecret,
  'redirectUri': instance.redirectUri,
  'scopes': instance.scopes,
  'tokenEndpoint': instance.tokenEndpoint,
  'tokenExpiry': instance.tokenExpiry?.toIso8601String(),
};

RateLimitConfig _$RateLimitConfigFromJson(Map<String, dynamic> json) =>
    RateLimitConfig(
      requestsPerMinute: (json['requestsPerMinute'] as num).toInt(),
      requestsPerHour: (json['requestsPerHour'] as num).toInt(),
      burstLimit: (json['burstLimit'] as num).toInt(),
      retryAfter: json['retryAfter'] as String?,
    );

Map<String, dynamic> _$RateLimitConfigToJson(RateLimitConfig instance) =>
    <String, dynamic>{
      'requestsPerMinute': instance.requestsPerMinute,
      'requestsPerHour': instance.requestsPerHour,
      'burstLimit': instance.burstLimit,
      'retryAfter': instance.retryAfter,
    };

LabIntegration _$LabIntegrationFromJson(Map<String, dynamic> json) =>
    LabIntegration(
      id: json['id'] as String,
      name: json['name'] as String,
      labSystem: json['labSystem'] as String,
      status: $enumDecode(_$IntegrationStatusEnumMap, json['status']),
      lastSync: DateTime.parse(json['lastSync'] as String),
      testTypes: (json['testTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      resultFields: (json['resultFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alertRules: (json['alertRules'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dataMapping: LabDataMapping.fromJson(
        json['dataMapping'] as Map<String, dynamic>,
      ),
      supportedTests: (json['supportedTests'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LabIntegrationToJson(LabIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'labSystem': instance.labSystem,
      'status': _$IntegrationStatusEnumMap[instance.status]!,
      'lastSync': instance.lastSync.toIso8601String(),
      'testTypes': instance.testTypes,
      'resultFields': instance.resultFields,
      'alertRules': instance.alertRules,
      'dataMapping': instance.dataMapping,
      'supportedTests': instance.supportedTests,
      'metadata': instance.metadata,
    };

LabDataMapping _$LabDataMappingFromJson(Map<String, dynamic> json) =>
    LabDataMapping(
      fieldMappings: Map<String, String>.from(json['fieldMappings'] as Map),
      unitConversions: Map<String, String>.from(json['unitConversions'] as Map),
      referenceRanges: Map<String, String>.from(json['referenceRanges'] as Map),
      criticalValues: (json['criticalValues'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alertThresholds: (json['alertThresholds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LabDataMappingToJson(LabDataMapping instance) =>
    <String, dynamic>{
      'fieldMappings': instance.fieldMappings,
      'unitConversions': instance.unitConversions,
      'referenceRanges': instance.referenceRanges,
      'criticalValues': instance.criticalValues,
      'alertThresholds': instance.alertThresholds,
    };

LabResult _$LabResultFromJson(Map<String, dynamic> json) => LabResult(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  testId: json['testId'] as String,
  testName: json['testName'] as String,
  result: json['result'] as String,
  unit: json['unit'] as String,
  referenceRange: json['referenceRange'] as String,
  flag: $enumDecode(_$ResultFlagEnumMap, json['flag']),
  collectionDate: DateTime.parse(json['collectionDate'] as String),
  resultDate: DateTime.parse(json['resultDate'] as String),
  labId: json['labId'] as String,
  notes: json['notes'] as String?,
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$LabResultToJson(LabResult instance) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'testId': instance.testId,
  'testName': instance.testName,
  'result': instance.result,
  'unit': instance.unit,
  'referenceRange': instance.referenceRange,
  'flag': _$ResultFlagEnumMap[instance.flag]!,
  'collectionDate': instance.collectionDate.toIso8601String(),
  'resultDate': instance.resultDate.toIso8601String(),
  'labId': instance.labId,
  'notes': instance.notes,
  'alerts': instance.alerts,
};

const _$ResultFlagEnumMap = {
  ResultFlag.normal: 'normal',
  ResultFlag.high: 'high',
  ResultFlag.low: 'low',
  ResultFlag.criticalHigh: 'critical_high',
  ResultFlag.criticalLow: 'critical_low',
  ResultFlag.abnormal: 'abnormal',
};

PharmacyIntegration _$PharmacyIntegrationFromJson(Map<String, dynamic> json) =>
    PharmacyIntegration(
      id: json['id'] as String,
      name: json['name'] as String,
      pharmacySystem: json['pharmacySystem'] as String,
      status: $enumDecode(_$IntegrationStatusEnumMap, json['status']),
      lastSync: DateTime.parse(json['lastSync'] as String),
      supportedFeatures: (json['supportedFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medicationFields: (json['medicationFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ePrescription: EPrescriptionConfig.fromJson(
        json['ePrescription'] as Map<String, dynamic>,
      ),
      refillTracking: RefillTrackingConfig.fromJson(
        json['refillTracking'] as Map<String, dynamic>,
      ),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PharmacyIntegrationToJson(
  PharmacyIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'pharmacySystem': instance.pharmacySystem,
  'status': _$IntegrationStatusEnumMap[instance.status]!,
  'lastSync': instance.lastSync.toIso8601String(),
  'supportedFeatures': instance.supportedFeatures,
  'medicationFields': instance.medicationFields,
  'ePrescription': instance.ePrescription,
  'refillTracking': instance.refillTracking,
  'alerts': instance.alerts,
  'metadata': instance.metadata,
};

EPrescriptionConfig _$EPrescriptionConfigFromJson(Map<String, dynamic> json) =>
    EPrescriptionConfig(
      isEnabled: json['isEnabled'] as bool,
      standard: json['standard'] as String,
      supportedMedications: (json['supportedMedications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      controlledSubstances: (json['controlledSubstances'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      formulary: (json['formulary'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      insurancePlans: (json['insurancePlans'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EPrescriptionConfigToJson(
  EPrescriptionConfig instance,
) => <String, dynamic>{
  'isEnabled': instance.isEnabled,
  'standard': instance.standard,
  'supportedMedications': instance.supportedMedications,
  'controlledSubstances': instance.controlledSubstances,
  'formulary': instance.formulary,
  'insurancePlans': instance.insurancePlans,
};

RefillTrackingConfig _$RefillTrackingConfigFromJson(
  Map<String, dynamic> json,
) => RefillTrackingConfig(
  isEnabled: json['isEnabled'] as bool,
  trackingFields: (json['trackingFields'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notificationTypes: (json['notificationTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  refillRules: (json['refillRules'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  approvalWorkflow: (json['approvalWorkflow'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RefillTrackingConfigToJson(
  RefillTrackingConfig instance,
) => <String, dynamic>{
  'isEnabled': instance.isEnabled,
  'trackingFields': instance.trackingFields,
  'notificationTypes': instance.notificationTypes,
  'refillRules': instance.refillRules,
  'approvalWorkflow': instance.approvalWorkflow,
};

InsuranceIntegration _$InsuranceIntegrationFromJson(
  Map<String, dynamic> json,
) => InsuranceIntegration(
  id: json['id'] as String,
  name: json['name'] as String,
  insuranceSystem: json['insuranceSystem'] as String,
  region: json['region'] as String,
  status: $enumDecode(_$IntegrationStatusEnumMap, json['status']),
  lastSync: DateTime.parse(json['lastSync'] as String),
  supportedPlans: (json['supportedPlans'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  coverageTypes: (json['coverageTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  claimAutomation: ClaimAutomationConfig.fromJson(
    json['claimAutomation'] as Map<String, dynamic>,
  ),
  reimbursement: ReimbursementConfig.fromJson(
    json['reimbursement'] as Map<String, dynamic>,
  ),
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$InsuranceIntegrationToJson(
  InsuranceIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'insuranceSystem': instance.insuranceSystem,
  'region': instance.region,
  'status': _$IntegrationStatusEnumMap[instance.status]!,
  'lastSync': instance.lastSync.toIso8601String(),
  'supportedPlans': instance.supportedPlans,
  'coverageTypes': instance.coverageTypes,
  'claimAutomation': instance.claimAutomation,
  'reimbursement': instance.reimbursement,
  'alerts': instance.alerts,
  'metadata': instance.metadata,
};

ClaimAutomationConfig _$ClaimAutomationConfigFromJson(
  Map<String, dynamic> json,
) => ClaimAutomationConfig(
  isEnabled: json['isEnabled'] as bool,
  standard: json['standard'] as String,
  claimTypes: (json['claimTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiredFields: (json['requiredFields'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  validationRules: (json['validationRules'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  approvalWorkflow: (json['approvalWorkflow'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ClaimAutomationConfigToJson(
  ClaimAutomationConfig instance,
) => <String, dynamic>{
  'isEnabled': instance.isEnabled,
  'standard': instance.standard,
  'claimTypes': instance.claimTypes,
  'requiredFields': instance.requiredFields,
  'validationRules': instance.validationRules,
  'approvalWorkflow': instance.approvalWorkflow,
};

ReimbursementConfig _$ReimbursementConfigFromJson(Map<String, dynamic> json) =>
    ReimbursementConfig(
      isEnabled: json['isEnabled'] as bool,
      currency: json['currency'] as String,
      paymentMethods: (json['paymentMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      feeSchedules: (json['feeSchedules'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      billingCodes: (json['billingCodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      documentationRequirements:
          (json['documentationRequirements'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$ReimbursementConfigToJson(
  ReimbursementConfig instance,
) => <String, dynamic>{
  'isEnabled': instance.isEnabled,
  'currency': instance.currency,
  'paymentMethods': instance.paymentMethods,
  'feeSchedules': instance.feeSchedules,
  'billingCodes': instance.billingCodes,
  'documentationRequirements': instance.documentationRequirements,
};

MobileTelepsychiatryIntegration _$MobileTelepsychiatryIntegrationFromJson(
  Map<String, dynamic> json,
) => MobileTelepsychiatryIntegration(
  id: json['id'] as String,
  name: json['name'] as String,
  platform: json['platform'] as String,
  status: $enumDecode(_$IntegrationStatusEnumMap, json['status']),
  lastSync: DateTime.parse(json['lastSync'] as String),
  supportedFeatures: (json['supportedFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  offlineConfig: OfflineConfig.fromJson(
    json['offlineConfig'] as Map<String, dynamic>,
  ),
  securityConfig: SecurityConfig.fromJson(
    json['securityConfig'] as Map<String, dynamic>,
  ),
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MobileTelepsychiatryIntegrationToJson(
  MobileTelepsychiatryIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'platform': instance.platform,
  'status': _$IntegrationStatusEnumMap[instance.status]!,
  'lastSync': instance.lastSync.toIso8601String(),
  'supportedFeatures': instance.supportedFeatures,
  'offlineConfig': instance.offlineConfig,
  'securityConfig': instance.securityConfig,
  'alerts': instance.alerts,
  'metadata': instance.metadata,
};

OfflineConfig _$OfflineConfigFromJson(Map<String, dynamic> json) =>
    OfflineConfig(
      isEnabled: json['isEnabled'] as bool,
      offlineFeatures: (json['offlineFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      syncStrategy: json['syncStrategy'] as String,
      maxOfflineDays: (json['maxOfflineDays'] as num).toInt(),
      dataTypes: (json['dataTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      conflictResolution: (json['conflictResolution'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OfflineConfigToJson(OfflineConfig instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'offlineFeatures': instance.offlineFeatures,
      'syncStrategy': instance.syncStrategy,
      'maxOfflineDays': instance.maxOfflineDays,
      'dataTypes': instance.dataTypes,
      'conflictResolution': instance.conflictResolution,
    };

SecurityConfig _$SecurityConfigFromJson(Map<String, dynamic> json) =>
    SecurityConfig(
      biometricAuth: json['biometricAuth'] as bool,
      encryption: json['encryption'] as bool,
      securityFeatures: (json['securityFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      complianceStandards: (json['complianceStandards'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      auditLogs: (json['auditLogs'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      accessControls: (json['accessControls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SecurityConfigToJson(SecurityConfig instance) =>
    <String, dynamic>{
      'biometricAuth': instance.biometricAuth,
      'encryption': instance.encryption,
      'securityFeatures': instance.securityFeatures,
      'complianceStandards': instance.complianceStandards,
      'auditLogs': instance.auditLogs,
      'accessControls': instance.accessControls,
    };

IntegrationAlert _$IntegrationAlertFromJson(Map<String, dynamic> json) =>
    IntegrationAlert(
      id: json['id'] as String,
      integrationId: json['integrationId'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isAcknowledged: json['isAcknowledged'] as bool,
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.parse(json['acknowledgedAt'] as String),
      acknowledgedBy: json['acknowledgedBy'] as String?,
      actions: (json['actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$IntegrationAlertToJson(IntegrationAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'integrationId': instance.integrationId,
      'type': instance.type,
      'message': instance.message,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isAcknowledged': instance.isAcknowledged,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': instance.acknowledgedBy,
      'actions': instance.actions,
    };

const _$AlertSeverityEnumMap = {
  AlertSeverity.info: 'info',
  AlertSeverity.warning: 'warning',
  AlertSeverity.error: 'error',
  AlertSeverity.critical: 'critical',
};

IntegrationSummary _$IntegrationSummaryFromJson(Map<String, dynamic> json) =>
    IntegrationSummary(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      summaryDate: DateTime.parse(json['summaryDate'] as String),
      overallStatus: $enumDecode(
        _$IntegrationStatusEnumMap,
        json['overallStatus'],
      ),
      activeIntegrations: (json['activeIntegrations'] as List<dynamic>)
          .map((e) => Integration.fromJson(e as Map<String, dynamic>))
          .toList(),
      inactiveIntegrations: (json['inactiveIntegrations'] as List<dynamic>)
          .map((e) => Integration.fromJson(e as Map<String, dynamic>))
          .toList(),
      criticalAlerts: (json['criticalAlerts'] as List<dynamic>)
          .map((e) => IntegrationAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$IntegrationSummaryToJson(IntegrationSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clinicianId': instance.clinicianId,
      'summaryDate': instance.summaryDate.toIso8601String(),
      'overallStatus': _$IntegrationStatusEnumMap[instance.overallStatus]!,
      'activeIntegrations': instance.activeIntegrations,
      'inactiveIntegrations': instance.inactiveIntegrations,
      'criticalAlerts': instance.criticalAlerts,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
    };

Integration _$IntegrationFromJson(Map<String, dynamic> json) => Integration(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  status: $enumDecode(_$IntegrationStatusEnumMap, json['status']),
  lastSync: DateTime.parse(json['lastSync'] as String),
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  config: json['config'] as Map<String, dynamic>?,
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$IntegrationToJson(Integration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'status': _$IntegrationStatusEnumMap[instance.status]!,
      'lastSync': instance.lastSync.toIso8601String(),
      'features': instance.features,
      'config': instance.config,
      'alerts': instance.alerts,
    };
