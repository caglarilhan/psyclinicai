import 'dart:async';
import 'dart:math';
import 'package:psyclinicai/models/therapy_simulation_models.dart';
import 'package:psyclinicai/services/ai_service.dart';

class TherapySimulationService {
  static final TherapySimulationService _instance = TherapySimulationService._internal();
  factory TherapySimulationService() => _instance;
  TherapySimulationService._internal();

  final AIService _aiService = AIService();
  final List<SimulationScenario> _scenarios = [];
  final Map<String, SimulationSession> _sessions = {};
  final StreamController<SimulationSession> _sessionController = StreamController<SimulationSession>.broadcast();
  final StreamController<SessionMessage> _messageController = StreamController<SessionMessage>.broadcast();

  Stream<SimulationSession> get sessionStream => _sessionController.stream;
  Stream<SessionMessage> get messageStream => _messageController.stream;

  Future<void> initialize() async {
    _createDemoScenarios();
  }

  List<SimulationScenario> getScenarios() {
    return List.unmodifiable(_scenarios);
  }

  SimulationScenario? getScenario(String id) {
    try {
      return _scenarios.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<SimulationSession> createSession(SimulationScenario scenario) async {
    final session = SimulationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scenario: scenario,
      startTime: DateTime.now(),
      messages: [],
      sessionNotes: '',
      score: null,
    );

    _sessions[session.id] = session;
    _sessionController.add(session);
    return session;
  }

  SimulationSession? getSession(String id) {
    return _sessions[id];
  }

  Future<void> addMessage(String sessionId, SessionMessage message) async {
    final session = _sessions[sessionId];
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    session.messages.add(message);
    _messageController.add(message);
    _sessionController.add(session);
  }

  Future<SessionMessage?> getAIResponse(String sessionId, String messageId) async {
    final session = _sessions[sessionId];
    if (session == null) {
      return null;
    }

    final message = session.messages.firstWhere((m) => m.id == messageId);
    final conversationHistory = session.messages;

    // AI servisinden yanıt al
    final prompt = _buildAIPrompt(message, session.scenario, conversationHistory);
    final response = await _aiService.generateResponse(prompt);

    if (response != null) {
      final aiMessage = SessionMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: sessionId,
        sender: MessageSender.therapist,
        content: response,
        timestamp: DateTime.now(),
        metadata: {},
      );

      await addMessage(sessionId, aiMessage);
      return aiMessage;
    }

    return null;
  }

  SimulationScore? calculateScore(String sessionId, String therapistId) {
    final session = _sessions[sessionId];
    if (session == null) return null;

    final therapistMessages = session.messages
        .where((m) => m.sender == MessageSender.therapist)
        .toList();

    if (therapistMessages.isEmpty) return null;

    // Basit skorlama algoritması
    int empathyScore = 0;
    int questioningScore = 0;
    int activeListeningScore = 0;
    int professionalLanguageScore = 0;

    for (final message in therapistMessages) {
      final content = message.content.toLowerCase();

      // Empati skoru
      if (content.contains('anlıyorum') || 
          content.contains('hissettiğin') || 
          content.contains('zor olmalı')) {
        empathyScore += 20;
      }

      // Soru sorma skoru
      if (content.contains('?') && 
          !content.contains('evet') && 
          !content.contains('hayır')) {
        questioningScore += 25;
      }

      // Aktif dinleme skoru
      if (content.contains('demek') || 
          content.contains('anladığım') || 
          content.contains('tekrar')) {
        activeListeningScore += 20;
      }

      // Profesyonel dil skoru
      if (!content.contains('lan') && 
          !content.contains('oğlum') && 
          !content.contains('kızım')) {
        professionalLanguageScore += 15;
      }
    }

    // Skorları normalize et (0-100 arası)
    empathyScore = empathyScore.clamp(0, 100);
    questioningScore = questioningScore.clamp(0, 100);
    activeListeningScore = activeListeningScore.clamp(0, 100);
    professionalLanguageScore = professionalLanguageScore.clamp(0, 100);

    final totalScore = (empathyScore + questioningScore + activeListeningScore + professionalLanguageScore) ~/ 4;

    final score = SimulationScore(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      empathyScore: empathyScore.toDouble(),
      questioningScore: questioningScore.toDouble(),
      activeListeningScore: activeListeningScore.toDouble(),
      professionalLanguageScore: professionalLanguageScore.toDouble(),
      overallScore: totalScore.toDouble(),
      strengths: _identifyStrengths(session),
      areasForImprovement: _identifyAreasForImprovement(session),
      detailedScores: {
        'empathy': empathyScore,
        'questioning': questioningScore,
        'active_listening': activeListeningScore,
        'professional_language': professionalLanguageScore,
      },
      calculatedAt: DateTime.now(),
    );

    session.score = score;
    return score;
  }

  List<String> _identifyStrengths(SimulationSession session) {
    List<String> strengths = [];
    
    // Empati güçlü yanları
    if (session.messages.any((msg) => 
        msg.sender == MessageSender.therapist && 
        (msg.content.toLowerCase().contains('anlıyorum') ||
         msg.content.toLowerCase().contains('hissettiğin') ||
         msg.content.toLowerCase().contains('zor olmalı')))) {
      strengths.add('Empati gösterme');
    }
    
    // Açık uçlu sorular
    if (session.messages.any((msg) => 
        msg.sender == MessageSender.therapist && 
        (msg.content.contains('?') && 
         !msg.content.toLowerCase().contains('evet') &&
         !msg.content.toLowerCase().contains('hayır')))) {
      strengths.add('Açık uçlu sorular sorma');
    }
    
    // Aktif dinleme
    if (session.messages.any((msg) => 
        msg.sender == MessageSender.therapist && 
        (msg.content.toLowerCase().contains('demek') ||
         msg.content.toLowerCase().contains('anladığım') ||
         msg.content.toLowerCase().contains('tekrar')))) {
      strengths.add('Aktif dinleme');
    }
    
    // Profesyonel dil
    if (session.messages.any((msg) => 
        msg.sender == MessageSender.therapist && 
        !msg.content.toLowerCase().contains('lan') &&
        !msg.content.toLowerCase().contains('oğlum') &&
        !msg.content.toLowerCase().contains('kızım'))) {
      strengths.add('Profesyonel dil kullanımı');
    }
    
    return strengths.isNotEmpty ? strengths : ['Temel terapötik beceriler'];
  }

  List<String> _identifyAreasForImprovement(SimulationSession session) {
    List<String> areas = [];
    
    // Empati eksiklikleri
    if (!session.messages.any((msg) => 
        msg.sender == MessageSender.therapist && 
        (msg.content.toLowerCase().contains('anlıyorum') ||
         msg.content.toLowerCase().contains('hissettiğin')))) {
      areas.add('Empati gösterme');
    }
    
    // Kapalı uçlu sorular
    if (session.messages.any((msg) => 
        msg.sender == MessageSender.therapist && 
        (msg.content.toLowerCase().contains('evet mi') ||
         msg.content.toLowerCase().contains('hayır mı') ||
         msg.content.toLowerCase().contains('doğru mu')))) {
      areas.add('Açık uçlu sorular sorma');
    }
    
    // Aktif dinleme eksiklikleri
    if (!session.messages.any((msg) => 
        msg.sender == MessageSender.therapist && 
        msg.content.toLowerCase().contains('demek'))) {
      areas.add('Aktif dinleme');
    }
    
    // Profesyonel olmayan dil
    if (session.messages.any((msg) => 
        msg.sender == MessageSender.therapist && 
        (msg.content.toLowerCase().contains('lan') ||
         msg.content.toLowerCase().contains('oğlum') ||
         msg.content.toLowerCase().contains('kızım')))) {
      areas.add('Profesyonel dil kullanımı');
    }
    
    return areas.isNotEmpty ? areas : ['Genel terapötik beceriler'];
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

  String getScoreFeedback(SimulationScore score) {
    if (score.overallScore >= 80) {
      return 'Mükemmel! Çok iyi bir terapist olacaksınız! Empati, soru sorma ve aktif dinleme becerileriniz çok güçlü.';
    } else if (score.overallScore >= 60) {
      return 'İyi! Biraz daha pratik yapmanız gerekiyor. Empati göstermeye ve açık uçlu sorular sormaya odaklanın.';
    } else if (score.overallScore >= 40) {
      return 'Geliştirilmesi gereken alanlar var. Daha fazla empati gösterin ve danışanı dinlemeye odaklanın.';
    } else {
      return 'Temel becerileri geliştirmeniz gerekiyor. Empati, aktif dinleme ve profesyonel dil kullanımına odaklanın.';
    }
  }

  String _buildAIPrompt(SessionMessage therapistMessage, SimulationScenario scenario, List<SessionMessage> conversationHistory) {
    final clientName = scenario.initialContext['client_name'] ?? 'Danışan';
    final recentMessages = conversationHistory.reversed.take(5).toList().reversed.map((m) => 
      '${m.sender == MessageSender.therapist ? "Terapist" : clientName}: ${m.content}'
    ).join('\n');

    return '''
Sen bir deneyimli terapistsin. ${scenario.scenarioDescription}

Danışan Profili: ${scenario.patientProfile}
Terapi Yaklaşımı: ${scenario.approach.name}

Son konuşma:
$recentMessages

Terapist olarak danışanın son mesajına uygun, empatik ve profesyonel bir yanıt ver. Yanıtın kısa ve etkili olsun.
''';
  }

  void _createDemoScenarios() {
    _scenarios.addAll([
      SimulationScenario(
        id: 'depression_1',
        title: 'Depresyon Vakası - Ahmet',
        description: 'Depresyon vakası simülasyonu',
        difficulty: 'Orta',
        approach: TherapyApproach.cbt,
        patientProfile: '32 yaşında erkek, 6 aydır depresif belirtiler gösteriyor',
        scenarioDescription: 'Ahmet son 6 aydır iş stresi ve kişisel sorunlar nedeniyle depresif belirtiler yaşıyor.',
        learningObjectives: ['Depresyon belirtilerini tanıma', 'CBT tekniklerini uygulama'],
        keyTechniques: ['Düşünce kayıtları', 'Davranış aktivasyonu'],
        commonPitfalls: ['Çok hızlı ilerleme', 'Duyguları görmezden gelme'],
        initialContext: {
          'client_name': 'Ahmet',
          'age': '32',
          'gender': 'Erkek',
          'presenting_problem': 'Depresyon',
          'duration': '6 ay',
        },
        metadata: {
          'category': 'depression',
          'severity': 'moderate',
        },
        createdAt: DateTime.now(),
        isActive: true,
      ),
      SimulationScenario(
        id: 'anxiety_1',
        title: 'Anksiyete Vakası - Ayşe',
        description: 'Anksiyete vakası simülasyonu',
        difficulty: 'Kolay',
        approach: TherapyApproach.mindfulness,
        patientProfile: '28 yaşında kadın, sosyal anksiyete yaşıyor',
        scenarioDescription: 'Ayşe sosyal durumlarda aşırı kaygı yaşıyor ve bu durum günlük yaşamını etkiliyor.',
        learningObjectives: ['Anksiyete belirtilerini tanıma', 'Mindfulness tekniklerini öğretme'],
        keyTechniques: ['Nefes egzersizleri', 'Farkındalık meditasyonu'],
        commonPitfalls: ['Kaygıyı artırma', 'Teknikleri yanlış uygulama'],
        initialContext: {
          'client_name': 'Ayşe',
          'age': '28',
          'gender': 'Kadın',
          'presenting_problem': 'Sosyal Anksiyete',
          'duration': '2 yıl',
        },
        metadata: {
          'category': 'anxiety',
          'severity': 'mild',
        },
        createdAt: DateTime.now(),
        isActive: true,
      ),
    ]);
  }

  void dispose() {
    _scenarios.clear();
    _sessions.clear();
    _sessionController.close();
    _messageController.close();
  }
}
