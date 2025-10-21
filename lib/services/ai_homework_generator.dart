import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/homework_assignment.dart';
import 'homework_template_service.dart';
import 'homework_service.dart';

class AIHomeworkGenerator extends ChangeNotifier {
  static final AIHomeworkGenerator _instance = AIHomeworkGenerator._internal();
  factory AIHomeworkGenerator() => _instance;
  AIHomeworkGenerator._internal();

  Future<void> initialize() async {
    // AI Homework Generator başlatma
    print('AIHomeworkGenerator initialized');
  }

  final HomeworkTemplateService _templateService = HomeworkTemplateService();

  // AI destekli ödev önerisi
  Future<List<HomeworkAssignment>> generateSmartAssignments({
    required String patientId,
    required String primaryDiagnosis,
    List<String> symptoms = const [],
    List<String> completedAssignments = const [],
    String difficulty = 'Orta',
    int maxDuration = 30,
    int count = 3,
  }) async {
    
    // Tamamlanan ödevleri analiz et
    final completedCategories = _analyzeCompletedAssignments(completedAssignments);
    
    // Semptomlara göre öncelikli kategorileri belirle
    final priorityCategories = _determinePriorityCategories(symptoms, primaryDiagnosis);
    
    // AI önerileri oluştur
    final suggestions = <HomeworkAssignment>[];
    
    // 1. Temel ödevler (her hasta için)
    suggestions.addAll(_generateBasicAssignments(patientId, primaryDiagnosis, difficulty));
    
    // 2. Semptom odaklı ödevler
    suggestions.addAll(_generateSymptomFocusedAssignments(
      patientId, symptoms, primaryDiagnosis, difficulty, maxDuration));
    
    // 3. Tamamlanan ödevlere göre ilerleme ödevleri
    suggestions.addAll(_generateProgressionAssignments(
      patientId, completedCategories, primaryDiagnosis, difficulty));
    
    // 4. Kişiselleştirilmiş ödevler
    suggestions.addAll(_generatePersonalizedAssignments(
      patientId, primaryDiagnosis, symptoms, difficulty, maxDuration));
    
    // Ödevleri filtrele ve sırala
    final filteredSuggestions = _filterAndRankAssignments(
      suggestions, completedAssignments, count);
    
    return filteredSuggestions;
  }

  List<String> _analyzeCompletedAssignments(List<String> completedAssignments) {
    // Tamamlanan ödevlerin kategorilerini analiz et
    final categories = <String>[];
    for (var assignmentId in completedAssignments) {
      // Burada gerçek ödev verilerini alabilirsiniz
      // Şimdilik demo kategoriler
      if (assignmentId.contains('dep_')) categories.add('Depresyon');
      if (assignmentId.contains('anx_')) categories.add('Anksiyete');
      if (assignmentId.contains('trauma_')) categories.add('Travma');
    }
    return categories;
  }

  List<String> _determinePriorityCategories(List<String> symptoms, String diagnosis) {
    final priorities = <String>[];
    
    // Tanıya göre öncelik
    priorities.add(diagnosis);
    
    // Semptomlara göre ek kategoriler
    for (var symptom in symptoms) {
      if (symptom.toLowerCase().contains('endişe') || 
          symptom.toLowerCase().contains('kaygı')) {
        priorities.add('Anksiyete');
      }
      if (symptom.toLowerCase().contains('üzüntü') || 
          symptom.toLowerCase().contains('motivasyon')) {
        priorities.add('Depresyon');
      }
      if (symptom.toLowerCase().contains('travma') || 
          symptom.toLowerCase().contains('anı')) {
        priorities.add('Travma');
      }
    }
    
    return priorities.toSet().toList();
  }

  List<HomeworkAssignment> _generateBasicAssignments(
    String patientId, String diagnosis, String difficulty) {
    
    final basicTemplates = _templateService.getTemplatesByCategory('Genel');
    final assignments = <HomeworkAssignment>[];
    
    // Her hasta için temel ödevler
    for (var template in basicTemplates.take(2)) {
      if (template.difficulty == difficulty || difficulty == 'Zor') {
        assignments.add(_templateService.createAssignmentFromTemplate(
          template: template,
          patientId: patientId,
          clinicianId: 'default_clinician',
          dueDate: DateTime.now().add(Duration(days: 3)),
        ));
      }
    }
    
    return assignments;
  }

  List<HomeworkAssignment> _generateSymptomFocusedAssignments(
    String patientId, List<String> symptoms, String diagnosis, 
    String difficulty, int maxDuration) {
    
    final assignments = <HomeworkAssignment>[];
    final suggestions = _templateService.getSuggestedTemplates(
      primaryDiagnosis: diagnosis,
      symptoms: symptoms,
      difficulty: difficulty,
      maxDuration: maxDuration,
    );
    
    for (var template in suggestions.take(2)) {
      assignments.add(_templateService.createAssignmentFromTemplate(
        template: template,
        patientId: patientId,
        clinicianId: 'default_clinician',
        dueDate: DateTime.now().add(Duration(days: 5)),
      ));
    }
    
    return assignments;
  }

  List<HomeworkAssignment> _generateProgressionAssignments(
    String patientId, List<String> completedCategories, 
    String diagnosis, String difficulty) {
    
    final assignments = <HomeworkAssignment>[];
    
    // Tamamlanan kategorilere göre ilerleme ödevleri
    for (var category in completedCategories) {
      final templates = _templateService.getTemplatesByCategory(category);
      
      // Daha zor seviyeye geç
      String nextDifficulty = difficulty;
      if (difficulty == 'Kolay') nextDifficulty = 'Orta';
      else if (difficulty == 'Orta') nextDifficulty = 'Zor';
      
      final advancedTemplates = templates.where((t) => 
        t.difficulty == nextDifficulty).take(1);
      
      for (var template in advancedTemplates) {
        assignments.add(_templateService.createAssignmentFromTemplate(
          template: template,
          patientId: patientId,
          clinicianId: 'default_clinician',
          dueDate: DateTime.now().add(Duration(days: 7)),
        ));
      }
    }
    
    return assignments;
  }

  List<HomeworkAssignment> _generatePersonalizedAssignments(
    String patientId, String diagnosis, List<String> symptoms, 
    String difficulty, int maxDuration) {
    
    final assignments = <HomeworkAssignment>[];
    
    // Kişiselleştirilmiş ödevler oluştur
    if (symptoms.contains('uykusuzluk')) {
      assignments.add(_createCustomAssignment(
        patientId: patientId,
        clinicianId: 'default_clinician',
        title: 'Uyku Rutini Oluşturma',
        description: 'Her gün aynı saatte yatıp kalkarak uyku rutini oluşturun. Yatmadan 1 saat önce ekranları kapatın.',
        category: 'Uyku',
        difficulty: 'Kolay',
        estimatedDuration: 0,
        dueDate: DateTime.now().add(Duration(days: 3)),
      ));
    }
    
    if (symptoms.contains('sosyal izolasyon')) {
      assignments.add(_createCustomAssignment(
        patientId: patientId,
        clinicianId: 'default_clinician',
        title: 'Sosyal Bağlantı Kurma',
        description: 'Bu hafta en az 2 kişiyle konuşun. Telefon, mesaj veya yüz yüze görüşme olabilir.',
        category: 'Sosyal',
        difficulty: 'Orta',
        estimatedDuration: 30,
        dueDate: DateTime.now().add(Duration(days: 7)),
      ));
    }
    
    if (symptoms.contains('stres')) {
      assignments.add(_createCustomAssignment(
        patientId: patientId,
        clinicianId: 'default_clinician',
        title: 'Stres Yönetimi Teknikleri',
        description: 'Günde 2 kez 5 dakika nefes egzersizi yapın. Stresli anlarda bu tekniği kullanın.',
        category: 'Stres Yönetimi',
        difficulty: 'Kolay',
        estimatedDuration: 10,
        dueDate: DateTime.now().add(Duration(days: 2)),
      ));
    }
    
    return assignments;
  }

  HomeworkAssignment _createCustomAssignment({
    required String patientId,
    required String clinicianId,
    required String title,
    required String description,
    required String category,
    required String difficulty,
    required int estimatedDuration,
    required DateTime dueDate,
    String? customInstructions,
  }) {
    return HomeworkAssignment(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      clientId: patientId,
      clinicianId: clinicianId,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      estimatedDuration: estimatedDuration,
      customInstructions: customInstructions,
      dueDate: dueDate,
      assignedDate: DateTime.now(),
    );
  }

  List<HomeworkAssignment> _filterAndRankAssignments(
    List<HomeworkAssignment> suggestions, 
    List<String> completedAssignments, 
    int count) {
    
    // Tamamlanan ödevleri filtrele
    final filtered = suggestions.where((assignment) => 
      !completedAssignments.contains(assignment.id)).toList();
    
    // Ödevleri önem sırasına göre sırala
    filtered.sort((a, b) {
      // Temel ödevler önce
      if (a.category == 'Genel' && b.category != 'Genel') return -1;
      if (b.category == 'Genel' && a.category != 'Genel') return 1;
      
      // Zorluk seviyesine göre
      final difficultyOrder = {'Kolay': 1, 'Orta': 2, 'Zor': 3};
      final aDiff = difficultyOrder[a.difficulty] ?? 2;
      final bDiff = difficultyOrder[b.difficulty] ?? 2;
      
      return aDiff.compareTo(bDiff);
    });
    
    return filtered.take(count).toList();
  }

  // Ödev tamamlama analizi
  Map<String, dynamic> analyzeCompletionPattern({
    required String patientId,
    required List<HomeworkAssignment> assignments,
  }) {
    final completed = assignments.where((a) => a.status == HomeworkStatus.completed).toList();
    final pending = assignments.where((a) => a.status == HomeworkStatus.pending).toList();
    
    final analysis = {
      'totalAssignments': assignments.length,
      'completedCount': completed.length,
      'pendingCount': pending.length,
      'completionRate': assignments.isEmpty ? 0.0 : completed.length / assignments.length,
      'averageCompletionTime': _calculateAverageCompletionTime(completed),
      'preferredCategories': _getPreferredCategories(completed),
      'difficultyPreference': _getDifficultyPreference(completed),
      'recommendations': _generateRecommendations(completed, pending),
    };
    
    return analysis;
  }

  double _calculateAverageCompletionTime(List<HomeworkAssignment> completed) {
    if (completed.isEmpty) return 0.0;
    
    double totalDays = 0;
    for (var assignment in completed) {
      if (assignment.completedDate != null) {
        final days = assignment.completedDate!.difference(assignment.assignedDate).inDays;
        totalDays += days;
      }
    }
    
    return totalDays / completed.length;
  }

  List<String> _getPreferredCategories(List<HomeworkAssignment> completed) {
    final categoryCount = <String, int>{};
    for (var assignment in completed) {
      categoryCount[assignment.category] = (categoryCount[assignment.category] ?? 0) + 1;
    }
    
    final sorted = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.map((e) => e.key).toList();
  }

  String _getDifficultyPreference(List<HomeworkAssignment> completed) {
    if (completed.isEmpty) return 'Orta';
    
    final difficultyCount = <String, int>{};
    for (var assignment in completed) {
      difficultyCount[assignment.difficulty] = (difficultyCount[assignment.difficulty] ?? 0) + 1;
    }
    
    final sorted = difficultyCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  List<String> _generateRecommendations(List<HomeworkAssignment> completed, List<HomeworkAssignment> pending) {
    final recommendations = <String>[];
    
    if (completed.isEmpty) {
      recommendations.add('İlk ödevleri kolay seviyeden başlayın');
      recommendations.add('Günlük rutin oluşturmaya odaklanın');
    } else if (completed.length < 3) {
      recommendations.add('Daha fazla temel ödev tamamlayın');
      recommendations.add('Sosyal bağlantı ödevlerini deneyin');
    } else {
      recommendations.add('Daha zor seviyeye geçebilirsiniz');
      recommendations.add('Yeni kategorileri keşfedin');
    }
    
    if (pending.length > 5) {
      recommendations.add('Çok fazla bekleyen ödev var, öncelik sırası yapın');
    }
    
    return recommendations;
  }
}
