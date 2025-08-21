import 'package:json_annotation/json_annotation.dart';

part 'real_time_session_models.g.dart';

// ===== GERÇEK ZAMANLI OTURUM MODELLERİ =====

@JsonSerializable()
class RealTimeSessionData {
  final String sessionId;
  final String clientId;
  final String therapistId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final List<RealTimeMetric> metrics;
  final List<SessionAlert> alerts;
  final List<AIInsight> aiInsights;
  final Map<String, dynamic>? metadata;

  RealTimeSessionData({
    required this.sessionId,
    required this.clientId,
    required this.therapistId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.metrics,
    required this.alerts,
    required this.aiInsights,
    this.metadata,
  });

  factory RealTimeSessionData.fromJson(Map<String, dynamic> json) =>
      _$RealTimeSessionDataFromJson(json);

  Map<String, dynamic> toJson() => _$RealTimeSessionDataToJson(this);
}

@JsonSerializable()
class RealTimeMetric {
  final String id;
  final String name;
  final String type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final String? threshold;
  final bool isAlert;

  RealTimeMetric({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.threshold,
    required this.isAlert,
  });

  factory RealTimeMetric.fromJson(Map<String, dynamic> json) =>
      _$RealTimeMetricFromJson(json);

  Map<String, dynamic> toJson() => _$RealTimeMetricToJson(this);
}

@JsonSerializable()
class SessionAlert {
  final String id;
  final String type;
  final String severity;
  final String message;
  final DateTime timestamp;
  final bool isActive;
  final List<String> actions;
  final Map<String, dynamic>? context;

  SessionAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.isActive,
    required this.actions,
    this.context,
  });

  factory SessionAlert.fromJson(Map<String, dynamic> json) =>
      _$SessionAlertFromJson(json);

  Map<String, dynamic> toJson() => _$SessionAlertToJson(this);
}

@JsonSerializable()
class AIInsight {
  final String id;
  final String type;
  final String content;
  final double confidence;
  final DateTime timestamp;
  final List<String> supportingData;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  AIInsight({
    required this.id,
    required this.type,
    required this.content,
    required this.confidence,
    required this.timestamp,
    required this.supportingData,
    required this.recommendations,
    this.metadata,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) =>
      _$AIInsightFromJson(json);

  Map<String, dynamic> toJson() => _$AIInsightToJson(this);
}

enum SessionStatus {
  @JsonValue('preparing')
  preparing,
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('ended')
  ended,
}

enum MetricType {
  @JsonValue('heart_rate')
  heartRate,
  @JsonValue('blood_pressure')
  bloodPressure,
  @JsonValue('mood_score')
  moodScore,
  @JsonValue('stress_level')
  stressLevel,
  @JsonValue('engagement')
  engagement,
  @JsonValue('speech_rate')
  speechRate,
  @JsonValue('voice_tone')
  voiceTone,
}

enum AlertSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum InsightType {
  @JsonValue('risk_assessment')
  riskAssessment,
  @JsonValue('mood_analysis')
  moodAnalysis,
  @JsonValue('behavior_pattern')
  behaviorPattern,
  @JsonValue('crisis_indicator')
  crisisIndicator,
  @JsonValue('treatment_suggestion')
  treatmentSuggestion,
}
