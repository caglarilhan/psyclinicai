/// AI Model Training Models for PsyClinicAI
/// This file contains all the data models needed for AI model training functionality

import 'package:json_annotation/json_annotation.dart';

part 'ai_training_models.g.dart';

/// AI Model Training Status
enum TrainingStatus {
  @JsonValue('pending') pending,
  @JsonValue('in_progress') inProgress,
  @JsonValue('completed') completed,
  @JsonValue('failed') failed,
  @JsonValue('cancelled') cancelled,
  @JsonValue('paused') paused,
}

/// Training Data Type
enum TrainingDataType {
  @JsonValue('text') text,
  @JsonValue('image') image,
  @JsonValue('audio') audio,
  @JsonValue('video') video,
  @JsonValue('tabular') tabular,
  @JsonValue('multimodal') multimodal,
}

/// Model Architecture Type
enum ModelArchitecture {
  @JsonValue('transformer') transformer,
  @JsonValue('cnn') cnn,
  @JsonValue('rnn') rnn,
  @JsonValue('lstm') lstm,
  @JsonValue('gru') gru,
  @JsonValue('autoencoder') autoencoder,
  @JsonValue('gan') gan,
  @JsonValue('custom') custom,
}

/// Training Framework
enum TrainingFramework {
  @JsonValue('pytorch') pytorch,
  @JsonValue('tensorflow') tensorflow,
  @JsonValue('keras') keras,
  @JsonValue('scikit_learn') scikitLearn,
  @JsonValue('custom') custom,
}

/// Training Data Quality
enum DataQuality {
  @JsonValue('excellent') excellent,
  @JsonValue('good') good,
  @JsonValue('fair') fair,
  @JsonValue('poor') poor,
  @JsonValue('unknown') unknown,
}

/// Training Dataset
@JsonSerializable()
class TrainingDataset {
  final String id;
  final String name;
  final String description;
  final TrainingDataType dataType;
  final int totalSamples;
  final int trainingSamples;
  final int validationSamples;
  final int testSamples;
  final Map<String, dynamic> metadata;
  final DataQuality quality;
  final List<String> tags;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const TrainingDataset({
    required this.id,
    required this.name,
    required this.description,
    required this.dataType,
    required this.totalSamples,
    required this.trainingSamples,
    required this.validationSamples,
    required this.testSamples,
    required this.metadata,
    required this.quality,
    required this.tags,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory TrainingDataset.fromJson(Map<String, dynamic> json) =>
      _$TrainingDatasetFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingDatasetToJson(this);
}

/// Training Data Sample
@JsonSerializable()
class TrainingDataSample {
  final String id;
  final String datasetId;
  final String content;
  final Map<String, dynamic> labels;
  final Map<String, dynamic> features;
  final Map<String, dynamic> metadata;
  final bool isAnnotated;
  final String? annotatorId;
  final DateTime? annotatedAt;
  final double confidence;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrainingDataSample({
    required this.id,
    required this.datasetId,
    required this.content,
    required this.labels,
    required this.features,
    required this.metadata,
    required this.isAnnotated,
    this.annotatorId,
    this.annotatedAt,
    required this.confidence,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingDataSample.fromJson(Map<String, dynamic> json) =>
      _$TrainingDataSampleFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingDataSampleToJson(this);
}

/// AI Model Definition
@JsonSerializable()
class AIModelDefinition {
  final String id;
  final String name;
  final String description;
  final ModelArchitecture architecture;
  final TrainingFramework framework;
  final Map<String, dynamic> hyperparameters;
  final Map<String, dynamic> modelConfig;
  final int parameterCount;
  final String modelSize;
  final List<String> supportedTasks;
  final List<String> supportedLanguages;
  final Map<String, dynamic> requirements;
  final String version;
  final String author;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const AIModelDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.architecture,
    required this.framework,
    required this.hyperparameters,
    required this.modelConfig,
    required this.parameterCount,
    required this.modelSize,
    required this.supportedTasks,
    required this.supportedLanguages,
    required this.requirements,
    required this.version,
    required this.author,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory AIModelDefinition.fromJson(Map<String, dynamic> json) =>
      _$AIModelDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$AIModelDefinitionToJson(this);
}

/// Training Session
@JsonSerializable()
class TrainingSession {
  final String id;
  final String modelId;
  final String datasetId;
  final String name;
  final String description;
  final TrainingStatus status;
  final Map<String, dynamic> hyperparameters;
  final Map<String, dynamic> trainingConfig;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final int currentEpoch;
  final int totalEpochs;
  final double currentLoss;
  final double currentAccuracy;
  final Map<String, dynamic> metrics;
  final Map<String, dynamic> checkpoints;
  final String? trainedModelPath;
  final String? logsPath;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrainingSession({
    required this.id,
    required this.modelId,
    required this.datasetId,
    required this.name,
    required this.description,
    required this.status,
    required this.hyperparameters,
    required this.trainingConfig,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.currentEpoch,
    required this.totalEpochs,
    required this.currentLoss,
    required this.currentAccuracy,
    required this.metrics,
    required this.checkpoints,
    this.trainedModelPath,
    this.logsPath,
    required this.metadata,
    required this.tags,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSessionToJson(this);
}

/// Training Metrics
@JsonSerializable()
class TrainingMetrics {
  final String id;
  final String sessionId;
  final int epoch;
  final double trainingLoss;
  final double validationLoss;
  final double trainingAccuracy;
  final double validationAccuracy;
  final double learningRate;
  final double gradientNorm;
  final Map<String, dynamic> additionalMetrics;
  final DateTime timestamp;

  const TrainingMetrics({
    required this.id,
    required this.sessionId,
    required this.epoch,
    required this.trainingLoss,
    required this.validationLoss,
    required this.trainingAccuracy,
    required this.validationAccuracy,
    required this.learningRate,
    required this.gradientNorm,
    required this.additionalMetrics,
    required this.timestamp,
  });

  factory TrainingMetrics.fromJson(Map<String, dynamic> json) =>
      _$TrainingMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingMetricsToJson(this);
}

/// Model Checkpoint
@JsonSerializable()
class ModelCheckpoint {
  final String id;
  final String sessionId;
  final int epoch;
  final String modelPath;
  final String optimizerPath;
  final Map<String, dynamic> metrics;
  final String checkpointType;
  final double modelSize;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const ModelCheckpoint({
    required this.id,
    required this.sessionId,
    required this.epoch,
    required this.modelPath,
    required this.optimizerPath,
    required this.metrics,
    required this.checkpointType,
    required this.modelSize,
    required this.metadata,
    required this.createdAt,
  });

  factory ModelCheckpoint.fromJson(Map<String, dynamic> json) =>
      _$ModelCheckpointFromJson(json);

  Map<String, dynamic> toJson() => _$ModelCheckpointToJson(this);
}

/// Trained Model
@JsonSerializable()
class TrainedModel {
  final String id;
  final String definitionId;
  final String sessionId;
  final String name;
  final String version;
  final String modelPath;
  final Map<String, dynamic> performance;
  final Map<String, dynamic> evaluation;
  final Map<String, dynamic> metadata;
  final List<String> supportedTasks;
  final String status;
  final DateTime trainingCompletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeployed;

  const TrainedModel({
    required this.id,
    required this.definitionId,
    required this.sessionId,
    required this.name,
    required this.version,
    required this.modelPath,
    required this.performance,
    required this.evaluation,
    required this.metadata,
    required this.supportedTasks,
    required this.status,
    required this.trainingCompletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeployed,
  });

  factory TrainedModel.fromJson(Map<String, dynamic> json) =>
      _$TrainedModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainedModelToJson(this);
}

/// Model Evaluation
@JsonSerializable()
class ModelEvaluation {
  final String id;
  final String modelId;
  final String datasetId;
  final Map<String, dynamic> metrics;
  final Map<String, dynamic> confusionMatrix;
  final Map<String, dynamic> classificationReport;
  final List<String> predictions;
  final List<String> groundTruth;
  final Map<String, dynamic> analysis;
  final String evaluatorId;
  final DateTime evaluatedAt;
  final DateTime createdAt;

  const ModelEvaluation({
    required this.id,
    required this.modelId,
    required this.datasetId,
    required this.metrics,
    required this.confusionMatrix,
    required this.classificationReport,
    required this.predictions,
    required this.groundTruth,
    required this.analysis,
    required this.evaluatorId,
    required this.evaluatedAt,
    required this.createdAt,
  });

  factory ModelEvaluation.fromJson(Map<String, dynamic> json) =>
      _$ModelEvaluationFromJson(json);

  Map<String, dynamic> toJson() => _$ModelEvaluationToJson(this);
}

/// Training Configuration
@JsonSerializable()
class TrainingConfiguration {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> hyperparameters;
  final Map<String, dynamic> dataConfig;
  final Map<String, dynamic> modelConfig;
  final Map<String, dynamic> optimizerConfig;
  final Map<String, dynamic> schedulerConfig;
  final Map<String, dynamic> augmentationConfig;
  final Map<String, dynamic> validationConfig;
  final Map<String, dynamic> checkpointConfig;
  final Map<String, dynamic> loggingConfig;
  final List<String> tags;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const TrainingConfiguration({
    required this.id,
    required this.name,
    required this.description,
    required this.hyperparameters,
    required this.dataConfig,
    required this.modelConfig,
    required this.optimizerConfig,
    required this.schedulerConfig,
    required this.augmentationConfig,
    required this.validationConfig,
    required this.checkpointConfig,
    required this.loggingConfig,
    required this.tags,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory TrainingConfiguration.fromJson(Map<String, dynamic> json) =>
      _$TrainingConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingConfigurationToJson(this);
}

/// Training Job
@JsonSerializable()
class TrainingJob {
  final String id;
  final String sessionId;
  final String configurationId;
  final String status;
  final int priority;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Duration? estimatedDuration;
  final Duration? actualDuration;
  final Map<String, dynamic> resources;
  final Map<String, dynamic> constraints;
  final String assignedTo;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrainingJob({
    required this.id,
    required this.sessionId,
    required this.configurationId,
    required this.status,
    required this.priority,
    required this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.estimatedDuration,
    this.actualDuration,
    required this.resources,
    required this.constraints,
    required this.assignedTo,
    required this.metadata,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingJob.fromJson(Map<String, dynamic> json) =>
      _$TrainingJobFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingJobToJson(this);
}

/// Model Deployment
@JsonSerializable()
class ModelDeployment {
  final String id;
  final String modelId;
  final String environment;
  final String status;
  final String endpoint;
  final Map<String, dynamic> configuration;
  final Map<String, dynamic> resources;
  final Map<String, dynamic> monitoring;
  final DateTime deployedAt;
  final DateTime? undeployedAt;
  final String deployedBy;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ModelDeployment({
    required this.id,
    required this.modelId,
    required this.environment,
    required this.status,
    required this.endpoint,
    required this.configuration,
    required this.resources,
    required this.monitoring,
    required this.deployedAt,
    this.undeployedAt,
    required this.deployedBy,
    required this.metadata,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModelDeployment.fromJson(Map<String, dynamic> json) =>
      _$ModelDeploymentFromJson(json);

  Map<String, dynamic> toJson() => _$ModelDeploymentToJson(this);
}

/// Training Progress
@JsonSerializable()
class TrainingProgress {
  final String id;
  final String sessionId;
  final int currentEpoch;
  final int totalEpochs;
  final double progress;
  final double currentLoss;
  final double currentAccuracy;
  final double learningRate;
  final Map<String, dynamic> metrics;
  final String status;
  final DateTime timestamp;
  final DateTime createdAt;

  const TrainingProgress({
    required this.id,
    required this.sessionId,
    required this.currentEpoch,
    required this.totalEpochs,
    required this.progress,
    required this.currentLoss,
    required this.currentAccuracy,
    required this.learningRate,
    required this.metrics,
    required this.status,
    required this.timestamp,
    required this.createdAt,
  });

  factory TrainingProgress.fromJson(Map<String, dynamic> json) =>
      _$TrainingProgressFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingProgressToJson(this);
}

/// Data Preprocessing Pipeline
@JsonSerializable()
class DataPreprocessingPipeline {
  final String id;
  final String name;
  final String description;
  final List<String> steps;
  final Map<String, dynamic> configuration;
  final Map<String, dynamic> parameters;
  final List<String> inputFormats;
  final List<String> outputFormats;
  final Map<String, dynamic> validation;
  final List<String> tags;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const DataPreprocessingPipeline({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.configuration,
    required this.parameters,
    required this.inputFormats,
    required this.outputFormats,
    required this.validation,
    required this.tags,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory DataPreprocessingPipeline.fromJson(Map<String, dynamic> json) =>
      _$DataPreprocessingPipelineFromJson(json);

  Map<String, dynamic> toJson() => _$DataPreprocessingPipelineToJson(this);
}

/// Model Version Control
@JsonSerializable()
class ModelVersion {
  final String id;
  final String modelId;
  final String version;
  final String description;
  final Map<String, dynamic> changes;
  final String commitHash;
  final String branch;
  final Map<String, dynamic> metadata;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isStable;

  const ModelVersion({
    required this.id,
    required this.modelId,
    required this.version,
    required this.description,
    required this.changes,
    required this.commitHash,
    required this.branch,
    required this.metadata,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isStable,
  });

  factory ModelVersion.fromJson(Map<String, dynamic> json) =>
      _$ModelVersionFromJson(json);

  Map<String, dynamic> toJson() => _$ModelVersionToJson(this);
}
