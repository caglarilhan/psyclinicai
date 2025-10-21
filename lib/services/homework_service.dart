import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/homework_assignment.dart';
import '../services/homework_template_service.dart';

class HomeworkService extends ChangeNotifier {
  static final HomeworkService _instance = HomeworkService._internal();
  factory HomeworkService() => _instance;
  HomeworkService._internal();

  final List<HomeworkAssignment> _assignments = [];
  final HomeworkTemplateService _templateService = HomeworkTemplateService();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<HomeworkAssignment> get assignments => List.unmodifiable(_assignments);
  List<HomeworkTemplate> get templates => _templateService.templates;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadAssignments();
    _isInitialized = true;
    notifyListeners();
  }

  // Ödev ekleme
  Future<void> addAssignment(HomeworkAssignment assignment) async {
    _assignments.add(assignment);
    await _saveAssignments();
    notifyListeners();
  }

  // Ödev tamamlama durumu değiştirme
  Future<void> toggleCompleted(String assignmentId) async {
    final index = _assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      final assignment = _assignments[index];
      _assignments[index] = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
        completedDate: !assignment.isCompleted ? DateTime.now() : null,
        status: !assignment.isCompleted ? HomeworkStatus.completed : HomeworkStatus.pending,
      );
      await _saveAssignments();
      notifyListeners();
    }
  }

  // Tüm bekleyen ödevleri tamamla
  Future<void> completeAll() async {
    bool hasChanges = false;
    for (int i = 0; i < _assignments.length; i++) {
      if (_assignments[i].status == HomeworkStatus.pending) {
        _assignments[i] = _assignments[i].copyWith(
          isCompleted: true,
          completedDate: DateTime.now(),
          status: HomeworkStatus.completed,
        );
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      await _saveAssignments();
      notifyListeners();
    }
  }

  // Ödev atama
  Future<void> assign({
    required String clientId,
    required String clinicianId,
    required String templateId,
    String? customInstructions,
    DateTime? dueDate,
  }) async {
    final template = _templateService.templates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => throw Exception('Template bulunamadı'),
    );

    final assignment = HomeworkAssignment(
      clientId: clientId,
      clinicianId: clinicianId,
      title: template.title,
      description: template.description,
      category: template.category,
      difficulty: template.difficulty,
      estimatedDuration: template.estimatedDuration,
      customInstructions: customInstructions ?? template.instructions,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
      assignedDate: DateTime.now(),
    );

    await addAssignment(assignment);
  }

  // Ödev tamamlama
  Future<void> markCompleted(String assignmentId) async {
    final index = _assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      _assignments[index] = _assignments[index].copyWith(
        isCompleted: true,
        completedDate: DateTime.now(),
        status: HomeworkStatus.completed,
      );
      await _saveAssignments();
      notifyListeners();
    }
  }

  // Bekleyen ödevleri getir
  List<HomeworkAssignment> getPendingAssignments() {
    return _assignments.where((a) => a.status == HomeworkStatus.pending).toList();
  }

  // Tamamlanan ödevleri getir
  List<HomeworkAssignment> getCompletedAssignments() {
    return _assignments.where((a) => a.status == HomeworkStatus.completed).toList();
  }

  // Süresi geçmiş ödevleri getir
  List<HomeworkAssignment> getOverdueAssignments() {
    final now = DateTime.now();
    return _assignments.where((a) => 
      a.status == HomeworkStatus.pending && 
      a.dueDate.isBefore(now)
    ).toList();
  }

  // Ödev silme
  Future<void> deleteAssignment(String assignmentId) async {
    _assignments.removeWhere((a) => a.id == assignmentId);
    await _saveAssignments();
    notifyListeners();
  }

  // Verileri SharedPreferences'a kaydet
  Future<void> _saveAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final assignmentsJson = _assignments.map((a) => a.toJson()).toList();
    await prefs.setString('homework_assignments', json.encode(assignmentsJson));
  }

  // Verileri SharedPreferences'tan yükle
  Future<void> _loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final assignmentsJson = prefs.getString('homework_assignments');
    
    if (assignmentsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(assignmentsJson);
        _assignments.clear();
        _assignments.addAll(
          decoded.map((json) => HomeworkAssignment.fromJson(json)).toList()
        );
      } catch (e) {
        print('Homework assignments yükleme hatası: $e');
      }
    }
  }

  // Demo veriler ekle
  Future<void> addDemoAssignments() async {
    if (_assignments.isNotEmpty) return; // Zaten demo veriler var

    final demoAssignments = [
      HomeworkAssignment(
        clientId: 'demo_patient_001',
        clinicianId: 'demo_therapist_001',
        title: 'CBT Düşünce Kaydı',
        description: 'Otomatik olumsuz düşünceleri belirleme ve sorgulama',
        category: 'Depresyon',
        difficulty: 'Orta',
        estimatedDuration: 20,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        assignedDate: DateTime.now().subtract(const Duration(days: 1)),
        status: HomeworkStatus.pending,
      ),
      HomeworkAssignment(
        clientId: 'demo_patient_001',
        clinicianId: 'demo_therapist_001',
        title: 'Minnettarlık Günlüğü',
        description: 'Her gün minnettar olduğunuz 3 şeyi yazın',
        category: 'Genel',
        difficulty: 'Kolay',
        estimatedDuration: 10,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        assignedDate: DateTime.now().subtract(const Duration(days: 2)),
        status: HomeworkStatus.completed,
        isCompleted: true,
        completedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HomeworkAssignment(
        clientId: 'demo_patient_002',
        clinicianId: 'demo_therapist_001',
        title: 'Gevşeme Egzersizi',
        description: 'Derin nefes alma ve kas gevşetme teknikleri',
        category: 'Anksiyete',
        difficulty: 'Kolay',
        estimatedDuration: 15,
        dueDate: DateTime.now().subtract(const Duration(days: 1)), // Süresi geçmiş
        assignedDate: DateTime.now().subtract(const Duration(days: 3)),
        status: HomeworkStatus.overdue,
      ),
    ];

    _assignments.addAll(demoAssignments);
    await _saveAssignments();
    notifyListeners();
  }
}