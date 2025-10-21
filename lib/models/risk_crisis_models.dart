class RiskAssessment {
  final String id;
  final String patientId;
  final String assessorId;
  final RiskType type;
  final RiskLevel level;
  final DateTime assessedAt;
  final String? assessmentTool;
  final Map<String, dynamic> responses;
  final Map<String, dynamic> scores;
  final String? interpretation;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final String? recommendations;
  final DateTime? followUpDate;
  final String? notes;
  final Map<String, dynamic> metadata;

  const RiskAssessment({
    required this.id,
    required this.patientId,
    required this.assessorId,
    required this.type,
    required this.level,
    required this.assessedAt,
    this.assessmentTool,
    this.responses = const {},
    this.scores = const {},
    this.interpretation,
    this.riskFactors = const [],
    this.protectiveFactors = const [],
    this.recommendations,
    this.followUpDate,
    this.notes,
    this.metadata = const {},
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      assessorId: json['assessorId'] as String,
      type: RiskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RiskType.suicide,
      ),
      level: RiskLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => RiskLevel.low,
      ),
      assessedAt: DateTime.parse(json['assessedAt'] as String),
      assessmentTool: json['assessmentTool'] as String?,
      responses: Map<String, dynamic>.from(json['responses'] as Map? ?? {}),
      scores: Map<String, dynamic>.from(json['scores'] as Map? ?? {}),
      interpretation: json['interpretation'] as String?,
      riskFactors: List<String>.from(json['riskFactors'] as List? ?? []),
      protectiveFactors: List<String>.from(json['protectiveFactors'] as List? ?? []),
      recommendations: json['recommendations'] as String?,
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate'] as String) 
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'assessorId': assessorId,
      'type': type.name,
      'level': level.name,
      'assessedAt': assessedAt.toIso8601String(),
      'assessmentTool': assessmentTool,
      'responses': responses,
      'scores': scores,
      'interpretation': interpretation,
      'riskFactors': riskFactors,
      'protectiveFactors': protectiveFactors,
      'recommendations': recommendations,
      'followUpDate': followUpDate?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Check if assessment is high risk
  bool get isHighRisk {
    return level == RiskLevel.high || level == RiskLevel.critical;
  }

  // Check if follow-up is needed
  bool get needsFollowUp {
    return followUpDate != null && followUpDate!.isAfter(DateTime.now());
  }

  // Check if follow-up is overdue
  bool get isFollowUpOverdue {
    return followUpDate != null && followUpDate!.isBefore(DateTime.now());
  }
}

class CrisisIncident {
  final String id;
  final String patientId;
  final String reportedBy;
  final CrisisType type;
  final CrisisSeverity severity;
  final DateTime occurredAt;
  final String? location;
  final String description;
  final List<String> witnesses;
  final List<String> involvedStaff;
  final CrisisStatus status;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolution;
  final List<String> actions;
  final String? notes;
  final Map<String, dynamic> metadata;

  const CrisisIncident({
    required this.id,
    required this.patientId,
    required this.reportedBy,
    required this.type,
    required this.severity,
    required this.occurredAt,
    this.location,
    required this.description,
    this.witnesses = const [],
    this.involvedStaff = const [],
    this.status = CrisisStatus.reported,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
    this.actions = const [],
    this.notes,
    this.metadata = const {},
  });

  factory CrisisIncident.fromJson(Map<String, dynamic> json) {
    return CrisisIncident(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      reportedBy: json['reportedBy'] as String,
      type: CrisisType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CrisisType.suicide,
      ),
      severity: CrisisSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => CrisisSeverity.low,
      ),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      location: json['location'] as String?,
      description: json['description'] as String,
      witnesses: List<String>.from(json['witnesses'] as List? ?? []),
      involvedStaff: List<String>.from(json['involvedStaff'] as List? ?? []),
      status: CrisisStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CrisisStatus.reported,
      ),
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolvedBy: json['resolvedBy'] as String?,
      resolution: json['resolution'] as String?,
      actions: List<String>.from(json['actions'] as List? ?? []),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'reportedBy': reportedBy,
      'type': type.name,
      'severity': severity.name,
      'occurredAt': occurredAt.toIso8601String(),
      'location': location,
      'description': description,
      'witnesses': witnesses,
      'involvedStaff': involvedStaff,
      'status': status.name,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'resolution': resolution,
      'actions': actions,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Check if incident is active
  bool get isActive {
    return status == CrisisStatus.reported || status == CrisisStatus.investigating;
  }

  // Check if incident is urgent
  bool get isUrgent {
    return severity == CrisisSeverity.high || severity == CrisisSeverity.critical;
  }

  // Check if incident is overdue
  bool get isOverdue {
    if (status == CrisisStatus.resolved) return false;
    
    final hoursSinceOccurred = DateTime.now().difference(occurredAt).inHours;
    
    switch (severity) {
      case CrisisSeverity.critical:
        return hoursSinceOccurred > 1;
      case CrisisSeverity.high:
        return hoursSinceOccurred > 4;
      case CrisisSeverity.medium:
        return hoursSinceOccurred > 24;
      case CrisisSeverity.low:
        return hoursSinceOccurred > 72;
    }
  }
}

class SafetyPlan {
  final String id;
  final String patientId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SafetyPlanStatus status;
  final List<String> warningSigns;
  final List<String> copingStrategies;
  final List<String> socialSupports;
  final List<String> professionalSupports;
  final List<String> environmentalSafeguards;
  final String? emergencyContacts;
  final String? notes;
  final DateTime? reviewDate;
  final Map<String, dynamic> metadata;

  const SafetyPlan({
    required this.id,
    required this.patientId,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.status = SafetyPlanStatus.active,
    this.warningSigns = const [],
    this.copingStrategies = const [],
    this.socialSupports = const [],
    this.professionalSupports = const [],
    this.environmentalSafeguards = const [],
    this.emergencyContacts,
    this.notes,
    this.reviewDate,
    this.metadata = const {},
  });

  factory SafetyPlan.fromJson(Map<String, dynamic> json) {
    return SafetyPlan(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      status: SafetyPlanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SafetyPlanStatus.active,
      ),
      warningSigns: List<String>.from(json['warningSigns'] as List? ?? []),
      copingStrategies: List<String>.from(json['copingStrategies'] as List? ?? []),
      socialSupports: List<String>.from(json['socialSupports'] as List? ?? []),
      professionalSupports: List<String>.from(json['professionalSupports'] as List? ?? []),
      environmentalSafeguards: List<String>.from(json['environmentalSafeguards'] as List? ?? []),
      emergencyContacts: json['emergencyContacts'] as String?,
      notes: json['notes'] as String?,
      reviewDate: json['reviewDate'] != null 
          ? DateTime.parse(json['reviewDate'] as String) 
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.name,
      'warningSigns': warningSigns,
      'copingStrategies': copingStrategies,
      'socialSupports': socialSupports,
      'professionalSupports': professionalSupports,
      'environmentalSafeguards': environmentalSafeguards,
      'emergencyContacts': emergencyContacts,
      'notes': notes,
      'reviewDate': reviewDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Check if safety plan needs review
  bool get needsReview {
    if (reviewDate == null) return true;
    return reviewDate!.isBefore(DateTime.now());
  }

  // Check if safety plan is complete
  bool get isComplete {
    return warningSigns.isNotEmpty &&
           copingStrategies.isNotEmpty &&
           socialSupports.isNotEmpty &&
           professionalSupports.isNotEmpty &&
           environmentalSafeguards.isNotEmpty &&
           emergencyContacts != null;
  }
}

class RiskAlert {
  final String id;
  final String patientId;
  final String triggeredBy;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime triggeredAt;
  final String message;
  final Map<String, dynamic> triggerData;
  final AlertStatus status;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolution;
  final Map<String, dynamic> metadata;

  const RiskAlert({
    required this.id,
    required this.patientId,
    required this.triggeredBy,
    required this.type,
    required this.severity,
    required this.triggeredAt,
    required this.message,
    this.triggerData = const {},
    this.status = AlertStatus.active,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.resolvedBy,
    this.resolvedAt,
    this.resolution,
    this.metadata = const {},
  });

  factory RiskAlert.fromJson(Map<String, dynamic> json) {
    return RiskAlert(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      triggeredBy: json['triggeredBy'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.risk,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.low,
      ),
      triggeredAt: DateTime.parse(json['triggeredAt'] as String),
      message: json['message'] as String,
      triggerData: Map<String, dynamic>.from(json['triggerData'] as Map? ?? {}),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AlertStatus.active,
      ),
      acknowledgedBy: json['acknowledgedBy'] as String?,
      acknowledgedAt: json['acknowledgedAt'] != null 
          ? DateTime.parse(json['acknowledgedAt'] as String) 
          : null,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolution: json['resolution'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'triggeredBy': triggeredBy,
      'type': type.name,
      'severity': severity.name,
      'triggeredAt': triggeredAt.toIso8601String(),
      'message': message,
      'triggerData': triggerData,
      'status': status.name,
      'acknowledgedBy': acknowledgedBy,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolution': resolution,
      'metadata': metadata,
    };
  }

  // Check if alert is active
  bool get isActive {
    return status == AlertStatus.active;
  }

  // Check if alert is urgent
  bool get isUrgent {
    return severity == AlertSeverity.high || severity == AlertSeverity.critical;
  }

  // Check if alert is overdue
  bool get isOverdue {
    if (status == AlertStatus.resolved) return false;
    
    final hoursSinceTriggered = DateTime.now().difference(triggeredAt).inHours;
    
    switch (severity) {
      case AlertSeverity.critical:
        return hoursSinceTriggered > 1;
      case AlertSeverity.high:
        return hoursSinceTriggered > 4;
      case AlertSeverity.medium:
        return hoursSinceTriggered > 24;
      case AlertSeverity.low:
        return hoursSinceTriggered > 72;
    }
  }
}

enum RiskType {
  suicide,
  selfHarm,
  violence,
  substance,
  medical,
  other,
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

enum CrisisType {
  suicide,
  selfHarm,
  violence,
  medical,
  behavioral,
  other,
}

enum CrisisSeverity {
  low,
  medium,
  high,
  critical,
}

enum CrisisStatus {
  reported,
  investigating,
  resolved,
  escalated,
}

enum SafetyPlanStatus {
  active,
  inactive,
  archived,
}

enum AlertType {
  risk,
  crisis,
  safety,
  compliance,
  other,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum AlertStatus {
  active,
  acknowledged,
  resolved,
  dismissed,
}
