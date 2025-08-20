// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eu_health_system_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EUHealthSystemIntegration _$EUHealthSystemIntegrationFromJson(
  Map<String, dynamic> json,
) => EUHealthSystemIntegration(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  ePrescription: (json['ePrescription'] as List<dynamic>)
      .map((e) => EUPrescriptionIntegration.fromJson(e as Map<String, dynamic>))
      .toList(),
  snomedMappings: (json['snomedMappings'] as List<dynamic>)
      .map((e) => SNOMEDMapping.fromJson(e as Map<String, dynamic>))
      .toList(),
  complianceRequirements: (json['complianceRequirements'] as List<dynamic>)
      .map((e) => EUComplianceRequirement.fromJson(e as Map<String, dynamic>))
      .toList(),
  reportingRequirements: (json['reportingRequirements'] as List<dynamic>)
      .map((e) => EUReportingRequirement.fromJson(e as Map<String, dynamic>))
      .toList(),
  configuration: json['configuration'] as Map<String, dynamic>,
);

Map<String, dynamic> _$EUHealthSystemIntegrationToJson(
  EUHealthSystemIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'ePrescription': instance.ePrescription,
  'snomedMappings': instance.snomedMappings,
  'complianceRequirements': instance.complianceRequirements,
  'reportingRequirements': instance.reportingRequirements,
  'configuration': instance.configuration,
};

EUPrescriptionIntegration _$EUPrescriptionIntegrationFromJson(
  Map<String, dynamic> json,
) => EUPrescriptionIntegration(
  id: json['id'] as String,
  country: json['country'] as String,
  isActive: json['isActive'] as bool,
  lastSync: DateTime.parse(json['lastSync'] as String),
  standard: json['standard'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$EUPrescriptionIntegrationToJson(
  EUPrescriptionIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'country': instance.country,
  'isActive': instance.isActive,
  'lastSync': instance.lastSync.toIso8601String(),
  'standard': instance.standard,
  'metadata': instance.metadata,
};

SNOMEDMapping _$SNOMEDMappingFromJson(Map<String, dynamic> json) =>
    SNOMEDMapping(
      id: json['id'] as String,
      snomedCode: json['snomedCode'] as String,
      icd10Code: json['icd10Code'] as String,
      display: json['display'] as String,
      locale: json['locale'] as String,
    );

Map<String, dynamic> _$SNOMEDMappingToJson(SNOMEDMapping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'snomedCode': instance.snomedCode,
      'icd10Code': instance.icd10Code,
      'display': instance.display,
      'locale': instance.locale,
    };

EUComplianceRequirement _$EUComplianceRequirementFromJson(
  Map<String, dynamic> json,
) => EUComplianceRequirement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  regulation: json['regulation'] as String,
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  status: json['status'] as String,
  controls: (json['controls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$EUComplianceRequirementToJson(
  EUComplianceRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'regulation': instance.regulation,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'status': instance.status,
  'controls': instance.controls,
};

EUReportingRequirement _$EUReportingRequirementFromJson(
  Map<String, dynamic> json,
) => EUReportingRequirement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  authority: json['authority'] as String,
  frequency: json['frequency'] as String,
  nextDueDate: DateTime.parse(json['nextDueDate'] as String),
);

Map<String, dynamic> _$EUReportingRequirementToJson(
  EUReportingRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'authority': instance.authority,
  'frequency': instance.frequency,
  'nextDueDate': instance.nextDueDate.toIso8601String(),
};
