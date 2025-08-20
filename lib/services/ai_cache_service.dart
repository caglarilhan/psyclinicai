import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../utils/ai_logger.dart';

class AICacheService {
  static final AICacheService _instance = AICacheService._internal();
  factory AICacheService() => _instance;
  AICacheService._internal();

  final AILogger _logger = AILogger();
  static const String _cacheDirName = 'ai_cache';
  static const Duration _defaultExpiry = Duration(hours: 24);
  
  Directory? _cacheDir;
  final Map<String, CachedResponse> _memoryCache = {};
  static const int _maxMemoryCacheSize = 100;

  // Metrics
  int _memoryHits = 0;
  int _diskHits = 0;
  int _misses = 0;
  int _evictions = 0;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/$_cacheDirName');
      
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
      
      _logger.info('AICacheService initialized successfully', context: 'AICacheService');
    } catch (e) {
      _logger.error('Failed to initialize AICacheService', context: 'AICacheService', error: e);
    }
  }

  String _generateCacheKey(String prompt, String modelId, Map<String, dynamic> parameters) {
    final data = '$prompt$modelId${jsonEncode(parameters)}';
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<CachedResponse?> getCachedResponse(
    String prompt,
    String modelId,
    Map<String, dynamic> parameters,
  ) async {
    final cacheKey = _generateCacheKey(prompt, modelId, parameters);
    
    // Check memory cache first
    if (_memoryCache.containsKey(cacheKey)) {
      final cached = _memoryCache[cacheKey]!;
      if (!cached.isExpired) {
        _logger.debug('Cache hit from memory', context: 'AICacheService', data: {'key': cacheKey});
        _memoryHits++;
        return cached;
      } else {
        _memoryCache.remove(cacheKey);
      }
    }

    // Check disk cache
    try {
      final file = File('${_cacheDir!.path}/$cacheKey.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final cached = CachedResponse.fromJson(jsonDecode(content));
        
        if (!cached.isExpired) {
          // Move to memory cache
          _addToMemoryCache(cacheKey, cached);
          _logger.debug('Cache hit from disk', context: 'AICacheService', data: {'key': cacheKey});
          _diskHits++;
          return cached;
        } else {
          // Remove expired cache
          await file.delete();
        }
      }
    } catch (e) {
      _logger.warning('Error reading cache file', context: 'AICacheService', error: e);
    }

    _misses++;
    return null;
  }

  Future<void> cacheResponse(
    String prompt,
    String modelId,
    Map<String, dynamic> parameters,
    Map<String, dynamic> response,
    Duration? expiry,
  ) async {
    final cacheKey = _generateCacheKey(prompt, modelId, parameters);
    final cachedResponse = CachedResponse(
      prompt: prompt,
      modelId: modelId,
      parameters: parameters,
      response: response,
      timestamp: DateTime.now(),
      expiry: expiry ?? _defaultExpiry,
    );

    // Save to memory cache
    _addToMemoryCache(cacheKey, cachedResponse);

    // Save to disk cache
    try {
      final file = File('${_cacheDir!.path}/$cacheKey.json');
      await file.writeAsString(jsonEncode(cachedResponse.toJson()));
      _logger.debug('Response cached successfully', context: 'AICacheService', data: {'key': cacheKey});
    } catch (e) {
      _logger.error('Failed to cache response to disk', context: 'AICacheService', error: e);
    }
  }

  void _addToMemoryCache(String key, CachedResponse response) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      // Remove oldest entry
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
      _evictions++;
    }
    _memoryCache[key] = response;
  }

  Future<void> clearCache({bool memoryOnly = false}) async {
    _memoryCache.clear();
    
    if (!memoryOnly && _cacheDir != null) {
      try {
        final files = _cacheDir!.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            await file.delete();
          }
        }
        _logger.info('Cache cleared successfully', context: 'AICacheService');
      } catch (e) {
        _logger.error('Failed to clear disk cache', context: 'AICacheService', error: e);
      }
    }
  }

  Future<void> removeExpiredCache() async {
    final now = DateTime.now();
    
    // Clear expired memory cache
    _memoryCache.removeWhere((key, value) => value.isExpired);
    
    // Clear expired disk cache
    if (_cacheDir != null) {
      try {
        final files = _cacheDir!.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            try {
              final content = await file.readAsString();
              final cached = CachedResponse.fromJson(jsonDecode(content));
              if (cached.isExpired) {
                await file.delete();
              }
            } catch (e) {
              // Invalid cache file, remove it
              await file.delete();
            }
          }
        }
        _logger.info('Expired cache cleaned', context: 'AICacheService');
      } catch (e) {
        _logger.error('Failed to clean expired cache', context: 'AICacheService', error: e);
      }
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    int diskCacheSize = 0;
    int totalDiskSize = 0;
    
    if (_cacheDir != null) {
      try {
        final files = _cacheDir!.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            diskCacheSize++;
            totalDiskSize += await file.length();
          }
        }
      } catch (e) {
        _logger.warning('Error calculating disk cache stats', context: 'AICacheService', error: e);
      }
    }

    return {
      'memoryCacheSize': _memoryCache.length,
      'diskCacheSize': diskCacheSize,
      'totalDiskSizeBytes': totalDiskSize,
      'maxMemoryCacheSize': _maxMemoryCacheSize,
      'memoryHits': _memoryHits,
      'diskHits': _diskHits,
      'misses': _misses,
      'evictions': _evictions,
    };
  }
}

class CachedResponse {
  final String prompt;
  final String modelId;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> response;
  final DateTime timestamp;
  final Duration expiry;

  const CachedResponse({
    required this.prompt,
    required this.modelId,
    required this.parameters,
    required this.response,
    required this.timestamp,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(timestamp.add(expiry));

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'modelId': modelId,
    'parameters': parameters,
    'response': response,
    'timestamp': timestamp.toIso8601String(),
    'expiry': expiry.inMilliseconds,
  };

  factory CachedResponse.fromJson(Map<String, dynamic> json) => CachedResponse(
    prompt: json['prompt'],
    modelId: json['modelId'],
    parameters: json['parameters'],
    response: json['response'],
    timestamp: DateTime.parse(json['timestamp']),
    expiry: Duration(milliseconds: json['expiry']),
  );
}
