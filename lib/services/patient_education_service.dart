import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_education_models.dart';

class PatientEducationService {
  static final PatientEducationService _instance = PatientEducationService._internal();
  factory PatientEducationService() => _instance;
  PatientEducationService._internal();

  final List<PatientEducationModule> _modules = [];
  final List<PatientEducationProgress> _progressRecords = [];
  final List<EducationQuiz> _quizzes = [];
  final List<EducationRecommendation> _recommendations = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadModules();
    await _loadProgressRecords();
    await _loadQuizzes();
    await _loadRecommendations();
  }

  // Load modules from storage
  Future<void> _loadModules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modulesJson = prefs.getStringList('education_modules') ?? [];
      _modules.clear();
      
      for (final moduleJson in modulesJson) {
        final module = PatientEducationModule.fromJson(jsonDecode(moduleJson));
        _modules.add(module);
      }
    } catch (e) {
      print('Error loading education modules: $e');
      _modules.clear();
    }
  }

  // Save modules to storage
  Future<void> _saveModules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modulesJson = _modules
          .map((module) => jsonEncode(module.toJson()))
          .toList();
      await prefs.setStringList('education_modules', modulesJson);
    } catch (e) {
      print('Error saving education modules: $e');
    }
  }

  // Load progress records from storage
  Future<void> _loadProgressRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getStringList('education_progress') ?? [];
      _progressRecords.clear();
      
      for (final progress in progressJson) {
        final progressRecord = PatientEducationProgress.fromJson(jsonDecode(progress));
        _progressRecords.add(progressRecord);
      }
    } catch (e) {
      print('Error loading education progress: $e');
      _progressRecords.clear();
    }
  }

  // Save progress records to storage
  Future<void> _saveProgressRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = _progressRecords
          .map((progress) => jsonEncode(progress.toJson()))
          .toList();
      await prefs.setStringList('education_progress', progressJson);
    } catch (e) {
      print('Error saving education progress: $e');
    }
  }

  // Load quizzes from storage
  Future<void> _loadQuizzes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quizzesJson = prefs.getStringList('education_quizzes') ?? [];
      _quizzes.clear();
      
      for (final quizJson in quizzesJson) {
        final quiz = EducationQuiz.fromJson(jsonDecode(quizJson));
        _quizzes.add(quiz);
      }
    } catch (e) {
      print('Error loading education quizzes: $e');
      _quizzes.clear();
    }
  }

  // Save quizzes to storage
  Future<void> _saveQuizzes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quizzesJson = _quizzes
          .map((quiz) => jsonEncode(quiz.toJson()))
          .toList();
      await prefs.setStringList('education_quizzes', quizzesJson);
    } catch (e) {
      print('Error saving education quizzes: $e');
    }
  }

  // Load recommendations from storage
  Future<void> _loadRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recommendationsJson = prefs.getStringList('education_recommendations') ?? [];
      _recommendations.clear();
      
      for (final recommendationJson in recommendationsJson) {
        final recommendation = EducationRecommendation.fromJson(jsonDecode(recommendationJson));
        _recommendations.add(recommendation);
      }
    } catch (e) {
      print('Error loading education recommendations: $e');
      _recommendations.clear();
    }
  }

  // Save recommendations to storage
  Future<void> _saveRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recommendationsJson = _recommendations
          .map((recommendation) => jsonEncode(recommendation.toJson()))
          .toList();
      await prefs.setStringList('education_recommendations', recommendationsJson);
    } catch (e) {
      print('Error saving education recommendations: $e');
    }
  }

  // Get all modules
  List<PatientEducationModule> getAllModules() {
    return _modules.where((module) => module.isActive).toList();
  }

  // Get modules by category
  List<PatientEducationModule> getModulesByCategory(String category) {
    return _modules
        .where((module) => module.isActive && module.category == category)
        .toList();
  }

  // Get modules by difficulty
  List<PatientEducationModule> getModulesByDifficulty(String difficulty) {
    return _modules
        .where((module) => module.isActive && module.difficulty == difficulty)
        .toList();
  }

  // Get modules for target audience
  List<PatientEducationModule> getModulesForAudience(String audience) {
    return _modules
        .where((module) => module.isActive && module.targetAudience.contains(audience))
        .toList();
  }

  // Start education module for patient
  Future<PatientEducationProgress> startModule({
    required String patientId,
    required String moduleId,
  }) async {
    // Check if already started
    final existingProgress = _progressRecords
        .where((progress) => 
            progress.patientId == patientId && 
            progress.moduleId == moduleId)
        .firstOrNull;

    if (existingProgress != null) {
      return existingProgress;
    }

    final progress = PatientEducationProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      moduleId: moduleId,
      startedAt: DateTime.now(),
    );

    _progressRecords.add(progress);
    await _saveProgressRecords();

    return progress;
  }

  // Update progress
  Future<bool> updateProgress({
    required String progressId,
    required int percentage,
    List<String>? completedTopics,
    Map<String, dynamic>? quizResults,
    String? notes,
  }) async {
    try {
      final index = _progressRecords.indexWhere((progress) => progress.id == progressId);
      if (index == -1) return false;

      final progress = _progressRecords[index];
      final updatedProgress = progress.copyWith(
        progressPercentage: percentage,
        completedTopics: completedTopics ?? progress.completedTopics,
        quizResults: quizResults ?? progress.quizResults,
        notes: notes ?? progress.notes,
        status: percentage >= 100 ? EducationStatus.completed : EducationStatus.inProgress,
        completedAt: percentage >= 100 ? DateTime.now() : progress.completedAt,
      );

      _progressRecords[index] = updatedProgress;
      await _saveProgressRecords();
      return true;
    } catch (e) {
      print('Error updating progress: $e');
      return false;
    }
  }

  // Get progress for patient
  List<PatientEducationProgress> getProgressForPatient(String patientId) {
    return _progressRecords
        .where((progress) => progress.patientId == patientId)
        .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // Get progress for module
  PatientEducationProgress? getProgressForModule(String patientId, String moduleId) {
    return _progressRecords
        .where((progress) => 
            progress.patientId == patientId && 
            progress.moduleId == moduleId)
        .firstOrNull;
  }

  // Add quiz to module
  Future<EducationQuiz> addQuiz({
    required String moduleId,
    required String question,
    required List<String> options,
    required int correctAnswerIndex,
    required String explanation,
    String? imageUrl,
  }) async {
    final quiz = EducationQuiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moduleId: moduleId,
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: explanation,
      imageUrl: imageUrl,
    );

    _quizzes.add(quiz);
    await _saveQuizzes();

    return quiz;
  }

  // Get quizzes for module
  List<EducationQuiz> getQuizzesForModule(String moduleId) {
    return _quizzes.where((quiz) => quiz.moduleId == moduleId).toList();
  }

  // Recommend module to patient
  Future<EducationRecommendation> recommendModule({
    required String patientId,
    required String moduleId,
    required String reason,
    required String recommendedBy,
  }) async {
    final recommendation = EducationRecommendation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      moduleId: moduleId,
      reason: reason,
      recommendedAt: DateTime.now(),
      recommendedBy: recommendedBy,
    );

    _recommendations.add(recommendation);
    await _saveRecommendations();

    return recommendation;
  }

  // Get recommendations for patient
  List<EducationRecommendation> getRecommendationsForPatient(String patientId) {
    return _recommendations
        .where((recommendation) => recommendation.patientId == patientId)
        .toList()
        ..sort((a, b) => b.recommendedAt.compareTo(a.recommendedAt));
  }

  // Mark recommendation as viewed
  Future<bool> markRecommendationAsViewed(String recommendationId) async {
    try {
      final index = _recommendations.indexWhere((rec) => rec.id == recommendationId);
      if (index == -1) return false;

      final recommendation = _recommendations[index];
      final updatedRecommendation = EducationRecommendation(
        id: recommendation.id,
        patientId: recommendation.patientId,
        moduleId: recommendation.moduleId,
        reason: recommendation.reason,
        recommendedAt: recommendation.recommendedAt,
        recommendedBy: recommendation.recommendedBy,
        isViewed: true,
        viewedAt: DateTime.now(),
      );

      _recommendations[index] = updatedRecommendation;
      await _saveRecommendations();
      return true;
    } catch (e) {
      print('Error marking recommendation as viewed: $e');
      return false;
    }
  }

  // Get education statistics for patient
  Map<String, dynamic> getEducationStatistics(String patientId) {
    final progressRecords = getProgressForPatient(patientId);
    
    if (progressRecords.isEmpty) {
      return {
        'totalModules': 0,
        'completedModules': 0,
        'inProgressModules': 0,
        'averageProgress': 0.0,
        'totalStudyTime': 0,
      };
    }

    final completedModules = progressRecords
        .where((progress) => progress.status == EducationStatus.completed)
        .length;
    
    final inProgressModules = progressRecords
        .where((progress) => progress.status == EducationStatus.inProgress)
        .length;

    final totalProgress = progressRecords
        .map((progress) => progress.progressPercentage)
        .reduce((a, b) => a + b);

    final averageProgress = totalProgress / progressRecords.length;

    // Calculate total study time (estimated)
    final totalStudyTime = progressRecords
        .map((progress) {
          final module = _modules.firstWhere((m) => m.id == progress.moduleId);
          return (module.estimatedDuration * progress.progressPercentage / 100).round();
        })
        .reduce((a, b) => a + b);

    return {
      'totalModules': progressRecords.length,
      'completedModules': completedModules,
      'inProgressModules': inProgressModules,
      'averageProgress': averageProgress,
      'totalStudyTime': totalStudyTime,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_modules.isNotEmpty) return;

    final demoModules = [
      PatientEducationModule(
        id: 'edu_001',
        title: 'Diyabet Yönetimi',
        description: 'Tip 2 diyabet hastaları için kapsamlı eğitim modülü',
        category: 'diabetes',
        difficulty: 'Orta',
        estimatedDuration: 45,
        content: '''
        <h2>Diyabet Nedir?</h2>
        <p>Diyabet, kan şekeri seviyelerinin yüksek olması durumudur...</p>
        
        <h2>Beslenme Önerileri</h2>
        <ul>
          <li>Düzenli öğünler yiyin</li>
          <li>Karbonhidrat alımını kontrol edin</li>
          <li>Bol su için</li>
        </ul>
        
        <h2>Egzersiz</h2>
        <p>Düzenli egzersiz kan şekeri kontrolüne yardımcı olur...</p>
        ''',
        topics: ['Beslenme', 'Egzersiz', 'İlaç Kullanımı', 'Kan Şekeri Takibi'],
        targetAudience: ['Hasta', 'Aile'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      PatientEducationModule(
        id: 'edu_002',
        title: 'Hipertansiyon Kontrolü',
        description: 'Yüksek tansiyon hastaları için eğitim modülü',
        category: 'hypertension',
        difficulty: 'Kolay',
        estimatedDuration: 30,
        content: '''
        <h2>Hipertansiyon Nedir?</h2>
        <p>Hipertansiyon, kan basıncının sürekli yüksek olması durumudur...</p>
        
        <h2>Tuz Kısıtlaması</h2>
        <p>Günlük tuz alımınızı 5 gram ile sınırlayın...</p>
        
        <h2>Stres Yönetimi</h2>
        <p>Stres kan basıncını yükseltebilir...</p>
        ''',
        topics: ['Beslenme', 'Stres Yönetimi', 'İlaç Kullanımı', 'Tansiyon Takibi'],
        targetAudience: ['Hasta'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      PatientEducationModule(
        id: 'edu_003',
        title: 'Depresyon ile Başa Çıkma',
        description: 'Depresyon hastaları için psikoeğitim modülü',
        category: 'mentalHealth',
        difficulty: 'Zor',
        estimatedDuration: 60,
        content: '''
        <h2>Depresyon Belirtileri</h2>
        <p>Depresyonun yaygın belirtileri şunlardır...</p>
        
        <h2>CBT Teknikleri</h2>
        <p>Bilişsel davranışçı terapi teknikleri...</p>
        
        <h2>Destek Sistemleri</h2>
        <p>Aile ve arkadaş desteği önemlidir...</p>
        ''',
        topics: ['Belirtiler', 'CBT Teknikleri', 'Destek Sistemleri', 'İlaç Tedavisi'],
        targetAudience: ['Hasta', 'Aile'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    for (final module in demoModules) {
      _modules.add(module);
    }

    await _saveModules();

    // Add demo quizzes
    final demoQuizzes = [
      EducationQuiz(
        id: 'quiz_001',
        moduleId: 'edu_001',
        question: 'Diyabet hastaları günde kaç öğün yemelidir?',
        options: ['2 öğün', '3 öğün', '4-6 öğün', 'İstediği kadar'],
        correctAnswerIndex: 2,
        explanation: 'Diyabet hastaları kan şekeri kontrolü için 4-6 küçük öğün yemelidir.',
      ),
      EducationQuiz(
        id: 'quiz_002',
        moduleId: 'edu_002',
        question: 'Günlük tuz alımı ne kadar olmalıdır?',
        options: ['10 gram', '5 gram', '15 gram', '20 gram'],
        correctAnswerIndex: 1,
        explanation: 'Hipertansiyon hastaları günlük tuz alımını 5 gram ile sınırlamalıdır.',
      ),
    ];

    for (final quiz in demoQuizzes) {
      _quizzes.add(quiz);
    }

    await _saveQuizzes();

    print('✅ Demo education modules created: ${demoModules.length}');
    print('✅ Demo quizzes created: ${demoQuizzes.length}');
  }
}
