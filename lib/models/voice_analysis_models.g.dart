// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_analysis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoiceAnalysisSession _$VoiceAnalysisSessionFromJson(
  Map<String, dynamic> json,
) => VoiceAnalysisSession(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  patientId: json['patientId'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  emotionData: VoiceEmotionData.fromJson(
    json['emotionData'] as Map<String, dynamic>,
  ),
  stressData: VoiceStressData.fromJson(
    json['stressData'] as Map<String, dynamic>,
  ),
  patternData: VoicePatternData.fromJson(
    json['patternData'] as Map<String, dynamic>,
  ),
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => VoiceAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$VoiceAnalysisSessionToJson(
  VoiceAnalysisSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'patientId': instance.patientId,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'emotionData': instance.emotionData,
  'stressData': instance.stressData,
  'patternData': instance.patternData,
  'alerts': instance.alerts,
  'metadata': instance.metadata,
};

VoiceEmotionData _$VoiceEmotionDataFromJson(Map<String, dynamic> json) =>
    VoiceEmotionData(
      happiness: (json['happiness'] as num).toDouble(),
      sadness: (json['sadness'] as num).toDouble(),
      anger: (json['anger'] as num).toDouble(),
      fear: (json['fear'] as num).toDouble(),
      surprise: (json['surprise'] as num).toDouble(),
      disgust: (json['disgust'] as num).toDouble(),
      neutral: (json['neutral'] as num).toDouble(),
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map((e) => EmotionTimeline.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$VoiceEmotionDataToJson(VoiceEmotionData instance) =>
    <String, dynamic>{
      'happiness': instance.happiness,
      'sadness': instance.sadness,
      'anger': instance.anger,
      'fear': instance.fear,
      'surprise': instance.surprise,
      'disgust': instance.disgust,
      'neutral': instance.neutral,
      'timeline': instance.timeline,
      'metadata': instance.metadata,
    };

EmotionTimeline _$EmotionTimelineFromJson(Map<String, dynamic> json) =>
    EmotionTimeline(
      timestamp: DateTime.parse(json['timestamp'] as String),
      dominantEmotion: json['dominantEmotion'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      emotionScores: (json['emotionScores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$EmotionTimelineToJson(EmotionTimeline instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'dominantEmotion': instance.dominantEmotion,
      'confidence': instance.confidence,
      'emotionScores': instance.emotionScores,
    };

VoiceStressData _$VoiceStressDataFromJson(Map<String, dynamic> json) =>
    VoiceStressData(
      stressLevel: (json['stressLevel'] as num).toDouble(),
      category: $enumDecode(_$StressCategoryEnumMap, json['category']),
      indicators: (json['indicators'] as List<dynamic>)
          .map((e) => StressIndicator.fromJson(e as Map<String, dynamic>))
          .toList(),
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => StressTrigger.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$VoiceStressDataToJson(VoiceStressData instance) =>
    <String, dynamic>{
      'stressLevel': instance.stressLevel,
      'category': _$StressCategoryEnumMap[instance.category]!,
      'indicators': instance.indicators,
      'triggers': instance.triggers,
      'metadata': instance.metadata,
    };

const _$StressCategoryEnumMap = {
  StressCategory.low: 'low',
  StressCategory.moderate: 'moderate',
  StressCategory.high: 'high',
  StressCategory.critical: 'critical',
};

StressIndicator _$StressIndicatorFromJson(Map<String, dynamic> json) =>
    StressIndicator(
      type: json['type'] as String,
      intensity: (json['intensity'] as num).toDouble(),
      description: json['description'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );

Map<String, dynamic> _$StressIndicatorToJson(StressIndicator instance) =>
    <String, dynamic>{
      'type': instance.type,
      'intensity': instance.intensity,
      'description': instance.description,
      'detectedAt': instance.detectedAt.toIso8601String(),
    };

StressTrigger _$StressTriggerFromJson(Map<String, dynamic> json) =>
    StressTrigger(
      trigger: json['trigger'] as String,
      impact: (json['impact'] as num).toDouble(),
      context: json['context'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$StressTriggerToJson(StressTrigger instance) =>
    <String, dynamic>{
      'trigger': instance.trigger,
      'impact': instance.impact,
      'context': instance.context,
      'timestamp': instance.timestamp.toIso8601String(),
    };

VoicePatternData _$VoicePatternDataFromJson(Map<String, dynamic> json) =>
    VoicePatternData(
      speakingRate: (json['speakingRate'] as num).toDouble(),
      volumeVariation: (json['volumeVariation'] as num).toDouble(),
      pitchVariation: (json['pitchVariation'] as num).toDouble(),
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => SpeechPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      anomalies: (json['anomalies'] as List<dynamic>)
          .map((e) => Anomaly.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$VoicePatternDataToJson(VoicePatternData instance) =>
    <String, dynamic>{
      'speakingRate': instance.speakingRate,
      'volumeVariation': instance.volumeVariation,
      'pitchVariation': instance.pitchVariation,
      'patterns': instance.patterns,
      'anomalies': instance.anomalies,
      'metadata': instance.metadata,
    };

SpeechPattern _$SpeechPatternFromJson(Map<String, dynamic> json) =>
    SpeechPattern(
      type: json['type'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      description: json['description'] as String,
      occurrences: (json['occurrences'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$SpeechPatternToJson(
  SpeechPattern instance,
) => <String, dynamic>{
  'type': instance.type,
  'frequency': instance.frequency,
  'description': instance.description,
  'occurrences': instance.occurrences.map((e) => e.toIso8601String()).toList(),
};

Anomaly _$AnomalyFromJson(Map<String, dynamic> json) => Anomaly(
  type: json['type'] as String,
  severity: (json['severity'] as num).toDouble(),
  description: json['description'] as String,
  detectedAt: DateTime.parse(json['detectedAt'] as String),
  context: json['context'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AnomalyToJson(Anomaly instance) => <String, dynamic>{
  'type': instance.type,
  'severity': instance.severity,
  'description': instance.description,
  'detectedAt': instance.detectedAt.toIso8601String(),
  'context': instance.context,
};

VoiceAlert _$VoiceAlertFromJson(Map<String, dynamic> json) => VoiceAlert(
  id: json['id'] as String,
  type: $enumDecode(_$AlertTypeEnumMap, json['type']),
  severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  acknowledged: json['acknowledged'] as bool? ?? false,
  acknowledgedBy: json['acknowledgedBy'] as String?,
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$VoiceAlertToJson(VoiceAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'acknowledged': instance.acknowledged,
      'acknowledgedBy': instance.acknowledgedBy,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$AlertTypeEnumMap = {
  AlertType.stressSpike: 'stressSpike',
  AlertType.emotionChange: 'emotionChange',
  AlertType.speechPattern: 'speechPattern',
  AlertType.crisisIndicator: 'crisisIndicator',
  AlertType.complianceIssue: 'complianceIssue',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

VoiceAnalysisConfig _$VoiceAnalysisConfigFromJson(Map<String, dynamic> json) =>
    VoiceAnalysisConfig(
      realTimeAnalysis: json['realTimeAnalysis'] as bool,
      emotionDetection: json['emotionDetection'] as bool,
      stressMonitoring: json['stressMonitoring'] as bool,
      patternAnalysis: json['patternAnalysis'] as bool,
      anomalyDetection: json['anomalyDetection'] as bool,
      analysisInterval: (json['analysisInterval'] as num).toInt(),
      sensitivityThreshold: (json['sensitivityThreshold'] as num).toDouble(),
      enabledFeatures: (json['enabledFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$VoiceAnalysisConfigToJson(
  VoiceAnalysisConfig instance,
) => <String, dynamic>{
  'realTimeAnalysis': instance.realTimeAnalysis,
  'emotionDetection': instance.emotionDetection,
  'stressMonitoring': instance.stressMonitoring,
  'patternAnalysis': instance.patternAnalysis,
  'anomalyDetection': instance.anomalyDetection,
  'analysisInterval': instance.analysisInterval,
  'sensitivityThreshold': instance.sensitivityThreshold,
  'enabledFeatures': instance.enabledFeatures,
  'metadata': instance.metadata,
};

VoiceAnalysisResult _$VoiceAnalysisResultFromJson(Map<String, dynamic> json) =>
    VoiceAnalysisResult(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      emotionData: VoiceEmotionData.fromJson(
        json['emotionData'] as Map<String, dynamic>,
      ),
      stressData: VoiceStressData.fromJson(
        json['stressData'] as Map<String, dynamic>,
      ),
      patternData: VoicePatternData.fromJson(
        json['patternData'] as Map<String, dynamic>,
      ),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => VoiceAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      insights: json['insights'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$VoiceAnalysisResultToJson(
  VoiceAnalysisResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'timestamp': instance.timestamp.toIso8601String(),
  'emotionData': instance.emotionData,
  'stressData': instance.stressData,
  'patternData': instance.patternData,
  'alerts': instance.alerts,
  'confidence': instance.confidence,
  'insights': instance.insights,
  'metadata': instance.metadata,
};
