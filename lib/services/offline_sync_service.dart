import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineSyncService extends ChangeNotifier {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  Database? _database;
  final Connectivity _connectivity = Connectivity();
  Timer? _syncTimer;
  bool _isOnline = false;
  bool _isSyncing = false;

  // Stream controllers
  final StreamController<bool> _onlineStatusController = StreamController<bool>.broadcast();
  final StreamController<SyncProgress> _syncProgressController = StreamController<SyncProgress>.broadcast();
  final StreamController<SyncError> _syncErrorController = StreamController<SyncError>.broadcast();

  // Streams
  Stream<bool> get onlineStatusStream => _onlineStatusController.stream;
  Stream<SyncProgress> get syncProgressStream => _syncProgressController.stream;
  Stream<SyncError> get syncErrorStream => _syncErrorController.stream;

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  Database? get database => _database;

  Future<void> initialize() async {
    try {
      final bool isTestEnv = const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
      // Database'i başlat
      if (!isTestEnv) {
        await _initializeDatabase();
      }
      
      // Connectivity listener'ı başlat
      await _setupConnectivityListener();
      
      // Otomatik sync timer'ı başlat
      _startAutoSyncTimer();
      
      print('OfflineSyncService initialized successfully');
    } catch (e) {
      print('OfflineSyncService initialization failed: $e');
    }
  }

  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'psyclinic_offline.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    print('Local database initialized at: $path');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Sessions tablosu
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        therapistId TEXT NOT NULL,
        notes TEXT,
        aiSummary TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'pending',
        lastSyncAttempt TEXT,
        syncAttempts INTEGER DEFAULT 0
      )
    ''');

    // Appointments tablosu
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        therapistId TEXT NOT NULL,
        appointmentTime TEXT NOT NULL,
        duration INTEGER NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'pending',
        lastSyncAttempt TEXT,
        syncAttempts INTEGER DEFAULT 0
      )
    ''');

    // Clients tablosu
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        dateOfBirth TEXT,
        diagnosis TEXT,
        medications TEXT,
        emergencyContact TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'pending',
        lastSyncAttempt TEXT,
        syncAttempts INTEGER DEFAULT 0
      )
    ''');

    // Medications tablosu
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT,
        frequency TEXT,
        startDate TEXT,
        endDate TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'pending',
        lastSyncAttempt TEXT,
        syncAttempts INTEGER DEFAULT 0
      )
    ''');

    // Sync queue tablosu
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableName TEXT NOT NULL,
        recordId TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        priority INTEGER DEFAULT 0,
        retryCount INTEGER DEFAULT 0
      )
    ''');

    // Sync history tablosu
    await db.execute('''
      CREATE TABLE sync_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableName TEXT NOT NULL,
        recordId TEXT NOT NULL,
        operation TEXT NOT NULL,
        status TEXT NOT NULL,
        errorMessage TEXT,
        syncedAt TEXT NOT NULL,
        dataSize INTEGER
      )
    ''');

    print('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Database upgrade logic
    if (oldVersion < 1) {
      // Add new columns or tables for version 1
    }
  }

  Future<void> _setupConnectivityListener() async {
    // Initial connectivity check
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateOnlineStatus(result != ConnectivityResult.none);

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      bool isOnline = result != ConnectivityResult.none;
      _updateOnlineStatus(isOnline);
      
      if (isOnline && !_isSyncing) {
        // Online olduğunda otomatik sync başlat
        _triggerAutoSync();
      }
    });
  }

  void _updateOnlineStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _onlineStatusController.add(online);
      notifyListeners();
      
      if (online) {
        print('Device is now online');
      } else {
        print('Device is now offline');
      }
    }
  }

  void _startAutoSyncTimer() {
    // Her 5 dakikada bir sync kontrol et
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline && !_isSyncing) {
        _triggerAutoSync();
      }
    });
  }

  void _triggerAutoSync() {
    if (_isOnline && !_isSyncing) {
      _performSync();
    }
  }

  // Veri ekleme/güncelleme (offline-first approach)
  Future<void> insertOrUpdate({
    required String tableName,
    required String id,
    required Map<String, dynamic> data,
    String operation = 'upsert',
  }) async {
    try {
      // Local database'e kaydet
      await _saveToLocalDatabase(tableName, id, data, operation);
      
      // Sync queue'ya ekle
      await _addToSyncQueue(tableName, id, operation, data);
      
      // Online ise hemen sync et
      if (_isOnline && !_isSyncing) {
        _performSync();
      }
    } catch (e) {
      print('Error in insertOrUpdate: $e');
      rethrow;
    }
  }

  Future<void> _saveToLocalDatabase(
    String tableName,
    String id,
    Map<String, dynamic> data,
    String operation,
  ) async {
    if (_database == null) return;

    final now = DateTime.now().toIso8601String();
    final recordData = {
      ...data,
      'updatedAt': now,
      'syncStatus': 'pending',
      'lastSyncAttempt': null,
      'syncAttempts': 0,
    };

    if (operation == 'upsert') {
      // Upsert operation
      await _database!.insert(
        tableName,
        recordData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else if (operation == 'delete') {
      // Soft delete - syncStatus'u deleted olarak işaretle
      await _database!.update(
        tableName,
        {'syncStatus': 'deleted', 'updatedAt': now},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> _addToSyncQueue(
    String tableName,
    String id,
    String operation,
    Map<String, dynamic> data,
  ) async {
    if (_database == null) return;

    final queueData = {
      'tableName': tableName,
      'recordId': id,
      'operation': operation,
      'data': json.encode(data),
      'createdAt': DateTime.now().toIso8601String(),
      'priority': _getPriority(operation),
      'retryCount': 0,
    };

    await _database!.insert('sync_queue', queueData);
  }

  int _getPriority(String operation) {
    switch (operation) {
      case 'delete':
        return 3; // En yüksek öncelik
      case 'upsert':
        return 2; // Orta öncelik
      case 'update':
        return 1; // Düşük öncelik
      default:
        return 0;
    }
  }

  // Ana sync fonksiyonu
  Future<void> _performSync() async {
    if (_isSyncing || !_isOnline) return;

    try {
      _isSyncing = true;
      _syncProgressController.add(SyncProgress(
        status: 'starting',
        message: 'Senkronizasyon başlatılıyor...',
        progress: 0.0,
      ));

      // Sync queue'dan kayıtları al
      final pendingRecords = await _getPendingSyncRecords();
      
      if (pendingRecords.isEmpty) {
        _syncProgressController.add(SyncProgress(
          status: 'completed',
          message: 'Senkronize edilecek kayıt bulunamadı',
          progress: 100.0,
        ));
        return;
      }

      int processedCount = 0;
      int totalCount = pendingRecords.length;

      for (final record in pendingRecords) {
        try {
          await _syncRecord(record);
          processedCount++;
          
          final progress = (processedCount / totalCount) * 100;
          _syncProgressController.add(SyncProgress(
            status: 'syncing',
            message: 'Kayıt senkronize ediliyor: ${record['tableName']}',
            progress: progress,
          ));
        } catch (e) {
          // Sync hatası - retry count'u artır
          await _incrementRetryCount(record['id'] as int);
          
          if ((record['retryCount'] as int) >= 3) {
            // 3 deneme sonrası hata olarak işaretle
            await _markAsSyncError(record['id'] as int, e.toString());
          }
        }
      }

      // Sync history'yi güncelle
      await _updateSyncHistory(pendingRecords);
      
      _syncProgressController.add(SyncProgress(
        status: 'completed',
        message: 'Senkronizasyon tamamlandı: $processedCount/$totalCount kayıt',
        progress: 100.0,
      ));

    } catch (e) {
      _syncErrorController.add(SyncError(
        message: 'Sync hatası: $e',
        timestamp: DateTime.now(),
        details: e.toString(),
      ));
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingSyncRecords() async {
    if (_database == null) return [];

    return await _database!.query(
      'sync_queue',
      orderBy: 'priority DESC, createdAt ASC',
      limit: 50, // Her seferinde maksimum 50 kayıt
    );
  }

  Future<void> _syncRecord(Map<String, dynamic> record) async {
    // Burada gerçek API çağrıları yapılacak
    // Şimdilik simüle ediyoruz
    
    final tableName = record['tableName'];
    final recordId = record['recordId'];
    final operation = record['operation'];
    final data = json.decode(record['data']);

    // Simüle edilmiş API çağrısı
    await Future.delayed(Duration(milliseconds: 100 + ((record['retryCount'] as int) * 50)));

    // Başarılı sync sonrası queue'dan kaldır
    await _removeFromSyncQueue(record['id'] as int);
    
    // Local database'de sync status'u güncelle
    await _updateSyncStatus(tableName, recordId, 'synced');
  }

  Future<void> _incrementRetryCount(int queueId) async {
    if (_database == null) return;

    // Get current retry count and increment
    final currentRecord = await _database!.query(
      'sync_queue',
      columns: ['retryCount'],
      where: 'id = ?',
      whereArgs: [queueId],
    );
    
    if (currentRecord.isNotEmpty) {
      final currentCount = currentRecord.first['retryCount'] as int? ?? 0;
      await _database!.update(
        'sync_queue',
        {'retryCount': currentCount + 1},
        where: 'id = ?',
        whereArgs: [queueId],
      );
    }
  }

  Future<void> _markAsSyncError(int queueId, String errorMessage) async {
    if (_database == null) return;

    await _database!.update(
      'sync_queue',
      {'retryCount': 999}, // Hata olarak işaretle
      where: 'id = ?',
      whereArgs: [queueId],
    );
  }

  Future<void> _removeFromSyncQueue(int queueId) async {
    if (_database == null) return;

    await _database!.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [queueId],
    );
  }

  Future<void> _updateSyncStatus(String tableName, String recordId, String status) async {
    if (_database == null) return;

    await _database!.update(
      tableName,
      {
        'syncStatus': status,
        'lastSyncAttempt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  Future<void> _updateSyncHistory(List<Map<String, dynamic>> records) async {
    if (_database == null) return;

    for (final record in records) {
      final historyData = {
        'tableName': record['tableName'],
        'recordId': record['recordId'],
        'operation': record['operation'],
        'status': 'success',
        'errorMessage': null,
        'syncedAt': DateTime.now().toIso8601String(),
        'dataSize': record['data'].length,
      };

      await _database!.insert('sync_history', historyData);
    }
  }

  // Offline veri okuma
  Future<List<Map<String, dynamic>>> getOfflineData({
    required String tableName,
    String? where,
    List<Object>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    if (_database == null) return [];

    try {
      return await _database!.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      );
    } catch (e) {
      print('Error reading offline data: $e');
      return [];
    }
  }

  // Sync durumu kontrolü
  Future<SyncStatus> getSyncStatus() async {
    if (_database == null) {
      return SyncStatus(
        totalRecords: 0,
        pendingRecords: 0,
        syncedRecords: 0,
        errorRecords: 0,
        lastSyncTime: null,
        isOnline: _isOnline,
        isSyncing: _isSyncing,
      );
    }

    try {
      final pendingCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM sync_queue')
      ) ?? 0;

      final totalCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM sessions')
      ) ?? 0;

      final syncedCount = Sqflite.firstIntValue(
        await _database!.rawQuery(
          'SELECT COUNT(*) FROM sessions WHERE syncStatus = ?',
          ['synced']
        )
      ) ?? 0;

      final errorCount = Sqflite.firstIntValue(
        await _database!.rawQuery(
          'SELECT COUNT(*) FROM sync_queue WHERE retryCount >= 3'
        )
      ) ?? 0;

      final lastSyncResult = await _database!.query(
        'sync_history',
        orderBy: 'syncedAt DESC',
        limit: 1,
      );

      DateTime? lastSyncTime;
      if (lastSyncResult.isNotEmpty) {
        lastSyncTime = DateTime.parse(lastSyncResult.first['syncedAt'] as String);
      }

      return SyncStatus(
        totalRecords: totalCount,
        pendingRecords: pendingCount,
        syncedRecords: syncedCount,
        errorRecords: errorCount,
        lastSyncTime: lastSyncTime,
        isOnline: _isOnline,
        isSyncing: _isSyncing,
      );
    } catch (e) {
      print('Error getting sync status: $e');
      return SyncStatus(
        totalRecords: 0,
        pendingRecords: 0,
        syncedRecords: 0,
        errorRecords: 0,
        lastSyncTime: null,
        isOnline: _isOnline,
        isSyncing: _isSyncing,
      );
    }
  }

  // Manuel sync tetikleme
  Future<void> triggerManualSync() async {
    if (_isOnline && !_isSyncing) {
      await _performSync();
    } else {
      throw Exception('Sync is not available at the moment');
    }
  }

  // Conflict resolution
  Future<void> resolveConflict({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> serverData,
    required ConflictResolution resolution,
  }) async {
    Map<String, dynamic> resolvedData;

    switch (resolution) {
      case ConflictResolution.useLocal:
        resolvedData = localData;
        break;
      case ConflictResolution.useServer:
        resolvedData = serverData;
        break;
      case ConflictResolution.merge:
        resolvedData = {...serverData, ...localData};
        break;
    }

    // Resolved data'yı local database'e kaydet
    await _saveToLocalDatabase(tableName, recordId, resolvedData, 'upsert');
    
    // Sync queue'ya ekle
    await _addToSyncQueue(tableName, recordId, 'upsert', resolvedData);
  }

  // Database temizleme
  Future<void> clearOfflineData() async {
    if (_database == null) return;

    try {
      await _database!.delete('sync_queue');
      await _database!.delete('sync_history');
      
      // Ana tablolardaki sync status'ları sıfırla
      await _database!.update('sessions', {'syncStatus': 'pending'});
      await _database!.update('appointments', {'syncStatus': 'pending'});
      await _database!.update('clients', {'syncStatus': 'pending'});
      await _database!.update('medications', {'syncStatus': 'pending'});
      
      print('Offline data cleared successfully');
    } catch (e) {
      print('Error clearing offline data: $e');
    }
  }

  // Backup ve restore
  Future<String> createBackup() async {
    if (_database == null) return '';

    try {
      final tables = ['sessions', 'appointments', 'clients', 'medications', 'sync_queue', 'sync_history'];
      final backup = <String, List<Map<String, dynamic>>>{};

      for (final table in tables) {
        final data = await _database!.query(table);
        backup[table] = data;
      }

      return json.encode(backup);
    } catch (e) {
      print('Error creating backup: $e');
      return '';
    }
  }

  Future<void> restoreFromBackup(String backupData) async {
    if (_database == null) return;

    try {
      final backup = json.decode(backupData) as Map<String, dynamic>;
      
      for (final entry in backup.entries) {
        final tableName = entry.key;
        final records = entry.value as List<dynamic>;
        
        for (final record in records) {
          await _database!.insert(
            tableName,
            record as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      
      print('Backup restored successfully');
    } catch (e) {
      print('Error restoring backup: $e');
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncProgressController.close();
    _syncErrorController.close();
    _onlineStatusController.close();
    _database?.close();
  }
}

// Data classes
class SyncProgress {
  final String status; // 'starting', 'syncing', 'completed', 'error'
  final String message;
  final double progress; // 0.0 - 100.0

  SyncProgress({
    required this.status,
    required this.message,
    required this.progress,
  });
}

class SyncError {
  final String message;
  final DateTime timestamp;
  final String details;

  SyncError({
    required this.message,
    required this.timestamp,
    required this.details,
  });
}

class SyncStatus {
  final int totalRecords;
  final int pendingRecords;
  final int syncedRecords;
  final int errorRecords;
  final DateTime? lastSyncTime;
  final bool isOnline;
  final bool isSyncing;

  SyncStatus({
    required this.totalRecords,
    required this.pendingRecords,
    required this.syncedRecords,
    required this.errorRecords,
    this.lastSyncTime,
    required this.isOnline,
    required this.isSyncing,
  });

  double get syncProgress {
    if (totalRecords == 0) return 100.0;
    return (syncedRecords / totalRecords) * 100;
  }

  bool get hasErrors => errorRecords > 0;
  bool get needsSync => pendingRecords > 0;
}

enum ConflictResolution {
  useLocal,
  useServer,
  merge,
}
