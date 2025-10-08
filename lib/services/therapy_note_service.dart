import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/therapy_note_models.dart';

class TherapyNoteService extends ChangeNotifier {
  static final TherapyNoteService _instance = TherapyNoteService._internal();
  factory TherapyNoteService() => _instance;
  TherapyNoteService._internal();

  static const String _storageKey = 'therapy_note_entries';
  SharedPreferences? _prefs;

  final List<TherapyNoteTemplate> _templates = [
    TherapyNoteTemplate(
      id: 'dap',
      name: 'DAP Notu',
      description: 'Data-Assessment-Plan formatı',
      fields: [
        TherapyNoteField(key: 'data', label: 'Veri (Gözlemler)', type: NoteFieldType.longText),
        TherapyNoteField(key: 'assessment', label: 'Değerlendirme', type: NoteFieldType.longText),
        TherapyNoteField(key: 'plan', label: 'Plan', type: NoteFieldType.longText),
      ],
    ),
    TherapyNoteTemplate(
      id: 'soap',
      name: 'SOAP Notu',
      description: 'Subjective-Objective-Assessment-Plan',
      fields: [
        TherapyNoteField(key: 'subjective', label: 'Subjective', type: NoteFieldType.longText),
        TherapyNoteField(key: 'objective', label: 'Objective', type: NoteFieldType.longText),
        TherapyNoteField(key: 'assessment', label: 'Assessment', type: NoteFieldType.longText),
        TherapyNoteField(key: 'plan', label: 'Plan', type: NoteFieldType.longText),
      ],
    ),
  ];

  final List<TherapyNoteEntry> _entries = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<TherapyNoteTemplate> get templates => List.unmodifiable(_templates);
  List<TherapyNoteEntry> get entries => List.unmodifiable(_entries);

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs ??= await SharedPreferences.getInstance();
    await _loadEntries();

    _isInitialized = true;
    notifyListeners();
  }

  Future<TherapyNoteEntry> createEntry({
    required String sessionId,
    required String clinicianId,
    required String clientId,
    required String templateId,
    required Map<String, dynamic> values,
  }) async {
    final entry = TherapyNoteEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      clinicianId: clinicianId,
      clientId: clientId,
      templateId: templateId,
      values: values,
      createdAt: DateTime.now(),
    );
    _entries.add(entry);
    await _persistEntries();
    notifyListeners();
    return entry;
  }

  List<TherapyNoteEntry> getEntriesByClient(String clientId) {
    return _entries.where((e) => e.clientId == clientId).toList();
  }

  Future<void> _loadEntries() async {
    try {
      final raw = _prefs?.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      _entries
        ..clear()
        ..addAll(
          decoded
              .map((item) => TherapyNoteEntry.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList(),
        );
    } catch (e) {
      // Persisted veriler bozuksa sessizce sıfırla
      _entries.clear();
      debugPrint('TherapyNoteService load error: $e');
    }
  }

  Future<void> _persistEntries() async {
    if (_prefs == null) return;
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await _prefs!.setString(_storageKey, encoded);
  }
}
