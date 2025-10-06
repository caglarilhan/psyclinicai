import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AuditLogEntry {
  final int? id;
  final String action; // e.g. pdf.generate, pdf.open, pdf.share
  final String actor; // e.g. therapist email/id or 'unknown'
  final String target; // e.g. clientName/sessionId
  final String metadataJson; // arbitrary details as JSON string
  final DateTime createdAt;

  AuditLogEntry({
    this.id,
    required this.action,
    required this.actor,
    required this.target,
    required this.metadataJson,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'action': action,
        'actor': actor,
        'target': target,
        'metadata_json': metadataJson,
        'created_at': createdAt.toIso8601String(),
      };

  static AuditLogEntry fromMap(Map<String, Object?> m) => AuditLogEntry(
        id: m['id'] as int?,
        action: m['action'] as String,
        actor: m['actor'] as String,
        target: m['target'] as String,
        metadataJson: m['metadata_json'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

class AuditLogService {
  static final AuditLogService _instance = AuditLogService._internal();
  factory AuditLogService() => _instance;
  AuditLogService._internal();

  Database? _db;
  final _initLock = Completer<void>();

  Future<void> _ensureInitialized() async {
    if (_db != null) return;
    if (!_initLock.isCompleted) {
      try {
        final databasesPath = await getDatabasesPath();
        final dbPath = p.join(databasesPath, 'psyclinic_audit_logs.db');
        _db = await openDatabase(
          dbPath,
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE audit_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                action TEXT NOT NULL,
                actor TEXT NOT NULL,
                target TEXT NOT NULL,
                metadata_json TEXT NOT NULL,
                created_at TEXT NOT NULL
              );
            ''');
            await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_logs(action);');
            await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs(created_at);');
          },
        );
      } finally {
        if (!_initLock.isCompleted) _initLock.complete();
      }
    }
    return _initLock.future;
  }

  Future<int> insertLog({
    required String action,
    required String actor,
    required String target,
    required String metadataJson,
    DateTime? createdAt,
  }) async {
    await _ensureInitialized();
    final entry = AuditLogEntry(
      action: action,
      actor: actor,
      target: target,
      metadataJson: metadataJson,
      createdAt: createdAt ?? DateTime.now(),
    );
    return await _db!.insert('audit_logs', entry.toMap());
  }

  Future<List<AuditLogEntry>> listLogs({int limit = 200, int offset = 0}) async {
    await _ensureInitialized();
    final rows = await _db!.query(
      'audit_logs',
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(AuditLogEntry.fromMap).toList();
  }

  Future<String> exportAsCsv({int limit = 1000}) async {
    final logs = await listLogs(limit: limit);
    final buffer = StringBuffer();
    buffer.writeln('id,created_at,action,actor,target,metadata_json');
    for (final e in logs) {
      final idStr = (e.id ?? '').toString();
      final created = e.createdAt.toIso8601String();
      final safe = (String s) => '"' + s.replaceAll('"', '""') + '"';
      buffer.writeln([
        idStr,
        created,
        safe(e.action),
        safe(e.actor),
        safe(e.target),
        safe(e.metadataJson),
      ].join(','));
    }
    return buffer.toString();
  }
}


