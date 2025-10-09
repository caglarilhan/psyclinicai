import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/session_note_models.dart';
import 'audit_log_service.dart';

class SessionNoteService {
  static final SessionNoteService _instance = SessionNoteService._internal();
  factory SessionNoteService() => _instance;
  SessionNoteService._internal();

  static const _secureStorage = FlutterSecureStorage();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'psyclinicai.enc.db');
    String? encryptionKey = await _getEncryptionKey();
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      password: encryptionKey,
    );
  }

  Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: 'db_encryption_key');
    if (key == null) {
      key = _generateRandomKey();
      await _secureStorage.write(key: 'db_encryption_key', value: key);
    }
    return key;
  }

  String _generateRandomKey() {
    return 'session-note-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE session_notes (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        client_id TEXT NOT NULL,
        therapist_id TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        status TEXT NOT NULL,
        version INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        locked_at TEXT,
        locked_by TEXT,
        attachments TEXT,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE session_note_versions (
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        version INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        change_description TEXT NOT NULL,
        FOREIGN KEY (note_id) REFERENCES session_notes (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE session_note_templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        is_default INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultTemplates(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultTemplates(Database db) async {
    final templates = [
      SessionNoteTemplate(
        id: 'soap-template',
        name: 'SOAP Notu',
        type: SessionNoteType.soap,
        content: '''**Subjective (Öznel):**
Hastanın belirttiği şikayetler ve duygular:

**Objective (Objektif):**
Gözlemlenen davranışlar ve fiziksel durum:

**Assessment (Değerlendirme):**
Klinik değerlendirme ve tanısal düşünceler:

**Plan (Plan):**
Tedavi planı ve sonraki adımlar:''',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      SessionNoteTemplate(
        id: 'dap-template',
        name: 'DAP Notu',
        type: SessionNoteType.dap,
        content: '''**Data (Veri):**
Toplanan bilgiler ve gözlemler:

**Assessment (Değerlendirme):**
Klinik değerlendirme:

**Plan (Plan):**
Tedavi planı:''',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      SessionNoteTemplate(
        id: 'emdr-template',
        name: 'EMDR Notu',
        type: SessionNoteType.emdr,
        content: '''**EMDR Seans Notu**

**Hedef Anı:**
- Anı: 
- Duygu: 
- Vücut hissi: 
- Negatif inanç: 
- Pozitif inanç: 
- VOC: 
- SUD: 

**İşleme:**
- Bilateral stimülasyon: 
- Değişimler: 

**Sonuç:**
- Final SUD: 
- Final VOC: 
- Beden taraması: 
- Gelecek şablon: ''',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (final template in templates) {
      await db.insert('session_note_templates', template.toJson());
    }
  }

  Future<String> createSessionNote({
    required String sessionId,
    required String clientId,
    required String therapistId,
    required SessionNoteType type,
    String? templateId,
  }) async {
    final db = await database;
    final noteId = 'note_${DateTime.now().millisecondsSinceEpoch}';
    
    String content = '';
    if (templateId != null) {
      final template = await getTemplate(templateId);
      if (template != null) {
        content = template.content;
      }
    }

    final note = SessionNote(
      id: noteId,
      sessionId: sessionId,
      clientId: clientId,
      therapistId: therapistId,
      type: type,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert('session_notes', note.toJson());
    
    await AuditLogService().insertLog(
      action: 'session_note.create',
      details: 'Session note created: $noteId',
      userId: therapistId,
      resourceId: noteId,
    );

    return noteId;
  }

  Future<bool> updateSessionNote(String noteId, String content, String therapistId) async {
    final db = await database;
    
    // Get current note
    final currentNote = await getSessionNote(noteId);
    if (currentNote == null) return false;
    
    // Check if note is locked
    if (currentNote.status == SessionNoteStatus.locked) {
      return false;
    }

    // Create version backup
    await _createVersionBackup(currentNote, therapistId, 'Content updated');

    // Update note
    final updatedNote = currentNote.copyWith(
      content: content,
      updatedAt: DateTime.now(),
      version: currentNote.version + 1,
    );

    await db.update(
      'session_notes',
      updatedNote.toJson(),
      where: 'id = ?',
      whereArgs: [noteId],
    );

    await AuditLogService().insertLog(
      action: 'session_note.update',
      details: 'Session note updated: $noteId',
      userId: therapistId,
      resourceId: noteId,
    );

    return true;
  }

  Future<bool> lockSessionNote(String noteId, String therapistId) async {
    final db = await database;
    
    final currentNote = await getSessionNote(noteId);
    if (currentNote == null) return false;

    final lockedNote = currentNote.copyWith(
      status: SessionNoteStatus.locked,
      lockedAt: DateTime.now(),
      lockedBy: therapistId,
      updatedAt: DateTime.now(),
    );

    await db.update(
      'session_notes',
      lockedNote.toJson(),
      where: 'id = ?',
      whereArgs: [noteId],
    );

    await AuditLogService().insertLog(
      action: 'session_note.lock',
      details: 'Session note locked: $noteId',
      userId: therapistId,
      resourceId: noteId,
    );

    return true;
  }

  Future<bool> unlockSessionNote(String noteId, String therapistId) async {
    final db = await database;
    
    final currentNote = await getSessionNote(noteId);
    if (currentNote == null) return false;

    final unlockedNote = currentNote.copyWith(
      status: SessionNoteStatus.draft,
      lockedAt: null,
      lockedBy: null,
      updatedAt: DateTime.now(),
    );

    await db.update(
      'session_notes',
      unlockedNote.toJson(),
      where: 'id = ?',
      whereArgs: [noteId],
    );

    await AuditLogService().insertLog(
      action: 'session_note.unlock',
      details: 'Session note unlocked: $noteId',
      userId: therapistId,
      resourceId: noteId,
    );

    return true;
  }

  Future<SessionNote?> getSessionNote(String noteId) async {
    final db = await database;
    final result = await db.query(
      'session_notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );

    if (result.isEmpty) return null;
    return SessionNote.fromJson(result.first);
  }

  Future<List<SessionNote>> getSessionNotesForClient(String clientId) async {
    final db = await database;
    final result = await db.query(
      'session_notes',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => SessionNote.fromJson(json)).toList();
  }

  Future<List<SessionNote>> getSessionNotesForSession(String sessionId) async {
    final db = await database;
    final result = await db.query(
      'session_notes',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => SessionNote.fromJson(json)).toList();
  }

  Future<List<SessionNoteTemplate>> getTemplates() async {
    final db = await database;
    final result = await db.query(
      'session_note_templates',
      orderBy: 'name ASC',
    );

    return result.map((json) => SessionNoteTemplate.fromJson(json)).toList();
  }

  Future<SessionNoteTemplate?> getTemplate(String templateId) async {
    final db = await database;
    final result = await db.query(
      'session_note_templates',
      where: 'id = ?',
      whereArgs: [templateId],
    );

    if (result.isEmpty) return null;
    return SessionNoteTemplate.fromJson(result.first);
  }

  Future<List<SessionNoteVersion>> getNoteVersions(String noteId) async {
    final db = await database;
    final result = await db.query(
      'session_note_versions',
      where: 'note_id = ?',
      whereArgs: [noteId],
      orderBy: 'version DESC',
    );

    return result.map((json) => SessionNoteVersion.fromJson(json)).toList();
  }

  Future<bool> restoreVersion(String noteId, int version, String therapistId) async {
    final db = await database;
    
    // Get version to restore
    final versionResult = await db.query(
      'session_note_versions',
      where: 'note_id = ? AND version = ?',
      whereArgs: [noteId, version],
    );

    if (versionResult.isEmpty) return false;

    final versionData = SessionNoteVersion.fromJson(versionResult.first);
    
    // Get current note
    final currentNote = await getSessionNote(noteId);
    if (currentNote == null) return false;

    // Create version backup of current state
    await _createVersionBackup(currentNote, therapistId, 'Restored from version $version');

    // Restore content
    final restoredNote = currentNote.copyWith(
      content: versionData.content,
      updatedAt: DateTime.now(),
      version: currentNote.version + 1,
    );

    await db.update(
      'session_notes',
      restoredNote.toJson(),
      where: 'id = ?',
      whereArgs: [noteId],
    );

    await AuditLogService().insertLog(
      action: 'session_note.restore_version',
      details: 'Session note version restored: $noteId to version $version',
      userId: therapistId,
      resourceId: noteId,
    );

    return true;
  }

  Future<void> _createVersionBackup(SessionNote note, String therapistId, String description) async {
    final db = await database;
    
    final version = SessionNoteVersion(
      id: 'version_${note.id}_${note.version}_${DateTime.now().millisecondsSinceEpoch}',
      noteId: note.id,
      version: note.version,
      content: note.content,
      createdAt: DateTime.now(),
      createdBy: therapistId,
      changeDescription: description,
    );

    await db.insert('session_note_versions', version.toJson());
  }

  Future<bool> deleteSessionNote(String noteId, String therapistId) async {
    final db = await database;
    
    final currentNote = await getSessionNote(noteId);
    if (currentNote == null) return false;

    // Check if note is locked
    if (currentNote.status == SessionNoteStatus.locked) {
      return false;
    }

    await db.delete(
      'session_notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );

    await AuditLogService().insertLog(
      action: 'session_note.delete',
      details: 'Session note deleted: $noteId',
      userId: therapistId,
      resourceId: noteId,
    );

    return true;
  }

  Future<List<SessionNote>> searchSessionNotes(String query) async {
    final db = await database;
    final result = await db.query(
      'session_notes',
      where: 'content LIKE ? OR id LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );

    return result.map((json) => SessionNote.fromJson(json)).toList();
  }

  Future<Map<String, int>> getSessionNoteStatistics() async {
    final db = await database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM session_notes');
    final draftResult = await db.rawQuery('SELECT COUNT(*) as count FROM session_notes WHERE status = ?', ['draft']);
    final lockedResult = await db.rawQuery('SELECT COUNT(*) as count FROM session_notes WHERE status = ?', ['locked']);
    
    return {
      'total': totalResult.first['count'] as int,
      'draft': draftResult.first['count'] as int,
      'locked': lockedResult.first['count'] as int,
    };
  }
}