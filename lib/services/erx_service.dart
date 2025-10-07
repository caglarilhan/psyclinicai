import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/erx_models.dart';
import 'audit_log_service.dart';

class ERxService {
  static final ERxService _instance = ERxService._internal();
  factory ERxService() => _instance;
  ERxService._internal();

  Database? _db;
  final _init = Completer<void>();

  Future<void> _ensureInit() async {
    if (_db != null) return;
    if (!_init.isCompleted) {
      try {
        final dir = await getDatabasesPath();
        final path = p.join(dir, 'psyclinic_erx.db');
        _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE drugs (
              code TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              strength TEXT NOT NULL,
              form TEXT NOT NULL
            );
          ''');
          await db.execute('''
            CREATE TABLE interactions (
              a_code TEXT NOT NULL,
              b_code TEXT NOT NULL,
              severity TEXT NOT NULL,
              note TEXT NOT NULL,
              PRIMARY KEY (a_code, b_code)
            );
          ''');
          await db.execute('''
            CREATE TABLE prescriptions (
              id TEXT PRIMARY KEY,
              client_name TEXT NOT NULL,
              therapist_name TEXT NOT NULL,
              created_at TEXT NOT NULL,
              items_json TEXT NOT NULL,
              notes TEXT NOT NULL
            );
          ''');
        });
      } finally {
        if (!_init.isCompleted) _init.complete();
      }
    }
    return _init.future;
  }

  Future<void> upsertDrug(Drug d) async {
    await _ensureInit();
    await _db!.insert('drugs', {'code': d.code, 'name': d.name, 'strength': d.strength, 'form': d.form}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Drug>> searchDrugsByName(String query, {int limit = 20}) async {
    await _ensureInit();
    final rows = await _db!.query(
      'drugs',
      where: 'name LIKE ? OR code LIKE ?',
      whereArgs: ['%'+query+'%','%'+query+'%'],
      limit: limit,
    );
    return rows.map((m) => Drug(
      code: m['code'] as String,
      name: m['name'] as String,
      strength: m['strength'] as String,
      form: m['form'] as String,
    )).toList();
  }

  Future<void> upsertInteraction(DrugInteraction i) async {
    await _ensureInit();
    await _db!.insert('interactions', {'a_code': i.aCode, 'b_code': i.bCode, 'severity': i.severity, 'note': i.note}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DrugInteraction>> checkInteractions(List<PrescriptionItem> items) async {
    await _ensureInit();
    final codes = items.map((e) => e.drug.code).toList();
    final results = <DrugInteraction>[];
    for (int i = 0; i < codes.length; i++) {
      for (int j = i + 1; j < codes.length; j++) {
        final a = codes[i];
        final b = codes[j];
        final rows = await _db!.query('interactions',
            where: '(a_code = ? AND b_code = ?) OR (a_code = ? AND b_code = ?)', whereArgs: [a, b, b, a]);
        for (final m in rows) {
          results.add(DrugInteraction(
            aCode: m['a_code'] as String,
            bCode: m['b_code'] as String,
            severity: m['severity'] as String,
            note: m['note'] as String,
          ));
        }
      }
    }
    return results;
  }

  Future<void> savePrescription(Prescription p) async {
    await _ensureInit();
    final items = p.items
        .map((e) => {
              'drug': {'code': e.drug.code, 'name': e.drug.name, 'strength': e.drug.strength, 'form': e.drug.form},
              'dosage': e.dosage,
              'route': e.route,
              'frequency': e.frequency,
              'durationDays': e.durationDays,
            })
        .toList();
    await _db!.insert(
      'prescriptions',
      {
        'id': p.id,
        'client_name': p.clientName,
        'therapist_name': p.therapistName,
        'created_at': p.createdAt.toIso8601String(),
        'items_json': jsonEncode(items),
        'notes': p.notes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await AuditLogService().insertLog(
      action: 'erx.create',
      actor: p.therapistName,
      target: p.clientName + '|' + p.id,
      metadataJson: jsonEncode({'items': p.items.length}),
    );
  }
}


