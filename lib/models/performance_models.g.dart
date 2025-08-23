// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheEntry _$CacheEntryFromJson(Map<String, dynamic> json) => CacheEntry(
  key: json['key'] as String,
  value: json['value'],
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastAccessed: DateTime.parse(json['lastAccessed'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  accessCount: (json['accessCount'] as num).toInt(),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$CacheEntryToJson(CacheEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastAccessed': instance.lastAccessed.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'accessCount': instance.accessCount,
      'size': instance.size,
    };

DatabaseQuery _$DatabaseQueryFromJson(Map<String, dynamic> json) =>
    DatabaseQuery(
      queryHash: json['queryHash'] as String,
      result: QueryResult.fromJson(json['result'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      hitCount: (json['hitCount'] as num).toInt(),
      executionTime: (json['executionTime'] as num).toInt(),
    );

Map<String, dynamic> _$DatabaseQueryToJson(DatabaseQuery instance) =>
    <String, dynamic>{
      'queryHash': instance.queryHash,
      'result': instance.result,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastAccessed': instance.lastAccessed.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'hitCount': instance.hitCount,
      'executionTime': instance.executionTime,
    };

QueryResult _$QueryResultFromJson(Map<String, dynamic> json) => QueryResult(
  rows: (json['rows'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  executionTime: (json['executionTime'] as num).toInt(),
  affectedRows: (json['affectedRows'] as num).toInt(),
);

Map<String, dynamic> _$QueryResultToJson(QueryResult instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'executionTime': instance.executionTime,
      'affectedRows': instance.affectedRows,
    };

LoadBalancer _$LoadBalancerFromJson(Map<String, dynamic> json) => LoadBalancer(
  id: json['id'] as String,
  name: json['name'] as String,
  algorithm: $enumDecode(_$LoadBalancingAlgorithmEnumMap, json['algorithm']),
  servers: (json['servers'] as List<dynamic>)
      .map((e) => ServerInstance.fromJson(e as Map<String, dynamic>))
      .toList(),
  healthCheck: HealthCheckConfig.fromJson(
    json['healthCheck'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$LoadBalancerToJson(LoadBalancer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'algorithm': _$LoadBalancingAlgorithmEnumMap[instance.algorithm]!,
      'servers': instance.servers,
      'healthCheck': instance.healthCheck,
    };

const _$LoadBalancingAlgorithmEnumMap = {
  LoadBalancingAlgorithm.roundRobin: 'roundRobin',
  LoadBalancingAlgorithm.leastConnections: 'leastConnections',
  LoadBalancingAlgorithm.weighted: 'weighted',
  LoadBalancingAlgorithm.ipHash: 'ipHash',
};

ServerInstance _$ServerInstanceFromJson(Map<String, dynamic> json) =>
    ServerInstance(
      id: json['id'] as String,
      host: json['host'] as String,
      port: (json['port'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      status: $enumDecode(_$ServerStatusEnumMap, json['status']),
      currentConnections: (json['currentConnections'] as num).toInt(),
      maxConnections: (json['maxConnections'] as num).toInt(),
    );

Map<String, dynamic> _$ServerInstanceToJson(ServerInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'host': instance.host,
      'port': instance.port,
      'weight': instance.weight,
      'status': _$ServerStatusEnumMap[instance.status]!,
      'currentConnections': instance.currentConnections,
      'maxConnections': instance.maxConnections,
    };

const _$ServerStatusEnumMap = {
  ServerStatus.healthy: 'healthy',
  ServerStatus.unhealthy: 'unhealthy',
  ServerStatus.degraded: 'degraded',
  ServerStatus.maintenance: 'maintenance',
};

HealthCheckConfig _$HealthCheckConfigFromJson(Map<String, dynamic> json) =>
    HealthCheckConfig(
      interval: Duration(microseconds: (json['interval'] as num).toInt()),
      timeout: Duration(microseconds: (json['timeout'] as num).toInt()),
      endpoint: json['endpoint'] as String,
      expectedStatus: (json['expectedStatus'] as num).toInt(),
    );

Map<String, dynamic> _$HealthCheckConfigToJson(HealthCheckConfig instance) =>
    <String, dynamic>{
      'interval': instance.interval.inMicroseconds,
      'timeout': instance.timeout.inMicroseconds,
      'endpoint': instance.endpoint,
      'expectedStatus': instance.expectedStatus,
    };

PerformanceMetric _$PerformanceMetricFromJson(Map<String, dynamic> json) =>
    PerformanceMetric(
      timestamp: DateTime.parse(json['timestamp'] as String),
      metricType: $enumDecode(_$MetricTypeEnumMap, json['metricType']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      tags:
          (json['tags'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$PerformanceMetricToJson(PerformanceMetric instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'metricType': _$MetricTypeEnumMap[instance.metricType]!,
      'value': instance.value,
      'unit': instance.unit,
      'tags': instance.tags,
    };

const _$MetricTypeEnumMap = {
  MetricType.cpu: 'cpu',
  MetricType.memory: 'memory',
  MetricType.responseTime: 'responseTime',
  MetricType.throughput: 'throughput',
  MetricType.errorRate: 'errorRate',
  MetricType.diskUsage: 'diskUsage',
};

CacheMetrics _$CacheMetricsFromJson(Map<String, dynamic> json) => CacheMetrics(
  totalEntries: (json['totalEntries'] as num).toInt(),
  memoryEntries: (json['memoryEntries'] as num).toInt(),
  queryEntries: (json['queryEntries'] as num).toInt(),
  computationEntries: (json['computationEntries'] as num).toInt(),
  hitRatio: (json['hitRatio'] as num).toDouble(),
  totalHits: (json['totalHits'] as num).toInt(),
  totalMisses: (json['totalMisses'] as num).toInt(),
  evictions: (json['evictions'] as num).toInt(),
  memoryUsage: (json['memoryUsage'] as num).toInt(),
);

Map<String, dynamic> _$CacheMetricsToJson(CacheMetrics instance) =>
    <String, dynamic>{
      'totalEntries': instance.totalEntries,
      'memoryEntries': instance.memoryEntries,
      'queryEntries': instance.queryEntries,
      'computationEntries': instance.computationEntries,
      'hitRatio': instance.hitRatio,
      'totalHits': instance.totalHits,
      'totalMisses': instance.totalMisses,
      'evictions': instance.evictions,
      'memoryUsage': instance.memoryUsage,
    };

OptimizationAlert _$OptimizationAlertFromJson(Map<String, dynamic> json) =>
    OptimizationAlert(
      id: json['id'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OptimizationAlertToJson(OptimizationAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'recommendations': instance.recommendations,
    };

const _$AlertTypeEnumMap = {
  AlertType.highCpuUsage: 'highCpuUsage',
  AlertType.highMemoryUsage: 'highMemoryUsage',
  AlertType.slowResponseTime: 'slowResponseTime',
  AlertType.lowCacheHitRatio: 'lowCacheHitRatio',
  AlertType.databaseConnectionIssues: 'databaseConnectionIssues',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

PerformanceAnalytics _$PerformanceAnalyticsFromJson(
  Map<String, dynamic> json,
) => PerformanceAnalytics(
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  averageCpuUsage: (json['averageCpuUsage'] as num).toDouble(),
  averageMemoryUsage: (json['averageMemoryUsage'] as num).toDouble(),
  averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
  averageThroughput: (json['averageThroughput'] as num).toDouble(),
  cacheMetrics: CacheMetrics.fromJson(
    json['cacheMetrics'] as Map<String, dynamic>,
  ),
  optimizationRecommendations:
      (json['optimizationRecommendations'] as List<dynamic>)
          .map(
            (e) =>
                OptimizationRecommendation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$PerformanceAnalyticsToJson(
  PerformanceAnalytics instance,
) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'averageCpuUsage': instance.averageCpuUsage,
  'averageMemoryUsage': instance.averageMemoryUsage,
  'averageResponseTime': instance.averageResponseTime,
  'averageThroughput': instance.averageThroughput,
  'cacheMetrics': instance.cacheMetrics,
  'optimizationRecommendations': instance.optimizationRecommendations,
};

OptimizationRecommendation _$OptimizationRecommendationFromJson(
  Map<String, dynamic> json,
) => OptimizationRecommendation(
  type: $enumDecode(_$RecommendationTypeEnumMap, json['type']),
  priority: $enumDecode(_$RecommendationPriorityEnumMap, json['priority']),
  title: json['title'] as String,
  description: json['description'] as String,
  estimatedImpact: json['estimatedImpact'] as String,
  implementationCost: $enumDecode(
    _$RecommendationCostEnumMap,
    json['implementationCost'],
  ),
);

Map<String, dynamic> _$OptimizationRecommendationToJson(
  OptimizationRecommendation instance,
) => <String, dynamic>{
  'type': _$RecommendationTypeEnumMap[instance.type]!,
  'priority': _$RecommendationPriorityEnumMap[instance.priority]!,
  'title': instance.title,
  'description': instance.description,
  'estimatedImpact': instance.estimatedImpact,
  'implementationCost':
      _$RecommendationCostEnumMap[instance.implementationCost]!,
};

const _$RecommendationTypeEnumMap = {
  RecommendationType.scaleOut: 'scaleOut',
  RecommendationType.scaleUp: 'scaleUp',
  RecommendationType.caching: 'caching',
  RecommendationType.databaseOptimization: 'databaseOptimization',
  RecommendationType.memoryOptimization: 'memoryOptimization',
  RecommendationType.networkOptimization: 'networkOptimization',
};

const _$RecommendationPriorityEnumMap = {
  RecommendationPriority.low: 'low',
  RecommendationPriority.medium: 'medium',
  RecommendationPriority.high: 'high',
  RecommendationPriority.critical: 'critical',
};

const _$RecommendationCostEnumMap = {
  RecommendationCost.low: 'low',
  RecommendationCost.medium: 'medium',
  RecommendationCost.high: 'high',
  RecommendationCost.enterprise: 'enterprise',
};
