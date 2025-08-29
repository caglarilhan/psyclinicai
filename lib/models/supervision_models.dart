import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'supervision_models.g.dart';

// Enums
enum SupervisionType { individual, group, caseReview, skillAssessment, crisis }
enum SupervisionStatus { pending, inProgress, completed, cancelled }
enum PerformanceRating { poor, fair, good, veryGood, excellent }
enum SupervisionActivityType { sessionCreated, sessionCompleted, feedbackGiven, performanceUpdated }

// Main Models
class SupervisionSession {
  final String id;
  final String title;
  final String supervisorId;
  final String therapistId;
  final String therapistName;
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
    required this.title,
    required this.supervisorId,
    required this.therapistId,
    required this.therapistName,
    this.clientId,
    required this.type,
    required this.status,
    required this.scheduledDate,
    this.actualDate,
    required this.duration,
    required this.notes,
    required this.topics,
    required this.actionItems,
    required this.aiSummary,
    this.performanceRating,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupervisionSession.fromJson(Map<String, dynamic> json) {
    return SupervisionSession(
      id: json['id'],
      title: json['title'],
      supervisorId: json['supervisorId'],
      therapistId: json['therapistId'],
      therapistName: json['therapistName'],
      clientId: json['clientId'],
      type: SupervisionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: SupervisionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      actualDate: json['actualDate'] != null ? DateTime.parse(json['actualDate']) : null,
      duration: Duration(minutes: json['durationMinutes'] ?? 60),
      notes: json['notes'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      actionItems: List<String>.from(json['actionItems'] ?? []),
      aiSummary: Map<String, dynamic>.from(json['aiSummary'] ?? {}),
      performanceRating: json['performanceRating'] != null
          ? PerformanceRating.values.firstWhere(
              (e) => e.toString().split('.').last == json['performanceRating'],
            )
          : null,
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'supervisorId': supervisorId,
      'therapistId': therapistId,
      'therapistName': therapistName,
      'clientId': clientId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'scheduledDate': scheduledDate.toIso8601String(),
      'actualDate': actualDate?.toIso8601String(),
      'durationMinutes': duration.inMinutes,
      'notes': notes,
      'topics': topics,
      'actionItems': actionItems,
      'aiSummary': aiSummary,
      'performanceRating': performanceRating?.toString().split('.').last,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isOverdue => 
      status == SupervisionStatus.pending && 
      scheduledDate.isBefore(DateTime.now());

  bool get isToday => 
      scheduledDate.year == DateTime.now().year &&
      scheduledDate.month == DateTime.now().month &&
      scheduledDate.day == DateTime.now().day;

  String get statusText {
    switch (status) {
      case SupervisionStatus.pending:
        return 'Bekliyor';
      case SupervisionStatus.inProgress:
        return 'Devam Ediyor';
      case SupervisionStatus.completed:
        return 'Tamamlandı';
      case SupervisionStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  String get typeText {
    switch (type) {
      case SupervisionType.individual:
        return 'Bireysel';
      case SupervisionType.group:
        return 'Grup';
      case SupervisionType.caseReview:
        return 'Vaka İncelemesi';
      case SupervisionType.skillAssessment:
        return 'Beceri Değerlendirmesi';
      case SupervisionType.crisis:
        return 'Kriz';
    }
  }

  SupervisionSession copyWith({
    String? id,
    String? title,
    String? supervisorId,
    String? therapistId,
    String? therapistName,
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
      title: title ?? this.title,
      supervisorId: supervisorId ?? this.supervisorId,
      therapistId: therapistId ?? this.therapistId,
      therapistName: therapistName ?? this.therapistName,
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
}

class TherapistPerformance {
  final String id;
  final String therapistId;
  final String therapistName;
  final String specialization;
  final double successRate;
  final int caseCount;
  final double averageRating;
  final double improvementRate;
  final String notes;
  final DateTime lastUpdated;
  final bool isActive;
  final List<String> strengths;
  final List<String> improvementAreas;
  final Map<String, double> skillScores;

  TherapistPerformance({
    required this.id,
    required this.therapistId,
    required this.therapistName,
    required this.specialization,
    required this.successRate,
    required this.caseCount,
    required this.averageRating,
    required this.improvementRate,
    required this.notes,
    required this.lastUpdated,
    required this.isActive,
    required this.strengths,
    required this.improvementAreas,
    required this.skillScores,
  });

  factory TherapistPerformance.fromJson(Map<String, dynamic> json) {
    return TherapistPerformance(
      id: json['id'],
      therapistId: json['therapistId'],
      therapistName: json['therapistName'],
      specialization: json['specialization'] ?? '',
      successRate: json['successRate']?.toDouble() ?? 0.0,
      caseCount: json['caseCount'] ?? 0,
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      improvementRate: json['improvementRate']?.toDouble() ?? 0.0,
      notes: json['notes'] ?? '',
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'] ?? true,
      strengths: List<String>.from(json['strengths'] ?? []),
      improvementAreas: List<String>.from(json['improvementAreas'] ?? []),
      skillScores: Map<String, double>.from(json['skillScores'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'therapistId': therapistId,
      'therapistName': therapistName,
      'specialization': specialization,
      'successRate': successRate,
      'caseCount': caseCount,
      'averageRating': averageRating,
      'improvementRate': improvementRate,
      'notes': notes,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
      'strengths': strengths,
      'improvementAreas': improvementAreas,
      'skillScores': skillScores,
    };
  }

  String get performanceLevel {
    if (successRate >= 0.9) return 'Mükemmel';
    if (successRate >= 0.8) return 'Çok İyi';
    if (successRate >= 0.7) return 'İyi';
    if (successRate >= 0.6) return 'Orta';
    return 'Geliştirilmeli';
  }

  Color get performanceColor {
    if (successRate >= 0.9) return Colors.green;
    if (successRate >= 0.8) return Colors.lightGreen;
    if (successRate >= 0.7) return Colors.orange;
    if (successRate >= 0.6) return Colors.deepOrange;
    return Colors.red;
  }

  TherapistPerformance copyWith({
    String? id,
    String? therapistId,
    String? therapistName,
    String? specialization,
    double? successRate,
    int? caseCount,
    double? averageRating,
    double? improvementRate,
    String? notes,
    DateTime? lastUpdated,
    bool? isActive,
    List<String>? strengths,
    List<String>? improvementAreas,
    Map<String, double>? skillScores,
  }) {
    return TherapistPerformance(
      id: id ?? this.id,
      therapistId: therapistId ?? this.therapistId,
      therapistName: therapistName ?? this.therapistName,
      specialization: specialization ?? this.specialization,
      successRate: successRate ?? this.successRate,
      caseCount: caseCount ?? this.caseCount,
      averageRating: averageRating ?? this.averageRating,
      improvementRate: improvementRate ?? this.improvementRate,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      strengths: strengths ?? this.strengths,
      improvementAreas: improvementAreas ?? this.improvementAreas,
      skillScores: skillScores ?? this.skillScores,
    );
  }
}

class QualityMetrics {
  final double averageScore;
  final double qualityRate;
  final int totalSessions;
  final int successfulSessions;
  final List<String> improvementAreas;
  final Map<String, double> metricScores;
  final DateTime lastUpdated;

  QualityMetrics({
    required this.averageScore,
    required this.qualityRate,
    required this.totalSessions,
    required this.successfulSessions,
    required this.improvementAreas,
    required this.metricScores,
    required this.lastUpdated,
  });

  factory QualityMetrics.empty() {
    return QualityMetrics(
      averageScore: 0.0,
      qualityRate: 0.0,
      totalSessions: 0,
      successfulSessions: 0,
      improvementAreas: [],
      metricScores: {},
      lastUpdated: DateTime.now(),
    );
  }

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      averageScore: json['averageScore']?.toDouble() ?? 0.0,
      qualityRate: json['qualityRate']?.toDouble() ?? 0.0,
      totalSessions: json['totalSessions'] ?? 0,
      successfulSessions: json['successfulSessions'] ?? 0,
      improvementAreas: List<String>.from(json['improvementAreas'] ?? []),
      metricScores: Map<String, double>.from(json['metricScores'] ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageScore': averageScore,
      'qualityRate': qualityRate,
      'totalSessions': totalSessions,
      'successfulSessions': successfulSessions,
      'improvementAreas': improvementAreas,
      'metricScores': metricScores,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  String get qualityLevel {
    if (qualityRate >= 0.9) return 'Mükemmel';
    if (qualityRate >= 0.8) return 'Çok İyi';
    if (qualityRate >= 0.7) return 'İyi';
    if (qualityRate >= 0.6) return 'Orta';
    return 'Geliştirilmeli';
  }

  Color get qualityColor {
    if (qualityRate >= 0.9) return Colors.green;
    if (qualityRate >= 0.8) return Colors.lightGreen;
    if (qualityRate >= 0.7) return Colors.orange;
    if (qualityRate >= 0.6) return Colors.deepOrange;
    return Colors.red;
  }
}

class SupervisionActivity {
  final String id;
  final SupervisionActivityType type;
  final String description;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String? sessionId;
  final String? therapistId;
  final Map<String, dynamic> metadata;

  SupervisionActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.userId,
    required this.userName,
    this.sessionId,
    this.therapistId,
    this.metadata = const {},
  });

  factory SupervisionActivity.fromJson(Map<String, dynamic> json) {
    return SupervisionActivity(
      id: json['id'],
      type: SupervisionActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      userName: json['userName'],
      sessionId: json['sessionId'],
      therapistId: json['therapistId'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'sessionId': sessionId,
      'therapistId': therapistId,
      'metadata': metadata,
    };
  }
}
