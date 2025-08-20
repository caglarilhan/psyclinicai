// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hipaa_compliance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HIPAACompliance _$HIPAAComplianceFromJson(Map<String, dynamic> json) =>
    HIPAACompliance(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      lastAuditDate: DateTime.parse(json['lastAuditDate'] as String),
      nextAuditDate: DateTime.parse(json['nextAuditDate'] as String),
      status: $enumDecode(_$ComplianceStatusEnumMap, json['status']),
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => ComplianceRequirement.fromJson(e as Map<String, dynamic>))
          .toList(),
      auditLogs: (json['auditLogs'] as List<dynamic>)
          .map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      securityIncidents: (json['securityIncidents'] as List<dynamic>)
          .map((e) => SecurityIncident.fromJson(e as Map<String, dynamic>))
          .toList(),
      privacyOfficer: PrivacyOfficer.fromJson(
        json['privacyOfficer'] as Map<String, dynamic>,
      ),
      securityOfficer: SecurityOfficer.fromJson(
        json['securityOfficer'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$HIPAAComplianceToJson(HIPAACompliance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'lastAuditDate': instance.lastAuditDate.toIso8601String(),
      'nextAuditDate': instance.nextAuditDate.toIso8601String(),
      'status': _$ComplianceStatusEnumMap[instance.status]!,
      'requirements': instance.requirements,
      'auditLogs': instance.auditLogs,
      'securityIncidents': instance.securityIncidents,
      'privacyOfficer': instance.privacyOfficer,
      'securityOfficer': instance.securityOfficer,
    };

const _$ComplianceStatusEnumMap = {
  ComplianceStatus.compliant: 'compliant',
  ComplianceStatus.nonCompliant: 'nonCompliant',
  ComplianceStatus.partiallyCompliant: 'partiallyCompliant',
  ComplianceStatus.underReview: 'underReview',
  ComplianceStatus.pending: 'pending',
};

ComplianceRequirement _$ComplianceRequirementFromJson(
  Map<String, dynamic> json,
) => ComplianceRequirement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$RequirementCategoryEnumMap, json['category']),
  status: $enumDecode(_$ComplianceStatusEnumMap, json['status']),
  dueDate: DateTime.parse(json['dueDate'] as String),
  assignedTo: json['assignedTo'] as String,
  evidence: (json['evidence'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notes: json['notes'] as String,
);

Map<String, dynamic> _$ComplianceRequirementToJson(
  ComplianceRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': _$RequirementCategoryEnumMap[instance.category]!,
  'status': _$ComplianceStatusEnumMap[instance.status]!,
  'dueDate': instance.dueDate.toIso8601String(),
  'assignedTo': instance.assignedTo,
  'evidence': instance.evidence,
  'notes': instance.notes,
};

const _$RequirementCategoryEnumMap = {
  RequirementCategory.administrative: 'administrative',
  RequirementCategory.physical: 'physical',
  RequirementCategory.technical: 'technical',
  RequirementCategory.organizational: 'organizational',
  RequirementCategory.documentation: 'documentation',
};

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => AuditLog(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  userId: json['userId'] as String,
  action: json['action'] as String,
  resource: json['resource'] as String,
  details: json['details'] as String,
  ipAddress: json['ipAddress'] as String,
  userAgent: json['userAgent'] as String,
  level: $enumDecode(_$AuditLogLevelEnumMap, json['level']),
);

Map<String, dynamic> _$AuditLogToJson(AuditLog instance) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'userId': instance.userId,
  'action': instance.action,
  'resource': instance.resource,
  'details': instance.details,
  'ipAddress': instance.ipAddress,
  'userAgent': instance.userAgent,
  'level': _$AuditLogLevelEnumMap[instance.level]!,
};

const _$AuditLogLevelEnumMap = {
  AuditLogLevel.info: 'info',
  AuditLogLevel.warning: 'warning',
  AuditLogLevel.error: 'error',
  AuditLogLevel.critical: 'critical',
};

SecurityIncident _$SecurityIncidentFromJson(Map<String, dynamic> json) =>
    SecurityIncident(
      id: json['id'] as String,
      reportedDate: DateTime.parse(json['reportedDate'] as String),
      type: $enumDecode(_$IncidentTypeEnumMap, json['type']),
      severity: $enumDecode(_$IncidentSeverityEnumMap, json['severity']),
      description: json['description'] as String,
      reportedBy: json['reportedBy'] as String,
      status: $enumDecode(_$IncidentStatusEnumMap, json['status']),
      affectedPatients: (json['affectedPatients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      containmentActions: json['containmentActions'] as String,
      resolution: json['resolution'] as String,
      resolvedDate: DateTime.parse(json['resolvedDate'] as String),
    );

Map<String, dynamic> _$SecurityIncidentToJson(SecurityIncident instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportedDate': instance.reportedDate.toIso8601String(),
      'type': _$IncidentTypeEnumMap[instance.type]!,
      'severity': _$IncidentSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'reportedBy': instance.reportedBy,
      'status': _$IncidentStatusEnumMap[instance.status]!,
      'affectedPatients': instance.affectedPatients,
      'containmentActions': instance.containmentActions,
      'resolution': instance.resolution,
      'resolvedDate': instance.resolvedDate.toIso8601String(),
    };

const _$IncidentTypeEnumMap = {
  IncidentType.unauthorizedAccess: 'unauthorizedAccess',
  IncidentType.dataBreach: 'dataBreach',
  IncidentType.malware: 'malware',
  IncidentType.phishing: 'phishing',
  IncidentType.physicalTheft: 'physicalTheft',
  IncidentType.systemFailure: 'systemFailure',
  IncidentType.other: 'other',
};

const _$IncidentSeverityEnumMap = {
  IncidentSeverity.low: 'low',
  IncidentSeverity.medium: 'medium',
  IncidentSeverity.high: 'high',
  IncidentSeverity.critical: 'critical',
};

const _$IncidentStatusEnumMap = {
  IncidentStatus.reported: 'reported',
  IncidentStatus.investigating: 'investigating',
  IncidentStatus.contained: 'contained',
  IncidentStatus.resolved: 'resolved',
  IncidentStatus.closed: 'closed',
};

PrivacyOfficer _$PrivacyOfficerFromJson(Map<String, dynamic> json) =>
    PrivacyOfficer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      title: json['title'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      certifications: (json['certifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      responsibilities: json['responsibilities'] as String,
    );

Map<String, dynamic> _$PrivacyOfficerToJson(PrivacyOfficer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'title': instance.title,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'certifications': instance.certifications,
      'responsibilities': instance.responsibilities,
    };

SecurityOfficer _$SecurityOfficerFromJson(Map<String, dynamic> json) =>
    SecurityOfficer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      title: json['title'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      certifications: (json['certifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      responsibilities: json['responsibilities'] as String,
    );

Map<String, dynamic> _$SecurityOfficerToJson(SecurityOfficer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'title': instance.title,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'certifications': instance.certifications,
      'responsibilities': instance.responsibilities,
    };
