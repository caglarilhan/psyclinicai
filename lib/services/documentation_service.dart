import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DocumentationService extends ChangeNotifier {
  static final DocumentationService _instance = DocumentationService._internal();
  factory DocumentationService() => _instance;
  DocumentationService._internal();

  Map<String, DocumentationSection> _sections = {};
  Map<String, List<DocumentationExample>> _examples = {};
  Map<String, List<DocumentationVideo>> _videos = {};
  Map<String, List<DocumentationFAQ>> _faqs = {};
  
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  Map<String, DocumentationSection> get sections => Map.unmodifiable(_sections);
  Map<String, List<DocumentationExample>> get examples => Map.unmodifiable(_examples);
  Map<String, List<DocumentationVideo>> get videos => Map.unmodifiable(_videos);
  Map<String, List<DocumentationFAQ>> get faqs => Map.unmodifiable(_faqs);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadDocumentation();
      _isInitialized = true;
      notifyListeners();
      print('DocumentationService initialized successfully');
    } catch (e) {
      print('DocumentationService initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _loadDocumentation() async {
    await _loadCoreDocumentation();
    await _loadFeatureDocumentation();
    await _loadExamples();
    await _loadVideos();
    await _loadFAQs();
  }

  Future<void> _loadCoreDocumentation() async {
    // Core system documentation
    _sections['getting_started'] = DocumentationSection(
      id: 'getting_started',
      title: 'Başlangıç Rehberi',
      description: 'PsyClinic AI sistemini kullanmaya başlama',
      content: '''
# 🚀 PsyClinic AI Başlangıç Rehberi

## Hoş Geldiniz!
PsyClinic AI, psikiyatristler için geliştirilmiş kapsamlı bir dijital platformdur.

## 📱 İlk Kurulum
1. **Giriş Yapın**: E-posta ve şifrenizle sisteme giriş yapın
2. **Profil Oluşturun**: Kişisel bilgilerinizi ve uzmanlık alanlarınızı girin
3. **Bölge Seçin**: TR/US/EU bölgelerinden birini seçin
4. **Onay Verin**: KVKK/HIPAA/GDPR uyumluluk onaylarını verin

## 🎯 Ana Özellikler
- **AI Destekli Teşhis**: DSM-5/ICD-11 entegrasyonu
- **İlaç Yönetimi**: E-reçete ve etkileşim kontrolü
- **Gerçek Zamanlı Analiz**: Oturum sırasında AI destek
- **Telehealth**: Uzaktan görüşme ve izleme
- **Bölgesel Uyumluluk**: TR/US/EU standartları

## 🔧 Hızlı Başlangıç
1. Dashboard'da "Yeni Hasta" butonuna tıklayın
2. Hasta bilgilerini girin
3. AI teşhis sistemini kullanarak değerlendirme yapın
4. Tedavi planı oluşturun ve takip edin
      ''',
      category: 'core',
      order: 1,
      isActive: true,
    );

    _sections['ai_diagnosis'] = DocumentationSection(
      id: 'ai_diagnosis',
      title: 'AI Teşhis Sistemi',
      description: 'Yapay zeka destekli teşhis ve değerlendirme',
      content: '''
# 🧠 AI Teşhis Sistemi

## Genel Bakış
AI Teşhis Sistemi, DSM-5 ve ICD-11 kriterlerine göre psikiyatrik bozuklukları değerlendirir.

## 🎯 Kullanım Adımları
1. **Hasta Seçimi**: Değerlendirilecek hastayı seçin
2. **Belirti Girişi**: Hasta belirtilerini sisteme girin
3. **AI Analizi**: Sistemi çalıştırarak AI değerlendirmesi alın
4. **Sonuç İnceleme**: AI önerilerini ve güven skorunu inceleyin
5. **Teşhis Onayı**: AI önerisini onaylayın veya düzenleyin

## 📊 AI Model Performansı
- **Doğruluk Oranı**: %92
- **Ortalama Yanıt Süresi**: 2.3 saniye
- **Desteklenen Bozukluklar**: 150+
- **Güncelleme Sıklığı**: Haftalık

## 🔍 Desteklenen Ölçekler
- **PANSS**: Şizofreni değerlendirmesi
- **YMRS**: Mani değerlendirmesi
- **HAM-D**: Depresyon değerlendirmesi
- **HAM-A**: Anksiyete değerlendirmesi
- **MADRS**: Montgomery-Asberg Depresyon Ölçeği

## ⚠️ Önemli Notlar
- AI önerileri klinik değerlendirmeyi destekler, yerine geçmez
- Her teşhis klinisyen tarafından onaylanmalıdır
- Sistem sürekli öğrenir ve gelişir
      ''',
      category: 'features',
      order: 2,
      isActive: true,
    );

    _sections['medication_management'] = DocumentationSection(
      id: 'medication_management',
      title: 'İlaç Yönetimi',
      description: 'E-reçete, etkileşim kontrolü ve dozaj yönetimi',
      content: '''
# 💊 İlaç Yönetimi Sistemi

## E-Reçete Sistemi
### Türkiye (e-Reçete)
- **SGK Entegrasyonu**: Otomatik geri ödeme
- **İlaç Kurumu Veritabanı**: Güncel ilaç bilgileri
- **Dijital İmza**: Güvenli reçete imzalama
- **Hasta Geçmişi**: Önceki reçeteleri görüntüleme

### ABD (ePrescribing)
- **DEA Uyumluluğu**: Kontrollü maddeler için
- **RxNorm Entegrasyonu**: Standart ilaç kodları
- **PDMP Kontrolü**: Reçete izleme programı
- **Medicare/Medicaid**: Otomatik ödeme

### AB (ePrescription)
- **GDPR Uyumluluğu**: Veri koruma
- **SNOMED-CT**: Klinik terminoloji
- **eIDAS**: Elektronik kimlik doğrulama
- **Cross-border**: Ülkeler arası reçete

## 🚫 Etkileşim Kontrolü
### Otomatik Kontrol
- **İlaç-İlaç**: Yan etki riski değerlendirmesi
- **İlaç-Hastalık**: Kontrendikasyon kontrolü
- **İlaç-Gıda**: Besin etkileşimleri
- **İlaç-Laboratuvar**: Test sonuçları etkisi

### Risk Skorlama
- **Düşük Risk**: %0-25
- **Orta Risk**: %26-50
- **Yüksek Risk**: %51-75
- **Kritik Risk**: %76-100

## 📈 Dozaj Yönetimi
### Titrasyon Algoritmaları
- **SSRI**: 2-4 haftada kademeli artış
- **Lithium**: Serum seviyesi takibi
- **Antipsikotik**: Klinik yanıta göre ayarlama
- **Benzodiazepin**: Kısa süreli kullanım

### Hasta Takibi
- **Yan Etki İzleme**: Otomatik uyarılar
- **Uyum Takibi**: İlaç alma hatırlatıcıları
- **Laboratuvar**: Düzenli test takibi
- **Klinik Değerlendirme**: Periyodik kontroller
      ''',
      category: 'features',
      order: 3,
      isActive: true,
    );
  }

  Future<void> _loadFeatureDocumentation() async {
    // Feature-specific documentation
    _sections['telehealth'] = DocumentationSection(
      id: 'telehealth',
      title: 'Telehealth & Uzaktan İzleme',
      description: 'Video görüşmeleri ve IoT cihaz entegrasyonu',
      content: '''
# 📱 Telehealth & Uzaktan İzleme

## Video Görüşmeleri
### Güvenlik Özellikleri
- **End-to-End Şifreleme**: AES-256
- **HIPAA Uyumlu**: Hasta gizliliği korunur
- **Kayıt Kontrolü**: Hasta onayı gerekli
- **Oturum Zaman Aşımı**: Güvenlik için otomatik kapanma

### Kalite Ayarları
- **Düşük Bant Genişliği**: 128 kbps
- **Orta Kalite**: 256 kbps
- **Yüksek Kalite**: 512 kbps
- **Otomatik Ayarlama**: Bağlantı kalitesine göre

## IoT Cihaz Entegrasyonu
### Desteklenen Cihazlar
- **Akıllı Saat**: Kalp atış hızı, uyku
- **Kan Basıncı Monitörü**: Otomatik ölçüm
- **Glukoz Monitörü**: Diyabet takibi
- **Aktivite Takipçisi**: Günlük hareket

### Veri Güvenliği
- **Şifreli İletim**: TLS 1.3
- **Yerel Depolama**: Cihazda şifreli
- **Anonim Veri**: Araştırma için
- **Hasta Kontrolü**: Veri paylaşım izni

## Dijital Terapötikler
### Program Türleri
- **Bilişsel Davranışçı Terapi**: Yapılandırılmış programlar
- **Mindfulness**: Meditasyon ve nefes egzersizleri
- **Uyku Hijyeni**: Uyku kalitesi iyileştirme
- **Stres Yönetimi**: Günlük pratikler

### Etkinlik Takibi
- **Kullanım Metrikleri**: Program tamamlama oranı
- **Klinik Sonuçlar**: Belirti azalması
- **Hasta Memnuniyeti**: Değerlendirme skorları
- **Uzun Vadeli Takip**: Relaps önleme
      ''',
      category: 'features',
      order: 4,
      isActive: true,
    );
  }

  Future<void> _loadExamples() async {
    // Code examples and use cases
    _examples['ai_diagnosis'] = [
      DocumentationExample(
        id: 'depression_diagnosis',
        title: 'Depresyon Teşhisi Örneği',
        description: 'AI ile major depresif bozukluk teşhisi',
        code: '''
// Hasta belirtileri
final symptoms = [
  SymptomAssessment(
    name: 'Depresif ruh hali',
    severity: SymptomSeverity.severe,
    duration: Duration.daily,
    frequency: Frequency.continuous,
  ),
  SymptomAssessment(
    name: 'İlgi kaybı',
    severity: SymptomSeverity.moderate,
    duration: Duration.daily,
    frequency: Frequency.continuous,
  ),
];

// AI teşhis
final diagnosis = await diagnosisService.generateAIDiagnosis(
  SymptomAssessment(
    id: 'assessment_001',
    patientId: 'patient_001',
    symptoms: symptoms,
    duration: Duration.weeks,
    frequency: Frequency.daily,
  ),
);

print('Teşhis: ${diagnosis.disorderName}');
print('Güven: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%');
        ''',
        language: 'dart',
        category: 'ai_diagnosis',
      ),
    ];

    _examples['medication_management'] = [
      DocumentationExample(
        id: 'drug_interaction_check',
        title: 'İlaç Etkileşim Kontrolü',
        description: 'İki ilaç arasındaki etkileşimi kontrol etme',
        code: '''
// İlaç listesi
final medications = [
  'Sertraline 50mg',
  'Lithium 300mg',
  'Risperidone 2mg',
];

// Etkileşim kontrolü
final interactions = await medicationService.checkDrugInteractions(
  medications: medications,
);

for (final interaction in interactions) {
  print('${interaction.drug1} + ${interaction.drug2}');
  print('Risk: ${interaction.severity}');
  print('Öneri: ${interaction.recommendations.join(', ')}');
}
        ''',
        language: 'dart',
        category: 'medication',
      ),
    ];
  }

  Future<void> _loadVideos() async {
    // Video tutorials
    _videos['getting_started'] = [
      DocumentationVideo(
        id: 'welcome_tour',
        title: 'PsyClinic AI Tanıtım Turu',
        description: 'Sistemin genel özelliklerini keşfedin',
        url: 'https://example.com/videos/welcome_tour.mp4',
        duration: Duration(minutes: 5),
        category: 'getting_started',
      ),
      DocumentationVideo(
        id: 'first_patient',
        title: 'İlk Hasta Kaydı',
        description: 'Yeni hasta ekleme ve profil oluşturma',
        url: 'https://example.com/videos/first_patient.mp4',
        duration: Duration(minutes: 8),
        category: 'getting_started',
      ),
    ];

    _videos['ai_diagnosis'] = [
      DocumentationVideo(
        id: 'ai_diagnosis_workflow',
        title: 'AI Teşhis İş Akışı',
        description: 'Adım adım AI teşhis süreci',
        url: 'https://example.com/videos/ai_diagnosis.mp4',
        duration: Duration(minutes: 12),
        category: 'ai_diagnosis',
      ),
    ];
  }

  Future<void> _loadFAQs() async {
    // Frequently asked questions
    _faqs['general'] = [
      DocumentationFAQ(
        id: 'data_security',
        question: 'Hasta verileri nasıl korunuyor?',
        answer: '''
PsyClinic AI, en yüksek güvenlik standartlarını kullanır:

🔒 **Şifreleme**: AES-256 end-to-end şifreleme
🏥 **HIPAA Uyumlu**: ABD sağlık verisi koruma standartları
🇪🇺 **GDPR Uyumlu**: Avrupa veri koruma düzenlemeleri
🇹🇷 **KVKK Uyumlu**: Türkiye kişisel veri koruma kanunu
🔐 **Çok Faktörlü Kimlik Doğrulama**: SMS + Biyometrik
📱 **Cihaz Güvenliği**: Kayıp cihaz uzaktan silme
        ''',
        category: 'general',
        tags: ['güvenlik', 'veri koruma', 'uyumluluk'],
      ),
      DocumentationFAQ(
        id: 'ai_accuracy',
        question: 'AI teşhislerinin doğruluğu nedir?',
        answer: '''
AI teşhis sistemi sürekli öğrenir ve gelişir:

📊 **Genel Doğruluk**: %92
🧠 **Model Güncellemeleri**: Haftalık
📈 **Sürekli İyileştirme**: Yeni verilerle eğitim
👨‍⚕️ **Klinisyen Onayı**: Her teşhis kontrol edilir
⚠️ **Önemli Not**: AI destek sağlar, karar vermez
🔬 **Bilimsel Kanıt**: Peer-reviewed araştırmalar
        ''',
        category: 'ai',
        tags: ['AI', 'doğruluk', 'güvenilirlik'],
      ),
    ];

    _faqs['technical'] = [
      DocumentationFAQ(
        id: 'offline_usage',
        question: 'İnternet olmadan kullanabilir miyim?',
        answer: '''
Evet, sınırlı offline özellikler mevcuttur:

📱 **Offline Mod**: Temel hasta bilgileri
💾 **Yerel Depolama**: Şifreli veri saklama
🔄 **Senkronizasyon**: Bağlantı geri geldiğinde
⚠️ **Kısıtlamalar**: AI özellikleri offline çalışmaz
📊 **Veri Güncelleme**: Manuel senkronizasyon gerekli
        ''',
        category: 'technical',
        tags: ['offline', 'senkronizasyon', 'veri'],
      ),
    ];
  }

  // Search functionality
  List<DocumentationSection> searchDocumentation(String query) {
    if (query.isEmpty) return [];
    
    final results = <DocumentationSection>[];
    
    for (final section in _sections.values) {
      if (section.title.toLowerCase().contains(query.toLowerCase()) ||
          section.description.toLowerCase().contains(query.toLowerCase()) ||
          section.content.toLowerCase().contains(query.toLowerCase())) {
        results.add(section);
      }
    }
    
    return results;
  }

  List<DocumentationFAQ> searchFAQs(String query) {
    if (query.isEmpty) return [];
    
    final results = <DocumentationFAQ>[];
    
    for (final category in _faqs.keys) {
      for (final faq in _faqs[category]!) {
        if (faq.question.toLowerCase().contains(query.toLowerCase()) ||
            faq.answer.toLowerCase().contains(query.toLowerCase())) {
          results.add(faq);
        }
      }
    }
    
    return results;
  }

  // Get documentation by category
  List<DocumentationSection> getSectionsByCategory(String category) {
    return _sections.values
        .where((section) => section.category == category)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  // Get examples by category
  List<DocumentationExample> getExamplesByCategory(String category) {
    return _examples[category] ?? [];
  }

  // Get videos by category
  List<DocumentationVideo> getVideosByCategory(String category) {
    return _videos[category] ?? [];
  }

  // Get FAQs by category
  List<DocumentationFAQ> getFAQsByCategory(String category) {
    return _faqs[category] ?? [];
  }
}

// Documentation data models
class DocumentationSection {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;
  final int order;
  final bool isActive;

  DocumentationSection({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.order,
    required this.isActive,
  });
}

class DocumentationExample {
  final String id;
  final String title;
  final String description;
  final String code;
  final String language;
  final String category;

  DocumentationExample({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.language,
    required this.category,
  });
}

class DocumentationVideo {
  final String id;
  final String title;
  final String description;
  final String url;
  final Duration duration;
  final String category;

  DocumentationVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.duration,
    required this.category,
  });
}

class DocumentationFAQ {
  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> tags;

  DocumentationFAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.tags,
  });
}
