class EthicsViolation {
  final String id;
  final String title;
  final String description;
  final ViolationType type;
  final ViolationSeverity severity;
  final String reportedBy;
  final String? reportedByRole;
  final DateTime reportedAt;
  final String? patientId;
  final String? caseId;
  final String? clinicianId;
  final List<String> evidence;
  final List<String> witnesses;
  final ViolationStatus status;
  final String? assignedTo;
  final DateTime? assignedAt;
  final String? investigationNotes;
  final DateTime? investigationStartedAt;
  final DateTime? investigationCompletedAt;
  final String? resolution;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final List<String> actions;
  final Map<String, dynamic> metadata;

  const EthicsViolation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.reportedBy,
    this.reportedByRole,
    required this.reportedAt,
    this.patientId,
    this.caseId,
    this.clinicianId,
    this.evidence = const [],
    this.witnesses = const [],
    this.status = ViolationStatus.reported,
    this.assignedTo,
    this.assignedAt,
    this.investigationNotes,
    this.investigationStartedAt,
    this.investigationCompletedAt,
    this.resolution,
    this.resolvedAt,
    this.resolvedBy,
    this.actions = const [],
    this.metadata = const {},
  });

  factory EthicsViolation.fromJson(Map<String, dynamic> json) {
    return EthicsViolation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ViolationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ViolationType.confidentiality,
      ),
      severity: ViolationSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ViolationSeverity.low,
      ),
      reportedBy: json['reportedBy'] as String,
      reportedByRole: json['reportedByRole'] as String?,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      patientId: json['patientId'] as String?,
      caseId: json['caseId'] as String?,
      clinicianId: json['clinicianId'] as String?,
      evidence: List<String>.from(json['evidence'] as List? ?? []),
      witnesses: List<String>.from(json['witnesses'] as List? ?? []),
      status: ViolationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ViolationStatus.reported,
      ),
      assignedTo: json['assignedTo'] as String?,
      assignedAt: json['assignedAt'] != null 
          ? DateTime.parse(json['assignedAt'] as String) 
          : null,
      investigationNotes: json['investigationNotes'] as String?,
      investigationStartedAt: json['investigationStartedAt'] != null 
          ? DateTime.parse(json['investigationStartedAt'] as String) 
          : null,
      investigationCompletedAt: json['investigationCompletedAt'] != null 
          ? DateTime.parse(json['investigationCompletedAt'] as String) 
          : null,
      resolution: json['resolution'] as String?,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolvedBy: json['resolvedBy'] as String?,
      actions: List<String>.from(json['actions'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'reportedBy': reportedBy,
      'reportedByRole': reportedByRole,
      'reportedAt': reportedAt.toIso8601String(),
      'patientId': patientId,
      'caseId': caseId,
      'clinicianId': clinicianId,
      'evidence': evidence,
      'witnesses': witnesses,
      'status': status.name,
      'assignedTo': assignedTo,
      'assignedAt': assignedAt?.toIso8601String(),
      'investigationNotes': investigationNotes,
      'investigationStartedAt': investigationStartedAt?.toIso8601String(),
      'investigationCompletedAt': investigationCompletedAt?.toIso8601String(),
      'resolution': resolution,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'actions': actions,
      'metadata': metadata,
    };
  }

  // Check if violation is urgent
  bool get isUrgent {
    return severity == ViolationSeverity.critical || 
           severity == ViolationSeverity.high;
  }

  // Check if violation is overdue
  bool get isOverdue {
    if (status == ViolationStatus.resolved) return false;
    
    final daysSinceReported = DateTime.now().difference(reportedAt).inDays;
    
    switch (severity) {
      case ViolationSeverity.critical:
        return daysSinceReported > 1;
      case ViolationSeverity.high:
        return daysSinceReported > 3;
      case ViolationSeverity.medium:
        return daysSinceReported > 7;
      case ViolationSeverity.low:
        return daysSinceReported > 14;
    }
  }
}

class RedFlag {
  final String id;
  final String title;
  final String description;
  final RedFlagType type;
  final RedFlagSeverity severity;
  final String detectedBy;
  final DateTime detectedAt;
  final String? patientId;
  final String? caseId;
  final String? clinicianId;
  final Map<String, dynamic> triggerData;
  final RedFlagStatus status;
  final String? assignedTo;
  final DateTime? assignedAt;
  final String? investigationNotes;
  final DateTime? investigationStartedAt;
  final DateTime? investigationCompletedAt;
  final String? resolution;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final List<String> actions;
  final Map<String, dynamic> metadata;

  const RedFlag({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.detectedBy,
    required this.detectedAt,
    this.patientId,
    this.caseId,
    this.clinicianId,
    this.triggerData = const {},
    this.status = RedFlagStatus.detected,
    this.assignedTo,
    this.assignedAt,
    this.investigationNotes,
    this.investigationStartedAt,
    this.investigationCompletedAt,
    this.resolution,
    this.resolvedAt,
    this.resolvedBy,
    this.actions = const [],
    this.metadata = const {},
  });

  factory RedFlag.fromJson(Map<String, dynamic> json) {
    return RedFlag(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: RedFlagType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RedFlagType.risk,
      ),
      severity: RedFlagSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => RedFlagSeverity.low,
      ),
      detectedBy: json['detectedBy'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      patientId: json['patientId'] as String?,
      caseId: json['caseId'] as String?,
      clinicianId: json['clinicianId'] as String?,
      triggerData: Map<String, dynamic>.from(json['triggerData'] as Map? ?? {}),
      status: RedFlagStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RedFlagStatus.detected,
      ),
      assignedTo: json['assignedTo'] as String?,
      assignedAt: json['assignedAt'] != null 
          ? DateTime.parse(json['assignedAt'] as String) 
          : null,
      investigationNotes: json['investigationNotes'] as String?,
      investigationStartedAt: json['investigationStartedAt'] != null 
          ? DateTime.parse(json['investigationStartedAt'] as String) 
          : null,
      investigationCompletedAt: json['investigationCompletedAt'] != null 
          ? DateTime.parse(json['investigationCompletedAt'] as String) 
          : null,
      resolution: json['resolution'] as String?,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolvedBy: json['resolvedBy'] as String?,
      actions: List<String>.from(json['actions'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'detectedBy': detectedBy,
      'detectedAt': detectedAt.toIso8601String(),
      'patientId': patientId,
      'caseId': caseId,
      'clinicianId': clinicianId,
      'triggerData': triggerData,
      'status': status.name,
      'assignedTo': assignedTo,
      'assignedAt': assignedAt?.toIso8601String(),
      'investigationNotes': investigationNotes,
      'investigationStartedAt': investigationStartedAt?.toIso8601String(),
      'investigationCompletedAt': investigationCompletedAt?.toIso8601String(),
      'resolution': resolution,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'actions': actions,
      'metadata': metadata,
    };
  }

  // Check if red flag is urgent
  bool get isUrgent {
    return severity == RedFlagSeverity.critical || 
           severity == RedFlagSeverity.high;
  }

  // Check if red flag is overdue
  bool get isOverdue {
    if (status == RedFlagStatus.resolved) return false;
    
    final hoursSinceDetected = DateTime.now().difference(detectedAt).inHours;
    
    switch (severity) {
      case RedFlagSeverity.critical:
        return hoursSinceDetected > 2;
      case RedFlagSeverity.high:
        return hoursSinceDetected > 8;
      case RedFlagSeverity.medium:
        return hoursSinceDetected > 24;
      case RedFlagSeverity.low:
        return hoursSinceDetected > 72;
    }
  }
}

class EthicsPolicy {
  final String id;
  final String title;
  final String description;
  final PolicyType type;
  final String content;
  final List<String> applicableRoles;
  final List<String> applicableScenarios;
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final int version;

  const EthicsPolicy({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.applicableRoles,
    required this.applicableScenarios,
    required this.effectiveDate,
    this.expiryDate,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.version = 1,
  });

  factory EthicsPolicy.fromJson(Map<String, dynamic> json) {
    return EthicsPolicy(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: PolicyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PolicyType.general,
      ),
      content: json['content'] as String,
      applicableRoles: List<String>.from(json['applicableRoles'] as List),
      applicableScenarios: List<String>.from(json['applicableScenarios'] as List),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'content': content,
      'applicableRoles': applicableRoles,
      'applicableScenarios': applicableScenarios,
      'effectiveDate': effectiveDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'version': version,
    };
  }

  // Check if policy is effective
  bool get isEffective {
    if (!isActive) return false;
    if (effectiveDate.isAfter(DateTime.now())) return false;
    if (expiryDate != null && expiryDate!.isBefore(DateTime.now())) return false;
    return true;
  }
}

enum ViolationType {
  confidentiality,
  consent,
  competence,
  boundaries,
  documentation,
  billing,
  supervision,
  research,
  discrimination,
  harassment,
  other,
}

enum ViolationSeverity {
  low,
  medium,
  high,
  critical,
}

enum ViolationStatus {
  reported,
  assigned,
  investigating,
  resolved,
  dismissed,
  escalated,
}

enum RedFlagType {
  risk,
  safety,
  compliance,
  quality,
  performance,
  behavior,
  system,
  other,
}

enum RedFlagSeverity {
  low,
  medium,
  high,
  critical,
}

enum RedFlagStatus {
  detected,
  assigned,
  investigating,
  resolved,
  dismissed,
  escalated,
}

enum PolicyType {
  general,
  confidentiality,
  consent,
  boundaries,
  supervision,
  documentation,
  billing,
  research,
  discrimination,
  harassment,
}
