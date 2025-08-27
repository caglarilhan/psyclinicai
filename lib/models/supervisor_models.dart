import 'package:json_annotation/json_annotation.dart';

part 'supervisor_models.g.dart';

/// Performance Level - Performans seviyesi
enum PerformanceLevel {
  @JsonValue('excellent') excellent,
  @JsonValue('good') good,
  @JsonValue('average') average,
  @JsonValue('below_average') belowAverage,
  @JsonValue('poor') poor,
}

/// Evaluation Status - Değerlendirme durumu
enum EvaluationStatus {
  @JsonValue('pending') pending,
  @JsonValue('in_progress') inProgress,
  @JsonValue('completed') completed,
  @JsonValue('reviewed') reviewed,
  @JsonValue('approved') approved,
}

/// Session Quality - Seans kalitesi
enum SessionQuality {
  @JsonValue('excellent') excellent,
  @JsonValue('good') good,
  @JsonValue('adequate') adequate,
  @JsonValue('needs_improvement') needsImprovement,
  @JsonValue('poor') poor,
}

/// Supervision Type - Süpervizyon türü
enum SupervisionType {
  @JsonValue('individual') individual,
  @JsonValue('group') group,
  @JsonValue('peer') peer,
  @JsonValue('case_review') caseReview,
  @JsonValue('live_supervision') liveSupervision,
}

/// Therapist Performance - Terapist performansı
@JsonSerializable()
class TherapistPerformance {
  final String id;
  final String therapistId;
  final String therapistName;
  final DateTime evaluationPeriod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final PerformanceLevel overallLevel;
  final double overallScore; // 0-100
  final Map<String, double> categoryScores;
  final Map<String, dynamic> metrics;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> recommendations;
  final String? supervisorNotes;
  final String? therapistNotes;
  final Map<String, dynamic> metadata;

  const TherapistPerformance({
    required this.id,
    required this.therapistId,
    required this.therapistName,
    required this.evaluationPeriod,
    required this.createdAt,
    this.updatedAt,
    required this.overallLevel,
    required this.overallScore,
    required this.categoryScores,
    required this.metrics,
    required this.strengths,
    required this.areasForImprovement,
    required this.recommendations,
    this.supervisorNotes,
    this.therapistNotes,
    required this.metadata,
  });

  factory TherapistPerformance.fromJson(Map<String, dynamic> json) =>
      _$TherapistPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$TherapistPerformanceToJson(this);
}

/// Session Evaluation - Seans değerlendirmesi
@JsonSerializable()
class SessionEvaluation {
  final String id;
  final String sessionId;
  final String therapistId;
  final String therapistName;
  final String clientId;
  final String clientName;
  final DateTime sessionDate;
  final DateTime evaluationDate;
  final String evaluatorId;
  final String? evaluatorName;
  final SessionQuality quality;
  final double qualityScore; // 0-100
  final int sessionDuration; // minutes
  final int plannedDuration; // minutes
  final bool isOnTime;
  final bool isComplete;
  final Map<String, double> skillScores;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> recommendations;
  final String? evaluatorNotes;
  final String? therapistNotes;
  final EvaluationStatus status;
  final Map<String, dynamic> metadata;

  const SessionEvaluation({
    required this.id,
    required this.sessionId,
    required this.therapistId,
    required this.therapistName,
    required this.clientId,
    required this.clientName,
    required this.sessionDate,
    required this.evaluationDate,
    required this.evaluatorId,
    this.evaluatorName,
    required this.quality,
    required this.qualityScore,
    required this.sessionDuration,
    required this.plannedDuration,
    required this.isOnTime,
    required this.isComplete,
    required this.skillScores,
    required this.strengths,
    required this.areasForImprovement,
    required this.recommendations,
    this.evaluatorNotes,
    this.therapistNotes,
    required this.status,
    required this.metadata,
  });

  factory SessionEvaluation.fromJson(Map<String, dynamic> json) =>
      _$SessionEvaluationFromJson(json);

  Map<String, dynamic> toJson() => _$SessionEvaluationToJson(this);
}

/// AI Evaluation - AI değerlendirmesi
@JsonSerializable()
class AIEvaluation {
  final String id;
  final String sessionId;
  final String therapistId;
  final DateTime evaluationDate;
  final String aiModel;
  final String aiVersion;
  final double confidenceScore; // 0-1
  final Map<String, double> skillAssessments;
  final Map<String, double> techniqueEvaluations;
  final Map<String, double> interventionScores;
  final List<String> detectedStrengths;
  final List<String> detectedAreasForImprovement;
  final List<String> aiRecommendations;
  final String aiAnalysis;
  final Map<String, dynamic> rawAnalysis;
  final bool isReviewed;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final Map<String, dynamic> metadata;

  const AIEvaluation({
    required this.id,
    required this.sessionId,
    required this.therapistId,
    required this.evaluationDate,
    required this.aiModel,
    required this.aiVersion,
    required this.confidenceScore,
    required this.skillAssessments,
    required this.techniqueEvaluations,
    required this.interventionScores,
    required this.detectedStrengths,
    required this.detectedAreasForImprovement,
    required this.aiRecommendations,
    required this.aiAnalysis,
    required this.rawAnalysis,
    required this.isReviewed,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    required this.metadata,
  });

  factory AIEvaluation.fromJson(Map<String, dynamic> json) =>
      _$AIEvaluationFromJson(json);

  Map<String, dynamic> toJson() => _$AIEvaluationToJson(this);
}

/// Supervision Session - Süpervizyon seansı
@JsonSerializable()
class SupervisionSession {
  final String id;
  final String supervisorId;
  final String supervisorName;
  final List<String> therapistIds;
  final List<String> therapistNames;
  final SupervisionType type;
  final DateTime scheduledDate;
  final DateTime? actualDate;
  final int plannedDuration; // minutes
  final int actualDuration; // minutes
  final String? location;
  final String? agenda;
  final List<String> discussionTopics;
  final List<String> actionItems;
  final String? supervisorNotes;
  final List<String> therapistNotes;
  final EvaluationStatus status;
  final Map<String, dynamic> metadata;
  final List<String> attachments;

  const SupervisionSession({
    required this.id,
    required this.supervisorId,
    required this.supervisorName,
    required this.therapistIds,
    required this.therapistNames,
    required this.type,
    required this.scheduledDate,
    this.actualDate,
    required this.plannedDuration,
    required this.actualDuration,
    this.location,
    this.agenda,
    required this.discussionTopics,
    required this.actionItems,
    this.supervisorNotes,
    required this.therapistNotes,
    required this.status,
    required this.metadata,
    required this.attachments,
  });

  factory SupervisionSession.fromJson(Map<String, dynamic> json) =>
      _$SupervisionSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisionSessionToJson(this);
}

/// Performance Metrics - Performans metrikleri
@JsonSerializable()
class PerformanceMetrics {
  final String id;
  final String therapistId;
  final DateTime calculationDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalSessions;
  final int completedSessions;
  final int cancelledSessions;
  final int noShowSessions;
  final double averageSessionDuration; // minutes
  final double onTimeRate; // percentage
  final double completionRate; // percentage
  final double averageQualityScore; // 0-100
  final Map<String, double> skillAverages;
  final Map<String, int> techniqueUsage;
  final Map<String, double> interventionEffectiveness;
  final int totalClients;
  final int activeClients;
  final int dischargedClients;
  final double clientSatisfactionScore; // 0-100
  final Map<String, dynamic> detailedMetrics;
  final Map<String, dynamic> metadata;

  const PerformanceMetrics({
    required this.id,
    required this.therapistId,
    required this.calculationDate,
    required this.periodStart,
    required this.periodEnd,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.noShowSessions,
    required this.averageSessionDuration,
    required this.onTimeRate,
    required this.completionRate,
    required this.averageQualityScore,
    required this.skillAverages,
    required this.techniqueUsage,
    required this.interventionEffectiveness,
    required this.totalClients,
    required this.activeClients,
    required this.dischargedClients,
    required this.clientSatisfactionScore,
    required this.detailedMetrics,
    required this.metadata,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceMetricsToJson(this);
}

/// Development Plan - Gelişim planı
@JsonSerializable()
class DevelopmentPlan {
  final String id;
  final String therapistId;
  final String therapistName;
  final DateTime createdDate;
  final DateTime? targetDate;
  final String supervisorId;
  final String? supervisorName;
  final List<String> goals;
  final List<String> actionSteps;
  final List<String> resources;
  final List<String> milestones;
  final Map<String, DateTime> milestoneDates;
  final List<String> completedActions;
  final List<String> completedMilestones;
  final double progressPercentage;
  final String? supervisorNotes;
  final String? therapistNotes;
  final EvaluationStatus status;
  final Map<String, dynamic> metadata;

  const DevelopmentPlan({
    required this.id,
    required this.therapistId,
    required this.therapistName,
    required this.createdDate,
    this.targetDate,
    required this.supervisorId,
    this.supervisorName,
    required this.goals,
    required this.actionSteps,
    required this.resources,
    required this.milestones,
    required this.milestoneDates,
    required this.completedActions,
    required this.completedMilestones,
    required this.progressPercentage,
    this.supervisorNotes,
    this.therapistNotes,
    required this.status,
    required this.metadata,
  });

  factory DevelopmentPlan.fromJson(Map<String, dynamic> json) =>
      _$DevelopmentPlanFromJson(json);

  Map<String, dynamic> toJson() => _$DevelopmentPlanToJson(this);
}

/// Performance Report - Performans raporu
@JsonSerializable()
class PerformanceReport {
  final String id;
  final String therapistId;
  final String therapistName;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String generatedBy;
  final PerformanceLevel overallLevel;
  final double overallScore;
  final Map<String, double> categoryBreakdown;
  final List<String> keyAchievements;
  final List<String> areasForImprovement;
  final List<String> recommendations;
  final Map<String, dynamic> statistics;
  final List<String> strengths;
  final List<String> challenges;
  final String summary;
  final Map<String, dynamic> metadata;
  final List<String> attachments;

  const PerformanceReport({
    required this.id,
    required this.therapistId,
    required this.therapistName,
    required this.reportDate,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedBy,
    required this.overallLevel,
    required this.overallScore,
    required this.categoryBreakdown,
    required this.keyAchievements,
    required this.areasForImprovement,
    required this.recommendations,
    required this.statistics,
    required this.strengths,
    required this.challenges,
    required this.summary,
    required this.metadata,
    required this.attachments,
  });

  factory PerformanceReport.fromJson(Map<String, dynamic> json) =>
      _$PerformanceReportFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceReportToJson(this);
}

/// Team Performance - Takım performansı
@JsonSerializable()
class TeamPerformance {
  final String id;
  final String teamId;
  final String teamName;
  final DateTime evaluationDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<String> therapistIds;
  final List<String> therapistNames;
  final double teamAverageScore;
  final PerformanceLevel teamLevel;
  final Map<String, double> categoryAverages;
  final List<String> teamStrengths;
  final List<String> teamChallenges;
  final List<String> teamRecommendations;
  final Map<String, dynamic> individualScores;
  final Map<String, dynamic> comparativeMetrics;
  final String? supervisorNotes;
  final Map<String, dynamic> metadata;

  const TeamPerformance({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.evaluationDate,
    required this.periodStart,
    required this.periodEnd,
    required this.therapistIds,
    required this.therapistNames,
    required this.teamAverageScore,
    required this.teamLevel,
    required this.categoryAverages,
    required this.teamStrengths,
    required this.teamChallenges,
    required this.teamRecommendations,
    required this.individualScores,
    required this.comparativeMetrics,
    this.supervisorNotes,
    required this.metadata,
  });

  factory TeamPerformance.fromJson(Map<String, dynamic> json) =>
      _$TeamPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$TeamPerformanceToJson(this);
}
