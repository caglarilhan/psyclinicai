import 'package:flutter/material.dart';

enum CaseStatus {
  active,
  onHold,
  completed,
  transferred,
  closed,
}

enum CasePriority {
  low,
  medium,
  high,
  urgent,
}

enum CaseType {
  individual,
  family,
  couple,
  group,
  emergency,
  consultation,
}

enum ProgressIndicator {
  improving,
  stable,
  declining,
  fluctuating,
  unknown,
}

class Case {
  final String id;
  final String clientId;
  final String therapistId;
  final String title;
  final String description;
  final CaseStatus status;
  final CasePriority priority;
  final CaseType type;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastSessionDate;
  final int totalSessions;
  final ProgressIndicator progressIndicator;
  final String? diagnosis;
  final List<String> goals;
  final List<String> interventions;
  final List<String> notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Case({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.type,
    required this.startDate,
    this.endDate,
    this.lastSessionDate,
    this.totalSessions = 0,
    this.progressIndicator = ProgressIndicator.unknown,
    this.diagnosis,
    this.goals = const [],
    this.interventions = const [],
    this.notes = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Case copyWith({
    String? id,
    String? clientId,
    String? therapistId,
    String? title,
    String? description,
    CaseStatus? status,
    CasePriority? priority,
    CaseType? type,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastSessionDate,
    int? totalSessions,
    ProgressIndicator? progressIndicator,
    String? diagnosis,
    List<String>? goals,
    List<String>? interventions,
    List<String>? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Case(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      therapistId: therapistId ?? this.therapistId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      totalSessions: totalSessions ?? this.totalSessions,
      progressIndicator: progressIndicator ?? this.progressIndicator,
      diagnosis: diagnosis ?? this.diagnosis,
      goals: goals ?? this.goals,
      interventions: interventions ?? this.interventions,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'totalSessions': totalSessions,
      'progressIndicator': progressIndicator.name,
      'diagnosis': diagnosis,
      'goals': goals,
      'interventions': interventions,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: CaseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CaseStatus.active,
      ),
      priority: CasePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => CasePriority.medium,
      ),
      type: CaseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CaseType.individual,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      lastSessionDate: json['lastSessionDate'] != null 
          ? DateTime.parse(json['lastSessionDate'] as String) 
          : null,
      totalSessions: json['totalSessions'] as int? ?? 0,
      progressIndicator: ProgressIndicator.values.firstWhere(
        (e) => e.name == json['progressIndicator'],
        orElse: () => ProgressIndicator.unknown,
      ),
      diagnosis: json['diagnosis'] as String?,
      goals: List<String>.from(json['goals'] as List? ?? []),
      interventions: List<String>.from(json['interventions'] as List? ?? []),
      notes: List<String>.from(json['notes'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isActive => status == CaseStatus.active;
  bool get isCompleted => status == CaseStatus.completed;
  bool get isUrgent => priority == CasePriority.urgent;
  bool get needsAttention => isActive && (isUrgent || progressIndicator == ProgressIndicator.declining);

  String get statusText {
    switch (status) {
      case CaseStatus.active:
        return 'Aktif';
      case CaseStatus.onHold:
        return 'Beklemede';
      case CaseStatus.completed:
        return 'Tamamlandı';
      case CaseStatus.transferred:
        return 'Transfer Edildi';
      case CaseStatus.closed:
        return 'Kapatıldı';
    }
  }

  String get priorityText {
    switch (priority) {
      case CasePriority.low:
        return 'Düşük';
      case CasePriority.medium:
        return 'Orta';
      case CasePriority.high:
        return 'Yüksek';
      case CasePriority.urgent:
        return 'Acil';
    }
  }

  String get typeText {
    switch (type) {
      case CaseType.individual:
        return 'Bireysel';
      case CaseType.family:
        return 'Aile';
      case CaseType.couple:
        return 'Çift';
      case CaseType.group:
        return 'Grup';
      case CaseType.emergency:
        return 'Acil';
      case CaseType.consultation:
        return 'Konsültasyon';
    }
  }

  String get progressText {
    switch (progressIndicator) {
      case ProgressIndicator.improving:
        return 'İyileşiyor';
      case ProgressIndicator.stable:
        return 'Stabil';
      case ProgressIndicator.declining:
        return 'Kötüleşiyor';
      case ProgressIndicator.fluctuating:
        return 'Dalgalanıyor';
      case ProgressIndicator.unknown:
        return 'Bilinmiyor';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case CasePriority.low:
        return Colors.green;
      case CasePriority.medium:
        return Colors.orange;
      case CasePriority.high:
        return Colors.red;
      case CasePriority.urgent:
        return Colors.purple;
    }
  }

  Color get progressColor {
    switch (progressIndicator) {
      case ProgressIndicator.improving:
        return Colors.green;
      case ProgressIndicator.stable:
        return Colors.blue;
      case ProgressIndicator.declining:
        return Colors.red;
      case ProgressIndicator.fluctuating:
        return Colors.orange;
      case ProgressIndicator.unknown:
        return Colors.grey;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Case && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Case(id: $id, title: $title, status: $status, priority: $priority)';
  }
}

class CaseProgress {
  final String id;
  final String caseId;
  final DateTime assessmentDate;
  final String assessorId;
  final ProgressIndicator progressIndicator;
  final String? notes;
  final List<String> achievements;
  final List<String> challenges;
  final List<String> nextSteps;
  final Map<String, dynamic>? metrics;
  final Map<String, dynamic>? metadata;

  const CaseProgress({
    required this.id,
    required this.caseId,
    required this.assessmentDate,
    required this.assessorId,
    required this.progressIndicator,
    this.notes,
    this.achievements = const [],
    this.challenges = const [],
    this.nextSteps = const [],
    this.metrics,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseId': caseId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'assessorId': assessorId,
      'progressIndicator': progressIndicator.name,
      'notes': notes,
      'achievements': achievements,
      'challenges': challenges,
      'nextSteps': nextSteps,
      'metrics': metrics,
      'metadata': metadata,
    };
  }

  factory CaseProgress.fromJson(Map<String, dynamic> json) {
    return CaseProgress(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      assessorId: json['assessorId'] as String,
      progressIndicator: ProgressIndicator.values.firstWhere(
        (e) => e.name == json['progressIndicator'],
        orElse: () => ProgressIndicator.unknown,
      ),
      notes: json['notes'] as String?,
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      challenges: List<String>.from(json['challenges'] as List? ?? []),
      nextSteps: List<String>.from(json['nextSteps'] as List? ?? []),
      metrics: json['metrics'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class CaseGoal {
  final String id;
  final String caseId;
  final String title;
  final String description;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime? completedDate;
  final String? completionNotes;
  final List<String> milestones;
  final List<String> completedMilestones;
  final Map<String, dynamic>? metadata;

  const CaseGoal({
    required this.id,
    required this.caseId,
    required this.title,
    required this.description,
    required this.targetDate,
    this.isCompleted = false,
    this.completedDate,
    this.completionNotes,
    this.milestones = const [],
    this.completedMilestones = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseId': caseId,
      'title': title,
      'description': description,
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'completionNotes': completionNotes,
      'milestones': milestones,
      'completedMilestones': completedMilestones,
      'metadata': metadata,
    };
  }

  factory CaseGoal.fromJson(Map<String, dynamic> json) {
    return CaseGoal(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'] as String) 
          : null,
      completionNotes: json['completionNotes'] as String?,
      milestones: List<String>.from(json['milestones'] as List? ?? []),
      completedMilestones: List<String>.from(json['completedMilestones'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);
  double get completionRate {
    if (milestones.isEmpty) return isCompleted ? 1.0 : 0.0;
    return completedMilestones.length / milestones.length;
  }
}

class CaseIntervention {
  final String id;
  final String caseId;
  final String title;
  final String description;
  final String interventionType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? outcome;
  final String? notes;
  final List<String> techniques;
  final Map<String, dynamic>? metadata;

  const CaseIntervention({
    required this.id,
    required this.caseId,
    required this.title,
    required this.description,
    required this.interventionType,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.outcome,
    this.notes,
    this.techniques = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseId': caseId,
      'title': title,
      'description': description,
      'interventionType': interventionType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'outcome': outcome,
      'notes': notes,
      'techniques': techniques,
      'metadata': metadata,
    };
  }

  factory CaseIntervention.fromJson(Map<String, dynamic> json) {
    return CaseIntervention(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      interventionType: json['interventionType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      outcome: json['outcome'] as String?,
      notes: json['notes'] as String?,
      techniques: List<String>.from(json['techniques'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isCompleted => endDate != null || !isActive;
  Duration get duration {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate);
  }
}
