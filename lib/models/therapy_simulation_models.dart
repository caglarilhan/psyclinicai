import 'package:json_annotation/json_annotation.dart';

part 'therapy_simulation_models.g.dart';

/// Simulation Status - Simülasyon durumu
enum SimulationStatus {
  @JsonValue('not_started') notStarted,
  @JsonValue('in_progress') inProgress,
  @JsonValue('paused') paused,
  @JsonValue('completed') completed,
  @JsonValue('cancelled') cancelled,
}

/// Therapy Approach - Terapi yaklaşımı
enum TherapyApproach {
  @JsonValue('cbt') cbt,
  @JsonValue('dbt') dbt,
  @JsonValue('psychodynamic') psychodynamic,
  @JsonValue('humanistic') humanistic,
  @JsonValue('integrative') integrative,
  @JsonValue('mindfulness') mindfulness,
}

/// Role Type - Rol türü
enum RoleType {
  @JsonValue('therapist') therapist,
  @JsonValue('patient') patient,
  @JsonValue('supervisor') supervisor,
  @JsonValue('family_member') familyMember,
}

/// Feedback Type - Geri bildirim türü
enum FeedbackType {
  @JsonValue('positive') positive,
  @JsonValue('constructive') constructive,
  @JsonValue('critical') critical,
  @JsonValue('suggestion') suggestion,
}

/// Therapy Simulation Session - Terapi simülasyon seansı
@JsonSerializable()
class TherapySimulationSession {
  final String id;
  final String title;
  final String description;
  final TherapyApproach approach;
  final SimulationStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int maxDuration; // minutes
  final int currentDuration; // minutes
  final String createdBy;
  final String? patientProfile;
  final String? scenarioDescription;
  final List<String> learningObjectives;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;

  const TherapySimulationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.approach,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.maxDuration,
    required this.currentDuration,
    required this.createdBy,
    this.patientProfile,
    this.scenarioDescription,
    required this.learningObjectives,
    required this.settings,
    required this.metadata,
  });

  factory TherapySimulationSession.fromJson(Map<String, dynamic> json) =>
      _$TherapySimulationSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TherapySimulationSessionToJson(this);
}

/// Simulation Turn - Simülasyon turu
@JsonSerializable()
class SimulationTurn {
  final String id;
  final String sessionId;
  final int turnNumber;
  final RoleType role;
  final String content;
  final String? aiResponse;
  final String? userResponse;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  final Map<String, dynamic> metadata;

  const SimulationTurn({
    required this.id,
    required this.sessionId,
    required this.turnNumber,
    required this.role,
    required this.content,
    this.aiResponse,
    this.userResponse,
    required this.timestamp,
    required this.context,
    required this.metadata,
  });

  factory SimulationTurn.fromJson(Map<String, dynamic> json) =>
      _$SimulationTurnFromJson(json);

  Map<String, dynamic> toJson() => _$SimulationTurnToJson(this);
}

/// AI Response - AI yanıtı
@JsonSerializable()
class AIResponse {
  final String id;
  final String turnId;
  final String content;
  final RoleType role;
  final String? reasoning;
  final List<String> techniques;
  final Map<String, dynamic> emotions;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const AIResponse({
    required this.id,
    required this.turnId,
    required this.content,
    required this.role,
    this.reasoning,
    required this.techniques,
    required this.emotions,
    required this.metadata,
    required this.timestamp,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AIResponseToJson(this);
}

/// User Response - Kullanıcı yanıtı
@JsonSerializable()
class UserResponse {
  final String id;
  final String turnId;
  final String content;
  final RoleType role;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const UserResponse({
    required this.id,
    required this.turnId,
    required this.content,
    required this.role,
    required this.timestamp,
    required this.metadata,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

/// Simulation Feedback - Simülasyon geri bildirimi
@JsonSerializable()
class SimulationFeedback {
  final String id;
  final String sessionId;
  final String turnId;
  final FeedbackType type;
  final String content;
  final String? suggestion;
  final int rating; // 1-5
  final String? evaluatorId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const SimulationFeedback({
    required this.id,
    required this.sessionId,
    required this.turnId,
    required this.type,
    required this.content,
    this.suggestion,
    required this.rating,
    this.evaluatorId,
    required this.timestamp,
    required this.metadata,
  });

  factory SimulationFeedback.fromJson(Map<String, dynamic> json) =>
      _$SimulationFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$SimulationFeedbackToJson(this);
}

/// Simulation Metrics - Simülasyon metrikleri
@JsonSerializable()
class SimulationMetrics {
  final String id;
  final String sessionId;
  final int totalTurns;
  final int userTurns;
  final int aiTurns;
  final double averageResponseTime; // seconds
  final double engagementScore; // 0-100
  final double techniqueUsageScore; // 0-100
  final double empathyScore; // 0-100
  final List<String> strengths;
  final List<String> areasForImprovement;
  final Map<String, dynamic> detailedMetrics;
  final DateTime calculatedAt;

  const SimulationMetrics({
    required this.id,
    required this.sessionId,
    required this.totalTurns,
    required this.userTurns,
    required this.aiTurns,
    required this.averageResponseTime,
    required this.engagementScore,
    required this.techniqueUsageScore,
    required this.empathyScore,
    required this.strengths,
    required this.areasForImprovement,
    required this.detailedMetrics,
    required this.calculatedAt,
  });

  factory SimulationMetrics.fromJson(Map<String, dynamic> json) =>
      _$SimulationMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$SimulationMetricsToJson(this);
}

/// Simulation Scenario - Simülasyon senaryosu
@JsonSerializable()
class SimulationScenario {
  final String id;
  final String title;
  final String description;
  final TherapyApproach approach;
  final String difficulty; // beginner, intermediate, advanced
  final String patientProfile;
  final String scenarioDescription;
  final List<String> learningObjectives;
  final List<String> keyTechniques;
  final List<String> commonPitfalls;
  final Map<String, dynamic> initialContext;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final bool isActive;

  const SimulationScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.approach,
    required this.difficulty,
    required this.patientProfile,
    required this.scenarioDescription,
    required this.learningObjectives,
    required this.keyTechniques,
    required this.commonPitfalls,
    required this.initialContext,
    required this.metadata,
    required this.createdAt,
    required this.isActive,
  });

  factory SimulationScenario.fromJson(Map<String, dynamic> json) =>
      _$SimulationScenarioFromJson(json);

  Map<String, dynamic> toJson() => _$SimulationScenarioToJson(this);
}
