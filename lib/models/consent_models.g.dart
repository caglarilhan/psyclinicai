// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsentRecord _$ConsentRecordFromJson(Map<String, dynamic> json) =>
    ConsentRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      consentType: json['consentType'] as String,
      region: json['region'] as String,
      versionId: json['versionId'] as String,
      consentDate: DateTime.parse(json['consentDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      isActive: json['isActive'] as bool,
      consentText: json['consentText'] as String,
      consentData: json['consentData'] as Map<String, dynamic>,
      purposes: (json['purposes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      method: $enumDecode(_$ConsentMethodEnumMap, json['method']),
      recordedBy: json['recordedBy'] as String,
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
      revokedBy: json['revokedBy'] as String?,
      revocationReason: json['revocationReason'] as String?,
      lastModified: json['lastModified'] == null
          ? null
          : DateTime.parse(json['lastModified'] as String),
      lastModifiedBy: json['lastModifiedBy'] as String?,
      modificationHistory:
          (json['modificationHistory'] as List<dynamic>?)
              ?.map(
                (e) => ConsentModification.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ConsentRecordToJson(ConsentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'consentType': instance.consentType,
      'region': instance.region,
      'versionId': instance.versionId,
      'consentDate': instance.consentDate.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'isActive': instance.isActive,
      'consentText': instance.consentText,
      'consentData': instance.consentData,
      'purposes': instance.purposes,
      'method': _$ConsentMethodEnumMap[instance.method]!,
      'recordedBy': instance.recordedBy,
      'revokedAt': instance.revokedAt?.toIso8601String(),
      'revokedBy': instance.revokedBy,
      'revocationReason': instance.revocationReason,
      'lastModified': instance.lastModified?.toIso8601String(),
      'lastModifiedBy': instance.lastModifiedBy,
      'modificationHistory': instance.modificationHistory,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

const _$ConsentMethodEnumMap = {
  ConsentMethod.written: 'written',
  ConsentMethod.electronic: 'electronic',
  ConsentMethod.verbal: 'verbal',
  ConsentMethod.implied: 'implied',
  ConsentMethod.optOut: 'optOut',
  ConsentMethod.digitalSignature: 'digitalSignature',
  ConsentMethod.biometric: 'biometric',
  ConsentMethod.twoFactor: 'twoFactor',
};

ConsentVersion _$ConsentVersionFromJson(Map<String, dynamic> json) =>
    ConsentVersion(
      id: json['id'] as String,
      templateId: json['templateId'] as String,
      versionNumber: json['versionNumber'] as String,
      content: json['content'] as String,
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      isActive: json['isActive'] as bool,
      deprecatedDate: json['deprecatedDate'] == null
          ? null
          : DateTime.parse(json['deprecatedDate'] as String),
      deprecatedReason: json['deprecatedReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ConsentVersionToJson(ConsentVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateId': instance.templateId,
      'versionNumber': instance.versionNumber,
      'content': instance.content,
      'effectiveDate': instance.effectiveDate.toIso8601String(),
      'isActive': instance.isActive,
      'deprecatedDate': instance.deprecatedDate?.toIso8601String(),
      'deprecatedReason': instance.deprecatedReason,
      'metadata': instance.metadata,
    };

ConsentTemplate _$ConsentTemplateFromJson(Map<String, dynamic> json) =>
    ConsentTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      version: json['version'] as String,
      content: json['content'] as String,
      requiredFields: (json['requiredFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      legalBasis: json['legalBasis'] as String,
      retentionPeriod: json['retentionPeriod'] as String,
      isActive: json['isActive'] as bool,
      effectiveDate: json['effectiveDate'] == null
          ? null
          : DateTime.parse(json['effectiveDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ConsentTemplateToJson(ConsentTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'region': instance.region,
      'version': instance.version,
      'content': instance.content,
      'requiredFields': instance.requiredFields,
      'legalBasis': instance.legalBasis,
      'retentionPeriod': instance.retentionPeriod,
      'isActive': instance.isActive,
      'effectiveDate': instance.effectiveDate?.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'metadata': instance.metadata,
    };

ConsentModification _$ConsentModificationFromJson(Map<String, dynamic> json) =>
    ConsentModification(
      id: json['id'] as String,
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      modifiedBy: json['modifiedBy'] as String,
      reason: json['reason'] as String,
      changes: json['changes'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ConsentModificationToJson(
  ConsentModification instance,
) => <String, dynamic>{
  'id': instance.id,
  'modifiedAt': instance.modifiedAt.toIso8601String(),
  'modifiedBy': instance.modifiedBy,
  'reason': instance.reason,
  'changes': instance.changes,
  'notes': instance.notes,
  'metadata': instance.metadata,
};

ConsentComplianceReport _$ConsentComplianceReportFromJson(
  Map<String, dynamic> json,
) => ConsentComplianceReport(
  id: json['id'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  region: json['region'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  totalConsents: (json['totalConsents'] as num).toInt(),
  activeConsents: (json['activeConsents'] as num).toInt(),
  expiredConsents: (json['expiredConsents'] as num).toInt(),
  revokedConsents: (json['revokedConsents'] as num).toInt(),
  complianceRate: (json['complianceRate'] as num).toDouble(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ConsentComplianceReportToJson(
  ConsentComplianceReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'region': instance.region,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'totalConsents': instance.totalConsents,
  'activeConsents': instance.activeConsents,
  'expiredConsents': instance.expiredConsents,
  'revokedConsents': instance.revokedConsents,
  'complianceRate': instance.complianceRate,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
