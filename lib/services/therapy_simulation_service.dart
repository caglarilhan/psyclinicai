import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/therapy_simulation_models.dart';

/// Terapi Simülasyonu Servisi
/// AI destekli rol-play simülasyonları için
class TherapySimulationService {
  static const String _baseUrl = 'https://api.psyclinicai.com/therapy-simulation';
  static const String _apiKey = 'your_api_key_here';
  
  // Caches
  final Map<String, TherapySimulationSession> _sessionsCache = {};
  final Map<String, List<SimulationTurn>> _turnsCache = {};
  final Map<String, SimulationMetrics> _metricsCache = {};
  final List<SimulationScenario> _scenariosCache = [];
  
  // Stream controllers
  final StreamController<TherapySimulationSession> _sessionController = 
      StreamController<TherapySimulationSession>.broadcast();
  final StreamController<SimulationTurn> _turnController = 
      StreamController<SimulationTurn>.broadcast();
  final StreamController<SimulationMetrics> _metricsController = 
      StreamController<SimulationMetrics>.broadcast();
  
  // Streams
  Stream<TherapySimulationSession> get sessionStream => _sessionController.stream;
  Stream<SimulationTurn> get turnStream => _turnController.stream;
  Stream<SimulationMetrics> get metricsStream => _metricsController.stream;
  
  /// Servisi başlat
  Future<void> initialize() async {
    try {
      await _loadScenarios();
      await _loadMockData();
      print('TherapySimulationService initialized successfully');
    } catch (e) {
      print('Error initializing TherapySimulationService: $e');
      // Mock data ile devam et
      await _loadMockData();
    }
  }
  
  /// Senaryoları yükle
  Future<void> _loadScenarios() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/scenarios'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _scenariosCache.clear();
        _scenariosCache.addAll(
          data.map((json) => SimulationScenario.fromJson(json))
        );
      }
    } catch (e) {
      print('Error loading scenarios: $e');
    }
  }
  
  /// Mock data yükle
  Future<void> _loadMockData() async {
    _scenariosCache.addAll(_generateMockScenarios());
  }
  
  /// Yeni simülasyon seansı oluştur
  Future<TherapySimulationSession> createSession({
    required String title,
    required String description,
    required TherapyApproach approach,
    required String createdBy,
    String? patientProfile,
    String? scenarioDescription,
    List<String>? learningObjectives,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final session = TherapySimulationSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        approach: approach,
        status: SimulationStatus.notStarted,
        createdAt: DateTime.now(),
        maxDuration: 60,
        currentDuration: 0,
        createdBy: createdBy,
        patientProfile: patientProfile,
        scenarioDescription: scenarioDescription,
        learningObjectives: learningObjectives ?? ['Temel terapi tekniklerini uygula'],
        settings: settings ?? {},
        metadata: {},
      );
      
      // Cache'e ekle
      _sessionsCache[session.id] = session;
      
      // Stream'e gönder
      _sessionController.add(session);
      
      return session;
    } catch (e) {
      print('Error creating session: $e');
      rethrow;
    }
  }
  
  /// Simülasyon seansını başlat
  Future<void> startSession(String sessionId) async {
    try {
      final session = _sessionsCache[sessionId];
      if (session != null) {
        final updatedSession = TherapySimulationSession(
          id: session.id,
          title: session.title,
          description: session.description,
          approach: session.approach,
          status: SimulationStatus.inProgress,
          createdAt: session.createdAt,
          startedAt: DateTime.now(),
          completedAt: session.completedAt,
          maxDuration: session.maxDuration,
          currentDuration: session.currentDuration,
          createdBy: session.createdBy,
          patientProfile: session.patientProfile,
          scenarioDescription: session.scenarioDescription,
          learningObjectives: session.learningObjectives,
          settings: session.settings,
          metadata: session.metadata,
        );
        
        _sessionsCache[sessionId] = updatedSession;
        _sessionController.add(updatedSession);
      }
    } catch (e) {
      print('Error starting session: $e');
    }
  }
  
  /// Simülasyon turu ekle
  Future<SimulationTurn> addTurn({
    required String sessionId,
    required String content,
    required RoleType role,
    Map<String, dynamic>? context,
  }) async {
    try {
      final session = _sessionsCache[sessionId];
      if (session == null) {
        throw Exception('Session not found');
      }
      
      final turn = SimulationTurn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: sessionId,
        turnNumber: (_turnsCache[sessionId]?.length ?? 0) + 1,
        role: role,
        content: content,
        timestamp: DateTime.now(),
        context: context ?? {},
        metadata: {},
      );
      
      // Cache'e ekle
      if (_turnsCache[sessionId] == null) {
        _turnsCache[sessionId] = [];
      }
      _turnsCache[sessionId]!.add(turn);
      
      // Stream'e gönder
      _turnController.add(turn);
      
      return turn;
    } catch (e) {
      print('Error adding turn: $e');
      rethrow;
    }
  }
  
  /// AI yanıtı al
  Future<AIResponse> getAIResponse({
    required String turnId,
    required String sessionId,
    required RoleType role,
    Map<String, dynamic>? context,
  }) async {
    try {
      final session = _sessionsCache[sessionId];
      if (session == null) {
        throw Exception('Session not found');
      }
      
      // AI prompt oluştur
      final prompt = _generatePrompt(session, role, context);
      
      // AI API çağrısı (mock)
      final aiContent = await _callAI(prompt, role);
      
      final aiResponse = AIResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        turnId: turnId,
        content: aiContent,
        role: role,
        reasoning: _generateReasoning(role, session.approach),
        techniques: _extractTechniques(aiContent, session.approach),
        emotions: _analyzeEmotions(aiContent),
        metadata: context ?? {},
        timestamp: DateTime.now(),
      );
      
      // Turn'i güncelle
      final turns = _turnsCache[sessionId];
      if (turns != null) {
        final turnIndex = turns.indexWhere((t) => t.id == turnId);
        if (turnIndex != -1) {
          final updatedTurn = SimulationTurn(
            id: turns[turnIndex].id,
            sessionId: turns[turnIndex].sessionId,
            turnNumber: turns[turnIndex].turnNumber,
            role: turns[turnIndex].role,
            content: turns[turnIndex].content,
            aiResponse: aiContent,
            userResponse: turns[turnIndex].userResponse,
            timestamp: turns[turnIndex].timestamp,
            context: turns[turnIndex].context,
            metadata: turns[turnIndex].metadata,
          );
          turns[turnIndex] = updatedTurn;
          _turnController.add(updatedTurn);
        }
      }
      
      return aiResponse;
    } catch (e) {
      print('Error getting AI response: $e');
      rethrow;
    }
  }
  
  /// Simülasyonu tamamla
  Future<void> completeSession(String sessionId) async {
    try {
      final session = _sessionsCache[sessionId];
      if (session != null) {
        final updatedSession = TherapySimulationSession(
          id: session.id,
          title: session.title,
          description: session.description,
          approach: session.approach,
          status: SimulationStatus.completed,
          createdAt: session.createdAt,
          startedAt: session.startedAt,
          completedAt: DateTime.now(),
          maxDuration: session.maxDuration,
          currentDuration: DateTime.now().difference(session.startedAt ?? session.createdAt).inMinutes,
          createdBy: session.createdBy,
          patientProfile: session.patientProfile,
          scenarioDescription: session.scenarioDescription,
          learningObjectives: session.learningObjectives,
          settings: session.settings,
          metadata: session.metadata,
        );
        
        _sessionsCache[sessionId] = updatedSession;
        _sessionController.add(updatedSession);
        
        // Metrikleri hesapla
        await _calculateMetrics(sessionId);
      }
    } catch (e) {
      print('Error completing session: $e');
    }
  }
  
  /// Metrikleri hesapla
  Future<SimulationMetrics> _calculateMetrics(String sessionId) async {
    try {
      final turns = _turnsCache[sessionId] ?? [];
      final session = _sessionsCache[sessionId];
      
      if (session == null) return _generateMockMetrics(sessionId);
      
      final userTurns = turns.where((t) => t.role == RoleType.therapist).length;
      final aiTurns = turns.where((t) => t.role == RoleType.patient).length;
      
      final metrics = SimulationMetrics(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: sessionId,
        totalTurns: turns.length,
        userTurns: userTurns,
        aiTurns: aiTurns,
        averageResponseTime: _calculateAverageResponseTime(turns),
        engagementScore: _calculateEngagementScore(turns),
        techniqueUsageScore: _calculateTechniqueScore(turns, session.approach),
        empathyScore: _calculateEmpathyScore(turns),
        strengths: _identifyStrengths(turns),
        areasForImprovement: _identifyAreasForImprovement(turns),
        detailedMetrics: _generateDetailedMetrics(turns),
        calculatedAt: DateTime.now(),
      );
      
      _metricsCache[sessionId] = metrics;
      _metricsController.add(metrics);
      
      return metrics;
    } catch (e) {
      print('Error calculating metrics: $e');
      return _generateMockMetrics(sessionId);
    }
  }
  
  /// AI prompt oluştur
  String _generatePrompt(TherapySimulationSession session, RoleType role, Map<String, dynamic>? context) {
    final approach = session.approach.toString().split('.').last;
    final patientProfile = session.patientProfile ?? 'Genel hasta profili';
    
    if (role == RoleType.patient) {
      return '''
Sen bir $approach terapi seansında hasta rolündesin. 
Hasta profili: $patientProfile
Senaryo: ${session.scenarioDescription ?? 'Standart terapi seansı'}

Lütfen hasta perspektifinden gerçekçi ve terapötik olarak uygun yanıtlar ver.
''';
    } else {
      return '''
Sen bir $approach terapistisin. 
Hasta profili: $patientProfile
Senaryo: ${session.scenarioDescription ?? 'Standart terapi seansı'}

Lütfen terapötik teknikleri kullanarak uygun müdahaleler yap.
''';
    }
  }
  
  /// AI API çağrısı (mock)
  Future<String> _callAI(String prompt, RoleType role) async {
    // Gerçek AI API çağrısı burada yapılacak
    await Future.delayed(Duration(milliseconds: 500)); // Simüle edilmiş gecikme
    
    if (role == RoleType.patient) {
      return _generateMockPatientResponse();
    } else {
      return _generateMockTherapistResponse();
    }
  }
  
  /// Mock hasta yanıtı
  String _generateMockPatientResponse() {
    final responses = [
      'Evet, gerçekten de öyle hissediyorum...',
      'Bu konuda çok endişeliyim.',
      'Bazen kendimi çok yalnız hissediyorum.',
      'Ailemle ilgili sorunlar yaşıyorum.',
      'İş hayatımda çok stres var.',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }
  
  /// Mock terapist yanıtı
  String _generateMockTherapistResponse() {
    final responses = [
      'Bu duyguları nasıl deneyimliyorsun?',
      'Bu durumla nasıl başa çıkıyorsun?',
      'Bu konuda daha detaylı konuşmak ister misin?',
      'Bu hissiyatın ne zaman başladığını hatırlıyor musun?',
      'Bu durumla ilgili ne yapmak istiyorsun?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }
  
  /// Akıl yürütme oluştur
  String _generateReasoning(RoleType role, TherapyApproach approach) {
    if (role == RoleType.therapist) {
      return 'Terapötik müdahale: ${approach.toString().split('.').last} yaklaşımına uygun teknik kullanıldı.';
    } else {
      return 'Hasta perspektifi: Gerçekçi ve terapötik olarak uygun yanıt verildi.';
    }
  }
  
  /// Teknikleri çıkar
  List<String> _extractTechniques(String content, TherapyApproach approach) {
    final techniques = <String>[];
    
    switch (approach) {
      case TherapyApproach.cbt:
        if (content.contains('düşünce') || content.contains('bilişsel')) {
          techniques.add('Bilişsel Yeniden Yapılandırma');
        }
        if (content.contains('davranış') || content.contains('aktivite')) {
          techniques.add('Davranış Aktivasyonu');
        }
        break;
      case TherapyApproach.dbt:
        if (content.contains('farkındalık') || content.contains('mindfulness')) {
          techniques.add('Farkındalık');
        }
        if (content.contains('düzenleme') || content.contains('regülasyon')) {
          techniques.add('Duygu Düzenleme');
        }
        break;
      default:
        techniques.add('Genel Terapötik Teknik');
    }
    
    return techniques;
  }
  
  /// Duyguları analiz et
  Map<String, dynamic> _analyzeEmotions(String content) {
    final emotions = <String, double>{};
    
    if (content.contains('endişe') || content.contains('kaygı')) {
      emotions['anxiety'] = 0.8;
    }
    if (content.contains('üzgün') || content.contains('depresif')) {
      emotions['sadness'] = 0.7;
    }
    if (content.contains('öfke') || content.contains('kızgın')) {
      emotions['anger'] = 0.6;
    }
    if (content.contains('mutlu') || content.contains('iyi')) {
      emotions['happiness'] = 0.5;
    }
    
    return emotions;
  }
  
  /// Ortalama yanıt süresini hesapla
  double _calculateAverageResponseTime(List<SimulationTurn> turns) {
    if (turns.length < 2) return 0.0;
    
    double totalTime = 0;
    for (int i = 1; i < turns.length; i++) {
      totalTime += turns[i].timestamp.difference(turns[i - 1].timestamp).inMilliseconds;
    }
    
    return totalTime / (turns.length - 1) / 1000; // saniye cinsinden
  }
  
  /// Katılım skorunu hesapla
  double _calculateEngagementScore(List<SimulationTurn> turns) {
    if (turns.isEmpty) return 0.0;
    
    // Basit katılım hesaplaması
    final avgTurnLength = turns.map((t) => t.content.length).reduce((a, b) => a + b) / turns.length;
    final engagementScore = (avgTurnLength / 100).clamp(0.0, 1.0) * 100;
    
    return engagementScore;
  }
  
  /// Teknik kullanım skorunu hesapla
  double _calculateTechniqueScore(List<SimulationTurn> turns, TherapyApproach approach) {
    if (turns.isEmpty) return 0.0;
    
    int techniqueCount = 0;
    for (final turn in turns) {
      if (turn.role == RoleType.therapist) {
        final techniques = _extractTechniques(turn.content, approach);
        techniqueCount += techniques.length;
      }
    }
    
    return (techniqueCount / turns.length * 20).clamp(0.0, 100.0);
  }
  
  /// Empati skorunu hesapla
  double _calculateEmpathyScore(List<SimulationTurn> turns) {
    if (turns.isEmpty) return 0.0;
    
    int empathyIndicators = 0;
    final empathyWords = ['anlıyorum', 'hissediyorum', 'zor', 'yardım', 'destek'];
    
    for (final turn in turns) {
      if (turn.role == RoleType.therapist) {
        for (final word in empathyWords) {
          if (turn.content.toLowerCase().contains(word)) {
            empathyIndicators++;
            break;
          }
        }
      }
    }
    
    return (empathyIndicators / turns.length * 100).clamp(0.0, 100.0);
  }
  
  /// Güçlü yanları belirle
  List<String> _identifyStrengths(List<SimulationTurn> turns) {
    final strengths = <String>[];
    
    if (turns.isNotEmpty) {
      strengths.add('Aktif katılım');
      strengths.add('Tutarlı iletişim');
    }
    
    return strengths;
  }
  
  /// Gelişim alanlarını belirle
  List<String> _identifyAreasForImprovement(List<SimulationTurn> turns) {
    final areas = <String>[];
    
    if (turns.isNotEmpty) {
      areas.add('Teknik çeşitliliği artırılabilir');
      areas.add('Daha detaylı sorular sorulabilir');
    }
    
    return areas;
  }
  
  /// Detaylı metrikler oluştur
  Map<String, dynamic> _generateDetailedMetrics(List<SimulationTurn> turns) {
    return {
      'totalDuration': turns.isNotEmpty ? turns.last.timestamp.difference(turns.first.timestamp).inMinutes : 0,
      'responseVariety': turns.map((t) => t.content.length).toSet().length,
      'roleBalance': {
        'therapist': turns.where((t) => t.role == RoleType.therapist).length,
        'patient': turns.where((t) => t.role == RoleType.patient).length,
      }
    };
  }
  
  /// Mock metrikler oluştur
  SimulationMetrics _generateMockMetrics(String sessionId) {
    return SimulationMetrics(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      totalTurns: 8,
      userTurns: 4,
      aiTurns: 4,
      averageResponseTime: 15.5,
      engagementScore: 85.0,
      techniqueUsageScore: 78.0,
      empathyScore: 82.0,
      strengths: ['Aktif dinleme', 'Empatik yaklaşım'],
      areasForImprovement: ['Teknik çeşitliliği', 'Müdahale zamanlaması'],
      detailedMetrics: {'sessionQuality': 'high'},
      calculatedAt: DateTime.now(),
    );
  }
  
  /// Mock senaryolar oluştur
  List<SimulationScenario> _generateMockScenarios() {
    return [
      SimulationScenario(
        id: '1',
        title: 'Depresyon ile Başa Çıkma',
        description: 'Hafif depresyon belirtileri gösteren hasta ile CBT yaklaşımı',
        approach: TherapyApproach.cbt,
        difficulty: 'beginner',
        patientProfile: '25 yaşında, üniversite öğrencisi, son zamanlarda motivasyon kaybı yaşayan',
        scenarioDescription: 'Hasta ders çalışmaya odaklanamıyor ve sosyal aktivitelerden kaçınıyor',
        learningObjectives: ['Bilişsel çarpıtmaları tanıma', 'Davranış aktivasyonu teknikleri'],
        keyTechniques: ['Sokratik sorgulama', 'Günlük aktivite planlaması'],
        commonPitfalls: ['Çok hızlı ilerleme', 'Duyguları görmezden gelme'],
        initialContext: {'mood': 'low', 'energy': 'low'},
        metadata: {},
        createdAt: DateTime.now(),
        isActive: true,
      ),
      SimulationScenario(
        id: '2',
        title: 'Anksiyete Yönetimi',
        description: 'Sosyal anksiyete yaşayan hasta ile DBT yaklaşımı',
        approach: TherapyApproach.dbt,
        difficulty: 'intermediate',
        patientProfile: '30 yaşında, iş hayatında sosyal durumlardan kaçınan',
        scenarioDescription: 'Toplantılarda konuşma yaparken aşırı kaygı yaşayan hasta',
        learningObjectives: ['Farkındalık teknikleri', 'Duygu düzenleme stratejileri'],
        keyTechniques: ['Nefes egzersizleri', 'Radikal kabul'],
        commonPitfalls: ['Kaçınma davranışını pekiştirme', 'Hızlı çözüm arama'],
        initialContext: {'anxiety_level': 'high', 'avoidance': 'high'},
        metadata: {},
        createdAt: DateTime.now(),
        isActive: true,
      ),
    ];
  }
  
  /// Senaryoları getir
  List<SimulationScenario> getScenarios() {
    return List.unmodifiable(_scenariosCache);
  }
  
  /// Seansı getir
  TherapySimulationSession? getSession(String sessionId) {
    return _sessionsCache[sessionId];
  }
  
  /// Seansları getir
  List<TherapySimulationSession> getSessions() {
    return List.unmodifiable(_sessionsCache.values);
  }
  
  /// Turn'leri getir
  List<SimulationTurn> getTurns(String sessionId) {
    return List.unmodifiable(_turnsCache[sessionId] ?? []);
  }
  
  /// Metrikleri getir
  SimulationMetrics? getMetrics(String sessionId) {
    return _metricsCache[sessionId];
  }
  
  /// Servisi temizle
  void dispose() {
    _sessionController.close();
    _turnController.close();
    _metricsController.close();
  }
}
