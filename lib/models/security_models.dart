import 'package:flutter/material.dart';

// Güvenlik durumu
class SecurityStatus {
  final double overallScore;
  final double encryptionScore;
  final double accessControlScore;
  final double auditScore;
  final DateTime lastUpdated;
  final List<SecurityIssue> issues;

  SecurityStatus({
    required this.overallScore,
    required this.encryptionScore,
    required this.accessControlScore,
    required this.auditScore,
    required this.lastUpdated,
    required this.issues,
  });

  factory SecurityStatus.fromJson(Map<String, dynamic> json) {
    return SecurityStatus(
      overallScore: (json['overallScore'] ?? 0.0).toDouble(),
      encryptionScore: (json['encryptionScore'] ?? 0.0).toDouble(),
      accessControlScore: (json['accessControlScore'] ?? 0.0).toDouble(),
      auditScore: (json['auditScore'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      issues: (json['issues'] as List?)
          ?.map((e) => SecurityIssue.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'encryptionScore': encryptionScore,
      'accessControlScore': accessControlScore,
      'auditScore': auditScore,
      'lastUpdated': lastUpdated.toIso8601String(),
      'issues': issues.map((e) => e.toJson()).toList(),
    };
  }

  // Güvenlik seviyesi
  SecurityLevel get securityLevel {
    if (overallScore >= 90) return SecurityLevel.excellent;
    if (overallScore >= 80) return SecurityLevel.good;
    if (overallScore >= 70) return SecurityLevel.fair;
    if (overallScore >= 60) return SecurityLevel.poor;
    return SecurityLevel.critical;
  }

  // Renk
  Color get securityColor {
    switch (securityLevel) {
      case SecurityLevel.excellent:
        return Colors.green;
      case SecurityLevel.good:
        return Colors.lightGreen;
      case SecurityLevel.fair:
        return Colors.orange;
      case SecurityLevel.poor:
        return Colors.deepOrange;
      case SecurityLevel.critical:
        return Colors.red;
    }
  }
}

// Güvenlik seviyesi enum'u
enum SecurityLevel { excellent, good, fair, poor, critical }

// Güvenlik sorunu
class SecurityIssue {
  final String id;
  final String title;
  final String description;
  final SecurityIssueType type;
  final SecurityIssueSeverity severity;
  final DateTime detectedAt;
  final bool isResolved;
  final String? resolutionNotes;

  SecurityIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.detectedAt,
    required this.isResolved,
    this.resolutionNotes,
  });

  factory SecurityIssue.fromJson(Map<String, dynamic> json) {
    return SecurityIssue(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: SecurityIssueType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SecurityIssueType.general,
      ),
      severity: SecurityIssueSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SecurityIssueSeverity.low,
      ),
      detectedAt: DateTime.parse(json['detectedAt'] ?? DateTime.now().toIso8601String()),
      isResolved: json['isResolved'] ?? false,
      resolutionNotes: json['resolutionNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'detectedAt': detectedAt.toIso8601String(),
      'isResolved': isResolved,
      'resolutionNotes': resolutionNotes,
    };
  }

  // Renk
  Color get severityColor {
    switch (severity) {
      case SecurityIssueSeverity.low:
        return Colors.blue;
      case SecurityIssueSeverity.medium:
        return Colors.orange;
      case SecurityIssueSeverity.high:
        return Colors.red;
      case SecurityIssueSeverity.critical:
        return Colors.purple;
    }
  }
}

// Güvenlik sorunu türü enum'u
enum SecurityIssueType { encryption, access, audit, network, general }

// Güvenlik sorunu şiddeti enum'u
enum SecurityIssueSeverity { low, medium, high, critical }

// Uyumluluk raporu
class ComplianceReport {
  final String id;
  final String complianceType;
  final ComplianceStatus status;
  final DateTime lastChecked;
  final DateTime nextCheck;
  final String notes;
  final List<ComplianceRequirement> requirements;

  ComplianceReport({
    required this.id,
    required this.complianceType,
    required this.status,
    required this.lastChecked,
    required this.nextCheck,
    required this.notes,
    required this.requirements,
  });

  factory ComplianceReport.fromJson(Map<String, dynamic> json) {
    return ComplianceReport(
      id: json['id'] ?? '',
      complianceType: json['complianceType'] ?? '',
      status: ComplianceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ComplianceStatus.unknown,
      ),
      lastChecked: DateTime.parse(json['lastChecked'] ?? DateTime.now().toIso8601String()),
      nextCheck: DateTime.parse(json['nextCheck'] ?? DateTime.now().add(Duration(days: 30)).toIso8601String()),
      notes: json['notes'] ?? '',
      requirements: (json['requirements'] as List?)
          ?.map((e) => ComplianceRequirement.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complianceType': complianceType,
      'status': status.name,
      'lastChecked': lastChecked.toIso8601String(),
      'nextCheck': nextCheck.toIso8601String(),
      'notes': notes,
      'requirements': requirements.map((e) => e.toJson()).toList(),
    };
  }

  // Uyumluluk yüzdesi
  double get compliancePercentage {
    if (requirements.isEmpty) return 0.0;
    final compliantCount = requirements.where((r) => r.isCompliant).length;
    return (compliantCount / requirements.length) * 100;
  }
}

// Uyumluluk durumu enum'u
enum ComplianceStatus { compliant, warning, nonCompliant, unknown }

// Uyumluluk gereksinimi
class ComplianceRequirement {
  final String id;
  final String title;
  final String description;
  final bool isCompliant;
  final String? notes;
  final DateTime lastChecked;

  ComplianceRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompliant,
    this.notes,
    required this.lastChecked,
  });

  factory ComplianceRequirement.fromJson(Map<String, dynamic> json) {
    return ComplianceRequirement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompliant: json['isCompliant'] ?? false,
      notes: json['notes'],
      lastChecked: DateTime.parse(json['lastChecked'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompliant': isCompliant,
      'notes': notes,
      'lastChecked': lastChecked.toIso8601String(),
    };
  }
}

// Denetim kaydı
class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final AuditLogType type;
  final DateTime timestamp;
  final String? resourceId;
  final String? resourceType;
  final Map<String, dynamic>? metadata;
  final String? ipAddress;
  final String? userAgent;

  AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.type,
    required this.timestamp,
    this.resourceId,
    this.resourceType,
    this.metadata,
    this.ipAddress,
    this.userAgent,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      action: json['action'] ?? '',
      type: AuditLogType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AuditLogType.general,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      resourceId: json['resourceId'],
      resourceType: json['resourceType'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'action': action,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'resourceId': resourceId,
      'resourceType': resourceType,
      'metadata': metadata,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }

  // Zaman farkı
  Duration get timeAgo => DateTime.now().difference(timestamp);

  // Zaman farkı metni
  String get timeAgoText {
    final days = timeAgo.inDays;
    final hours = timeAgo.inHours;
    final minutes = timeAgo.inMinutes;

    if (days > 0) return '$days gün önce';
    if (hours > 0) return '$hours saat önce';
    if (minutes > 0) return '$minutes dakika önce';
    return 'Az önce';
  }
}

// Denetim kaydı türü enum'u
enum AuditLogType { login, logout, dataAccess, dataModification, security, general }

// Şifreleme durumu
class EncryptionStatus {
  final String algorithm;
  final int keySize;
  final String mode;
  final bool isActive;
  final DateTime lastKeyRotation;
  final List<String> supportedAlgorithms;

  EncryptionStatus({
    required this.algorithm,
    required this.keySize,
    required this.mode,
    required this.isActive,
    required this.lastKeyRotation,
    required this.supportedAlgorithms,
  });

  factory EncryptionStatus.fromJson(Map<String, dynamic> json) {
    return EncryptionStatus(
      algorithm: json['algorithm'] ?? '',
      keySize: json['keySize'] ?? 0,
      mode: json['mode'] ?? '',
      isActive: json['isActive'] ?? false,
      lastKeyRotation: DateTime.parse(json['lastKeyRotation'] ?? DateTime.now().toIso8601String()),
      supportedAlgorithms: (json['supportedAlgorithms'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'algorithm': algorithm,
      'keySize': keySize,
      'mode': mode,
      'isActive': isActive,
      'lastKeyRotation': lastKeyRotation.toIso8601String(),
      'supportedAlgorithms': supportedAlgorithms,
    };
  }

  // Güçlü şifreleme mi
  bool get isStrongEncryption => keySize >= 256 && algorithm.contains('AES');
}

// Erişim kontrol durumu
class AccessControlStatus {
  final bool roleBasedAccess;
  final bool multiFactorAuth;
  final bool sessionManagement;
  final bool ipRestriction;
  final List<String> activeRoles;
  final List<String> restrictedIPs;
  final int maxSessionDuration;

  AccessControlStatus({
    required this.roleBasedAccess,
    required this.multiFactorAuth,
    required this.sessionManagement,
    required this.ipRestriction,
    required this.activeRoles,
    required this.restrictedIPs,
    required this.maxSessionDuration,
  });

  factory AccessControlStatus.fromJson(Map<String, dynamic> json) {
    return AccessControlStatus(
      roleBasedAccess: json['roleBasedAccess'] ?? false,
      multiFactorAuth: json['multiFactorAuth'] ?? false,
      sessionManagement: json['sessionManagement'] ?? false,
      ipRestriction: json['ipRestriction'] ?? false,
      activeRoles: (json['activeRoles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      restrictedIPs: (json['restrictedIPs'] as List?)?.map((e) => e.toString()).toList() ?? [],
      maxSessionDuration: json['maxSessionDuration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleBasedAccess': roleBasedAccess,
      'multiFactorAuth': multiFactorAuth,
      'sessionManagement': sessionManagement,
      'ipRestriction': ipRestriction,
      'activeRoles': activeRoles,
      'restrictedIPs': restrictedIPs,
      'maxSessionDuration': maxSessionDuration,
    };
  }

  // Güvenlik skoru
  double get securityScore {
    double score = 0;
    if (roleBasedAccess) score += 25;
    if (multiFactorAuth) score += 25;
    if (sessionManagement) score += 25;
    if (ipRestriction) score += 25;
    return score;
  }
}

// Güvenlik olayı
class SecurityEvent {
  final String id;
  final String title;
  final String description;
  final SecurityEventType type;
  final SecurityEventSeverity severity;
  final DateTime occurredAt;
  final String? userId;
  final String? userName;
  final String? ipAddress;
  final Map<String, dynamic>? details;
  final bool isResolved;
  final String? resolutionNotes;

  SecurityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.occurredAt,
    this.userId,
    this.userName,
    this.ipAddress,
    this.details,
    required this.isResolved,
    this.resolutionNotes,
  });

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: SecurityEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SecurityEventType.general,
      ),
      severity: SecurityEventSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SecurityEventSeverity.low,
      ),
      occurredAt: DateTime.parse(json['occurredAt'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'],
      userName: json['userName'],
      ipAddress: json['ipAddress'],
      details: json['details'] != null ? Map<String, dynamic>.from(json['details']) : null,
      isResolved: json['isResolved'] ?? false,
      resolutionNotes: json['resolutionNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'occurredAt': occurredAt.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'ipAddress': ipAddress,
      'details': details,
      'isResolved': isResolved,
      'resolutionNotes': resolutionNotes,
    };
  }

  // Renk
  Color get severityColor {
    switch (severity) {
      case SecurityEventSeverity.low:
        return Colors.blue;
      case SecurityEventSeverity.medium:
        return Colors.orange;
      case SecurityEventSeverity.high:
        return Colors.red;
      case SecurityEventSeverity.critical:
        return Colors.purple;
    }
  }
}

// Güvenlik olayı türü enum'u
enum SecurityEventType { intrusion, dataBreach, unauthorizedAccess, malware, general }

// Güvenlik olayı şiddeti enum'u
enum SecurityEventSeverity { low, medium, high, critical }

// Yasal Uyumluluk Çerçeveleri
enum ComplianceFramework {
  hipaa,    // ABD
  gdpr,     // Avrupa
  kvkk,     // Türkiye
  pipeda,   // Kanada
  sox,      // ABD finansal
  iso27001, // Uluslararası
}

// Veri Saklama Politikası
class DataRetentionPolicy {
  final String id;
  final String name;
  final String description;
  final Duration retentionPeriod;
  final List<String> dataTypes;
  final bool autoDelete;
  final DateTime? lastReview;
  final String? reviewedBy;

  const DataRetentionPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.retentionPeriod,
    required this.dataTypes,
    required this.autoDelete,
    this.lastReview,
    this.reviewedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'retentionPeriod': retentionPeriod.inDays,
      'dataTypes': dataTypes,
      'autoDelete': autoDelete,
      'lastReview': lastReview?.toIso8601String(),
      'reviewedBy': reviewedBy,
    };
  }

  factory DataRetentionPolicy.fromJson(Map<String, dynamic> json) {
    return DataRetentionPolicy(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      retentionPeriod: Duration(days: json['retentionPeriod'] as int),
      dataTypes: List<String>.from(json['dataTypes'] as List),
      autoDelete: json['autoDelete'] as bool,
      lastReview: json['lastReview'] != null 
          ? DateTime.parse(json['lastReview'] as String) 
          : null,
      reviewedBy: json['reviewedBy'] as String?,
    );
  }
}

// Şifreleme Konfigürasyonu
class EncryptionConfig {
  final String algorithm;
  final int keySize;
  final String keyRotationPeriod;
  final bool hardwareAcceleration;
  final List<String> supportedAlgorithms;
  final DateTime lastKeyRotation;
  final DateTime nextKeyRotation;

  const EncryptionConfig({
    required this.algorithm,
    required this.keySize,
    required this.keyRotationPeriod,
    required this.hardwareAcceleration,
    required this.supportedAlgorithms,
    required this.lastKeyRotation,
    required this.nextKeyRotation,
  });

  Map<String, dynamic> toJson() {
    return {
      'algorithm': algorithm,
      'keySize': keySize,
      'keyRotationPeriod': keyRotationPeriod,
      'hardwareAcceleration': hardwareAcceleration,
      'supportedAlgorithms': supportedAlgorithms,
      'lastKeyRotation': lastKeyRotation.toIso8601String(),
      'nextKeyRotation': nextKeyRotation.toIso8601String(),
    };
  }

  factory EncryptionConfig.fromJson(Map<String, dynamic> json) {
    return EncryptionConfig(
      algorithm: json['algorithm'] as String,
      keySize: json['keySize'] as int,
      keyRotationPeriod: json['keyRotationPeriod'] as String,
      hardwareAcceleration: json['hardwareAcceleration'] as bool,
      supportedAlgorithms: List<String>.from(json['supportedAlgorithms'] as List),
      lastKeyRotation: DateTime.parse(json['lastKeyRotation'] as String),
      nextKeyRotation: DateTime.parse(json['nextKeyRotation'] as String),
    );
  }
}

// Erişim Kontrol Politikası
class AccessControlPolicy {
  final String id;
  final String name;
  final String description;
  final List<String> roles;
  final List<String> resources;
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastModified;
  final String? createdBy;

  const AccessControlPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.roles,
    required this.resources,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.lastModified,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'roles': roles,
      'resources': resources,
      'permissions': permissions,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory AccessControlPolicy.fromJson(Map<String, dynamic> json) {
    return AccessControlPolicy(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      roles: List<String>.from(json['roles'] as List),
      resources: List<String>.from(json['resources'] as List),
      permissions: List<String>.from(json['permissions'] as List),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: json['lastModified'] != null 
          ? DateTime.parse(json['lastModified'] as String) 
          : null,
      createdBy: json['createdBy'] as String?,
    );
  }
}

// Veri Anonimleştirme
class DataAnonymizationRule {
  final String id;
  final String fieldName;
  final AnonymizationType type;
  final String? replacementValue;
  final bool isActive;
  final DateTime createdAt;

  const DataAnonymizationRule({
    required this.id,
    required this.fieldName,
    required this.type,
    this.replacementValue,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldName': fieldName,
      'type': type.name,
      'replacementValue': replacementValue,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DataAnonymizationRule.fromJson(Map<String, dynamic> json) {
    return DataAnonymizationRule(
      id: json['id'] as String,
      fieldName: json['fieldName'] as String,
      type: AnonymizationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnonymizationType.mask,
      ),
      replacementValue: json['replacementValue'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

enum AnonymizationType {
  mask,      // Son 4 karakteri göster
  hash,      // Hash'le
  replace,   // Belirli değerle değiştir
  remove,    // Tamamen kaldır
  randomize, // Rastgele değer ata
}

// Güvenlik Olayı
class SecurityIncident {
  final String id;
  final String title;
  final String description;
  final SecurityIncidentType type;
  final SecurityIncidentSeverity severity;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final List<String> affectedUsers;
  final List<String> affectedData;
  final String? resolutionNotes;
  final bool isResolved;

  const SecurityIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.detectedAt,
    this.resolvedAt,
    this.resolvedBy,
    required this.affectedUsers,
    required this.affectedData,
    this.resolutionNotes,
    required this.isResolved,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'detectedAt': detectedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'affectedUsers': affectedUsers,
      'affectedData': affectedData,
      'resolutionNotes': resolutionNotes,
      'isResolved': isResolved,
    };
  }

  factory SecurityIncident.fromJson(Map<String, dynamic> json) {
    return SecurityIncident(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: SecurityIncidentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SecurityIncidentType.unauthorizedAccess,
      ),
      severity: SecurityIncidentSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SecurityIncidentSeverity.low,
      ),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolvedBy: json['resolvedBy'] as String?,
      affectedUsers: List<String>.from(json['affectedUsers'] as List),
      affectedData: List<String>.from(json['affectedData'] as List),
      resolutionNotes: json['resolutionNotes'] as String?,
      isResolved: json['isResolved'] as bool,
    );
  }
}

enum SecurityIncidentType {
  unauthorizedAccess,
  dataBreach,
  malware,
  phishing,
  socialEngineering,
  physicalSecurity,
  networkAttack,
  other,
}

enum SecurityIncidentSeverity {
  low,
  medium,
  high,
  critical,
}
