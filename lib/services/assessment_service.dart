import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/mbc_models.dart';

class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();
  factory AssessmentService() => _instance;
  AssessmentService._internal();

  Database? _db;
  final _initLock = Completer<void>();

  Future<void> _ensureInitialized() async {
    if (_db != null) return;
    if (!_initLock.isCompleted) {
      try {
        final databasesPath = await getDatabasesPath();
        final dbPath = p.join(databasesPath, 'psyclinic_assessments.db');
        _db = await openDatabase(
          dbPath,
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE assessments (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                client_name TEXT NOT NULL,
                created_at TEXT NOT NULL,
                items_json TEXT NOT NULL,
                total_score INTEGER NOT NULL
              );
            ''');
            await db.execute('CREATE INDEX IF NOT EXISTS idx_assessments_client ON assessments(client_name);');
            await db.execute('CREATE INDEX IF NOT EXISTS idx_assessments_type ON assessments(type);');
          },
        );
      } finally {
        if (!_initLock.isCompleted) _initLock.complete();
      }
    }
    return _initLock.future;
  }

  Future<void> saveResult(AssessmentResult result) async {
    await _ensureInitialized();
    final items = result.items
        .map((e) => {'index': e.index, 'question': e.question, 'answer': e.answer})
        .toList();
    await _db!.insert(
      'assessments',
      {
        'id': result.id,
        'type': result.type,
        'client_name': result.clientName,
        'created_at': result.createdAt.toIso8601String(),
        'items_json': jsonEncode(items),
        'total_score': result.totalScore,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AssessmentResult>> listResults({String? clientName, String? type, int limit = 100}) async {
    await _ensureInitialized();
    final where = <String>[];
    final args = <Object?>[];
    if (clientName != null) {
      where.add('client_name = ?');
      args.add(clientName);
    }
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    final rows = await _db!.query(
      'assessments',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map((m) {
      final items = (jsonDecode(m['items_json'] as String) as List)
          .map((e) => AssessmentItem(index: e['index'] as int, question: e['question'] as String, answer: e['answer'] as int))
          .toList();
      return AssessmentResult(
        id: m['id'] as String,
        type: m['type'] as String,
        clientName: m['client_name'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        items: items,
        totalScore: m['total_score'] as int,
      );
    }).toList();
  }
}


