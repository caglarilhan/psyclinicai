import 'package:json_annotation/json_annotation.dart';

part 'case_management_models.g.dart';

/// Case Status - Vaka durumu
enum CaseStatus {
  @JsonValue('active') active,
  @JsonValue('on_hold') onHold,
  @JsonValue('completed') completed,
  @JsonValue('transferred') transferred,
  @JsonValue('discontinued') discontinued,
}

/// Priority Level - Öncelik seviyesi
enum PriorityLevel {
  @JsonValue('low') low,
  @JsonValue('medium') medium,
  @JsonValue('high') high,
  @JsonValue('urgent') urgent,
}

/// Assessment Type - Değerlendirme türü
enum AssessmentType {
  @JsonValue('initial') initial,
  @JsonValue('progress') progress,
  @JsonValue('final') final_,
  @JsonValue('crisis') crisis,
  @JsonValue('follow_up') followUp,
}

/// Progress Indicator - İlerleme göstergesi
enum ProgressIndicator {
  @JsonValue('improving') improving,
  @JsonValue('stable') stable,
  @JsonValue('declining') declining,
  @JsonValue('fluctuating') fluctuating,
}

/// Risk Level - Risk seviyesi
enum RiskLevel {
  @JsonValue('low') low,
  @JsonValue('moderate') moderate,
  @JsonValue('high') high,
  @JsonValue('critical') critical,
}

/// Case Management - Vaka yönetimi
@JsonSerializable()
class CaseManagement {
  final String id;
  final String clientId;
  final String therapistId;
  final String title;
  final String description;
  final CaseStatus status;
  final PriorityLevel priority;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? primaryDiagnosis;
  final List<String> secondaryDiagnoses;
  final List<String> treatmentGoals;
  final List<String> interventions;
  final Map<String, dynamic> clientInfo;
  final Map<String, dynamic> treatmentPlan;
  final Map<String, dynamic> metadata;
  final String? supervisorId;
  final String? notes;

  const CaseManagement({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.primaryDiagnosis,
    required this.secondaryDiagnoses,
    required this.treatmentGoals,
    required this.interventions,
    required this.clientInfo,
    required this.treatmentPlan,
    required this.metadata,
    this.supervisorId,
    this.notes,
  });

  factory CaseManagement.fromJson(Map<String, dynamic> json) =>
      _$CaseManagementFromJson(json);

  Map<String, dynamic> toJson() => _$CaseManagementToJson(this);
}

/// Case Assessment - Vaka değerlendirmesi
@JsonSerializable()
class CaseAssessment {
  final String id;
  final String caseId;
  final AssessmentType type;
  final DateTime assessmentDate;
  final String assessorId;
  final String? assessorName;
  final Map<String, dynamic> clinicalFindings;
  final Map<String, dynamic> functionalAssessment;
  final Map<String, dynamic> riskAssessment;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> recommendations;
  final ProgressIndicator progressIndicator;
  final RiskLevel riskLevel;
  final String? summary;
  final Map<String, dynamic> scores;
  final Map<String, dynamic> metadata;
  final List<String> attachments;

  const CaseAssessment({
    required this.id,
    required this.caseId,
    required this.type,
    required this.assessmentDate,
    required this.assessorId,
    this.assessorName,
    required this.clinicalFindings,
    required this.functionalAssessment,
    required this.riskAssessment,
    required this.strengths,
    required this.challenges,
    required this.recommendations,
    required this.progressIndicator,
    required this.riskLevel,
    this.summary,
    required this.scores,
    required this.metadata,
    required this.attachments,
  });

  factory CaseAssessment.fromJson(Map<String, dynamic> json) =>
      _$CaseAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$CaseAssessmentToJson(this);
}

/// Case Progress - Vaka ilerlemesi
@JsonSerializable()
class CaseProgress {
  final String id;
  final String caseId;
  final DateTime progressDate;
  final String recordedBy;
  final String? recordedByName;
  final String progressNote;
  final ProgressIndicator indicator;
  final List<String> achievedGoals;
  final List<String> newGoals;
  final List<String> interventions;
  final Map<String, dynamic> measurements;
  final Map<String, dynamic> observations;
  final String? nextSteps;
  final Map<String, dynamic> metadata;
  final List<String> relatedSessions;

  const CaseProgress({
    required this.id,
    required this.caseId,
    required this.progressDate,
    required this.recordedBy,
    this.recordedByName,
    required this.progressNote,
    required this.indicator,
    required this.achievedGoals,
    required this.newGoals,
    required this.interventions,
    required this.measurements,
    required this.observations,
    required this.nextSteps,
    required this.metadata,
    required this.relatedSessions,
  });

  factory CaseProgress.fromJson(Map<String, dynamic> json) =>
      _$CaseProgressFromJson(json);

  Map<String, dynamic> toJson() => _$CaseProgressToJson(this);
}

/// Treatment Goal - Tedavi hedefi
@JsonSerializable()
class TreatmentGoal {
  final String id;
  final String caseId;
  final String title;
  final String description;
  final String category;
  final DateTime targetDate;
  final DateTime? achievedDate;
  final bool isAchieved;
  final int priority;
  final List<String> milestones;
  final List<String> interventions;
  final Map<String, dynamic> measurements;
  final Map<String, dynamic> metadata;
  final String? notes;

  const TreatmentGoal({
    required this.id,
    required this.caseId,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    this.achievedDate,
    required this.isAchieved,
    required this.priority,
    required this.milestones,
    required this.interventions,
    required this.measurements,
    required this.metadata,
    this.notes,
  });

  factory TreatmentGoal.fromJson(Map<String, dynamic> json) =>
      _$TreatmentGoalFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentGoalToJson(this);
}

/// Case Timeline - Vaka zaman çizelgesi
@JsonSerializable()
class CaseTimeline {
  final String id;
  final String caseId;
  final DateTime eventDate;
  final String eventType;
  final String title;
  final String description;
  final String? performedBy;
  final Map<String, dynamic> eventData;
  final Map<String, dynamic> metadata;

  const CaseTimeline({
    required this.id,
    required this.caseId,
    required this.eventDate,
    required this.eventType,
    required this.title,
    required this.description,
    this.performedBy,
    required this.eventData,
    required this.metadata,
  });

  factory CaseTimeline.fromJson(Map<String, dynamic> json) =>
      _$CaseTimelineFromJson(json);

  Map<String, dynamic> toJson() => _$CaseTimelineToJson(this);
}

/// Case Summary - Vaka özeti
@JsonSerializable()
class CaseSummary {
  final String id;
  final String caseId;
  final DateTime generatedAt;
  final String generatedBy;
  final String summary;
  final Map<String, dynamic> keyMetrics;
  final List<String> achievements;
  final List<String> challenges;
  final List<String> recommendations;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic> metadata;

  const CaseSummary({
    required this.id,
    required this.caseId,
    required this.generatedAt,
    required this.generatedBy,
    required this.summary,
    required this.keyMetrics,
    required this.achievements,
    required this.challenges,
    required this.recommendations,
    required this.statistics,
    required this.metadata,
  });

  factory CaseSummary.fromJson(Map<String, dynamic> json) =>
      _$CaseSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CaseSummaryToJson(this);
}

/// Case Alert - Vaka uyarısı
@JsonSerializable()
class CaseAlert {
  final String id;
  final String caseId;
  final String alertType;
  final String title;
  final String message;
  final PriorityLevel priority;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final bool isActive;
  final Map<String, dynamic> alertData;
  final Map<String, dynamic> metadata;

  const CaseAlert({
    required this.id,
    required this.caseId,
    required this.alertType,
    required this.title,
    required this.message,
    required this.priority,
    required this.createdAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
    required this.isActive,
    required this.alertData,
    required this.metadata,
  });

  factory CaseAlert.fromJson(Map<String, dynamic> json) =>
      _$CaseAlertFromJson(json);

  Map<String, dynamic> toJson() => _$CaseAlertToJson(this);
}

/// Case Statistics - Vaka istatistikleri
@JsonSerializable()
class CaseStatistics {
  final String id;
  final String caseId;
  final DateTime calculatedAt;
  final int totalSessions;
  final int completedSessions;
  final int totalAssessments;
  final int achievedGoals;
  final int totalGoals;
  final double averageProgressScore;
  final double riskScore;
  final Map<String, dynamic> progressTrend;
  final Map<String, dynamic> goalAchievement;
  final Map<String, dynamic> interventionEffectiveness;
  final Map<String, dynamic> metadata;

  const CaseStatistics({
    required this.id,
    required this.caseId,
    required this.calculatedAt,
    required this.totalSessions,
    required this.completedSessions,
    required this.totalAssessments,
    required this.achievedGoals,
    required this.totalGoals,
    required this.averageProgressScore,
    required this.riskScore,
    required this.progressTrend,
    required this.goalAchievement,
    required this.interventionEffectiveness,
    required this.metadata,
  });

  factory CaseStatistics.fromJson(Map<String, dynamic> json) =>
      _$CaseStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$CaseStatisticsToJson(this);
}
