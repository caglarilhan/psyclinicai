import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineService extends ChangeNotifier {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  bool _isOnline = true;
  bool _isInitialized = false;
  Database? _database;
  final List<Map<String, dynamic>> _pendingSync = [];
  final List<Map<String, dynamic>> _offlineData = [];

  bool get isOnline => _isOnline;
  bool get isInitialized => _isInitialized;
  List<Map<String, dynamic>> get pendingSync => List.unmodifiable(_pendingSync);
  List<Map<String, dynamic>> get offlineData => List.unmodifiable(_offlineData);

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initDatabase();
    await _checkConnectivity();
    await _loadOfflineData();
    
    // Connectivity listener
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectivityStatus(result);
    });

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'psyclinic_offline.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Patients table
        await db.execute('''
          CREATE TABLE patients (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            diagnosis TEXT,
            last_session TEXT,
            status TEXT,
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'pending'
          )
        ''');

        // Appointments table
        await db.execute('''
          CREATE TABLE appointments (
            id TEXT PRIMARY KEY,
            patient_id TEXT,
            doctor_id TEXT,
            date TEXT,
            time TEXT,
            type TEXT,
            status TEXT,
            notes TEXT,
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'pending'
          )
        ''');

        // Prescriptions table
        await db.execute('''
          CREATE TABLE prescriptions (
            id TEXT PRIMARY KEY,
            patient_id TEXT,
            medication_name TEXT,
            dosage TEXT,
            frequency TEXT,
            duration TEXT,
            instructions TEXT,
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'pending'
          )
        ''');

        // Voice notes table
        await db.execute('''
          CREATE TABLE voice_notes (
            id TEXT PRIMARY KEY,
            patient_id TEXT,
            title TEXT,
            duration TEXT,
            transcription TEXT,
            tags TEXT,
            file_path TEXT,
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'pending'
          )
        ''');

        // Mood entries table
        await db.execute('''
          CREATE TABLE mood_entries (
            id TEXT PRIMARY KEY,
            patient_id TEXT,
            mood_score INTEGER,
            anxiety_level INTEGER,
            energy_level INTEGER,
            sleep_quality INTEGER,
            notes TEXT,
            tags TEXT,
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'pending'
          )
        ''');

        // Sync queue table
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_name TEXT NOT NULL,
            record_id TEXT NOT NULL,
            operation TEXT NOT NULL,
            data TEXT NOT NULL,
            created_at TEXT,
            retry_count INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectivityStatus(result);
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      _isOnline = false;
    }
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (wasOnline != _isOnline) {
      notifyListeners();
      
      if (_isOnline) {
        _syncPendingData();
      }
    }
  }

  Future<void> _loadOfflineData() async {
    if (_database == null) return;

    try {
      // Load patients
      final patients = await _database!.query('patients');
      _offlineData.addAll(patients.map((p) => {...p, 'table': 'patients'}));

      // Load appointments
      final appointments = await _database!.query('appointments');
      _offlineData.addAll(appointments.map((a) => {...a, 'table': 'appointments'}));

      // Load prescriptions
      final prescriptions = await _database!.query('prescriptions');
      _offlineData.addAll(prescriptions.map((p) => {...p, 'table': 'prescriptions'}));

      // Load voice notes
      final voiceNotes = await _database!.query('voice_notes');
      _offlineData.addAll(voiceNotes.map((v) => {...v, 'table': 'voice_notes'}));

      // Load mood entries
      final moodEntries = await _database!.query('mood_entries');
      _offlineData.addAll(moodEntries.map((m) => {...m, 'table': 'mood_entries'}));

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading offline data: $e');
    }
  }

  // Patient operations
  Future<String> addPatient(Map<String, dynamic> patient) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();
    
    final patientData = {
      'id': id,
      'name': patient['name'],
      'diagnosis': patient['diagnosis'],
      'last_session': patient['last_session'],
      'status': patient['status'] ?? 'active',
      'created_at': now,
      'updated_at': now,
      'sync_status': _isOnline ? 'synced' : 'pending',
    };

    if (_isOnline) {
      // Try to sync immediately
      try {
        await _syncPatient(patientData);
        patientData['sync_status'] = 'synced';
    } catch (e) {
        patientData['sync_status'] = 'pending';
        await _addToSyncQueue('patients', id, 'create', patientData);
      }
    } else {
      await _addToSyncQueue('patients', id, 'create', patientData);
    }

    await _database!.insert('patients', patientData);
    _offlineData.add({...patientData, 'table': 'patients'});
    notifyListeners();

    return id;
  }

  Future<void> updatePatient(String id, Map<String, dynamic> updates) async {
    final now = DateTime.now().toIso8601String();
    final updateData = {
      ...updates,
      'updated_at': now,
      'sync_status': _isOnline ? 'synced' : 'pending',
    };

    if (_isOnline) {
      try {
        await _syncPatientUpdate(id, updateData);
        updateData['sync_status'] = 'synced';
      } catch (e) {
        updateData['sync_status'] = 'pending';
        await _addToSyncQueue('patients', id, 'update', updateData);
      }
    } else {
      await _addToSyncQueue('patients', id, 'update', updateData);
    }

    await _database!.update(
      'patients',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Update offline data
    final index = _offlineData.indexWhere((item) => item['id'] == id && item['table'] == 'patients');
    if (index != -1) {
      _offlineData[index] = {..._offlineData[index], ...updateData};
    }
    notifyListeners();
  }

  Future<void> deletePatient(String id) async {
    if (_isOnline) {
      try {
        await _syncPatientDelete(id);
      } catch (e) {
        await _addToSyncQueue('patients', id, 'delete', {'id': id});
      }
    } else {
      await _addToSyncQueue('patients', id, 'delete', {'id': id});
    }

    await _database!.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );

    _offlineData.removeWhere((item) => item['id'] == id && item['table'] == 'patients');
    notifyListeners();
  }

  // Appointment operations
  Future<String> addAppointment(Map<String, dynamic> appointment) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();
    
    final appointmentData = {
      'id': id,
      'patient_id': appointment['patient_id'],
      'doctor_id': appointment['doctor_id'],
      'date': appointment['date'],
      'time': appointment['time'],
      'type': appointment['type'],
      'status': appointment['status'] ?? 'scheduled',
      'notes': appointment['notes'],
      'created_at': now,
      'updated_at': now,
      'sync_status': _isOnline ? 'synced' : 'pending',
    };

    if (_isOnline) {
      try {
        await _syncAppointment(appointmentData);
        appointmentData['sync_status'] = 'synced';
    } catch (e) {
        appointmentData['sync_status'] = 'pending';
        await _addToSyncQueue('appointments', id, 'create', appointmentData);
      }
    } else {
      await _addToSyncQueue('appointments', id, 'create', appointmentData);
    }

    await _database!.insert('appointments', appointmentData);
    _offlineData.add({...appointmentData, 'table': 'appointments'});
    notifyListeners();

    return id;
  }

  // Voice note operations
  Future<String> addVoiceNote(Map<String, dynamic> voiceNote) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();
    
    final voiceNoteData = {
      'id': id,
      'patient_id': voiceNote['patient_id'],
      'title': voiceNote['title'],
      'duration': voiceNote['duration'],
      'transcription': voiceNote['transcription'],
      'tags': voiceNote['tags']?.join(',') ?? '',
      'file_path': voiceNote['file_path'],
      'created_at': now,
      'updated_at': now,
      'sync_status': _isOnline ? 'synced' : 'pending',
    };

    if (_isOnline) {
      try {
        await _syncVoiceNote(voiceNoteData);
        voiceNoteData['sync_status'] = 'synced';
      } catch (e) {
        voiceNoteData['sync_status'] = 'pending';
        await _addToSyncQueue('voice_notes', id, 'create', voiceNoteData);
      }
    } else {
      await _addToSyncQueue('voice_notes', id, 'create', voiceNoteData);
    }

    await _database!.insert('voice_notes', voiceNoteData);
    _offlineData.add({...voiceNoteData, 'table': 'voice_notes'});
    notifyListeners();

    return id;
  }

  // Mood entry operations
  Future<String> addMoodEntry(Map<String, dynamic> moodEntry) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();
    
    final moodEntryData = {
      'id': id,
      'patient_id': moodEntry['patient_id'],
      'mood_score': moodEntry['mood_score'],
      'anxiety_level': moodEntry['anxiety_level'],
      'energy_level': moodEntry['energy_level'],
      'sleep_quality': moodEntry['sleep_quality'],
      'notes': moodEntry['notes'],
      'tags': moodEntry['tags']?.join(',') ?? '',
      'created_at': now,
      'updated_at': now,
      'sync_status': _isOnline ? 'synced' : 'pending',
    };

    if (_isOnline) {
      try {
        await _syncMoodEntry(moodEntryData);
        moodEntryData['sync_status'] = 'synced';
    } catch (e) {
        moodEntryData['sync_status'] = 'pending';
        await _addToSyncQueue('mood_entries', id, 'create', moodEntryData);
      }
    } else {
      await _addToSyncQueue('mood_entries', id, 'create', moodEntryData);
    }

    await _database!.insert('mood_entries', moodEntryData);
    _offlineData.add({...moodEntryData, 'table': 'mood_entries'});
    notifyListeners();

    return id;
  }

  // Sync queue operations
  Future<void> _addToSyncQueue(String tableName, String recordId, String operation, Map<String, dynamic> data) async {
    await _database!.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });

    _pendingSync.add({
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  Future<void> _syncPendingData() async {
    if (_database == null) return;

    try {
      final pendingItems = await _database!.query('sync_queue');
      
      for (final item in pendingItems) {
        try {
          final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;
          
          switch (item['table_name']) {
            case 'patients':
              if (item['operation'] == 'create') {
                await _syncPatient(data);
              } else if (item['operation'] == 'update') {
                await _syncPatientUpdate(item['record_id'] as String, data);
              } else if (item['operation'] == 'delete') {
                await _syncPatientDelete(item['record_id'] as String);
              }
              break;
            case 'appointments':
              if (item['operation'] == 'create') {
                await _syncAppointment(data);
              }
              break;
            case 'voice_notes':
              if (item['operation'] == 'create') {
                await _syncVoiceNote(data);
              }
              break;
            case 'mood_entries':
              if (item['operation'] == 'create') {
                await _syncMoodEntry(data);
              }
              break;
          }

          // Remove from sync queue
          await _database!.delete(
            'sync_queue',
            where: 'id = ?',
            whereArgs: [item['id']],
          );

          // Update sync status
          await _database!.update(
            item['table_name'] as String,
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [item['record_id']],
          );

          // Remove from pending sync
          _pendingSync.removeWhere((p) => 
            p['table_name'] == item['table_name'] && 
            p['record_id'] == item['record_id']
          );
          
        } catch (e) {
          debugPrint('Sync error for ${item['table_name']}: $e');
          
          // Increment retry count
          await _database!.update(
            'sync_queue',
            {'retry_count': (item['retry_count'] as int) + 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing pending data: $e');
    }
  }

  // Public wrapper to trigger sync from UI safely
  Future<void> syncPendingData() async {
    await _syncPendingData();
  }

  // Mock sync methods (replace with actual API calls)
  Future<void> _syncPatient(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate API call
    if (data['name'] == 'error') {
      throw Exception('Sync failed');
    }
  }

  Future<void> _syncPatientUpdate(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate API call
  }

  Future<void> _syncPatientDelete(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate API call
  }

  Future<void> _syncAppointment(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate API call
  }

  Future<void> _syncVoiceNote(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate API call
  }

  Future<void> _syncMoodEntry(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate API call
  }

  // Utility methods
  List<Map<String, dynamic>> getPatients() {
    return _offlineData.where((item) => item['table'] == 'patients').toList();
  }

  List<Map<String, dynamic>> getAppointments() {
    return _offlineData.where((item) => item['table'] == 'appointments').toList();
  }

  List<Map<String, dynamic>> getVoiceNotes() {
    return _offlineData.where((item) => item['table'] == 'voice_notes').toList();
  }

  List<Map<String, dynamic>> getMoodEntries() {
    return _offlineData.where((item) => item['table'] == 'mood_entries').toList();
  }

  int getPendingSyncCount() {
    return _pendingSync.length;
  }

  Future<void> clearOfflineData() async {
    if (_database == null) return;

    await _database!.delete('patients');
    await _database!.delete('appointments');
    await _database!.delete('prescriptions');
    await _database!.delete('voice_notes');
    await _database!.delete('mood_entries');
    await _database!.delete('sync_queue');

    _offlineData.clear();
    _pendingSync.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}