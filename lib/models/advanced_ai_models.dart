import 'package:json_annotation/json_annotation.dart';

part 'advanced_ai_models.g.dart';

// === PREDICTIVE ANALYTICS MODELS ===

@JsonSerializable()
class PredictiveModel {
  final String id;
  final String name;
  final String description;
  final ModelType type;
  final ModelCategory category;
  final ModelStatus status;
  final String version;
  final DateTime trainedAt;
  final DateTime lastUpdated;
  final ModelPerformance performance;
  final ModelMetadata metadata;
  final List<ModelFeature> features;
  final List<ModelPrediction> predictions;
  final ModelTrainingData trainingData;

  PredictiveModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.status,
    required this.version,
    required this.trainedAt,
    required this.lastUpdated,
    required this.performance,
    required this.metadata,
    required this.features,
    required this.predictions,
    required this.trainingData,
  });

  factory PredictiveModel.fromJson(Map<String, dynamic> json) => _$PredictiveModelFromJson(json);
  Map<String, dynamic> toJson() => _$PredictiveModelToJson(this);
}

@JsonSerializable()
class ModelPrediction {
  final String id;
  final String modelId;
  final String patientId;
  final String predictionType;
  final double confidence;
  final double probability;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> outputData;
  final DateTime timestamp;
  final PredictionStatus status;
  final String? explanation;
  final List<PredictionFeature> featureImportance;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  ModelPrediction({
    required this.id,
    required this.modelId,
    required this.patientId,
    required this.predictionType,
    required this.confidence,
    required this.probability,
    required this.inputData,
    required this.outputData,
    required this.timestamp,
    required this.status,
    this.explanation,
    required this.featureImportance,
    required this.isVerified,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory ModelPrediction.fromJson(Map<String, dynamic> json) => _$ModelPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$ModelPredictionToJson(this);
}

@JsonSerializable()
class RelapsePrediction {
  final String id;
  final String patientId;
  final double relapseRisk;
  final RiskLevel riskLevel;
  final DateTime predictedDate;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final double confidence;
  final String modelVersion;
  final DateTime createdAt;
  final List<RiskMitigation> mitigations;

  RelapsePrediction({
    required this.id,
    required this.patientId,
    required this.relapseRisk,
    required this.riskLevel,
    required this.predictedDate,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.confidence,
    required this.modelVersion,
    required this.createdAt,
    required this.mitigations,
  });

  factory RelapsePrediction.fromJson(Map<String, dynamic> json) => _$RelapsePredictionFromJson(json);
  Map<String, dynamic> toJson() => _$RelapsePredictionToJson(this);
}

// === NATURAL LANGUAGE PROCESSING MODELS ===

@JsonSerializable()
class NLPModel {
  final String id;
  final String name;
  final NLPModelType type;
  final String version;
  final List<String> supportedLanguages;
  final List<String> supportedTasks;
  final ModelPerformance performance;
  final DateTime trainedAt;
  final DateTime lastUpdated;
  final Map<String, dynamic> configuration;

  NLPModel({
    required this.id,
    required this.name,
    required this.type,
    required this.version,
    required this.supportedLanguages,
    required this.supportedTasks,
    required this.performance,
    required this.trainedAt,
    required this.lastUpdated,
    required this.configuration,
  });

  factory NLPModel.fromJson(Map<String, dynamic> json) => _$NLPModelFromJson(json);
  Map<String, dynamic> toJson() => _$NLPModelToJson(this);
}

@JsonSerializable()
class ICDCodeExtraction {
  final String id;
  final String sessionId;
  final String patientId;
  final String therapistId;
  final String originalText;
  final List<ExtractedICDCode> extractedCodes;
  final double confidence;
  final String modelVersion;
  final DateTime extractedAt;
  final ExtractionStatus status;
  final List<String> alternativeCodes;
  final String? reasoning;

  ICDCodeExtraction({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.therapistId,
    required this.originalText,
    required this.extractedCodes,
    required this.confidence,
    required this.modelVersion,
    required this.extractedAt,
    required this.status,
    required this.alternativeCodes,
    this.reasoning,
  });

  factory ICDCodeExtraction.fromJson(Map<String, dynamic> json) => _$ICDCodeExtractionFromJson(json);
  Map<String, dynamic> toJson() => _$ICDCodeExtractionToJson(this);
}

@JsonSerializable()
class ExtractedICDCode {
  final String icdCode;
  final String description;
  final double confidence;
  final List<String> supportingText;
  final List<String> symptoms;
  final String severity;
  final String? modifier;

  ExtractedICDCode({
    required this.icdCode,
    required this.description,
    required this.confidence,
    required this.supportingText,
    required this.symptoms,
    required this.severity,
    this.modifier,
  });

  factory ExtractedICDCode.fromJson(Map<String, dynamic> json) => _$ExtractedICDCodeFromJson(json);
  Map<String, dynamic> toJson() => _$ExtractedICDCodeToJson(this);
}

@JsonSerializable()
class SentimentAnalysis {
  final String id;
  final String textId;
  final String text;
  final SentimentType primarySentiment;
  final Map<SentimentType, double> sentimentScores;
  final List<Emotion> emotions;
  final double confidence;
  final String modelVersion;
  final DateTime analyzedAt;
  final List<SentimentEntity> entities;

  SentimentAnalysis({
    required this.id,
    required this.textId,
    required this.text,
    required this.primarySentiment,
    required this.sentimentScores,
    required this.emotions,
    required this.confidence,
    required this.modelVersion,
    required this.analyzedAt,
    required this.entities,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) => _$SentimentAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$SentimentAnalysisToJson(this);
}

// === COMPUTER VISION MODELS ===

@JsonSerializable()
class ComputerVisionModel {
  final String id;
  final String name;
  final VisionModelType type;
  final String version;
  final List<String> supportedTasks;
  final ModelPerformance performance;
  final DateTime trainedAt;
  final DateTime lastUpdated;
  final Map<String, dynamic> configuration;

  ComputerVisionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.version,
    required this.supportedTasks,
    required this.performance,
    required this.trainedAt,
    required this.lastUpdated,
    required this.configuration,
  });

  factory ComputerVisionModel.fromJson(Map<String, dynamic> json) => _$ComputerVisionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ComputerVisionModelToJson(this);
}

@JsonSerializable()
class FacialExpressionAnalysis {
  final String id;
  final String sessionId;
  final String patientId;
  final DateTime timestamp;
  final List<DetectedEmotion> emotions;
  final List<FacialAction> actions;
  final List<GazePoint> gazePoints;
  final List<MicroExpression> microExpressions;
  final double confidence;
  final String modelVersion;
  final List<String> qualityMetrics;

  FacialExpressionAnalysis({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.timestamp,
    required this.emotions,
    required this.actions,
    required this.gazePoints,
    required this.microExpressions,
    required this.confidence,
    required this.modelVersion,
    required this.qualityMetrics,
  });

  factory FacialExpressionAnalysis.fromJson(Map<String, dynamic> json) => _$FacialExpressionAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$FacialExpressionAnalysisToJson(this);
}

@JsonSerializable()
class DetectedEmotion {
  final EmotionType emotion;
  final double confidence;
  final double intensity;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> triggers;

  DetectedEmotion({
    required this.emotion,
    required this.confidence,
    required this.intensity,
    required this.startTime,
    required this.endTime,
    required this.triggers,
  });

  factory DetectedEmotion.fromJson(Map<String, dynamic> json) => _$DetectedEmotionFromJson(json);
  Map<String, dynamic> toJson() => _$DetectedEmotionToJson(this);
}

@JsonSerializable()
class FacialAction {
  final String actionUnit;
  final String description;
  final double intensity;
  final DateTime timestamp;
  final double confidence;

  FacialAction({
    required this.actionUnit,
    required this.description,
    required this.intensity,
    required this.timestamp,
    required this.confidence,
  });

  factory FacialAction.fromJson(Map<String, dynamic> json) => _$FacialActionFromJson(json);
  Map<String, dynamic> toJson() => _$FacialActionToJson(this);
}

@JsonSerializable()
class GazePoint {
  final double x;
  final double y;
  final DateTime timestamp;
  final double confidence;
  final String? target;

  GazePoint({
    required this.x,
    required this.y,
    required this.timestamp,
    required this.confidence,
    this.target,
  });

  factory GazePoint.fromJson(Map<String, dynamic> json) => _$GazePointFromJson(json);
  Map<String, dynamic> toJson() => _$GazePointToJson(this);
}

@JsonSerializable()
class MicroExpression {
  final EmotionType emotion;
  final double intensity;
  final DateTime startTime;
  final DateTime endTime;
  final double confidence;
  final String? trigger;

  MicroExpression({
    required this.emotion,
    required this.intensity,
    required this.startTime,
    required this.endTime,
    required this.confidence,
    this.trigger,
  });

  factory MicroExpression.fromJson(Map<String, dynamic> json) => _$MicroExpressionFromJson(json);
  Map<String, dynamic> toJson() => _$MicroExpressionToJson(this);
}

// === VOICE ANALYSIS MODELS ===

@JsonSerializable()
class VoiceAnalysisModel {
  final String id;
  final String name;
  final VoiceModelType type;
  final String version;
  final List<String> supportedLanguages;
  final List<String> supportedFeatures;
  final ModelPerformance performance;
  final DateTime trainedAt;
  final DateTime lastUpdated;

  VoiceAnalysisModel({
    required this.id,
    required this.name,
    required this.type,
    required this.version,
    required this.supportedLanguages,
    required this.supportedFeatures,
    required this.performance,
    required this.trainedAt,
    required this.lastUpdated,
  });

  factory VoiceAnalysisModel.fromJson(Map<String, dynamic> json) => _$VoiceAnalysisModelFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceAnalysisModelToJson(this);
}

@JsonSerializable()
class VoiceAnalysis {
  final String id;
  final String sessionId;
  final String patientId;
  final DateTime timestamp;
  final VoiceCharacteristics characteristics;
  final List<VoiceEmotion> emotions;
  final List<SpeechPattern> patterns;
  final List<VoiceStress> stressIndicators;
  final double confidence;
  final String modelVersion;
  final List<String> qualityMetrics;

  VoiceAnalysis({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.timestamp,
    required this.characteristics,
    required this.emotions,
    required this.patterns,
    required this.stressIndicators,
    required this.confidence,
    required this.modelVersion,
    required this.qualityMetrics,
  });

  factory VoiceAnalysis.fromJson(Map<String, dynamic> json) => _$VoiceAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceAnalysisToJson(this);
}

@JsonSerializable()
class VoiceCharacteristics {
  final double pitch;
  final double speakingRate;
  final double volume;
  final double clarity;
  final double fluency;
  final List<String> speechDisorders;
  final Map<String, double> prosody;

  VoiceCharacteristics({
    required this.pitch,
    required this.speakingRate,
    required this.volume,
    required this.clarity,
    required this.fluency,
    required this.speechDisorders,
    required this.prosody,
  });

  factory VoiceCharacteristics.fromJson(Map<String, dynamic> json) => _$VoiceCharacteristicsFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceCharacteristicsToJson(this);
}

@JsonSerializable()
class VoiceEmotion {
  final EmotionType emotion;
  final double confidence;
  final double intensity;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, double> emotionBlend;

  VoiceEmotion({
    required this.emotion,
    required this.confidence,
    required this.intensity,
    required this.startTime,
    required this.endTime,
    required this.emotionBlend,
  });

  factory VoiceEmotion.fromJson(Map<String, dynamic> json) => _$VoiceEmotionFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceEmotionToJson(this);
}

@JsonSerializable()
class SpeechPattern {
  final String patternType;
  final String description;
  final double frequency;
  final List<DateTime> occurrences;
  final double confidence;
  final String? clinicalSignificance;

  SpeechPattern({
    required this.patternType,
    required this.description,
    required this.frequency,
    required this.occurrences,
    required this.confidence,
    this.clinicalSignificance,
  });

  factory SpeechPattern.fromJson(Map<String, dynamic> json) => _$SpeechPatternFromJson(json);
  Map<String, dynamic> toJson() => _$SpeechPatternToJson(this);
}

@JsonSerializable()
class VoiceStress {
  final StressType type;
  final double level;
  final DateTime timestamp;
  final double confidence;
  final List<String> indicators;

  VoiceStress({
    required this.type,
    required this.level,
    required this.timestamp,
    required this.confidence,
    required this.indicators,
  });

  factory VoiceStress.fromJson(Map<String, dynamic> json) => _$VoiceStressFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceStressToJson(this);
}

// === EXPLAINABLE AI (XAI) MODELS ===

@JsonSerializable()
class XAIModel {
  final String id;
  final String name;
  final XAIType type;
  final String version;
  final List<String> supportedMethods;
  final ModelPerformance performance;
  final DateTime trainedAt;
  final DateTime lastUpdated;

  XAIModel({
    required this.id,
    required this.name,
    required this.type,
    required this.version,
    required this.supportedMethods,
    required this.performance,
    required this.trainedAt,
    required this.lastUpdated,
  });

  factory XAIModel.fromJson(Map<String, dynamic> json) => _$XAIModelFromJson(json);
  Map<String, dynamic> toJson() => _$XAIModelToJson(this);
}

@JsonSerializable()
class AIExplanation {
  final String id;
  final String predictionId;
  final String modelId;
  final String explanationType;
  final String explanation;
  final double confidence;
  final List<ExplanationFeature> features;
  final List<ExplanationRule> rules;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;
  final String modelVersion;

  AIExplanation({
    required this.id,
    required this.predictionId,
    required this.modelId,
    required this.explanationType,
    required this.explanation,
    required this.confidence,
    required this.features,
    required this.rules,
    required this.metadata,
    required this.generatedAt,
    required this.modelVersion,
  });

  factory AIExplanation.fromJson(Map<String, dynamic> json) => _$AIExplanationFromJson(json);
  Map<String, dynamic> toJson() => _$AIExplanationToJson(this);
}

@JsonSerializable()
class ExplanationFeature {
  final String featureName;
  final String featureValue;
  final double importance;
  final double contribution;
  final String? description;
  final List<String> relatedSymptoms;

  ExplanationFeature({
    required this.featureName,
    required this.featureValue,
    required this.importance,
    required this.contribution,
    this.description,
    required this.relatedSymptoms,
  });

  factory ExplanationFeature.fromJson(Map<String, dynamic> json) => _$ExplanationFeatureFromJson(json);
  Map<String, dynamic> toJson() => _$ExplanationFeatureToJson(this);
}

@JsonSerializable()
class ExplanationRule {
  final String ruleId;
  final String ruleDescription;
  final String condition;
  final String conclusion;
  final double confidence;
  final List<String> supportingEvidence;

  ExplanationRule({
    required this.ruleId,
    required this.ruleDescription,
    required this.condition,
    required this.conclusion,
    required this.confidence,
    required this.supportingEvidence,
  });

  factory ExplanationRule.fromJson(Map<String, dynamic> json) => _$ExplanationRuleFromJson(json);
  Map<String, dynamic> toJson() => _$ExplanationRuleToJson(this);
}

// === SUPPORTING MODELS ===

@JsonSerializable()
class ModelPerformance {
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double auc;
  final Map<String, double> classMetrics;
  final List<ConfusionMatrix> confusionMatrices;
  final List<ROCCurve> rocCurves;

  ModelPerformance({
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.auc,
    required this.classMetrics,
    required this.confusionMatrices,
    required this.rocCurves,
  });

  factory ModelPerformance.fromJson(Map<String, dynamic> json) => _$ModelPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$ModelPerformanceToJson(this);
}

@JsonSerializable()
class ModelMetadata {
  final String algorithm;
  final Map<String, dynamic> hyperparameters;
  final List<String> preprocessingSteps;
  final String dataSource;
  final int trainingSamples;
  final int validationSamples;
  final int testSamples;
  final Map<String, dynamic> additionalInfo;

  ModelMetadata({
    required this.algorithm,
    required this.hyperparameters,
    required this.preprocessingSteps,
    required this.dataSource,
    required this.trainingSamples,
    required this.validationSamples,
    required this.testSamples,
    required this.additionalInfo,
  });

  factory ModelMetadata.fromJson(Map<String, dynamic> json) => _$ModelMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ModelMetadataToJson(this);
}

@JsonSerializable()
class ModelFeature {
  final String name;
  final String type;
  final String description;
  final double importance;
  final List<String> categories;
  final Map<String, dynamic> statistics;

  ModelFeature({
    required this.name,
    required this.type,
    required this.description,
    required this.importance,
    required this.categories,
    required this.statistics,
  });

  factory ModelFeature.fromJson(Map<String, dynamic> json) => _$ModelFeatureFromJson(json);
  Map<String, dynamic> toJson() => _$ModelFeatureToJson(this);
}

@JsonSerializable()
class ModelTrainingData {
  final String id;
  final String description;
  final DateTime createdAt;
  final int sampleCount;
  final List<String> features;
  final Map<String, int> classDistribution;
  final List<String> dataQuality;

  ModelTrainingData({
    required this.id,
    required this.description,
    required this.createdAt,
    required this.sampleCount,
    required this.features,
    required this.classDistribution,
    required this.dataQuality,
  });

  factory ModelTrainingData.fromJson(Map<String, dynamic> json) => _$ModelTrainingDataFromJson(json);
  Map<String, dynamic> toJson() => _$ModelTrainingDataToJson(this);
}

@JsonSerializable()
class RiskMitigation {
  final String id;
  final String strategy;
  final String description;
  final double effectiveness;
  final List<String> actions;
  final DateTime recommendedAt;
  final bool isImplemented;

  RiskMitigation({
    required this.id,
    required this.strategy,
    required this.description,
    required this.effectiveness,
    required this.actions,
    required this.recommendedAt,
    required this.isImplemented,
  });

  factory RiskMitigation.fromJson(Map<String, dynamic> json) => _$RiskMitigationFromJson(json);
  Map<String, dynamic> toJson() => _$RiskMitigationToJson(this);
}

@JsonSerializable()
class ConfusionMatrix {
  final String id;
  final List<List<int>> matrix;
  final List<String> labels;
  final DateTime createdAt;

  ConfusionMatrix({
    required this.id,
    required this.matrix,
    required this.labels,
    required this.createdAt,
  });

  factory ConfusionMatrix.fromJson(Map<String, dynamic> json) => _$ConfusionMatrixFromJson(json);
  Map<String, dynamic> toJson() => _$ConfusionMatrixToJson(this);
}

@JsonSerializable()
class ROCCurve {
  final String id;
  final List<ROCPoint> points;
  final double auc;
  final DateTime createdAt;

  ROCCurve({
    required this.id,
    required this.points,
    required this.auc,
    required this.createdAt,
  });

  factory ROCCurve.fromJson(Map<String, dynamic> json) => _$ROCCurveFromJson(json);
  Map<String, dynamic> toJson() => _$ROCCurveToJson(this);
}

@JsonSerializable()
class ROCPoint {
  final double falsePositiveRate;
  final double truePositiveRate;
  final double threshold;

  ROCPoint({
    required this.falsePositiveRate,
    required this.truePositiveRate,
    required this.threshold,
  });

  factory ROCPoint.fromJson(Map<String, dynamic> json) => _$ROCPointFromJson(json);
  Map<String, dynamic> toJson() => _$ROCPointToJson(this);
}

// === ENUMS ===

enum ModelType {
  @JsonValue('classification')
  classification,
  @JsonValue('regression')
  regression,
  @JsonValue('clustering')
  clustering,
  @JsonValue('anomaly_detection')
  anomalyDetection,
  @JsonValue('time_series')
  timeSeries,
  @JsonValue('reinforcement_learning')
  reinforcementLearning,
}

enum ModelCategory {
  @JsonValue('clinical')
  clinical,
  @JsonValue('operational')
  operational,
  @JsonValue('financial')
  financial,
  @JsonValue('compliance')
  compliance,
  @JsonValue('research')
  research,
}

enum ModelStatus {
  @JsonValue('training')
  training,
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('deprecated')
  deprecated,
  @JsonValue('error')
  error,
}

enum PredictionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('verified')
  verified,
  @JsonValue('incorrect')
  incorrect,
  @JsonValue('expired')
  expired,
}

enum RiskLevel {
  @JsonValue('low')
  low,
  @JsonValue('moderate')
  moderate,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum NLPModelType {
  @JsonValue('bert')
  bert,
  @JsonValue('gpt')
  gpt,
  @JsonValue('lstm')
  lstm,
  @JsonValue('transformer')
  transformer,
  @JsonValue('custom')
  custom,
}

enum ExtractionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('reviewed')
  reviewed,
}

enum SentimentType {
  @JsonValue('positive')
  positive,
  @JsonValue('negative')
  negative,
  @JsonValue('neutral')
  neutral,
  @JsonValue('mixed')
  mixed,
}

enum EmotionType {
  @JsonValue('happy')
  happy,
  @JsonValue('sad')
  sad,
  @JsonValue('angry')
  angry,
  @JsonValue('fearful')
  fearful,
  @JsonValue('surprised')
  surprised,
  @JsonValue('disgusted')
  disgusted,
  @JsonValue('neutral')
  neutral,
  @JsonValue('anxious')
  anxious,
  @JsonValue('depressed')
  depressed,
  @JsonValue('manic')
  manic,
}

enum VisionModelType {
  @JsonValue('cnn')
  cnn,
  @JsonValue('resnet')
  resnet,
  @JsonValue('yolo')
  yolo,
  @JsonValue('custom')
  custom,
}

enum VoiceModelType {
  @JsonValue('lstm')
  lstm,
  @JsonValue('transformer')
  transformer,
  @JsonValue('cnn')
  cnn,
  @JsonValue('custom')
  custom,
}

enum StressType {
  @JsonValue('acute')
  acute,
  @JsonValue('chronic')
  chronic,
  @JsonValue('trauma')
  trauma,
  @JsonValue('anxiety')
  anxiety,
}

enum XAIType {
  @JsonValue('feature_importance')
  featureImportance,
  @JsonValue('rule_based')
  ruleBased,
  @JsonValue('counterfactual')
  counterfactual,
  @JsonValue('gradient_based')
  gradientBased,
  @JsonValue('attention_based')
  attentionBased,
}

@JsonSerializable()
class Emotion {
  final EmotionType type;
  final double intensity;
  final double confidence;
  final DateTime timestamp;
  final List<String> triggers;

  Emotion({
    required this.type,
    required this.intensity,
    required this.confidence,
    required this.timestamp,
    required this.triggers,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) => _$EmotionFromJson(json);
  Map<String, dynamic> toJson() => _$EmotionToJson(this);
}

@JsonSerializable()
class SentimentEntity {
  final String text;
  final String type;
  final double confidence;
  final Map<String, dynamic> metadata;

  SentimentEntity({
    required this.text,
    required this.type,
    required this.confidence,
    required this.metadata,
  });

  factory SentimentEntity.fromJson(Map<String, dynamic> json) => _$SentimentEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SentimentEntityToJson(this);
}

@JsonSerializable()
class PredictionFeature {
  final String name;
  final String value;
  final double importance;
  final double contribution;
  final String? description;

  PredictionFeature({
    required this.name,
    required this.value,
    required this.importance,
    required this.contribution,
    this.description,
  });

  factory PredictionFeature.fromJson(Map<String, dynamic> json) => _$PredictionFeatureFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionFeatureToJson(this);
}
