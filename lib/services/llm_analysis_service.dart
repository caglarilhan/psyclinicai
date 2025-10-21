import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class LLMAnalysisService extends ChangeNotifier {
  static final LLMAnalysisService _instance = LLMAnalysisService._internal();
  factory LLMAnalysisService() => _instance;
  LLMAnalysisService._internal();

  // API Keys (gerçek uygulamada secure storage'dan alınır)
  String? _openAIKey;
  String? _anthropicKey;
  String? _googleAIKey;
  
  bool _isProcessing = false;
  String _currentProvider = 'openai'; // 'openai', 'anthropic', 'google'

  bool get isProcessing => _isProcessing;
  String get currentProvider => _currentProvider;

  void initialize() {
    // API anahtarlarını yükle (gerçek uygulamada secure storage'dan)
    _loadAPIKeys();
  }

  void _loadAPIKeys() {
    // Demo anahtarlar (gerçek uygulamada flutter_secure_storage kullanılır)
    _openAIKey = 'sk-demo-openai-key';
    _anthropicKey = 'sk-ant-demo-key';
    _googleAIKey = 'demo-google-ai-key';
  }

  void setProvider(String provider) {
    _currentProvider = provider;
    notifyListeners();
  }

  // Hasta raporu analizi
  Future<Map<String, dynamic>> analyzePatientReport(String reportText) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final prompt = _buildAnalysisPrompt(reportText);
      final response = await _callLLM(prompt);
      
      return _parseAnalysisResponse(response);

    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // İlaç önerileri
  Future<List<Map<String, dynamic>>> generateDrugRecommendations(
    String diagnosis,
    List<String> symptoms,
    List<String> currentMedications,
    List<String> allergies,
    String patientAge,
    String patientGender,
  ) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final prompt = _buildDrugRecommendationPrompt(
        diagnosis, symptoms, currentMedications, allergies, patientAge, patientGender
      );
      
      final response = await _callLLM(prompt);
      return _parseDrugRecommendations(response);

    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // İlaç etkileşim analizi
  Future<Map<String, dynamic>> analyzeDrugInteractions(
    List<String> drugNames,
    String patientProfile,
  ) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final prompt = _buildInteractionPrompt(drugNames, patientProfile);
      final response = await _callLLM(prompt);
      
      return _parseInteractionResponse(response);

    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // LLM çağrısı
  Future<String> _callLLM(String prompt) async {
    switch (_currentProvider) {
      case 'openai':
        return await _callOpenAI(prompt);
      case 'anthropic':
        return await _callAnthropic(prompt);
      case 'google':
        return await _callGoogleAI(prompt);
      default:
        return await _callOpenAI(prompt);
    }
  }

  // OpenAI API çağrısı
  Future<String> _callOpenAI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIKey',
        },
        body: json.encode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'Sen bir tıbbi AI asistanısın. Hasta raporlarını analiz edip ilaç önerileri sunuyorsun.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('OpenAI API hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OpenAI API hatası: $e');
      }
      return _getDemoResponse('analysis');
    }
  }

  // Anthropic Claude API çağrısı
  Future<String> _callAnthropic(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _anthropicKey!,
          'anthropic-version': '2023-06-01',
        },
        body: json.encode({
          'model': 'claude-3-sonnet-20240229',
          'max_tokens': 2000,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['content'][0]['text'];
      } else {
        throw Exception('Anthropic API hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Anthropic API hatası: $e');
      }
      return _getDemoResponse('analysis');
    }
  }

  // Google AI API çağrısı
  Future<String> _callGoogleAI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 2000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Google AI API hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google AI API hatası: $e');
      }
      return _getDemoResponse('analysis');
    }
  }

  // Prompt oluşturma
  String _buildAnalysisPrompt(String reportText) {
    return '''
Aşağıdaki hasta raporunu analiz et ve JSON formatında yanıtla:

RAPOR:
$reportText

Lütfen şu bilgileri çıkar:
1. Tanılar (diagnoses): Array
2. Semptomlar (symptoms): Array  
3. Mevcut ilaçlar (current_medications): Array
4. Alerjiler (allergies): Array
5. Vital bulgular (vital_signs): Object
6. Öneriler (recommendations): Array
7. Risk faktörleri (risk_factors): Array
8. Güven skoru (confidence_score): Number (0-1)

JSON formatında yanıtla:
{
  "diagnoses": ["tanı1", "tanı2"],
  "symptoms": ["semptom1", "semptom2"],
  "current_medications": ["ilaç1", "ilaç2"],
  "allergies": ["alerji1", "alerji2"],
  "vital_signs": {"blood_pressure": "150/95", "pulse": "85"},
  "recommendations": ["öneri1", "öneri2"],
  "risk_factors": ["risk1", "risk2"],
  "confidence_score": 0.85
}
''';
  }

  String _buildDrugRecommendationPrompt(
    String diagnosis,
    List<String> symptoms,
    List<String> currentMedications,
    List<String> allergies,
    String patientAge,
    String patientGender,
  ) {
    return '''
Hasta profili:
- Tanı: $diagnosis
- Semptomlar: ${symptoms.join(', ')}
- Mevcut ilaçlar: ${currentMedications.join(', ')}
- Alerjiler: ${allergies.join(', ')}
- Yaş: $patientAge
- Cinsiyet: $patientGender

Bu hasta için uygun ilaç önerileri yap. Her öneri için:
1. İlaç adı
2. Dozaj
3. Sıklık
4. Süre
5. Neden
6. Takip gereksinimleri
7. Kontrendikasyonlar
8. Güven skoru

JSON formatında yanıtla:
{
  "recommendations": [
    {
      "drug_name": "Metformin",
      "dosage": "500mg",
      "frequency": "Günde 2 kez",
      "duration": "Sürekli",
      "reason": "Tip 2 diabetes için birinci basamak tedavi",
      "monitoring": "Kan şekeri, böbrek fonksiyonları",
      "contraindications": ["Böbrek yetmezliği"],
      "confidence": 0.9
    }
  ]
}
''';
  }

  String _buildInteractionPrompt(List<String> drugNames, String patientProfile) {
    return '''
İlaç etkileşim analizi:

İlaçlar: ${drugNames.join(', ')}
Hasta profili: $patientProfile

Bu ilaçlar arasındaki etkileşimleri analiz et:
1. Etkileşim türü (major, moderate, minor)
2. Mekanizma
3. Klinik etki
4. Öneriler
5. Risk seviyesi
6. Takip gereksinimleri

JSON formatında yanıtla:
{
  "interactions": [
    {
      "drugs": ["ilaç1", "ilaç2"],
      "type": "moderate",
      "mechanism": "CYP enzim inhibisyonu",
      "clinical_effect": "İlaç seviyelerinde artış",
      "recommendation": "Dozaj ayarlaması gerekebilir",
      "risk_level": "medium",
      "monitoring": "İlaç seviyeleri takip edilmeli"
    }
  ],
  "overall_risk": "medium",
  "recommendations": ["genel öneri1", "genel öneri2"]
}
''';
  }

  // Yanıt parsing
  Map<String, dynamic> _parseAnalysisResponse(String response) {
    try {
      // JSON parse etmeye çalış
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        return json.decode(jsonString);
      }
    } catch (e) {
      if (kDebugMode) {
        print('JSON parse hatası: $e');
      }
    }
    
    // Fallback: Demo veri
    return _getDemoAnalysisData();
  }

  List<Map<String, dynamic>> _parseDrugRecommendations(String response) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        final data = json.decode(jsonString);
        return List<Map<String, dynamic>>.from(data['recommendations'] ?? []);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Drug recommendations parse hatası: $e');
      }
    }
    
    return _getDemoDrugRecommendations();
  }

  Map<String, dynamic> _parseInteractionResponse(String response) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        return json.decode(jsonString);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Interaction response parse hatası: $e');
      }
    }
    
    return _getDemoInteractionData();
  }

  // Demo yanıtlar
  String _getDemoResponse(String type) {
    switch (type) {
      case 'analysis':
        return '''
{
  "diagnoses": ["Tip 2 Diabetes Mellitus", "Hipertansiyon"],
  "symptoms": ["Poliüri", "Polidipsi", "Yorgunluk"],
  "current_medications": ["Metformin 500mg", "Lisinopril 10mg"],
  "allergies": ["Penisilin"],
  "vital_signs": {"blood_pressure": "150/95", "pulse": "85", "temperature": "36.8"},
  "recommendations": ["Kan şekeri takibi", "Kan basıncı kontrolü"],
  "risk_factors": ["Yaşlı hasta", "Çoklu ilaç kullanımı"],
  "confidence_score": 0.85
}
''';
      default:
        return 'Demo yanıt';
    }
  }

  Map<String, dynamic> _getDemoAnalysisData() {
    return {
      'diagnoses': ['Tip 2 Diabetes Mellitus', 'Hipertansiyon'],
      'symptoms': ['Poliüri', 'Polidipsi', 'Yorgunluk'],
      'current_medications': ['Metformin 500mg', 'Lisinopril 10mg'],
      'allergies': ['Penisilin'],
      'vital_signs': {'blood_pressure': '150/95', 'pulse': '85'},
      'recommendations': ['Kan şekeri takibi', 'Kan basıncı kontrolü'],
      'risk_factors': ['Yaşlı hasta', 'Çoklu ilaç kullanımı'],
      'confidence_score': 0.85,
    };
  }

  List<Map<String, dynamic>> _getDemoDrugRecommendations() {
    return [
      {
        'drug_name': 'Metformin',
        'dosage': '500mg',
        'frequency': 'Günde 2 kez',
        'duration': 'Sürekli',
        'reason': 'Tip 2 diabetes için birinci basamak tedavi',
        'monitoring': 'Kan şekeri, böbrek fonksiyonları',
        'contraindications': ['Böbrek yetmezliği'],
        'confidence': 0.9,
      },
      {
        'drug_name': 'Lisinopril',
        'dosage': '10mg',
        'frequency': 'Günde 1 kez',
        'duration': 'Sürekli',
        'reason': 'Hipertansiyon kontrolü için ACE inhibitörü',
        'monitoring': 'Kan basıncı, böbrek fonksiyonları',
        'contraindications': ['Hamilelik'],
        'confidence': 0.85,
      },
    ];
  }

  Map<String, dynamic> _getDemoInteractionData() {
    return {
      'interactions': [
        {
          'drugs': ['Metformin', 'Lisinopril'],
          'type': 'minor',
          'mechanism': 'Renal clearance etkileşimi',
          'clinical_effect': 'Minimal klinik etki',
          'recommendation': 'Normal kullanım',
          'risk_level': 'low',
          'monitoring': 'Böbrek fonksiyonları',
        }
      ],
      'overall_risk': 'low',
      'recommendations': ['Normal takip', 'Böbrek fonksiyonları kontrolü'],
    };
  }
}
