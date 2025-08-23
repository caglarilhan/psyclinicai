import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class OfflineService {
  static const String _offlineDataKey = 'offline_data';
  static const String _syncQueueKey = 'sync_queue';
  static const String _offlineConfigKey = 'offline_config';
  
  // Singleton pattern
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  // Stream controllers
  final StreamController<OfflineStatus> _statusStreamController = 
      StreamController<OfflineStatus>.broadcast();
  
  final StreamController<SyncProgress> _syncProgressStreamController = 
      StreamController<SyncProgress>.broadcast();

  // Get streams
  Stream<OfflineStatus> get statusStream => _statusStreamController.stream;
  Stream<SyncProgress> get syncProgressStream => _syncProgressStreamController.stream;

  // Offline status
  bool _isOffline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingSyncCount = 0;

  // Getters
  bool get isOffline => _isOffline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncCount => _pendingSyncCount;

  // Initialize offline service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load offline configuration
      final configJson = prefs.getString(_offlineConfigKey);
      if (configJson != null) {
        final config = OfflineConfig.fromJson(json.decode(configJson));
        _isOffline = config.enabled;
      }
      
      // Load pending sync count
      final syncQueue = await _getSyncQueue();
      _pendingSyncCount = syncQueue.length;
      
      // Check network status
      await _checkNetworkStatus();
      
      print('✅ Offline service initialized');
      
    } catch (e) {
      print('Error initializing offline service: $e');
    }
  }

  // Check network status
  Future<void> _checkNetworkStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final wasOffline = _isOffline;
      _isOffline = result.isEmpty;
      
      if (wasOffline != _isOffline) {
        _statusStreamController.add(OfflineStatus(
          isOffline: _isOffline,
          timestamp: DateTime.now(),
          reason: _isOffline ? 'Network unavailable' : 'Network restored',
        ));
        
        if (!_isOffline && _pendingSyncCount > 0) {
          _triggerAutoSync();
        }
      }
      
    } catch (e) {
      final wasOffline = _isOffline;
      _isOffline = true;
      
      if (wasOffline != _isOffline) {
        _statusStreamController.add(OfflineStatus(
          isOffline: _isOffline,
          timestamp: DateTime.now(),
          reason: 'Network error: $e',
        ));
      }
    }
  }

  // Enable offline mode
  Future<void> enableOfflineMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final config = OfflineConfig(
        enabled: true,
        autoSync: true,
        syncInterval: 300, // 5 minutes
        maxOfflineDataSize: 100 * 1024 * 1024, // 100 MB
        compressionEnabled: true,
      );
      
      await prefs.setString(_offlineConfigKey, json.encode(config.toJson()));
      _isOffline = true;
      
      _statusStreamController.add(OfflineStatus(
        isOffline: _isOffline,
        timestamp: DateTime.now(),
        reason: 'Offline mode enabled manually',
      ));
      
      print('✅ Offline mode enabled');
      
    } catch (e) {
      print('Error enabling offline mode: $e');
    }
  }

  // Disable offline mode
  Future<void> disableOfflineMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final config = OfflineConfig(
        enabled: false,
        autoSync: false,
        syncInterval: 0,
        maxOfflineDataSize: 0,
        compressionEnabled: false,
      );
      
      await prefs.setString(_offlineConfigKey, json.encode(config.toJson()));
      _isOffline = false;
      
      _statusStreamController.add(OfflineStatus(
        isOffline: _isOffline,
        timestamp: DateTime.now(),
        reason: 'Offline mode disabled',
      ));
      
      print('✅ Offline mode disabled');
      
    } catch (e) {
      print('Error disabling offline mode: $e');
    }
  }

  // Save data offline
  Future<bool> saveOfflineData({
    required String key,
    required Map<String, dynamic> data,
    required String dataType,
    String? userId,
  }) async {
    try {
      if (!_isOffline) {
        print('Not in offline mode, saving to cloud instead');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final offlineData = await _getOfflineData();
      
      final offlineEntry = OfflineDataEntry(
        id: _generateSecureId(),
        key: key,
        data: data,
        dataType: dataType,
        userId: userId,
        timestamp: DateTime.now(),
        priority: _getDataPriority(dataType),
        size: json.encode(data).length,
      );
      
      offlineData[key] = offlineEntry.toJson();
      
      // Check storage limit
      final totalSize = offlineData.values.fold<int>(0, (sum, entry) => 
        sum + (entry['size'] as int)
      );
      
      final config = await _getOfflineConfig();
      if (totalSize > config.maxOfflineDataSize) {
        await _cleanupOldData(offlineData);
      }
      
      await prefs.setString(_offlineDataKey, json.encode(offlineData));
      
      // Add to sync queue
      await _addToSyncQueue(offlineEntry);
      
      print('✅ Data saved offline: $key');
      return true;
      
    } catch (e) {
      print('Error saving offline data: $e');
      return false;
    }
  }

  // Get offline data
  Future<Map<String, dynamic>?> getOfflineDataByKey(String key) async {
    try {
      final offlineData = await _getOfflineData();
      final entry = offlineData[key];
      
      if (entry != null) {
        return entry['data'] as Map<String, dynamic>;
      }
      
      return null;
      
    } catch (e) {
      print('Error getting offline data: $e');
      return null;
    }
  }

  // Get all offline data by type
  Future<List<Map<String, dynamic>>> getOfflineDataByType(String dataType) async {
    try {
      final offlineData = await _getOfflineData();
      final filteredData = <Map<String, dynamic>>[];
      
      for (final entry in offlineData.values) {
        if (entry['dataType'] == dataType) {
          filteredData.add(entry['data'] as Map<String, dynamic>);
        }
      }
      
      return filteredData;
      
    } catch (e) {
      print('Error getting offline data by type: $e');
      return [];
    }
  }

  // Get offline data
  Future<Map<String, Map<String, dynamic>>> _getOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString(_offlineDataKey);
      
      if (dataJson != null) {
        final data = json.decode(dataJson) as Map<String, dynamic>;
        return Map<String, Map<String, dynamic>>.from(data);
      }
      
      return {};
      
    } catch (e) {
      print('Error getting offline data: $e');
      return {};
    }
  }

  // Add to sync queue
  Future<void> _addToSyncQueue(OfflineDataEntry entry) async {
    try {
      final syncQueue = await _getSyncQueue();
      
      final syncItem = SyncQueueItem(
        id: entry.id,
        key: entry.key,
        dataType: entry.dataType,
        userId: entry.userId,
        timestamp: entry.timestamp,
        priority: entry.priority,
        retryCount: 0,
        status: 'pending',
      );
      
      syncQueue.add(syncItem.toJson());
      await _saveSyncQueue(syncQueue);
      
      _pendingSyncCount = syncQueue.length;
      
    } catch (e) {
      print('Error adding to sync queue: $e');
    }
  }

  // Get sync queue
  Future<List<Map<String, dynamic>>> _getSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_syncQueueKey);
      
      if (queueJson != null) {
        final queue = json.decode(queueJson) as List<dynamic>;
        return queue.cast<Map<String, dynamic>>();
      }
      
      return [];
      
    } catch (e) {
      print('Error getting sync queue: $e');
      return [];
    }
  }

  // Save sync queue
  Future<void> _saveSyncQueue(List<Map<String, dynamic>> queue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_syncQueueKey, json.encode(queue));
    } catch (e) {
      print('Error saving sync queue: $e');
    }
  }

  // Trigger auto sync
  Future<void> _triggerAutoSync() async {
    if (_isOffline || _isSyncing || _pendingSyncCount == 0) return;
    
    final config = await _getOfflineConfig();
    if (!config.autoSync) return;
    
    Timer(const Duration(seconds: 5), () {
      _startSync();
    });
  }

  // Start sync process
  Future<void> _startSync() async {
    if (_isSyncing) return;
    
    setState(() => _isSyncing = true);
    
    try {
      final syncQueue = await _getSyncQueue();
      if (syncQueue.isEmpty) {
        setState(() => _isSyncing = false);
        return;
      }
      
      // Sort by priority and timestamp
      syncQueue.sort((a, b) {
        final priorityA = a['priority'] as int;
        final priorityB = b['priority'] as int;
        
        if (priorityA != priorityB) {
          return priorityB.compareTo(priorityA); // Higher priority first
        }
        
        final timestampA = DateTime.parse(a['timestamp']);
        final timestampB = DateTime.parse(b['timestamp']);
        return timestampA.compareTo(timestampB); // Older first
      });
      
      int processedCount = 0;
      int successCount = 0;
      int failedCount = 0;
      
      for (final item in syncQueue) {
        try {
          _syncProgressStreamController.add(SyncProgress(
            current: processedCount + 1,
            total: syncQueue.length,
            currentItem: item['key'],
            status: 'Processing ${item['key']}...',
          ));
          
          final success = await _syncItem(item);
          
          if (success) {
            successCount++;
            // Remove from queue
            syncQueue.removeAt(processedCount);
          } else {
            failedCount++;
            // Update retry count
            item['retryCount'] = (item['retryCount'] as int) + 1;
            
            if (item['retryCount'] >= 3) {
              // Mark as failed permanently
              item['status'] = 'failed';
              syncQueue.removeAt(processedCount);
            } else {
              processedCount++;
            }
          }
          
          await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
          
        } catch (e) {
          print('Error syncing item: $e');
          failedCount++;
          processedCount++;
        }
      }
      
      // Save updated queue
      await _saveSyncQueue(syncQueue);
      
      // Update counts
      _pendingSyncCount = syncQueue.length;
      _lastSyncTime = DateTime.now();
      
      // Send final progress
      _syncProgressStreamController.add(SyncProgress(
        current: syncQueue.length,
        total: syncQueue.length,
        currentItem: 'Sync completed',
        status: 'Sync completed: $successCount successful, $failedCount failed',
      ));
      
      print('✅ Sync completed: $successCount successful, $failedCount failed');
      
    } catch (e) {
      print('Error during sync: $e');
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  // Sync individual item
  Future<bool> _syncItem(Map<String, dynamic> item) async {
    try {
      // Simulate cloud sync
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Simulate 90% success rate
      final random = Random();
      return random.nextDouble() > 0.1;
      
    } catch (e) {
      print('Error syncing item: $e');
      return false;
    }
  }

  // Cleanup old data
  Future<void> _cleanupOldData(Map<String, Map<String, dynamic>> offlineData) async {
    try {
      // Sort by timestamp (oldest first)
      final sortedEntries = offlineData.entries.toList()
        ..sort((a, b) => DateTime.parse(a.value['timestamp'])
            .compareTo(DateTime.parse(b.value['timestamp'])));
      
      // Remove oldest entries until under limit
      final config = await _getOfflineConfig();
      int currentSize = offlineData.values.fold<int>(0, (sum, entry) => 
        sum + (entry['size'] as int)
      );
      
      for (final entry in sortedEntries) {
        if (currentSize <= config.maxOfflineDataSize) break;
        
        currentSize -= entry.value['size'] as int;
        offlineData.remove(entry.key);
        
        print('🗑️ Cleaned up old offline data: ${entry.key}');
      }
      
    } catch (e) {
      print('Error cleaning up old data: $e');
    }
  }

  // Get data priority
  int _getDataPriority(String dataType) {
    switch (dataType) {
      case 'patient_emergency':
        return 100; // Highest priority
      case 'patient_critical':
        return 90;
      case 'patient_update':
        return 70;
      case 'appointment':
        return 60;
      case 'medication':
        return 50;
      case 'note':
        return 30;
      case 'log':
        return 10; // Lowest priority
      default:
        return 50;
    }
  }

  // Get offline config
  Future<OfflineConfig> _getOfflineConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_offlineConfigKey);
      
      if (configJson != null) {
        return OfflineConfig.fromJson(json.decode(configJson));
      }
      
      // Return default config
      return const OfflineConfig(
        enabled: false,
        autoSync: true,
        syncInterval: 300,
        maxOfflineDataSize: 100 * 1024 * 1024,
        compressionEnabled: true,
      );
      
    } catch (e) {
      print('Error getting offline config: $e');
      return const OfflineConfig(
        enabled: false,
        autoSync: true,
        syncInterval: 300,
        maxOfflineDataSize: 100 * 1024 * 1024,
        compressionEnabled: true,
      );
    }
  }

  // Generate secure ID
  String _generateSecureId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Set state
  void setState(Function fn) {
    fn();
    // Notify listeners if needed
  }

  // Manual sync
  Future<void> manualSync() async {
    if (_isOffline) {
      print('Cannot sync while offline');
      return;
    }
    
    await _startSync();
  }

  // Get offline statistics
  Future<OfflineStatistics> getOfflineStatistics() async {
    try {
      final offlineData = await _getOfflineData();
      final syncQueue = await _getSyncQueue();
      
      int totalSize = 0;
      final dataTypeCounts = <String, int>{};
      
      for (final entry in offlineData.values) {
        totalSize += entry['size'] as int;
        final dataType = entry['dataType'] as String;
        dataTypeCounts[dataType] = (dataTypeCounts[dataType] ?? 0) + 1;
      }
      
      return OfflineStatistics(
        totalEntries: offlineData.length,
        totalSize: totalSize,
        pendingSync: syncQueue.length,
        lastSyncTime: _lastSyncTime,
        dataTypeCounts: dataTypeCounts,
        isOffline: _isOffline,
        isSyncing: _isSyncing,
      );
      
    } catch (e) {
      print('Error getting offline statistics: $e');
      return OfflineStatistics(
        totalEntries: 0,
        totalSize: 0,
        pendingSync: 0,
        lastSyncTime: null,
        dataTypeCounts: {},
        isOffline: _isOffline,
        isSyncing: _isSyncing,
      );
    }
  }

  // Dispose resources
  void dispose() {
    _statusStreamController.close();
    _syncProgressStreamController.close();
  }
}

// Data classes
class OfflineConfig {
  final bool enabled;
  final bool autoSync;
  final int syncInterval; // seconds
  final int maxOfflineDataSize; // bytes
  final bool compressionEnabled;

  const OfflineConfig({
    required this.enabled,
    required this.autoSync,
    required this.syncInterval,
    required this.maxOfflineDataSize,
    required this.compressionEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'autoSync': autoSync,
      'syncInterval': syncInterval,
      'maxOfflineDataSize': maxOfflineDataSize,
      'compressionEnabled': compressionEnabled,
    };
  }

  factory OfflineConfig.fromJson(Map<String, dynamic> json) {
    return OfflineConfig(
      enabled: json['enabled'] ?? false,
      autoSync: json['autoSync'] ?? true,
      syncInterval: json['syncInterval'] ?? 300,
      maxOfflineDataSize: json['maxOfflineDataSize'] ?? 100 * 1024 * 1024,
      compressionEnabled: json['compressionEnabled'] ?? true,
    );
  }
}

class OfflineDataEntry {
  final String id;
  final String key;
  final Map<String, dynamic> data;
  final String dataType;
  final String? userId;
  final DateTime timestamp;
  final int priority;
  final int size;

  const OfflineDataEntry({
    required this.id,
    required this.key,
    required this.data,
    required this.dataType,
    this.userId,
    required this.timestamp,
    required this.priority,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'data': data,
      'dataType': dataType,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority,
      'size': size,
    };
  }
}

class SyncQueueItem {
  final String id;
  final String key;
  final String dataType;
  final String? userId;
  final DateTime timestamp;
  final int priority;
  final int retryCount;
  final String status;

  const SyncQueueItem({
    required this.id,
    required this.key,
    required this.dataType,
    this.userId,
    required this.timestamp,
    required this.priority,
    required this.retryCount,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'dataType': dataType,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority,
      'retryCount': retryCount,
      'status': status,
    };
  }
}

class OfflineStatus {
  final bool isOffline;
  final DateTime timestamp;
  final String reason;

  const OfflineStatus({
    required this.isOffline,
    required this.timestamp,
    required this.reason,
  });
}

class SyncProgress {
  final int current;
  final int total;
  final String currentItem;
  final String status;

  const SyncProgress({
    required this.current,
    required this.total,
    required this.currentItem,
    required this.status,
  });
}

class OfflineStatistics {
  final int totalEntries;
  final int totalSize;
  final int pendingSync;
  final DateTime? lastSyncTime;
  final Map<String, int> dataTypeCounts;
  final bool isOffline;
  final bool isSyncing;

  const OfflineStatistics({
    required this.totalEntries,
    required this.totalSize,
    required this.pendingSync,
    this.lastSyncTime,
    required this.dataTypeCounts,
    required this.isOffline,
    required this.isSyncing,
  });
}

enum SyncStatus {
  pending,
  processing,
  completed,
  failed,
  retrying,
}
