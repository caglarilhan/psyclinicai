import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:isolate';

class PerformanceOptimizationService extends ChangeNotifier {
  static final PerformanceOptimizationService _instance = PerformanceOptimizationService._internal();
  factory PerformanceOptimizationService() => _instance;
  PerformanceOptimizationService._internal();

  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};
  final Map<String, List<PerformanceEvent>> _events = {};
  final Map<String, CachePerformance> _cachePerformance = {};
  
  // Background processing
  final Map<String, Isolate> _isolates = {};
  final Map<String, ReceivePort> _receivePorts = {};
  
  // Memory management
  final Map<String, MemoryUsage> _memoryUsage = {};
  Timer? _cleanupTimer;
  
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  Map<String, PerformanceMetric> get metrics => Map.unmodifiable(_metrics);
  Map<String, CachePerformance> get cachePerformance => Map.unmodifiable(_cachePerformance);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadPerformanceData();
      _startCleanupTimer();
      _isInitialized = true;
      notifyListeners();
      print('PerformanceOptimizationService initialized successfully');
    } catch (e) {
      print('PerformanceOptimizationService initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _loadPerformanceData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load cached performance data
    final metricsJson = prefs.getString('performance_metrics');
    if (metricsJson != null) {
      try {
        // Parse and load metrics
      } catch (e) {
        print('Error loading performance metrics: $e');
      }
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupOldData();
      _optimizeMemory();
    });
  }

  // Performance tracking
  void trackEvent(String category, String event, {Map<String, dynamic>? data}) {
    final eventId = '${category}_${event}_${DateTime.now().millisecondsSinceEpoch}';
    final performanceEvent = PerformanceEvent(
      id: eventId,
      category: category,
      event: event,
      timestamp: DateTime.now(),
      data: data ?? {},
    );

    _events.putIfAbsent(category, () => []).add(performanceEvent);
    
    // Update metrics
    _updateMetric(category, event, performanceEvent);
    
    notifyListeners();
  }

  void _updateMetric(String category, String event, PerformanceEvent performanceEvent) {
    final metricKey = '${category}_${event}';
    
    if (!_metrics.containsKey(metricKey)) {
      _metrics[metricKey] = PerformanceMetric(
        category: category,
        event: event,
        count: 0,
        totalDuration: Duration.zero,
        averageDuration: Duration.zero,
        lastUpdated: DateTime.now(),
      );
    }

    final metric = _metrics[metricKey]!;
    metric.count++;
    
    // Calculate duration if available
    if (performanceEvent.data.containsKey('duration')) {
      final duration = Duration(milliseconds: performanceEvent.data['duration']);
      metric.totalDuration += duration;
      metric.averageDuration = Duration(
        milliseconds: metric.totalDuration.inMilliseconds ~/ metric.count,
      );
    }
    
    metric.lastUpdated = DateTime.now();
  }

  // Cache performance tracking
  void trackCacheHit(String cacheKey, String cacheType) {
    _cachePerformance.putIfAbsent(cacheType, () => CachePerformance(
      type: cacheType,
      hits: 0,
      misses: 0,
      totalRequests: 0,
      lastUpdated: DateTime.now(),
    ));

    final cache = _cachePerformance[cacheType]!;
    cache.hits++;
    cache.totalRequests++;
    cache.lastUpdated = DateTime.now();
    
    notifyListeners();
  }

  void trackCacheMiss(String cacheKey, String cacheType) {
    _cachePerformance.putIfAbsent(cacheType, () => CachePerformance(
      type: cacheType,
      hits: 0,
      misses: 0,
      totalRequests: 0,
      lastUpdated: DateTime.now(),
    ));

    final cache = _cachePerformance[cacheType]!;
    cache.misses++;
    cache.totalRequests++;
    cache.lastUpdated = DateTime.now();
    
    notifyListeners();
  }

  // Background processing
  Future<T> runInBackground<T>(String taskId, Future<T> Function() task) async {
    final receivePort = ReceivePort();
    _receivePorts[taskId] = receivePort;

    try {
      final result = await Isolate.run(task);
      _receivePorts.remove(taskId);
      return result;
    } catch (e) {
      _receivePorts.remove(taskId);
      rethrow;
    }
  }

  Future<void> runHeavyComputation(String taskId, Map<String, dynamic> data) async {
    final receivePort = ReceivePort();
    _receivePorts[taskId] = receivePort;

    final isolate = await Isolate.spawn(_heavyComputation, {
      'sendPort': receivePort.sendPort,
      'data': data,
    });

    _isolates[taskId] = isolate;

    // Listen for results
    receivePort.listen((message) {
      if (message is Map<String, dynamic> && message['type'] == 'result') {
        // Handle result
        _cleanupIsolate(taskId);
      }
    });
  }

  static void _heavyComputation(Map<String, dynamic> data) {
    final sendPort = data['sendPort'] as SendPort;
    final computationData = data['data'] as Map<String, dynamic>;
    
    try {
      // Perform heavy computation
      final result = _performComputation(computationData);
      
      sendPort.send({
        'type': 'result',
        'data': result,
      });
    } catch (e) {
      sendPort.send({
        'type': 'error',
        'error': e.toString(),
      });
    }
  }

  static Map<String, dynamic> _performComputation(Map<String, dynamic> data) {
    // Simulate heavy computation
    final startTime = DateTime.now();
    
    // Complex calculations would go here
    int result = 0;
    for (int i = 0; i < 1000000; i++) {
      result += i * i;
    }
    
    final duration = DateTime.now().difference(startTime);
    
    return {
      'result': result,
      'duration': duration.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void _cleanupIsolate(String taskId) {
    final isolate = _isolates[taskId];
    if (isolate != null) {
      isolate.kill();
      _isolates.remove(taskId);
    }
    
    final receivePort = _receivePorts[taskId];
    if (receivePort != null) {
      receivePort.close();
      _receivePorts.remove(taskId);
    }
  }

  // Memory management
  void trackMemoryUsage(String component, int bytesUsed) {
    _memoryUsage[component] = MemoryUsage(
      component: component,
      bytesUsed: bytesUsed,
      timestamp: DateTime.now(),
    );
    
    notifyListeners();
  }

  void _optimizeMemory() {
    // Clean up old events
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
    
    for (final category in _events.keys) {
      _events[category]!.removeWhere((event) => event.timestamp.isBefore(cutoffTime));
    }
    
    // Clean up old metrics
    final oldMetrics = _metrics.keys.where((key) {
      final metric = _metrics[key]!;
      return metric.lastUpdated.isBefore(cutoffTime);
    }).toList();
    
    for (final key in oldMetrics) {
      _metrics.remove(key);
    }
    
    notifyListeners();
  }

  void _cleanupOldData() {
    // Remove data older than 7 days
    final cutoffTime = DateTime.now().subtract(const Duration(days: 7));
    
    // Clean up old cache performance data
    for (final cache in _cachePerformance.values) {
      if (cache.lastUpdated.isBefore(cutoffTime)) {
        // Reset old data
        cache.hits = 0;
        cache.misses = 0;
        cache.totalRequests = 0;
        cache.lastUpdated = DateTime.now();
      }
    }
  }

  // Performance analysis
  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{};
    
    // Overall metrics
    report['totalEvents'] = _events.values.fold<int>(0, (sum, events) => sum + events.length);
    report['totalMetrics'] = _metrics.length;
    report['cacheHitRate'] = _calculateOverallCacheHitRate();
    
    // Top performing components
    report['topComponents'] = _getTopPerformingComponents();
    
    // Performance trends
    report['trends'] = _calculatePerformanceTrends();
    
    return report;
  }

  double _calculateOverallCacheHitRate() {
    if (_cachePerformance.isEmpty) return 0.0;
    
    int totalHits = 0;
    int totalRequests = 0;
    
    for (final cache in _cachePerformance.values) {
      totalHits += cache.hits;
      totalRequests += cache.totalRequests;
    }
    
    return totalRequests > 0 ? totalHits / totalRequests : 0.0;
  }

  List<Map<String, dynamic>> _getTopPerformingComponents() {
    final components = <Map<String, dynamic>>[];
    
    for (final metric in _metrics.values) {
      components.add({
        'category': metric.category,
        'event': metric.event,
        'count': metric.count,
        'averageDuration': metric.averageDuration.inMilliseconds,
      });
    }
    
    // Sort by count (descending)
    components.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    return components.take(10).toList();
  }

  Map<String, dynamic> _calculatePerformanceTrends() {
    // Calculate trends over the last hour
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 1));
    
    final recentEvents = <String, int>{};
    
    for (final category in _events.keys) {
      for (final event in _events[category]!) {
        if (event.timestamp.isAfter(cutoffTime)) {
          final key = '${event.category}_${event.event}';
          recentEvents[key] = (recentEvents[key] ?? 0) + 1;
        }
      }
    }
    
    return {
      'recentActivity': recentEvents,
      'period': '1 hour',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    
    // Clean up all isolates
    for (final isolate in _isolates.values) {
      isolate.kill();
    }
    
    // Close all receive ports
    for (final receivePort in _receivePorts.values) {
      receivePort.close();
    }
    
    super.dispose();
  }
}

// Performance data models
class PerformanceMetric {
  String category;
  String event;
  int count;
  Duration totalDuration;
  Duration averageDuration;
  DateTime lastUpdated;

  PerformanceMetric({
    required this.category,
    required this.event,
    required this.count,
    required this.totalDuration,
    required this.averageDuration,
    required this.lastUpdated,
  });
}

class PerformanceEvent {
  final String id;
  final String category;
  final String event;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  PerformanceEvent({
    required this.id,
    required this.category,
    required this.event,
    required this.timestamp,
    required this.data,
  });
}

class CachePerformance {
  String type;
  int hits;
  int misses;
  int totalRequests;
  DateTime lastUpdated;

  CachePerformance({
    required this.type,
    required this.hits,
    required this.misses,
    required this.totalRequests,
    required this.lastUpdated,
  });
}

class MemoryUsage {
  final String component;
  final int bytesUsed;
  final DateTime timestamp;

  MemoryUsage({
    required this.component,
    required this.bytesUsed,
    required this.timestamp,
  });
}
