import 'package:flutter/foundation.dart';

// Ülke bazlı ilaç sistemi konfigürasyonu
class CountryConfig {
  // Desteklenen ülkeler ve ilaç sistemleri
  static const Map<String, Map<String, dynamic>> supportedCountries = {
    'US': {
      'name': 'United States',
      'nativeName': 'United States',
      'flag': '🇺🇸',
      'currency': 'USD',
      'language': 'en',
      'primarySystem': 'FDA',
      'secondarySystems': ['WHO'],
      'timezone': 'America/New_York',
      'regulatoryBody': 'FDA (Food and Drug Administration)',
      'drugDatabase': 'Orange Book',
      'approvalProcess': 'NDA/ANDA',
      'patentSystem': true,
      'genericSubstitution': true,
      'prescriptionRequired': true,
      'otcAvailable': true,
      'insuranceCoverage': 'Private + Medicare/Medicaid',
      'pharmacyRegulation': 'State Boards',
      'clinicalGuidelines': 'USPSTF, AAFP, ACP',
      'drugInteractions': 'Micromedex, Lexicomp',
      'sideEffects': 'FDA Adverse Event Reporting System',
      'dosageGuidelines': 'FDA Labeling',
      'pregnancyCategories': ['A', 'B', 'C', 'D', 'X'],
      'lactationCategories': ['L1', 'L2', 'L3', 'L4', 'L5'],
      'renalAdjustments': true,
      'hepaticAdjustments': true,
      'geneticTesting': true,
      'pharmacogenomics': true,
    },
    
    'TR': {
      'name': 'Turkey',
      'nativeName': 'Türkiye',
      'flag': '🇹🇷',
      'currency': 'TRY',
      'language': 'tr',
      'primarySystem': 'Turkey',
      'secondarySystems': ['WHO', 'EMA'],
      'timezone': 'Europe/Istanbul',
      'regulatoryBody': 'TİTCK (Türkiye İlaç ve Tıbbi Cihaz Kurumu)',
      'drugDatabase': 'Türkiye İlaç Veritabanı',
      'approvalProcess': 'Ruhsat Sistemi',
      'patentSystem': true,
      'genericSubstitution': true,
      'prescriptionRequired': true,
      'otcAvailable': true,
      'insuranceCoverage': 'SGK (Sosyal Güvenlik Kurumu)',
      'pharmacyRegulation': 'Sağlık Bakanlığı',
      'clinicalGuidelines': 'Türkiye Klinik Rehberleri',
      'drugInteractions': 'Türkiye İlaç Etkileşim Veritabanı',
      'sideEffects': 'TİTCK Yan Etki Bildirim Sistemi',
      'dosageGuidelines': 'Türkiye Doz Rehberleri',
      'pregnancyCategories': ['Güvenli', 'Dikkatli', 'Kaçınılmalı'],
      'lactationCategories': ['Emzirmede Güvenli', 'Dikkatli', 'Kaçınılmalı'],
      'renalAdjustments': true,
      'hepaticAdjustments': true,
      'geneticTesting': false,
      'pharmacogenomics': false,
    },
    
    'DE': {
      'name': 'Germany',
      'nativeName': 'Deutschland',
      'flag': '🇩🇪',
      'currency': 'EUR',
      'language': 'de',
      'primarySystem': 'EMA',
      'secondarySystems': ['WHO', 'BfArM'],
      'timezone': 'Europe/Berlin',
      'regulatoryBody': 'BfArM (Bundesinstitut für Arzneimittel und Medizinprodukte)',
      'drugDatabase': 'Rote Liste',
      'approvalProcess': 'EMA + National Authorization',
      'patentSystem': true,
      'genericSubstitution': true,
      'prescriptionRequired': true,
      'otcAvailable': true,
      'insuranceCoverage': 'Statutory Health Insurance',
      'pharmacyRegulation': 'Apothekenkammer',
      'clinicalGuidelines': 'AWMF Guidelines',
      'drugInteractions': 'ABDA Database',
      'sideEffects': 'BfArM Adverse Drug Reaction Database',
      'dosageGuidelines': 'Fachinformation',
      'pregnancyCategories': ['A', 'B', 'C', 'D', 'X'],
      'lactationCategories': ['L1', 'L2', 'L3', 'L4', 'L5'],
      'renalAdjustments': true,
      'hepaticAdjustments': true,
      'geneticTesting': true,
      'pharmacogenomics': true,
    },
    
    'FR': {
      'name': 'France',
      'nativeName': 'France',
      'flag': '🇫🇷',
      'currency': 'EUR',
      'language': 'fr',
      'primarySystem': 'EMA',
      'secondarySystems': ['WHO', 'ANSM'],
      'timezone': 'Europe/Paris',
      'regulatoryBody': 'ANSM (Agence nationale de sécurité du médicament)',
      'drugDatabase': 'Vidal',
      'approvalProcess': 'EMA + National Authorization',
      'patentSystem': true,
      'genericSubstitution': true,
      'prescriptionRequired': true,
      'otcAvailable': true,
      'insuranceCoverage': 'Sécurité Sociale',
      'pharmacyRegulation': 'Ordre des Pharmaciens',
      'clinicalGuidelines': 'HAS Guidelines',
      'drugInteractions': 'Thériaque Database',
      'sideEffects': 'ANSM Pharmacovigilance',
      'dosageGuidelines': 'Résumé des Caractéristiques du Produit',
      'pregnancyCategories': ['A', 'B', 'C', 'D', 'X'],
      'lactationCategories': ['L1', 'L2', 'L3', 'L4', 'L5'],
      'renalAdjustments': true,
      'hepaticAdjustments': true,
      'geneticTesting': true,
      'pharmacogenomics': true,
    },
    
    'NL': {
      'name': 'Netherlands',
      'nativeName': 'Nederland',
      'flag': '🇳🇱',
      'currency': 'EUR',
      'language': 'nl',
      'primarySystem': 'EMA',
      'secondarySystems': ['WHO', 'CBG'],
      'timezone': 'Europe/Amsterdam',
      'regulatoryBody': 'CBG (College ter Beoordeling van Geneesmiddelen)',
      'drugDatabase': 'Farmacotherapeutisch Kompas',
      'approvalProcess': 'EMA + National Authorization',
      'patentSystem': true,
      'genericSubstitution': true,
      'prescriptionRequired': true,
      'otcAvailable': true,
      'insuranceCoverage': 'Basic Health Insurance',
      'pharmacyRegulation': 'Koninklijke Nederlandse Maatschappij ter bevordering der Pharmacie',
      'clinicalGuidelines': 'NHG Guidelines',
      'drugInteractions': 'KNMP Database',
      'sideEffects': 'Lareb Pharmacovigilance',
      'dosageGuidelines': 'SmPC',
      'pregnancyCategories': ['A', 'B', 'C', 'D', 'X'],
      'lactationCategories': ['L1', 'L2', 'L3', 'L4', 'L5'],
      'renalAdjustments': true,
      'hepaticAdjustments': true,
      'geneticTesting': true,
      'pharmacogenomics': true,
    },
    
    'CA': {
      'name': 'Canada',
      'nativeName': 'Canada',
      'flag': '🇨🇦',
      'currency': 'CAD',
      'language': 'en',
      'primarySystem': 'Health Canada',
      'secondarySystems': ['WHO', 'FDA'],
      'timezone': 'America/Toronto',
      'regulatoryBody': 'Health Canada',
      'drugDatabase': 'Drug Product Database',
      'approvalProcess': 'NDS/ANDS',
      'patentSystem': true,
      'genericSubstitution': true,
      'prescriptionRequired': true,
      'otcAvailable': true,
      'insuranceCoverage': 'Provincial + Private',
      'pharmacyRegulation': 'Provincial Colleges',
      'clinicalGuidelines': 'Canadian Medical Association',
      'drugInteractions': 'CPS Database',
      'sideEffects': 'Canada Vigilance Program',
      'dosageGuidelines': 'Product Monograph',
      'pregnancyCategories': ['A', 'B', 'C', 'D', 'X'],
      'lactationCategories': ['L1', 'L2', 'L3', 'L4', 'L5'],
      'renalAdjustments': true,
      'hepaticAdjustments': true,
      'geneticTesting': true,
      'pharmacogenomics': true,
    },
    
    'GB': {
      'name': 'United Kingdom',
      'nativeName': 'United Kingdom',
      'flag': '🇬🇧',
      'currency': 'GBP',
      'language': 'en',
      'primarySystem': 'EMA',
      'secondarySystems': ['WHO', 'MHRA'],
      'timezone': 'Europe/London',
      'regulatoryBody': 'MHRA (Medicines and Healthcare products Regulatory Agency)',
      'drugDatabase': 'British National Formulary',
      'approvalProcess': 'EMA + National Authorization',
      'patentSystem': true,
      'genericSubstitution': true,
      'prescriptionRequired': true,
      'otcAvailable': true,
      'insuranceCoverage': 'NHS',
      'pharmacyRegulation': 'General Pharmaceutical Council',
      'clinicalGuidelines': 'NICE Guidelines',
      'drugInteractions': 'BNF Database',
      'sideEffects': 'Yellow Card Scheme',
      'dosageGuidelines': 'Summary of Product Characteristics',
      'pregnancyCategories': ['A', 'B', 'C', 'D', 'X'],
      'lactationCategories': ['L1', 'L2', 'L3', 'L4', 'L5'],
      'renalAdjustments': true,
      'hepaticAdjustments': true,
      'geneticTesting': true,
      'pharmacogenomics': true,
    },
  };

  // Varsayılan ülke
  static const String defaultCountry = 'TR';

  // Mevcut seçili ülke
  static String _currentCountry = defaultCountry;

  // Ülke değiştirme
  static void setCountry(String countryCode) {
    if (supportedCountries.containsKey(countryCode.toUpperCase())) {
      _currentCountry = countryCode.toUpperCase();
    } else {
      _currentCountry = defaultCountry;
    }
  }

  // Mevcut ülke kodu
  static String get currentCountry => _currentCountry;

  // Mevcut ülke bilgileri
  static Map<String, dynamic> get currentCountryInfo => 
      supportedCountries[_currentCountry] ?? supportedCountries[defaultCountry]!;

  // Ülke adı
  static String get currentCountryName => currentCountryInfo['name'];

  // Yerel ülke adı
  static String get currentCountryNativeName => currentCountryInfo['nativeName'];

  // Bayrak
  static String get currentCountryFlag => currentCountryInfo['flag'];

  // Para birimi
  static String get currentCountryCurrency => currentCountryInfo['currency'];

  // Dil
  static String get currentCountryLanguage => currentCountryInfo['language'];

  // Birincil ilaç sistemi
  static String get currentPrimarySystem => currentCountryInfo['primarySystem'];

  // İkincil ilaç sistemleri
  static List<String> get currentSecondarySystems => 
      List<String>.from(currentCountryInfo['secondarySystems']);

  // Zaman dilimi
  static String get currentTimezone => currentCountryInfo['timezone'];

  // Düzenleyici kurum
  static String get currentRegulatoryBody => currentCountryInfo['regulatoryBody'];

  // İlaç veritabanı
  static String get currentDrugDatabase => currentCountryInfo['drugDatabase'];

  // Onay süreci
  static String get currentApprovalProcess => currentCountryInfo['approvalProcess'];

  // Patent sistemi
  static bool get hasPatentSystem => currentCountryInfo['patentSystem'];

  // Jenerik ikame
  static bool get hasGenericSubstitution => currentCountryInfo['genericSubstitution'];

  // Reçete gerekli
  static bool get requiresPrescription => currentCountryInfo['prescriptionRequired'];

  // OTC mevcut
  static bool get hasOTCAvailable => currentCountryInfo['otcAvailable'];

  // Sigorta kapsamı
  static String get currentInsuranceCoverage => currentCountryInfo['insuranceCoverage'];

  // Eczane düzenlemesi
  static String get currentPharmacyRegulation => currentCountryInfo['pharmacyRegulation'];

  // Klinik rehberleri
  static String get currentClinicalGuidelines => currentCountryInfo['clinicalGuidelines'];

  // İlaç etkileşimleri
  static String get currentDrugInteractions => currentCountryInfo['drugInteractions'];

  // Yan etkiler
  static String get currentSideEffects => currentCountryInfo['sideEffects'];

  // Doz rehberleri
  static String get currentDosageGuidelines => currentCountryInfo['dosageGuidelines'];

  // Gebelik kategorileri
  static List<String> get currentPregnancyCategories => 
      List<String>.from(currentCountryInfo['pregnancyCategories']);

  // Emzirme kategorileri
  static List<String> get currentLactationCategories => 
      List<String>.from(currentCountryInfo['lactationCategories']);

  // Böbrek ayarlamaları
  static bool get hasRenalAdjustments => currentCountryInfo['renalAdjustments'];

  // Karaciğer ayarlamaları
  static bool get hasHepaticAdjustments => currentCountryInfo['hepaticAdjustments'];

  // Genetik test
  static bool get hasGeneticTesting => currentCountryInfo['geneticTesting'];

  // Farmakogenomik
  static bool get hasPharmacogenomics => currentCountryInfo['pharmacogenomics'];

  // Desteklenen ülke mi?
  static bool isCountrySupported(String countryCode) {
    return supportedCountries.containsKey(countryCode.toUpperCase());
  }

  // Tüm desteklenen ülkeler
  static List<String> get allSupportedCountries => supportedCountries.keys.toList();

  // Ülke bilgilerini JSON olarak al
  static Map<String, dynamic> getCurrentCountryAsJson() {
    return {
      'countryCode': _currentCountry,
      'countryInfo': currentCountryInfo,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Ülke değişiklik geçmişi
  static final List<Map<String, dynamic>> _countryChangeHistory = [];

  // Ülke değişiklik geçmişini al
  static List<Map<String, dynamic>> get countryChangeHistory => _countryChangeHistory;

  // Ülke değişikliğini kaydet
  static void _logCountryChange(String fromCountry, String toCountry) {
    _countryChangeHistory.add({
      'fromCountry': fromCountry,
      'toCountry': toCountry,
      'timestamp': DateTime.now().toIso8601String(),
      'reason': 'User selection',
    });
    
    // Geçmişi 100 kayıtla sınırla
    if (_countryChangeHistory.length > 100) {
      _countryChangeHistory.removeAt(0);
    }
  }

  // Güvenli ülke değiştirme
  static bool changeCountry(String countryCode) {
    final oldCountry = _currentCountry;
    final newCountry = countryCode.toUpperCase();
    
    if (isCountrySupported(newCountry)) {
      setCountry(newCountry);
      _logCountryChange(oldCountry, newCountry);
      return true;
    }
    return false;
  }

  // Ülke bazlı özellik kontrolü
  static bool hasFeature(String feature) {
    switch (feature) {
      case 'patentSystem':
        return hasPatentSystem;
      case 'genericSubstitution':
        return hasGenericSubstitution;
      case 'renalAdjustments':
        return hasRenalAdjustments;
      case 'hepaticAdjustments':
        return hasHepaticAdjustments;
      case 'geneticTesting':
        return hasGeneticTesting;
      case 'pharmacogenomics':
        return hasPharmacogenomics;
      default:
        return false;
    }
  }

  // Ülke bazlı dil desteği
  static List<String> getSupportedLanguages() {
    final languages = <String>{};
    for (final country in supportedCountries.values) {
      languages.add(country['language']);
    }
    return languages.toList();
  }

  // Ülke bazlı para birimi desteği
  static List<String> getSupportedCurrencies() {
    final currencies = <String>{};
    for (final country in supportedCountries.values) {
      currencies.add(country['currency']);
    }
    return currencies.toList();
  }

  // Ülke bazlı zaman dilimi desteği
  static List<String> getSupportedTimezones() {
    final timezones = <String>{};
    for (final country in supportedCountries.values) {
      timezones.add(country['timezone']);
    }
    return timezones.toList();
  }

  // Ülke bazlı ilaç sistemi desteği
  static Map<String, List<String>> getDrugSystemSupport() {
    final support = <String, List<String>>{};
    for (final country in supportedCountries.values) {
      final primary = country['primarySystem'];
      final secondary = List<String>.from(country['secondarySystems']);
      
      if (!support.containsKey(primary)) {
        support[primary] = [];
      }
      support[primary]!.add(country['name']);
      
      for (final secondarySystem in secondary) {
        if (!support.containsKey(secondarySystem)) {
          support[secondarySystem] = [];
        }
        support[secondarySystem]!.add(country['name']);
      }
    }
    return support;
  }

  // Ülke bazlı özellik karşılaştırması
  static Map<String, Map<String, bool>> getFeatureComparison() {
    final comparison = <String, Map<String, bool>>{};
    
    for (final countryCode in supportedCountries.keys) {
      final country = supportedCountries[countryCode]!;
      comparison[countryCode] = {
        'patentSystem': country['patentSystem'],
        'genericSubstitution': country['genericSubstitution'],
        'renalAdjustments': country['renalAdjustments'],
        'hepaticAdjustments': country['hepaticAdjustments'],
        'geneticTesting': country['geneticTesting'],
        'pharmacogenomics': country['pharmacogenomics'],
      };
    }
    
    return comparison;
  }

  // Ülke bazlı istatistikler
  static Map<String, dynamic> getCountryStatistics() {
    return {
      'totalCountries': supportedCountries.length,
      'supportedLanguages': getSupportedLanguages().length,
      'supportedCurrencies': getSupportedCurrencies().length,
      'supportedTimezones': getSupportedTimezones().length,
      'drugSystems': getDrugSystemSupport().keys.length,
      'featureComparison': getFeatureComparison(),
      'currentCountry': _currentCountry,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}
