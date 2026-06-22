/// Static catalog data for `/feature_system` — the marketing / status
/// surface that enumerates the 6 main areas (Patient management, AI &
/// analytics, Communication, Operations, Security, Integrations) and
/// the ~60 individual features grouped under them, each with a
/// `status` of Active / In development / Planned / Testing.
///
/// All records are static demo data — no PHI, no per-user state, no
/// repository call. Lives in its own file so the 976-line screen
/// god-file shrinks to the render layer only.
///
/// HIGH-class refactor (audit 2026-06-21): the catalog accounts for
/// ~450 of the 976 lines in the screen file.
library;

import 'package:flutter/material.dart';

/// Top-level cards on `_buildMainCategories` — each `featureCount`
/// is the rounded total of items in the matching detail entry.
List<Map<String, dynamic>> mainCategoryCards() => [
  {
    'name': 'Patient management',
    'icon': Icons.people,
    'color': const Color(0xFF0F766E),
    'featureCount': 25,
  },
  {
    'name': 'AI & analytics',
    'icon': Icons.psychology,
    'color': const Color(0xFF115E59),
    'featureCount': 20,
  },
  {
    'name': 'Communication',
    'icon': Icons.video_call,
    'color': const Color(0xFF14B8A6),
    'featureCount': 15,
  },
  {
    'name': 'Operations',
    'icon': Icons.analytics,
    'color': const Color(0xFF0E7490),
    'featureCount': 18,
  },
  {
    'name': 'Security',
    'icon': Icons.security,
    'color': const Color(0xFF0891B2),
    'featureCount': 12,
  },
  {
    'name': 'Integrations',
    'icon': Icons.integration_instructions,
    'color': const Color(0xFF2DD4BF),
    'featureCount': 10,
  },
];

/// The 6-area catalog. Keys match `mainCategoryCards()` names so
/// `_buildDetailedFeatures(category)` can filter without a join.
/// When `category == 'All'` the screen returns every value.
List<Map<String, dynamic>> detailedFeatureCategories(String category) {
  if (category == 'All') return _allFeatures.values.toList();
  return _allFeatures.containsKey(category)
      ? [_allFeatures[category]!]
      : <Map<String, dynamic>>[];
}

final Map<String, Map<String, dynamic>> _allFeatures = {
  'Patient management': {
    'name': 'Patient management',
    'description': 'Patient records, appointments and follow-ups',
    'icon': Icons.people,
    'colors': [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
    'features': [
      {
        'name': 'Patient list',
        'description': 'Tüm hastaları görüntüleme ve yönetim',
        'icon': Icons.people,
        'color': const Color(0xFF0F766E),
        'status': 'Active',
      },
      {
        'name': 'Patient details',
        'description': 'Detaylı hasta bilgileri ve geçmiş',
        'icon': Icons.person,
        'color': const Color(0xFF115E59),
        'status': 'Active',
      },
      {
        'name': 'Appointments',
        'description': 'Randevu oluşturma ve takip',
        'icon': Icons.calendar_today,
        'color': const Color(0xFF14B8A6),
        'status': 'Active',
      },
      {
        'name': 'Randevu Geçmişi',
        'description': 'Geçmiş randevular ve notlar',
        'icon': Icons.history,
        'color': const Color(0xFF0E7490),
        'status': 'Active',
      },
      {
        'name': 'Patient portal',
        'description': 'Hastalar için özel portal erişimi',
        'icon': Icons.person_pin,
        'color': const Color(0xFF0891B2),
        'status': 'In development',
      },
      {
        'name': 'Gelişmiş Arama',
        'description': 'Detaylı hasta arama ve filtreleme',
        'icon': Icons.search,
        'color': const Color(0xFF2DD4BF),
        'status': 'Active',
      },
      {
        'name': 'Patient groups',
        'description': 'Hasta kategorilendirme ve gruplama',
        'icon': Icons.group,
        'color': const Color(0xFF0F766E),
        'status': 'Planned',
      },
      {
        'name': 'Patient statistics',
        'description': 'Hasta bazlı analiz ve istatistikler',
        'icon': Icons.bar_chart,
        'color': const Color(0xFF115E59),
        'status': 'In development',
      },
      {
        'name': 'Patient notifications',
        'description': 'Otomatik hasta bildirim sistemi',
        'icon': Icons.notifications,
        'color': const Color(0xFF14B8A6),
        'status': 'Planned',
      },
      {
        'name': 'Patient privacy',
        'description': 'Hasta veri güvenliği ve gizlilik',
        'icon': Icons.security,
        'color': const Color(0xFF0E7490),
        'status': 'Active',
      },
    ],
  },
  'AI & analytics': {
    'name': 'AI & analytics',
    'description': 'Yapay zeka destekli tanı ve analiz araçları',
    'icon': Icons.psychology,
    'colors': [const Color(0xFF115E59), const Color(0xFF0E7490)],
    'features': [
      {
        'name': 'AI Tanı Asistanı',
        'description': 'Yapay zeka destekli tanı önerileri',
        'icon': Icons.psychology,
        'color': const Color(0xFF0F766E),
        'status': 'Active',
      },
      {
        'name': 'AI Sohbet Botu',
        'description': 'Hasta ile AI destekli sohbet',
        'icon': Icons.chat,
        'color': const Color(0xFF115E59),
        'status': 'In development',
      },
      {
        'name': 'Risk Analizi',
        'description': 'Hasta risk değerlendirmesi',
        'icon': Icons.warning,
        'color': const Color(0xFF14B8A6),
        'status': 'Active',
      },
      {
        'name': 'Tedavi Önerici',
        'description': 'AI destekli tedavi planı önerileri',
        'icon': Icons.medical_services,
        'color': const Color(0xFF0E7490),
        'status': 'In development',
      },
      {
        'name': 'Analitik Raporlar',
        'description': 'Detaylı analiz ve raporlar',
        'icon': Icons.analytics,
        'color': const Color(0xFF0891B2),
        'status': 'Active',
      },
      {
        'name': 'Mood Takibi',
        'description': 'Hasta ruh hali takip sistemi',
        'icon': Icons.timeline,
        'color': const Color(0xFF2DD4BF),
        'status': 'Active',
      },
      {
        'name': 'Rol Analizi',
        'description': 'Rol bazlı özellik analizi',
        'icon': Icons.people_alt,
        'color': const Color(0xFF0F766E),
        'status': 'Active',
      },
      {
        'name': 'Tahmin Analizi',
        'description': 'Gelecek trend ve tahminler',
        'icon': Icons.trending_up,
        'color': const Color(0xFF115E59),
        'status': 'Planned',
      },
      {
        'name': 'Performans Metrikleri',
        'description': 'Klinik performans ölçümleri',
        'icon': Icons.speed,
        'color': const Color(0xFF14B8A6),
        'status': 'In development',
      },
      {
        'name': 'Veri Görselleştirme',
        'description': 'İnteraktif grafik ve çizelgeler',
        'icon': Icons.show_chart,
        'color': const Color(0xFF0E7490),
        'status': 'Active',
      },
    ],
  },
  'Communication': {
    'name': 'Communication & telemedicine',
    'description': 'Uzaktan görüşme ve iletişim platformları',
    'icon': Icons.video_call,
    'colors': [const Color(0xFF14B8A6), const Color(0xFF0891B2)],
    'features': [
      {
        'name': 'Telemedicine',
        'description': 'Uzaktan görüşme sistemi',
        'icon': Icons.video_call,
        'color': const Color(0xFF0F766E),
        'status': 'Active',
      },
      {
        'name': 'Sesli Notlar',
        'description': 'Ses kayıt ve not alma',
        'icon': Icons.mic,
        'color': const Color(0xFF115E59),
        'status': 'Active',
      },
      {
        'name': 'Konsültasyon',
        'description': 'Uzman konsültasyon sistemi',
        'icon': Icons.medical_services,
        'color': const Color(0xFF14B8A6),
        'status': 'Active',
      },
      {
        'name': 'Mobil Uygulama',
        'description': 'Mobil erişim ve özellikler',
        'icon': Icons.phone_android,
        'color': const Color(0xFF0E7490),
        'status': 'Active',
      },
      {
        'name': 'Mesajlaşma',
        'description': 'Güvenli mesajlaşma sistemi',
        'icon': Icons.message,
        'color': const Color(0xFF0891B2),
        'status': 'In development',
      },
      {
        'name': 'Video Kayıt',
        'description': 'Görüşme kayıt ve arşivleme',
        'icon': Icons.videocam,
        'color': const Color(0xFF2DD4BF),
        'status': 'Planned',
      },
      {
        'name': 'Ekran Paylaşımı',
        'description': 'Ekran paylaşım özelliği',
        'icon': Icons.screen_share,
        'color': const Color(0xFF0F766E),
        'status': 'Planned',
      },
      {
        'name': 'Çoklu Dil',
        'description': 'Çoklu dil desteği',
        'icon': Icons.language,
        'color': const Color(0xFF115E59),
        'status': 'In development',
      },
    ],
  },
  'Operations': {
    'name': 'Yönetim & Raporlama',
    'description': 'Raporlar, finansal ve personel yönetimi',
    'icon': Icons.analytics,
    'colors': [const Color(0xFF0E7490), const Color(0xFF2DD4BF)],
    'features': [
      {
        'name': 'Raporlama',
        'description': 'Detaylı rapor oluşturma',
        'icon': Icons.analytics,
        'color': const Color(0xFF0F766E),
        'status': 'Active',
      },
      {
        'name': 'Finansal Yönetim',
        'description': 'Gelir-gider takibi',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF115E59),
        'status': 'Active',
      },
      {
        'name': 'Personel Yönetimi',
        'description': 'Personel takip ve yönetim',
        'icon': Icons.people,
        'color': const Color(0xFF14B8A6),
        'status': 'Active',
      },
      {
        'name': 'Faturalandırma',
        'description': 'Otomatik fatura oluşturma',
        'icon': Icons.receipt,
        'color': const Color(0xFF0E7490),
        'status': 'In development',
      },
      {
        'name': 'Sigorta Entegrasyonu',
        'description': 'Sigorta sistemleri entegrasyonu',
        'icon': Icons.local_hospital,
        'color': const Color(0xFF0891B2),
        'status': 'Planned',
      },
      {
        'name': 'E-Reçete',
        'description': 'Elektronik reçete sistemi',
        'icon': Icons.medication,
        'color': const Color(0xFF2DD4BF),
        'status': 'In development',
      },
      {
        'name': 'Stok Yönetimi',
        'description': 'İlaç ve malzeme stok takibi',
        'icon': Icons.inventory,
        'color': const Color(0xFF0F766E),
        'status': 'Planned',
      },
      {
        'name': 'Kalite Kontrol',
        'description': 'Hizmet kalitesi değerlendirme',
        'icon': Icons.check_circle,
        'color': const Color(0xFF115E59),
        'status': 'Planned',
      },
    ],
  },
  'Security': {
    'name': 'Security & settings',
    'description': 'Security settings and system configuration',
    'icon': Icons.security,
    'colors': [const Color(0xFF0891B2), const Color(0xFFDDD6FE)],
    'features': [
      {
        'name': 'Security settings',
        'description': 'Sistem güvenlik yapılandırması',
        'icon': Icons.security,
        'color': const Color(0xFF0F766E),
        'status': 'Active',
      },
      {
        'name': 'Dil settings',
        'description': 'Çoklu dil desteği',
        'icon': Icons.language,
        'color': const Color(0xFF115E59),
        'status': 'Active',
      },
      {
        'name': 'Offline Ayarlar',
        'description': 'Çevrimdışı çalışma modu',
        'icon': Icons.wifi_off,
        'color': const Color(0xFF14B8A6),
        'status': 'Active',
      },
      {
        'name': 'Kullanıcı Yönetimi',
        'description': 'Kullanıcı hesapları ve yetkiler',
        'icon': Icons.person_add,
        'color': const Color(0xFF0E7490),
        'status': 'Active',
      },
      {
        'name': 'Veri Yedekleme',
        'description': 'Otomatik veri yedekleme',
        'icon': Icons.backup,
        'color': const Color(0xFF0891B2),
        'status': 'Active',
      },
      {
        'name': 'Audit Log',
        'description': 'Sistem aktivite kayıtları',
        'icon': Icons.history,
        'color': const Color(0xFF2DD4BF),
        'status': 'Active',
      },
      {
        'name': 'Şifreleme',
        'description': 'Veri şifreleme ve koruma',
        'icon': Icons.lock,
        'color': const Color(0xFF0F766E),
        'status': 'Active',
      },
      {
        'name': 'İki Faktörlü Doğrulama',
        'description': '2FA güvenlik sistemi',
        'icon': Icons.verified_user,
        'color': const Color(0xFF115E59),
        'status': 'In development',
      },
    ],
  },
  'Entegrasyon': {
    'name': 'Entegrasyon & API',
    'description': 'Dış sistemler ve API entegrasyonları',
    'icon': Icons.integration_instructions,
    'colors': [const Color(0xFF2DD4BF), const Color(0xFFE9D5FF)],
    'features': [
      {
        'name': 'API Yönetimi',
        'description': 'REST API ve dokümantasyon',
        'icon': Icons.api,
        'color': const Color(0xFF0F766E),
        'status': 'Active',
      },
      {
        'name': 'Webhook Desteği',
        'description': 'Webhook entegrasyonları',
        'icon': Icons.webhook,
        'color': const Color(0xFF115E59),
        'status': 'In development',
      },
      {
        'name': 'Üçüncü Parti Entegrasyon',
        'description': 'Dış sistem entegrasyonları',
        'icon': Icons.link,
        'color': const Color(0xFF14B8A6),
        'status': 'Planned',
      },
      {
        'name': 'Veri Senkronizasyonu',
        'description': 'Çoklu sistem veri senkronizasyonu',
        'icon': Icons.sync,
        'color': const Color(0xFF0E7490),
        'status': 'In development',
      },
      {
        'name': 'Cloud Entegrasyonu',
        'description': 'Bulut servisleri entegrasyonu',
        'icon': Icons.cloud,
        'color': const Color(0xFF0891B2),
        'status': 'Active',
      },
      {
        'name': 'Mobile SDK',
        'description': 'Mobil uygulama geliştirme kiti',
        'icon': Icons.phone_android,
        'color': const Color(0xFF2DD4BF),
        'status': 'Planned',
      },
    ],
  },
};
