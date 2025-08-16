import 'package:json_annotation/json_annotation.dart';

part 'supervision_models.g.dart';

// Enums
enum SupervisionType {
  individual,
  group,
  caseReview,
  skillAssessment,
  supervision,
  crisisManagement,
  documentationReview
}

enum SupervisionStatus {
  pending,
  scheduled,
  inProgress,
  completed,
  cancelled,
  requiresFollowUp
}

enum PerformanceRating {
  poor,
  fair,
  good,
  veryGood,
  excellent
}

// Main Models
@JsonSerializable()
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

  const SupervisionSession({
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

  factory SupervisionSession.fromJson(Map<String, dynamic> json) =>
      _$SupervisionSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionSessionToJson(this);
}

@JsonSerializable()
class TherapistPerformance {
  final String id;
  final String therapistId;
  final String therapistName;
  final String specialization;
  final double successRate;
  final int caseCount;
  final double averageRating;
  final double improvementRate;
  final String? notes;
  final DateTime lastUpdated;

  const TherapistPerformance({
    required this.id,
    required this.therapistId,
    required this.therapistName,
    required this.specialization,
    required this.successRate,
    required this.caseCount,
    required this.averageRating,
    required this.improvementRate,
    this.notes,
    required this.lastUpdated,
  });

  factory TherapistPerformance.fromJson(Map<String, dynamic> json) =>
      _$TherapistPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$TherapistPerformanceToJson(this);
}

@JsonSerializable()
class QualityMetric {
  final String id;
  final String metricName;
  final String description;
  final String category;
  final double score;
  final String trend;
  final double? targetValue;
  final double? weight;
  final String? notes;
  final DateTime lastUpdated;

  const QualityMetric({
    required this.id,
    required this.metricName,
    required this.description,
    required this.category,
    required this.score,
    required this.trend,
    this.targetValue,
    this.weight,
    this.notes,
    required this.lastUpdated,
  });

  factory QualityMetric.fromJson(Map<String, dynamic> json) =>
      _$QualityMetricFromJson(json);

  Map<String, dynamic> toJson() => _$QualityMetricToJson(this);
}

@JsonSerializable()
class SupervisionReport {
  final String id;
  final String sessionId;
  final String supervisorId;
  final String therapistId;
  final DateTime reportDate;
  final String summary;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> recommendations;
  final PerformanceRating overallRating;
  final String? additionalNotes;
  final DateTime createdAt;

  const SupervisionReport({
    required this.id,
    required this.sessionId,
    required this.supervisorId,
    required this.therapistId,
    required this.reportDate,
    required this.summary,
    required this.strengths,
    required this.areasForImprovement,
    required this.recommendations,
    required this.overallRating,
    this.additionalNotes,
    required this.createdAt,
  });

  factory SupervisionReport.fromJson(Map<String, dynamic> json) =>
      _$SupervisionReportFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionReportToJson(this);
}

@JsonSerializable()
class SupervisionTemplate {
  final String id;
  final String name;
  final String description;
  final SupervisionType type;
  final Duration defaultDuration;
  final List<String> standardTopics;
  final List<String> standardActionItems;
  final Map<String, dynamic> aiPromptTemplate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupervisionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.defaultDuration,
    required this.standardTopics,
    required this.standardActionItems,
    required this.aiPromptTemplate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupervisionTemplate.fromJson(Map<String, dynamic> json) =>
      _$SupervisionTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionTemplateToJson(this);
}

@JsonSerializable()
class SupervisionSchedule {
  final String id;
  final String supervisorId;
  final String therapistId;
  final DateTime scheduledDate;
  final Duration duration;
  final SupervisionType type;
  final String? notes;
  final bool isRecurring;
  final String? recurrencePattern;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupervisionSchedule({
    required this.id,
    required this.supervisorId,
    required this.therapistId,
    required this.scheduledDate,
    required this.duration,
    required this.type,
    this.notes,
    required this.isRecurring,
    this.recurrencePattern,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupervisionSchedule.fromJson(Map<String, dynamic> json) =>
      _$SupervisionScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionScheduleToJson(this);
}

@JsonSerializable()
class SupervisionFeedback {
  final String id;
  final String sessionId;
  final String fromId;
  final String toId;
  final String feedbackType;
  final String content;
  final double? rating;
  final List<String>? tags;
  final bool isAnonymous;
  final DateTime createdAt;

  const SupervisionFeedback({
    required this.id,
    required this.sessionId,
    required this.fromId,
    required this.toId,
    required this.feedbackType,
    required this.content,
    this.rating,
    this.tags,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory SupervisionFeedback.fromJson(Map<String, dynamic> json) =>
      _$SupervisionFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionFeedbackToJson(this);
}

@JsonSerializable()
class SupervisionAnalytics {
  final String id;
  final String supervisorId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalSessions;
  final int completedSessions;
  final int cancelledSessions;
  final double averageSessionDuration;
  final Map<String, int> sessionsByType;
  final Map<String, double> performanceByTherapist;
  final List<String> topTopics;
  final List<String> commonActionItems;
  final DateTime generatedAt;

  const SupervisionAnalytics({
    required this.id,
    required this.supervisorId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.averageSessionDuration,
    required this.sessionsByType,
    required this.performanceByTherapist,
    required this.topTopics,
    required this.commonActionItems,
    required this.generatedAt,
  });

  factory SupervisionAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SupervisionAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionAnalyticsToJson(this);
}

@JsonSerializable()
class SupervisionGoal {
  final String id;
  final String therapistId;
  final String supervisorId;
  final String title;
  final String description;
  final DateTime targetDate;
  final String status;
  final double progress;
  final List<String> milestones;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupervisionGoal({
    required this.id,
    required this.therapistId,
    required this.supervisorId,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.status,
    required this.progress,
    required this.milestones,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupervisionGoal.fromJson(Map<String, dynamic> json) =>
      _$SupervisionGoalFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionGoalToJson(this);
}

@JsonSerializable()
class SupervisionResource {
  final String id;
  final String name;
  final String description;
  final String type;
  final String url;
  final String? filePath;
  final List<String> tags;
  final String uploadedBy;
  final DateTime uploadedAt;
  final bool isPublic;
  final int downloadCount;

  const SupervisionResource({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.url,
    this.filePath,
    required this.tags,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.isPublic,
    required this.downloadCount,
  });

  factory SupervisionResource.fromJson(Map<String, dynamic> json) =>
      _$SupervisionResourceFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionResourceToJson(this);
}
