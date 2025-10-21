import 'package:flutter/foundation.dart';
import '../models/specialty_models.dart';

class SpecialtyRecommendationService extends ChangeNotifier {
  final List<SpecialtyRecommendation> _recommendations = [];
  final List<SpecialtyWorkflow> _workflows = [];
  final List<SpecialtyTool> _tools = [];

  List<SpecialtyRecommendation> get recommendations => List.unmodifiable(_recommendations);
  List<SpecialtyWorkflow> get workflows => List.unmodifiable(_workflows);
  List<SpecialtyTool> get tools => List.unmodifiable(_tools);

  // Initialize with specialty-specific recommendations
  void initializeSpecialtyData() {
    if (_recommendations.isNotEmpty) return;

    // PSİKİYATRİST ÖNERİLERİ
    _recommendations.addAll([
      SpecialtyRecommendation(
        id: 'psychiatrist_001',
        title: 'Akıllı Reçete Sistemi',
        description: 'AI destekli ilaç etkileşimi kontrolü ve dozaj optimizasyonu',
        targetSpecialty: SpecialtyType.psychiatrist,
        category: 'İlaç Yönetimi',
        features: [
          'İlaç etkileşimi kontrolü',
          'Dozaj optimizasyonu',
          'Yan etki takibi',
          'E-reçete entegrasyonu',
          'TITCK veritabanı bağlantısı'
        ],
        priority: 'high',
        icon: 'medication',
        color: 'blue',
      ),
      SpecialtyRecommendation(
        id: 'psychiatrist_002',
        title: 'DSM-5/ICD-11 Tanı Asistanı',
        description: 'Semptom analizi ve tanı önerileri için AI destekli sistem',
        targetSpecialty: SpecialtyType.psychiatrist,
        category: 'Tanı ve Değerlendirme',
        features: [
          'Semptom analizi',
          'Tanı önerileri',
          'DSM-5/ICD-11 kriterleri',
          'Ölçek entegrasyonu',
          'Tedavi planı önerileri'
        ],
        priority: 'high',
        icon: 'psychology',
        color: 'purple',
      ),
      SpecialtyRecommendation(
        id: 'psychiatrist_003',
        title: 'Konsültasyon Yönetimi',
        description: 'Diğer uzmanlarla konsültasyon süreçlerini yönetme',
        targetSpecialty: SpecialtyType.psychiatrist,
        category: 'İletişim',
        features: [
          'Konsültasyon istekleri',
          'Yanıt sistemi',
          'Şablonlar',
          'Takvim entegrasyonu',
          'Dokümantasyon'
        ],
        priority: 'medium',
        icon: 'medical_services',
        color: 'green',
      ),
    ]);

    // PSİKOLOG ÖNERİLERİ
    _recommendations.addAll([
      SpecialtyRecommendation(
        id: 'psychologist_001',
        title: 'Terapi Protokol Kütüphanesi',
        description: 'EMDR, CBT, DBT gibi kanıta dayalı terapi protokolleri',
        targetSpecialty: SpecialtyType.psychologist,
        category: 'Terapi Yönetimi',
        features: [
          'EMDR protokolü',
          'CBT teknikleri',
          'DBT becerileri',
          'Kriz müdahale protokolleri',
          'Süpervizyon onay sistemi'
        ],
        priority: 'high',
        icon: 'library_books',
        color: 'purple',
      ),
      SpecialtyRecommendation(
        id: 'psychologist_002',
        title: 'Otomatik Değerlendirme Anketleri',
        description: 'PHQ-9, GAD-7 gibi ölçeklerin otomatik gönderimi ve analizi',
        targetSpecialty: SpecialtyType.psychologist,
        category: 'Değerlendirme',
        features: [
          'PHQ-9 otomatik gönderim',
          'GAD-7 analizi',
          'Dashboard trendleri',
          'Hasta bildirimleri',
          'Sonuç raporları'
        ],
        priority: 'high',
        icon: 'assessment',
        color: 'orange',
      ),
      SpecialtyRecommendation(
        id: 'psychologist_003',
        title: 'Etik İhlal Raporlama',
        description: 'Mesleki etik ihlalleri için güvenli raporlama sistemi',
        targetSpecialty: SpecialtyType.psychologist,
        category: 'Etik ve Güvenlik',
        features: [
          'Anonim raporlama',
          'İhlal kategorileri',
          'Öncelik seviyeleri',
          'Takip sistemi',
          'Çözüm önerileri'
        ],
        priority: 'medium',
        icon: 'security',
        color: 'red',
      ),
    ]);

    // HEMŞİRE ÖNERİLERİ
    _recommendations.addAll([
      SpecialtyRecommendation(
        id: 'nurse_001',
        title: 'Hasta Bakım Planları',
        description: 'Kişiselleştirilmiş bakım planları ve görev takibi',
        targetSpecialty: SpecialtyType.nurse,
        category: 'Hasta Bakımı',
        features: [
          'Kişiselleştirilmiş bakım planları',
          'Görev takibi',
          'Vital bulgular takibi',
          'İlaç uyumu kontrolü',
          'Bakım notları'
        ],
        priority: 'high',
        icon: 'healing',
        color: 'green',
      ),
      SpecialtyRecommendation(
        id: 'nurse_002',
        title: 'Acil Durum Protokolleri',
        description: 'Kritik durumlar için hızlı müdahale protokolleri',
        targetSpecialty: SpecialtyType.nurse,
        category: 'Acil Durum',
        features: [
          'Suicidal ideation protokolü',
          'Panik atak müdahalesi',
          'Agresyon yönetimi',
          'Kriz değerlendirmesi',
          'Sağlık Bakanlığı raporu'
        ],
        priority: 'high',
        icon: 'emergency',
        color: 'red',
      ),
      SpecialtyRecommendation(
        id: 'nurse_003',
        title: 'Hasta Eğitimi Modülleri',
        description: 'İlaç kullanımı ve yaşam tarzı eğitimleri',
        targetSpecialty: SpecialtyType.nurse,
        category: 'Hasta Eğitimi',
        features: [
          'İlaç kullanım eğitimleri',
          'Yaşam tarzı önerileri',
          'İnteraktif materyaller',
          'İlerleme takibi',
          'Quiz sistemi'
        ],
        priority: 'medium',
        icon: 'school',
        color: 'blue',
      ),
    ]);

    // SEKRETER ÖNERİLERİ
    _recommendations.addAll([
      SpecialtyRecommendation(
        id: 'secretary_001',
        title: 'Gelişmiş Randevu Yönetimi',
        description: 'Otomatik randevu planlama ve hasta bildirimleri',
        targetSpecialty: SpecialtyType.secretary,
        category: 'Randevu Yönetimi',
        features: [
          'Otomatik randevu planlama',
          'Hasta bildirimleri',
          'SMS/Email entegrasyonu',
          'Takvim senkronizasyonu',
          'Bekleme listesi yönetimi'
        ],
        priority: 'high',
        icon: 'calendar_today',
        color: 'blue',
      ),
      SpecialtyRecommendation(
        id: 'secretary_002',
        title: 'Hasta Kayıt Optimizasyonu',
        description: 'Hızlı hasta kayıt ve dokümantasyon sistemi',
        targetSpecialty: SpecialtyType.secretary,
        category: 'Kayıt Yönetimi',
        features: [
          'Hızlı hasta kayıt',
          'Dokümantasyon şablonları',
          'Arama ve filtreleme',
          'Dosya yönetimi',
          'Rapor oluşturma'
        ],
        priority: 'high',
        icon: 'folder',
        color: 'green',
      ),
      SpecialtyRecommendation(
        id: 'secretary_003',
        title: 'Faturalandırma Otomasyonu',
        description: 'Otomatik fatura oluşturma ve ödeme takibi',
        targetSpecialty: SpecialtyType.secretary,
        category: 'Finansal Yönetim',
        features: [
          'Otomatik fatura oluşturma',
          'Ödeme takibi',
          'Sigorta entegrasyonu',
          'Raporlama',
          'Muhasebe bağlantısı'
        ],
        priority: 'medium',
        icon: 'receipt',
        color: 'orange',
      ),
    ]);

    // YÖNETİCİ ÖNERİLERİ
    _recommendations.addAll([
      SpecialtyRecommendation(
        id: 'admin_001',
        title: 'Performans Analitikleri',
        description: 'Klinik performans ve hasta sonuçları analizi',
        targetSpecialty: SpecialtyType.administrator,
        category: 'Analitik ve Raporlama',
        features: [
          'Klinik performans metrikleri',
          'Hasta sonuçları analizi',
          'Personel verimliliği',
          'Maliyet analizi',
          'Trend raporları'
        ],
        priority: 'high',
        icon: 'analytics',
        color: 'purple',
      ),
      SpecialtyRecommendation(
        id: 'admin_002',
        title: 'Personel Yönetimi',
        description: 'Personel planlama, eğitim ve performans takibi',
        targetSpecialty: SpecialtyType.administrator,
        category: 'İnsan Kaynakları',
        features: [
          'Vardiya planlama',
          'Eğitim takibi',
          'Performans değerlendirme',
          'İzin yönetimi',
          'Sertifika takibi'
        ],
        priority: 'medium',
        icon: 'people',
        color: 'blue',
      ),
      SpecialtyRecommendation(
        id: 'admin_003',
        title: 'Finansal Yönetim',
        description: 'Bütçe planlama, maliyet kontrolü ve gelir analizi',
        targetSpecialty: SpecialtyType.administrator,
        category: 'Finansal Yönetim',
        features: [
          'Bütçe planlama',
          'Maliyet kontrolü',
          'Gelir analizi',
          'Sigorta anlaşmaları',
          'Muhasebe entegrasyonu'
        ],
        priority: 'high',
        icon: 'account_balance',
        color: 'green',
      ),
    ]);

    // HASTA ÖNERİLERİ
    _recommendations.addAll([
      SpecialtyRecommendation(
        id: 'patient_001',
        title: 'Kişisel Sağlık Takibi',
        description: 'Mood tracking, ilaç hatırlatıcıları ve kişisel hedefler',
        targetSpecialty: SpecialtyType.patient,
        category: 'Kişisel Takip',
        features: [
          'Mood tracking',
          'İlaç hatırlatıcıları',
          'Kişisel hedefler',
          'Semptom günlüğü',
          'İlerleme raporları'
        ],
        priority: 'high',
        icon: 'timeline',
        color: 'purple',
      ),
      SpecialtyRecommendation(
        id: 'patient_002',
        title: 'Eğitim Materyalleri',
        description: 'Kişiselleştirilmiş eğitim içerikleri ve interaktif modüller',
        targetSpecialty: SpecialtyType.patient,
        category: 'Eğitim',
        features: [
          'Kişiselleştirilmiş içerik',
          'İnteraktif modüller',
          'Video eğitimleri',
          'Quiz ve değerlendirmeler',
          'İlerleme takibi'
        ],
        priority: 'medium',
        icon: 'school',
        color: 'blue',
      ),
      SpecialtyRecommendation(
        id: 'patient_003',
        title: 'AI Asistan',
        description: '7/24 erişilebilir AI destekli sağlık asistanı',
        targetSpecialty: SpecialtyType.patient,
        category: 'Destek',
        features: [
          '7/24 erişim',
          'Kriz desteği',
          'Genel sorular',
          'Randevu planlama',
          'Acil durum bağlantısı'
        ],
        priority: 'high',
        icon: 'smart_toy',
        color: 'orange',
      ),
    ]);

    notifyListeners();
  }

  // Get recommendations for specific specialty
  List<SpecialtyRecommendation> getRecommendationsForSpecialty(SpecialtyType specialty) {
    return _recommendations
        .where((rec) => rec.targetSpecialty == specialty)
        .toList()
        ..sort((a, b) => _getPriorityOrder(a.priority).compareTo(_getPriorityOrder(b.priority)));
  }

  // Get recommendations by category
  List<SpecialtyRecommendation> getRecommendationsByCategory(SpecialtyType specialty, String category) {
    return _recommendations
        .where((rec) => rec.targetSpecialty == specialty && rec.category == category)
        .toList()
        ..sort((a, b) => _getPriorityOrder(a.priority).compareTo(_getPriorityOrder(b.priority)));
  }

  // Get high priority recommendations
  List<SpecialtyRecommendation> getHighPriorityRecommendations(SpecialtyType specialty) {
    return _recommendations
        .where((rec) => rec.targetSpecialty == specialty && rec.priority == 'high')
        .toList();
  }

  // Get specialty-specific workflows
  List<SpecialtyWorkflow> getWorkflowsForSpecialty(SpecialtyType specialty) {
    return _workflows
        .where((workflow) => workflow.targetSpecialty == specialty)
        .toList();
  }

  // Get specialty-specific tools
  List<SpecialtyTool> getToolsForSpecialty(SpecialtyType specialty) {
    return _tools
        .where((tool) => tool.targetSpecialty == specialty)
        .toList();
  }

  // Get all categories for a specialty
  List<String> getCategoriesForSpecialty(SpecialtyType specialty) {
    final categories = _recommendations
        .where((rec) => rec.targetSpecialty == specialty)
        .map((rec) => rec.category)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  // Get specialty statistics
  Map<String, dynamic> getSpecialtyStatistics(SpecialtyType specialty) {
    final specialtyRecs = _recommendations.where((rec) => rec.targetSpecialty == specialty).toList();
    final categories = specialtyRecs.map((rec) => rec.category).toSet().length;
    final highPriority = specialtyRecs.where((rec) => rec.priority == 'high').length;
    final mediumPriority = specialtyRecs.where((rec) => rec.priority == 'medium').length;
    final lowPriority = specialtyRecs.where((rec) => rec.priority == 'low').length;

    return {
      'totalRecommendations': specialtyRecs.length,
      'categories': categories,
      'highPriority': highPriority,
      'mediumPriority': mediumPriority,
      'lowPriority': lowPriority,
    };
  }

  int _getPriorityOrder(String priority) {
    switch (priority) {
      case 'high':
        return 1;
      case 'medium':
        return 2;
      case 'low':
        return 3;
      default:
        return 4;
    }
  }

  // Get specialty name in Turkish
  String getSpecialtyName(SpecialtyType specialty) {
    switch (specialty) {
      case SpecialtyType.psychiatrist:
        return 'Psikiyatrist';
      case SpecialtyType.psychologist:
        return 'Psikolog';
      case SpecialtyType.nurse:
        return 'Hemşire';
      case SpecialtyType.secretary:
        return 'Sekreter';
      case SpecialtyType.administrator:
        return 'Yönetici';
      case SpecialtyType.patient:
        return 'Hasta';
    }
  }

  // Get specialty description
  String getSpecialtyDescription(SpecialtyType specialty) {
    switch (specialty) {
      case SpecialtyType.psychiatrist:
        return 'Psikiyatristler için ilaç yönetimi, tanı ve konsültasyon özellikleri';
      case SpecialtyType.psychologist:
        return 'Psikologlar için terapi protokolleri, değerlendirme ve etik özellikleri';
      case SpecialtyType.nurse:
        return 'Hemşireler için hasta bakımı, vital bulgular ve acil durum özellikleri';
      case SpecialtyType.secretary:
        return 'Sekreterler için randevu yönetimi, hasta kayıtları ve faturalandırma';
      case SpecialtyType.administrator:
        return 'Yöneticiler için analitik, personel yönetimi ve finansal özellikler';
      case SpecialtyType.patient:
        return 'Hastalar için kişisel takip, eğitim ve AI asistan özellikleri';
    }
  }
}
