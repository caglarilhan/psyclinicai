import 'package:json_annotation/json_annotation.dart';

part 'ai_performance_metrics.g.dart';

@JsonSerializable()
class AIModelPerformance {
  final String modelId;
  final String modelName;
  final String taskType;
  final double accuracy;
  final double responseTime;
  final double confidenceScore;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final DateTime lastUsed;
  final Map<String, dynamic> metadata;

  const AIModelPerformance({
    required this.modelId,
    required this.modelName,
    required this.taskType,
    required this.accuracy,
    required this.responseTime,
    required this.confidenceScore,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.lastUsed,
    this.metadata = const {},
  });

  factory AIModelPerformance.fromJson(Map<String, dynamic> json) =>
      _$AIModelPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$AIModelPerformanceToJson(this);

  double get successRate => totalRequests > 0 ? successfulRequests / totalRequests : 0.0;
  
  bool get isHighPerformance => accuracy > 0.8 && responseTime < 2.0;
  
  AIModelPerformance copyWith({
    String? modelId,
    String? modelName,
    String? taskType,
    double? accuracy,
    double? responseTime,
    double? confidenceScore,
    int? totalRequests,
    int? successfulRequests,
    int? failedRequests,
    DateTime? lastUsed,
    Map<String, dynamic>? metadata,
  }) {
    return AIModelPerformance(
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      taskType: taskType ?? this.taskType,
      accuracy: accuracy ?? this.accuracy,
      responseTime: responseTime ?? this.responseTime,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      totalRequests: totalRequests ?? this.totalRequests,
      successfulRequests: successfulRequests ?? this.successfulRequests,
      failedRequests: failedRequests ?? this.failedRequests,
      lastUsed: lastUsed ?? this.lastUsed,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class AITaskResult {
  final String taskId;
  final String modelId;
  final String taskType;
  final bool success;
  final double confidence;
  final Duration responseTime;
  final String? errorMessage;
  final Map<String, dynamic> result;
  final DateTime timestamp;

  const AITaskResult({
    required this.taskId,
    required this.modelId,
    required this.taskType,
    required this.success,
    required this.confidence,
    required this.responseTime,
    this.errorMessage,
    required this.result,
    required this.timestamp,
  });

  factory AITaskResult.fromJson(Map<String, dynamic> json) =>
      _$AITaskResultFromJson(json);

  Map<String, dynamic> toJson() => _$AITaskResultToJson(this);
}

@JsonSerializable()
class AIModelComparison {
  final String taskType;
  final List<AIModelPerformance> models;
  final String? recommendedModel;
  final DateTime comparisonDate;

  const AIModelComparison({
    required this.taskType,
    required this.models,
    this.recommendedModel,
    required this.comparisonDate,
  });

  factory AIModelComparison.fromJson(Map<String, dynamic> json) =>
      _$AIModelComparisonFromJson(json);

  Map<String, dynamic> toJson() => _$AIModelComparisonToJson(this);

  AIModelPerformance? get bestPerformingModel {
    if (models.isEmpty) return null;
    return models.reduce((a, b) => a.accuracy > b.accuracy ? a : b);
  }
}
