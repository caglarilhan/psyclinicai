import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  // Offline veri saklama
  final Map<String, dynamic> _offlineData = {};
  final List<Map<String, dynamic>> _pendingOperations = [];
  final List<Map<String, dynamic>> _syncQueue = [];
  
  // Sync durumu
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  // Stream controllers
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _syncStatusController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<bool> get connectivityStream => _connectivityController.stream;
  Stream<Map<String, dynamic>> get syncStatusStream => _syncStatusController.stream;

  // Getter'lar
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  List<Map<String, dynamic>> get pendingOperations => List.unmodifiable(_pendingOperations);
  List<Map<String, dynamic>> get syncQueue => List.unmodifiable(_syncQueue);

  // Servisi başlat
  Future<void> initialize() async {
    await _loadOfflineData();
    await _loadPendingOperations();
    await _checkConnectivity();
    
    // Connectivity listener
    Connectivity().onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
    
    // Otomatik sync timer
    Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isOnline && _pendingOperations.isNotEmpty) {
        _syncData();
      }
    });
  }

  // Offline veri kaydet
  Future<void> saveOfflineData(String key, dynamic data) async {
    _offlineData[key] = data;
    await _saveOfflineDataToStorage();
    
    // Pending operation ekle
    _addPendingOperation('save', key, data);
  }

  // Offline veri al
  dynamic getOfflineData(String key) {
    return _offlineData[key];
  }

  // Offline veri sil
  Future<void> deleteOfflineData(String key) async {
    _offlineData.remove(key);
    await _saveOfflineDataToStorage();
    
    // Pending operation ekle
    _addPendingOperation('delete', key, null);
  }

  // Pending operation ekle
  void _addPendingOperation(String operation, String key, dynamic data) {
    final operationData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'operation': operation,
      'key': key,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    };
    
    _pendingOperations.add(operationData);
    _savePendingOperations();
    
    // Sync status güncelle
    _updateSyncStatus();
  }

  // Connectivity değişikliğini handle et
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (!wasOnline && _isOnline) {
      // Online'a geçti, sync yap
      _syncData();
    }
    
    _connectivityController.add(_isOnline);
  }

  // Veri sync et
  Future<void> _syncData() async {
    if (_isSyncing || _pendingOperations.isEmpty) return;
    
    setState(() {
      _isSyncing = true;
    });
    
    try {
      // Pending operations'ları işle
      for (final operation in List.from(_pendingOperations)) {
        if (operation['synced'] == false) {
          await _processOperation(operation);
          operation['synced'] = true;
        }
      }
      
      // Sync edilmiş operations'ları temizle
      _pendingOperations.removeWhere((op) => op['synced'] == true);
      await _savePendingOperations();
      
      _lastSyncTime = DateTime.now();
      _updateSyncStatus();
      
    } catch (e) {
      // Sync hatası, tekrar denenecek
      print('Sync error: $e');
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  // Operation işle
  Future<void> _processOperation(Map<String, dynamic> operation) async {
    final op = operation['operation'];
    final key = operation['key'];
    final data = operation['data'];
    
    switch (op) {
      case 'save':
        await _syncSaveOperation(key, data);
        break;
      case 'delete':
        await _syncDeleteOperation(key);
        break;
      case 'update':
        await _syncUpdateOperation(key, data);
        break;
    }
  }

  // Save operation sync
  Future<void> _syncSaveOperation(String key, dynamic data) async {
    // TODO: API'ye veri gönder
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate API call
  }

  // Delete operation sync
  Future<void> _syncDeleteOperation(String key) async {
    // TODO: API'den veri sil
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate API call
  }

  // Update operation sync
  Future<void> _syncUpdateOperation(String key, dynamic data) async {
    // TODO: API'de veri güncelle
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate API call
  }

  // Manuel sync
  Future<void> manualSync() async {
    await _syncData();
  }

  // Offline data storage
  Future<void> _saveOfflineDataToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('offline_data', json.encode(_offlineData));
  }

  Future<void> _loadOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('offline_data');
    if (data != null) {
      _offlineData.addAll(json.decode(data));
    }
  }

  // Pending operations storage
  Future<void> _savePendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_operations', json.encode(_pendingOperations));
  }

  Future<void> _loadPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('pending_operations');
    if (data != null) {
      final operations = json.decode(data) as List;
      _pendingOperations.addAll(operations.cast<Map<String, dynamic>>());
    }
  }

  // Connectivity check
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

  // Sync status güncelle
  void _updateSyncStatus() {
    final status = {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'pendingOperations': _pendingOperations.length,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
    };
    
    _syncStatusController.add(status);
  }

  // Offline mode için CRUD operations
  Future<void> createOfflineRecord(String collection, Map<String, dynamic> data) async {
    final key = '${collection}_${DateTime.now().millisecondsSinceEpoch}';
    await saveOfflineData(key, {
      'collection': collection,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
      'synced': false,
    });
  }

  Future<void> updateOfflineRecord(String key, Map<String, dynamic> data) async {
    final existingData = getOfflineData(key);
    if (existingData != null) {
      existingData['data'] = data;
      existingData['updatedAt'] = DateTime.now().toIso8601String();
      existingData['synced'] = false;
      await saveOfflineData(key, existingData);
    }
  }

  Future<void> deleteOfflineRecord(String key) async {
    await deleteOfflineData(key);
  }

  List<Map<String, dynamic>> getOfflineRecords(String collection) {
    final records = <Map<String, dynamic>>[];
    
    _offlineData.forEach((key, value) {
      if (value is Map && value['collection'] == collection) {
        records.add({
          'key': key,
          ...value,
        });
      }
    });
    
    return records;
  }

  // Conflict resolution
  Future<Map<String, dynamic>> resolveConflict(String key, Map<String, dynamic> localData, Map<String, dynamic> serverData) async {
    // Basit conflict resolution: Server data'yı öncelikle
    return serverData;
  }

  // Sync istatistikleri
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'pendingOperations': _pendingOperations.length,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'offlineDataSize': _offlineData.length,
      'syncQueueSize': _syncQueue.length,
    };
  }

  // Offline mode durumu
  bool isOfflineMode() {
    return !_isOnline;
  }

  // Offline indicator
  Widget buildOfflineIndicator() {
    return StreamBuilder<bool>(
      stream: connectivityStream,
      builder: (context, snapshot) {
        final isOffline = snapshot.data == false;
        
        if (!isOffline) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.orange,
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Çevrimdışı mod - Veriler yerel olarak saklanıyor',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              if (_pendingOperations.isNotEmpty)
                Text(
                  '${_pendingOperations.length} bekleyen işlem',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }

  // Sync progress indicator
  Widget buildSyncProgress() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null || !status['isSyncing']) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          color: Colors.blue,
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Veriler senkronize ediliyor...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  // Dispose
  void dispose() {
    _connectivityController.close();
    _syncStatusController.close();
  }

  // State management için helper
  void setState(VoidCallback fn) {
    fn();
    _updateSyncStatus();
  }
}
