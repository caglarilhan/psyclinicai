import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/therapy_simulation_models.dart';
import 'ai_service.dart';

/// Terapi Simülasyonu Servisi
/// AI destekli rol-play simülasyonları için
class TherapySimulationService {
  static final TherapySimulationService _instance = TherapySimulationService._internal();
  factory TherapySimulationService() => _instance;
  TherapySimulationService._internal();

  final AIService _aiService = AIService();
  final Random _random = Random();

  // Senaryo veritabanı
  final List<SimulationScenario> _scenarios = [];
  
  // Aktif simülasyonlar
  final Map<String, SimulationSession> _activeSessions = {};

  Future<void> initialize() async {
    await _loadScenarios();
    print('TherapySimulationService initialized with ${_scenarios.length} scenarios');
  }

  Future<void> _loadScenarios() async {
    _scenarios.addAll([
      SimulationScenario(
        id: '1',
        title: 'Depresyon Vakası: Ahmet',
        description: '35 yaşında erkek, son 6 aydır depresif belirtiler gösteriyor. İş kaybı ve evlilik problemleri yaşıyor.',
        difficulty: ScenarioDifficulty.intermediate,
        category: 'Depresyon',
        clientProfile: ClientProfile(
          name: 'Ahmet',
          age: 35,
          gender: 'Erkek',
          presentingProblem: 'Depresyon, iş kaybı, evlilik problemleri',
          background: 'Mühendis, 2 çocuk babası, son 6 aydır işsiz',
          symptoms: [
            'Üzgün ruh hali',
            'Uyku problemleri',
            'İştah kaybı',
            'Konsantrasyon güçlüğü',
            'Yorgunluk',
            'Değersizlik hissi'
          ],
          goals: 'Depresyonu yönetmek, iş bulmak, evliliği iyileştirmek',
        ),
        therapeuticApproach: 'CBT + Problem Solving Therapy',
        estimatedDuration: 45,
        tags: ['depresyon', 'iş kaybı', 'evlilik', 'CBT'],
      ),
      SimulationScenario(
        id: '2',
        title: 'Anksiyete Vakası: Zeynep',
        description: '28 yaşında kadın, sosyal anksiyete ve panik atak belirtileri. Topluluk önünde konuşma korkusu.',
        difficulty: ScenarioDifficulty.beginner,
        category: 'Anksiyete',
        clientProfile: ClientProfile(
          name: 'Zeynep',
          age: 28,
          gender: 'Kadın',
          presentingProblem: 'Sosyal anksiyete, panik atak',
          background: 'Öğretmen, bekar, sosyal ortamlarda kendini rahatsız hissediyor',
          symptoms: [
            'Sosyal ortamlarda kaygı',
            'Panik atak',
            'Kaçınma davranışları',
            'Fiziksel belirtiler',
            'Kendini yargılanmış hissetme'
          ],
          goals: 'Sosyal anksiyeteyi azaltmak, panik atakları yönetmek',
        ),
        therapeuticApproach: 'Exposure Therapy + Relaxation Techniques',
        estimatedDuration: 40,
        tags: ['anksiyete', 'sosyal fobi', 'panik atak', 'exposure'],
      ),
      SimulationScenario(
        id: '3',
        title: 'Travma Vakası: Mehmet',
        description: '42 yaşında erkek, trafik kazası sonrası TSSB belirtileri. Flashback\'ler ve uyku problemleri.',
        difficulty: ScenarioDifficulty.advanced,
        category: 'Travma',
        clientProfile: ClientProfile(
          name: 'Mehmet',
          age: 42,
          gender: 'Erkek',
          presentingProblem: 'TSSB, trafik kazası sonrası',
          background: 'Şoför, 3 ay önce ciddi trafik kazası geçirdi',
          symptoms: [
            'Flashback\'ler',
            'Uyku problemleri',
            'Kaçınma davranışları',
            'Aşırı uyarılma',
            'Duygusal uyuşma',
            'Konsantrasyon güçlüğü'
          ],
          goals: 'Travma belirtilerini azaltmak, normal hayata dönmek',
        ),
        therapeuticApproach: 'EMDR + Trauma-Focused CBT',
        estimatedDuration: 60,
        tags: ['travma', 'TSSB', 'EMDR', 'flashback'],
      ),
      SimulationScenario(
        id: '4',
        title: 'İlişki Vakası: Ayşe & Ali',
        description: 'Çift terapi: 5 yıllık evlilik, iletişim problemleri ve güven sorunları.',
        difficulty: ScenarioDifficulty.intermediate,
        category: 'İlişki',
        clientProfile: ClientProfile(
          name: 'Ayşe & Ali',
          age: 32,
          gender: 'Çift',
          presentingProblem: 'İletişim problemleri, güven sorunları',
          background: '5 yıllık evlilik, 1 çocuk, sürekli tartışmalar',
          symptoms: [
            'İletişim problemleri',
            'Güven sorunları',
            'Sürekli tartışmalar',
            'Duygusal uzaklaşma',
            'Çocuk üzerinde etki'
          ],
          goals: 'İletişimi iyileştirmek, güveni yeniden kurmak',
        ),
        therapeuticApproach: 'Couples Therapy + Communication Skills',
        estimatedDuration: 50,
        tags: ['ilişki', 'çift terapi', 'iletişim', 'güven'],
      ),
      SimulationScenario(
        id: '5',
        title: 'Bağımlılık Vakası: Can',
        description: '25 yaşında erkek, alkol bağımlılığı ve aile problemleri. Detoks sonrası rehabilitasyon.',
        difficulty: ScenarioDifficulty.advanced,
        category: 'Bağımlılık',
        clientProfile: ClientProfile(
          name: 'Can',
          age: 25,
          gender: 'Erkek',
          presentingProblem: 'Alkol bağımlılığı, aile problemleri',
          background: 'Üniversite öğrencisi, aile içi şiddet geçmişi',
          symptoms: [
            'Alkol kullanımı',
            'Kontrol kaybı',
            'Aile problemleri',
            'Akademik başarısızlık',
            'Sosyal izolasyon'
          ],
          goals: 'Sobriyet sağlamak, aile ilişkilerini iyileştirmek',
        ),
        therapeuticApproach: 'Motivational Interviewing + Family Therapy',
        estimatedDuration: 55,
        tags: ['bağımlılık', 'alkol', 'aile', 'motivasyonel görüşme'],
      ),
    ]);
  }

  List<SimulationScenario> getScenarios() => List.unmodifiable(_scenarios);

  SimulationScenario? getScenarioById(String id) {
    try {
      return _scenarios.firstWhere((scenario) => scenario.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<String> generateAIResponse(
    String therapistMessage,
    SimulationScenario scenario,
    List<SessionMessage> conversationHistory,
  ) async {
    try {
      // AI servisinden yanıt al
      final prompt = _buildAIPrompt(therapistMessage, scenario, conversationHistory);
      final response = await _aiService.generateResponse(
        prompt: prompt,
        maxTokens: 200,
      );
      
      return response.isNotEmpty ? response : _getFallbackResponse(scenario);
    } catch (e) {
      print('AI response generation failed: $e');
      return _getFallbackResponse(scenario);
    }
  }

  String _buildAIPrompt(
    String therapistMessage,
    SimulationScenario scenario,
    List<SessionMessage> conversationHistory,
  ) {
    final clientProfile = scenario.clientProfile;
    final recentMessages = conversationHistory.takeLast(5).map((m) => 
      '${m.sender == MessageSender.therapist ? "Terapist" : clientProfile.name}: ${m.content}'
    ).join('\n');

    return '''
Sen ${clientProfile.name} adında ${clientProfile.age} yaşında bir danışansın. 
${clientProfile.presentingProblem} problemi yaşıyorsun.

Arka plan: ${clientProfile.background}
Belirtiler: ${clientProfile.symptoms.join(', ')}
Hedefler: ${clientProfile.goals}

Son konuşma:
$recentMessages

Terapist: $therapistMessage

Senin yanıtın (doğal, gerçekçi ve probleminize uygun olmalı):
''';
  }

  String _getFallbackResponse(SimulationScenario scenario) {
    final responses = {
      '1': [ // Ahmet - Depresyon
        'Kendimi çok boş hissediyorum... Sanki hiçbir şey beni mutlu edemiyor.',
        'İş bulmaya çalışıyorum ama hiç umudum yok. Her mülakatta reddediliyorum.',
        'Karım sürekli beni suçluyor. "Sen işsizsin, para kazanamıyorsun" diyor.',
        'Bazen ölmek istediğimi bile düşünüyorum...',
        'Hiçbir şey yapmak istemiyorum. Sadece yatıp uyumak istiyorum.',
      ],
      '2': [ // Zeynep - Anksiyete
        'Kalp atışlarım hızlanıyor, nefes alamıyorum... Sanki öleceğim gibi hissediyorum.',
        'İnsanların beni yargılayacağını düşünüyorum. "Ya yanlış bir şey söylersem?"',
        'Topluluk önünde konuşmam gerektiğinde neredeyse bayılıyorum.',
        'Bu durum beni çok yoruyor... Sürekli endişeli hissediyorum.',
        'Sosyal ortamlarda kendimi çok rahatsız hissediyorum.',
      ],
      '3': [ // Mehmet - Travma
        'O anı tekrar yaşıyorum... Cam kırıkları, sesler, acı... Uyuyamıyorum.',
        'Arabaya binmek imkansız! Her seferinde o kazayı hatırlıyorum.',
        'Sürekli tetikteyim, en ufak ses bile beni korkutuyor.',
        'O geceyi sürekli rüyamda görüyorum... Uyuyamıyorum.',
        'Her yerde tehlike arıyorum... Güvende hissetmiyorum.',
      ],
      '4': [ // Ayşe & Ali - İlişki
        'Onu anlayamıyorum ve o da beni anlamıyor. Evliliğimiz çöküyor gibi.',
        'Sürekli tartışıyoruz. Küçük şeyler bile büyük kavgalara dönüşüyor.',
        'Güvenim kalmadı. Her hareketini şüpheyle karşılıyorum.',
        'Çocuğumuz bu durumdan etkileniyor. Çok üzülüyorum.',
        'Eskiden nasıl mutluyduk, şimdi nasıl bu hale geldik?',
      ],
      '5': [ // Can - Bağımlılık
        'Alkol kullanımımı kontrol edemiyorum. Her gün içmeye başlıyorum.',
        'Ailem beni terk etti. Artık kimse bana güvenmiyor.',
        'Üniversiteyi bıraktım. Hiçbir şeyi başaramıyorum.',
        'Bırakmaya çalışıyorum ama dayanamıyorum. Çok zor.',
        'Kendimden nefret ediyorum. Neden bu hale geldim?',
      ],
    };

    final scenarioResponses = responses[scenario.id] ?? [
      'Anlıyorum... Bu konuda daha fazla konuşmak istiyorum.',
      'Bilmiyorum... Bazen iyi hissediyorum ama çoğunlukla kötüyüm.',
      'Size yardım etmenizi umuyorum...',
      'Bu konuda düşünmem gerekiyor...',
      'Teşekkür ederim doktor...',
    ];

    return scenarioResponses[_random.nextInt(scenarioResponses.length)];
  }

  SimulationScore calculateScore(
    List<SessionMessage> messages,
    SimulationScenario scenario,
  ) {
    int empathyScore = 0;
    int questioningScore = 0;
    int activeListeningScore = 0;
    int professionalLanguageScore = 0;

    final therapistMessages = messages
        .where((m) => m.sender == MessageSender.therapist)
        .map((m) => m.content.toLowerCase())
        .toList();

    for (final message in therapistMessages) {
      // Empati skoru
      if (_containsEmpathyKeywords(message)) {
        empathyScore += 10;
      }
      if (_containsValidation(message)) {
        empathyScore += 5;
      }

      // Soru sorma skoru
      if (_containsOpenQuestions(message)) {
        questioningScore += 15;
      }
      if (_containsClarificationQuestions(message)) {
        questioningScore += 10;
      }

      // Aktif dinleme skoru
      if (_containsActiveListening(message)) {
        activeListeningScore += 10;
      }
      if (_containsReflection(message)) {
        activeListeningScore += 8;
      }

      // Profesyonel dil skoru
      if (_containsProfessionalLanguage(message)) {
        professionalLanguageScore += 5;
      }
      if (_containsTherapeuticTechniques(message)) {
        professionalLanguageScore += 8;
      }
    }

    final totalScore = empathyScore + questioningScore + activeListeningScore + professionalLanguageScore;

    return SimulationScore(
      empathyScore: empathyScore,
      questioningScore: questioningScore,
      activeListeningScore: activeListeningScore,
      professionalLanguageScore: professionalLanguageScore,
      totalScore: totalScore,
    );
  }

  bool _containsEmpathyKeywords(String message) {
    final empathyWords = [
      'anlıyorum', 'hissediyorum', 'zor olmalı', 'üzgünüm',
      'korkutucu', 'stresli', 'yorgun', 'endişeli', 'kaygılı'
    ];
    return empathyWords.any((word) => message.contains(word));
  }

  bool _containsValidation(String message) {
    final validationWords = [
      'normal', 'doğal', 'anlaşılır', 'mantıklı', 'haklısın'
    ];
    return validationWords.any((word) => message.contains(word));
  }

  bool _containsOpenQuestions(String message) {
    final openQuestionWords = [
      'nasıl', 'ne zaman', 'nerede', 'neden', 'hangi',
      'hangi şekilde', 'nasıl hissettin', 'ne düşündün'
    ];
    return openQuestionWords.any((word) => message.contains(word));
  }

  bool _containsClarificationQuestions(String message) {
    final clarificationWords = [
      'yani', 'demek ki', 'anladığım kadarıyla', 'tekrar edeyim'
    ];
    return clarificationWords.any((word) => message.contains(word));
  }

  bool _containsActiveListening(String message) {
    final activeListeningWords = [
      'yani', 'demek ki', 'anladığım kadarıyla', 'tekrar edeyim',
      'özetlersek', 'şunu mu demek istiyorsun'
    ];
    return activeListeningWords.any((word) => message.contains(word));
  }

  bool _containsReflection(String message) {
    final reflectionWords = [
      'sanki', 'gibi', 'benzer', 'aynı', 'görünüyor'
    ];
    return reflectionWords.any((word) => message.contains(word));
  }

  bool _containsProfessionalLanguage(String message) {
    final professionalWords = [
      'terapi', 'tedavi', 'iyileşme', 'süreç', 'çalışma',
      'hedef', 'strateji', 'teknik', 'yöntem'
    ];
    return professionalWords.any((word) => message.contains(word));
  }

  bool _containsTherapeuticTechniques(String message) {
    final techniqueWords = [
      'nefes', 'gevşeme', 'meditasyon', 'mindfulness', 'exposure',
      'bilişsel', 'davranışsal', 'çözüm', 'plan'
    ];
    return techniqueWords.any((word) => message.contains(word));
  }

  String getScoreFeedback(SimulationScore score) {
    if (score.totalScore >= 80) {
      return 'Mükemmel! Çok iyi bir terapist olacaksınız! Empati, soru sorma ve aktif dinleme becerileriniz çok güçlü.';
    } else if (score.totalScore >= 60) {
      return 'İyi! Biraz daha pratik yapmanız gerekiyor. Empati göstermeye ve açık uçlu sorular sormaya odaklanın.';
    } else if (score.totalScore >= 40) {
      return 'Geliştirilmesi gereken alanlar var. Daha fazla empati gösterin ve danışanı dinlemeye odaklanın.';
    } else {
      return 'Temel becerileri geliştirmeniz gerekiyor. Empati, aktif dinleme ve profesyonel dil kullanımına odaklanın.';
    }
  }

  List<String> getImprovementSuggestions(SimulationScore score) {
    final suggestions = <String>[];

    if (score.empathyScore < 20) {
      suggestions.add('Empati becerilerinizi geliştirin: "Anlıyorum", "Zor olmalı" gibi ifadeler kullanın');
    }

    if (score.questioningScore < 25) {
      suggestions.add('Daha fazla açık uçlu soru sorun: "Nasıl hissettin?", "Ne düşündün?" gibi');
    }

    if (score.activeListeningScore < 20) {
      suggestions.add('Aktif dinleme tekniklerini kullanın: "Yani...", "Demek ki..." gibi');
    }

    if (score.professionalLanguageScore < 15) {
      suggestions.add('Profesyonel terapi dilini kullanın ve teknik terimler ekleyin');
    }

    if (suggestions.isEmpty) {
      suggestions.add('Tüm alanlarda iyi performans gösteriyorsunuz!');
    }

    return suggestions;
  }
}

class SimulationSession {
  final String id;
  final SimulationScenario scenario;
  final DateTime startTime;
  final List<SessionMessage> messages;
  String sessionNotes;
  SimulationScore? score;

  SimulationSession({
    required this.id,
    required this.scenario,
    required this.startTime,
    required this.messages,
    this.sessionNotes = '',
    this.score,
  });

  Duration get duration => DateTime.now().difference(startTime);
  int get messageCount => messages.length;
  int get therapistMessageCount => messages.where((m) => m.sender == MessageSender.therapist).length;
  int get clientMessageCount => messages.where((m) => m.sender == MessageSender.client).length;
}
