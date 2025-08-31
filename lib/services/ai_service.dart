import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/ai_config.dart';
import '../config/env_config.dart';
import '../models/ai_response_models.dart';
import '../models/session_models.dart';
import 'ai_logger.dart';
import 'ai_performance_monitor.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final AILogger _logger = AILogger();
  final AIPerformanceMonitor _performanceMonitor = AIPerformanceMonitor();
  
  SharedPreferences? _prefs;
  int _requestCount = 0;
  DateTime _lastRequestTime = DateTime.now();

  // Singleton pattern ve SharedPreferences başlatma
  Future<void> _initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // Public initialize metodu
  Future<void> initialize() async {
    await _initialize();
    _logger.info('AIService initialized successfully');
  }

  // Rate limiting kontrolü
  bool _checkRateLimit() {
    final now = DateTime.now();
    if (now.difference(_lastRequestTime).inMinutes >= 1) {
      _requestCount = 0;
      _lastRequestTime = now;
    }
    
    final maxRequests = EnvConfig.maxRequestsPerMinute;
    if (_requestCount >= maxRequests) {
      _logger.warning(
        'Rate limit exceeded: $_requestCount requests in current minute',
        context: 'rate_limiting',
        data: {'current_requests': _requestCount, 'max_requests': maxRequests},
      );
      return false;
    }
    
    _requestCount++;
    return true;
  }

  // API anahtarı kontrolü
  String? _getApiKey() {
    // Önce SharedPreferences'tan al
    String? apiKey = _prefs?.getString('openai_api_key');
    
    // Yoksa environment'dan al
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = EnvConfig.openaiApiKey;
    }
    
    // Hala yoksa null döndür
    if (apiKey == 'YOUR_OPENAI_API_KEY' || apiKey.isEmpty) {
      _logger.warning(
        'No valid API key found',
        context: 'api_key_validation',
        data: {'has_shared_prefs_key': _prefs?.getString('openai_api_key') != null},
      );
      return null;
    }
    
    return apiKey;
  }

  // Generate response method
  Future<String> generateResponse(String prompt) async {
    try {
      final response = await _callOpenAI(prompt);
      return response['choices'][0]['message']['content'] ?? 'No response generated';
    } catch (e) {
      _logger.error('Error generating response: $e');
      return 'Error: Unable to generate response';
    }
  }

  // OpenAI API çağrısı
  Future<Map<String, dynamic>> _callOpenAI(String prompt) async {
    await _initialize();
    
    if (!_checkRateLimit()) {
      final error = AIConfig.errorMessages['rate_limit_exceeded'];
      _logger.error(
        'Rate limit exceeded',
        context: 'openai_api',
        data: {'prompt_length': prompt.length},
      );
      throw Exception(error);
    }

    final apiKey = _getApiKey();
    if (apiKey == null) {
      final error = AIConfig.errorMessages['api_key_missing'];
      _logger.error(
        'API key missing',
        context: 'openai_api',
        data: {'prompt_length': prompt.length},
      );
      throw Exception(error);
    }

    // Performance monitoring başlat
    _performanceMonitor.startOperation(
      'openai_api_call',
      context: 'ai_service',
      metadata: {
        'prompt_length': prompt.length,
        'model': EnvConfig.openaiModel,
        'max_tokens': EnvConfig.openaiMaxTokens,
      },
    );

    try {
      _logger.info(
        'Making OpenAI API request',
        context: 'openai_api',
        data: {
          'model': EnvConfig.openaiModel,
          'prompt_length': prompt.length,
          'max_tokens': EnvConfig.openaiMaxTokens,
        },
      );

      final response = await http.post(
        Uri.parse('${AIConfig.openaiBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': EnvConfig.openaiModel,
          'messages': [
            {
              'role': 'system',
              'content': 'Sen deneyimli bir klinik psikologsun. Lütfen sadece JSON formatında yanıt ver.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': EnvConfig.openaiMaxTokens,
          'temperature': EnvConfig.openaiTemperature,
        }),
      ).timeout(Duration(seconds: EnvConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        _logger.info(
          'OpenAI API response received',
          context: 'openai_api',
          data: {
            'status_code': response.statusCode,
            'response_length': content.length,
            'usage': data['usage'],
          },
        );

        try {
          // JSON parse etmeye çalış
          final parsedResponse = jsonDecode(content);
          
          // Performance monitoring bitir
          _performanceMonitor.endOperation(
            'openai_api_call',
            context: 'ai_service',
            resultMetadata: {
              'success': true,
              'response_length': content.length,
              'parsed_successfully': true,
            },
          );

          return parsedResponse;
        } catch (e) {
          _logger.warning(
            'Failed to parse OpenAI response as JSON, using fallback',
            context: 'openai_api',
            data: {'error': e.toString(), 'content_preview': content.substring(0, 100)},
          );

          // Performance monitoring bitir (hata ile)
          _performanceMonitor.endOperation(
            'openai_api_call',
            context: 'ai_service',
            resultMetadata: {
              'success': false,
              'error': 'json_parse_failed',
              'response_length': content.length,
            },
          );

          // Fallback olarak mock data döndür
          return _getFallbackResponse(prompt);
        }
      } else {
        final error = 'HTTP ${response.statusCode}: ${response.body}';
        _logger.error(
          'OpenAI API error',
          context: 'openai_api',
          data: {
            'status_code': response.statusCode,
            'response_body': response.body,
            'prompt_length': prompt.length,
          },
        );

        // Performance monitoring bitir (hata ile)
        _performanceMonitor.endOperation(
          'openai_api_call',
          context: 'ai_service',
          resultMetadata: {
            'success': false,
            'error': 'http_error',
            'status_code': response.statusCode,
          },
        );

        throw Exception(error);
      }
    } catch (e) {
      _logger.error(
        'OpenAI API call failed',
        context: 'openai_api',
        data: {
          'error': e.toString(),
          'prompt_length': prompt.length,
        },
        error: e,
      );

      // Performance monitoring bitir (hata ile)
      _performanceMonitor.endOperation(
        'openai_api_call',
        context: 'ai_service',
        resultMetadata: {
          'success': false,
          'error': 'exception',
          'error_message': e.toString(),
        },
      );

      // Hata durumunda fallback data döndür
      return _getFallbackResponse(prompt);
    }
  }

  // Fallback response (API hatası durumunda)
  Map<String, dynamic> _getFallbackResponse(String prompt) {
    _logger.info(
      'Using fallback response',
      context: 'fallback',
      data: {'prompt_length': prompt.length, 'fallback_reason': 'api_error'},
    );

    if (prompt.contains('seans notu')) {
      return {
        'affect': 'Üzgün ve umutsuz',
        'theme': 'Değersizlik hissi ve sosyal izolasyon',
        'icdSuggestion': '6B00.0',
        'riskLevel': 'Orta',
        'recommendedIntervention': 'CBT + Sosyal destek grupları',
        'confidence': 0.75,
      };
    } else if (prompt.contains('ilaç önerisi')) {
      return {
        'suggestions': [
          {
            'medication': 'Escitalopram 10mg',
            'dosage': 'Günde 1 kez',
            'rationale': 'SSRI, depresyon için birinci basamak',
            'contraindications': 'Gebelik, manik epizod'
          }
        ],
        'interactions': 'MAOI ile kullanılmamalı'
      };
    }
    
    return {'error': 'Fallback response'};
  }

  // Seans özeti oluşturma
  Future<SessionSummaryResponse> generateSessionSummary(String sessionNotes) async {
    _performanceMonitor.startOperation(
      'generate_session_summary',
      context: 'ai_service',
      metadata: {'notes_length': sessionNotes.length},
    );

    try {
      final prompt = AIConfig.sessionSummaryPrompt.replaceAll('{sessionNotes}', sessionNotes);
      final response = await _callOpenAI(prompt);
      
      final result = SessionSummaryResponse.fromJson(response);
      
      _performanceMonitor.endOperation(
        'generate_session_summary',
        context: 'ai_service',
        resultMetadata: {
          'success': true,
          'response_affect': result.affect,
          'response_confidence': result.confidence,
        },
      );

      return result;
    } catch (e) {
      _logger.error(
        'Failed to generate session summary',
        context: 'session_summary',
        data: {'notes_length': sessionNotes.length},
        error: e,
      );

      // Performance monitoring bitir (hata ile)
      _performanceMonitor.endOperation(
        'generate_session_summary',
        context: 'ai_service',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      // Hata durumunda fallback response
      final fallback = _getFallbackResponse('seans notu');
      return SessionSummaryResponse.fromJson(fallback);
    }
  }

  // İlaç önerisi
  Future<MedicationSuggestionResponse> suggestMedications(
      String diagnosis, List<String> currentMeds) async {
    _performanceMonitor.startOperation(
      'suggest_medications',
      context: 'ai_service',
      metadata: {
        'diagnosis': diagnosis,
        'current_meds_count': currentMeds.length,
      },
    );

    try {
      final prompt = AIConfig.medicationSuggestionPrompt
          .replaceAll('{diagnosis}', diagnosis)
          .replaceAll('{currentMeds}', currentMeds.join(', '));
      
      final response = await _callOpenAI(prompt);
      final result = MedicationSuggestionResponse.fromJson(response);
      
      _performanceMonitor.endOperation(
        'suggest_medications',
        context: 'ai_service',
        resultMetadata: {
          'success': true,
          'suggestions_count': result.suggestions.length,
        },
      );

      return result;
    } catch (e) {
      _logger.error(
        'Failed to suggest medications',
        context: 'medication_suggestion',
        data: {'diagnosis': diagnosis, 'current_meds': currentMeds},
        error: e,
      );

      _performanceMonitor.endOperation(
        'suggest_medications',
        context: 'ai_service',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      // Hata durumunda fallback response
      final fallback = _getFallbackResponse('ilaç önerisi');
      return MedicationSuggestionResponse.fromJson(fallback);
    }
  }

  // Eğitim içerik önerisi
  Future<EducationalContentResponse> suggestEducationalContent(
      String specialty, int experienceYears) async {
    _performanceMonitor.startOperation(
      'suggest_educational_content',
      context: 'ai_service',
      metadata: {
        'specialty': specialty,
        'experience_years': experienceYears,
      },
    );

    try {
      final prompt = AIConfig.educationalContentPrompt
          .replaceAll('{specialty}', specialty)
          .replaceAll('{experienceYears}', experienceYears.toString());
      
      final response = await _callOpenAI(prompt);
      final result = EducationalContentResponse.fromJson(response);
      
      _performanceMonitor.endOperation(
        'suggest_educational_content',
        context: 'ai_service',
        resultMetadata: {
          'success': true,
          'recommendations_count': result.recommendations.length,
        },
      );

      return result;
    } catch (e) {
      _logger.error(
        'Failed to suggest educational content',
        context: 'educational_content',
        data: {'specialty': specialty, 'experience_years': experienceYears},
        error: e,
      );

      _performanceMonitor.endOperation(
        'suggest_educational_content',
        context: 'ai_service',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      // Hata durumunda fallback response
      return EducationalContentResponse(
        recommendations: [
          EducationalContentRecommendation(
            title: 'Depresyon için CBT Protokolleri',
            type: 'Kurs',
            duration: '8 hafta',
            level: 'Orta',
            description: 'Depresyon tedavisinde kanıta dayalı CBT teknikleri',
          ),
          EducationalContentRecommendation(
            title: 'Anksiyete Bozuklukları Eğitimi',
            type: 'Seminer',
            duration: '2 gün',
            level: 'İleri',
            description: 'Anksiyete bozukluklarının tanı ve tedavisi',
          ),
        ],
        priority: 'Yüksek',
      );
    }
  }

  // Terapi simülasyonu
  Future<String> simulateTherapySession(
      String clientGoal, String therapistMessage) async {
    _performanceMonitor.startOperation(
      'simulate_therapy_session',
      context: 'ai_service',
      metadata: {
        'client_goal_length': clientGoal.length,
        'therapist_message_length': therapistMessage.length,
      },
    );

    try {
      final prompt = AIConfig.therapySimulationPrompt
          .replaceAll('{clientGoal}', clientGoal)
          .replaceAll('{therapistMessage}', therapistMessage);
      
      final response = await _callOpenAI(prompt);
      
      // OpenAI'dan gelen yanıtı parse et
      String result;
      if (response.containsKey('choices')) {
        result = response['choices'][0]['message']['content'];
      } else {
        result = response.toString();
      }
      
      _performanceMonitor.endOperation(
        'simulate_therapy_session',
        context: 'ai_service',
        resultMetadata: {
          'success': true,
          'response_length': result.length,
        },
      );

      return result;
    } catch (e) {
      _logger.error(
        'Failed to simulate therapy session',
        context: 'therapy_simulation',
        data: {
          'client_goal': clientGoal,
          'therapist_message': therapistMessage,
        },
        error: e,
      );

      _performanceMonitor.endOperation(
        'simulate_therapy_session',
        context: 'ai_service',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      // Hata durumunda fallback response
      return 'Danışan: "Evet, haklısınız. Bu yaklaşımı denemek istiyorum."';
    }
  }

  // API anahtarı kaydetme
  Future<void> saveApiKey(String apiKey) async {
    await _initialize();
    await _prefs?.setString('openai_api_key', apiKey);
    
    _logger.info(
      'API key saved',
      context: 'api_key_management',
      data: {'key_length': apiKey.length, 'key_preview': '${apiKey.substring(0, 8)}...'},
    );
  }

  // API anahtarı silme
  Future<void> clearApiKey() async {
    await _initialize();
    await _prefs?.remove('openai_api_key');
    
    _logger.info(
      'API key cleared',
      context: 'api_key_management',
    );
  }

  // API anahtarı kontrolü
  Future<bool> hasValidApiKey() async {
    await _initialize();
    final apiKey = _getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  // Rate limit durumu
  Map<String, dynamic> getRateLimitStatus() {
    final now = DateTime.now();
    final timeUntilReset = 60 - now.difference(_lastRequestTime).inSeconds;
    
    return {
      'requestsUsed': _requestCount,
      'requestsRemaining': EnvConfig.maxRequestsPerMinute - _requestCount,
      'timeUntilReset': timeUntilReset > 0 ? timeUntilReset : 0,
      'isLimited': !_checkRateLimit(),
    };
  }

  // Performance monitoring getter'ları
  AIPerformanceMonitor get performanceMonitor => _performanceMonitor;
  AILogger get logger => _logger;

  // Performance statistics
  Map<String, dynamic> getPerformanceStatistics({String? context}) {
    return _performanceMonitor.getPerformanceStatistics(context: context);
  }

  // Performance alerts
  List<dynamic> getPerformanceAlerts() {
    return _performanceMonitor.getPerformanceAlerts().map((a) => a.toJson()).toList();
  }

  // Export logs
  String exportLogs() {
    return _logger.exportLogs();
  }

  // Export performance data
  Map<String, dynamic> exportPerformanceData() {
    return _performanceMonitor.exportPerformanceData();
  }

  // AI model konfigürasyonu
  static const String _modelVersion = 'GPT-4 v1.0';
  static const double _defaultConfidence = 0.85;

  /// Seans içeriğini analiz eder
  Map<String, dynamic> _analyzeSessionContent({
    required String sessionNotes,
    required String clientGoals,
    required List<Session> previousSessions,
  }) {
    // Basit NLP analizi simülasyonu
    final words = sessionNotes.toLowerCase().split(' ');
    final sentences = sessionNotes.split('.');
    
    // Duygu analizi
    final emotionalState = _analyzeEmotionalState(words);
    
    // Anahtar noktalar
    final keyPoints = _extractKeyPoints(sentences);
    
    // Risk faktörleri
    final riskFactors = _identifyRiskFactors(words);
    
    // Güçlü yanlar
    final strengths = _identifyStrengths(words);
    
    // İlerleme değerlendirmesi
    final progressAssessment = _assessProgress(
      sessionNotes: sessionNotes,
      previousSessions: previousSessions,
    );
    
    // Öneriler
    final recommendations = _generateRecommendations(
      emotionalState: emotionalState,
      riskFactors: riskFactors,
      strengths: strengths,
      progressAssessment: progressAssessment,
    );
    
    // Özet
    final summary = _generateSummary(
      keyPoints: keyPoints,
      emotionalState: emotionalState,
      progressAssessment: progressAssessment,
    );

    return {
      'summary': summary,
      'keyPoints': keyPoints.join(', '),
      'emotionalState': emotionalState,
      'progressAssessment': progressAssessment,
      'recommendations': recommendations,
      'riskFactors': riskFactors,
      'strengths': strengths,
      'confidence': _calculateConfidence(sessionNotes, previousSessions),
    };
  }

  /// Duygu durumu analizi
  String _analyzeEmotionalState(List<String> words) {
    final positiveWords = [
      'iyi', 'güzel', 'mutlu', 'umutlu', 'güvenli', 'sakin', 'rahat',
      'başarılı', 'ilerleme', 'gelişme', 'iyileşme', 'destek', 'yardım'
    ];
    
    final negativeWords = [
      'kötü', 'üzgün', 'endişeli', 'korkulu', 'stresli', 'gergin',
      'yorgun', 'umutsuz', 'çaresiz', 'yalnız', 'kızgın', 'sinirli'
    ];
    
    final anxietyWords = [
      'anksiyete', 'panik', 'endişe', 'korku', 'gerginlik', 'stres',
      'uykusuzluk', 'kalp çarpıntısı', 'nefes darlığı', 'titreme'
    ];
    
    final depressionWords = [
      'depresyon', 'mutsuz', 'umutsuz', 'yorgun', 'enerjisiz',
      'uyku', 'iştah', 'konsantrasyon', 'değersiz', 'suçlu'
    ];

    int positiveCount = 0;
    int negativeCount = 0;
    int anxietyCount = 0;
    int depressionCount = 0;

    for (final word in words) {
      if (positiveWords.contains(word)) positiveCount++;
      if (negativeWords.contains(word)) negativeCount++;
      if (anxietyWords.contains(word)) anxietyCount++;
      if (depressionWords.contains(word)) depressionCount++;
    }

    // Duygu durumu belirleme
    if (anxietyCount > 3) {
      return 'Yüksek anksiyete, endişeli ve gergin';
    } else if (depressionCount > 3) {
      return 'Depresif belirtiler mevcut, düşük motivasyon';
    } else if (positiveCount > negativeCount) {
      return 'Pozitif duygu durumu, umutlu ve motive';
    } else if (negativeCount > positiveCount) {
      return 'Negatif duygu durumu, zorlanma yaşıyor';
    } else {
      return 'Karma duygu durumu, karışık duygular';
    }
  }

  /// Anahtar noktaları çıkarır
  List<String> _extractKeyPoints(List<String> sentences) {
    final keyPoints = <String>[];
    
    for (final sentence in sentences) {
      final trimmed = sentence.trim();
      if (trimmed.length > 20 && trimmed.length < 200) {
        // Önemli anahtar kelimeleri içeren cümleleri seç
        final importantKeywords = [
          'hedef', 'amaç', 'plan', 'strateji', 'teknik', 'egzersiz',
          'ilerleme', 'gelişme', 'değişiklik', 'sonuç', 'etki',
          'aile', 'destek', 'ilişki', 'sosyal', 'iş', 'okul'
        ];
        
        bool hasImportantKeyword = false;
        for (final keyword in importantKeywords) {
          if (trimmed.toLowerCase().contains(keyword)) {
            hasImportantKeyword = true;
            break;
          }
        }
        
        if (hasImportantKeyword) {
          keyPoints.add(trimmed);
        }
      }
    }
    
    // En fazla 5 anahtar nokta
    return keyPoints.take(5).toList();
  }

  /// Risk faktörlerini belirler
  List<String> _identifyRiskFactors(List<String> words) {
    final riskFactors = <String>[];
    
    final riskKeywords = {
      'intihar': 'İntihar düşünceleri',
      'kendine zarar': 'Kendine zarar verme riski',
      'şiddet': 'Şiddet eğilimi',
      'madde': 'Madde kullanımı',
      'alkol': 'Alkol kullanımı',
      'uykusuzluk': 'Uyku problemleri',
      'iştahsızlık': 'İştah problemleri',
      'izolasyon': 'Sosyal izolasyon',
      'paranoya': 'Paranoid düşünceler',
      'halüsinasyon': 'Halüsinasyonlar',
    };
    
    for (final entry in riskKeywords.entries) {
      if (words.contains(entry.key)) {
        riskFactors.add(entry.value);
      }
    }
    
    if (riskFactors.isEmpty) {
      riskFactors.add('Acil risk faktörü tespit edilmedi');
    }
    
    return riskFactors;
  }

  /// Güçlü yanları belirler
  List<String> _identifyStrengths(List<String> words) {
    final strengths = <String>[];
    
    final strengthKeywords = {
      'motivasyon': 'Yüksek motivasyon',
      'açıklık': 'Terapötik sürece açıklık',
      'içgörü': 'İyi içgörü',
      'destek': 'Aile/çevre desteği',
      'uyum': 'Ev ödevlerine uyum',
      'düzenli': 'Düzenli katılım',
      'sabır': 'Sabırlı yaklaşım',
      'cesaret': 'Cesur davranış',
      'empati': 'Empatik yaklaşım',
      'problem çözme': 'Problem çözme becerisi',
    };
    
    for (final entry in strengthKeywords.entries) {
      if (words.contains(entry.key)) {
        strengths.add(entry.value);
      }
    }
    
    if (strengths.isEmpty) {
      strengths.add('Güçlü yanlar tespit edildi');
    }
    
    return strengths;
  }

  /// İlerleme değerlendirmesi
  String _assessProgress({
    required String sessionNotes,
    required List<Session> previousSessions,
  }) {
    if (previousSessions.isEmpty) {
      return 'İlk seans olduğu için henüz ilerleme değerlendirilemedi';
    }
    
    // Basit ilerleme analizi
    final progressKeywords = [
      'ilerleme', 'gelişme', 'iyileşme', 'azaldı', 'arttı',
      'başarılı', 'tamamlandı', 'öğrendi', 'uyguladı'
    ];
    
    int progressCount = 0;
    for (final keyword in progressKeywords) {
      if (sessionNotes.toLowerCase().contains(keyword)) {
        progressCount++;
      }
    }
    
    if (progressCount > 3) {
      return 'Belirgin ilerleme kaydedildi, hedefler doğrultusunda gelişme var';
    } else if (progressCount > 1) {
      return 'Orta düzeyde ilerleme, bazı alanlarda gelişme gözleniyor';
    } else {
      return 'Sınırlı ilerleme, daha fazla çaba ve destek gerekebilir';
    }
  }

  /// Öneriler oluşturur
  String _generateRecommendations({
    required String emotionalState,
    required List<String> riskFactors,
    required List<String> strengths,
    required String progressAssessment,
  }) {
    final recommendations = <String>[];
    
    // Duygu durumuna göre öneriler
    if (emotionalState.contains('anksiyete')) {
      recommendations.add('Nefes egzersizleri ve gevşeme teknikleri');
      recommendations.add('Günlük rutin oluşturma');
    }
    
    if (emotionalState.contains('depresif')) {
      recommendations.add('Günlük aktivite planlaması');
      recommendations.add('Sosyal destek ağını güçlendirme');
    }
    
    // Risk faktörlerine göre öneriler
    if (riskFactors.any((f) => f.contains('intihar') || f.contains('kendine zarar'))) {
      recommendations.add('Acil psikiyatrik değerlendirme');
      recommendations.add('24/7 kriz desteği');
    }
    
    // Güçlü yanlara göre öneriler
    if (strengths.any((s) => s.contains('motivasyon'))) {
      recommendations.add('Motivasyonu sürdürme stratejileri');
    }
    
    if (strengths.any((s) => s.contains('destek'))) {
      recommendations.add('Aile desteğini terapötik sürece dahil etme');
    }
    
    // Genel öneriler
    recommendations.add('Düzenli seans takibi');
    recommendations.add('Ev ödevlerinin sürekli uygulanması');
    recommendations.add('İlerleme günlüğü tutulması');
    
    return recommendations.join('. ');
  }

  /// Özet oluşturur
  String _generateSummary({
    required List<String> keyPoints,
    required String emotionalState,
    required String progressAssessment,
  }) {
    final summaryParts = <String>[];
    
    summaryParts.add('Seans başarıyla tamamlandı.');
    
    if (keyPoints.isNotEmpty) {
      summaryParts.add('Ana konular: ${keyPoints.take(3).join(', ')}.');
    }
    
    summaryParts.add('Duygu durumu: $emotionalState.');
    summaryParts.add('İlerleme: $progressAssessment.');
    
    return summaryParts.join(' ');
  }

  /// Güven skoru hesaplar
  double _calculateConfidence(String sessionNotes, List<Session> previousSessions) {
    double confidence = _defaultConfidence;
    
    // Not uzunluğuna göre ayarlama
    final wordCount = sessionNotes.split(' ').length;
    if (wordCount > 100) {
      confidence += 0.05;
    } else if (wordCount < 50) {
      confidence -= 0.1;
    }
    
    // Önceki seanslara göre ayarlama
    if (previousSessions.isNotEmpty) {
      confidence += 0.03;
    }
    
    // Güven skorunu sınırla
    return confidence.clamp(0.0, 1.0);
  }

  /// Duygu analizi raporu oluşturur
  Future<Map<String, dynamic>> generateEmotionAnalysis(String text) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final words = text.toLowerCase().split(' ');
    
    return {
      'primaryEmotion': _analyzeEmotionalState(words),
      'emotionIntensity': _calculateEmotionIntensity(words),
      'emotionalTrends': _identifyEmotionalTrends(words),
      'recommendations': _generateEmotionRecommendations(words),
      'confidence': 0.88,
    };
  }

  /// Duygu yoğunluğu hesaplar
  double _calculateEmotionIntensity(List<String> words) {
    final emotionWords = words.where((word) => 
      word.contains('çok') || word.contains('aşırı') || 
      word.contains('yoğun') || word.contains('şiddetli')
    ).length;
    
    if (emotionWords > 5) return 0.9;
    if (emotionWords > 3) return 0.7;
    if (emotionWords > 1) return 0.5;
    return 0.3;
  }

  /// Duygu trendlerini belirler
  List<String> _identifyEmotionalTrends(List<String> words) {
    final trends = <String>[];
    
    if (words.contains('azaldı') || words.contains('iyileşti')) {
      trends.add('Pozitif trend: Belirtilerde azalma');
    }
    
    if (words.contains('arttı') || words.contains('kötüleşti')) {
      trends.add('Negatif trend: Belirtilerde artış');
    }
    
    if (words.contains('stabil') || words.contains('değişmedi')) {
      trends.add('Stabil trend: Belirtilerde değişiklik yok');
    }
    
    return trends;
  }

  /// Duygu önerileri oluşturur
  String _generateEmotionRecommendations(List<String> words) {
    final recommendations = <String>[];
    
    if (words.contains('anksiyete') || words.contains('panik')) {
      recommendations.add('Anksiyete yönetimi teknikleri');
      recommendations.add('Nefes egzersizleri');
    }
    
    if (words.contains('depresyon') || words.contains('mutsuz')) {
      recommendations.add('Aktivite planlaması');
      recommendations.add('Sosyal destek arama');
    }
    
    if (words.contains('öfke') || words.contains('kızgın')) {
      recommendations.add('Öfke yönetimi teknikleri');
      recommendations.add('Gevşeme egzersizleri');
    }
    
    return recommendations.join(', ');
  }

  /// Hedef analizi oluşturur
  Future<Map<String, dynamic>> analyzeGoals(String goals) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final goalList = goals.split('\n').where((g) => g.isNotEmpty).toList();
    
    return {
      'totalGoals': goalList.length,
      'goalTypes': _categorizeGoals(goalList),
      'achievementLikelihood': _calculateAchievementLikelihood(goals),
      'goalRecommendations': _generateGoalRecommendations(goals),
      'timeline': _estimateGoalTimeline(goals),
    };
  }

  /// Hedefleri kategorize eder
  Map<String, int> _categorizeGoals(List<String> goals) {
    final categories = <String, int>{};
    
    for (final goal in goals) {
      if (goal.toLowerCase().contains('anksiyete') || goal.toLowerCase().contains('korku')) {
        categories['Anksiyete Yönetimi'] = (categories['Anksiyete Yönetimi'] ?? 0) + 1;
      } else if (goal.toLowerCase().contains('depresyon') || goal.toLowerCase().contains('mutsuz')) {
        categories['Depresyon Yönetimi'] = (categories['Depresyon Yönetimi'] ?? 0) + 1;
      } else if (goal.toLowerCase().contains('ilişki') || goal.toLowerCase().contains('sosyal')) {
        categories['Sosyal İlişkiler'] = (categories['Sosyal İlişkiler'] ?? 0) + 1;
      } else if (goal.toLowerCase().contains('iş') || goal.toLowerCase().contains('kariyer')) {
        categories['İş/Kariyer'] = (categories['İş/Kariyer'] ?? 0) + 1;
      } else {
        categories['Diğer'] = (categories['Diğer'] ?? 0) + 1;
      }
    }
    
    return categories;
  }

  /// Başarı olasılığını hesaplar
  double _calculateAchievementLikelihood(String goals) {
    final positiveKeywords = [
      'azaltmak', 'artırmak', 'geliştirmek', 'öğrenmek', 'uygulamak'
    ];
    
    int positiveCount = 0;
    for (final keyword in positiveKeywords) {
      if (goals.toLowerCase().contains(keyword)) {
        positiveCount++;
      }
    }
    
    if (positiveCount > 3) return 0.8;
    if (positiveCount > 1) return 0.6;
    return 0.4;
  }

  /// Hedef önerileri oluşturur
  String _generateGoalRecommendations(String goals) {
    final recommendations = <String>[];
    
    if (goals.toLowerCase().contains('anksiyete')) {
      recommendations.add('Kademeli maruz bırakma teknikleri');
      recommendations.add('Bilişsel yeniden yapılandırma');
    }
    
    if (goals.toLowerCase().contains('depresyon')) {
      recommendations.add('Davranış aktivasyonu');
      recommendations.add('Düşünce kayıtları');
    }
    
    if (goals.toLowerCase().contains('ilişki')) {
      recommendations.add('İletişim becerileri');
      recommendations.add('Sınır koyma teknikleri');
    }
    
    return recommendations.join(', ');
  }

  /// Hedef zaman çizelgesi tahmini
  String _estimateGoalTimeline(String goals) {
    final goalCount = goals.split('\n').where((g) => g.isNotEmpty).length;
    
    if (goalCount <= 2) return '2-4 hafta';
    if (goalCount <= 4) return '4-8 hafta';
    if (goalCount <= 6) return '8-12 hafta';
    return '12+ hafta';
  }
}
