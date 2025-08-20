// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'us_health_system_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

USHealthSystemIntegration _$USHealthSystemIntegrationFromJson(
  Map<String, dynamic> json,
) => USHealthSystemIntegration(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  ehrIntegrations: (json['ehrIntegrations'] as List<dynamic>)
      .map((e) => EHRIntegration.fromJson(e as Map<String, dynamic>))
      .toList(),
  payerIntegrations: (json['payerIntegrations'] as List<dynamic>)
      .map((e) => PayerIntegration.fromJson(e as Map<String, dynamic>))
      .toList(),
  fhirSubscriptions: (json['fhirSubscriptions'] as List<dynamic>)
      .map((e) => FHIRSubscription.fromJson(e as Map<String, dynamic>))
      .toList(),
  complianceRequirements: (json['complianceRequirements'] as List<dynamic>)
      .map((e) => USComplianceRequirement.fromJson(e as Map<String, dynamic>))
      .toList(),
  reportingRequirements: (json['reportingRequirements'] as List<dynamic>)
      .map((e) => USReportingRequirement.fromJson(e as Map<String, dynamic>))
      .toList(),
  configuration: json['configuration'] as Map<String, dynamic>,
);

Map<String, dynamic> _$USHealthSystemIntegrationToJson(
  USHealthSystemIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'ehrIntegrations': instance.ehrIntegrations,
  'payerIntegrations': instance.payerIntegrations,
  'fhirSubscriptions': instance.fhirSubscriptions,
  'complianceRequirements': instance.complianceRequirements,
  'reportingRequirements': instance.reportingRequirements,
  'configuration': instance.configuration,
};

EHRIntegration _$EHRIntegrationFromJson(Map<String, dynamic> json) =>
    EHRIntegration(
      id: json['id'] as String,
      vendor: json['vendor'] as String,
      baseUrl: json['baseUrl'] as String,
      isActive: json['isActive'] as bool,
      lastSync: DateTime.parse(json['lastSync'] as String),
      supportedResources: (json['supportedResources'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      authMethod: json['authMethod'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EHRIntegrationToJson(EHRIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendor': instance.vendor,
      'baseUrl': instance.baseUrl,
      'isActive': instance.isActive,
      'lastSync': instance.lastSync.toIso8601String(),
      'supportedResources': instance.supportedResources,
      'authMethod': instance.authMethod,
      'metadata': instance.metadata,
    };

PayerIntegration _$PayerIntegrationFromJson(Map<String, dynamic> json) =>
    PayerIntegration(
      id: json['id'] as String,
      payerName: json['payerName'] as String,
      isActive: json['isActive'] as bool,
      lastSync: DateTime.parse(json['lastSync'] as String),
      claimRules: (json['claimRules'] as List<dynamic>)
          .map((e) => ClaimSubmissionRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      priorAuthRules: (json['priorAuthRules'] as List<dynamic>)
          .map(
            (e) => PriorAuthorizationRule.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PayerIntegrationToJson(PayerIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payerName': instance.payerName,
      'isActive': instance.isActive,
      'lastSync': instance.lastSync.toIso8601String(),
      'claimRules': instance.claimRules,
      'priorAuthRules': instance.priorAuthRules,
      'metadata': instance.metadata,
    };

ClaimSubmissionRule _$ClaimSubmissionRuleFromJson(Map<String, dynamic> json) =>
    ClaimSubmissionRule(
      id: json['id'] as String,
      codeSystem: json['codeSystem'] as String,
      code: json['code'] as String,
      requiredModifiers: (json['requiredModifiers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      requiredDocuments: (json['requiredDocuments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      placeOfService: (json['placeOfService'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allowedTelehealth: json['allowedTelehealth'] as bool,
      policyReference: json['policyReference'] as String,
    );

Map<String, dynamic> _$ClaimSubmissionRuleToJson(
  ClaimSubmissionRule instance,
) => <String, dynamic>{
  'id': instance.id,
  'codeSystem': instance.codeSystem,
  'code': instance.code,
  'requiredModifiers': instance.requiredModifiers,
  'requiredDocuments': instance.requiredDocuments,
  'placeOfService': instance.placeOfService,
  'allowedTelehealth': instance.allowedTelehealth,
  'policyReference': instance.policyReference,
};

PriorAuthorizationRule _$PriorAuthorizationRuleFromJson(
  Map<String, dynamic> json,
) => PriorAuthorizationRule(
  id: json['id'] as String,
  serviceCode: json['serviceCode'] as String,
  payerName: json['payerName'] as String,
  required: json['required'] as bool,
  criteria: (json['criteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  turnaroundTime: json['turnaroundTime'] as String,
);

Map<String, dynamic> _$PriorAuthorizationRuleToJson(
  PriorAuthorizationRule instance,
) => <String, dynamic>{
  'id': instance.id,
  'serviceCode': instance.serviceCode,
  'payerName': instance.payerName,
  'required': instance.required,
  'criteria': instance.criteria,
  'turnaroundTime': instance.turnaroundTime,
};

FHIRSubscription _$FHIRSubscriptionFromJson(Map<String, dynamic> json) =>
    FHIRSubscription(
      id: json['id'] as String,
      resourceType: json['resourceType'] as String,
      criteria: json['criteria'] as String,
      endpoint: json['endpoint'] as String,
      channelType: json['channelType'] as String,
      status: json['status'] as String,
      lastDelivery: DateTime.parse(json['lastDelivery'] as String),
    );

Map<String, dynamic> _$FHIRSubscriptionToJson(FHIRSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resourceType': instance.resourceType,
      'criteria': instance.criteria,
      'endpoint': instance.endpoint,
      'channelType': instance.channelType,
      'status': instance.status,
      'lastDelivery': instance.lastDelivery.toIso8601String(),
    };

USComplianceRequirement _$USComplianceRequirementFromJson(
  Map<String, dynamic> json,
) => USComplianceRequirement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  regulation: json['regulation'] as String,
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  status: json['status'] as String,
  controls: (json['controls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  evidence: (json['evidence'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$USComplianceRequirementToJson(
  USComplianceRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'regulation': instance.regulation,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'status': instance.status,
  'controls': instance.controls,
  'evidence': instance.evidence,
};

USReportingRequirement _$USReportingRequirementFromJson(
  Map<String, dynamic> json,
) => USReportingRequirement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  authority: json['authority'] as String,
  frequency: json['frequency'] as String,
  format: json['format'] as String,
  nextDueDate: DateTime.parse(json['nextDueDate'] as String),
);

Map<String, dynamic> _$USReportingRequirementToJson(
  USReportingRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'authority': instance.authority,
  'frequency': instance.frequency,
  'format': instance.format,
  'nextDueDate': instance.nextDueDate.toIso8601String(),
};
