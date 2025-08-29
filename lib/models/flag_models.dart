import 'package:flutter/material.dart';

enum FlagSeverity {
  low,
  medium,
  high,
  critical,
  emergency,
}

enum FlagStatus {
  active,
  resolved,
  escalated,
  monitoring,
  archived,
}

enum FlagType {
  suicide,
  selfHarm,
  violence,
  substanceAbuse,
  medicationNonCompliance,
  missedAppointments,
  familyConflict,
  financialCrisis,
  legalIssues,
  medicalEmergency,
  other,
}

enum FlagCategory {
  clinical,
  safety,
  compliance,
  administrative,
  medical,
  social,
  financial,
  legal,
}

class Flag {
  final String id;
  final String clientId;
  final String therapistId;
  final FlagType type;
  final FlagCategory category;
  final FlagSeverity severity;
  final FlagStatus status;
  final String title;
  final String description;
  final String? triggerEvent;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolutionNotes;
  final List<String> actions;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final bool requiresImmediate;
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final List<String> assignedTo;
  final Map<String, dynamic>? metadata;

  const Flag({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.type,
    required this.category,
    required this.severity,
    required this.status,
    required this.title,
    required this.description,
    this.triggerEvent,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNotes,
    this.actions = const [],
    this.riskFactors = const [],
    this.protectiveFactors = const [],
    this.requiresImmediate = false,
    this.requiresFollowUp = false,
    this.followUpDate,
    this.assignedTo = const [],
    this.metadata,
  });

  Flag copyWith({
    String? id,
    String? clientId,
    String? therapistId,
    FlagType? type,
    FlagCategory? category,
    FlagSeverity? severity,
    FlagStatus? status,
    String? title,
    String? description,
    String? triggerEvent,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionNotes,
    List<String>? actions,
    List<String>? riskFactors,
    List<String>? protectiveFactors,
    bool? requiresImmediate,
    bool? requiresFollowUp,
    DateTime? followUpDate,
    List<String>? assignedTo,
    Map<String, dynamic>? metadata,
  }) {
    return Flag(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      therapistId: therapistId ?? this.therapistId,
      type: type ?? this.type,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      triggerEvent: triggerEvent ?? this.triggerEvent,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      actions: actions ?? this.actions,
      riskFactors: riskFactors ?? this.riskFactors,
      protectiveFactors: protectiveFactors ?? this.protectiveFactors,
      requiresImmediate: requiresImmediate ?? this.requiresImmediate,
      requiresFollowUp: requiresFollowUp ?? this.requiresFollowUp,
      followUpDate: followUpDate ?? this.followUpDate,
      assignedTo: assignedTo ?? this.assignedTo,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'type': type.name,
      'category': category.name,
      'severity': severity.name,
      'status': status.name,
      'title': title,
      'description': description,
      'triggerEvent': triggerEvent,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'resolutionNotes': resolutionNotes,
      'actions': actions,
      'riskFactors': riskFactors,
      'protectiveFactors': protectiveFactors,
      'requiresImmediate': requiresImmediate,
      'requiresFollowUp': requiresFollowUp,
      'followUpDate': followUpDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'metadata': metadata,
    };
  }

  factory Flag.fromJson(Map<String, dynamic> json) {
    return Flag(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      type: FlagType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FlagType.other,
      ),
      category: FlagCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FlagCategory.clinical,
      ),
      severity: FlagSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => FlagSeverity.medium,
      ),
      status: FlagStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FlagStatus.active,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      triggerEvent: json['triggerEvent'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolvedBy: json['resolvedBy'] as String?,
      resolutionNotes: json['resolutionNotes'] as String?,
      actions: List<String>.from(json['actions'] as List? ?? []),
      riskFactors: List<String>.from(json['riskFactors'] as List? ?? []),
      protectiveFactors: List<String>.from(json['protectiveFactors'] as List? ?? []),
      requiresImmediate: json['requiresImmediate'] as bool? ?? false,
      requiresFollowUp: json['requiresFollowUp'] as bool? ?? false,
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate'] as String) 
          : null,
      assignedTo: List<String>.from(json['assignedTo'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isActive => status == FlagStatus.active;
  bool get isResolved => status == FlagStatus.resolved;
  bool get isCritical => severity == FlagSeverity.critical || severity == FlagSeverity.emergency;
  bool get needsImmediateAttention => requiresImmediate && isActive;

  String get severityText {
    switch (severity) {
      case FlagSeverity.low:
        return 'Düşük';
      case FlagSeverity.medium:
        return 'Orta';
      case FlagSeverity.high:
        return 'Yüksek';
      case FlagSeverity.critical:
        return 'Kritik';
      case FlagSeverity.emergency:
        return 'Acil';
    }
  }

  String get typeText {
    switch (type) {
      case FlagType.suicide:
        return 'İntihar Riski';
      case FlagType.selfHarm:
        return 'Kendine Zarar Verme';
      case FlagType.violence:
        return 'Şiddet Riski';
      case FlagType.substanceAbuse:
        return 'Madde Kullanımı';
      case FlagType.medicationNonCompliance:
        return 'İlaç Uyumsuzluğu';
      case FlagType.missedAppointments:
        return 'Kaçırılan Randevular';
      case FlagType.familyConflict:
        return 'Aile Çatışması';
      case FlagType.financialCrisis:
        return 'Finansal Kriz';
      case FlagType.legalIssues:
        return 'Yasal Sorunlar';
      case FlagType.medicalEmergency:
        return 'Tıbbi Acil';
      case FlagType.other:
        return 'Diğer';
    }
  }

  String get categoryText {
    switch (category) {
      case FlagCategory.clinical:
        return 'Klinik';
      case FlagCategory.safety:
        return 'Güvenlik';
      case FlagCategory.compliance:
        return 'Uyumluluk';
      case FlagCategory.administrative:
        return 'İdari';
      case FlagCategory.medical:
        return 'Tıbbi';
      case FlagCategory.social:
        return 'Sosyal';
      case FlagCategory.financial:
        return 'Finansal';
      case FlagCategory.legal:
        return 'Yasal';
    }
  }

  Color get severityColor {
    switch (severity) {
      case FlagSeverity.low:
        return Colors.green;
      case FlagSeverity.medium:
        return Colors.orange;
      case FlagSeverity.high:
        return Colors.red;
      case FlagSeverity.critical:
        return Colors.purple;
      case FlagSeverity.emergency:
        return Colors.black;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Flag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Flag(id: $id, title: $title, severity: $severity, status: $status)';
  }
}

class FlagAction {
  final String id;
  final String flagId;
  final String action;
  final String? description;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? completedAt;
  final String? completedBy;
  final String? completionNotes;
  final bool isCompleted;

  const FlagAction({
    required this.id,
    required this.flagId,
    required this.action,
    this.description,
    required this.createdAt,
    required this.createdBy,
    this.completedAt,
    this.completedBy,
    this.completionNotes,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flagId': flagId,
      'action': action,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
      'completionNotes': completionNotes,
      'isCompleted': isCompleted,
    };
  }

  factory FlagAction.fromJson(Map<String, dynamic> json) {
    return FlagAction(
      id: json['id'] as String,
      flagId: json['flagId'] as String,
      action: json['action'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      completedBy: json['completedBy'] as String?,
      completionNotes: json['completionNotes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class RiskAssessment {
  final String id;
  final String clientId;
  final DateTime assessmentDate;
  final String assessorId;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final int riskScore;
  final String riskLevel;
  final String? recommendations;
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final Map<String, dynamic>? metadata;

  const RiskAssessment({
    required this.id,
    required this.clientId,
    required this.assessmentDate,
    required this.assessorId,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.riskScore,
    required this.riskLevel,
    this.recommendations,
    this.requiresFollowUp = false,
    this.followUpDate,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'assessorId': assessorId,
      'riskFactors': riskFactors,
      'protectiveFactors': protectiveFactors,
      'riskScore': riskScore,
      'riskLevel': riskLevel,
      'recommendations': recommendations,
      'requiresFollowUp': requiresFollowUp,
      'followUpDate': followUpDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      assessorId: json['assessorId'] as String,
      riskFactors: List<String>.from(json['riskFactors'] as List),
      protectiveFactors: List<String>.from(json['protectiveFactors'] as List),
      riskScore: json['riskScore'] as int,
      riskLevel: json['riskLevel'] as String,
      recommendations: json['recommendations'] as String?,
      requiresFollowUp: json['requiresFollowUp'] as bool? ?? false,
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Color get riskLevelColor {
    switch (riskLevel.toLowerCase()) {
      case 'düşük':
        return Colors.green;
      case 'orta':
        return Colors.orange;
      case 'yüksek':
        return Colors.red;
      case 'kritik':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class CrisisProtocol {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final List<String> contacts;
  final List<String> resources;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CrisisProtocol({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.contacts,
    required this.resources,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps': steps,
      'contacts': contacts,
      'resources': resources,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CrisisProtocol.fromJson(Map<String, dynamic> json) {
    return CrisisProtocol(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      steps: List<String>.from(json['steps'] as List),
      contacts: List<String>.from(json['contacts'] as List),
      resources: List<String>.from(json['resources'] as List),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }
}
