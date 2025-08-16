import 'dart:async';
import '../config/env_config.dart';
import 'ai_logger.dart';

class AIPerformanceMonitor {
  static final AIPerformanceMonitor _instance = AIPerformanceMonitor._internal();
  factory AIPerformanceMonitor() => _instance;
  AIPerformanceMonitor._internal();

  final AILogger _logger = AILogger();
  final Map<String, List<PerformanceMetric>> _metrics = {};
  final Map<String, Timer> _cleanupTimers = {};

  // Performance metrics
  void startOperation(String operationName, {String? context, Map<String, dynamic>? metadata}) {
    final key = _getMetricKey(operationName, context);
    
    if (!_metrics.containsKey(key)) {
      _metrics[key] = [];
    }

    final metric = PerformanceMetric(
      operationName: operationName,
      context: context,
      startTime: DateTime.now(),
      metadata: metadata,
    );

    _metrics[key]!.add(metric);

    // Cleanup timer'ı ayarla (24 saat sonra eski metrikleri temizle)
    _scheduleCleanup(key);

    _logger.debug(
      'Started operation: $operationName',
      context: context,
      data: metadata,
    );
  }

  void endOperation(String operationName, {String? context, Map<String, dynamic>? resultMetadata}) {
    final key = _getMetricKey(operationName, context);
    
    if (!_metrics.containsKey(key)) {
      _logger.warning(
        'Attempted to end operation that was not started: $operationName',
        context: context,
      );
      return;
    }

    final metrics = _metrics[key]!;
    if (metrics.isEmpty) {
      _logger.warning(
        'No active metrics found for operation: $operationName',
        context: context,
      );
      return;
    }

    // En son başlatılan metriği bul
    final metric = metrics.last;
    metric.endTime = DateTime.now();
    metric.duration = metric.endTime!.difference(metric.startTime);
    metric.resultMetadata = resultMetadata;

    _logger.info(
      'Completed operation: $operationName in ${metric.duration!.inMilliseconds}ms',
      context: context,
      data: resultMetadata,
    );

    // Performance log'u ekle
    _logger.logPerformance(
      operationName,
      metric.duration!,
      context: context,
      metadata: resultMetadata,
    );
  }

  // Operation duration'ını al
  Duration? getOperationDuration(String operationName, {String? context}) {
    final key = _getMetricKey(operationName, context);
    
    if (!_metrics.containsKey(key)) return null;

    final metrics = _metrics[key]!;
    if (metrics.isEmpty) return null;

    // En son tamamlanan metriği bul
    for (int i = metrics.length - 1; i >= 0; i--) {
      if (metrics[i].isCompleted) {
        return metrics[i].duration;
      }
    }

    return null;
  }

  // Average duration hesapla
  Duration getAverageDuration(String operationName, {String? context, int? sampleSize}) {
    final key = _getMetricKey(operationName, context);
    
    if (!_metrics.containsKey(key)) return Duration.zero;

    final metrics = _metrics[key]!;
    final completedMetrics = metrics.where((m) => m.isCompleted).toList();

    if (completedMetrics.isEmpty) return Duration.zero;

    // Sample size'a göre filtrele
    if (sampleSize != null && completedMetrics.length > sampleSize) {
      completedMetrics.sort((a, b) => b.startTime.compareTo(a.startTime));
      completedMetrics.removeRange(sampleSize, completedMetrics.length);
    }

    final totalMilliseconds = completedMetrics
        .map((m) => m.duration!.inMilliseconds)
        .reduce((a, b) => a + b);

    return Duration(milliseconds: totalMilliseconds ~/ completedMetrics.length);
  }

  // Performance statistics
  Map<String, dynamic> getPerformanceStatistics({String? context}) {
    final stats = <String, dynamic>{};
    
    for (final entry in _metrics.entries) {
      final operationName = entry.key.split('::').first;
      final metrics = entry.value;
      final completedMetrics = metrics.where((m) => m.isCompleted).toList();

      if (completedMetrics.isEmpty) continue;

      final durations = completedMetrics.map((m) => m.duration!.inMilliseconds).toList();
      durations.sort();

      final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
      final minDuration = durations.first;
      final maxDuration = durations.last;
      final medianDuration = durations[durations.length ~/ 2];

      stats[operationName] = {
        'total_operations': completedMetrics.length,
        'average_duration_ms': avgDuration.round(),
        'min_duration_ms': minDuration,
        'max_duration_ms': maxDuration,
        'median_duration_ms': medianDuration,
        'success_rate': _calculateSuccessRate(completedMetrics),
      };
    }

    return stats;
  }

  // Success rate hesapla
  double _calculateSuccessRate(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;

    final successfulMetrics = metrics.where((m) => 
        m.resultMetadata != null && 
        !m.resultMetadata!.containsKey('error')).length;

    return successfulMetrics / metrics.length;
  }

  // Slow operations'ları bul
  List<PerformanceMetric> getSlowOperations(Duration threshold, {String? context}) {
    final slowMetrics = <PerformanceMetric>[];

    for (final entry in _metrics.entries) {
      if (context != null && !entry.key.contains(context)) continue;

      final metrics = entry.value;
      final slowOnes = metrics.where((m) => 
          m.isCompleted && 
          m.duration!.compareTo(threshold) > 0).toList();

      slowMetrics.addAll(slowOnes);
    }

    slowMetrics.sort((a, b) => b.duration!.compareTo(a.duration!));
    return slowMetrics;
  }

  // Performance alerts
  List<PerformanceAlert> getPerformanceAlerts() {
    final alerts = <PerformanceAlert>[];

    for (final entry in _metrics.entries) {
      final operationName = entry.key.split('::').first;
      final metrics = entry.value;
      final recentMetrics = metrics.where((m) => 
          m.startTime.isAfter(DateTime.now().subtract(const Duration(hours: 1)))).toList();

      if (recentMetrics.length < 3) continue; // En az 3 örnek gerekli

      final avgDuration = getAverageDuration(operationName, sampleSize: 10);
      final recentAvgDuration = getAverageDuration(operationName, sampleSize: 3);

      // Performance degradation check
      if (recentAvgDuration.inMilliseconds > avgDuration.inMilliseconds * 1.5) {
        alerts.add(PerformanceAlert(
          type: PerformanceAlertType.degradation,
          operationName: operationName,
          message: 'Performance degradation detected: ${recentAvgDuration.inMilliseconds}ms vs ${avgDuration.inMilliseconds}ms average',
          severity: PerformanceAlertSeverity.warning,
          timestamp: DateTime.now(),
        ));
      }

      // High error rate check
      final errorRate = _calculateErrorRate(recentMetrics);
      if (errorRate > 0.2) { // %20'den fazla hata
        alerts.add(PerformanceAlert(
          type: PerformanceAlertType.highErrorRate,
          operationName: operationName,
          message: 'High error rate: ${(errorRate * 100).round()}%',
          severity: PerformanceAlertSeverity.error,
          timestamp: DateTime.now(),
        ));
      }
    }

    return alerts;
  }

  double _calculateErrorRate(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;

    final errorMetrics = metrics.where((m) => 
        m.resultMetadata != null && 
        m.resultMetadata!.containsKey('error')).length;

    return errorMetrics / metrics.length;
  }

  // Cleanup
  void _scheduleCleanup(String key) {
    if (_cleanupTimers.containsKey(key)) {
      _cleanupTimers[key]!.cancel();
    }

    _cleanupTimers[key] = Timer(const Duration(hours: 24), () {
      _cleanupOldMetrics(key);
    });
  }

  void _cleanupOldMetrics(String key) {
    if (!_metrics.containsKey(key)) return;

    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7)); // 7 günden eski metrikleri temizle

    _metrics[key]!.removeWhere((metric) => metric.startTime.isBefore(cutoff));

    if (_metrics[key]!.isEmpty) {
      _metrics.remove(key);
    }

    _cleanupTimers.remove(key);
  }

  // Helper methods
  String _getMetricKey(String operationName, String? context) {
    return context != null ? '$operationName::$context' : operationName;
  }

  // Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    
    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();
  }

  // Export performance data
  Map<String, dynamic> exportPerformanceData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'metrics': _metrics.map((key, value) => MapEntry(key, value.map((m) => m.toJson()).toList())),
      'statistics': getPerformanceStatistics(),
      'alerts': getPerformanceAlerts().map((a) => a.toJson()).toList(),
    };
  }
}

class PerformanceMetric {
  final String operationName;
  final String? context;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;
  final Map<String, dynamic>? metadata;
  Map<String, dynamic>? resultMetadata;

  PerformanceMetric({
    required this.operationName,
    this.context,
    required this.startTime,
    this.endTime,
    this.duration,
    this.metadata,
    this.resultMetadata,
  });

  bool get isCompleted => endTime != null && duration != null;

  Map<String, dynamic> toJson() {
    return {
      'operationName': operationName,
      'context': context,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration_ms': duration?.inMilliseconds,
      'metadata': metadata,
      'resultMetadata': resultMetadata,
      'isCompleted': isCompleted,
    };
  }
}

enum PerformanceAlertType {
  degradation,
  highErrorRate,
  timeout,
  rateLimit,
}

enum PerformanceAlertSeverity {
  info,
  warning,
  error,
  critical,
}

class PerformanceAlert {
  final PerformanceAlertType type;
  final String operationName;
  final String message;
  final PerformanceAlertSeverity severity;
  final DateTime timestamp;

  PerformanceAlert({
    required this.type,
    required this.operationName,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'operationName': operationName,
      'message': message,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

