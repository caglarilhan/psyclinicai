import 'package:json_annotation/json_annotation.dart';

part 'hipaa_compliance_models.g.dart';

@JsonSerializable()
class HIPAACompliance {
  final String id;
  final String organizationId;
  final DateTime lastAuditDate;
  final DateTime nextAuditDate;
  final ComplianceStatus status;
  final List<ComplianceRequirement> requirements;
  final List<AuditLog> auditLogs;
  final List<SecurityIncident> securityIncidents;
  final PrivacyOfficer privacyOfficer;
  final SecurityOfficer securityOfficer;

  const HIPAACompliance({
    required this.id,
    required this.organizationId,
    required this.lastAuditDate,
    required this.nextAuditDate,
    required this.status,
    required this.requirements,
    required this.auditLogs,
    required this.securityIncidents,
    required this.privacyOfficer,
    required this.securityOfficer,
  });

  factory HIPAACompliance.fromJson(Map<String, dynamic> json) =>
      _$HIPAAComplianceFromJson(json);

  Map<String, dynamic> toJson() => _$HIPAAComplianceToJson(this);

  bool get isCompliant => status == ComplianceStatus.compliant;
  bool get needsAudit => DateTime.now().isAfter(nextAuditDate);
}

@JsonSerializable()
class ComplianceRequirement {
  final String id;
  final String title;
  final String description;
  final RequirementCategory category;
  final ComplianceStatus status;
  final DateTime dueDate;
  final String assignedTo;
  final List<String> evidence;
  final String notes;

  const ComplianceRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.dueDate,
    required this.assignedTo,
    required this.evidence,
    required this.notes,
  });

  factory ComplianceRequirement.fromJson(Map<String, dynamic> json) =>
      _$ComplianceRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceRequirementToJson(this);
}

@JsonSerializable()
class AuditLog {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String action;
  final String resource;
  final String details;
  final String ipAddress;
  final String userAgent;
  final AuditLogLevel level;

  const AuditLog({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.action,
    required this.resource,
    required this.details,
    required this.ipAddress,
    required this.userAgent,
    required this.level,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);

  Map<String, dynamic> toJson() => _$AuditLogToJson(this);
}

@JsonSerializable()
class SecurityIncident {
  final String id;
  final DateTime reportedDate;
  final IncidentType type;
  final IncidentSeverity severity;
  final String description;
  final String reportedBy;
  final IncidentStatus status;
  final List<String> affectedPatients;
  final String containmentActions;
  final String resolution;
  final DateTime resolvedDate;

  const SecurityIncident({
    required this.id,
    required this.reportedDate,
    required this.type,
    required this.severity,
    required this.description,
    required this.reportedBy,
    required this.status,
    required this.affectedPatients,
    required this.containmentActions,
    required this.resolution,
    required this.resolvedDate,
  });

  factory SecurityIncident.fromJson(Map<String, dynamic> json) =>
      _$SecurityIncidentFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityIncidentToJson(this);
}

@JsonSerializable()
class PrivacyOfficer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String title;
  final DateTime appointmentDate;
  final List<String> certifications;
  final String responsibilities;

  const PrivacyOfficer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.title,
    required this.appointmentDate,
    required this.certifications,
    required this.responsibilities,
  });

  factory PrivacyOfficer.fromJson(Map<String, dynamic> json) =>
      _$PrivacyOfficerFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacyOfficerToJson(this);
}

@JsonSerializable()
class SecurityOfficer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String title;
  final DateTime appointmentDate;
  final List<String> certifications;
  final String responsibilities;

  const SecurityOfficer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.title,
    required this.appointmentDate,
    required this.certifications,
    required this.responsibilities,
  });

  factory SecurityOfficer.fromJson(Map<String, dynamic> json) =>
      _$SecurityOfficerFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityOfficerToJson(this);
}

enum ComplianceStatus {
  compliant,
  nonCompliant,
  partiallyCompliant,
  underReview,
  pending,
}

enum RequirementCategory {
  administrative,
  physical,
  technical,
  organizational,
  documentation,
}

enum AuditLogLevel {
  info,
  warning,
  error,
  critical,
}

enum IncidentType {
  unauthorizedAccess,
  dataBreach,
  malware,
  phishing,
  physicalTheft,
  systemFailure,
  other,
}

enum IncidentSeverity {
  low,
  medium,
  high,
  critical,
}

enum IncidentStatus {
  reported,
  investigating,
  contained,
  resolved,
  closed,
}
