import 'package:flutter/material.dart';

// Bölgesel konfigürasyon - PRD'ye göre
class RegionConfig {
  static const String US = 'US';
  static const String EU = 'EU';
  static const String UK = 'UK';
  static const String CA = 'CA';
  static const String TR = 'TR';

  // Bölge bilgileri
  static const Map<String, RegionInfo> regions = {
    US: RegionInfo(
      name: 'United States',
      diagnosisStandard: 'DSM-5-TR',
      legalCompliance: ['HIPAA'],
      language: 'en',
      aiPromptSuffix: 'DSM-5-TR formatında öner.',
      hosting: 'us-central1',
      currency: '\$',
      timezone: 'America/New_York',
      features: {
        'ai_diagnosis': true,
        'supervision': true,
        'flag_system': true,
        'audit_trail': true,
        'explainable_ai': true,
      },
      warnings: [
        'AI tanı koymaz - Destekleyici sistem olarak kullanın',
        'FDA onayı gerektirmez',
        'HIPAA uyumluluğu zorunlu',
      ],
    ),
    EU: RegionInfo(
      name: 'European Union',
      diagnosisStandard: 'ICD-11',
      legalCompliance: ['GDPR'],
      language: 'en',
      aiPromptSuffix: 'ICD-11 kodu ile özetle.',
      hosting: 'europe-west1',
      currency: '€',
      timezone: 'Europe/Berlin',
      features: {
        'ai_diagnosis': true,
        'supervision': true,
        'flag_system': true,
        'data_export': true,
        'data_deletion': true,
        'cultural_sensitivity': true,
      },
      warnings: [
        'Psikolojik danışman vs klinik psikolog ayrımı net olmalı',
        'GDPR uyumluluğu zorunlu',
        'Veri silme hakkı kritik',
      ],
    ),
    UK: RegionInfo(
      name: 'United Kingdom',
      diagnosisStandard: 'ICD-11',
      legalCompliance: ['GDPR', 'NHS'],
      language: 'en',
      aiPromptSuffix: 'ICD-11 + NICE protokolleri ile özetle.',
      hosting: 'europe-west2',
      currency: '£',
      timezone: 'Europe/London',
      features: {
        'ai_diagnosis': true,
        'supervision': true,
        'flag_system': true,
        'nhs_integration': true,
        'therapy_plans': true,
        'explainable_ai': true,
      },
      warnings: [
        'NHS uyumluluğu gerekli',
        'AI çıktıları şeffaf olmalı',
        'Explainable AI vurgusu yapılmalı',
      ],
    ),
    CA: RegionInfo(
      name: 'Canada',
      diagnosisStandard: 'ICD-11 + DSM-5',
      legalCompliance: ['PIPEDA'],
      language: 'en-fr',
      aiPromptSuffix: 'ICD kodu ve Fransızca açıklama dahil.',
      hosting: 'northamerica-northeast1',
      currency: 'C\$',
      timezone: 'America/Toronto',
      features: {
        'ai_diagnosis': true,
        'supervision': true,
        'flag_system': true,
        'bilingual_support': true,
        'clinical_dashboard': true,
        'ai_recommendations': true,
      },
      warnings: [
        'Veri Kanada içinde kalmalı',
        'Bilingual destek zorunlu',
        'PIPEDA uyumluluğu gerekli',
      ],
    ),
    TR: RegionInfo(
      name: 'Türkiye',
      diagnosisStandard: 'ICD-10',
      legalCompliance: ['KVKK'],
      language: 'tr',
      aiPromptSuffix: 'Türkçe ICD kodu ile özetle.',
      hosting: 'europe-west2',
      currency: '₺',
      timezone: 'Europe/Istanbul',
      features: {
        'ai_diagnosis': true,
        'supervision': true,
        'flag_system': true,
        'offline_support': true,
        'pdf_export': true,
        'prescription_module': true,
        'low_cost_plans': true,
      },
      warnings: [
        'Tanı yetkisi olan meslek grupları net ayrılmalı',
        'KVKK uyumluluğu zorunlu',
        'Offline kullanım desteklenmeli',
      ],
    ),
  };

  // Aktif bölge
  static String _activeRegion = TR;

  static String get activeRegion => _activeRegion;
  static RegionInfo get activeRegionInfo => regions[_activeRegion]!;

  // Bölge değiştirme
  static void setRegion(String region) {
    if (regions.containsKey(region)) {
      _activeRegion = region;
    }
  }

  // Bölge özelliklerini kontrol et
  static bool hasFeature(String feature) {
    return activeRegionInfo.features[feature] ?? false;
  }

  // Uyarıları al
  static List<String> get warnings => activeRegionInfo.warnings;

  // Dil desteği
  static bool supportsLanguage(String language) {
    return activeRegionInfo.language.contains(language);
  }

  // Tanı standardı
  static String get diagnosisStandard => activeRegionInfo.diagnosisStandard;

  // Yasal uyumluluk
  static List<String> get legalCompliance => activeRegionInfo.legalCompliance;

  // AI prompt suffix
  static String get aiPromptSuffix => activeRegionInfo.aiPromptSuffix;

  // Hosting bölgesi
  static String get hosting => activeRegionInfo.hosting;

  // Para birimi
  static String get currency => activeRegionInfo.currency;

  // Zaman dilimi
  static String get timezone => activeRegionInfo.timezone;
}

// Bölge bilgisi sınıfı
class RegionInfo {
  final String name;
  final String diagnosisStandard;
  final List<String> legalCompliance;
  final String language;
  final String aiPromptSuffix;
  final String hosting;
  final String currency;
  final String timezone;
  final Map<String, bool> features;
  final List<String> warnings;

  const RegionInfo({
    required this.name,
    required this.diagnosisStandard,
    required this.legalCompliance,
    required this.language,
    required this.aiPromptSuffix,
    required this.hosting,
    required this.currency,
    required this.timezone,
    required this.features,
    required this.warnings,
  });

  // Bölge özelliklerini kontrol et
  bool hasFeature(String feature) {
    return features[feature] ?? false;
  }

  // Yasal uyumluluk kontrolü
  bool isCompliantWith(String compliance) {
    return legalCompliance.contains(compliance);
  }

  // Çoklu dil desteği
  bool isBilingual() {
    return language.contains('-');
  }

  // Desteklenen dilleri al
  List<String> get supportedLanguages {
    if (isBilingual()) {
      return language.split('-');
    }
    return [language];
  }
}

// Güvenlik konfigürasyonu
class SecurityConfig {
  // Şifreleme standartları
  static const Map<String, Map<String, dynamic>> encryptionStandards = {
    'HIPAA': {
      'algorithm': 'AES-256',
      'keySize': 256,
      'mode': 'GCM',
      'auditLog': true,
      'accessControl': true,
    },
    'GDPR': {
      'algorithm': 'AES-256',
      'keySize': 256,
      'mode': 'GCM',
      'dataExport': true,
      'dataDeletion': true,
      'dpoRequired': true,
    },
    'KVKK': {
      'algorithm': 'AES-256',
      'keySize': 256,
      'mode': 'GCM',
      'explicitConsent': true,
      'roleBasedAccess': true,
      'anonymization': true,
    },
    'PIPEDA': {
      'algorithm': 'AES-256',
      'keySize': 256,
      'mode': 'GCM',
      'canadianHosting': true,
      'dataAccessProtocol': true,
    },
  };

  // Aktif bölge için güvenlik ayarları
  static Map<String, dynamic> get activeSecurityConfig {
    final compliance = RegionConfig.activeRegionInfo.legalCompliance.first;
    return encryptionStandards[compliance] ?? encryptionStandards['GDPR']!;
  }

  // Şifreleme algoritması
  static String get encryptionAlgorithm => activeSecurityConfig['algorithm'];

  // Anahtar boyutu
  static int get keySize => activeSecurityConfig['keySize'];

  // Şifreleme modu
  static String get encryptionMode => activeSecurityConfig['mode'];

  // Denetim kaydı gerekli mi
  static bool get auditLogRequired => activeSecurityConfig['auditLog'] ?? false;

  // Erişim kontrolü gerekli mi
  static bool get accessControlRequired => activeSecurityConfig['accessControl'] ?? false;

  // Veri dışa aktarma gerekli mi
  static bool get dataExportRequired => activeSecurityConfig['dataExport'] ?? false;

  // Veri silme gerekli mi
  static bool get dataDeletionRequired => activeSecurityConfig['dataDeletion'] ?? false;

  // DPO gerekli mi
  static bool get dpoRequired => activeSecurityConfig['dpoRequired'] ?? false;

  // Açık rıza gerekli mi
  static bool get explicitConsentRequired => activeSecurityConfig['explicitConsent'] ?? false;

  // Rol bazlı erişim gerekli mi
  static bool get roleBasedAccessRequired => activeSecurityConfig['roleBasedAccess'] ?? false;

  // Anonimleştirme gerekli mi
  static bool get anonymizationRequired => activeSecurityConfig['anonymization'] ?? false;

  // Kanada içi hosting gerekli mi
  static bool get canadianHostingRequired => activeSecurityConfig['canadianHosting'] ?? false;
}

// AI konfigürasyonu
class AIConfig {
  // Bölgeye özel AI prompt'ları
  static const Map<String, Map<String, String>> regionPrompts = {
    'US': {
      'session_summary': 'Bu terapi notunu DSM-5-TR uyumlu şekilde özetle: Duygu, Tema, ICD önerisi.',
      'prescription': 'Bu tanıya uygun 2 öneri ilaç + etkileşim riski verir misin?',
      'education': 'Terapistin uzmanlığına göre 3 video öner.',
      'simulation': 'Bir danışan gibi davran. Terapi hedefi: anksiyete.',
    },
    'EU': {
      'session_summary': 'Bu terapi notunu ICD-11 uyumlu şekilde özetle: Duygu, Tema, ICD önerisi.',
      'prescription': 'Bu tanıya uygun 2 öneri ilaç + etkileşim riski verir misin?',
      'education': 'Terapistin uzmanlığına göre 3 video öner.',
      'simulation': 'Bir danışan gibi davran. Terapi hedefi: anksiyete.',
    },
    'UK': {
      'session_summary': 'Bu terapi notunu ICD-11 + NICE protokolleri ile özetle.',
      'prescription': 'Bu tanıya uygun 2 öneri ilaç + etkileşim riski verir misin?',
      'education': 'Terapistin uzmanlığına göre 3 video öner.',
      'simulation': 'Bir danışan gibi davran. Terapi hedefi: anksiyete.',
    },
    'CA': {
      'session_summary': 'Bu terapi notunu ICD kodu ve Fransızca açıklama dahil özetle.',
      'prescription': 'Bu tanıya uygun 2 öneri ilaç + etkileşim riski verir misin?',
      'education': 'Terapistin uzmanlığına göre 3 video öner.',
      'simulation': 'Bir danışan gibi davran. Terapi hedefi: anksiyete.',
    },
    'TR': {
      'session_summary': 'Bu terapi notunu Türkçe ICD kodu ile özetle: Duygu, Tema, ICD önerisi.',
      'prescription': 'Bu tanıya uygun 2 öneri ilaç + etkileşim riski verir misin?',
      'education': 'Terapistin uzmanlığına göre 3 video öner.',
      'simulation': 'Bir danışan gibi davran. Terapi hedefi: anksiyete.',
    },
  };

  // Aktif bölge için AI prompt'ı al
  static String getPrompt(String type) {
    final region = RegionConfig.activeRegion;
    final prompts = regionPrompts[region] ?? regionPrompts['TR']!;
    return prompts[type] ?? prompts['session_summary']!;
  }

  // Seans özeti prompt'ı
  static String get sessionSummaryPrompt => getPrompt('session_summary');

  // Reçete prompt'ı
  static String get prescriptionPrompt => getPrompt('prescription');

  // Eğitim prompt'ı
  static String get educationPrompt => getPrompt('education');

  // Simülasyon prompt'ı
  static String get simulationPrompt => getPrompt('simulation');
}

// Fiyatlandırma konfigürasyonu
class PricingConfig {
  // Bölgeye özel fiyatlandırma
  static const Map<String, Map<String, Map<String, dynamic>>> regionPricing = {
    'US': {
      'starter': {'price': 0, 'currency': '\$', 'features': ['3 danışan', 'AI özeti yok']},
      'pro': {'price': 12, 'currency': '\$', 'features': ['Sınırsız danışan', 'AI özet', 'PDF']},
      'enterprise': {'price': 49, 'currency': '\$', 'features': ['Tüm modüller', 'Çoklu şube']},
    },
    'EU': {
      'starter': {'price': 0, 'currency': '€', 'features': ['3 danışan', 'AI özeti yok']},
      'pro': {'price': 10, 'currency': '€', 'features': ['Sınırsız danışan', 'AI özet', 'PDF']},
      'enterprise': {'price': 45, 'currency': '€', 'features': ['Tüm modüller', 'Çoklu şube']},
    },
    'UK': {
      'starter': {'price': 0, 'currency': '£', 'features': ['3 danışan', 'AI özeti yok']},
      'pro': {'price': 9, 'currency': '£', 'features': ['Sınırsız danışan', 'AI özet', 'PDF']},
      'enterprise': {'price': 40, 'currency': '£', 'features': ['Tüm modüller', 'Çoklu şube']},
    },
    'CA': {
      'starter': {'price': 0, 'currency': 'C\$', 'features': ['3 danışan', 'AI özeti yok']},
      'pro': {'price': 16, 'currency': 'C\$', 'features': ['Sınırsız danışan', 'AI özet', 'PDF']},
      'enterprise': {'price': 65, 'currency': 'C\$', 'features': ['Tüm modüller', 'Çoklu şube']},
    },
    'TR': {
      'starter': {'price': 0, 'currency': '₺', 'features': ['3 danışan', 'AI özeti yok']},
      'pro': {'price': 150, 'currency': '₺', 'features': ['Sınırsız danışan', 'AI özet', 'PDF']},
      'enterprise': {'price': 600, 'currency': '₺', 'features': ['Tüm modüller', 'Çoklu şube']},
    },
  };

  // Aktif bölge için fiyatlandırma al
  static Map<String, dynamic> getPlan(String plan) {
    final region = RegionConfig.activeRegion;
    final pricing = regionPricing[region] ?? regionPricing['TR']!;
    return pricing[plan] ?? pricing['starter']!;
  }

  // Starter plan
  static Map<String, dynamic> get starterPlan => getPlan('starter');

  // Pro plan
  static Map<String, dynamic> get proPlan => getPlan('pro');

  // Enterprise plan
  static Map<String, dynamic> get enterprisePlan => getPlan('enterprise');
}
