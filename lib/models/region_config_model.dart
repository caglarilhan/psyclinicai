import 'package:flutter/material.dart';

enum CountryCode {
  TR, // Turkey
  US, // United States
  GB, // United Kingdom
  DE, // Germany
  FR, // France
  ES, // Spain
  IT, // Italy
  NL, // Netherlands
  CA, // Canada
  AU, // Australia
  JP, // Japan
  KR, // South Korea
  CN, // China
  IN, // India
  BR, // Brazil
  MX, // Mexico
  AR, // Argentina
  RU, // Russia
  SA, // Saudi Arabia
  AE, // United Arab Emirates
}

enum LanguageCode {
  tr, // Turkish
  en, // English
  de, // German
  fr, // French
  es, // Spanish
  it, // Italian
  nl, // Dutch
  ja, // Japanese
  ko, // Korean
  zh, // Chinese
  hi, // Hindi
  pt, // Portuguese
  ru, // Russian
  ar, // Arabic
}

enum CurrencyCode {
  TRY, // Turkish Lira
  USD, // US Dollar
  EUR, // Euro
  GBP, // British Pound
  JPY, // Japanese Yen
  KRW, // South Korean Won
  CNY, // Chinese Yuan
  INR, // Indian Rupee
  BRL, // Brazilian Real
  MXN, // Mexican Peso
  ARS, // Argentine Peso
  RUB, // Russian Ruble
  SAR, // Saudi Riyal
  AED, // UAE Dirham
}

class RegionConfig {
  final CountryCode countryCode;
  final String countryName;
  final String countryNameLocal;
  final LanguageCode primaryLanguage;
  final List<LanguageCode> supportedLanguages;
  final CurrencyCode primaryCurrency;
  final List<CurrencyCode> supportedCurrencies;
  final String timezone;
  final String dateFormat;
  final String timeFormat;
  final String phoneCode;
  final String postalCodeFormat;
  final Map<String, dynamic> legalRequirements;
  final Map<String, dynamic> culturalPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  RegionConfig({
    required this.countryCode,
    required this.countryName,
    required this.countryNameLocal,
    required this.primaryLanguage,
    this.supportedLanguages = const [],
    required this.primaryCurrency,
    this.supportedCurrencies = const [],
    required this.timezone,
    required this.dateFormat,
    required this.timeFormat,
    required this.phoneCode,
    required this.postalCodeFormat,
    this.legalRequirements = const {},
    this.culturalPreferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  bool supportsLanguage(LanguageCode language) => supportedLanguages.contains(language);
  bool supportsCurrency(CurrencyCode currency) => supportedCurrencies.contains(currency);

  RegionConfig copyWith({
    CountryCode? countryCode,
    String? countryName,
    String? countryNameLocal,
    LanguageCode? primaryLanguage,
    List<LanguageCode>? supportedLanguages,
    CurrencyCode? primaryCurrency,
    List<CurrencyCode>? supportedCurrencies,
    String? timezone,
    String? dateFormat,
    String? timeFormat,
    String? phoneCode,
    String? postalCodeFormat,
    Map<String, dynamic>? legalRequirements,
    Map<String, dynamic>? culturalPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegionConfig(
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      countryNameLocal: countryNameLocal ?? this.countryNameLocal,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
      timezone: timezone ?? this.timezone,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      phoneCode: phoneCode ?? this.phoneCode,
      postalCodeFormat: postalCodeFormat ?? this.postalCodeFormat,
      legalRequirements: legalRequirements ?? this.legalRequirements,
      culturalPreferences: culturalPreferences ?? this.culturalPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode.name,
      'countryName': countryName,
      'countryNameLocal': countryNameLocal,
      'primaryLanguage': primaryLanguage.name,
      'supportedLanguages': supportedLanguages.map((l) => l.name).toList(),
      'primaryCurrency': primaryCurrency.name,
      'supportedCurrencies': supportedCurrencies.map((c) => c.name).toList(),
      'timezone': timezone,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'phoneCode': phoneCode,
      'postalCodeFormat': postalCodeFormat,
      'legalRequirements': legalRequirements,
      'culturalPreferences': culturalPreferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RegionConfig.fromJson(Map<String, dynamic> json) {
    return RegionConfig(
      countryCode: CountryCode.values.firstWhere((e) => e.name == json['countryCode']),
      countryName: json['countryName'],
      countryNameLocal: json['countryNameLocal'],
      primaryLanguage: LanguageCode.values.firstWhere((e) => e.name == json['primaryLanguage']),
      supportedLanguages: (json['supportedLanguages'] as List).map((l) => LanguageCode.values.firstWhere((e) => e.name == l)).toList(),
      primaryCurrency: CurrencyCode.values.firstWhere((e) => e.name == json['primaryCurrency']),
      supportedCurrencies: (json['supportedCurrencies'] as List).map((c) => CurrencyCode.values.firstWhere((e) => e.name == c)).toList(),
      timezone: json['timezone'],
      dateFormat: json['dateFormat'],
      timeFormat: json['timeFormat'],
      phoneCode: json['phoneCode'],
      postalCodeFormat: json['postalCodeFormat'],
      legalRequirements: Map<String, dynamic>.from(json['legalRequirements'] ?? {}),
      culturalPreferences: Map<String, dynamic>.from(json['culturalPreferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class WhiteLabelConfig {
  final String id;
  final String organizationName;
  final String appName;
  final String appVersion;
  final String? logoUrl;
  final String? faviconUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String? customFont;
  final Map<String, String> customTexts;
  final Map<String, dynamic> branding;
  final Map<String, dynamic> features;
  final Map<String, dynamic> integrations;
  final DateTime createdAt;
  final DateTime updatedAt;

  WhiteLabelConfig({
    required this.id,
    required this.organizationName,
    required this.appName,
    required this.appVersion,
    this.logoUrl,
    this.faviconUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.customFont,
    this.customTexts = const {},
    this.branding = const {},
    this.features = const {},
    this.integrations = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  WhiteLabelConfig copyWith({
    String? id,
    String? organizationName,
    String? appName,
    String? appVersion,
    String? logoUrl,
    String? faviconUrl,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    String? customFont,
    Map<String, String>? customTexts,
    Map<String, dynamic>? branding,
    Map<String, dynamic>? features,
    Map<String, dynamic>? integrations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WhiteLabelConfig(
      id: id ?? this.id,
      organizationName: organizationName ?? this.organizationName,
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      logoUrl: logoUrl ?? this.logoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      customFont: customFont ?? this.customFont,
      customTexts: customTexts ?? this.customTexts,
      branding: branding ?? this.branding,
      features: features ?? this.features,
      integrations: integrations ?? this.integrations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationName': organizationName,
      'appName': appName,
      'appVersion': appVersion,
      'logoUrl': logoUrl,
      'faviconUrl': faviconUrl,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'accentColor': accentColor.value,
      'customFont': customFont,
      'customTexts': customTexts,
      'branding': branding,
      'features': features,
      'integrations': integrations,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WhiteLabelConfig.fromJson(Map<String, dynamic> json) {
    return WhiteLabelConfig(
      id: json['id'],
      organizationName: json['organizationName'],
      appName: json['appName'],
      appVersion: json['appVersion'],
      logoUrl: json['logoUrl'],
      faviconUrl: json['faviconUrl'],
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      accentColor: Color(json['accentColor']),
      customFont: json['customFont'],
      customTexts: Map<String, String>.from(json['customTexts'] ?? {}),
      branding: Map<String, dynamic>.from(json['branding'] ?? {}),
      features: Map<String, dynamic>.from(json['features'] ?? {}),
      integrations: Map<String, dynamic>.from(json['integrations'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class LocalizationConfig {
  final LanguageCode languageCode;
  final String languageName;
  final String languageNameLocal;
  final Map<String, String> translations;
  final String dateFormat;
  final String timeFormat;
  final String numberFormat;
  final String currencyFormat;
  final bool isRTL;
  final Map<String, dynamic> culturalSettings;

  LocalizationConfig({
    required this.languageCode,
    required this.languageName,
    required this.languageNameLocal,
    required this.translations,
    required this.dateFormat,
    required this.timeFormat,
    required this.numberFormat,
    required this.currencyFormat,
    this.isRTL = false,
    this.culturalSettings = const {},
  });

  String getText(String key) => translations[key] ?? key;

  LocalizationConfig copyWith({
    LanguageCode? languageCode,
    String? languageName,
    String? languageNameLocal,
    Map<String, String>? translations,
    String? dateFormat,
    String? timeFormat,
    String? numberFormat,
    String? currencyFormat,
    bool? isRTL,
    Map<String, dynamic>? culturalSettings,
  }) {
    return LocalizationConfig(
      languageCode: languageCode ?? this.languageCode,
      languageName: languageName ?? this.languageName,
      languageNameLocal: languageNameLocal ?? this.languageNameLocal,
      translations: translations ?? this.translations,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      currencyFormat: currencyFormat ?? this.currencyFormat,
      isRTL: isRTL ?? this.isRTL,
      culturalSettings: culturalSettings ?? this.culturalSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode.name,
      'languageName': languageName,
      'languageNameLocal': languageNameLocal,
      'translations': translations,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'numberFormat': numberFormat,
      'currencyFormat': currencyFormat,
      'isRTL': isRTL,
      'culturalSettings': culturalSettings,
    };
  }

  factory LocalizationConfig.fromJson(Map<String, dynamic> json) {
    return LocalizationConfig(
      languageCode: LanguageCode.values.firstWhere((e) => e.name == json['languageCode']),
      languageName: json['languageName'],
      languageNameLocal: json['languageNameLocal'],
      translations: Map<String, String>.from(json['translations']),
      dateFormat: json['dateFormat'],
      timeFormat: json['timeFormat'],
      numberFormat: json['numberFormat'],
      currencyFormat: json['currencyFormat'],
      isRTL: json['isRTL'] ?? false,
      culturalSettings: Map<String, dynamic>.from(json['culturalSettings'] ?? {}),
    );
  }
}
