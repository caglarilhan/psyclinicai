import 'package:flutter/foundation.dart';
import '../models/therapy_note_models.dart';

class TherapyNoteService extends ChangeNotifier {
  static final TherapyNoteService _instance = TherapyNoteService._internal();
  factory TherapyNoteService() => _instance;
  TherapyNoteService._internal();

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
    notifyListeners();
    return entry;
  }

  List<TherapyNoteEntry> getEntriesByClient(String clientId) {
    return _entries.where((e) => e.clientId == clientId).toList();
  }
}
