import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/homework_assignment.dart';
import 'homework_service.dart';

class HomeworkTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final String difficulty; // Kolay, Orta, Zor
  final int estimatedDuration; // dakika
  final String instructions;
  final List<String> materials;
  final String therapeuticGoal;
  final Map<String, dynamic> metadata;

  HomeworkTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.difficulty,
    required this.estimatedDuration,
    required this.instructions,
    required this.materials,
    required this.therapeuticGoal,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'tags': tags,
    'difficulty': difficulty,
    'estimatedDuration': estimatedDuration,
    'instructions': instructions,
    'materials': materials,
    'therapeuticGoal': therapeuticGoal,
    'metadata': metadata,
  };

  factory HomeworkTemplate.fromJson(Map<String, dynamic> json) => HomeworkTemplate(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    tags: List<String>.from(json['tags']),
    difficulty: json['difficulty'],
    estimatedDuration: json['estimatedDuration'],
    instructions: json['instructions'],
    materials: List<String>.from(json['materials']),
    therapeuticGoal: json['therapeuticGoal'],
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );
}

class HomeworkTemplateService extends ChangeNotifier {
  static final HomeworkTemplateService _instance = HomeworkTemplateService._internal();
  factory HomeworkTemplateService() => _instance;
  HomeworkTemplateService._internal();

  final List<HomeworkTemplate> _templates = [];
  final Map<String, List<String>> _categoryKeywords = {};

  List<HomeworkTemplate> get templates => List.unmodifiable(_templates);
  
  List<String> get categories => _templates.map((t) => t.category).toSet().toList();

  void initialize() {
    _loadDefaultTemplates();
    _buildCategoryKeywords();
  }

  void _loadDefaultTemplates() {
    _templates.addAll([
      // Depresyon için ödevler
      HomeworkTemplate(
        id: 'dep_activity_schedule',
        title: 'Günlük Aktivite Planı',
        description: 'Hasta günlük aktivitelerini planlar ve takip eder',
        category: 'Depresyon',
        tags: ['aktivite', 'planlama', 'rutin'],
        difficulty: 'Kolay',
        estimatedDuration: 15,
        instructions: 'Her gün için 3-5 aktivite planlayın. Hem zevk alacağınız hem de başarabileceğiniz aktiviteler seçin.',
        materials: ['Kalem', 'Kağıt', 'Takvim'],
        therapeuticGoal: 'Motivasyon artırma ve rutin oluşturma',
        metadata: {'targetDisorders': ['depresyon', 'anksiyete']},
      ),
      
      HomeworkTemplate(
        id: 'dep_thought_record',
        title: 'Düşünce Kayıt Formu',
        description: 'Olumsuz düşünceleri kaydetme ve analiz etme',
        category: 'Depresyon',
        tags: ['düşünce', 'kayıt', 'analiz'],
        difficulty: 'Orta',
        estimatedDuration: 20,
        instructions: 'Gün içinde olumsuz hissettiğinizde durumu, düşüncelerinizi ve duygularınızı kaydedin.',
        materials: ['Düşünce kayıt formu', 'Kalem'],
        therapeuticGoal: 'Bilişsel farkındalık ve yeniden yapılandırma',
        metadata: {'targetDisorders': ['depresyon', 'anksiyete']},
      ),

      HomeworkTemplate(
        id: 'dep_gratitude_journal',
        title: 'Şükran Günlüğü',
        description: 'Günlük şükran duyulan şeyleri kaydetme',
        category: 'Depresyon',
        tags: ['şükran', 'pozitif', 'günlük'],
        difficulty: 'Kolay',
        estimatedDuration: 10,
        instructions: 'Her gün 3 şey için şükran duyduğunuzu yazın. Küçük şeyler de olabilir.',
        materials: ['Günlük', 'Kalem'],
        therapeuticGoal: 'Pozitif duyguları güçlendirme',
        metadata: {'targetDisorders': ['depresyon']},
      ),

      // Anksiyete için ödevler
      HomeworkTemplate(
        id: 'anx_breathing_exercise',
        title: 'Nefes Egzersizi',
        description: 'Günlük nefes egzersizi uygulaması',
        category: 'Anksiyete',
        tags: ['nefes', 'rahatlama', 'egzersiz'],
        difficulty: 'Kolay',
        estimatedDuration: 10,
        instructions: 'Günde 2 kez 5 dakika nefes egzersizi yapın. 4 saniye nefes alın, 4 saniye tutun, 4 saniye verin.',
        materials: ['Telefon uygulaması', 'Timer'],
        therapeuticGoal: 'Fizyolojik rahatlama ve stres azaltma',
        metadata: {'targetDisorders': ['anksiyete', 'panik']},
      ),

      HomeworkTemplate(
        id: 'anx_worry_time',
        title: 'Endişe Zamanı',
        description: 'Endişeleri belirli bir zamanda ele alma',
        category: 'Anksiyete',
        tags: ['endişe', 'zaman', 'kontrol'],
        difficulty: 'Orta',
        estimatedDuration: 15,
        instructions: 'Günlük 15 dakika "endişe zamanı" ayırın. Bu süre dışında endişelerinizi erteleyin.',
        materials: ['Timer', 'Kağıt', 'Kalem'],
        therapeuticGoal: 'Endişe kontrolü ve zaman yönetimi',
        metadata: {'targetDisorders': ['anksiyete', 'GAD']},
      ),

      HomeworkTemplate(
        id: 'anx_exposure_hierarchy',
        title: 'Maruz Kalma Hiyerarşisi',
        description: 'Korkulan durumlara kademeli maruz kalma',
        category: 'Anksiyete',
        tags: ['maruz kalma', 'korku', 'aşamalı'],
        difficulty: 'Zor',
        estimatedDuration: 30,
        instructions: 'Korktuğunuz durumları zorluk seviyesine göre sıralayın ve en kolayından başlayarak uygulayın.',
        materials: ['Maruz kalma formu', 'Kalem'],
        therapeuticGoal: 'Korku azaltma ve güven artırma',
        metadata: {'targetDisorders': ['fobi', 'panik', 'SAD']},
      ),

      // Travma için ödevler
      HomeworkTemplate(
        id: 'trauma_grounding',
        title: 'Topraklama Teknikleri',
        description: 'Travmatik anılar sırasında topraklama uygulaması',
        category: 'Travma',
        tags: ['topraklama', 'anı', 'güvenlik'],
        difficulty: 'Kolay',
        estimatedDuration: 5,
        instructions: 'Travmatik anılar geldiğinde 5-4-3-2-1 tekniğini uygulayın: 5 görülen, 4 dokunulan, 3 duyulan, 2 koklanan, 1 tadılan.',
        materials: ['Topraklama kartı'],
        therapeuticGoal: 'Güvenlik hissi ve anı kontrolü',
        metadata: {'targetDisorders': ['PTSD', 'travma']},
      ),

      HomeworkTemplate(
        id: 'trauma_narrative',
        title: 'Travma Anlatısı',
        description: 'Travmatik deneyimi yazılı olarak anlatma',
        category: 'Travma',
        tags: ['anlatı', 'yazma', 'işleme'],
        difficulty: 'Zor',
        estimatedDuration: 45,
        instructions: 'Travmatik deneyiminizi detaylı olarak yazın. Duygularınızı, düşüncelerinizi ve fiziksel hislerinizi dahil edin.',
        materials: ['Kağıt', 'Kalem', 'Güvenli ortam'],
        therapeuticGoal: 'Travma işleme ve bütünleştirme',
        metadata: {'targetDisorders': ['PTSD', 'travma']},
      ),

      // Genel ödevler
      HomeworkTemplate(
        id: 'gen_mindfulness',
        title: 'Mindfulness Meditasyonu',
        description: 'Günlük mindfulness uygulaması',
        category: 'Genel',
        tags: ['mindfulness', 'meditasyon', 'farkındalık'],
        difficulty: 'Orta',
        estimatedDuration: 20,
        instructions: 'Her gün 10-20 dakika mindfulness meditasyonu yapın. Nefesinize odaklanın.',
        materials: ['Meditasyon uygulaması', 'Rahat ortam'],
        therapeuticGoal: 'Farkındalık artırma ve stres azaltma',
        metadata: {'targetDisorders': ['genel']},
      ),

      HomeworkTemplate(
        id: 'gen_sleep_hygiene',
        title: 'Uyku Hijyeni',
        description: 'Sağlıklı uyku alışkanlıkları geliştirme',
        category: 'Genel',
        tags: ['uyku', 'hijyen', 'rutin'],
        difficulty: 'Kolay',
        estimatedDuration: 0,
        instructions: 'Her gün aynı saatte yatın ve kalkın. Yatmadan 1 saat önce ekranları kapatın.',
        materials: ['Uyku takip formu'],
        therapeuticGoal: 'Uyku kalitesi artırma',
        metadata: {'targetDisorders': ['uykusuzluk', 'genel']},
      ),

      HomeworkTemplate(
        id: 'gen_social_connection',
        title: 'Sosyal Bağlantı',
        description: 'Sosyal ilişkileri güçlendirme',
        category: 'Genel',
        tags: ['sosyal', 'bağlantı', 'ilişki'],
        difficulty: 'Orta',
        estimatedDuration: 30,
        instructions: 'Haftada en az 2 kez bir arkadaşınızla veya aile üyenizle kaliteli zaman geçirin.',
        materials: ['Planlama defteri'],
        therapeuticGoal: 'Sosyal destek artırma',
        metadata: {'targetDisorders': ['depresyon', 'anksiyete', 'genel']},
      ),
    ]);
  }

  void _buildCategoryKeywords() {
    _categoryKeywords['Depresyon'] = [
      'depresyon', 'üzüntü', 'motivasyon', 'enerji', 'umutsuzluk', 'değersizlik',
      'suçluluk', 'iştah', 'uyku', 'konsantrasyon', 'intihar'
    ];
    _categoryKeywords['Anksiyete'] = [
      'anksiyete', 'endişe', 'kaygı', 'panik', 'korku', 'gerginlik', 'huzursuzluk',
      'fobi', 'sosyal', 'genel', 'ayrılık'
    ];
    _categoryKeywords['Travma'] = [
      'travma', 'PTSD', 'anı', 'flashback', 'kabus', 'tetikleyici', 'kaçınma',
      'hipervigilans', 'uyuşma', 'öfke'
    ];
    _categoryKeywords['Genel'] = [
      'genel', 'stres', 'uyku', 'beslenme', 'egzersiz', 'sosyal', 'mindfulness',
      'rahatlama', 'planlama', 'organizasyon'
    ];
  }

  // AI destekli ödev önerisi
  List<HomeworkTemplate> getSuggestedTemplates({
    required String primaryDiagnosis,
    List<String> symptoms = const [],
    String difficulty = 'Orta',
    int maxDuration = 30,
  }) {
    List<HomeworkTemplate> suggestions = [];
    
    // Tanıya göre filtreleme
    for (var template in _templates) {
      if (template.metadata['targetDisorders']?.contains(primaryDiagnosis.toLowerCase()) == true ||
          template.category.toLowerCase() == primaryDiagnosis.toLowerCase()) {
        
        // Zorluk ve süre filtresi
        if (_matchesDifficulty(template.difficulty, difficulty) &&
            template.estimatedDuration <= maxDuration) {
          suggestions.add(template);
        }
      }
    }

    // Semptomlara göre ek öneriler
    for (var symptom in symptoms) {
      for (var template in _templates) {
        if (template.tags.any((tag) => tag.toLowerCase().contains(symptom.toLowerCase())) &&
            !suggestions.contains(template)) {
          suggestions.add(template);
        }
      }
    }

    // Zorluk seviyesine göre sırala
    suggestions.sort((a, b) => _getDifficultyScore(a.difficulty).compareTo(_getDifficultyScore(b.difficulty)));
    
    return suggestions.take(5).toList();
  }

  bool _matchesDifficulty(String templateDifficulty, String requestedDifficulty) {
    if (requestedDifficulty == 'Kolay') {
      return templateDifficulty == 'Kolay';
    } else if (requestedDifficulty == 'Orta') {
      return templateDifficulty == 'Kolay' || templateDifficulty == 'Orta';
    } else {
      return true; // Zor - tüm seviyeleri kabul et
    }
  }

  int _getDifficultyScore(String difficulty) {
    switch (difficulty) {
      case 'Kolay': return 1;
      case 'Orta': return 2;
      case 'Zor': return 3;
      default: return 2;
    }
  }

  // Ödev şablonundan gerçek ödev oluşturma
  HomeworkAssignment createAssignmentFromTemplate({
    required HomeworkTemplate template,
    required String patientId,
    required String clinicianId,
    DateTime? dueDate,
    String? customInstructions,
  }) {
    final now = DateTime.now();
    final assignment = HomeworkAssignment(
      id: '${template.id}_${now.millisecondsSinceEpoch}',
      clientId: patientId,
      clinicianId: clinicianId,
      title: template.title,
      description: template.description,
      category: template.category,
      difficulty: template.difficulty,
      estimatedDuration: template.estimatedDuration,
      customInstructions: customInstructions ?? template.instructions,
      dueDate: dueDate ?? now.add(Duration(days: 7)),
      assignedDate: now,
    );

    return assignment;
  }

  // Kategoriye göre ödevler
  List<HomeworkTemplate> getTemplatesByCategory(String category) {
    return _templates.where((t) => t.category == category).toList();
  }

  // Etiketlere göre arama
  List<HomeworkTemplate> searchTemplates(String query) {
    final lowerQuery = query.toLowerCase();
    return _templates.where((template) {
      return template.title.toLowerCase().contains(lowerQuery) ||
             template.description.toLowerCase().contains(lowerQuery) ||
             template.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
             template.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
