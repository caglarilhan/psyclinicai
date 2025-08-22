import 'package:json_annotation/json_annotation.dart';

part 'predictive_analytics_models.g.dart';

@JsonSerializable()
class PredictiveModel {
  final String id;
  final String name;
  final String description;
  final ModelType type;
  final ModelStatus status;
  final double accuracy;
  final DateTime lastTrained;
  final DateTime lastUpdated;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> metadata;

  const PredictiveModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.accuracy,
    required this.lastTrained,
    required this.lastUpdated,
    this.parameters = const {},
    this.metadata = const {},
  });

  factory PredictiveModel.fromJson(Map<String, dynamic> json) => _$PredictiveModelFromJson(json);
  Map<String, dynamic> toJson() => _$PredictiveModelToJson(this);
}

enum ModelType {
  regression,
  classification,
  clustering,
  timeSeries,
  anomalyDetection,
  recommendation
}

enum ModelStatus {
  training,
  active,
  inactive,
  deprecated,
  error
}

@JsonSerializable()
class PredictionRequest {
  final String id;
  final String modelId;
  final String tenantId;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> context;
  final Map<String, dynamic> metadata;

  const PredictionRequest({
    required this.id,
    required this.modelId,
    required this.tenantId,
    required this.userId,
    required this.timestamp,
    required this.inputData,
    this.context = const {},
    this.metadata = const {},
  });

  factory PredictionRequest.fromJson(Map<String, dynamic> json) => _$PredictionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionRequestToJson(this);
}

@JsonSerializable()
class PredictionResult {
  final String id;
  final String requestId;
  final String modelId;
  final DateTime timestamp;
  final Map<String, dynamic> predictions;
  final double confidence;
  final Map<String, dynamic> explanations;
  final Map<String, dynamic> metadata;

  const PredictionResult({
    required this.id,
    required this.requestId,
    required this.modelId,
    required this.timestamp,
    required this.predictions,
    required this.confidence,
    this.explanations = const {},
    this.metadata = const {},
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) => _$PredictionResultFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionResultToJson(this);
}

@JsonSerializable()
class TreatmentOutcomePrediction {
  final String id;
  final String patientId;
  final String treatmentId;
  final double successProbability;
  final int estimatedDurationWeeks;
  final List<String> riskFactors;
  final List<String> recommendedAdjustments;
  final Map<String, dynamic> confidenceIntervals;
  final Map<String, dynamic> metadata;

  const TreatmentOutcomePrediction({
    required this.id,
    required this.patientId,
    required this.treatmentId,
    required this.successProbability,
    required this.estimatedDurationWeeks,
    required this.riskFactors,
    required this.recommendedAdjustments,
    this.confidenceIntervals = const {},
    this.metadata = const {},
  });

  factory TreatmentOutcomePrediction.fromJson(Map<String, dynamic> json) => _$TreatmentOutcomePredictionFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentOutcomePredictionToJson(this);
}

@JsonSerializable()
class RelapseRiskPrediction {
  final String id;
  final String patientId;
  final double relapseRisk;
  final RiskLevel riskLevel;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final DateTime predictedRiskPeriod;
  final List<String> preventionStrategies;
  final Map<String, dynamic> metadata;

  const RelapseRiskPrediction({
    required this.id,
    required this.patientId,
    required this.relapseRisk,
    required this.riskLevel,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.predictedRiskPeriod,
    required this.preventionStrategies,
    this.metadata = const {},
  });

  factory RelapseRiskPrediction.fromJson(Map<String, dynamic> json) => _$RelapseRiskPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$RelapseRiskPredictionToJson(this);
}

enum RiskLevel {
  low,
  moderate,
  high,
  critical
}

@JsonSerializable()
class PatientProgressPrediction {
  final String id;
  final String patientId;
  final DateTime predictionDate;
  final double improvementScore;
  final int estimatedRecoveryWeeks;
  final List<String> milestones;
  final List<String> challenges;
  final Map<String, dynamic> confidenceMetrics;
  final Map<String, dynamic> metadata;

  const PatientProgressPrediction({
    required this.id,
    required this.patientId,
    required this.predictionDate,
    required this.improvementScore,
    required this.estimatedRecoveryWeeks,
    required this.milestones,
    required this.challenges,
    this.confidenceMetrics = const {},
    this.metadata = const {},
  });

  factory PatientProgressPrediction.fromJson(Map<String, dynamic> json) => _$PatientProgressPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$PatientProgressPredictionToJson(this);
}

@JsonSerializable()
class CrisisPrediction {
  final String id;
  final String patientId;
  final CrisisType crisisType;
  final double crisisProbability;
  final DateTime predictedTimeframe;
  final List<String> warningSigns;
  final List<String> interventionStrategies;
  final UrgencyLevel urgency;
  final Map<String, dynamic> metadata;

  const CrisisPrediction({
    required this.id,
    required this.patientId,
    required this.crisisType,
    required this.crisisProbability,
    required this.predictedTimeframe,
    required this.warningSigns,
    required this.interventionStrategies,
    required this.urgency,
    this.metadata = const {},
  });

  factory CrisisPrediction.fromJson(Map<String, dynamic> json) => _$CrisisPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$CrisisPredictionToJson(this);
}

enum CrisisType {
  suicidal,
  violent,
  psychotic,
  substanceAbuse,
  selfHarm,
  other
}

enum UrgencyLevel {
  low,
  medium,
  high,
  immediate
}

@JsonSerializable()
class ModelPerformanceMetrics {
  final String id;
  final String modelId;
  final DateTime evaluationDate;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double auc;
  final Map<String, double> classMetrics;
  final Map<String, dynamic> confusionMatrix;
  final Map<String, dynamic> metadata;

  const ModelPerformanceMetrics({
    required this.id,
    required this.modelId,
    required this.evaluationDate,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.auc,
    this.classMetrics = const {},
    this.confusionMatrix = const {},
    this.metadata = const {},
  });

  factory ModelPerformanceMetrics.fromJson(Map<String, dynamic> json) => _$ModelPerformanceMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$ModelPerformanceMetricsToJson(this);
}

@JsonSerializable()
class FeatureImportance {
  final String featureName;
  final double importance;
  final double standardDeviation;
  final List<double> importanceHistory;
  final Map<String, dynamic> metadata;

  const FeatureImportance({
    required this.featureName,
    required this.importance,
    required this.standardDeviation,
    this.importanceHistory = const [],
    this.metadata = const {},
  });

  factory FeatureImportance.fromJson(Map<String, dynamic> json) => _$FeatureImportanceFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureImportanceToJson(this);
}

@JsonSerializable()
class ModelTrainingJob {
  final String id;
  final String modelId;
  final TrainingStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final double progress;
  final Map<String, dynamic> hyperparameters;
  final Map<String, dynamic> trainingMetrics;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const ModelTrainingJob({
    required this.id,
    required this.modelId,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.progress,
    this.hyperparameters = const {},
    this.trainingMetrics = const {},
    this.errorMessage,
    this.metadata = const {},
  });

  factory ModelTrainingJob.fromJson(Map<String, dynamic> json) => _$ModelTrainingJobFromJson(json);
  Map<String, dynamic> toJson() => _$ModelTrainingJobToJson(this);
}

enum TrainingStatus {
  pending,
  running,
  completed,
  failed,
  cancelled
}
