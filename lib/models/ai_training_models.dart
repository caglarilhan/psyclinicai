/// AI Model Training Models for PsyClinicAI
/// This file contains all the data models needed for AI model training functionality

import 'package:json_annotation/json_annotation.dart';

part 'ai_training_models.g.dart';

/// Training job status enumeration
enum TrainingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('running')
  running,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
}

/// Model category enumeration
enum ModelCategory {
  @JsonValue('diagnosis')
  diagnosis,
  @JsonValue('treatment')
  treatment,
  @JsonValue('riskAssessment')
  riskAssessment,
  @JsonValue('prognosis')
  prognosis,
  @JsonValue('screening')
  screening,
  @JsonValue('monitoring')
  monitoring,
}

/// Dataset format enumeration
enum DatasetFormat {
  @JsonValue('csv')
  csv,
  @JsonValue('json')
  json,
  @JsonValue('parquet')
  parquet,
  @JsonValue('hdf5')
  hdf5,
  @JsonValue('numpy')
  numpy,
  @JsonValue('pandas')
  pandas,
}

/// Training job model
@JsonSerializable()
class TrainingJob {
  final String id;
  final String modelName;
  final String description;
  final ModelCategory category;
  final String templateId;
  final String templateName;
  final String datasetId;
  final String datasetName;
  final TrainingStatus status;
  final int progress;
  final int currentEpoch;
  final int totalEpochs;
  final double currentAccuracy;
  final double currentLoss;
  final Duration elapsedTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> hyperparameters;
  final List<String> logs;
  final String? errorMessage;
  final Map<String, dynamic>? metrics;

  const TrainingJob({
    required this.id,
    required this.modelName,
    required this.description,
    required this.category,
    required this.templateId,
    required this.templateName,
    required this.datasetId,
    required this.datasetName,
    required this.status,
    required this.progress,
    required this.currentEpoch,
    required this.totalEpochs,
    required this.currentAccuracy,
    required this.currentLoss,
    required this.elapsedTime,
    required this.createdAt,
    required this.updatedAt,
    required this.hyperparameters,
    required this.logs,
    this.errorMessage,
    this.metrics,
  });

  factory TrainingJob.fromJson(Map<String, dynamic> json) => _$TrainingJobFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingJobToJson(this);

  /// Create a copy with updated values
  TrainingJob copyWith({
    String? id,
    String? modelName,
    String? description,
    ModelCategory? category,
    String? templateId,
    String? templateName,
    String? datasetId,
    String? datasetName,
    TrainingStatus? status,
    int? progress,
    int? currentEpoch,
    int? totalEpochs,
    double? currentAccuracy,
    double? currentLoss,
    Duration? elapsedTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? hyperparameters,
    List<String>? logs,
    String? errorMessage,
    Map<String, dynamic>? metrics,
  }) {
    return TrainingJob(
      id: id ?? this.id,
      modelName: modelName ?? this.modelName,
      description: description ?? this.description,
      category: category ?? this.category,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      datasetId: datasetId ?? this.datasetId,
      datasetName: datasetName ?? this.datasetName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentEpoch: currentEpoch ?? this.currentEpoch,
      totalEpochs: totalEpochs ?? this.totalEpochs,
      currentAccuracy: currentAccuracy ?? this.currentAccuracy,
      currentLoss: currentLoss ?? this.currentLoss,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hyperparameters: hyperparameters ?? this.hyperparameters,
      logs: logs ?? this.logs,
      errorMessage: errorMessage ?? this.errorMessage,
      metrics: metrics ?? this.metrics,
    );
  }

  /// Check if training is in progress
  bool get isRunning => status == TrainingStatus.running;
  
  /// Check if training is completed
  bool get isCompleted => status == TrainingStatus.completed;
  
  /// Check if training failed
  bool get isFailed => status == TrainingStatus.failed;
  
  /// Check if training can be resumed
  bool get canResume => status == TrainingStatus.paused;
  
  /// Check if training can be stopped
  bool get canStop => status == TrainingStatus.running;
}

/// Custom trained model
@JsonSerializable()
class CustomModel {
  final String id;
  final String name;
  final String description;
  final ModelCategory category;
  final String version;
  final double size; // in MB
  final DateTime createdAt;
  final DateTime updatedAt;
  final ModelPerformance performance;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final bool isDeployed;
  final String? deploymentUrl;
  final Map<String, dynamic>? configuration;

  const CustomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.version,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
    required this.performance,
    required this.metadata,
    required this.tags,
    required this.isDeployed,
    this.deploymentUrl,
    this.configuration,
  });

  factory CustomModel.fromJson(Map<String, dynamic> json) => _$CustomModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomModelToJson(this);

  /// Create a copy with updated values
  CustomModel copyWith({
    String? id,
    String? name,
    String? description,
    ModelCategory? category,
    String? version,
    double? size,
    DateTime? createdAt,
    DateTime? updatedAt,
    ModelPerformance? performance,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isDeployed,
    String? deploymentUrl,
    Map<String, dynamic>? configuration,
  }) {
    return CustomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      version: version ?? this.version,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      performance: performance ?? this.performance,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      isDeployed: isDeployed ?? this.isDeployed,
      deploymentUrl: deploymentUrl ?? this.deploymentUrl,
      configuration: configuration ?? this.configuration,
    );
  }
}

/// Model performance metrics
@JsonSerializable()
class ModelPerformance {
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double auc;
  final double mse;
  final double mae;
  final Map<String, double> classMetrics;
  final Map<String, double> customMetrics;

  const ModelPerformance({
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.auc,
    required this.mse,
    required this.mae,
    required this.classMetrics,
    required this.customMetrics,
  });

  factory ModelPerformance.fromJson(Map<String, dynamic> json) => _$ModelPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$ModelPerformanceToJson(this);

  /// Calculate overall performance score
  double get overallScore {
    return (accuracy + precision + recall + f1Score) / 4.0;
  }

  /// Check if performance meets minimum thresholds
  bool get meetsThresholds {
    return accuracy >= 0.8 && precision >= 0.8 && recall >= 0.8 && f1Score >= 0.8;
  }
}

/// Dataset model
@JsonSerializable()
class Dataset {
  final String id;
  final String name;
  final String description;
  final DatasetFormat format;
  final int samples;
  final int features;
  final double size; // in MB
  final DateTime createdAt;
  final DateTime updatedAt;
  final double quality;
  final double trainSplit;
  final double validationSplit;
  final double testSplit;
  final Map<String, dynamic> schema;
  final List<String> columns;
  final Map<String, dynamic> statistics;
  final List<String> tags;
  final String? source;
  final Map<String, dynamic>? metadata;

  const Dataset({
    required this.id,
    required this.name,
    required this.description,
    required this.format,
    required this.samples,
    required this.features,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
    required this.quality,
    required this.trainSplit,
    required this.validationSplit,
    required this.testSplit,
    required this.schema,
    required this.columns,
    required this.statistics,
    required this.tags,
    this.source,
    this.metadata,
  });

  factory Dataset.fromJson(Map<String, dynamic> json) => _$DatasetFromJson(json);
  Map<String, dynamic> toJson() => _$DatasetToJson(this);

  /// Create a copy with updated values
  Dataset copyWith({
    String? id,
    String? name,
    String? description,
    DatasetFormat? format,
    int? samples,
    int? features,
    double? size,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? quality,
    double? trainSplit,
    double? validationSplit,
    double? testSplit,
    Map<String, dynamic>? schema,
    List<String>? columns,
    Map<String, dynamic>? statistics,
    List<String>? tags,
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return Dataset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      format: format ?? this.format,
      samples: samples ?? this.samples,
      features: features ?? this.features,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quality: quality ?? this.quality,
      trainSplit: trainSplit ?? this.trainSplit,
      validationSplit: validationSplit ?? this.validationSplit,
      testSplit: testSplit ?? this.testSplit,
      schema: schema ?? this.schema,
      columns: columns ?? this.columns,
      statistics: statistics ?? this.statistics,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if dataset is ready for training
  bool get isReadyForTraining {
    return quality >= 0.7 && samples >= 100 && features >= 5;
  }

  /// Get total split percentages
  double get totalSplit {
    return trainSplit + validationSplit + testSplit;
  }

  /// Validate split percentages
  bool get hasValidSplit {
    return (totalSplit - 1.0).abs() < 0.01;
  }
}

/// Model template for training
@JsonSerializable()
class ModelTemplate {
  final String id;
  final String name;
  final String description;
  final ModelCategory category;
  final String architecture;
  final int parameters; // in millions
  final double size; // in MB
  final List<String> supportedTasks;
  final Map<String, dynamic> defaultHyperparameters;
  final Map<String, dynamic> constraints;
  final List<String> requirements;
  final String? paperUrl;
  final String? repositoryUrl;
  final Map<String, dynamic>? metadata;

  const ModelTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.architecture,
    required this.parameters,
    required this.size,
    required this.supportedTasks,
    required this.defaultHyperparameters,
    required this.constraints,
    required this.requirements,
    this.paperUrl,
    this.repositoryUrl,
    this.metadata,
  });

  factory ModelTemplate.fromJson(Map<String, dynamic> json) => _$ModelTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$ModelTemplateToJson(this);

  /// Create a copy with updated values
  ModelTemplate copyWith({
    String? id,
    String? name,
    String? description,
    ModelCategory? category,
    String? architecture,
    int? parameters,
    double? size,
    List<String>? supportedTasks,
    Map<String, dynamic>? defaultHyperparameters,
    Map<String, dynamic>? constraints,
    List<String>? requirements,
    String? paperUrl,
    String? repositoryUrl,
    Map<String, dynamic>? metadata,
  }) {
    return ModelTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      architecture: architecture ?? this.architecture,
      parameters: parameters ?? this.parameters,
      size: size ?? this.size,
      supportedTasks: supportedTasks ?? this.supportedTasks,
      defaultHyperparameters: defaultHyperparameters ?? this.defaultHyperparameters,
      constraints: constraints ?? this.constraints,
      requirements: requirements ?? this.requirements,
      paperUrl: paperUrl ?? this.paperUrl,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if template supports a specific task
  bool supportsTask(String task) {
    return supportedTasks.contains(task);
  }

  /// Get formatted parameter count
  String get formattedParameters {
    if (parameters >= 1000) {
      return '${(parameters / 1000).toStringAsFixed(1)}B';
    }
    return '${parameters}M';
  }
}

/// Training configuration
@JsonSerializable()
class TrainingConfig {
  final String modelName;
  final String description;
  final ModelCategory category;
  final String templateId;
  final String datasetId;
  final double learningRate;
  final int epochs;
  final int batchSize;
  final double validationSplit;
  final Map<String, dynamic> hyperparameters;
  final Map<String, dynamic> augmentation;
  final Map<String, dynamic> callbacks;
  final Map<String, dynamic> optimizer;
  final Map<String, dynamic> lossFunction;
  final Map<String, dynamic> metrics;

  const TrainingConfig({
    required this.modelName,
    required this.description,
    required this.category,
    required this.templateId,
    required this.datasetId,
    required this.learningRate,
    required this.epochs,
    required this.batchSize,
    required this.validationSplit,
    required this.hyperparameters,
    required this.augmentation,
    required this.callbacks,
    required this.optimizer,
    required this.lossFunction,
    required this.metrics,
  });

  factory TrainingConfig.fromJson(Map<String, dynamic> json) => _$TrainingConfigFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingConfigToJson(this);

  /// Validate configuration
  bool get isValid {
    return modelName.isNotEmpty &&
           description.isNotEmpty &&
           templateId.isNotEmpty &&
           datasetId.isNotEmpty &&
           learningRate > 0 &&
           epochs > 0 &&
           batchSize > 0 &&
           validationSplit > 0 &&
           validationSplit < 1;
  }

  /// Get configuration summary
  Map<String, dynamic> get summary {
    return {
      'modelName': modelName,
      'category': category.name,
      'templateId': templateId,
      'datasetId': datasetId,
      'learningRate': learningRate,
      'epochs': epochs,
      'batchSize': batchSize,
      'validationSplit': validationSplit,
    };
  }
}

/// Training metrics
@JsonSerializable()
class TrainingMetrics {
  final double loss;
  final double accuracy;
  final double valLoss;
  final double valAccuracy;
  final int epoch;
  final Duration duration;
  final Map<String, double> customMetrics;
  final Map<String, dynamic> metadata;

  const TrainingMetrics({
    required this.loss,
    required this.accuracy,
    required this.valLoss,
    required this.valAccuracy,
    required this.epoch,
    required this.duration,
    required this.customMetrics,
    required this.metadata,
  });

  factory TrainingMetrics.fromJson(Map<String, dynamic> json) => _$TrainingMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingMetricsToJson(this);

  /// Check if metrics indicate overfitting
  bool get isOverfitting {
    return valLoss > loss * 1.2 && valAccuracy < accuracy * 0.9;
  }

  /// Check if metrics indicate underfitting
  bool get isUnderfitting {
    return loss > 0.5 && accuracy < 0.6;
  }

  /// Get training progress percentage
  double get progress {
    return (epoch / 100.0).clamp(0.0, 1.0); // Assuming 100 epochs as standard
  }
}

/// Training log entry
@JsonSerializable()
class TrainingLog {
  final DateTime timestamp;
  final String level; // info, warning, error
  final String message;
  final Map<String, dynamic>? data;
  final String? source;

  const TrainingLog({
    required this.timestamp,
    required this.level,
    required this.message,
    this.data,
    this.source,
  });

  factory TrainingLog.fromJson(Map<String, dynamic> json) => _$TrainingLogFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingLogToJson(this);

  /// Check if log is an error
  bool get isError => level == 'error';
  
  /// Check if log is a warning
  bool get isWarning => level == 'warning';
  
  /// Check if log is info
  bool get isInfo => level == 'info';

  /// Format timestamp for display
  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}

/// Model deployment configuration
@JsonSerializable()
class DeploymentConfig {
  final String modelId;
  final String environment; // production, staging, development
  final Map<String, dynamic> resources;
  final Map<String, dynamic> scaling;
  final Map<String, dynamic> monitoring;
  final Map<String, dynamic> security;
  final List<String> endpoints;
  final Map<String, dynamic> metadata;

  const DeploymentConfig({
    required this.modelId,
    required this.environment,
    required this.resources,
    required this.scaling,
    required this.monitoring,
    required this.security,
    required this.endpoints,
    required this.metadata,
  });

  factory DeploymentConfig.fromJson(Map<String, dynamic> json) => _$DeploymentConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DeploymentConfigToJson(this);

  /// Check if deployment is production
  bool get isProduction => environment == 'production';
  
  /// Check if deployment is staging
  bool get isStaging => environment == 'staging';
  
  /// Check if deployment is development
  bool get isDevelopment => environment == 'development';
}

/// Model evaluation result
@JsonSerializable()
class ModelEvaluation {
  final String modelId;
  final String datasetId;
  final DateTime evaluatedAt;
  final ModelPerformance performance;
  final Map<String, dynamic> predictions;
  final Map<String, dynamic> confusionMatrix;
  final List<String> errors;
  final Map<String, dynamic> metadata;

  const ModelEvaluation({
    required this.modelId,
    required this.datasetId,
    required this.evaluatedAt,
    required this.performance,
    required this.predictions,
    required this.confusionMatrix,
    required this.errors,
    required this.metadata,
  });

  factory ModelEvaluation.fromJson(Map<String, dynamic> json) => _$ModelEvaluationFromJson(json);
  Map<String, dynamic> toJson() => _$ModelEvaluationToJson(this);

  /// Check if evaluation passed quality thresholds
  bool get passedQualityCheck {
    return performance.meetsThresholds && errors.isEmpty;
  }

  /// Get evaluation summary
  Map<String, dynamic> get summary {
    return {
      'modelId': modelId,
      'datasetId': datasetId,
      'evaluatedAt': evaluatedAt.toIso8601String(),
      'accuracy': performance.accuracy,
      'passed': passedQualityCheck,
      'errorCount': errors.length,
    };
  }
}

/// Training job request
@JsonSerializable()
class TrainingJobRequest {
  final String modelName;
  final String description;
  final ModelCategory category;
  final String templateId;
  final String datasetId;
  final double learningRate;
  final int epochs;
  final int batchSize;
  final double validationSplit;
  final Map<String, dynamic>? customHyperparameters;
  final Map<String, dynamic>? augmentation;
  final Map<String, dynamic>? callbacks;
  final Map<String, dynamic>? optimizer;
  final Map<String, dynamic>? lossFunction;
  final Map<String, dynamic>? metrics;

  const TrainingJobRequest({
    required this.modelName,
    required this.description,
    required this.category,
    required this.templateId,
    required this.datasetId,
    required this.learningRate,
    required this.epochs,
    required this.batchSize,
    required this.validationSplit,
    this.customHyperparameters,
    this.augmentation,
    this.callbacks,
    this.optimizer,
    this.lossFunction,
    this.metrics,
  });

  factory TrainingJobRequest.fromJson(Map<String, dynamic> json) => _$TrainingJobRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingJobRequestToJson(this);

  /// Validate request
  bool get isValid {
    return modelName.isNotEmpty &&
           description.isNotEmpty &&
           templateId.isNotEmpty &&
           datasetId.isNotEmpty &&
           learningRate > 0 &&
           epochs > 0 &&
           batchSize > 0 &&
           validationSplit > 0 &&
           validationSplit < 1;
  }

  /// Convert to training configuration
  TrainingConfig toTrainingConfig() {
    return TrainingConfig(
      modelName: modelName,
      description: description,
      category: category,
      templateId: templateId,
      datasetId: datasetId,
      learningRate: learningRate,
      epochs: epochs,
      batchSize: batchSize,
      validationSplit: validationSplit,
      hyperparameters: customHyperparameters ?? {},
      augmentation: augmentation ?? {},
      callbacks: callbacks ?? {},
      optimizer: optimizer ?? {},
      lossFunction: lossFunction ?? {},
      metrics: metrics ?? {},
    );
  }
}

/// Training job response
@JsonSerializable()
class TrainingJobResponse {
  final bool success;
  final String? jobId;
  final String? message;
  final Map<String, dynamic>? data;
  final List<String>? errors;

  const TrainingJobResponse({
    required this.success,
    this.jobId,
    this.message,
    this.data,
    this.errors,
  });

  factory TrainingJobResponse.fromJson(Map<String, dynamic> json) => _$TrainingJobResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingJobResponseToJson(this);

  /// Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  
  /// Get first error message
  String? get firstError => hasErrors ? errors!.first : null;
}

/// Model export configuration
@JsonSerializable()
class ModelExportConfig {
  final String modelId;
  final String format; // onnx, tensorflow, pytorch, etc.
  final Map<String, dynamic> options;
  final bool includeMetadata;
  final bool includeWeights;
  final String? outputPath;
  final Map<String, dynamic>? customOptions;

  const ModelExportConfig({
    required this.modelId,
    required this.format,
    required this.options,
    required this.includeMetadata,
    required this.includeWeights,
    this.outputPath,
    this.customOptions,
  });

  factory ModelExportConfig.fromJson(Map<String, dynamic> json) => _$ModelExportConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ModelExportConfigToJson(this);

  /// Check if export includes all components
  bool get isCompleteExport => includeMetadata && includeWeights;
  
  /// Get export options summary
  Map<String, dynamic> get summary {
    return {
      'modelId': modelId,
      'format': format,
      'includeMetadata': includeMetadata,
      'includeWeights': includeWeights,
      'outputPath': outputPath,
    };
  }
}

/// Dataset upload configuration
@JsonSerializable()
class DatasetUploadConfig {
  final String name;
  final String description;
  final DatasetFormat format;
  final String filePath;
  final double trainSplit;
  final double validationSplit;
  final double testSplit;
  final Map<String, dynamic>? schema;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;

  const DatasetUploadConfig({
    required this.name,
    required this.description,
    required this.format,
    required this.filePath,
    required this.trainSplit,
    required this.validationSplit,
    required this.testSplit,
    this.schema,
    this.tags,
    this.metadata,
  });

  factory DatasetUploadConfig.fromJson(Map<String, dynamic> json) => _$DatasetUploadConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DatasetUploadConfigToJson(this);

  /// Validate upload configuration
  bool get isValid {
    return name.isNotEmpty &&
           description.isNotEmpty &&
           filePath.isNotEmpty &&
           trainSplit > 0 &&
           validationSplit > 0 &&
           testSplit > 0 &&
           (trainSplit + validationSplit + testSplit - 1.0).abs() < 0.01;
  }

  /// Get split summary
  Map<String, double> get splitSummary {
    return {
      'train': trainSplit,
      'validation': validationSplit,
      'test': testSplit,
      'total': trainSplit + validationSplit + testSplit,
    };
  }
}

/// Dataset validation result
@JsonSerializable()
class DatasetValidationResult {
  final bool isValid;
  final int samples;
  final int features;
  final double size;
  final double quality;
  final List<String> warnings;
  final List<String> errors;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic> schema;

  const DatasetValidationResult({
    required this.isValid,
    required this.samples,
    required this.features,
    required this.size,
    required this.quality,
    required this.warnings,
    required this.errors,
    required this.statistics,
    required this.schema,
  });

  factory DatasetValidationResult.fromJson(Map<String, dynamic> json) => _$DatasetValidationResultFromJson(json);
  Map<String, dynamic> toJson() => _$DatasetValidationResultToJson(this);

  /// Check if dataset has warnings
  bool get hasWarnings => warnings.isNotEmpty;
  
  /// Check if dataset has errors
  bool get hasErrors => errors.isNotEmpty;
  
  /// Get validation summary
  Map<String, dynamic> get summary {
    return {
      'isValid': isValid,
      'samples': samples,
      'features': features,
      'size': size,
      'quality': quality,
      'warningCount': warnings.length,
      'errorCount': errors.length,
    };
  }
}
