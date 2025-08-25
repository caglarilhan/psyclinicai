import 'package:json_annotation/json_annotation.dart';

part 'advanced_analytics_models.g.dart';

/// Business Intelligence Dashboard Data
@JsonSerializable()
class BIDashboardData {
  final Map<String, dynamic> financialMetrics;
  final Map<String, dynamic> operationalMetrics;
  final Map<String, dynamic> patientMetrics;
  final Map<String, dynamic> staffMetrics;
  final Map<String, dynamic> qualityMetrics;
  final DateTime lastUpdated;

  const BIDashboardData({
    required this.financialMetrics,
    required this.operationalMetrics,
    required this.patientMetrics,
    required this.staffMetrics,
    required this.qualityMetrics,
    required this.lastUpdated,
  });

  factory BIDashboardData.fromJson(Map<String, dynamic> json) => _$BIDashboardDataFromJson(json);
  Map<String, dynamic> toJson() => _$BIDashboardDataToJson(this);
}

/// Predictive Analytics Model
@JsonSerializable()
class PredictiveModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final double accuracy;
  final DateTime lastTrained;
  final Map<String, dynamic> parameters;
  final List<String> features;
  final Map<String, dynamic> performance;

  const PredictiveModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.accuracy,
    required this.lastTrained,
    required this.parameters,
    required this.features,
    required this.performance,
  });

  factory PredictiveModel.fromJson(Map<String, dynamic> json) => _$PredictiveModelFromJson(json);
  Map<String, dynamic> toJson() => _$PredictiveModelToJson(this);
}

/// Performance Metrics
@JsonSerializable()
class PerformanceMetrics {
  final String metricId;
  final String name;
  final String category;
  final double currentValue;
  final double previousValue;
  final double targetValue;
  final double changePercentage;
  final String trend;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  const PerformanceMetrics({
    required this.metricId,
    required this.name,
    required this.category,
    required this.currentValue,
    required this.previousValue,
    required this.targetValue,
    required this.changePercentage,
    required this.trend,
    required this.lastUpdated,
    required this.metadata,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) => _$PerformanceMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceMetricsToJson(this);
}
