import 'package:flutter/foundation.dart';
import '../models/homework_models.dart';

class HomeworkService extends ChangeNotifier {
  static final HomeworkService _instance = HomeworkService._internal();
  factory HomeworkService() => _instance;
  HomeworkService._internal();

  final List<HomeworkTemplate> _templates = const [
    HomeworkTemplate(id: 'cbt_thought_record', title: 'CBT Düşünce Kaydı', description: 'Durum-düşünce-duygu-davranış-zorlama'),
    HomeworkTemplate(id: 'behavioral_activation', title: 'Davranışsal Aktivasyon', description: 'Planlı keyifli/başarı etkinlikleri'),
  ];

  final List<HomeworkAssignment> _assignments = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<HomeworkTemplate> get templates => List.unmodifiable(_templates);
  List<HomeworkAssignment> get assignments => List.unmodifiable(_assignments);

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    notifyListeners();
  }

  Future<HomeworkAssignment> assign({
    required String clientId,
    required String clinicianId,
    required String templateId,
    String customInstructions = '',
    DateTime? dueDate,
  }) async {
    final hw = HomeworkAssignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      clinicianId: clinicianId,
      templateId: templateId,
      customInstructions: customInstructions,
      assignedAt: DateTime.now(),
      dueDate: dueDate,
    );
    _assignments.add(hw);
    notifyListeners();
    return hw;
  }

  void markCompleted(String assignmentId) {
    final idx = _assignments.indexWhere((a) => a.id == assignmentId);
    if (idx >= 0) {
      final a = _assignments[idx];
      _assignments[idx] = HomeworkAssignment(
        id: a.id,
        clientId: a.clientId,
        clinicianId: a.clinicianId,
        templateId: a.templateId,
        customInstructions: a.customInstructions,
        assignedAt: a.assignedAt,
        dueDate: a.dueDate,
        completed: true,
      );
      notifyListeners();
    }
  }
}
