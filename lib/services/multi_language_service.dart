import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psyclinicai/models/global_language_models.dart';

/// Multi-Language Service for PsyClinicAI
/// Provides comprehensive multi-language support for global expansion
class MultiLanguageService {
  static final MultiLanguageService _instance = MultiLanguageService._internal();
  factory MultiLanguageService() => _instance;
  MultiLanguageService._internal();

  // Language data
  final Map<String, Language> _languages = {};
  final Map<String, TranslationKey> _translationKeys = {};
  final Map<String, RegionalConfig> _regionalConfigs = {};
  final Map<String, CulturalAdaptation> _culturalAdaptations = {};
  
  // Current state
  String _currentLanguage = 'en';
  String _currentRegion = 'US';
  LocalizationConfig? _localizationConfig;
  
  // Stream controllers for real-time updates
  final StreamController<String> _languageChangeController = StreamController<String>.broadcast();
  final StreamController<TranslationKey> _translationUpdateController = StreamController<TranslationKey>.broadcast();
  final StreamController<LanguageMetrics> _metricsController = StreamController<LanguageMetrics>.broadcast();

  Stream<String> get languageChangeStream => _languageChangeController.stream;
  Stream<TranslationKey> get translationUpdateStream => _translationUpdateController.stream;
  Stream<LanguageMetrics> get metricsStream => _metricsController.stream;

  /// Initialize the multi-language service
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _loadLanguages();
    await _loadRegionalConfigs();
    await _loadCulturalAdaptations();
    await _loadLocalizationConfig();
    print('✅ Multi-Language Service initialized with ${_languages.length} languages');
  }

  /// Load supported languages
  Future<void> _loadLanguages() async {
    final languages = [
      Language(
        code: 'en',
        name: 'English',
        nativeName: 'English',
        direction: LanguageDirection.ltr,
        flag: '🇺🇸',
        isSupported: true,
        isRTL: false,
        regions: ['US', 'GB', 'CA', 'AU', 'NZ'],
        translations: {'en': 'English'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        completionPercentage: 100.0,
      ),
      Language(
        code: 'es',
        name: 'Spanish',
        nativeName: 'Español',
        direction: LanguageDirection.ltr,
        flag: '🇪🇸',
        isSupported: true,
        isRTL: false,
        regions: ['ES', 'MX', 'AR', 'CO', 'PE'],
        translations: {'en': 'Spanish', 'es': 'Español'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
        completionPercentage: 95.2,
      ),
      Language(
        code: 'fr',
        name: 'French',
        nativeName: 'Français',
        direction: LanguageDirection.ltr,
        flag: '🇫🇷',
        isSupported: true,
        isRTL: false,
        regions: ['FR', 'CA', 'BE', 'CH', 'LU'],
        translations: {'en': 'French', 'fr': 'Français'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 15)),
        completionPercentage: 92.8,
      ),
      Language(
        code: 'de',
        name: 'German',
        nativeName: 'Deutsch',
        direction: LanguageDirection.ltr,
        flag: '🇩🇪',
        isSupported: true,
        isRTL: false,
        regions: ['DE', 'AT', 'CH', 'LI'],
        translations: {'en': 'German', 'de': 'Deutsch'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 12)),
        completionPercentage: 89.5,
      ),
      Language(
        code: 'it',
        name: 'Italian',
        nativeName: 'Italiano',
        direction: LanguageDirection.ltr,
        flag: '🇮🇹',
        isSupported: true,
        isRTL: false,
        regions: ['IT', 'CH', 'SM', 'VA'],
        translations: {'en': 'Italian', 'it': 'Italiano'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 18)),
        completionPercentage: 87.3,
      ),
      Language(
        code: 'pt',
        name: 'Portuguese',
        nativeName: 'Português',
        direction: LanguageDirection.ltr,
        flag: '🇵🇹',
        isSupported: true,
        isRTL: false,
        regions: ['PT', 'BR', 'AO', 'MZ'],
        translations: {'en': 'Portuguese', 'pt': 'Português'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
        completionPercentage: 84.7,
      ),
      Language(
        code: 'ru',
        name: 'Russian',
        nativeName: 'Русский',
        direction: LanguageDirection.ltr,
        flag: '🇷🇺',
        isSupported: true,
        isRTL: false,
        regions: ['RU', 'BY', 'KZ', 'KG'],
        translations: {'en': 'Russian', 'ru': 'Русский'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 25)),
        completionPercentage: 78.9,
      ),
      Language(
        code: 'zh',
        name: 'Chinese (Simplified)',
        nativeName: '中文',
        direction: LanguageDirection.ltr,
        flag: '🇨🇳',
        isSupported: true,
        isRTL: false,
        regions: ['CN', 'SG', 'MY'],
        translations: {'en': 'Chinese (Simplified)', 'zh': '中文'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
        completionPercentage: 76.4,
      ),
      Language(
        code: 'ja',
        name: 'Japanese',
        nativeName: '日本語',
        direction: LanguageDirection.ltr,
        flag: '🇯🇵',
        isSupported: true,
        isRTL: false,
        regions: ['JP'],
        translations: {'en': 'Japanese', 'ja': '日本語'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 35)),
        completionPercentage: 72.1,
      ),
      Language(
        code: 'ko',
        name: 'Korean',
        nativeName: '한국어',
        direction: LanguageDirection.ltr,
        flag: '🇰🇷',
        isSupported: true,
        isRTL: false,
        regions: ['KR', 'KP'],
        translations: {'en': 'Korean', 'ko': '한국어'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 40)),
        completionPercentage: 68.5,
      ),
      Language(
        code: 'ar',
        name: 'Arabic',
        nativeName: 'العربية',
        direction: LanguageDirection.rtl,
        flag: '🇸🇦',
        isSupported: true,
        isRTL: true,
        regions: ['SA', 'AE', 'EG', 'JO', 'LB'],
        translations: {'en': 'Arabic', 'ar': 'العربية'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 45)),
        completionPercentage: 65.2,
      ),
      Language(
        code: 'tr',
        name: 'Turkish',
        nativeName: 'Türkçe',
        direction: LanguageDirection.ltr,
        flag: '🇹🇷',
        isSupported: true,
        isRTL: false,
        regions: ['TR', 'CY'],
        translations: {'en': 'Turkish', 'tr': 'Türkçe'},
        lastUpdated: DateTime.now().subtract(const Duration(days: 50)),
        completionPercentage: 61.8,
      ),
    ];

    for (final language in languages) {
      _languages[language.code] = language;
    }
  }

  /// Load regional configurations
  Future<void> _loadRegionalConfigs() async {
    final configs = [
      RegionalConfig(
        regionCode: 'US',
        regionName: 'United States',
        defaultLanguage: 'en',
        supportedLanguages: ['en', 'es'],
        currency: 'USD',
        timezone: 'America/New_York',
        dateFormat: 'MM/dd/yyyy',
        numberFormat: '#,##0.00',
        culturalSettings: {
          'greeting': 'Hello',
          'date_preference': 'month_first',
          'time_format': '12_hour',
        },
        complianceFrameworks: ['HIPAA', 'SOC2'],
        legalRequirements: {
          'data_retention': '7_years',
          'privacy_notice': 'required',
        },
      ),
      RegionalConfig(
        regionCode: 'EU',
        regionName: 'European Union',
        defaultLanguage: 'en',
        supportedLanguages: ['en', 'de', 'fr', 'it', 'es', 'pt'],
        currency: 'EUR',
        timezone: 'Europe/Brussels',
        dateFormat: 'dd/MM/yyyy',
        numberFormat: '#,##0,00',
        culturalSettings: {
          'greeting': 'Hello',
          'date_preference': 'day_first',
          'time_format': '24_hour',
        },
        complianceFrameworks: ['GDPR', 'SOC2'],
        legalRequirements: {
          'data_retention': '5_years',
          'privacy_notice': 'required',
          'right_to_forget': 'required',
        },
      ),
      RegionalConfig(
        regionCode: 'TR',
        regionName: 'Turkey',
        defaultLanguage: 'tr',
        supportedLanguages: ['tr', 'en'],
        currency: 'TRY',
        timezone: 'Europe/Istanbul',
        dateFormat: 'dd.MM.yyyy',
        numberFormat: '#,##0,00',
        culturalSettings: {
          'greeting': 'Merhaba',
          'date_preference': 'day_first',
          'time_format': '24_hour',
        },
        complianceFrameworks: ['KVKK'],
        legalRequirements: {
          'data_retention': '10_years',
          'privacy_notice': 'required',
        },
      ),
      RegionalConfig(
        regionCode: 'JP',
        regionName: 'Japan',
        defaultLanguage: 'ja',
        supportedLanguages: ['ja', 'en'],
        currency: 'JPY',
        timezone: 'Asia/Tokyo',
        dateFormat: 'yyyy/MM/dd',
        numberFormat: '#,##0',
        culturalSettings: {
          'greeting': 'こんにちは',
          'date_preference': 'year_first',
          'time_format': '24_hour',
        },
        complianceFrameworks: ['PIPA'],
        legalRequirements: {
          'data_retention': '5_years',
          'privacy_notice': 'required',
        },
      ),
    ];

    for (final config in configs) {
      _regionalConfigs[config.regionCode] = config;
    }
  }

  /// Load cultural adaptations
  Future<void> _loadCulturalAdaptations() async {
    final adaptations = [
      CulturalAdaptation(
        regionCode: 'US',
        languageCode: 'en',
        culturalPreferences: {
          'communication_style': 'direct',
          'formality_level': 'casual',
          'personal_space': 'moderate',
        },
        sensitiveTopics: {
          'mental_health': ['depression', 'anxiety', 'suicide'],
          'religion': ['beliefs', 'practices'],
          'politics': ['voting', 'parties'],
        },
        colorMeanings: {
          'red': 'danger_warning',
          'blue': 'trust_calm',
          'green': 'success_growth',
        },
        symbolMeanings: {
          'thumbs_up': 'approval',
          'ok_sign': 'agreement',
          'peace_sign': 'harmony',
        },
        culturalTaboos: ['pointing_finger', 'showing_sole'],
        greetingStyles: {
          'formal': 'handshake',
          'casual': 'wave_nod',
        },
        communicationStyles: {
          'directness': 'high',
          'context_dependency': 'low',
        },
      ),
      CulturalAdaptation(
        regionCode: 'TR',
        languageCode: 'tr',
        culturalPreferences: {
          'communication_style': 'warm',
          'formality_level': 'respectful',
          'personal_space': 'close',
        },
        sensitiveTopics: {
          'mental_health': ['depresyon', 'anksiyete', 'intihar'],
          'family': ['relationships', 'marriage'],
          'religion': ['inanc', 'ibadet'],
        },
        colorMeanings: {
          'kirmizi': 'enerji_cesaret',
          'mavi': 'guven_huzur',
          'yesil': 'umut_buyume',
        },
        symbolMeanings: {
          'bas_parmak': 'onay',
          'el_sikisma': 'dostluk',
          'gulumseme': 'sicaklik',
        },
        culturalTaboos: ['ayak_gosterme', 'parmak_isaret'],
        greetingStyles: {
          'formal': 'el_sikisma',
          'casual': 'sarilma_opucuk',
        },
        communicationStyles: {
          'directness': 'medium',
          'context_dependency': 'high',
        },
      ),
    ];

    for (final adaptation in adaptations) {
      final key = '${adaptation.regionCode}_${adaptation.languageCode}';
      _culturalAdaptations[key] = adaptation;
    }
  }

  /// Load localization configuration
  Future<void> _loadLocalizationConfig() async {
    _localizationConfig = LocalizationConfig(
      defaultLanguage: 'en',
      supportedLanguages: _languages.keys.toList(),
      languageSettings: _languages.map((key, language) => MapEntry(key, LanguageSettings(
        languageCode: key,
        enabled: language.isSupported,
        enabledAt: DateTime.now().subtract(const Duration(days: 30)),
        enabledBy: 'system',
        features: {
          'ui_translation': true,
          'content_translation': true,
          'voice_support': key == 'en' || key == 'es' || key == 'fr',
          'ai_translation': true,
        },
        customTranslations: {},
        regionalVariants: language.regions,
      ))),
      autoDetectLanguage: true,
      fallbackToDefault: true,
      regionLanguageMapping: {
        'US': 'en',
        'GB': 'en',
        'ES': 'es',
        'FR': 'fr',
        'DE': 'de',
        'IT': 'it',
        'TR': 'tr',
        'JP': 'ja',
        'CN': 'zh',
        'KR': 'ko',
        'SA': 'ar',
      },
    );
  }

  /// Get current language
  String get currentLanguage => _currentLanguage;

  /// Get current region
  String get currentRegion => _currentRegion;

  /// Get current language object
  Language? get currentLanguageObject => _languages[_currentLanguage];

  /// Get current regional config
  RegionalConfig? get currentRegionalConfig => _regionalConfigs[_currentRegion];

  /// Change current language
  Future<void> changeLanguage(String languageCode) async {
    if (_languages.containsKey(languageCode) && _languages[languageCode]!.isSupported) {
      _currentLanguage = languageCode;
      _languageChangeController.add(languageCode);
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);
      
      print('🌍 Language changed to: $languageCode');
    } else {
      throw Exception('Language not supported: $languageCode');
    }
  }

  /// Change current region
  Future<void> changeRegion(String regionCode) async {
    if (_regionalConfigs.containsKey(regionCode)) {
      _currentRegion = regionCode;
      
      // Auto-detect language for region
      final regionConfig = _regionalConfigs[regionCode]!;
      if (regionConfig.defaultLanguage != _currentLanguage) {
        await changeLanguage(regionConfig.defaultLanguage);
      }
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_region', regionCode);
      
      print('🌍 Region changed to: $regionCode');
    } else {
      throw Exception('Region not supported: $regionCode');
    }
  }

  /// Get translation for a key
  String getTranslation(String key, {String? languageCode, String? category}) {
    final lang = languageCode ?? _currentLanguage;
    final translationKey = _translationKeys[key];
    
    if (translationKey != null && translationKey.translations.containsKey(lang)) {
      return translationKey.translations[lang]!;
    }
    
    // Fallback to English
    if (lang != 'en' && translationKey?.translations.containsKey('en') == true) {
      return translationKey!.translations['en']!;
    }
    
    // Return key if no translation found
    return key;
  }

  /// Add or update translation
  Future<void> addTranslation(String key, String category, Map<String, String> translations) async {
    final translationKey = TranslationKey(
      key: key,
      category: category,
      description: 'Translation for $key',
      translations: translations,
      status: TranslationStatus.draft,
      lastUpdated: DateTime.now(),
      updatedBy: 'system',
      tags: [category],
      isContextual: false,
    );
    
    _translationKeys[key] = translationKey;
    _translationUpdateController.add(translationKey);
    
    print('🌍 Added translation for key: $key');
  }

  /// Get all supported languages
  List<Language> getSupportedLanguages() {
    return _languages.values.where((lang) => lang.isSupported).toList();
  }

  /// Get all regional configs
  List<RegionalConfig> getAllRegionalConfigs() {
    return _regionalConfigs.values.toList();
  }

  /// Get cultural adaptation for current region and language
  CulturalAdaptation? getCulturalAdaptation() {
    final key = '${_currentRegion}_${_currentLanguage}';
    return _culturalAdaptations[key];
  }

  /// Detect language from text
  Future<LanguageDetectionResult> detectLanguage(String text) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Simple language detection based on common words
    // In production, use proper NLP libraries
    final random = Random();
    String detectedLang = 'en';
    double confidence = 0.8;
    
    if (text.contains('hola') || text.contains('gracias')) {
      detectedLang = 'es';
      confidence = 0.9;
    } else if (text.contains('bonjour') || text.contains('merci')) {
      detectedLang = 'fr';
      confidence = 0.9;
    } else if (text.contains('hallo') || text.contains('danke')) {
      detectedLang = 'de';
      confidence = 0.9;
    } else if (text.contains('merhaba') || text.contains('teşekkür')) {
      detectedLang = 'tr';
      confidence = 0.9;
    }
    
    return LanguageDetectionResult(
      detectedLanguage: detectedLang,
      confidence: confidence + (random.nextDouble() * 0.1),
      alternatives: [
        LanguageProbability(languageCode: 'en', probability: 0.1),
        LanguageProbability(languageCode: 'es', probability: 0.05),
      ],
      isReliable: confidence > 0.7,
      detectionMethod: 'keyword_based',
    );
  }

  /// Get language metrics
  Future<LanguageMetrics> getLanguageMetrics(String languageCode) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final language = _languages[languageCode];
    if (language == null) {
      throw Exception('Language not found: $languageCode');
    }
    
    final totalKeys = _translationKeys.length;
    final translatedKeys = _translationKeys.values
        .where((key) => key.translations.containsKey(languageCode))
        .length;
    
    final completionRate = totalKeys > 0 ? (translatedKeys / totalKeys) * 100 : 0.0;
    final accuracyRate = 85.0 + (Random().nextDouble() * 15.0); // Simulated accuracy
    
    return LanguageMetrics(
      languageCode: languageCode,
      totalKeys: totalKeys,
      translatedKeys: translatedKeys,
      reviewedKeys: (translatedKeys * 0.8).round(),
      approvedKeys: (translatedKeys * 0.7).round(),
      completionRate: completionRate,
      accuracyRate: accuracyRate,
      lastActivity: language.lastUpdated,
      activeContributors: ['translator_1', 'translator_2'],
      categoryBreakdown: {
        'ui': (translatedKeys * 0.4).round(),
        'content': (translatedKeys * 0.3).round(),
        'medical': (translatedKeys * 0.2).round(),
        'system': (translatedKeys * 0.1).round(),
      },
    );
  }

  /// Get localization report
  Future<LocalizationReport> getLocalizationReport() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final languageMetrics = <String, LanguageMetrics>{};
    final activeProjects = <TranslationProject>[];
    final languagesNeedingAttention = <String>[];
    
    // Generate metrics for each language
    for (final language in _languages.values) {
      if (language.isSupported) {
        final metrics = await getLanguageMetrics(language.code);
        languageMetrics[language.code] = metrics;
        
        if (metrics.completionRate < 80.0) {
          languagesNeedingAttention.add(language.code);
        }
      }
    }
    
    return LocalizationReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      generatedBy: 'system',
      languageMetrics: languageMetrics,
      activeProjects: activeProjects,
      languagesNeedingAttention: languagesNeedingAttention,
      translationRequests: {
        'es': 15,
        'fr': 12,
        'de': 8,
        'tr': 6,
      },
      userSatisfaction: {
        'en': 95.0,
        'es': 88.0,
        'fr': 85.0,
        'de': 82.0,
        'tr': 78.0,
      },
    );
  }

  /// Load user preferences
  Future<void> loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selected_language');
    final savedRegion = prefs.getString('selected_region');
    
    if (savedLanguage != null && _languages.containsKey(savedLanguage)) {
      _currentLanguage = savedLanguage;
    }
    
    if (savedRegion != null && _regionalConfigs.containsKey(savedRegion)) {
      _currentRegion = savedRegion;
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', _currentLanguage);
    await prefs.setString('selected_region', _currentRegion);
  }

  /// Get text direction for current language
  TextDirection getTextDirection() {
    final language = _languages[_currentLanguage];
    if (language != null && language.isRTL) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  /// Format date according to current region
  String formatDate(DateTime date) {
    final region = _regionalConfigs[_currentRegion];
    if (region != null) {
      switch (region.dateFormat) {
        case 'MM/dd/yyyy':
          return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
        case 'dd/MM/yyyy':
          return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        case 'dd.MM.yyyy':
          return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        case 'yyyy/MM/dd':
          return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
        default:
          return date.toIso8601String();
      }
    }
    return date.toIso8601String();
  }

  /// Format number according to current region
  String formatNumber(double number) {
    final region = _regionalConfigs[_currentRegion];
    if (region != null) {
      switch (region.numberFormat) {
        case '#,##0.00':
          return number.toStringAsFixed(2).replaceAll('.', ',');
        case '#,##0,00':
          return number.toStringAsFixed(2).replaceAll('.', ',');
        case '#,##0':
          return number.round().toString();
        default:
          return number.toString();
      }
    }
    return number.toString();
  }

  /// Dispose resources
  void dispose() {
    _languageChangeController.close();
    _translationUpdateController.close();
    _metricsController.close();
  }
}


