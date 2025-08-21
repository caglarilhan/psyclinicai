import 'package:json_annotation/json_annotation.dart';

part 'multimodal_analysis_models.g.dart';

// ===== MULTIMODAL ANALİZ MODELLERİ =====

@JsonSerializable()
class MultimodalAnalysisSession {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime sessionDate;
  final Duration sessionDuration;
  final List<ModalityData> modalities;
  final MultimodalAnalysisResult analysisResult;
  final List<String> alerts;
  final double confidence;

  MultimodalAnalysisSession({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.sessionDate,
    required this.sessionDuration,
    required this.modalities,
    required this.analysisResult,
    required this.alerts,
    required this.confidence,
  });

  factory MultimodalAnalysisSession.fromJson(Map<String, dynamic> json) =>
      _$MultimodalAnalysisSessionFromJson(json);

  Map<String, dynamic> toJson() => _$MultimodalAnalysisSessionToJson(this);
}

enum ModalityType {
  @JsonValue('voice')
  voice,
  @JsonValue('video')
  video,
  @JsonValue('sleep')
  sleep,
  @JsonValue('activity')
  activity,
  @JsonValue('digital_phenotype')
  digitalPhenotype,
  @JsonValue('biometric')
  biometric,
}

@JsonSerializable()
class ModalityData {
  final String id;
  final ModalityType type;
  final DateTime timestamp;
  final Map<String, dynamic> rawData;
  final Map<String, dynamic> processedData;
  final double quality;
  final String? notes;

  ModalityData({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.rawData,
    required this.processedData,
    required this.quality,
    this.notes,
  });

  factory ModalityData.fromJson(Map<String, dynamic> json) =>
      _$ModalityDataFromJson(json);

  Map<String, dynamic> toJson() => _$ModalityDataToJson(this);
}

// ===== VOICE BIOMARKERS =====

@JsonSerializable()
class VoiceBiomarkerAnalysis {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final VoiceCharacteristics characteristics;
  final VoiceEmotionAnalysis emotionAnalysis;
  final SpeechPatternAnalysis speechPattern;
  final VoiceStressAnalysis stressAnalysis;
  final List<String> biomarkers;
  final double relapseRisk;
  final List<String> recommendations;

  VoiceBiomarkerAnalysis({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.characteristics,
    required this.emotionAnalysis,
    required this.speechPattern,
    required this.stressAnalysis,
    required this.biomarkers,
    required this.relapseRisk,
    required this.recommendations,
  });

  factory VoiceBiomarkerAnalysis.fromJson(Map<String, dynamic> json) =>
      _$VoiceBiomarkerAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceBiomarkerAnalysisToJson(this);
}

@JsonSerializable()
class VoiceCharacteristics {
  final double pitch;
  final double volume;
  final double speakingRate;
  final double articulation;
  final double fluency;
  final List<String> disfluencies;
  final Map<String, double> prosody;

  VoiceCharacteristics({
    required this.pitch,
    required this.volume,
    required this.speakingRate,
    required this.articulation,
    required this.fluency,
    required this.disfluencies,
    required this.prosody,
  });

  factory VoiceCharacteristics.fromJson(Map<String, dynamic> json) =>
      _$VoiceCharacteristicsFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceCharacteristicsToJson(this);
}

@JsonSerializable()
class VoiceEmotionAnalysis {
  final Map<String, double> emotionScores;
  final String dominantEmotion;
  final double emotionIntensity;
  final List<String> emotionTransitions;
  final double emotionalStability;

  VoiceEmotionAnalysis({
    required this.emotionScores,
    required this.dominantEmotion,
    required this.emotionIntensity,
    required this.emotionTransitions,
    required this.emotionalStability,
  });

  factory VoiceEmotionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$VoiceEmotionAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceEmotionAnalysisToJson(this);
}

@JsonSerializable()
class SpeechPatternAnalysis {
  final double wordDensity;
  final double sentenceComplexity;
  final List<String> vocabularyLevel;
  final double coherence;
  final List<String> speechDisorders;
  final Map<String, double> linguisticFeatures;

  SpeechPatternAnalysis({
    required this.wordDensity,
    required this.sentenceComplexity,
    required this.vocabularyLevel,
    required this.coherence,
    required this.speechDisorders,
    required this.linguisticFeatures,
  });

  factory SpeechPatternAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SpeechPatternAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SpeechPatternAnalysisToJson(this);
}

@JsonSerializable()
class VoiceStressAnalysis {
  final double stressLevel;
  final List<String> stressIndicators;
  final double vocalFatigue;
  final List<String> stressPatterns;
  final double recoveryRate;

  VoiceStressAnalysis({
    required this.stressLevel,
    required this.stressIndicators,
    required this.vocalFatigue,
    required this.stressPatterns,
    required this.recoveryRate,
  });

  factory VoiceStressAnalysis.fromJson(Map<String, dynamic> json) =>
      _$VoiceStressAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceStressAnalysisToJson(this);
}

// ===== VIDEO MİKROİFADELER =====

@JsonSerializable()
class VideoMicroexpressionAnalysis {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final List<FacialExpression> expressions;
  final List<Microexpression> microexpressions;
  final GazeAnalysis gazeAnalysis;
  final List<String> emotionalStates;
  final double dissociationRisk;
  final List<String> recommendations;

  VideoMicroexpressionAnalysis({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.expressions,
    required this.microexpressions,
    required this.gazeAnalysis,
    required this.emotionalStates,
    required this.dissociationRisk,
    required this.recommendations,
  });

  factory VideoMicroexpressionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$VideoMicroexpressionAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$VideoMicroexpressionAnalysisToJson(this);
}

@JsonSerializable()
class FacialExpression {
  final String id;
  final DateTime timestamp;
  final String emotion;
  final double intensity;
  final double confidence;
  final List<FacialAction> actions;
  final Map<String, double> coordinates;

  FacialExpression({
    required this.id,
    required this.timestamp,
    required this.emotion,
    required this.intensity,
    required this.confidence,
    required this.actions,
    required this.coordinates,
  });

  factory FacialExpression.fromJson(Map<String, dynamic> json) =>
      _$FacialExpressionFromJson(json);

  Map<String, dynamic> toJson() => _$FacialExpressionToJson(this);
}

@JsonSerializable()
class FacialAction {
  final String id;
  final String actionUnit;
  final double intensity;
  final String description;
  final double duration;

  FacialAction({
    required this.id,
    required this.actionUnit,
    required this.intensity,
    required this.description,
    required this.duration,
  });

  factory FacialAction.fromJson(Map<String, dynamic> json) =>
      _$FacialActionFromJson(json);

  Map<String, dynamic> toJson() => _$FacialActionToJson(this);
}

@JsonSerializable()
class Microexpression {
  final String id;
  final DateTime timestamp;
  final String emotion;
  final double intensity;
  final double duration;
  final String significance;
  final List<String> implications;

  Microexpression({
    required this.id,
    required this.timestamp,
    required this.emotion,
    required this.intensity,
    required this.duration,
    required this.significance,
    required this.implications,
  });

  factory Microexpression.fromJson(Map<String, dynamic> json) =>
      _$MicroexpressionFromJson(json);

  Map<String, dynamic> toJson() => _$MicroexpressionToJson(this);
}

@JsonSerializable()
class GazeAnalysis {
  final List<GazePoint> gazePoints;
  final double attentionLevel;
  final List<String> gazePatterns;
  final double eyeContact;
  final List<String> avoidanceBehaviors;

  GazeAnalysis({
    required this.gazePoints,
    required this.attentionLevel,
    required this.gazePatterns,
    required this.eyeContact,
    required this.avoidanceBehaviors,
  });

  factory GazeAnalysis.fromJson(Map<String, dynamic> json) =>
      _$GazeAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$GazeAnalysisToJson(this);
}

@JsonSerializable()
class GazePoint {
  final String id;
  final DateTime timestamp;
  final double x;
  final double y;
  final double duration;
  final String target;

  GazePoint({
    required this.id,
    required this.timestamp,
    required this.x,
    required this.y,
    required this.duration,
    required this.target,
  });

  factory GazePoint.fromJson(Map<String, dynamic> json) =>
      _$GazePointFromJson(json);

  Map<String, dynamic> toJson() => _$GazePointToJson(this);
}

// ===== UYKU & AKTİVİTE KORELASYONU =====

@JsonSerializable()
class SleepActivityCorrelation {
  final String id;
  final String patientId;
  final DateTime analysisDate;
  final SleepData sleepData;
  final ActivityData activityData;
  final CorrelationAnalysis correlation;
  final List<String> insights;
  final List<String> recommendations;

  SleepActivityCorrelation({
    required this.id,
    required this.patientId,
    required this.analysisDate,
    required this.sleepData,
    required this.activityData,
    required this.correlation,
    required this.insights,
    required this.recommendations,
  });

  factory SleepActivityCorrelation.fromJson(Map<String, dynamic> json) =>
      _$SleepActivityCorrelationFromJson(json);

  Map<String, dynamic> toJson() => _$SleepActivityCorrelationToJson(this);
}

@JsonSerializable()
class SleepData {
  final DateTime sleepDate;
  final Duration totalSleepTime;
  final Duration deepSleepTime;
  final Duration remSleepTime;
  final Duration lightSleepTime;
  final int sleepEfficiency;
  final int wakeUps;
  final double sleepQuality;
  final List<String> sleepDisorders;

  SleepData({
    required this.sleepDate,
    required this.totalSleepTime,
    required this.deepSleepTime,
    required this.remSleepTime,
    required this.lightSleepTime,
    required this.sleepEfficiency,
    required this.wakeUps,
    required this.sleepQuality,
    required this.sleepDisorders,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) =>
      _$SleepDataFromJson(json);

  Map<String, dynamic> toJson() => _$SleepDataToJson(this);
}

@JsonSerializable()
class ActivityData {
  final DateTime activityDate;
  final int steps;
  final double distance;
  final int calories;
  final double activeMinutes;
  final double sedentaryMinutes;
  final List<String> activities;
  final double activityLevel;

  ActivityData({
    required this.activityDate,
    required this.steps,
    required this.distance,
    required this.calories,
    required this.activeMinutes,
    required this.sedentaryMinutes,
    required this.activities,
    required this.activityLevel,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) =>
      _$ActivityDataFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityDataToJson(this);
}

@JsonSerializable()
class CorrelationAnalysis {
  final double correlationCoefficient;
  final String correlationType;
  final List<String> patterns;
  final List<String> anomalies;
  final double confidence;
  final List<String> factors;

  CorrelationAnalysis({
    required this.correlationCoefficient,
    required this.correlationType,
    required this.patterns,
    required this.anomalies,
    required this.confidence,
    required this.factors,
  });

  factory CorrelationAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CorrelationAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$CorrelationAnalysisToJson(this);
}

// ===== DİJİTAL FENOTİPİNG =====

@JsonSerializable()
class DigitalPhenotyping {
  final String id;
  final String patientId;
  final DateTime analysisDate;
  final PhoneUsageData phoneUsage;
  final AppUsageData appUsage;
  final CommunicationData communication;
  final LocationData location;
  final List<String> patterns;
  final double relapseRisk;
  final List<String> recommendations;

  DigitalPhenotyping({
    required this.id,
    required this.patientId,
    required this.analysisDate,
    required this.phoneUsage,
    required this.appUsage,
    required this.communication,
    required this.location,
    required this.patterns,
    required this.relapseRisk,
    required this.recommendations,
  });

  factory DigitalPhenotyping.fromJson(Map<String, dynamic> json) =>
      _$DigitalPhenotypingFromJson(json);

  Map<String, dynamic> toJson() => _$DigitalPhenotypingToJson(this);
}

@JsonSerializable()
class PhoneUsageData {
  final Duration totalScreenTime;
  final Duration nightUsage;
  final int unlockCount;
  final List<String> usagePatterns;
  final double usageVariability;

  PhoneUsageData({
    required this.totalScreenTime,
    required this.nightUsage,
    required this.unlockCount,
    required this.usagePatterns,
    required this.usageVariability,
  });

  factory PhoneUsageData.fromJson(Map<String, dynamic> json) =>
      _$PhoneUsageDataFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneUsageDataToJson(this);
}

@JsonSerializable()
class AppUsageData {
  final Map<String, Duration> appUsageTimes;
  final List<String> mostUsedApps;
  final List<String> socialMediaUsage;
  final List<String> productivityUsage;
  final double appDiversity;

  AppUsageData({
    required this.appUsageTimes,
    required this.mostUsedApps,
    required this.socialMediaUsage,
    required this.productivityUsage,
    required this.appDiversity,
  });

  factory AppUsageData.fromJson(Map<String, dynamic> json) =>
      _$AppUsageDataFromJson(json);

  Map<String, dynamic> toJson() => _$AppUsageDataToJson(this);
}

@JsonSerializable()
class CommunicationData {
  final int callsCount;
  final Duration totalCallTime;
  final int messagesCount;
  final List<String> communicationPatterns;
  final double socialEngagement;

  CommunicationData({
    required this.callsCount,
    required this.totalCallTime,
    required this.messagesCount,
    required this.communicationPatterns,
    required this.socialEngagement,
  });

  factory CommunicationData.fromJson(Map<String, dynamic> json) =>
      _$CommunicationDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommunicationDataToJson(this);
}

@JsonSerializable()
class LocationData {
  final List<LocationPoint> locations;
  final double locationVariability;
  final List<String> frequentPlaces;
  final List<String> movementPatterns;
  final double socialIsolation;

  LocationData({
    required this.locations,
    required this.locationVariability,
    required this.frequentPlaces,
    required this.movementPatterns,
    required this.socialIsolation,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}

@JsonSerializable()
class LocationPoint {
  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String place;
  final Duration duration;

  LocationPoint({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.duration,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) =>
      _$LocationPointFromJson(json);

  Map<String, dynamic> toJson() => _$LocationPointToJson(this);
}

// ===== MULTIMODAL ANALİZ SONUCU =====

@JsonSerializable()
class MultimodalAnalysisResult {
  final String id;
  final DateTime analysisDate;
  final List<ModalityResult> modalityResults;
  final IntegratedAnalysis integratedAnalysis;
  final List<String> criticalFindings;
  final List<String> recommendations;
  final double overallConfidence;

  MultimodalAnalysisResult({
    required this.id,
    required this.analysisDate,
    required this.modalityResults,
    required this.integratedAnalysis,
    required this.criticalFindings,
    required this.recommendations,
    required this.overallConfidence,
  });

  factory MultimodalAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$MultimodalAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$MultimodalAnalysisResultToJson(this);
}

@JsonSerializable()
class ModalityResult {
  final ModalityType type;
  final double confidence;
  final List<String> findings;
  final List<String> alerts;
  final Map<String, dynamic>? metadata;

  ModalityResult({
    required this.type,
    required this.confidence,
    required this.findings,
    required this.alerts,
    this.metadata,
  });

  factory ModalityResult.fromJson(Map<String, dynamic> json) =>
      _$ModalityResultFromJson(json);

  Map<String, dynamic> toJson() => _$ModalityResultToJson(this);
}

@JsonSerializable()
class IntegratedAnalysis {
  final double relapseRisk;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final String overallAssessment;
  final List<String> trends;
  final double predictionAccuracy;

  IntegratedAnalysis({
    required this.relapseRisk,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.overallAssessment,
    required this.trends,
    required this.predictionAccuracy,
  });

  factory IntegratedAnalysis.fromJson(Map<String, dynamic> json) =>
      _$IntegratedAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$IntegratedAnalysisToJson(this);
}
