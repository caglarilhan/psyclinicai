import 'package:json_annotation/json_annotation.dart';

part 'security_models.g.dart';

// ===== GÜVENLİK SEVİYELERİ =====
enum SecurityLevel {
  low,
  medium,
  high,
  critical,
}

// ===== KULLANICI ROLLERİ =====
enum UserRole {
  admin,
  therapist,
  supervisor,
  client,
  guest,
}

// ===== DENETİM OLAY TİPLERİ =====
enum AuditEventType {
  authentication,
  authorization,
  dataAccess,
  dataModification,
  system,
  security,
  compliance,
}

// ===== GÜVENLİK AÇIĞI TİPLERİ =====
enum VulnerabilityType {
  authentication,
  authorization,
  dataExposure,
  encryption,
  network,
  configuration,
  code,
}

// ===== GÜVENLİK AÇIĞI ŞİDDETİ =====
enum VulnerabilitySeverity {
  low,
  medium,
  high,
  critical,
}

// ===== DENETİM KAYDI =====
@JsonSerializable()
class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final AuditEventType eventType;
  final String eventDescription;
  final DateTime timestamp;
  final String ipAddress;
  final String userAgent;
  final Map<String, dynamic>? metadata;
  final SecurityLevel securityLevel;
  final bool isSuccessful;
  final String? errorMessage;

  const AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.eventType,
    required this.eventDescription,
    required this.timestamp,
    required this.ipAddress,
    required this.userAgent,
    this.metadata,
    required this.securityLevel,
    required this.isSuccessful,
    this.errorMessage,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);
  Map<String, dynamic> toJson() => _$AuditLogToJson(this);
}

// ===== GÜVENLİK AÇIĞI =====
@JsonSerializable()
class SecurityVulnerability {
  final String id;
  final String title;
  final String description;
  final VulnerabilityType type;
  final VulnerabilitySeverity severity;
  final DateTime discoveredAt;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final Map<String, dynamic>? metadata;
  final List<String> affectedComponents;
  final double riskScore; // 0-10 scale

  const SecurityVulnerability({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.discoveredAt,
    this.resolvedAt,
    this.resolutionNotes,
    this.metadata,
    required this.affectedComponents,
    required this.riskScore,
  });

  factory SecurityVulnerability.fromJson(Map<String, dynamic> json) => _$SecurityVulnerabilityFromJson(json);
  Map<String, dynamic> toJson() => _$SecurityVulnerabilityToJson(this);
}

// ===== GÜVENLİK DEĞERLENDİRMESİ =====
@JsonSerializable()
class SecurityAssessment {
  final String id;
  final DateTime assessmentDate;
  final SecurityLevel overallSecurityLevel;
  final double overallScore; // 0-100 scale
  final List<SecurityVulnerability> vulnerabilities;
  final Map<String, double> componentScores;
  final List<String> recommendations;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const SecurityAssessment({
    required this.id,
    required this.assessmentDate,
    required this.overallSecurityLevel,
    required this.overallScore,
    required this.vulnerabilities,
    required this.componentScores,
    required this.recommendations,
    this.notes,
    this.metadata,
  });

  factory SecurityAssessment.fromJson(Map<String, dynamic> json) => _$SecurityAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$SecurityAssessmentToJson(this);
}
