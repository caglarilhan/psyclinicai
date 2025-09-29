import 'package:flutter/foundation.dart';

// Güvenlik durumu
enum SecurityStatus {
  secure,
  warning,
  critical,
}

// Güvenlik sorunu türü
enum SecurityIssueType {
  access,
  encryption,
  audit,
  compliance,
  network,
}

// Güvenlik sorunu şiddeti
enum SecurityIssueSeverity {
  low,
  medium,
  high,
  critical,
}

// Güvenlik sorunu
class SecurityIssue {
  final String id;
  final String title;
  final String description;
  final SecurityIssueType type;
  final SecurityIssueSeverity severity;
  final DateTime detectedAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolutionNotes;

  const SecurityIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.detectedAt,
    required this.isResolved,
    this.resolvedAt,
    this.resolutionNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'detectedAt': detectedAt.toIso8601String(),
      'isResolved': isResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionNotes': resolutionNotes,
    };
  }

  factory SecurityIssue.fromJson(Map<String, dynamic> json) {
    return SecurityIssue(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: SecurityIssueType.values.firstWhere((e) => e.name == json['type']),
      severity: SecurityIssueSeverity.values.firstWhere((e) => e.name == json['severity']),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      isResolved: json['isResolved'] as bool,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolutionNotes: json['resolutionNotes'] as String?,
    );
  }
}

// Güvenlik durumu detayları
class SecurityStatusDetails {
  final double overallScore;
  final double encryptionScore;
  final double accessControlScore;
  final double auditScore;
  final DateTime lastUpdated;
  final List<SecurityIssue> issues;

  const SecurityStatusDetails({
    required this.overallScore,
    required this.encryptionScore,
    required this.accessControlScore,
    required this.auditScore,
    required this.lastUpdated,
    required this.issues,
  });

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

  factory SecurityStatusDetails.fromJson(Map<String, dynamic> json) {
    return SecurityStatusDetails(
      overallScore: (json['overallScore'] as num).toDouble(),
      encryptionScore: (json['encryptionScore'] as num).toDouble(),
      accessControlScore: (json['accessControlScore'] as num).toDouble(),
      auditScore: (json['auditScore'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      issues: (json['issues'] as List).map((e) => SecurityIssue.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// Güvenlik olayı şiddeti enum'u
enum SecurityEventSeverity { low, medium, high, critical }

// Güvenlik olayı türü
enum SecurityIncidentType {
  unauthorizedAccess,
  dataBreach,
  malware,
  phishing,
  socialEngineering,
  other,
  configurationError,
  networkAttack,
  insiderThreat,
  physicalSecurity,
}

// Güvenlik olayı şiddeti
enum SecurityIncidentSeverity {
  low,
  medium,
  high,
  critical,
}

// Anonimleştirme türü
enum AnonymizationType {
  mask,
  hash,
  replace,
  remove,
  randomize,
}

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
  final String createdBy;
  final DateTime? lastModified;

  const AccessControlPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.roles,
    required this.resources,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
    this.lastModified,
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
      'createdBy': createdBy,
      'lastModified': lastModified?.toIso8601String(),
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
      createdBy: json['createdBy'] as String,
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
    );
  }
}

// Veri Anonimleştirme Kuralı
class DataAnonymizationRule {
  final String id;
  final String fieldName;
  final AnonymizationType type;
  final bool isActive;
  final DateTime createdAt;
  final String? replacementValue;

  const DataAnonymizationRule({
    required this.id,
    required this.fieldName,
    required this.type,
    required this.isActive,
    required this.createdAt,
    this.replacementValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldName': fieldName,
      'type': type.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'replacementValue': replacementValue,
    };
  }

  factory DataAnonymizationRule.fromJson(Map<String, dynamic> json) {
    return DataAnonymizationRule(
      id: json['id'] as String,
      fieldName: json['fieldName'] as String,
      type: AnonymizationType.values.firstWhere((e) => e.name == json['type']),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      replacementValue: json['replacementValue'] as String?,
    );
  }
}

// Güvenlik Olayı
class SecurityIncident {
  final String id;
  final String title;
  final String description;
  final SecurityIncidentType type;
  final SecurityIncidentSeverity severity;
  final DateTime detectedAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final List<String> affectedUsers;

  const SecurityIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.detectedAt,
    required this.isResolved,
    this.resolvedAt,
    this.resolutionNotes,
    this.affectedUsers = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'detectedAt': detectedAt.toIso8601String(),
      'isResolved': isResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionNotes': resolutionNotes,
      'affectedUsers': affectedUsers,
    };
  }

  factory SecurityIncident.fromJson(Map<String, dynamic> json) {
    return SecurityIncident(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: SecurityIncidentType.values.firstWhere((e) => e.name == json['type']),
      severity: SecurityIncidentSeverity.values.firstWhere((e) => e.name == json['severity']),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      isResolved: json['isResolved'] as bool,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolutionNotes: json['resolutionNotes'] as String?,
      affectedUsers: (json['affectedUsers'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

// Enhanced Security Models

// Enhanced Compliance Framework Model
class EnhancedComplianceFramework {
  final String id;
  final String name;
  final String region;
  final String description;
  final List<String> requirements;
  final Map<String, dynamic> configurations;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnhancedComplianceFramework({
    required this.id,
    required this.name,
    required this.region,
    required this.description,
    required this.requirements,
    required this.configurations,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'description': description,
      'requirements': requirements,
      'configurations': configurations,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EnhancedComplianceFramework.fromJson(Map<String, dynamic> json) {
    return EnhancedComplianceFramework(
      id: json['id'],
      name: json['name'],
      region: json['region'],
      description: json['description'],
      requirements: List<String>.from(json['requirements']),
      configurations: Map<String, dynamic>.from(json['configurations']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

// Enhanced Data Retention Policy Model
class EnhancedDataRetentionPolicy {
  final String id;
  final String name;
  final String description;
  final Map<String, int> retentionPeriods; // days
  final List<String> dataTypes;
  final String deletionMethod;
  final bool requiresApproval;
  final List<String> approvers;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnhancedDataRetentionPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.retentionPeriods,
    required this.dataTypes,
    required this.deletionMethod,
    this.requiresApproval = false,
    this.approvers = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'retentionPeriods': retentionPeriods,
      'dataTypes': dataTypes,
      'deletionMethod': deletionMethod,
      'requiresApproval': requiresApproval,
      'approvers': approvers,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EnhancedDataRetentionPolicy.fromJson(Map<String, dynamic> json) {
    return EnhancedDataRetentionPolicy(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      retentionPeriods: Map<String, int>.from(json['retentionPeriods']),
      dataTypes: List<String>.from(json['dataTypes']),
      deletionMethod: json['deletionMethod'],
      requiresApproval: json['requiresApproval'] ?? false,
      approvers: List<String>.from(json['approvers'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

// Enhanced Encryption Configuration Model
class EnhancedEncryptionConfig {
  final String id;
  final String name;
  final String algorithm;
  final int keySize;
  final String keyManagement;
  final bool isHardwareAccelerated;
  final Map<String, dynamic> settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnhancedEncryptionConfig({
    required this.id,
    required this.name,
    required this.algorithm,
    required this.keySize,
    required this.keyManagement,
    this.isHardwareAccelerated = false,
    required this.settings,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'algorithm': algorithm,
      'keySize': keySize,
      'keyManagement': keyManagement,
      'isHardwareAccelerated': isHardwareAccelerated,
      'settings': settings,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EnhancedEncryptionConfig.fromJson(Map<String, dynamic> json) {
    return EnhancedEncryptionConfig(
      id: json['id'],
      name: json['name'],
      algorithm: json['algorithm'],
      keySize: json['keySize'],
      keyManagement: json['keyManagement'],
      isHardwareAccelerated: json['isHardwareAccelerated'] ?? false,
      settings: Map<String, dynamic>.from(json['settings']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

// Enhanced Access Control Policy Model
class EnhancedAccessControlPolicy {
  final String id;
  final String name;
  final String description;
  final List<String> roles;
  final List<String> permissions;
  final Map<String, List<String>> resourceAccess;
  final String enforcementLevel;
  final bool requiresMFA;
  final List<String> allowedIPs;
  final List<String> allowedDevices;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnhancedAccessControlPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.roles,
    required this.permissions,
    required this.resourceAccess,
    required this.enforcementLevel,
    this.requiresMFA = false,
    this.allowedIPs = const [],
    this.allowedDevices = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'roles': roles,
      'permissions': permissions,
      'resourceAccess': resourceAccess,
      'enforcementLevel': enforcementLevel,
      'requiresMFA': requiresMFA,
      'allowedIPs': allowedIPs,
      'allowedDevices': allowedDevices,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EnhancedAccessControlPolicy.fromJson(Map<String, dynamic> json) {
    return EnhancedAccessControlPolicy(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      roles: List<String>.from(json['roles']),
      permissions: List<String>.from(json['permissions']),
      resourceAccess: Map<String, List<String>>.from(
        json['resourceAccess'].map((key, value) => MapEntry(key, List<String>.from(value))),
      ),
      enforcementLevel: json['enforcementLevel'],
      requiresMFA: json['requiresMFA'] ?? false,
      allowedIPs: List<String>.from(json['allowedIPs'] ?? []),
      allowedDevices: List<String>.from(json['allowedDevices'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

// Enhanced Data Anonymization Rule Model
class EnhancedDataAnonymizationRule {
  final String id;
  final String name;
  final String description;
  final List<String> dataFields;
  final String anonymizationMethod;
  final Map<String, dynamic> parameters;
  final bool isReversible;
  final String retentionKey;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnhancedDataAnonymizationRule({
    required this.id,
    required this.name,
    required this.description,
    required this.dataFields,
    required this.anonymizationMethod,
    required this.parameters,
    this.isReversible = false,
    this.retentionKey = '',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dataFields': dataFields,
      'anonymizationMethod': anonymizationMethod,
      'parameters': parameters,
      'isReversible': isReversible,
      'retentionKey': retentionKey,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EnhancedDataAnonymizationRule.fromJson(Map<String, dynamic> json) {
    return EnhancedDataAnonymizationRule(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dataFields: List<String>.from(json['dataFields']),
      anonymizationMethod: json['anonymizationMethod'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      isReversible: json['isReversible'] ?? false,
      retentionKey: json['retentionKey'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

// Enhanced Security Incident Model
class EnhancedSecurityIncident {
  final String id;
  final String title;
  final String description;
  final String severity;
  final String status;
  final String category;
  final String reportedBy;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final List<String> affectedUsers;
  final List<String> affectedSystems;
  final Map<String, dynamic> details;
  final List<String> actions;
  final String assignedTo;
  final List<String> attachments;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnhancedSecurityIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.category,
    required this.reportedBy,
    required this.reportedAt,
    this.resolvedAt,
    this.affectedUsers = const [],
    this.affectedSystems = const [],
    required this.details,
    this.actions = const [],
    this.assignedTo = '',
    this.attachments = const [],
    this.isResolved = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity,
      'status': status,
      'category': category,
      'reportedBy': reportedBy,
      'reportedAt': reportedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'affectedUsers': affectedUsers,
      'affectedSystems': affectedSystems,
      'details': details,
      'actions': actions,
      'assignedTo': assignedTo,
      'attachments': attachments,
      'isResolved': isResolved,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EnhancedSecurityIncident.fromJson(Map<String, dynamic> json) {
    return EnhancedSecurityIncident(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      severity: json['severity'],
      status: json['status'],
      category: json['category'],
      reportedBy: json['reportedBy'],
      reportedAt: DateTime.parse(json['reportedAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      affectedUsers: List<String>.from(json['affectedUsers'] ?? []),
      affectedSystems: List<String>.from(json['affectedSystems'] ?? []),
      details: Map<String, dynamic>.from(json['details']),
      actions: List<String>.from(json['actions'] ?? []),
      assignedTo: json['assignedTo'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      isResolved: json['isResolved'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

// Security Audit Log Model
class SecurityAuditLog {
  final String id;
  final String userId;
  final String action;
  final String resource;
  final String ipAddress;
  final String userAgent;
  final Map<String, dynamic> details;
  final bool isSuccessful;
  final String? errorMessage;
  final DateTime timestamp;
  final String sessionId;

  SecurityAuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.resource,
    required this.ipAddress,
    required this.userAgent,
    required this.details,
    required this.isSuccessful,
    this.errorMessage,
    required this.timestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'action': action,
      'resource': resource,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'details': details,
      'isSuccessful': isSuccessful,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
    };
  }

  factory SecurityAuditLog.fromJson(Map<String, dynamic> json) {
    return SecurityAuditLog(
      id: json['id'],
      userId: json['userId'],
      action: json['action'],
      resource: json['resource'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      details: Map<String, dynamic>.from(json['details']),
      isSuccessful: json['isSuccessful'],
      errorMessage: json['errorMessage'],
      timestamp: DateTime.parse(json['timestamp']),
      sessionId: json['sessionId'],
    );
  }
}

// Denetim kaydı türü
enum AuditLogType {
  login,
  logout,
  dataAccess,
  dataModification,
  security,
  compliance,
}

// Denetim kaydı
class AuditLog {
  final String id;
  final String userId;
  final String action;
  final String resource;
  final AuditLogType type;
  final DateTime timestamp;
  final String? details;
  final String? ipAddress;
  final String? userAgent;

  const AuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.resource,
    required this.type,
    required this.timestamp,
    this.details,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'action': action,
      'resource': resource,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      resource: json['resource'] as String,
      type: AuditLogType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as String?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
    );
  }
}

// Uyumluluk durumu
enum ComplianceStatus {
  compliant,
  nonCompliant,
  partiallyCompliant,
  underReview,
}

// Uyumluluk gereksinimi
class ComplianceRequirement {
  final String id;
  final String title;
  final String description;
  final ComplianceFramework framework;
  final ComplianceStatus status;
  final DateTime? lastChecked;
  final String? notes;

  const ComplianceRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.framework,
    required this.status,
    this.lastChecked,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'framework': framework.name,
      'status': status.name,
      'lastChecked': lastChecked?.toIso8601String(),
      'notes': notes,
    };
  }

  factory ComplianceRequirement.fromJson(Map<String, dynamic> json) {
    return ComplianceRequirement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      framework: ComplianceFramework.values.firstWhere((e) => e.name == json['framework']),
      status: ComplianceStatus.values.firstWhere((e) => e.name == json['status']),
      lastChecked: json['lastChecked'] != null 
          ? DateTime.parse(json['lastChecked'] as String) 
          : null,
      notes: json['notes'] as String?,
    );
  }
}

// Uyumluluk raporu
class ComplianceReport {
  final String id;
  final String title;
  final ComplianceFramework framework;
  final ComplianceStatus status;
  final DateTime reportDate;
  final List<ComplianceRequirement> requirements;
  final String? notes;

  const ComplianceReport({
    required this.id,
    required this.title,
    required this.framework,
    required this.status,
    required this.reportDate,
    required this.requirements,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'framework': framework.name,
      'status': status.name,
      'reportDate': reportDate.toIso8601String(),
      'requirements': requirements.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  factory ComplianceReport.fromJson(Map<String, dynamic> json) {
    return ComplianceReport(
      id: json['id'] as String,
      title: json['title'] as String,
      framework: ComplianceFramework.values.firstWhere((e) => e.name == json['framework']),
      status: ComplianceStatus.values.firstWhere((e) => e.name == json['status']),
      reportDate: DateTime.parse(json['reportDate'] as String),
      requirements: (json['requirements'] as List).map((e) => ComplianceRequirement.fromJson(e as Map<String, dynamic>)).toList(),
      notes: json['notes'] as String?,
    );
  }
}
