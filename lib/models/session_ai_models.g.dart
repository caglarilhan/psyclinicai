// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealTimeSessionAnalysis _$RealTimeSessionAnalysisFromJson(
  Map<String, dynamic> json,
) => RealTimeSessionAnalysis(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  phase: $enumDecode(_$SessionPhaseEnumMap, json['phase']),
  emotionalStates: (json['emotionalStates'] as List<dynamic>)
      .map((e) => EmotionalState.fromJson(e as Map<String, dynamic>))
      .toList(),
  riskIndicators: (json['riskIndicators'] as List<dynamic>)
      .map((e) => RiskIndicator.fromJson(e as Map<String, dynamic>))
      .toList(),
  interventionSuggestions: (json['interventionSuggestions'] as List<dynamic>)
      .map((e) => InterventionSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
  insights: (json['insights'] as List<dynamic>)
      .map((e) => SessionInsight.fromJson(e as Map<String, dynamic>))
      .toList(),
  progress: SessionProgress.fromJson(json['progress'] as Map<String, dynamic>),
  alerts: (json['alerts'] as List<dynamic>)
      .map((e) => Alert.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RealTimeSessionAnalysisToJson(
  RealTimeSessionAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'clientId': instance.clientId,
  'therapistId': instance.therapistId,
  'timestamp': instance.timestamp.toIso8601String(),
  'phase': _$SessionPhaseEnumMap[instance.phase]!,
  'emotionalStates': instance.emotionalStates,
  'riskIndicators': instance.riskIndicators,
  'interventionSuggestions': instance.interventionSuggestions,
  'insights': instance.insights,
  'progress': instance.progress,
  'alerts': instance.alerts,
  'metadata': instance.metadata,
};

const _$SessionPhaseEnumMap = {
  SessionPhase.introduction: 'introduction',
  SessionPhase.exploration: 'exploration',
  SessionPhase.intervention: 'intervention',
  SessionPhase.integration: 'integration',
  SessionPhase.closure: 'closure',
  SessionPhase.followUp: 'followUp',
};

EmotionalState _$EmotionalStateFromJson(Map<String, dynamic> json) =>
    EmotionalState(
      id: json['id'] as String,
      emotion: $enumDecode(_$EmotionTypeEnumMap, json['emotion']),
      intensity: (json['intensity'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      trigger: json['trigger'] as String,
      physicalSigns: (json['physicalSigns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      behavioralSigns: (json['behavioralSigns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      context: json['context'] as String,
    );

Map<String, dynamic> _$EmotionalStateToJson(EmotionalState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emotion': _$EmotionTypeEnumMap[instance.emotion]!,
      'intensity': instance.intensity,
      'confidence': instance.confidence,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'trigger': instance.trigger,
      'physicalSigns': instance.physicalSigns,
      'behavioralSigns': instance.behavioralSigns,
      'context': instance.context,
    };

const _$EmotionTypeEnumMap = {
  EmotionType.joy: 'joy',
  EmotionType.sadness: 'sadness',
  EmotionType.anger: 'anger',
  EmotionType.fear: 'fear',
  EmotionType.surprise: 'surprise',
  EmotionType.disgust: 'disgust',
  EmotionType.anxiety: 'anxiety',
  EmotionType.depression: 'depression',
  EmotionType.excitement: 'excitement',
  EmotionType.calm: 'calm',
  EmotionType.confusion: 'confusion',
  EmotionType.frustration: 'frustration',
  EmotionType.hope: 'hope',
  EmotionType.despair: 'despair',
  EmotionType.love: 'love',
  EmotionType.hate: 'hate',
  EmotionType.guilt: 'guilt',
  EmotionType.shame: 'shame',
  EmotionType.pride: 'pride',
  EmotionType.envy: 'envy',
};

RiskIndicator _$RiskIndicatorFromJson(Map<String, dynamic> json) =>
    RiskIndicator(
      id: json['id'] as String,
      type: $enumDecode(_$RiskTypeEnumMap, json['type']),
      severity: $enumDecode(_$RiskSeverityEnumMap, json['severity']),
      description: json['description'] as String,
      evidence: (json['evidence'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      recommendedAction: json['recommendedAction'] as String,
      requiresImmediateAttention: json['requiresImmediateAttention'] as bool,
    );

Map<String, dynamic> _$RiskIndicatorToJson(RiskIndicator instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$RiskTypeEnumMap[instance.type]!,
      'severity': _$RiskSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'evidence': instance.evidence,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'confidence': instance.confidence,
      'recommendedAction': instance.recommendedAction,
      'requiresImmediateAttention': instance.requiresImmediateAttention,
    };

const _$RiskTypeEnumMap = {
  RiskType.selfHarm: 'selfHarm',
  RiskType.harmToOthers: 'harmToOthers',
  RiskType.substanceAbuse: 'substanceAbuse',
  RiskType.domesticViolence: 'domesticViolence',
  RiskType.suicidalThoughts: 'suicidalThoughts',
  RiskType.psychoticSymptoms: 'psychoticSymptoms',
  RiskType.severeDepression: 'severeDepression',
  RiskType.anxietyCrisis: 'anxietyCrisis',
  RiskType.medicationNonCompliance: 'medicationNonCompliance',
  RiskType.socialIsolation: 'socialIsolation',
  RiskType.financialCrisis: 'financialCrisis',
  RiskType.legalIssues: 'legalIssues',
};

const _$RiskSeverityEnumMap = {
  RiskSeverity.low: 'low',
  RiskSeverity.medium: 'medium',
  RiskSeverity.high: 'high',
  RiskSeverity.critical: 'critical',
};

InterventionSuggestion _$InterventionSuggestionFromJson(
  Map<String, dynamic> json,
) => InterventionSuggestion(
  id: json['id'] as String,
  type: $enumDecode(_$InterventionTypeEnumMap, json['type']),
  title: json['title'] as String,
  description: json['description'] as String,
  rationale: json['rationale'] as String,
  techniques: (json['techniques'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  resources: (json['resources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
  timing: $enumDecode(_$InterventionTimingEnumMap, json['timing']),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  expectedOutcome: json['expectedOutcome'] as String,
);

Map<String, dynamic> _$InterventionSuggestionToJson(
  InterventionSuggestion instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$InterventionTypeEnumMap[instance.type]!,
  'title': instance.title,
  'description': instance.description,
  'rationale': instance.rationale,
  'techniques': instance.techniques,
  'resources': instance.resources,
  'confidence': instance.confidence,
  'timing': _$InterventionTimingEnumMap[instance.timing]!,
  'contraindications': instance.contraindications,
  'expectedOutcome': instance.expectedOutcome,
};

const _$InterventionTypeEnumMap = {
  InterventionType.cognitive: 'cognitive',
  InterventionType.behavioral: 'behavioral',
  InterventionType.emotional: 'emotional',
  InterventionType.interpersonal: 'interpersonal',
  InterventionType.mindfulness: 'mindfulness',
  InterventionType.relaxation: 'relaxation',
  InterventionType.crisis: 'crisis',
  InterventionType.psychoeducation: 'psychoeducation',
  InterventionType.referral: 'referral',
  InterventionType.medication: 'medication',
};

const _$InterventionTimingEnumMap = {
  InterventionTiming.immediate: 'immediate',
  InterventionTiming.duringSession: 'duringSession',
  InterventionTiming.afterSession: 'afterSession',
  InterventionTiming.nextSession: 'nextSession',
  InterventionTiming.ongoing: 'ongoing',
};

SessionInsight _$SessionInsightFromJson(Map<String, dynamic> json) =>
    SessionInsight(
      id: json['id'] as String,
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      supportingEvidence: (json['supportingEvidence'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalRelevance: json['clinicalRelevance'] as String,
      relatedTopics: (json['relatedTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActionable: json['isActionable'] as bool,
    );

Map<String, dynamic> _$SessionInsightToJson(SessionInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$InsightTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'confidence': instance.confidence,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'supportingEvidence': instance.supportingEvidence,
      'clinicalRelevance': instance.clinicalRelevance,
      'relatedTopics': instance.relatedTopics,
      'isActionable': instance.isActionable,
    };

const _$InsightTypeEnumMap = {
  InsightType.pattern: 'pattern',
  InsightType.connection: 'connection',
  InsightType.breakthrough: 'breakthrough',
  InsightType.obstacle: 'obstacle',
  InsightType.strength: 'strength',
  InsightType.vulnerability: 'vulnerability',
  InsightType.relationship: 'relationship',
  InsightType.behavior: 'behavior',
  InsightType.thought: 'thought',
  InsightType.emotion: 'emotion',
};

SessionProgress _$SessionProgressFromJson(Map<String, dynamic> json) =>
    SessionProgress(
      id: json['id'] as String,
      overallProgress: (json['overallProgress'] as num).toDouble(),
      goalProgress: (json['goalProgress'] as List<dynamic>)
          .map((e) => GoalProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
          .toList(),
      breakthroughs: (json['breakthroughs'] as List<dynamic>)
          .map((e) => Breakthrough.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextSteps: json['nextSteps'] as String,
      lastAssessment: DateTime.parse(json['lastAssessment'] as String),
    );

Map<String, dynamic> _$SessionProgressToJson(SessionProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'overallProgress': instance.overallProgress,
      'goalProgress': instance.goalProgress,
      'milestones': instance.milestones,
      'challenges': instance.challenges,
      'breakthroughs': instance.breakthroughs,
      'nextSteps': instance.nextSteps,
      'lastAssessment': instance.lastAssessment.toIso8601String(),
    };

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
  id: json['id'] as String,
  type: $enumDecode(_$AlertTypeEnumMap, json['type']),
  priority: $enumDecode(_$AlertPriorityEnumMap, json['priority']),
  title: json['title'] as String,
  description: json['description'] as String,
  triggeredAt: DateTime.parse(json['triggeredAt'] as String),
  isAcknowledged: json['isAcknowledged'] as bool,
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  acknowledgedBy: json['acknowledgedBy'] as String?,
  recommendedActions: (json['recommendedActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiresEscalation: json['requiresEscalation'] as bool,
);

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$AlertTypeEnumMap[instance.type]!,
  'priority': _$AlertPriorityEnumMap[instance.priority]!,
  'title': instance.title,
  'description': instance.description,
  'triggeredAt': instance.triggeredAt.toIso8601String(),
  'isAcknowledged': instance.isAcknowledged,
  'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
  'acknowledgedBy': instance.acknowledgedBy,
  'recommendedActions': instance.recommendedActions,
  'requiresEscalation': instance.requiresEscalation,
};

const _$AlertTypeEnumMap = {
  AlertType.risk: 'risk',
  AlertType.crisis: 'crisis',
  AlertType.progress: 'progress',
  AlertType.technique: 'technique',
  AlertType.reminder: 'reminder',
  AlertType.warning: 'warning',
  AlertType.information: 'information',
};

const _$AlertPriorityEnumMap = {
  AlertPriority.low: 'low',
  AlertPriority.medium: 'medium',
  AlertPriority.high: 'high',
  AlertPriority.critical: 'critical',
};

GoalProgress _$GoalProgressFromJson(Map<String, dynamic> json) => GoalProgress(
  id: json['id'] as String,
  goalId: json['goalId'] as String,
  goalTitle: json['goalTitle'] as String,
  progress: (json['progress'] as num).toDouble(),
  achievements: (json['achievements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  obstacles: (json['obstacles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$GoalProgressToJson(GoalProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'goalTitle': instance.goalTitle,
      'progress': instance.progress,
      'achievements': instance.achievements,
      'obstacles': instance.obstacles,
      'status': instance.status,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

Milestone _$MilestoneFromJson(Map<String, dynamic> json) => Milestone(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  achievedAt: DateTime.parse(json['achievedAt'] as String),
  significance: (json['significance'] as num).toDouble(),
  contributingFactors: (json['contributingFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  celebrationNote: json['celebrationNote'] as String,
);

Map<String, dynamic> _$MilestoneToJson(Milestone instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'achievedAt': instance.achievedAt.toIso8601String(),
  'significance': instance.significance,
  'contributingFactors': instance.contributingFactors,
  'celebrationNote': instance.celebrationNote,
};

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$ChallengeTypeEnumMap, json['type']),
  difficulty: (json['difficulty'] as num).toDouble(),
  copingStrategies: (json['copingStrategies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  currentStatus: json['currentStatus'] as String,
  identifiedAt: DateTime.parse(json['identifiedAt'] as String),
);

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$ChallengeTypeEnumMap[instance.type]!,
  'difficulty': instance.difficulty,
  'copingStrategies': instance.copingStrategies,
  'currentStatus': instance.currentStatus,
  'identifiedAt': instance.identifiedAt.toIso8601String(),
};

const _$ChallengeTypeEnumMap = {
  ChallengeType.emotional: 'emotional',
  ChallengeType.cognitive: 'cognitive',
  ChallengeType.behavioral: 'behavioral',
  ChallengeType.interpersonal: 'interpersonal',
  ChallengeType.environmental: 'environmental',
  ChallengeType.physical: 'physical',
  ChallengeType.financial: 'financial',
  ChallengeType.social: 'social',
};

Breakthrough _$BreakthroughFromJson(Map<String, dynamic> json) => Breakthrough(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  significance: (json['significance'] as num).toDouble(),
  contributingFactors: (json['contributingFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  impact: json['impact'] as String,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  celebrationNote: json['celebrationNote'] as String,
);

Map<String, dynamic> _$BreakthroughToJson(Breakthrough instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'significance': instance.significance,
      'contributingFactors': instance.contributingFactors,
      'impact': instance.impact,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'celebrationNote': instance.celebrationNote,
    };
