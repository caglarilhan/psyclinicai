class AIConfig {
  // OpenAI Configuration
  static const String openaiApiKey = 'YOUR_OPENAI_API_KEY';
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String openaiModel = 'gpt-4-turbo-preview';
  static const int openaiMaxTokens = 2000;
  static const double openaiTemperature = 0.7;
  
  // Claude Configuration (Alternatif)
  static const String claudeApiKey = 'YOUR_CLAUDE_API_KEY';
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';
  static const String claudeModel = 'claude-3-sonnet-20240229';
  static const int claudeMaxTokens = 2000;
  
  // AI Prompt Templates
  static const String sessionSummaryPrompt = '''
Sen deneyimli bir klinik psikologsun. Aşağıdaki seans notunu analiz ederek şu bilgileri çıkar:

1. **Duygu Durumu (Affect)**: Danışanın ana duygu durumu
2. **Ana Tema**: Seansın ana konusu ve danışanın temel sorunu
3. **ICD-11 Önerisi**: En uygun tanı kodu (Türkiye için ICD-10 da kabul edilir)
4. **Risk Seviyesi**: Düşük/Orta/Yüksek
5. **Önerilen Müdahale**: Terapi yaklaşımı ve öneriler
6. **Güven Seviyesi**: 0.0-1.0 arası

Seans Notu:
{sessionNotes}

Lütfen sadece JSON formatında yanıt ver:
{
  "affect": "duygu durumu",
  "theme": "ana tema",
  "icdSuggestion": "ICD kodu",
  "riskLevel": "risk seviyesi",
  "recommendedIntervention": "önerilen müdahale",
  "confidence": 0.85
}
''';

  static const String medicationSuggestionPrompt = '''
Sen deneyimli bir psikiyatristsin. Aşağıdaki tanı ve mevcut ilaçlara göre ilaç önerisi yap:

Tanı: {diagnosis}
Mevcut İlaçlar: {currentMeds}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "suggestions": [
    {
      "medication": "İlaç adı",
      "dosage": "Doz bilgisi",
      "rationale": "Öneri gerekçesi",
      "contraindications": "Dikkat edilecek durumlar"
    }
  ],
  "interactions": "İlaç etkileşim uyarıları"
}
''';

  static const String educationalContentPrompt = '''
Sen psikoloji eğitimi uzmanısın. Aşağıdaki uzmanlık alanı ve deneyim yılına göre eğitim içerik önerisi yap:

Uzmanlık Alanı: {specialty}
Deneyim Yılı: {experienceYears}

Lütfen şu bilgileri içeren JSON formatında yanıt ver:
{
  "recommendations": [
    {
      "title": "Eğitim başlığı",
      "type": "Kurs/Seminer/Kitap",
      "duration": "Süre",
      "level": "Seviye",
      "description": "Açıklama"
    }
  ],
  "priority": "Öncelik sırası"
}
''';

  static const String therapySimulationPrompt = '''
Sen deneyimli bir danışansın. Aşağıdaki hedef ve terapist mesajına gerçekçi bir yanıt ver:

Danışan Hedefi: {clientGoal}
Terapist Mesajı: {therapistMessage}

Lütfen danışanın ağzından gerçekçi bir yanıt ver. Kısa ve doğal olsun.
''';

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxTokensPerRequest = 4000;
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'api_key_missing': 'API anahtarı bulunamadı',
    'rate_limit_exceeded': 'Dakikada maksimum istek sayısı aşıldı',
    'invalid_response': 'AI servisinden geçersiz yanıt alındı',
    'network_error': 'Ağ bağlantısı hatası',
    'timeout': 'İstek zaman aşımına uğradı',
  };
}
