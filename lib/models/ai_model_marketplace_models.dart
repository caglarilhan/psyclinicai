import 'package:json_annotation/json_annotation.dart';

part 'ai_model_marketplace_models.g.dart';

/// AI Model definition
@JsonSerializable()
class AIModel {
  final String id;
  final String name;
  final String provider;
  final String description;
  final List<String> capabilities;
  final List<String> supportedLanguages;
  final Map<String, dynamic> parameters;
  final double costPerToken;
  final double costPerRequest;
  final double rating;
  final int usageCount;
  final bool isActive;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    required this.capabilities,
    required this.supportedLanguages,
    required this.parameters,
    required this.costPerToken,
    required this.costPerRequest,
    required this.rating,
    required this.usageCount,
    required this.isActive,
    required this.lastUpdated,
    required this.metadata,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) => _$AIModelFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelToJson(this);
}

/// AI Model Instance for active usage
@JsonSerializable()
class AIModelInstance {
  final String id;
  final String modelId;
  final String name;
  final String provider;
  final Map<String, dynamic> configuration;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final int totalRequests;
  final double totalCost;
  final Map<String, dynamic> performance;

  const AIModelInstance({
    required this.id,
    required this.modelId,
    required this.name,
    required this.provider,
    required this.configuration,
    required this.isActive,
    required this.createdAt,
    this.lastUsed,
    required this.totalRequests,
    required this.totalCost,
    required this.performance,
  });

  factory AIModelInstance.fromJson(Map<String, dynamic> json) => _$AIModelInstanceFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelInstanceToJson(this);
}

/// AI Model Performance metrics
@JsonSerializable()
class AIModelPerformance {
  final String modelId;
  final String modelName;
  final DateTime timestamp;
  final double responseTime;
  final double accuracy;
  final double costEfficiency;
  final int requestsProcessed;
  final List<String> errors;
  final Map<String, dynamic> customMetrics;

  const AIModelPerformance({
    required this.modelId,
    required this.modelName,
    required this.timestamp,
    required this.responseTime,
    required this.accuracy,
    required this.costEfficiency,
    required this.requestsProcessed,
    required this.errors,
    required this.customMetrics,
  });

  factory AIModelPerformance.fromJson(Map<String, dynamic> json) => _$AIModelPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelPerformanceToJson(this);
}

/// AI Model Request
@JsonSerializable()
class AIModelRequest {
  final String modelId;
  final String prompt;
  final Map<String, dynamic> parameters;
  final String? context;
  final List<String>? examples;
  final Map<String, dynamic>? metadata;

  const AIModelRequest({
    required this.modelId,
    required this.prompt,
    required this.parameters,
    this.context,
    this.examples,
    this.metadata,
  });

  Map<String, dynamic> toJson() => _$AIModelRequestToJson(this);
}

/// AI Model Response
@JsonSerializable()
class AIModelResponse {
  final String requestId;
  final String modelId;
  final String response;
  final Map<String, dynamic> metadata;
  final double cost;
  final int tokensUsed;
  final DateTime timestamp;
  final bool isSuccess;
  final String? error;

  const AIModelResponse({
    required this.requestId,
    required this.modelId,
    required this.response,
    required this.metadata,
    required this.cost,
    required this.tokensUsed,
    required this.timestamp,
    required this.isSuccess,
    this.error,
  });

  factory AIModelResponse.fromJson(Map<String, dynamic> json) => _$AIModelResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelResponseToJson(this);
}
