import 'package:flutter/material.dart';
import 'dart:async';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Cache sistemi
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiration = const Duration(minutes: 30);

  // Performance metrikleri
  final Map<String, int> _loadTimes = {};
  final Map<String, int> _errorCounts = {};
  final List<String> _recentErrors = [];

  // Lazy loading için
  final Map<String, bool> _loadedStates = {};
  final Map<String, List<dynamic>> _lazyData = {};

  // Cache işlemleri
  void setCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  dynamic getCache(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    if (DateTime.now().difference(timestamp) > _cacheExpiration) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _cache[key];
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  void removeFromCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  // Performance tracking
  void startTimer(String operation) {
    _loadTimes[operation] = DateTime.now().millisecondsSinceEpoch;
  }

  void endTimer(String operation) {
    final startTime = _loadTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      _loadTimes['${operation}_duration'] = duration;
      _loadTimes.remove(operation);
    }
  }

  int getLoadTime(String operation) {
    return _loadTimes['${operation}_duration'] ?? 0;
  }

  // Error tracking
  void logError(String operation, String error) {
    _errorCounts[operation] = (_errorCounts[operation] ?? 0) + 1;
    _recentErrors.add('$operation: $error');
    
    // Son 10 hatayı tut
    if (_recentErrors.length > 10) {
      _recentErrors.removeAt(0);
    }
  }

  int getErrorCount(String operation) {
    return _errorCounts[operation] ?? 0;
  }

  List<String> getRecentErrors() {
    return List.unmodifiable(_recentErrors);
  }

  // Lazy loading
  Future<List<dynamic>> lazyLoadData(String key, Future<List<dynamic>> Function() loader) async {
    if (_loadedStates[key] == true) {
      return _lazyData[key] ?? [];
    }

    try {
      startTimer('lazy_load_$key');
      final data = await loader();
      endTimer('lazy_load_$key');

      _lazyData[key] = data;
      _loadedStates[key] = true;

      return data;
    } catch (e) {
      logError('lazy_load_$key', e.toString());
      rethrow;
    }
  }

  void resetLazyLoad(String key) {
    _loadedStates[key] = false;
    _lazyData.remove(key);
  }

  // Memory management
  void optimizeMemory() {
    // Eski cache'leri temizle
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiration) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }

    // Hata listesini temizle
    if (_recentErrors.length > 20) {
      _recentErrors.removeRange(0, _recentErrors.length - 20);
    }
  }

  // Performance istatistikleri
  Map<String, dynamic> getPerformanceStats() {
    return {
      'cacheSize': _cache.length,
      'lazyLoadedItems': _lazyData.length,
      'totalErrors': _errorCounts.values.fold(0, (sum, count) => sum + count),
      'recentErrors': _recentErrors.length,
      'averageLoadTime': _calculateAverageLoadTime(),
      'memoryUsage': _estimateMemoryUsage(),
    };
  }

  double _calculateAverageLoadTime() {
    final durations = _loadTimes.values.where((value) => value > 0).toList();
    if (durations.isEmpty) return 0.0;
    
    final sum = durations.reduce((a, b) => a + b);
    return sum / durations.length;
  }

  int _estimateMemoryUsage() {
    int totalSize = 0;
    
    // Cache boyutu
    totalSize += _cache.length * 100; // Tahmini
    
    // Lazy data boyutu
    totalSize += _lazyData.values.fold(0, (sum, list) => sum + list.length * 50);
    
    return totalSize;
  }

  // Image optimization
  String optimizeImageUrl(String url, {int? width, int? height}) {
    // TODO: Image optimization implementation
    return url;
  }

  // Network optimization
  Future<T> withRetry<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          logError('retry_operation', e.toString());
          rethrow;
        }
        
        // Exponential backoff
        await Future.delayed(Duration(milliseconds: 100 * attempts));
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}

// Performance widget'ı
class PerformanceWidget extends StatefulWidget {
  const PerformanceWidget({super.key});

  @override
  State<PerformanceWidget> createState() => _PerformanceWidgetState();
}

class _PerformanceWidgetState extends State<PerformanceWidget> {
  final PerformanceService _performanceService = PerformanceService();
  Timer? _updateTimer;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) => _updateStats());
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateStats() {
    setState(() {
      _stats = _performanceService.getPerformanceStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Cache bilgileri
            _buildStatItem(
              'Cache Boyutu',
              '${_stats['cacheSize'] ?? 0} öğe',
              Icons.storage,
              Colors.blue,
            ),
            
            _buildStatItem(
              'Lazy Loaded',
              '${_stats['lazyLoadedItems'] ?? 0} öğe',
              Icons.lazy_load,
              Colors.green,
            ),
            
            _buildStatItem(
              'Ortalama Yükleme',
              '${(_stats['averageLoadTime'] ?? 0).toStringAsFixed(0)}ms',
              Icons.timer,
              Colors.orange,
            ),
            
            _buildStatItem(
              'Toplam Hata',
              '${_stats['totalErrors'] ?? 0}',
              Icons.error,
              Colors.red,
            ),
            
            _buildStatItem(
              'Bellek Kullanımı',
              '${(_stats['memoryUsage'] ?? 0) ~/ 1024}KB',
              Icons.memory,
              Colors.purple,
            ),
            
            const SizedBox(height: 16),
            
            // Optimizasyon butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _optimizeMemory,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Belleği Temizle'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearCache,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Cache Temizle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _optimizeMemory() {
    _performanceService.optimizeMemory();
    _updateStats();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bellek optimizasyonu tamamlandı'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearCache() {
    _performanceService.clearCache();
    _updateStats();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache temizlendi'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Lazy loading widget'ı
class LazyLoadingWidget<T> extends StatefulWidget {
  final String key;
  final Future<List<T>> Function() loader;
  final Widget Function(List<T>) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const LazyLoadingWidget({
    super.key,
    required this.key,
    required this.loader,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<LazyLoadingWidget<T>> createState() => _LazyLoadingWidgetState<T>();
}

class _LazyLoadingWidgetState<T> extends State<LazyLoadingWidget<T>> {
  final PerformanceService _performanceService = PerformanceService();
  List<T>? _data;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _performanceService.lazyLoadData(
        widget.key,
        widget.loader,
      );
      
      setState(() {
        _data = data.cast<T>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ?? 
        const Center(
          child: CircularProgressIndicator(),
        );
    }

    if (_error != null) {
      return widget.errorWidget ?? 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Hata: $_error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        );
    }

    return widget.builder(_data ?? []);
  }
}
