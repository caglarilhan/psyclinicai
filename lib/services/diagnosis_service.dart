import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/ai_config.dart';
import '../config/env_config.dart';
import '../models/diagnosis_models.dart';
import 'ai_logger.dart';
import 'ai_performance_monitor.dart';

class DiagnosisService {
  static final DiagnosisService _instance = DiagnosisService._internal();
  factory DiagnosisService() => _instance;
  DiagnosisService._internal();

  final AILogger _logger = AILogger();
  final AIPerformanceMonitor _performanceMonitor = AIPerformanceMonitor();
  
  SharedPreferences? _prefs;
  
  // ICD-11 ve DSM-5 veritabanları (mock data - gerçek implementasyonda API'den gelecek)
  static const Map<String, Map<String, dynamic>> _icd11Database = {
    '6A70': {
      'code': '6A70',
      'title': 'Depressive disorder',
      'description': 'A mood disorder characterized by persistent sadness and loss of interest',
      'translations': {
        'tr': 'Depresif bozukluk',
        'de': 'Depressive Störung',
        'fr': 'Trouble dépressif'
      },
      'symptoms': ['Persistent sadness', 'Loss of interest', 'Fatigue', 'Sleep problems'],
      'severity': 'Moderate',
      'category': 'Mood disorders',
      'subcategory': 'Depressive disorders'
    },
    '6B00': {
      'code': '6B00',
      'title': 'Generalized anxiety disorder',
      'description': 'Excessive anxiety and worry about various aspects of life',
      'translations': {
        'tr': 'Yaygın anksiyete bozukluğu',
        'de': 'Generalisierte Angststörung',
        'fr': 'Trouble d\'anxiété généralisée'
      },
      'symptoms': ['Excessive worry', 'Restlessness', 'Difficulty concentrating', 'Muscle tension'],
      'severity': 'Moderate',
      'category': 'Anxiety disorders',
      'subcategory': 'Generalized anxiety disorders'
    }
  };

  static const Map<String, Map<String, dynamic>> _dsm5Database = {
    'F32.1': {
      'code': 'F32.1',
      'title': 'Major Depressive Disorder, Moderate',
      'description': 'Depressive disorder with moderate symptom severity',
      'criteria': [
        'Depressed mood most of the day',
        'Markedly diminished interest in activities',
        'Significant weight loss or gain',
        'Insomnia or hypersomnia'
      ],
      'symptoms': ['Depressed mood', 'Loss of interest', 'Weight changes', 'Sleep disturbances'],
      'severity': 'Moderate',
      'category': 'Depressive Disorders',
      'subcategory': 'Major Depressive Disorder'
    }
  };

  // Singleton pattern ve SharedPreferences başlatma
  Future<void> _initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // ICD-11 tanı arama
  Future<List<ICD11Diagnosis>> searchICD11({
    String? query,
    String? category,
    String? subcategory,
    String language = 'en',
    int maxResults = 50,
  }) async {
    _performanceMonitor.startOperation(
      'search_icd11',
      context: 'diagnosis_service',
      metadata: {
        'query': query,
        'category': category,
        'language': language,
        'max_results': maxResults,
      },
    );

    try {
      _logger.info(
        'Searching ICD-11 diagnoses',
        context: 'diagnosis_service',
        data: {'query': query, 'language': language},
      );

      // Mock search implementation - gerçek implementasyonda API'den gelecek
      List<ICD11Diagnosis> results = [];
      
      for (final entry in _icd11Database.entries) {
        final data = entry.value;
        
        // Query filter
        if (query != null && query.isNotEmpty) {
          final searchText = '${data['title']} ${data['description']}'.toLowerCase();
          if (!searchText.contains(query.toLowerCase())) continue;
        }
        
        // Category filter
        if (category != null && data['category'] != category) continue;
        
        // Subcategory filter
        if (subcategory != null && data['subcategory'] != subcategory) continue;
        
        // Create ICD11Diagnosis object
        final diagnosis = ICD11Diagnosis(
          code: data['code'],
          title: data['translations'][language] ?? data['title'],
          description: data['description'],
          translations: Map<String, String>.from(data['translations']),
          keywords: [],
          synonyms: [],
          inclusionCriteria: [],
          exclusionCriteria: [],
          relatedConditions: [],
          symptoms: List<String>.from(data['symptoms']),
          riskFactors: [],
          complications: [],
          severity: data['severity'],
          chronicity: 'Unknown',
          category: data['category'],
          subcategory: data['subcategory'],
          treatmentOptions: [],
          medications: [],
          therapies: [],
          metadata: {},
          isActive: true,
          lastUpdated: DateTime.now(),
        );
        
        results.add(diagnosis);
        
        if (results.length >= maxResults) break;
      }

      _performanceMonitor.endOperation(
        'search_icd11',
        context: 'diagnosis_service',
        resultMetadata: {
          'success': true,
          'results_count': results.length,
        },
      );

      return results;
    } catch (e) {
      _logger.error(
        'Failed to search ICD-11 diagnoses',
        context: 'diagnosis_service',
        data: {'query': query, 'error': e.toString()},
        error: e,
      );

      _performanceMonitor.endOperation(
        'search_icd11',
        context: 'diagnosis_service',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      return [];
    }
  }

  // DSM-5 tanı arama
  Future<List<DSM5Diagnosis>> searchDSM5({
    String? query,
    String? category,
    String? subcategory,
    String language = 'en',
    int maxResults = 50,
  }) async {
    _performanceMonitor.startOperation(
      'search_dsm5',
      context: 'diagnosis_service',
      metadata: {
        'query': query,
        'category': category,
        'language': language,
        'max_results': maxResults,
      },
    );

    try {
      _logger.info(
        'Searching DSM-5 diagnoses',
        context: 'diagnosis_service',
        data: {'query': query, 'language': language},
      );

      // Mock search implementation
      List<DSM5Diagnosis> results = [];
      
      for (final entry in _dsm5Database.entries) {
        final data = entry.value;
        
        // Query filter
        if (query != null && query.isNotEmpty) {
          final searchText = '${data['title']} ${data['description']}'.toLowerCase();
          if (!searchText.contains(query.toLowerCase())) continue;
        }
        
        // Category filter
        if (category != null && data['category'] != category) continue;
        
        // Subcategory filter
        if (subcategory != null && data['subcategory'] != subcategory) continue;
        
        // Create DSM5Diagnosis object
        final diagnosis = DSM5Diagnosis(
          code: data['code'],
          title: data['title'],
          description: data['description'],
          translations: {},
          criteria: data['criteria'].map((c) => DSM5Criterion(
            code: 'C${data['criteria'].indexOf(c)}',
            description: c,
            translations: {},
            examples: [],
            type: 'required',
            minRequired: 1,
            maxAllowed: 1,
            subCriteria: [],
            metadata: {},
          )).toList(),
          symptoms: List<String>.from(data['symptoms']),
          riskFactors: [],
          complications: [],
          severity: data['severity'],
          chronicity: 'Unknown',
          differentialDiagnosis: [],
          comorbidities: [],
          treatmentOptions: [],
          medications: [],
          therapies: [],
          metadata: {},
          isActive: true,
          lastUpdated: DateTime.now(),
        );
        
        results.add(diagnosis);
        
        if (results.length >= maxResults) break;
      }

      _performanceMonitor.endOperation(
        'search_dsm5',
        context: 'diagnosis_service',
        resultMetadata: {
          'success': true,
          'results_count': results.length,
        },
      );

      return results;
    } catch (e) {
      _logger.error(
        'Failed to search DSM-5 diagnoses',
        context: 'diagnosis_service',
        data: {'query': query, 'error': e.toString()},
        error: e,
      );

      _performanceMonitor.endOperation(
        'search_dsm5',
        context: 'diagnosis_service',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      return [];
    }
  }

  // AI destekli tanı önerisi
  Future<List<AIDiagnosisSuggestion>> getAIDiagnosisSuggestions({
    required List<String> symptoms,
    required List<String> patientInfo,
    String language = 'en',
    int maxSuggestions = 5,
    double minConfidence = 0.6,
  }) async {
    _performanceMonitor.startOperation(
      'get_ai_diagnosis_suggestions',
      context: 'diagnosis_service',
      metadata: {
        'symptoms_count': symptoms.length,
        'patient_info_count': patientInfo.length,
        'language': language,
        'max_suggestions': maxSuggestions,
        'min_confidence': minConfidence,
      },
    );

    try {
      _logger.info(
        'Getting AI diagnosis suggestions',
        context: 'diagnosis_service',
        data: {'symptoms': symptoms, 'language': language},
      );

      // AI prompt oluştur
      final prompt = '''
      Sen deneyimli bir klinik psikolog ve psikiyatristsin. 
      Aşağıdaki belirtilere ve hasta bilgilerine göre olası tanıları öner:

      Belirtiler: ${symptoms.join(', ')}
      Hasta Bilgileri: ${patientInfo.join(', ')}

      Lütfen şu formatta JSON yanıt ver:
      {
        "suggestions": [
          {
            "diagnosis": "Tanı adı",
            "code": "ICD-11 kodu",
            "system": "ICD-11 veya DSM-5",
            "confidence": 0.85,
            "supporting_symptoms": ["belirti1", "belirti2"],
            "reasoning": "Tanı gerekçesi",
            "differential": ["ayırıcı tanı1", "ayırıcı tanı2"],
            "assessments": ["değerlendirme1", "değerlendirme2"]
          }
        ]
      }
      ''';

      // OpenAI API'yi çağır
      final response = await _callOpenAI(prompt);
      
      if (response.containsKey('suggestions')) {
        final suggestions = response['suggestions'] as List;
        
        final aiSuggestions = suggestions.take(maxSuggestions).map((s) => AIDiagnosisSuggestion(
          suggestedDiagnosis: s['diagnosis'] ?? 'Unknown',
          diagnosisCode: s['code'] ?? 'Unknown',
          classificationSystem: s['system'] ?? 'Unknown',
          confidence: (s['confidence'] ?? 0.0).toDouble(),
          supportingSymptoms: List<String>.from(s['supporting_symptoms'] ?? []),
          supportingCriteria: [],
          conflictingSymptoms: [],
          conflictingCriteria: [],
          differentialDiagnoses: List<String>.from(s['differential'] ?? []),
          recommendedAssessments: List<String>.from(s['assessments'] ?? []),
          recommendedTests: [],
          reasoning: s['reasoning'] ?? 'No reasoning provided',
          metadata: {},
          generatedAt: DateTime.now(),
        )).where((s) => s.confidence >= minConfidence).toList();

        _performanceMonitor.endOperation(
          'get_ai_diagnosis_suggestions',
          context: 'diagnosis_service',
          resultMetadata: {
            'success': true,
            'suggestions_count': aiSuggestions.length,
            'average_confidence': aiSuggestions.isNotEmpty 
                ? aiSuggestions.map((s) => s.confidence).reduce((a, b) => a + b) / aiSuggestions.length 
                : 0.0,
          },
        );

        return aiSuggestions;
      }

      // Fallback: Mock suggestions
      return _getMockAISuggestions(symptoms, language, maxSuggestions);

    } catch (e) {
      _logger.error(
        'Failed to get AI diagnosis suggestions',
        context: 'diagnosis_service',
        data: {'symptoms': symptoms, 'error': e.toString()},
        error: e,
      );

      _performanceMonitor.endOperation(
        'get_ai_diagnosis_suggestions',
        context: 'diagnosis_service',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      // Fallback: Mock suggestions
      return _getMockAISuggestions(symptoms, language, maxSuggestions);
    }
  }

  // Mock AI suggestions (fallback)
  List<AIDiagnosisSuggestion> _getMockAISuggestions(
    List<String> symptoms, 
    String language, 
    int maxSuggestions
  ) {
    final mockSuggestions = [
      {
        'diagnosis': language == 'tr' ? 'Depresif Bozukluk' : 'Depressive Disorder',
        'code': '6A70',
        'system': 'ICD-11',
        'confidence': 0.85,
        'supporting_symptoms': ['Persistent sadness', 'Loss of interest'],
        'reasoning': 'Symptoms match major depressive disorder criteria',
        'differential': ['Bipolar disorder', 'Adjustment disorder'],
        'assessments': ['Beck Depression Inventory', 'PHQ-9']
      },
      {
        'diagnosis': language == 'tr' ? 'Yaygın Anksiyete Bozukluğu' : 'Generalized Anxiety Disorder',
        'code': '6B00',
        'system': 'ICD-11',
        'confidence': 0.72,
        'supporting_symptoms': ['Excessive worry', 'Restlessness'],
        'reasoning': 'Anxiety symptoms present with worry',
        'differential': ['Panic disorder', 'Social anxiety disorder'],
        'assessments': ['GAD-7', 'Beck Anxiety Inventory']
      }
    ];

    return mockSuggestions.take(maxSuggestions).map((s) => AIDiagnosisSuggestion(
      suggestedDiagnosis: s['diagnosis'],
      diagnosisCode: s['code'],
      classificationSystem: s['system'],
      confidence: s['confidence'].toDouble(),
      supportingSymptoms: List<String>.from(s['supporting_symptoms']),
      supportingCriteria: [],
      conflictingSymptoms: [],
      conflictingCriteria: [],
      differentialDiagnoses: List<String>.from(s['differential']),
      recommendedAssessments: List<String>.from(s['assessments']),
      recommendedTests: [],
      reasoning: s['reasoning'],
      metadata: {},
      generatedAt: DateTime.now(),
    )).toList();
  }

  // OpenAI API çağrısı
  Future<Map<String, dynamic>> _callOpenAI(String prompt) async {
    await _initialize();
    
    final apiKey = _prefs?.getString('openai_api_key') ?? EnvConfig.openaiApiKey;
    
    if (apiKey == 'YOUR_OPENAI_API_KEY') {
      throw Exception('OpenAI API key not configured');
    }

    try {
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
              'content': 'Sen deneyimli bir klinik psikolog ve psikiyatristsin. Lütfen sadece JSON formatında yanıt ver.',
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
        
        try {
          return jsonDecode(content);
        } catch (e) {
          return {'suggestions': []};
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.error(
        'OpenAI API call failed',
        context: 'diagnosis_service',
        data: {'error': e.toString()},
        error: e,
      );
      return {'suggestions': []};
    }
  }

  // Kapsamlı tanı arama
  Future<DiagnosisSearchResult> searchDiagnoses({
    required String query,
    DiagnosisSearchFilters? filters,
    String language = 'en',
  }) async {
    _performanceMonitor.startOperation(
      'search_diagnoses',
      context: 'diagnosis_service',
      metadata: {
        'query': query,
        'language': language,
        'filters': filters?.toJson(),
      },
    );

    try {
      _logger.info(
        'Comprehensive diagnosis search',
        context: 'diagnosis_service',
        data: {'query': query, 'language': language},
      );

      // Paralel arama yap
      final futures = await Future.wait([
        searchICD11(query: query, language: language),
        searchDSM5(query: query, language: language),
        getAIDiagnosisSuggestions(
          symptoms: [query],
          patientInfo: [],
          language: language,
        ),
      ]);

      final icd11Results = futures[0] as List<ICD11Diagnosis>;
      final dsm5Results = futures[1] as List<DSM5Diagnosis>;
      final aiSuggestions = futures[2] as List<AIDiagnosisSuggestion>;

      final result = DiagnosisSearchResult(
        icd11Results: icd11Results,
        dsm5Results: dsm5Results,
        aiSuggestions: aiSuggestions,
        totalResults: icd11Results.length + dsm5Results.length + aiSuggestions.length,
        searchQuery: query,
        filters: filters?.toJson().keys.toList() ?? [],
        metadata: {
          'search_time': DateTime.now().toIso8601String(),
          'language': language,
          'systems_searched': ['ICD-11', 'DSM-5', 'AI'],
        },
        searchedAt: DateTime.now(),
      );

      _performanceMonitor.endOperation(
        'search_diagnoses',
        context: 'diagnosis_service',
        resultMetadata: {
          'success': true,
          'total_results': result.totalResults,
          'icd11_count': icd11Results.length,
          'dsm5_count': dsm5Results.length,
          'ai_count': aiSuggestions.length,
        },
      );

      return result;
    } catch (e) {
      _logger.error(
        'Failed to search diagnoses',
        context: 'diagnosis_service',
        data: {'query': query, 'error': e.toString()},
        error: e,
      );

      _performanceMonitor.endOperation(
        'search_diagnoses',
        context: 'diagnosis_service',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      return DiagnosisSearchResult(
        icd11Results: [],
        dsm5Results: [],
        aiSuggestions: [],
        totalResults: 0,
        searchQuery: query,
        filters: [],
        metadata: {'error': e.toString()},
        searchedAt: DateTime.now(),
      );
    }
  }

  // Performance monitoring getter'ları
  AIPerformanceMonitor get performanceMonitor => _performanceMonitor;
  AILogger get logger => _logger;

  // Performance statistics
  Map<String, dynamic> getPerformanceStatistics({String? context}) {
    return _performanceMonitor.getPerformanceStatistics(context: context);
  }

  // Export performance data
  Map<String, dynamic> exportPerformanceData() {
    return _performanceMonitor.exportPerformanceData();
  }
}
