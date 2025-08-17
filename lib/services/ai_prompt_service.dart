import 'dart:convert';
import 'dart:math';
import '../config/ai_config.dart';
import '../utils/ai_logger.dart';
import '../models/ai_performance_metrics.dart';

class AIPromptService {
  static final AIPromptService _instance = AIPromptService._internal();
  factory AIPromptService() => _instance;
  AIPromptService._internal();

  final AILogger _logger = AILogger();
  final Random _random = Random();

  // Prompt Templates
  static const Map<String, String> _basePrompts = {
    'diagnosis': '''
Sen deneyimli bir klinik psikologsun. Aşağıdaki bilgileri analiz ederek profesyonel bir değerlendirme yap:

DANİŞAN BİLGİLERİ:
- Yaş: {age}
- Cinsiyet: {gender}
- Ana Şikayet: {mainComplaint}
- Semptomlar: {symptoms}
- Önceki Tanılar: {previousDiagnoses}
- İlaç Kullanımı: {medicationHistory}
- Aile Öyküsü: {familyHistory}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "primaryDiagnosis": {
    "icdCode": "ICD-11 kodu",
    "confidence": 0.85,
    "rationale": "Tanı gerekçesi"
  },
  "differentialDiagnoses": [
    {
      "icdCode": "ICD-11 kodu",
      "confidence": 0.75,
      "rationale": "Ayırıcı tanı gerekçesi"
    }
  ],
  "riskAssessment": {
    "level": "Düşük/Orta/Yüksek",
    "factors": ["Risk faktörleri"],
    "recommendations": ["Öneriler"]
  },
  "treatmentPlan": {
    "approach": "Terapi yaklaşımı",
    "interventions": ["Müdahale önerileri"],
    "medicationConsiderations": "İlaç değerlendirmesi"
  }
}
''',

    'session_summary': '''
Sen deneyimli bir klinik psikologsun. Aşağıdaki seans notunu analiz ederek şu bilgileri çıkar:

SEANS NOTU:
{sessionNotes}

DANİŞAN BİLGİLERİ:
- Ana Tanı: {primaryDiagnosis}
- Tedavi Hedefleri: {treatmentGoals}
- Önceki Seanslar: {previousSessions}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "sessionInsights": {
    "emotionalState": "Duygu durumu",
    "mainThemes": ["Ana temalar"],
    "progress": "İlerleme durumu",
    "challenges": ["Zorluklar"]
  },
  "clinicalAssessment": {
    "riskLevel": "Risk seviyesi",
    "symptomChanges": "Semptom değişiklikleri",
    "therapeuticAlliance": "Terapötik ittifak kalitesi"
  },
  "nextSteps": {
    "recommendations": ["Sonraki adım önerileri"],
    "homework": "Ev ödevi önerileri",
    "focusAreas": ["Odaklanılacak alanlar"]
  }
}
''',

    'medication_recommendation': '''
Sen deneyimli bir psikiyatristsin. Aşağıdaki bilgilere göre ilaç önerisi yap:

TANI BİLGİLERİ:
- Ana Tanı: {primaryDiagnosis}
- Alt Tanılar: {secondaryDiagnoses}
- Mevcut İlaçlar: {currentMedications}
- İlaç Yan Etkileri: {sideEffects}
- Laboratuvar Değerleri: {labValues}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "medicationRecommendations": [
    {
      "medication": "İlaç adı",
      "dosage": "Doz bilgisi",
      "frequency": "Kullanım sıklığı",
      "duration": "Kullanım süresi",
      "rationale": "Öneri gerekçesi"
    }
  ],
  "contraindications": ["Kontrendikasyonlar"],
  "drugInteractions": ["İlaç etkileşimleri"],
  "monitoring": ["İzleme gereksinimleri"],
  "patientEducation": "Hasta eğitimi önerileri"
}
''',

    'crisis_intervention': '''
Sen kriz müdahalesi konusunda uzman bir klinik psikologsun. Aşağıdaki durumu değerlendir:

KRİZ DURUMU:
- Aciliyet Seviyesi: {urgencyLevel}
- Risk Faktörleri: {riskFactors}
- Mevcut Güvenlik: {currentSafety}
- Önceki Krizler: {previousCrises}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "riskAssessment": {
    "immediateRisk": "Acil risk değerlendirmesi",
    "riskLevel": "Düşük/Orta/Yüksek/Acil",
    "protectiveFactors": ["Koruyucu faktörler"]
  },
  "interventionPlan": {
    "immediateActions": ["Acil eylemler"],
    "safetyMeasures": ["Güvenlik önlemleri"],
    "professionalSupport": "Profesyonel destek önerileri"
  },
  "followUp": {
    "timeline": "Takip zamanlaması",
    "resources": ["Kaynaklar"],
    "emergencyContacts": ["Acil durum kontakları"]
  }
}
''',

    'treatment_planning': '''
Sen deneyimli bir klinik psikologsun. Aşağıdaki bilgilere göre kapsamlı tedavi planı oluştur:

DANİŞAN PROFİLİ:
- Tanı: {diagnosis}
- Semptomlar: {symptoms}
- Güçlü Yanlar: {strengths}
- Zorluklar: {challenges}
- Hedefler: {goals}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "treatmentGoals": [
    {
      "goal": "Hedef açıklaması",
      "priority": "Yüksek/Orta/Düşük",
      "timeline": "Tahmini süre",
      "measurable": "Ölçülebilir kriterler"
    }
  ],
  "therapeuticApproaches": [
    {
      "approach": "Terapi yaklaşımı",
      "rationale": "Gerekçe",
      "techniques": ["Teknikler"],
      "expectedOutcomes": "Beklenen sonuçlar"
    }
  ],
  "interventionStrategies": [
    {
      "strategy": "Strateji açıklaması",
      "implementation": "Uygulama planı",
      "resources": ["Gerekli kaynaklar"],
      "evaluation": "Değerlendirme yöntemi"
    }
  ]
}
''',

    'real_time_session_analysis': '''
Sen deneyimli bir klinik psikologsun ve şu anda aktif bir terapi seansını gerçek zamanlı olarak analiz ediyorsun. Aşağıdaki seans verilerini analiz ederek anında öneriler sun:

SEANS BİLGİLERİ:
- Seans Süresi: {sessionDuration} dakika
- Mevcut Faz: {currentPhase}
- Seans Hedefleri: {sessionGoals}
- Danışan Geçmişi: {clientHistory}

GERÇEK ZAMANLI VERİLER:
- Duygusal Göstergeler: {emotionalIndicators}
- Risk Faktörleri: {riskFactors}
- İlerleme Göstergeleri: {progressIndicators}
- Son Seans Verileri: {recentSessionData}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "emotionalStates": [
    {
      "emotion": "duygu_tipi",
      "intensity": 0.85,
      "confidence": 0.9,
      "trigger": "tetikleyici",
      "physicalSigns": ["fiziksel_belirtiler"],
      "behavioralSigns": ["davranışsal_belirtiler"],
      "context": "bağlam"
    }
  ],
  "riskIndicators": [
    {
      "type": "risk_tipi",
      "severity": "Düşük/Orta/Yüksek/Kritik",
      "description": "risk_açıklaması",
      "evidence": ["kanıtlar"],
      "confidence": 0.8,
      "recommendedAction": "önerilen_eylem",
      "requiresImmediateAttention": true
    }
  ],
  "interventionSuggestions": [
    {
      "type": "müdahale_tipi",
      "title": "Müdahale başlığı",
      "description": "Müdahale açıklaması",
      "rationale": "Gerekçe",
      "techniques": ["teknikler"],
      "timing": "Anında/Seans_İçinde/Seans_Sonrası",
      "confidence": 0.85,
      "expectedOutcome": "Beklenen sonuç"
    }
  ],
  "insights": [
    {
      "type": "içgörü_tipi",
      "title": "İçgörü başlığı",
      "description": "İçgörü açıklaması",
      "confidence": 0.8,
      "clinicalRelevance": "Klinik önemi",
      "isActionable": true
    }
  ],
  "progress": {
    "overallProgress": 0.65,
    "nextSteps": "Sonraki adımlar",
    "milestones": ["kilometre_taşları"],
    "challenges": ["zorluklar"],
    "breakthroughs": ["atılımlar"]
  },
  "alerts": [
    {
      "type": "uyarı_tipi",
      "priority": "Düşük/Orta/Yüksek/Kritik",
      "title": "Uyarı başlığı",
      "description": "Uyarı açıklaması",
      "recommendedActions": ["önerilen_eylemler"],
      "requiresEscalation": false
    }
  ]
}
''',

    'multimodal_session_analysis': '''
Sen gelişmiş bir AI klinik psikologsun ve çoklu modalite (ses, yüz ifadesi, biyometrik) verilerini analiz ederek kapsamlı seans analizi yapıyorsun.

MULTİMODAL VERİLER:
- Ses Analizi: {voiceAnalysis}
- Yüz İfadesi: {facialAnalysis}
- Biyometrik Veriler: {biometricData}
- Seans İçeriği: {sessionContent}
- Danışan Geçmişi: {clientHistory}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "integratedAnalysis": {
    "overallEmotionalState": {
      "primaryEmotion": "ana_duygu",
      "secondaryEmotions": ["ikincil_duygular"],
      "emotionalConflict": true/false,
      "conflictDescription": "çelişki_açıklaması"
    },
    "stressAssessment": {
      "overallStress": 0.75,
      "stressSources": ["stres_kaynakları"],
      "stressManifestations": ["stres_tezahürleri"],
      "copingEffectiveness": 0.6
    },
    "riskEvaluation": {
      "immediateRisks": ["acil_riskler"],
      "longTermRisks": ["uzun_vadeli_riskler"],
      "riskFactors": ["risk_faktörleri"],
      "protectiveFactors": ["koruyucu_faktörler"]
    },
    "therapeuticInsights": {
      "clientReadiness": 0.8,
      "resistanceLevel": 0.3,
      "therapeuticAlliance": 0.85,
      "interventionOpportunities": ["müdahale_fırsatları"]
    },
    "recommendations": {
      "immediateActions": ["acil_eylemler"],
      "sessionAdjustments": ["seans_ayarlamaları"],
      "techniqueModifications": ["teknik_değişiklikleri"],
      "followUpConsiderations": ["takip_konuları"]
    }
  },
  "crossModalValidation": {
    "voiceFacialAlignment": 0.9,
    "biometricEmotionalCorrelation": 0.85,
    "dataConsistency": 0.95,
    "confidenceScore": 0.88
  },
  "predictiveInsights": {
    "sessionOutcome": "pozitif/negatif/nötr",
    "clientProgress": 0.7,
    "therapeuticEffectiveness": 0.8,
    "nextSessionFocus": ["sonraki_seans_odak_noktaları"]
  }
}
''',

    'crisis_intervention_ai': '''
Sen kriz müdahalesi konusunda uzmanlaşmış bir AI klinik psikologsun. Aşağıdaki kriz verilerini analiz ederek acil müdahale planı oluştur:

KRİZ VERİLERİ:
- Kriz Tipi: {crisisType}
- Kriz Seviyesi: {crisisLevel}
- Danışan Durumu: {clientStatus}
- Mevcut Riskler: {currentRisks}
- Biyometrik Veriler: {biometricData}
- Önceki Müdahaleler: {previousInterventions}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "crisisAssessment": {
    "immediateRisk": "Yüksek/Orta/Düşük",
    "riskFactors": ["risk_faktörleri"],
    "protectiveFactors": ["koruyucu_faktörler"],
    "escalationPotential": 0.8
  },
  "interventionPlan": {
    "immediateActions": [
      {
        "action": "eylem_açıklaması",
        "priority": "Kritik/Yüksek/Orta",
        "timeline": "anında/5_dakika/15_dakika",
        "responsibleParty": "sorumlu_kişi"
      }
    ],
    "safetyMeasures": ["güvenlik_önlemleri"],
    "deEscalationTechniques": ["sakinleştirme_teknikleri"],
    "emergencyProtocols": ["acil_protokoller"]
  },
  "resourceAllocation": {
    "requiredPersonnel": ["gerekli_personel"],
    "medicalSupport": "gerekli/gerekli_değil",
    "specializedServices": ["uzman_servisler"],
    "equipment": ["gerekli_ekipman"]
  },
  "communicationStrategy": {
    "clientCommunication": "iletişim_yaklaşımı",
    "familyNotification": "aile_bilgilendirme",
    "teamCoordination": "ekip_koordinasyonu",
    "documentation": "belgeleme_gereksinimleri"
  },
  "followUpPlan": {
    "immediateFollowUp": "takip_planı",
    "longTermMonitoring": "uzun_vadeli_izleme",
    "preventionStrategies": ["önleme_stratejileri"],
    "recoverySupport": "iyileşme_desteği"
  }
}
''',
  };

  // Prompt Optimization Strategies
  static const Map<String, Map<String, dynamic>> _optimizationStrategies = {
    'clarity': {
      'description': 'Daha net ve anlaşılır prompt\'lar',
      'techniques': ['Basit dil kullanımı', 'Spesifik örnekler', 'Adım adım talimatlar'],
    },
    'context': {
      'description': 'Daha fazla bağlam bilgisi',
      'techniques': ['Danışan geçmişi', 'Kültürel faktörler', 'Çevresel etkiler'],
    },
    'structure': {
      'description': 'Daha iyi yapılandırılmış çıktı',
      'techniques': ['JSON şablonları', 'Kategorize edilmiş bilgiler', 'Öncelik sıralaması'],
    },
    'safety': {
      'description': 'Güvenlik odaklı prompt\'lar',
      'techniques': ['Risk değerlendirmesi', 'Güvenlik protokolleri', 'Acil durum planları'],
    },
  };

  String generatePrompt(String promptType, Map<String, dynamic> parameters) {
    final basePrompt = _basePrompts[promptType];
    if (basePrompt == null) {
      _logger.warning('Unknown prompt type', context: 'AIPromptService', data: {'type': promptType});
      return '';
    }

    String prompt = basePrompt;
    
    // Replace parameters
    parameters.forEach((key, value) {
      prompt = prompt.replaceAll('{$key}', value.toString());
    });

    // Add system instructions based on prompt type
    prompt = _addSystemInstructions(prompt, promptType);
    
    // Add cultural context if available
    if (parameters.containsKey('culturalContext')) {
      prompt = _addCulturalContext(prompt, parameters['culturalContext']);
    }

    // Add safety guidelines
    prompt = _addSafetyGuidelines(prompt, promptType);

    return prompt;
  }

  String _addSystemInstructions(String prompt, String promptType) {
    final instructions = '''
SİSTEM TALİMATLARI:
- Sadece istenen JSON formatında yanıt ver
- Türkçe dilinde yanıt ver
- Profesyonel ve etik standartlara uygun ol
- Belirsiz durumlarda "belirsiz" olarak işaretle
- Güvenlik riski varsa mutlaka belirt
- ICD-11 kodlarını doğru kullan
- Önerilerin kanıt temelli olmasına dikkat et

''';

    return instructions + prompt;
  }

  String _addCulturalContext(String prompt, String culturalContext) {
    final culturalInstructions = '''
KÜLTÜREL BAĞLAM:
- Kültürel hassasiyetleri göz önünde bulundur
- Yerel değerleri ve inançları dikkate al
- Aile dinamiklerini kültürel perspektiften değerlendir
- Toplumsal normları göz önünde bulundur

''';

    return culturalInstructions + prompt;
  }

  String _addSafetyGuidelines(String prompt, String promptType) {
    String safetyGuidelines = '';
    
    switch (promptType) {
      case 'crisis_intervention':
        safetyGuidelines = '''
GÜVENLİK PROTOKOLLERİ:
- Acil risk durumunda mutlaka profesyonel yardım öner
- Güvenlik planı oluştur
- Acil durum kontaklarını belirt
- Hasta güvenliğini öncelik haline getir

''';
        break;
      case 'medication_recommendation':
        safetyGuidelines = '''
İLAÇ GÜVENLİĞİ:
- Yan etkileri mutlaka belirt
- Kontrendikasyonları kontrol et
- İlaç etkileşimlerini değerlendir
- Doz ayarlaması için doktor kontrolü öner

''';
        break;
      default:
        safetyGuidelines = '''
GENEL GÜVENLİK:
- Risk faktörlerini değerlendir
- Güvenlik önlemlerini belirt
- Profesyonel yardım gerektiren durumları tanımla

''';
    }

    return safetyGuidelines + prompt;
  }

  String optimizePrompt(String originalPrompt, AIModelPerformance performance) {
    if (performance.accuracy < 0.7) {
      return _applyOptimization(originalPrompt, 'clarity');
    } else if (performance.responseTime > 5.0) {
      return _applyOptimization(originalPrompt, 'structure');
    } else if (performance.confidenceScore < 0.8) {
      return _applyOptimization(originalPrompt, 'context');
    }
    
    return originalPrompt;
  }

  String _applyOptimization(String prompt, String strategy) {
    final techniques = _optimizationStrategies[strategy]?['techniques'] ?? [];
    
    String optimizedPrompt = prompt;
    
    switch (strategy) {
      case 'clarity':
        optimizedPrompt = 'Lütfen çok net ve anlaşılır bir şekilde yanıt ver:\n\n' + optimizedPrompt;
        break;
      case 'context':
        optimizedPrompt = 'Mümkün olduğunca fazla bağlam bilgisi sağla:\n\n' + optimizedPrompt;
        break;
      case 'structure':
        optimizedPrompt = 'Yanıtını çok düzenli ve kategorize edilmiş şekilde ver:\n\n' + optimizedPrompt;
        break;
    }
    
    return optimizedPrompt;
  }

  Map<String, dynamic> getPromptAnalytics(String promptType) {
    return {
      'type': promptType,
      'baseTemplate': _basePrompts[promptType] ?? 'Not found',
      'optimizationStrategies': _optimizationStrategies,
      'parameterPlaceholders': _extractParameterPlaceholders(promptType),
    };
  }

  List<String> _extractParameterPlaceholders(String promptType) {
    final basePrompt = _basePrompts[promptType];
    if (basePrompt == null) return [];
    
    final regex = RegExp(r'\{(\w+)\}');
    final matches = regex.allMatches(basePrompt);
    
    return matches.map((match) => match.group(1)!).toSet().toList();
  }

  String generateRandomPrompt(String promptType) {
    final basePrompt = _basePrompts[promptType];
    if (basePrompt == null) return '';
    
    // Generate random parameters for testing
    final randomParams = _generateRandomParameters(promptType);
    
    return generatePrompt(promptType, randomParams);
  }

  Map<String, dynamic> _generateRandomParameters(String promptType) {
    final params = <String, dynamic>{};
    
    switch (promptType) {
      case 'diagnosis':
        params['age'] = _random.nextInt(60) + 18;
        params['gender'] = ['Erkek', 'Kadın'][_random.nextInt(2)];
        params['mainComplaint'] = ['Depresyon', 'Anksiyete', 'Travma sonrası stres'][_random.nextInt(3)];
        break;
      case 'session_summary':
        params['sessionNotes'] = 'Test seans notu';
        params['primaryDiagnosis'] = 'F41.1 - Anksiyete Bozukluğu';
        break;
      // Add more cases as needed
    }
    
    return params;
  }
}
