import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import '../models/client_model.dart';
import '../models/appointment_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final storage = const FlutterSecureStorage();
    const keyName = 'db_key_v1';
    var key = await storage.read(key: keyName);
    key ??= _generateKey();
    await storage.write(key: keyName, value: key);

    final path = join(await getDatabasesPath(), 'psyclinicai.enc.db');
    return await sqlcipher.openDatabase(
      path,
      password: key,
      version: 1,
      onCreate: (db, version) => _onCreate(db, version),
      onUpgrade: (db, oldV, newV) => _onUpgrade(db, oldV, newV),
    );
  }

  String _generateKey() {
    // 32 byte key (base64) – demo amaçlı basit; prod’da KDF kullanılmalı
    return List.generate(32, (i) => (i * 7 + 13) % 256)
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Future<void> _onCreate(Database db, int version) async {
    // Clients table
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        gender TEXT NOT NULL,
        address TEXT,
        emergencyContact TEXT,
        emergencyPhone TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Appointments table
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        clientName TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        location TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringPattern TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (clientId) REFERENCES clients (id)
      )
    ''');

    // Sessions table
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        appointmentId TEXT,
        title TEXT NOT NULL,
        notes TEXT,
        sessionDate TEXT NOT NULL,
        duration INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (clientId) REFERENCES clients (id),
        FOREIGN KEY (appointmentId) REFERENCES appointments (id)
      )
    ''');

    // Audit logs table
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        action TEXT NOT NULL,
        resource TEXT NOT NULL,
        resourceId TEXT,
        details TEXT,
        timestamp TEXT NOT NULL,
        ipAddress TEXT,
        userAgent TEXT
      )
    ''');

    print('✅ Database created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    print('Database upgraded from $oldVersion to $newVersion');
  }

  // Client operations
  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', client.toJson());
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clients');
    return List.generate(maps.length, (i) => Client.fromJson(maps[i]));
  }

  Future<List<Client>> getActiveClients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clients',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Client.fromJson(maps[i]));
  }

  Future<Client?> getClientById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Client.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toJson(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(String id) async {
    final db = await database;
    return await db.update(
      'clients',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Appointment operations
  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toJson());
  }

  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('appointments');
    return List.generate(maps.length, (i) => Appointment.fromJson(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'startTime >= ? AND startTime < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Appointment.fromJson(maps[i]));
  }

  Future<Appointment?> getAppointmentById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Appointment.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toJson(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(String id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search operations
  Future<List<Client>> searchClients(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clients',
      where: 'isActive = ? AND (firstName LIKE ? OR lastName LIKE ? OR email LIKE ? OR phone LIKE ?)',
      whereArgs: [1, '%$query%', '%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Client.fromJson(maps[i]));
  }

  // Statistics
  Future<Map<String, int>> getClientStatistics() async {
    final db = await database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM clients');
    final activeResult = await db.rawQuery('SELECT COUNT(*) as count FROM clients WHERE isActive = 1');
    final maleResult = await db.rawQuery('SELECT COUNT(*) as count FROM clients WHERE isActive = 1 AND gender = ?', ['Erkek']);
    final femaleResult = await db.rawQuery('SELECT COUNT(*) as count FROM clients WHERE isActive = 1 AND gender = ?', ['Kadın']);
    
    return {
      'total': totalResult.first['count'] as int,
      'active': activeResult.first['count'] as int,
      'male': maleResult.first['count'] as int,
      'female': femaleResult.first['count'] as int,
    };
  }

  Future<Map<String, int>> getAppointmentStatistics() async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final todayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM appointments 
      WHERE date(startTime) = date(?)
    ''', [now.toIso8601String()]);

    final weekResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM appointments 
      WHERE startTime >= ? AND startTime < ?
    ''', [weekStart.toIso8601String(), weekStart.add(const Duration(days: 7)).toIso8601String()]);

    final monthResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM appointments 
      WHERE startTime >= ? AND startTime < ?
    ''', [monthStart.toIso8601String(), DateTime(now.year, now.month + 1, 1).toIso8601String()]);

    final upcomingResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM appointments 
      WHERE startTime > ?
    ''', [now.toIso8601String()]);

    return {
      'today': todayResult.first['count'] as int,
      'thisWeek': weekResult.first['count'] as int,
      'thisMonth': monthResult.first['count'] as int,
      'upcoming': upcomingResult.first['count'] as int,
    };
  }

  // Initialize with demo data
  Future<void> initializeWithDemoData() async {
    final db = await database;
    
    // Check if data already exists
    final clientCount = await db.rawQuery('SELECT COUNT(*) as count FROM clients');
    if ((clientCount.first['count'] as int) > 0) {
      print('Demo data already exists');
      return;
    }

    // Insert demo clients
    final demoClients = [
      Client(
        id: '1',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        email: 'ahmet.yilmaz@email.com',
        phone: '+90 555 123 4567',
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Erkek',
        address: 'İstanbul, Türkiye',
        emergencyContact: 'Ayşe Yılmaz',
        emergencyPhone: '+90 555 987 6543',
        notes: 'Anksiyete bozukluğu tedavisi görüyor.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Client(
        id: '2',
        firstName: 'Fatma',
        lastName: 'Kaya',
        email: 'fatma.kaya@email.com',
        phone: '+90 555 234 5678',
        dateOfBirth: DateTime(1985, 8, 22),
        gender: 'Kadın',
        address: 'Ankara, Türkiye',
        emergencyContact: 'Mehmet Kaya',
        emergencyPhone: '+90 555 876 5432',
        notes: 'Depresyon tedavisi devam ediyor.',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Client(
        id: '3',
        firstName: 'Mehmet',
        lastName: 'Demir',
        email: 'mehmet.demir@email.com',
        phone: '+90 555 345 6789',
        dateOfBirth: DateTime(1992, 12, 3),
        gender: 'Erkek',
        address: 'İzmir, Türkiye',
        emergencyContact: 'Zeynep Demir',
        emergencyPhone: '+90 555 765 4321',
        notes: 'PTSD tedavisi başlatıldı.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    for (final client in demoClients) {
      await insertClient(client);
    }

    // Insert demo appointments
    final now = DateTime.now();
    final demoAppointments = [
      Appointment(
        id: '1',
        clientId: '1',
        clientName: 'Ahmet Yılmaz',
        startTime: DateTime(now.year, now.month, now.day, 10, 0),
        endTime: DateTime(now.year, now.month, now.day, 11, 0),
        type: 'Bireysel Terapi',
        status: 'Scheduled',
        notes: 'İlk seans - Anksiyete değerlendirmesi',
        location: 'Ofis 1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: '2',
        clientId: '2',
        clientName: 'Fatma Kaya',
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 0),
        type: 'Bireysel Terapi',
        status: 'Scheduled',
        notes: 'Depresyon tedavisi - 3. seans',
        location: 'Ofis 1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Appointment(
        id: '3',
        clientId: '3',
        clientName: 'Mehmet Demir',
        startTime: DateTime(now.year, now.month, now.day + 1, 9, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        type: 'Bireysel Terapi',
        status: 'Scheduled',
        notes: 'PTSD tedavisi - 2. seans',
        location: 'Ofis 2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (final appointment in demoAppointments) {
      await insertAppointment(appointment);
    }

    print('✅ Demo data inserted successfully');
  }

  // Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
