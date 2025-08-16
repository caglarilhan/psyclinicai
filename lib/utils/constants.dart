class AppConstants {
  // Uygulama bilgileri
  static const String appName = 'PsyClinic AI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI Destekli Klinik Yönetim Sistemi';

  // Kullanıcı rolleri (PRD'den)
  static const List<String> userRoles = [
    'Psikolog',
    'Psikiyatrist',
    'Klinik yöneticisi',
    'Süpervizör',
    'Admin',
  ];

  // Hedef ülkeler (PRD'den)
  static const List<String> targetCountries = [
    'ABD',
    'Almanya',
    'Birleşik Krallık',
    'Fransa',
    'Hollanda',
    'Kanada',
    'Türkiye',
  ];

  // Tanı standartları (PRD'den)
  static const Map<String, String> diagnosisStandards = {
    'ABD': 'DSM-5-TR',
    'Almanya': 'ICD-11',
    'Birleşik Krallık': 'ICD-11',
    'Fransa': 'ICD-11',
    'Hollanda': 'ICD-11',
    'Kanada': 'ICD + DSM',
    'Türkiye': 'ICD-10',
  };

  // Yasal uyumluluk (PRD'den)
  static const Map<String, List<String>> legalCompliance = {
    'ABD': ['HIPAA'],
    'Almanya': ['GDPR'],
    'Birleşik Krallık': ['GDPR'],
    'Fransa': ['GDPR'],
    'Hollanda': ['GDPR'],
    'Kanada': ['PIPEDA'],
    'Türkiye': ['KVKK'],
  };

  // AI modül tipleri (PRD'den)
  static const List<String> aiModuleTypes = [
    'Seans Notu + AI Özet',
    'Randevu Takvimi',
    'Tanı Arama',
    'Reçete & İlaç Sistemi',
    'Flag Sistemi',
    'Eğitim Kitaplığı',
    'Terapi Simülasyonu',
    'Vaka Yöneticisi',
    'Süpervizör Paneli',
    'Finans Modülü',
    'Kurum Mesajlaşma',
  ];

  // Fiyatlandırma planları (PRD'den)
  static const Map<String, Map<String, dynamic>> pricingPlans = {
    'Starter': {
      'price': 0,
      'currency': 'USD',
      'features': ['3 danışan', 'AI özeti yok'],
    },
    'Pro': {
      'price': 12,
      'currency': 'USD',
      'features': ['Sınırsız danışan', 'AI özet', 'PDF'],
    },
    'Enterprise': {
      'price': 49,
      'currency': 'USD',
      'features': ['Tüm modüller', 'Çoklu şube'],
    },
  };

  // Sprint planı (PRD'den)
  static const Map<String, List<String>> sprintPlan = {
    'Sprint 1': ['Seans ekranı', 'Randevu', 'PDF'],
    'Sprint 2': ['Tanı sistemi', 'Reçete öneri', 'Flag AI'],
    'Sprint 3': ['Eğitim paneli', 'AI öneri', 'İçerik'],
    'Sprint 4': ['Simülasyon', 'Seans analizi'],
    'Sprint 5': ['CRM', 'Süpervizyon', 'White-label'],
  };

  // Klavye kısayolları (PRD'den)
  static const Map<String, String> keyboardShortcuts = {
    'Ctrl + N': 'Yeni seans başlat',
    'Ctrl + S': 'Notu kaydet',
    'Ctrl + P': 'PDF çıktısı',
    'Ctrl + Shift + A': 'AI özetini yeniden çalıştır',
    'Alt + 1': 'Panel: Notlar',
    'Alt + 2': 'Panel: AI',
    'Alt + 3': 'Panel: Danışan',
  };

  // Güvenlik standartları (PRD'den)
  static const Map<String, List<String>> securityStandards = {
    'HIPAA': ['AES-256', 'Audit log', 'Access control'],
    'GDPR': ['Export', 'Data silme', 'DPO zorunluluğu'],
    'KVKK': ['Açık rıza', 'Rol bazlı erişim', 'Anonimleştirme'],
    'PIPEDA': ['Kanada içi hosting', 'Veri erişim protokolü'],
  };

  // API endpoint'leri
  static const String baseUrl = 'https://api.psycliniciai.com';
  static const String authEndpoint = '/auth';
  static const String sessionEndpoint = '/sessions';
  static const String appointmentEndpoint = '/appointments';
  static const String aiEndpoint = '/ai';

  // Dosya boyut limitleri
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // Sayfa boyutları
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Zaman formatları
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Lokalizasyon
  static const String defaultLanguage = 'tr';
  static const List<String> supportedLanguages = ['tr', 'en', 'de', 'fr', 'nl'];

  // Hata mesajları
  static const Map<String, String> errorMessages = {
    'network_error': 'Ağ bağlantısı hatası',
    'auth_error': 'Kimlik doğrulama hatası',
    'permission_error': 'Yetki hatası',
    'validation_error': 'Doğrulama hatası',
    'server_error': 'Sunucu hatası',
    'unknown_error': 'Bilinmeyen hata',
  };

  // Başarı mesajları
  static const Map<String, String> successMessages = {
    'session_saved': 'Seans notu kaydedildi',
    'appointment_created': 'Randevu oluşturuldu',
    'ai_summary_generated': 'AI özeti oluşturuldu',
    'pdf_exported': 'PDF dışa aktarıldı',
    'profile_updated': 'Profil güncellendi',
  };
}
