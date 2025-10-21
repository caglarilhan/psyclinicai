class CrisisProtocol {
  final String id;
  final String title;
  final String description;
  final CrisisType type;
  final CrisisSeverity severity;
  final List<CrisisStep> steps;
  final List<String> requiredResources;
  final List<String> contactNumbers;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const CrisisProtocol({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.steps,
    required this.requiredResources,
    required this.contactNumbers,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory CrisisProtocol.fromJson(Map<String, dynamic> json) {
    return CrisisProtocol(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: CrisisType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CrisisType.medical,
      ),
      severity: CrisisSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => CrisisSeverity.moderate,
      ),
      steps: (json['steps'] as List<dynamic>)
          .map((step) => CrisisStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      requiredResources: List<String>.from(json['requiredResources'] as List),
      contactNumbers: List<String>.from(json['contactNumbers'] as List),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'steps': steps.map((step) => step.toJson()).toList(),
      'requiredResources': requiredResources,
      'contactNumbers': contactNumbers,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class CrisisStep {
  final String id;
  final int order;
  final String title;
  final String description;
  final List<String> actions;
  final List<String>? warnings;
  final Duration? estimatedTime;
  final bool isCritical;
  final String? responsibleRole;

  const CrisisStep({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.actions,
    this.warnings,
    this.estimatedTime,
    this.isCritical = false,
    this.responsibleRole,
  });

  factory CrisisStep.fromJson(Map<String, dynamic> json) {
    return CrisisStep(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      actions: List<String>.from(json['actions'] as List),
      warnings: json['warnings'] != null 
          ? List<String>.from(json['warnings'] as List) 
          : null,
      estimatedTime: json['estimatedTime'] != null 
          ? Duration(minutes: json['estimatedTime'] as int) 
          : null,
      isCritical: json['isCritical'] as bool? ?? false,
      responsibleRole: json['responsibleRole'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'title': title,
      'description': description,
      'actions': actions,
      'warnings': warnings,
      'estimatedTime': estimatedTime?.inMinutes,
      'isCritical': isCritical,
      'responsibleRole': responsibleRole,
    };
  }
}

class CrisisIncident {
  final String id;
  final String patientId;
  final String protocolId;
  final CrisisType type;
  final CrisisSeverity severity;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String initiatedBy; // clinician ID
  final List<String> involvedStaff;
  final List<CrisisStepExecution> stepExecutions;
  final String? notes;
  final CrisisStatus status;
  final Map<String, dynamic> metadata;

  const CrisisIncident({
    required this.id,
    required this.patientId,
    required this.protocolId,
    required this.type,
    required this.severity,
    required this.startedAt,
    this.endedAt,
    required this.initiatedBy,
    this.involvedStaff = const [],
    this.stepExecutions = const [],
    this.notes,
    this.status = CrisisStatus.active,
    this.metadata = const {},
  });

  factory CrisisIncident.fromJson(Map<String, dynamic> json) {
    return CrisisIncident(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      protocolId: json['protocolId'] as String,
      type: CrisisType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CrisisType.medical,
      ),
      severity: CrisisSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => CrisisSeverity.moderate,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String) 
          : null,
      initiatedBy: json['initiatedBy'] as String,
      involvedStaff: List<String>.from(json['involvedStaff'] as List? ?? []),
      stepExecutions: (json['stepExecutions'] as List<dynamic>?)
          ?.map((execution) => CrisisStepExecution.fromJson(execution as Map<String, dynamic>))
          .toList() ?? [],
      notes: json['notes'] as String?,
      status: CrisisStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CrisisStatus.active,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'protocolId': protocolId,
      'type': type.name,
      'severity': severity.name,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'initiatedBy': initiatedBy,
      'involvedStaff': involvedStaff,
      'stepExecutions': stepExecutions.map((execution) => execution.toJson()).toList(),
      'notes': notes,
      'status': status.name,
      'metadata': metadata,
    };
  }

  // Kriz süresi hesaplama
  Duration? get duration {
    if (endedAt == null) return null;
    return endedAt!.difference(startedAt);
  }

  // Tamamlanan adım sayısı
  int get completedStepsCount {
    return stepExecutions.where((execution) => execution.isCompleted).length;
  }

  // Toplam adım sayısı
  int get totalStepsCount {
    return stepExecutions.length;
  }

  // İlerleme yüzdesi
  double get progressPercentage {
    if (totalStepsCount == 0) return 0.0;
    return completedStepsCount / totalStepsCount;
  }
}

class CrisisStepExecution {
  final String id;
  final String stepId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? executedBy;
  final bool isCompleted;
  final String? notes;
  final List<String>? issues;
  final Map<String, dynamic>? measurements;

  const CrisisStepExecution({
    required this.id,
    required this.stepId,
    required this.startedAt,
    this.completedAt,
    this.executedBy,
    this.isCompleted = false,
    this.notes,
    this.issues,
    this.measurements,
  });

  factory CrisisStepExecution.fromJson(Map<String, dynamic> json) {
    return CrisisStepExecution(
      id: json['id'] as String,
      stepId: json['stepId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      executedBy: json['executedBy'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
      issues: json['issues'] != null 
          ? List<String>.from(json['issues'] as List) 
          : null,
      measurements: json['measurements'] != null 
          ? Map<String, dynamic>.from(json['measurements'] as Map) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepId': stepId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'executedBy': executedBy,
      'isCompleted': isCompleted,
      'notes': notes,
      'issues': issues,
      'measurements': measurements,
    };
  }
}

class CrisisAlert {
  final String id;
  final String patientId;
  final String incidentId;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime createdAt;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final List<String> notifiedStaff;

  const CrisisAlert({
    required this.id,
    required this.patientId,
    required this.incidentId,
    required this.type,
    required this.severity,
    required this.message,
    required this.createdAt,
    this.isAcknowledged = false,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.notifiedStaff = const [],
  });

  factory CrisisAlert.fromJson(Map<String, dynamic> json) {
    return CrisisAlert(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      incidentId: json['incidentId'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.crisisInitiated,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.high,
      ),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null 
          ? DateTime.parse(json['acknowledgedAt'] as String) 
          : null,
      acknowledgedBy: json['acknowledgedBy'] as String?,
      notifiedStaff: List<String>.from(json['notifiedStaff'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'incidentId': incidentId,
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isAcknowledged': isAcknowledged,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': acknowledgedBy,
      'notifiedStaff': notifiedStaff,
    };
  }
}

enum CrisisType {
  medical,
  psychiatric,
  cardiac,
  respiratory,
  neurological,
  trauma,
  overdose,
  suicide,
  violence,
  fire,
  security,
}

enum CrisisSeverity {
  low,
  moderate,
  high,
  critical,
  emergency,
}

enum CrisisStatus {
  active,
  resolved,
  escalated,
  cancelled,
}

enum AlertType {
  crisisInitiated,
  stepCompleted,
  stepOverdue,
  escalationRequired,
  resourcesNeeded,
  protocolDeviation,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}
