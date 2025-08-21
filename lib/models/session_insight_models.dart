import 'package:json_annotation/json_annotation.dart';

part 'session_insight_models.g.dart';

// ===== OTURUM İÇGÖRÜ MODELLERİ =====

@JsonSerializable()
class SessionInsight {
  final String id;
  final String sessionId;
  final String type;
  final String content;
  final double confidence;
  final DateTime timestamp;
  final List<String> supportingData;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  SessionInsight({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.content,
    required this.confidence,
    required this.timestamp,
    required this.supportingData,
    required this.recommendations,
    this.metadata,
  });

  factory SessionInsight.fromJson(Map<String, dynamic> json) =>
      _$SessionInsightFromJson(json);

  Map<String, dynamic> toJson() => _$SessionInsightToJson(this);
}

@JsonSerializable()
class SessionRiskAssessment {
  final String id;
  final String sessionId;
  final String riskType;
  final String severity;
  final String description;
  final List<String> indicators;
  final List<String> actions;
  final DateTime timestamp;
  final bool isActive;

  SessionRiskAssessment({
    required this.id,
    required this.sessionId,
    required this.riskType,
    required this.severity,
    required this.description,
    required this.indicators,
    required this.actions,
    required this.timestamp,
    required this.isActive,
  });

  factory SessionRiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$SessionRiskAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$SessionRiskAssessmentToJson(this);
}

@JsonSerializable()
class SessionIntervention {
  final String id;
  final String sessionId;
  final String type;
  final String description;
  final String rationale;
  final DateTime timestamp;
  final bool isImplemented;
  final String? outcome;

  SessionIntervention({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.description,
    required this.rationale,
    required this.timestamp,
    required this.isImplemented,
    this.outcome,
  });

  factory SessionIntervention.fromJson(Map<String, dynamic> json) =>
      _$SessionInterventionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionInterventionToJson(this);
}

enum InsightType {
  @JsonValue('mood_analysis')
  moodAnalysis,
  @JsonValue('behavior_pattern')
  behaviorPattern,
  @JsonValue('crisis_indicator')
  crisisIndicator,
  @JsonValue('treatment_suggestion')
  treatmentSuggestion,
  @JsonValue('progress_assessment')
  progressAssessment,
}

enum RiskSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum InterventionType {
  @JsonValue('safety_check')
  safetyCheck,
  @JsonValue('coping_strategy')
  copingStrategy,
  @JsonValue('crisis_protocol')
  crisisProtocol,
  @JsonValue('referral')
  referral,
  @JsonValue('medication_review')
  medicationReview,
}
