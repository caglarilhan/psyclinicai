import 'package:json_annotation/json_annotation.dart';

part 'session_ai_models.g.dart';

@JsonSerializable()
class RealTimeSessionAnalysis {
  final String id;
  final String sessionId;
  final String clientId;
  final String therapistId;
  final DateTime timestamp;
  final SessionPhase phase;
  final List<EmotionalState> emotionalStates;
  final List<RiskIndicator> riskIndicators;
  final List<InterventionSuggestion> interventionSuggestions;
  final List<SessionInsight> insights;
  final SessionProgress progress;
  final List<Alert> alerts;
  final Map<String, dynamic> metadata;

  const RealTimeSessionAnalysis({
    required this.id,
    required this.sessionId,
    required this.clientId,
    required this.therapistId,
    required this.timestamp,
    required this.phase,
    required this.emotionalStates,
    required this.riskIndicators,
    required this.interventionSuggestions,
    required this.insights,
    required this.progress,
    required this.alerts,
    required this.metadata,
  });

  factory RealTimeSessionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$RealTimeSessionAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$RealTimeSessionAnalysisToJson(this);

  bool get hasHighRisk => riskIndicators.any((r) => r.severity == RiskSeverity.high || r.severity == RiskSeverity.critical);
  bool get needsImmediateAttention => alerts.any((a) => a.priority == AlertPriority.critical);
}

@JsonSerializable()
class EmotionalState {
  final String id;
  final EmotionType emotion;
  final double intensity;
  final double confidence;
  final DateTime detectedAt;
  final String trigger;
  final List<String> physicalSigns;
  final List<String> behavioralSigns;
  final String context;

  const EmotionalState({
    required this.id,
    required this.emotion,
    required this.intensity,
    required this.confidence,
    required this.detectedAt,
    required this.trigger,
    required this.physicalSigns,
    required this.behavioralSigns,
    required this.context,
  });

  factory EmotionalState.fromJson(Map<String, dynamic> json) =>
      _$EmotionalStateFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionalStateToJson(this);

  bool get isHighIntensity => intensity > 0.7;
  bool get isReliable => confidence > 0.8;
}

@JsonSerializable()
class RiskIndicator {
  final String id;
  final RiskType type;
  final RiskSeverity severity;
  final String description;
  final List<String> evidence;
  final DateTime detectedAt;
  final double confidence;
  final String recommendedAction;
  final bool requiresImmediateAttention;

  const RiskIndicator({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.evidence,
    required this.detectedAt,
    required this.confidence,
    required this.recommendedAction,
    required this.requiresImmediateAttention,
  });

  factory RiskIndicator.fromJson(Map<String, dynamic> json) =>
      _$RiskIndicatorFromJson(json);

  Map<String, dynamic> toJson() => _$RiskIndicatorToJson(this);
}

@JsonSerializable()
class InterventionSuggestion {
  final String id;
  final InterventionType type;
  final String title;
  final String description;
  final String rationale;
  final List<String> techniques;
  final List<String> resources;
  final double confidence;
  final InterventionTiming timing;
  final List<String> contraindications;
  final String expectedOutcome;

  const InterventionSuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.rationale,
    required this.techniques,
    required this.resources,
    required this.confidence,
    required this.timing,
    required this.contraindications,
    required this.expectedOutcome,
  });

  factory InterventionSuggestion.fromJson(Map<String, dynamic> json) =>
      _$InterventionSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$InterventionSuggestionToJson(this);
}

@JsonSerializable()
class SessionInsight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final double confidence;
  final DateTime generatedAt;
  final List<String> supportingEvidence;
  final String clinicalRelevance;
  final List<String> relatedTopics;
  final bool isActionable;

  const SessionInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.generatedAt,
    required this.supportingEvidence,
    required this.clinicalRelevance,
    required this.relatedTopics,
    required this.isActionable,
  });

  factory SessionInsight.fromJson(Map<String, dynamic> json) =>
      _$SessionInsightFromJson(json);

  Map<String, dynamic> toJson() => _$SessionInsightToJson(this);
}

@JsonSerializable()
class SessionProgress {
  final String id;
  final double overallProgress;
  final List<GoalProgress> goalProgress;
  final List<Milestone> milestones;
  final List<Challenge> challenges;
  final List<Breakthrough> breakthroughs;
  final String nextSteps;
  final DateTime lastAssessment;

  const SessionProgress({
    required this.id,
    required this.overallProgress,
    required this.goalProgress,
    required this.milestones,
    required this.challenges,
    required this.breakthroughs,
    required this.nextSteps,
    required this.lastAssessment,
  });

  factory SessionProgress.fromJson(Map<String, dynamic> json) =>
      _$SessionProgressFromJson(json);

  Map<String, dynamic> toJson() => _$SessionProgressToJson(this);
}

@JsonSerializable()
class Alert {
  final String id;
  final AlertType type;
  final AlertPriority priority;
  final String title;
  final String description;
  final DateTime triggeredAt;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final List<String> recommendedActions;
  final bool requiresEscalation;

  const Alert({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.triggeredAt,
    required this.isAcknowledged,
    this.acknowledgedAt,
    this.acknowledgedBy,
    required this.recommendedActions,
    required this.requiresEscalation,
  });

  factory Alert.fromJson(Map<String, dynamic> json) =>
      _$AlertFromJson(json);

  Map<String, dynamic> toJson() => _$AlertToJson(this);
}

@JsonSerializable()
class GoalProgress {
  final String id;
  final String goalId;
  final String goalTitle;
  final double progress;
  final List<String> achievements;
  final List<String> obstacles;
  final String status;
  final DateTime lastUpdated;

  const GoalProgress({
    required this.id,
    required this.goalId,
    required this.goalTitle,
    required this.progress,
    required this.achievements,
    required this.obstacles,
    required this.status,
    required this.lastUpdated,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) =>
      _$GoalProgressFromJson(json);

  Map<String, dynamic> toJson() => _$GoalProgressToJson(this);
}

@JsonSerializable()
class Milestone {
  final String id;
  final String title;
  final String description;
  final DateTime achievedAt;
  final double significance;
  final List<String> contributingFactors;
  final String celebrationNote;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.achievedAt,
    required this.significance,
    required this.contributingFactors,
    required this.celebrationNote,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);

  Map<String, dynamic> toJson() => _$MilestoneToJson(this);
}

@JsonSerializable()
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final double difficulty;
  final List<String> copingStrategies;
  final String currentStatus;
  final DateTime identifiedAt;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.copingStrategies,
    required this.currentStatus,
    required this.identifiedAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeToJson(this);
}

@JsonSerializable()
class Breakthrough {
  final String id;
  final String title;
  final String description;
  final double significance;
  final List<String> contributingFactors;
  final String impact;
  final DateTime occurredAt;
  final String celebrationNote;

  const Breakthrough({
    required this.id,
    required this.title,
    required this.description,
    required this.significance,
    required this.contributingFactors,
    required this.impact,
    required this.occurredAt,
    required this.celebrationNote,
  });

  factory Breakthrough.fromJson(Map<String, dynamic> json) =>
      _$BreakthroughFromJson(json);

  Map<String, dynamic> toJson() => _$BreakthroughToJson(this);
}

// Enums
enum SessionPhase {
  introduction,
  exploration,
  intervention,
  integration,
  closure,
  followUp,
}

enum EmotionType {
  joy,
  sadness,
  anger,
  fear,
  surprise,
  disgust,
  anxiety,
  depression,
  excitement,
  calm,
  confusion,
  frustration,
  hope,
  despair,
  love,
  hate,
  guilt,
  shame,
  pride,
  envy,
}

enum RiskType {
  selfHarm,
  harmToOthers,
  substanceAbuse,
  domesticViolence,
  suicidalThoughts,
  psychoticSymptoms,
  severeDepression,
  anxietyCrisis,
  medicationNonCompliance,
  socialIsolation,
  financialCrisis,
  legalIssues,
}

enum RiskSeverity {
  low,
  medium,
  high,
  critical,
}

enum InterventionType {
  cognitive,
  behavioral,
  emotional,
  interpersonal,
  mindfulness,
  relaxation,
  crisis,
  psychoeducation,
  referral,
  medication,
}

enum InterventionTiming {
  immediate,
  duringSession,
  afterSession,
  nextSession,
  ongoing,
}

enum InsightType {
  pattern,
  connection,
  breakthrough,
  obstacle,
  strength,
  vulnerability,
  relationship,
  behavior,
  thought,
  emotion,
}

enum AlertType {
  risk,
  crisis,
  progress,
  technique,
  reminder,
  warning,
  information,
}

enum AlertPriority {
  low,
  medium,
  high,
  critical,
}

enum ChallengeType {
  emotional,
  cognitive,
  behavioral,
  interpersonal,
  environmental,
  physical,
  financial,
  social,
}
