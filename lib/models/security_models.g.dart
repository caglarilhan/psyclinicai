// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => AuditLog(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  eventType: $enumDecode(_$AuditEventTypeEnumMap, json['eventType']),
  eventDescription: json['eventDescription'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  ipAddress: json['ipAddress'] as String,
  userAgent: json['userAgent'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
  securityLevel: $enumDecode(_$SecurityLevelEnumMap, json['securityLevel']),
  isSuccessful: json['isSuccessful'] as bool,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$AuditLogToJson(AuditLog instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'eventType': _$AuditEventTypeEnumMap[instance.eventType]!,
  'eventDescription': instance.eventDescription,
  'timestamp': instance.timestamp.toIso8601String(),
  'ipAddress': instance.ipAddress,
  'userAgent': instance.userAgent,
  'metadata': instance.metadata,
  'securityLevel': _$SecurityLevelEnumMap[instance.securityLevel]!,
  'isSuccessful': instance.isSuccessful,
  'errorMessage': instance.errorMessage,
};

const _$AuditEventTypeEnumMap = {
  AuditEventType.authentication: 'authentication',
  AuditEventType.authorization: 'authorization',
  AuditEventType.dataAccess: 'dataAccess',
  AuditEventType.dataModification: 'dataModification',
  AuditEventType.system: 'system',
  AuditEventType.security: 'security',
  AuditEventType.compliance: 'compliance',
};

const _$SecurityLevelEnumMap = {
  SecurityLevel.low: 'low',
  SecurityLevel.medium: 'medium',
  SecurityLevel.high: 'high',
  SecurityLevel.critical: 'critical',
};

SecurityVulnerability _$SecurityVulnerabilityFromJson(
  Map<String, dynamic> json,
) => SecurityVulnerability(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$VulnerabilityTypeEnumMap, json['type']),
  severity: $enumDecode(_$VulnerabilitySeverityEnumMap, json['severity']),
  discoveredAt: DateTime.parse(json['discoveredAt'] as String),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  resolutionNotes: json['resolutionNotes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  affectedComponents: (json['affectedComponents'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskScore: (json['riskScore'] as num).toDouble(),
);

Map<String, dynamic> _$SecurityVulnerabilityToJson(
  SecurityVulnerability instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$VulnerabilityTypeEnumMap[instance.type]!,
  'severity': _$VulnerabilitySeverityEnumMap[instance.severity]!,
  'discoveredAt': instance.discoveredAt.toIso8601String(),
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'resolutionNotes': instance.resolutionNotes,
  'metadata': instance.metadata,
  'affectedComponents': instance.affectedComponents,
  'riskScore': instance.riskScore,
};

const _$VulnerabilityTypeEnumMap = {
  VulnerabilityType.authentication: 'authentication',
  VulnerabilityType.authorization: 'authorization',
  VulnerabilityType.dataExposure: 'dataExposure',
  VulnerabilityType.encryption: 'encryption',
  VulnerabilityType.network: 'network',
  VulnerabilityType.configuration: 'configuration',
  VulnerabilityType.code: 'code',
};

const _$VulnerabilitySeverityEnumMap = {
  VulnerabilitySeverity.low: 'low',
  VulnerabilitySeverity.medium: 'medium',
  VulnerabilitySeverity.high: 'high',
  VulnerabilitySeverity.critical: 'critical',
};

SecurityAssessment _$SecurityAssessmentFromJson(Map<String, dynamic> json) =>
    SecurityAssessment(
      id: json['id'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      overallSecurityLevel: $enumDecode(
        _$SecurityLevelEnumMap,
        json['overallSecurityLevel'],
      ),
      overallScore: (json['overallScore'] as num).toDouble(),
      vulnerabilities: (json['vulnerabilities'] as List<dynamic>)
          .map((e) => SecurityVulnerability.fromJson(e as Map<String, dynamic>))
          .toList(),
      componentScores: (json['componentScores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SecurityAssessmentToJson(SecurityAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'overallSecurityLevel':
          _$SecurityLevelEnumMap[instance.overallSecurityLevel]!,
      'overallScore': instance.overallScore,
      'vulnerabilities': instance.vulnerabilities,
      'componentScores': instance.componentScores,
      'recommendations': instance.recommendations,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };
