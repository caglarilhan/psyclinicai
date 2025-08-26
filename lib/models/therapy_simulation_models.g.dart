// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'therapy_simulation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TherapySimulationSession _$TherapySimulationSessionFromJson(
  Map<String, dynamic> json,
) => TherapySimulationSession(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  approach: $enumDecode(_$TherapyApproachEnumMap, json['approach']),
  status: $enumDecode(_$SimulationStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  maxDuration: (json['maxDuration'] as num).toInt(),
  currentDuration: (json['currentDuration'] as num).toInt(),
  createdBy: json['createdBy'] as String,
  patientProfile: json['patientProfile'] as String?,
  scenarioDescription: json['scenarioDescription'] as String?,
  learningObjectives: (json['learningObjectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  settings: json['settings'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$TherapySimulationSessionToJson(
  TherapySimulationSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'approach': _$TherapyApproachEnumMap[instance.approach]!,
  'status': _$SimulationStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'maxDuration': instance.maxDuration,
  'currentDuration': instance.currentDuration,
  'createdBy': instance.createdBy,
  'patientProfile': instance.patientProfile,
  'scenarioDescription': instance.scenarioDescription,
  'learningObjectives': instance.learningObjectives,
  'settings': instance.settings,
  'metadata': instance.metadata,
};

const _$TherapyApproachEnumMap = {
  TherapyApproach.cbt: 'cbt',
  TherapyApproach.dbt: 'dbt',
  TherapyApproach.psychodynamic: 'psychodynamic',
  TherapyApproach.humanistic: 'humanistic',
  TherapyApproach.integrative: 'integrative',
  TherapyApproach.mindfulness: 'mindfulness',
};

const _$SimulationStatusEnumMap = {
  SimulationStatus.notStarted: 'not_started',
  SimulationStatus.inProgress: 'in_progress',
  SimulationStatus.paused: 'paused',
  SimulationStatus.completed: 'completed',
  SimulationStatus.cancelled: 'cancelled',
};

SimulationTurn _$SimulationTurnFromJson(Map<String, dynamic> json) =>
    SimulationTurn(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      turnNumber: (json['turnNumber'] as num).toInt(),
      role: $enumDecode(_$RoleTypeEnumMap, json['role']),
      content: json['content'] as String,
      aiResponse: json['aiResponse'] as String?,
      userResponse: json['userResponse'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      context: json['context'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SimulationTurnToJson(SimulationTurn instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'turnNumber': instance.turnNumber,
      'role': _$RoleTypeEnumMap[instance.role]!,
      'content': instance.content,
      'aiResponse': instance.aiResponse,
      'userResponse': instance.userResponse,
      'timestamp': instance.timestamp.toIso8601String(),
      'context': instance.context,
      'metadata': instance.metadata,
    };

const _$RoleTypeEnumMap = {
  RoleType.therapist: 'therapist',
  RoleType.patient: 'patient',
  RoleType.supervisor: 'supervisor',
  RoleType.familyMember: 'family_member',
};

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) => AIResponse(
  id: json['id'] as String,
  turnId: json['turnId'] as String,
  content: json['content'] as String,
  role: $enumDecode(_$RoleTypeEnumMap, json['role']),
  reasoning: json['reasoning'] as String?,
  techniques: (json['techniques'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  emotions: json['emotions'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$AIResponseToJson(AIResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'turnId': instance.turnId,
      'content': instance.content,
      'role': _$RoleTypeEnumMap[instance.role]!,
      'reasoning': instance.reasoning,
      'techniques': instance.techniques,
      'emotions': instance.emotions,
      'metadata': instance.metadata,
      'timestamp': instance.timestamp.toIso8601String(),
    };

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
  id: json['id'] as String,
  turnId: json['turnId'] as String,
  content: json['content'] as String,
  role: $enumDecode(_$RoleTypeEnumMap, json['role']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'turnId': instance.turnId,
      'content': instance.content,
      'role': _$RoleTypeEnumMap[instance.role]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
    };

SimulationFeedback _$SimulationFeedbackFromJson(Map<String, dynamic> json) =>
    SimulationFeedback(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      turnId: json['turnId'] as String,
      type: $enumDecode(_$FeedbackTypeEnumMap, json['type']),
      content: json['content'] as String,
      suggestion: json['suggestion'] as String?,
      rating: (json['rating'] as num).toInt(),
      evaluatorId: json['evaluatorId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SimulationFeedbackToJson(SimulationFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'turnId': instance.turnId,
      'type': _$FeedbackTypeEnumMap[instance.type]!,
      'content': instance.content,
      'suggestion': instance.suggestion,
      'rating': instance.rating,
      'evaluatorId': instance.evaluatorId,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.positive: 'positive',
  FeedbackType.constructive: 'constructive',
  FeedbackType.critical: 'critical',
  FeedbackType.suggestion: 'suggestion',
};

SimulationMetrics _$SimulationMetricsFromJson(Map<String, dynamic> json) =>
    SimulationMetrics(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      totalTurns: (json['totalTurns'] as num).toInt(),
      userTurns: (json['userTurns'] as num).toInt(),
      aiTurns: (json['aiTurns'] as num).toInt(),
      averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
      engagementScore: (json['engagementScore'] as num).toDouble(),
      techniqueUsageScore: (json['techniqueUsageScore'] as num).toDouble(),
      empathyScore: (json['empathyScore'] as num).toDouble(),
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      detailedMetrics: json['detailedMetrics'] as Map<String, dynamic>,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$SimulationMetricsToJson(SimulationMetrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'totalTurns': instance.totalTurns,
      'userTurns': instance.userTurns,
      'aiTurns': instance.aiTurns,
      'averageResponseTime': instance.averageResponseTime,
      'engagementScore': instance.engagementScore,
      'techniqueUsageScore': instance.techniqueUsageScore,
      'empathyScore': instance.empathyScore,
      'strengths': instance.strengths,
      'areasForImprovement': instance.areasForImprovement,
      'detailedMetrics': instance.detailedMetrics,
      'calculatedAt': instance.calculatedAt.toIso8601String(),
    };

SimulationScenario _$SimulationScenarioFromJson(Map<String, dynamic> json) =>
    SimulationScenario(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      approach: $enumDecode(_$TherapyApproachEnumMap, json['approach']),
      difficulty: json['difficulty'] as String,
      patientProfile: json['patientProfile'] as String,
      scenarioDescription: json['scenarioDescription'] as String,
      learningObjectives: (json['learningObjectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      keyTechniques: (json['keyTechniques'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      commonPitfalls: (json['commonPitfalls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      initialContext: json['initialContext'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$SimulationScenarioToJson(SimulationScenario instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'approach': _$TherapyApproachEnumMap[instance.approach]!,
      'difficulty': instance.difficulty,
      'patientProfile': instance.patientProfile,
      'scenarioDescription': instance.scenarioDescription,
      'learningObjectives': instance.learningObjectives,
      'keyTechniques': instance.keyTechniques,
      'commonPitfalls': instance.commonPitfalls,
      'initialContext': instance.initialContext,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
    };
