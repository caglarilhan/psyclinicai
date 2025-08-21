import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/ai_config.dart';
import '../config/env_config.dart';
import '../models/ai_response_models.dart';
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
}
