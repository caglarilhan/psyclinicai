import 'package:json_annotation/json_annotation.dart';

part 'voice_analysis_models.g.dart';

@JsonSerializable()
class VoiceAnalysisSession {
  final String id;
  final String sessionId;
  final String patientId;
  final DateTime startTime;
  final DateTime endTime;
  final VoiceEmotionData emotionData;
  final VoiceStressData stressData;
  final VoicePatternData patternData;
  final List<VoiceAlert> alerts;
  final Map<String, dynamic> metadata;

  const VoiceAnalysisSession({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.startTime,
    required this.endTime,
    required this.emotionData,
    required this.stressData,
    required this.patternData,
    this.alerts = const [],
    this.metadata = const {},
  });

  factory VoiceAnalysisSession.fromJson(Map<String, dynamic> json) => _$VoiceAnalysisSessionFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceAnalysisSessionToJson(this);
}

@JsonSerializable()
class VoiceEmotionData {
  final double happiness;
  final double sadness;
  final double anger;
  final double fear;
  final double surprise;
  final double disgust;
  final double neutral;
  final List<EmotionTimeline> timeline;
  final Map<String, dynamic> metadata;

  const VoiceEmotionData({
    required this.happiness,
    required this.sadness,
    required this.anger,
    required this.fear,
    required this.surprise,
    required this.disgust,
    required this.neutral,
    this.timeline = const [],
    this.metadata = const {},
  });

  factory VoiceEmotionData.fromJson(Map<String, dynamic> json) => _$VoiceEmotionDataFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceEmotionDataToJson(this);
}

@JsonSerializable()
class EmotionTimeline {
  final DateTime timestamp;
  final String dominantEmotion;
  final double confidence;
  final Map<String, double> emotionScores;

  const EmotionTimeline({
    required this.timestamp,
    required this.dominantEmotion,
    required this.confidence,
    required this.emotionScores,
  });

  factory EmotionTimeline.fromJson(Map<String, dynamic> json) => _$EmotionTimelineFromJson(json);
  Map<String, dynamic> toJson() => _$EmotionTimelineToJson(this);
}

@JsonSerializable()
class VoiceStressData {
  final double stressLevel;
  final StressCategory category;
  final List<StressIndicator> indicators;
  final List<StressTrigger> triggers;
  final Map<String, dynamic> metadata;

  const VoiceStressData({
    required this.stressLevel,
    required this.category,
    required this.indicators,
    required this.triggers,
    this.metadata = const {},
  });

  factory VoiceStressData.fromJson(Map<String, dynamic> json) => _$VoiceStressDataFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceStressDataToJson(this);
}

enum StressCategory {
  low,
  moderate,
  high,
  critical
}

@JsonSerializable()
class StressIndicator {
  final String type;
  final double intensity;
  final String description;
  final DateTime detectedAt;

  const StressIndicator({
    required this.type,
    required this.intensity,
    required this.description,
    required this.detectedAt,
  });

  factory StressIndicator.fromJson(Map<String, dynamic> json) => _$StressIndicatorFromJson(json);
  Map<String, dynamic> toJson() => _$StressIndicatorToJson(this);
}

@JsonSerializable()
class StressTrigger {
  final String trigger;
  final double impact;
  final String context;
  final DateTime timestamp;

  const StressTrigger({
    required this.trigger,
    required this.impact,
    required this.context,
    required this.timestamp,
  });

  factory StressTrigger.fromJson(Map<String, dynamic> json) => _$StressTriggerFromJson(json);
  Map<String, dynamic> toJson() => _$StressTriggerToJson(this);
}

@JsonSerializable()
class VoicePatternData {
  final double speakingRate;
  final double volumeVariation;
  final double pitchVariation;
  final List<SpeechPattern> patterns;
  final List<Anomaly> anomalies;
  final Map<String, dynamic> metadata;

  const VoicePatternData({
    required this.speakingRate,
    required this.volumeVariation,
    required this.pitchVariation,
    required this.patterns,
    required this.anomalies,
    this.metadata = const {},
  });

  factory VoicePatternData.fromJson(Map<String, dynamic> json) => _$VoicePatternDataFromJson(json);
  Map<String, dynamic> toJson() => _$VoicePatternDataToJson(this);
}

@JsonSerializable()
class SpeechPattern {
  final String type;
  final double frequency;
  final String description;
  final List<DateTime> occurrences;

  const SpeechPattern({
    required this.type,
    required this.frequency,
    required this.description,
    required this.occurrences,
  });

  factory SpeechPattern.fromJson(Map<String, dynamic> json) => _$SpeechPatternFromJson(json);
  Map<String, dynamic> toJson() => _$SpeechPatternToJson(this);
}

@JsonSerializable()
class Anomaly {
  final String type;
  final double severity;
  final String description;
  final DateTime detectedAt;
  final Map<String, dynamic> context;

  const Anomaly({
    required this.type,
    required this.severity,
    required this.description,
    required this.detectedAt,
    this.context = const {},
  });

  factory Anomaly.fromJson(Map<String, dynamic> json) => _$AnomalyFromJson(json);
  Map<String, dynamic> toJson() => _$AnomalyToJson(this);
}

@JsonSerializable()
class VoiceAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final bool acknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final Map<String, dynamic> metadata;

  const VoiceAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    this.acknowledged = false,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.metadata = const {},
  });

  factory VoiceAlert.fromJson(Map<String, dynamic> json) => _$VoiceAlertFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceAlertToJson(this);
}

enum AlertType {
  stressSpike,
  emotionChange,
  speechPattern,
  crisisIndicator,
  complianceIssue
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical
}

@JsonSerializable()
class VoiceAnalysisConfig {
  final bool realTimeAnalysis;
  final bool emotionDetection;
  final bool stressMonitoring;
  final bool patternAnalysis;
  final bool anomalyDetection;
  final int analysisInterval;
  final double sensitivityThreshold;
  final List<String> enabledFeatures;
  final Map<String, dynamic> metadata;

  const VoiceAnalysisConfig({
    required this.realTimeAnalysis,
    required this.emotionDetection,
    required this.stressMonitoring,
    required this.patternAnalysis,
    required this.anomalyDetection,
    required this.analysisInterval,
    required this.sensitivityThreshold,
    required this.enabledFeatures,
    this.metadata = const {},
  });

  factory VoiceAnalysisConfig.fromJson(Map<String, dynamic> json) => _$VoiceAnalysisConfigFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceAnalysisConfigToJson(this);
}

@JsonSerializable()
class VoiceAnalysisResult {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final VoiceEmotionData emotionData;
  final VoiceStressData stressData;
  final VoicePatternData patternData;
  final List<VoiceAlert> alerts;
  final double confidence;
  final Map<String, dynamic> insights;
  final Map<String, dynamic> metadata;

  const VoiceAnalysisResult({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.emotionData,
    required this.stressData,
    required this.patternData,
    required this.alerts,
    required this.confidence,
    required this.insights,
    this.metadata = const {},
  });

  factory VoiceAnalysisResult.fromJson(Map<String, dynamic> json) => _$VoiceAnalysisResultFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceAnalysisResultToJson(this);
}
