import 'package:flutter/material.dart';

enum SupervisionStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  requiresFollowUp
}

enum SupervisionType {
  individual,
  group,
  caseReview,
  skillAssessment,
  crisisManagement,
  documentationReview
}

enum PerformanceRating {
  excellent,
  good,
  satisfactory,
  needsImprovement,
  unsatisfactory
}

class SupervisorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final List<String> specializations;
  final List<String> assignedTherapists;
  final DateTime startDate;
  final bool isActive;
  final Map<String, dynamic> credentials;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupervisorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.specializations = const [],
    this.assignedTherapists = const [],
    required this.startDate,
    this.isActive = true,
    this.credentials = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => '$firstName $lastName';

  SupervisorModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    List<String>? specializations,
    List<String>? assignedTherapists,
    DateTime? startDate,
    bool? isActive,
    Map<String, dynamic>? credentials,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupervisorModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      specializations: specializations ?? this.specializations,
      assignedTherapists: assignedTherapists ?? this.assignedTherapists,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      credentials: credentials ?? this.credentials,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'specializations': specializations,
      'assignedTherapists': assignedTherapists,
      'startDate': startDate.toIso8601String(),
      'isActive': isActive,
      'credentials': credentials,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      specializations: List<String>.from(json['specializations'] ?? []),
      assignedTherapists: List<String>.from(json['assignedTherapists'] ?? []),
      startDate: DateTime.parse(json['startDate']),
      isActive: json['isActive'] ?? true,
      credentials: Map<String, dynamic>.from(json['credentials'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class SupervisionSession {
  final String id;
  final String supervisorId;
  final String therapistId;
  final String? clientId;
  final SupervisionType type;
  final SupervisionStatus status;
  final DateTime scheduledDate;
  final DateTime? actualDate;
  final Duration duration;
  final String notes;
  final List<String> topics;
  final List<String> actionItems;
  final Map<String, dynamic> aiSummary;
  final PerformanceRating? performanceRating;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupervisionSession({
    required this.id,
    required this.supervisorId,
    required this.therapistId,
    this.clientId,
    required this.type,
    this.status = SupervisionStatus.pending,
    required this.scheduledDate,
    this.actualDate,
    required this.duration,
    required this.notes,
    this.topics = const [],
    this.actionItems = const [],
    required this.aiSummary,
    this.performanceRating,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == SupervisionStatus.completed;
  bool get isOverdue => scheduledDate.isBefore(DateTime.now()) && !isCompleted;

  SupervisionSession copyWith({
    String? id,
    String? supervisorId,
    String? therapistId,
    String? clientId,
    SupervisionType? type,
    SupervisionStatus? status,
    DateTime? scheduledDate,
    DateTime? actualDate,
    Duration? duration,
    String? notes,
    List<String>? topics,
    List<String>? actionItems,
    Map<String, dynamic>? aiSummary,
    PerformanceRating? performanceRating,
    String? feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupervisionSession(
      id: id ?? this.id,
      supervisorId: supervisorId ?? this.supervisorId,
      therapistId: therapistId ?? this.therapistId,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      actualDate: actualDate ?? this.actualDate,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      topics: topics ?? this.topics,
      actionItems: actionItems ?? this.actionItems,
      aiSummary: aiSummary ?? this.aiSummary,
      performanceRating: performanceRating ?? this.performanceRating,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supervisorId': supervisorId,
      'therapistId': therapistId,
      'clientId': clientId,
      'type': type.name,
      'status': status.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'actualDate': actualDate?.toIso8601String(),
      'duration': duration.inMinutes,
      'notes': notes,
      'topics': topics,
      'actionItems': actionItems,
      'aiSummary': aiSummary,
      'performanceRating': performanceRating?.name,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SupervisionSession.fromJson(Map<String, dynamic> json) {
    return SupervisionSession(
      id: json['id'],
      supervisorId: json['supervisorId'],
      therapistId: json['therapistId'],
      clientId: json['clientId'],
      type: SupervisionType.values.firstWhere((e) => e.name == json['type']),
      status: SupervisionStatus.values.firstWhere((e) => e.name == json['status']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      actualDate: json['actualDate'] != null ? DateTime.parse(json['actualDate']) : null,
      duration: Duration(minutes: json['duration']),
      notes: json['notes'],
      topics: List<String>.from(json['topics'] ?? []),
      actionItems: List<String>.from(json['actionItems'] ?? []),
      aiSummary: Map<String, dynamic>.from(json['aiSummary']),
      performanceRating: json['performanceRating'] != null 
          ? PerformanceRating.values.firstWhere((e) => e.name == json['performanceRating'])
          : null,
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class TherapistPerformance {
  final String therapistId;
  final String therapistName;
  final int totalSessions;
  final int completedSessions;
  final int cancelledSessions;
  final double averageSessionDuration;
  final PerformanceRating overallRating;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final Map<String, dynamic> metrics;
  final DateTime lastUpdated;

  TherapistPerformance({
    required this.therapistId,
    required this.therapistName,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.averageSessionDuration,
    required this.overallRating,
    this.strengths = const [],
    this.areasForImprovement = const [],
    this.metrics = const {},
    required this.lastUpdated,
  });

  double get completionRate => totalSessions > 0 ? completedSessions / totalSessions : 0.0;
  double get cancellationRate => totalSessions > 0 ? cancelledSessions / totalSessions : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'therapistId': therapistId,
      'therapistName': therapistName,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'cancelledSessions': cancelledSessions,
      'averageSessionDuration': averageSessionDuration,
      'overallRating': overallRating.name,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'metrics': metrics,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory TherapistPerformance.fromJson(Map<String, dynamic> json) {
    return TherapistPerformance(
      therapistId: json['therapistId'],
      therapistName: json['therapistName'],
      totalSessions: json['totalSessions'],
      completedSessions: json['completedSessions'],
      cancelledSessions: json['cancelledSessions'],
      averageSessionDuration: json['averageSessionDuration'].toDouble(),
      overallRating: PerformanceRating.values.firstWhere((e) => e.name == json['overallRating']),
      strengths: List<String>.from(json['strengths'] ?? []),
      areasForImprovement: List<String>.from(json['areasForImprovement'] ?? []),
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class QualityMetrics {
  final String id;
  final String metricName;
  final String description;
  final double currentValue;
  final double targetValue;
  final String unit;
  final DateTime measurementDate;
  final Map<String, dynamic> breakdown;
  final List<String> recommendations;

  QualityMetrics({
    required this.id,
    required this.metricName,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.measurementDate,
    this.breakdown = const {},
    this.recommendations = const [],
  });

  double get achievementRate => targetValue > 0 ? (currentValue / targetValue) * 100 : 0.0;
  bool get isOnTarget => achievementRate >= 90.0;
  bool get needsAttention => achievementRate < 70.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metricName': metricName,
      'description': description,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'unit': unit,
      'measurementDate': measurementDate.toIso8601String(),
      'breakdown': breakdown,
      'recommendations': recommendations,
    };
  }

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      id: json['id'],
      metricName: json['metricName'],
      description: json['description'],
      currentValue: json['currentValue'].toDouble(),
      targetValue: json['targetValue'].toDouble(),
      unit: json['unit'],
      measurementDate: DateTime.parse(json['measurementDate']),
      breakdown: Map<String, dynamic>.from(json['breakdown'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}
