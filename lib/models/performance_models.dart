import 'package:json_annotation/json_annotation.dart';

part 'performance_models.g.dart';

/// Performance Optimization Models for PsyClinicAI

@JsonSerializable()
class CacheEntry {
  final String key;
  final dynamic value;
  final DateTime createdAt;
  DateTime lastAccessed;
  final DateTime expiresAt;
  int accessCount;
  final int size;

  CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.lastAccessed,
    required this.expiresAt,
    required this.accessCount,
    required this.size,
  });

  factory CacheEntry.fromJson(Map<String, dynamic> json) => _$CacheEntryFromJson(json);
  Map<String, dynamic> toJson() => _$CacheEntryToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

@JsonSerializable()
class DatabaseQuery {
  final String queryHash;
  final QueryResult result;
  final DateTime createdAt;
  DateTime lastAccessed;
  final DateTime expiresAt;
  int hitCount;
  final int executionTime;

  DatabaseQuery({
    required this.queryHash,
    required this.result,
    required this.createdAt,
    required this.lastAccessed,
    required this.expiresAt,
    required this.hitCount,
    required this.executionTime,
  });

  factory DatabaseQuery.fromJson(Map<String, dynamic> json) => _$DatabaseQueryFromJson(json);
  Map<String, dynamic> toJson() => _$DatabaseQueryToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

@JsonSerializable()
class QueryResult {
  final List<Map<String, dynamic>> rows;
  final int executionTime;
  final int affectedRows;

  const QueryResult({
    required this.rows,
    required this.executionTime,
    required this.affectedRows,
  });

  factory QueryResult.fromJson(Map<String, dynamic> json) => _$QueryResultFromJson(json);
  Map<String, dynamic> toJson() => _$QueryResultToJson(this);
}

@JsonSerializable()
class LoadBalancer {
  final String id;
  final String name;
  final LoadBalancingAlgorithm algorithm;
  final List<ServerInstance> servers;
  final HealthCheckConfig healthCheck;

  const LoadBalancer({
    required this.id,
    required this.name,
    required this.algorithm,
    required this.servers,
    required this.healthCheck,
  });

  factory LoadBalancer.fromJson(Map<String, dynamic> json) => _$LoadBalancerFromJson(json);
  Map<String, dynamic> toJson() => _$LoadBalancerToJson(this);
}

@JsonSerializable()
class ServerInstance {
  final String id;
  final String host;
  final int port;
  final int weight;
  final ServerStatus status;
  final int currentConnections;
  final int maxConnections;

  const ServerInstance({
    required this.id,
    required this.host,
    required this.port,
    required this.weight,
    required this.status,
    required this.currentConnections,
    required this.maxConnections,
  });

  factory ServerInstance.fromJson(Map<String, dynamic> json) => _$ServerInstanceFromJson(json);
  Map<String, dynamic> toJson() => _$ServerInstanceToJson(this);
}

@JsonSerializable()
class HealthCheckConfig {
  final Duration interval;
  final Duration timeout;
  final String endpoint;
  final int expectedStatus;

  const HealthCheckConfig({
    required this.interval,
    required this.timeout,
    required this.endpoint,
    required this.expectedStatus,
  });

  factory HealthCheckConfig.fromJson(Map<String, dynamic> json) => _$HealthCheckConfigFromJson(json);
  Map<String, dynamic> toJson() => _$HealthCheckConfigToJson(this);
}

@JsonSerializable()
class PerformanceMetric {
  final DateTime timestamp;
  final MetricType metricType;
  final double value;
  final String unit;
  final Map<String, String> tags;

  const PerformanceMetric({
    required this.timestamp,
    required this.metricType,
    required this.value,
    required this.unit,
    this.tags = const {},
  });

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) => _$PerformanceMetricFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceMetricToJson(this);
}

@JsonSerializable()
class CacheMetrics {
  final int totalEntries;
  final int memoryEntries;
  final int queryEntries;
  final int computationEntries;
  final double hitRatio;
  final int totalHits;
  final int totalMisses;
  final int evictions;
  final int memoryUsage;

  const CacheMetrics({
    required this.totalEntries,
    required this.memoryEntries,
    required this.queryEntries,
    required this.computationEntries,
    required this.hitRatio,
    required this.totalHits,
    required this.totalMisses,
    required this.evictions,
    required this.memoryUsage,
  });

  factory CacheMetrics.fromJson(Map<String, dynamic> json) => _$CacheMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$CacheMetricsToJson(this);
}

@JsonSerializable()
class OptimizationAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final List<String> recommendations;

  const OptimizationAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    this.recommendations = const [],
  });

  factory OptimizationAlert.fromJson(Map<String, dynamic> json) => _$OptimizationAlertFromJson(json);
  Map<String, dynamic> toJson() => _$OptimizationAlertToJson(this);
}

@JsonSerializable()
class PerformanceAnalytics {
  final DateTime startDate;
  final DateTime endDate;
  final double averageCpuUsage;
  final double averageMemoryUsage;
  final double averageResponseTime;
  final double averageThroughput;
  final CacheMetrics cacheMetrics;
  final List<OptimizationRecommendation> optimizationRecommendations;

  const PerformanceAnalytics({
    required this.startDate,
    required this.endDate,
    required this.averageCpuUsage,
    required this.averageMemoryUsage,
    required this.averageResponseTime,
    required this.averageThroughput,
    required this.cacheMetrics,
    required this.optimizationRecommendations,
  });

  factory PerformanceAnalytics.fromJson(Map<String, dynamic> json) => _$PerformanceAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceAnalyticsToJson(this);
}

@JsonSerializable()
class OptimizationRecommendation {
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final String estimatedImpact;
  final RecommendationCost implementationCost;

  const OptimizationRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.estimatedImpact,
    required this.implementationCost,
  });

  factory OptimizationRecommendation.fromJson(Map<String, dynamic> json) => _$OptimizationRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$OptimizationRecommendationToJson(this);
}

// Enums
enum LoadBalancingAlgorithm { roundRobin, leastConnections, weighted, ipHash }
enum ServerStatus { healthy, unhealthy, degraded, maintenance }
enum MetricType { cpu, memory, responseTime, throughput, errorRate, diskUsage }
enum OptimizationType { caching, database, loadBalancing, compression, cdn }
enum AlertType { highCpuUsage, highMemoryUsage, slowResponseTime, lowCacheHitRatio, databaseConnectionIssues }
enum AlertSeverity { low, medium, high, critical }
enum RecommendationType { scaleOut, scaleUp, caching, databaseOptimization, memoryOptimization, networkOptimization }
enum RecommendationPriority { low, medium, high, critical }
enum RecommendationCost { low, medium, high, enterprise }
