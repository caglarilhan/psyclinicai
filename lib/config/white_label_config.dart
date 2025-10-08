import 'package:flutter/material.dart';

class WhiteLabelConfig {
  static final WhiteLabelConfig _instance = WhiteLabelConfig._internal();
  factory WhiteLabelConfig() => _instance;
  WhiteLabelConfig._internal();

  // Varsayılan konfigürasyon
  static const String defaultBrandName = 'PsyClinic AI';
  static const String defaultBrandTagline = 'Akıllı Psikiyatri Asistanı';
  static const String defaultSupportEmail = 'support@psyclinici.com';
  static const String defaultWebsite = 'https://psyclinici.com';

  // Mevcut konfigürasyon
  String _brandName = defaultBrandName;
  String _brandTagline = defaultBrandTagline;
  String _supportEmail = defaultSupportEmail;
  String _website = defaultWebsite;
  String _logoPath = '';
  String _faviconPath = '';
  Color _primaryColor = const Color(0xFF2563EB);
  Color _secondaryColor = const Color(0xFF7C3AED);
  Color _accentColor = const Color(0xFF10B981);
  bool _isCustomTheme = false;
  Map<String, dynamic> _customFeatures = {};
  Map<String, String> _customTexts = {};
  Map<String, String> _customUrls = {};

  // Getters
  String get brandName => _brandName;
  String get brandTagline => _brandTagline;
  String get supportEmail => _supportEmail;
  String get website => _website;
  String get logoPath => _logoPath;
  String get faviconPath => _faviconPath;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;
  bool get isCustomTheme => _isCustomTheme;
  Map<String, dynamic> get customFeatures => Map.unmodifiable(_customFeatures);
  Map<String, String> get customTexts => Map.unmodifiable(_customTexts);
  Map<String, String> get customUrls => Map.unmodifiable(_customUrls);

  // Konfigürasyon yükleme
  Future<void> loadConfig(String configPath) async {
    try {
      // TODO: JSON dosyasından konfigürasyon yükleme
      print('White-label konfigürasyon yüklendi: $configPath');
    } catch (e) {
      print('White-label konfigürasyon yüklenemedi: $e');
      _loadDefaultConfig();
    }
  }

  // Varsayılan konfigürasyon yükleme
  void _loadDefaultConfig() {
    _brandName = defaultBrandName;
    _brandTagline = defaultBrandTagline;
    _supportEmail = defaultSupportEmail;
    _website = defaultWebsite;
    _logoPath = '';
    _faviconPath = '';
    _primaryColor = const Color(0xFF2563EB);
    _secondaryColor = const Color(0xFF7C3AED);
    _accentColor = const Color(0xFF10B981);
    _isCustomTheme = false;
    _customFeatures.clear();
    _customTexts.clear();
    _customUrls.clear();
  }

  // Konfigürasyon güncelleme
  void updateConfig({
    String? brandName,
    String? brandTagline,
    String? supportEmail,
    String? website,
    String? logoPath,
    String? faviconPath,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    bool? isCustomTheme,
    Map<String, dynamic>? customFeatures,
    Map<String, String>? customTexts,
    Map<String, String>? customUrls,
  }) {
    if (brandName != null) _brandName = brandName;
    if (brandTagline != null) _brandTagline = brandTagline;
    if (supportEmail != null) _supportEmail = supportEmail;
    if (website != null) _website = website;
    if (logoPath != null) _logoPath = logoPath;
    if (faviconPath != null) _faviconPath = faviconPath;
    if (primaryColor != null) _primaryColor = primaryColor;
    if (secondaryColor != null) _secondaryColor = secondaryColor;
    if (accentColor != null) _accentColor = accentColor;
    if (isCustomTheme != null) _isCustomTheme = isCustomTheme;
    if (customFeatures != null) _customFeatures = customFeatures;
    if (customTexts != null) _customTexts = customTexts;
    if (customUrls != null) _customUrls = customUrls;

    print('White-label konfigürasyon güncellendi');
  }

  // Özelleştirilmiş tema oluşturma
  ThemeData createCustomTheme() {
    if (!_isCustomTheme) {
      return ThemeData.light();
    }

    return ThemeData(
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.light(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: Colors.white,
        background: Colors.grey[50]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Özelleştirilmiş metin alma
  String getCustomText(String key, {String defaultValue = ''}) {
    return _customTexts[key] ?? defaultValue;
  }

  // Özelleştirilmiş URL alma
  String getCustomUrl(String key, {String defaultValue = ''}) {
    return _customUrls[key] ?? defaultValue;
  }

  // Özelleştirilmiş özellik kontrolü
  bool hasCustomFeature(String feature) {
    return _customFeatures[feature] == true;
  }

  // Konfigürasyon sıfırlama
  void resetToDefault() {
    _loadDefaultConfig();
    print('White-label konfigürasyon varsayılana sıfırlandı');
  }

  // Konfigürasyon dışa aktarma
  Map<String, dynamic> exportConfig() {
    return {
      'brandName': _brandName,
      'brandTagline': _brandTagline,
      'supportEmail': _supportEmail,
      'website': _website,
      'logoPath': _logoPath,
      'faviconPath': _faviconPath,
      'primaryColor': _primaryColor.value,
      'secondaryColor': _secondaryColor.value,
      'accentColor': _accentColor.value,
      'isCustomTheme': _isCustomTheme,
      'customFeatures': _customFeatures,
      'customTexts': _customTexts,
      'customUrls': _customUrls,
    };
  }

  // Konfigürasyon içe aktarma
  void importConfig(Map<String, dynamic> config) {
    try {
      _brandName = config['brandName'] ?? defaultBrandName;
      _brandTagline = config['brandTagline'] ?? defaultBrandTagline;
      _supportEmail = config['supportEmail'] ?? defaultSupportEmail;
      _website = config['website'] ?? defaultWebsite;
      _logoPath = config['logoPath'] ?? '';
      _faviconPath = config['faviconPath'] ?? '';
      _primaryColor = Color(config['primaryColor'] ?? 0xFF2563EB);
      _secondaryColor = Color(config['secondaryColor'] ?? 0xFF7C3AED);
      _accentColor = Color(config['accentColor'] ?? 0xFF10B981);
      _isCustomTheme = config['isCustomTheme'] ?? false;
      _customFeatures = Map<String, dynamic>.from(config['customFeatures'] ?? {});
      _customTexts = Map<String, String>.from(config['customTexts'] ?? {});
      _customUrls = Map<String, String>.from(config['customUrls'] ?? {});

      print('White-label konfigürasyon içe aktarıldı');
    } catch (e) {
      print('White-label konfigürasyon içe aktarılamadı: $e');
      _loadDefaultConfig();
    }
  }

  // Önceden tanımlanmış temalar
  static const Map<String, Map<String, Color>> predefinedThemes = {
    'psyclinic': {
      'primary': Color(0xFF2563EB),
      'secondary': Color(0xFF7C3AED),
      'accent': Color(0xFF10B981),
    },
    'medical': {
      'primary': Color(0xFF059669),
      'secondary': Color(0xFF0891B2),
      'accent': Color(0xFFDC2626),
    },
    'wellness': {
      'primary': Color(0xFF7C3AED),
      'secondary': Color(0xFFEC4899),
      'accent': Color(0xFFF59E0B),
    },
    'corporate': {
      'primary': Color(0xFF1F2937),
      'secondary': Color(0xFF374151),
      'accent': Color(0xFF3B82F6),
    },
    'modern': {
      'primary': Color(0xFF6366F1),
      'secondary': Color(0xFF8B5CF6),
      'accent': Color(0xFF06B6D4),
    },
  };

  // Önceden tanımlanmış tema yükleme
  void loadPredefinedTheme(String themeName) {
    final theme = predefinedThemes[themeName];
    if (theme != null) {
      _primaryColor = theme['primary']!;
      _secondaryColor = theme['secondary']!;
      _accentColor = theme['accent']!;
      _isCustomTheme = true;
      print('Önceden tanımlanmış tema yüklendi: $themeName');
    } else {
      print('Tema bulunamadı: $themeName');
    }
  }

  // Konfigürasyon doğrulama
  bool validateConfig() {
    if (_brandName.isEmpty) return false;
    if (_supportEmail.isEmpty) return false;
    if (_website.isEmpty) return false;
    return true;
  }

  // Konfigürasyon durumu
  String getConfigStatus() {
    if (!validateConfig()) return 'Geçersiz';
    if (_isCustomTheme) return 'Özelleştirilmiş';
    return 'Varsayılan';
  }

  // Konfigürasyon özeti
  String getConfigSummary() {
    return '''
White-Label Konfigürasyon Özeti:
- Marka: $_brandName
- Slogan: $_brandTagline
- E-posta: $_supportEmail
- Website: $_website
- Tema: ${_isCustomTheme ? 'Özelleştirilmiş' : 'Varsayılan'}
- Durum: ${getConfigStatus()}
''';
  }
}

// White-label tema provider'ı
class WhiteLabelThemeProvider extends ChangeNotifier {
  final WhiteLabelConfig _config = WhiteLabelConfig();

  WhiteLabelConfig get config => _config;

  void updateTheme({
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
  }) {
    _config.updateConfig(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      isCustomTheme: true,
    );
    notifyListeners();
  }

  void loadPredefinedTheme(String themeName) {
    _config.loadPredefinedTheme(themeName);
    notifyListeners();
  }

  void resetTheme() {
    _config.resetToDefault();
    notifyListeners();
  }

  ThemeData get currentTheme => _config.createCustomTheme();
}
