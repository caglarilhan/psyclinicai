# 🧠 PsyClinic AI - AI Destekli Psikoloji Kliniği Yönetim Sistemi

PsyClinic AI, psikoloji klinikleri için geliştirilmiş, yapay zeka destekli kapsamlı bir yönetim sistemidir. Sistem, terapistlerin danışanlarını daha etkili bir şekilde yönetmelerine, AI destekli tanı ve tedavi önerileri almalarına olanak sağlar.

## ✨ Özellikler

### 🤖 AI Entegrasyonu
- **Çoklu AI Model Desteği**: OpenAI GPT-4, Anthropic Claude, Meta LLaMA
- **Akıllı Model Seçimi**: Performans bazlı otomatik model seçimi
- **AI Response Caching**: Hızlı yanıt için akıllı önbellekleme
- **Prompt Engineering**: Gelişmiş prompt optimizasyonu
- **Real-time Analytics**: AI performans metrikleri ve analiz

### 🏥 Klinik Yönetimi
- **Danışan Yönetimi**: Kapsamlı danışan profilleri ve geçmişi
- **Seans Takibi**: Detaylı seans notları ve AI destekli özetler
- **Tanı Yardımı**: AI destekli tanı önerileri ve ICD-11 kodları
- **İlaç Rehberi**: İlaç etkileşimleri ve önerileri
- **Randevu Sistemi**: AI destekli randevu optimizasyonu

### 🔒 Güvenlik ve Gizlilik
- **End-to-End Encryption**: Hassas veri şifreleme
- **Biometric Authentication**: Parmak izi ve yüz tanıma
- **Audit Logging**: Kapsamlı aktivite takibi
- **GDPR/KVKK Compliance**: Veri koruma standartları

### 📱 Çoklu Platform Desteği
- **iOS & Android**: Native mobil uygulamalar
- **Web**: Responsive web arayüzü
- **Desktop**: macOS ve Windows desteği
- **Offline Mode**: İnternet olmadan çalışma

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.8.0+
- Dart 3.0+
- iOS 12.0+ / Android 6.0+
- macOS 10.15+ / Windows 10+

### Adımlar

1. **Repository'yi klonlayın**
```bash
git clone https://github.com/yourusername/psyclinicai.git
cd psyclinicai
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **AI API anahtarlarını yapılandırın**
```bash
# .env dosyası oluşturun
cp .env.example .env

# API anahtarlarını ekleyin
OPENAI_API_KEY=your_openai_api_key
CLAUDE_API_KEY=your_claude_api_key
```

4. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 🏗️ Proje Yapısı

```
lib/
├── config/                 # Konfigürasyon dosyaları
│   ├── ai_config.dart     # AI servis ayarları
│   ├── env_config.dart    # Ortam değişkenleri
│   └── country_config.dart # Ülke ayarları
├── models/                 # Veri modelleri
│   ├── ai_models/         # AI ile ilgili modeller
│   ├── clinical_models/   # Klinik veri modelleri
│   └── user_models/       # Kullanıcı modelleri
├── services/               # İş mantığı servisleri
│   ├── ai_services/       # AI servisleri
│   ├── auth_services/     # Kimlik doğrulama
│   └── clinical_services/ # Klinik servisleri
├── screens/                # Uygulama ekranları
│   ├── auth/              # Kimlik doğrulama ekranları
│   ├── dashboard/         # Ana dashboard
│   └── clinical/          # Klinik ekranları
└── widgets/                # Yeniden kullanılabilir bileşenler
    ├── ai_widgets/        # AI bileşenleri
    └── clinical_widgets/  # Klinik bileşenleri
```

## 🤖 AI Servisleri

### AI Orchestration Service
Merkezi AI yönetim servisi, farklı AI modellerini koordine eder ve en iyi sonucu seçer.

```dart
final aiService = AIOrchestrationService();
final response = await aiService.processRequest(
  promptType: 'diagnosis',
  parameters: diagnosisParams,
  taskId: 'unique_task_id',
);
```

### AI Cache Service
AI yanıtlarını önbellekler ve performansı artırır.

```dart
final cacheService = AICacheService();
await cacheService.cacheResponse(
  promptType,
  modelId,
  parameters,
  response,
);
```

### AI Prompt Service
Gelişmiş prompt yönetimi ve optimizasyonu sağlar.

```dart
final promptService = AIPromptService();
final prompt = promptService.generatePrompt(
  'diagnosis',
  diagnosisParameters,
);
```

## 📊 Analytics ve Monitoring

### AI Performance Dashboard
- Model performans karşılaştırması
- Yanıt süresi analizi
- Başarı oranı takibi
- Cache hit rate istatistikleri

### Real-time Monitoring
- Canlı AI istek takibi
- Hata oranı analizi
- Kullanım metrikleri
- Performans trendleri

## 🔧 Konfigürasyon

### AI Model Ayarları
```dart
// lib/config/ai_config.dart
class AIConfig {
  static const String openaiModel = 'gpt-4-turbo-preview';
  static const String claudeModel = 'claude-3-sonnet-20240229';
  static const int maxTokens = 4000;
  static const double temperature = 0.7;
}
```

### Ortam Değişkenleri
```bash
# .env
OPENAI_API_KEY=your_key_here
CLAUDE_API_KEY=your_key_here
AI_MAX_REQUESTS_PER_MINUTE=60
AI_TIMEOUT_SECONDS=30
DEBUG_MODE=true
```

## 🧪 Test

### Unit Tests
```bash
flutter test test/unit/
```

### Widget Tests
```bash
flutter test test/widget/
```

### Integration Tests
```bash
flutter test test/integration/
```

## 📱 Kullanım Örnekleri

### AI Destekli Tanı
```dart
final diagnosisService = AIDiagnosisService();
final result = await diagnosisService.analyzeSymptoms(
  clientId: 'client_001',
  symptoms: symptomsList,
  clientHistory: clientHistory,
  therapistId: 'therapist_001',
);
```

### AI Chatbot
```dart
EnhancedAIChatbotWidget(
  initialContext: 'Depresyon tedavisi',
  clientId: 'client_001',
  therapistId: 'therapist_001',
  onAnalysisComplete: (response) {
    print('AI analizi tamamlandı: $response');
  },
)
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- **Proje Sahibi**: [Your Name](mailto:your.email@example.com)
- **GitHub**: [@yourusername](https://github.com/yourusername)
- **Website**: [https://psyclinic.ai](https://psyclinic.ai)

## 🙏 Teşekkürler

- [Flutter](https://flutter.dev) ekibine
- [OpenAI](https://openai.com) ekibine
- [Anthropic](https://anthropic.com) ekibine
- [Meta AI](https://ai.meta.com) ekibine
- Tüm katkıda bulunanlara

---

**PsyClinic AI** - Geleceğin psikoloji kliniği yönetim sistemi 🚀
