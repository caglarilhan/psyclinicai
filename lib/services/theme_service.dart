import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/white_label_config.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // Theme modes
  static const String _lightThemeKey = 'light_theme';
  static const String _darkThemeKey = 'dark_theme';
  static const String _systemThemeKey = 'system_theme';
  static const String _customThemeKey = 'custom_theme';

  // Current theme
  ThemeMode _currentThemeMode = ThemeMode.system;
  bool _isDarkMode = false;
  bool _isSystemTheme = true;
  bool _isCustomTheme = false;

  // Theme colors
  Color _primaryColor = const Color(0xFF2196F3);
  Color _secondaryColor = const Color(0xFF03DAC6);
  Color _accentColor = const Color(0xFFFF4081);
  Color _errorColor = const Color(0xFFB00020);

  // Custom theme colors
  Color _customPrimaryColor = const Color(0xFF2196F3);
  Color _customSecondaryColor = const Color(0xFF03DAC6);
  Color _customAccentColor = const Color(0xFFFF4081);
  Color _customErrorColor = const Color(0xFFB00020);
  bool _hasCustomColors = false;

  // Stream controllers
  final StreamController<ThemeMode> _themeModeController = StreamController<ThemeMode>.broadcast();
  final StreamController<bool> _darkModeController = StreamController<bool>.broadcast();
  final StreamController<Color> _primaryColorController = StreamController<Color>.broadcast();

  // Streams
  Stream<ThemeMode> get themeModeStream => _themeModeController.stream;
  Stream<bool> get darkModeStream => _darkModeController.stream;
  Stream<Color> get primaryColorStream => _primaryColorController.stream;

  // Getters
  ThemeMode get currentThemeMode => _currentThemeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isSystemTheme => _isSystemTheme;
  bool get isCustomTheme => _isCustomTheme;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;
  Color get errorColor => _errorColor;

  // White-label tema desteği
  final WhiteLabelConfig _whiteLabelConfig = WhiteLabelConfig();

  ThemeMode get currentWhiteLabelTheme => _whiteLabelConfig.createCustomTheme();

  Future<void> initialize() async {
    try {
      // Saved theme settings'i yükle
      await _loadThemeSettings();
      
      // System theme listener'ı başlat
      _setupSystemThemeListener();
      
      print('ThemeService initialized successfully');
    } catch (e) {
      print('ThemeService initialization failed: $e');
    }
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme mode
    final themeModeString = prefs.getString('theme_mode') ?? 'system';
    _currentThemeMode = _stringToThemeMode(themeModeString);
    
    // Custom colors
    final customPrimaryHex = prefs.getString('custom_primary_color');
    if (customPrimaryHex != null) {
      _customPrimaryColor = _hexToColor(customPrimaryHex);
    }
    
    final customSecondaryHex = prefs.getString('custom_secondary_color');
    if (customSecondaryHex != null) {
      _customSecondaryColor = _hexToColor(customSecondaryHex);
    }
    
    final customAccentHex = prefs.getString('custom_accent_color');
    if (customAccentHex != null) {
      _customAccentColor = _hexToColor(customAccentHex);
    }
    
    final customErrorHex = prefs.getString('custom_error_color');
    if (customErrorHex != null) {
      _customErrorColor = _hexToColor(customErrorHex);
    }
    
    // Custom colors flag
    _hasCustomColors = prefs.getBool('has_custom_colors') ?? false;

    // Custom renkler aktifse aktif palete uygula
    if (_hasCustomColors) {
      _primaryColor = _customPrimaryColor;
      _secondaryColor = _customSecondaryColor;
      _accentColor = _customAccentColor;
      _errorColor = _customErrorColor;
    }

    // Theme status'ları güncelle
    _updateThemeStatus();
    
    notifyListeners();
  }

  void _setupSystemThemeListener() {
    // System theme değişikliklerini dinle
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () async {},
        stateChangeCallBack: () async {},
        resumedCallBack: () async {
          // App resume olduğunda system theme'i kontrol et
          if (_isSystemTheme) {
            _updateSystemTheme();
          }
        },
        inactiveCallBack: () async {},
        pausedCallBack: () async {},
      ),
    );
  }

  void _updateSystemTheme() {
    if (_isSystemTheme) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final newDarkMode = brightness == Brightness.dark;
      
      if (_isDarkMode != newDarkMode) {
        _isDarkMode = newDarkMode;
        _darkModeController.add(_isDarkMode);
        notifyListeners();
      }
    }
  }

  void _updateThemeStatus() {
    _isSystemTheme = _currentThemeMode == ThemeMode.system;
    _isCustomTheme = _hasCustomColors;
    
    if (_isSystemTheme) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _isDarkMode = brightness == Brightness.dark;
    } else if (_currentThemeMode == ThemeMode.dark) {
      _isDarkMode = true;
    } else {
      _isDarkMode = false;
    }
  }

  // Theme mode değiştirme
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_currentThemeMode == themeMode) return;

    _currentThemeMode = themeMode;
    _updateThemeStatus();
    
    // Settings'i kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeModeToString(themeMode));
    
    // Stream'lere bildir
    _themeModeController.add(_currentThemeMode);
    _darkModeController.add(_isDarkMode);
    
    notifyListeners();
    
    print('Theme mode changed to: ${_themeModeToString(themeMode)}');
  }

  // Dark mode toggle
  Future<void> toggleDarkMode() async {
    if (_isSystemTheme) {
      // System theme'den çık ve manuel dark mode'a geç
      await setThemeMode(_isDarkMode ? ThemeMode.light : ThemeMode.dark);
    } else {
      // Mevcut theme'i toggle et
      final newThemeMode = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
      await setThemeMode(newThemeMode);
    }
  }

  // Custom theme colors
  Future<void> setCustomColors({
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? errorColor,
  }) async {
    bool hasChanges = false;
    
    if (primaryColor != null && _customPrimaryColor != primaryColor) {
      _customPrimaryColor = primaryColor;
      hasChanges = true;
    }
    
    if (secondaryColor != null && _customSecondaryColor != secondaryColor) {
      _customSecondaryColor = secondaryColor;
      hasChanges = true;
    }
    
    if (accentColor != null && _customAccentColor != accentColor) {
      _customAccentColor = accentColor;
      hasChanges = true;
    }
    
    if (errorColor != null && _customErrorColor != errorColor) {
      _customErrorColor = errorColor;
      hasChanges = true;
    }
    
    if (hasChanges) {
      // Settings'i kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_primary_color', _colorToHex(_customPrimaryColor));
      await prefs.setString('custom_secondary_color', _colorToHex(_customSecondaryColor));
      await prefs.setString('custom_accent_color', _colorToHex(_customAccentColor));
      await prefs.setString('custom_error_color', _colorToHex(_customErrorColor));
      
      // Custom colors flag'ini set et
      _hasCustomColors = true;
      await prefs.setBool('has_custom_colors', true);
      
      // Aktif palete uygula
      _primaryColor = _customPrimaryColor;
      _secondaryColor = _customSecondaryColor;
      _accentColor = _customAccentColor;
      _errorColor = _customErrorColor;

      // Stream'e bildir
      _primaryColorController.add(_customPrimaryColor);
      
      notifyListeners();
      
      print('Custom colors updated');
    }
  }

  // Preset themes
  Future<void> setPresetTheme(String presetName) async {
    switch (presetName.toLowerCase()) {
      case 'psyclinic':
        await setCustomColors(
          primaryColor: const Color(0xFF1976D2), // Mavi
          secondaryColor: const Color(0xFF26A69A), // Yeşil
          accentColor: const Color(0xFFFF5722), // Turuncu
          errorColor: const Color(0xFFD32F2F), // Kırmızı
        );
        break;
        
      case 'medical':
        await setCustomColors(
          primaryColor: const Color(0xFF2E7D32), // Koyu yeşil
          secondaryColor: const Color(0xFF1976D2), // Mavi
          accentColor: const Color(0xFFFF6F00), // Turuncu
          errorColor: const Color(0xFFC62828), // Koyu kırmızı
        );
        break;
        
      case 'calm':
        await setCustomColors(
          primaryColor: const Color(0xFF5C6BC0), // Lavanta
          secondaryColor: const Color(0xFF81C784), // Açık yeşil
          accentColor: const Color(0xFFFFB74D), // Açık turuncu
          errorColor: const Color(0xFFE57373), // Açık kırmızı
        );
        break;
        
      case 'professional':
        await setCustomColors(
          primaryColor: const Color(0xFF424242), // Gri
          secondaryColor: const Color(0xFF757575), // Açık gri
          accentColor: const Color(0xFF1976D2), // Mavi
          errorColor: const Color(0xFFD32F2F), // Kırmızı
        );
        break;
      case 'purpleblue':
      case 'purple_blue':
      case 'purple-blue':
        await setCustomColors(
          primaryColor: const Color(0xFF6A1B9A), // Mor
          secondaryColor: const Color(0xFF1976D2), // Mavi
          accentColor: const Color(0xFFD32F2F), // Kırmızı vurgu
          errorColor: const Color(0xFFD32F2F), // Kırmızı
        );
        break;
        
      default:
        throw Exception('Unknown preset theme: $presetName');
    }
  }

  // Theme data oluşturma
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _primaryColor,
        secondary: _secondaryColor,
        tertiary: _accentColor,
        error: _errorColor,
        surface: Colors.white,
        background: const Color(0xFFFAFAFA),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: _primaryColor,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _primaryColor.withOpacity(0.1),
        selectedColor: _primaryColor,
        labelStyle: TextStyle(color: _primaryColor),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: _primaryColor,
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        tertiary: _accentColor,
        error: _errorColor,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: _primaryColor,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _primaryColor.withOpacity(0.2),
        selectedColor: _primaryColor,
        labelStyle: TextStyle(color: _primaryColor),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade700,
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: _primaryColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }

  ThemeData getCustomTheme() {
    if (_isDarkMode) {
      return getDarkTheme();
    } else {
      return getLightTheme();
    }
  }

  // Color utilities
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Alpha channel ekle
    }
    return Color(int.parse(hex, radix: 16));
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return _lightThemeKey;
      case ThemeMode.dark:
        return _darkThemeKey;
      case ThemeMode.system:
        return _systemThemeKey;
    }
  }

  ThemeMode _stringToThemeMode(String themeModeString) {
    switch (themeModeString) {
      case _lightThemeKey:
        return ThemeMode.light;
      case _darkThemeKey:
        return ThemeMode.dark;
      case _systemThemeKey:
        return ThemeMode.system;
      case _customThemeKey:
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  // Theme export/import
  Future<Map<String, dynamic>> exportThemeSettings() async {
    return {
      'themeMode': _themeModeToString(_currentThemeMode),
      'customColors': {
        'primary': _colorToHex(_customPrimaryColor),
        'secondary': _colorToHex(_customSecondaryColor),
        'accent': _colorToHex(_customAccentColor),
        'error': _colorToHex(_customErrorColor),
      },
      'isDarkMode': _isDarkMode,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importThemeSettings(Map<String, dynamic> settings) async {
    try {
      // Theme mode
      if (settings.containsKey('themeMode')) {
        final themeMode = _stringToThemeMode(settings['themeMode']);
        await setThemeMode(themeMode);
      }
      
      // Custom colors
      if (settings.containsKey('customColors')) {
        final colors = settings['customColors'] as Map<String, dynamic>;
        
        await setCustomColors(
          primaryColor: colors.containsKey('primary') ? _hexToColor(colors['primary']) : null,
          secondaryColor: colors.containsKey('secondary') ? _hexToColor(colors['secondary']) : null,
          accentColor: colors.containsKey('accent') ? _hexToColor(colors['accent']) : null,
          errorColor: colors.containsKey('error') ? _hexToColor(colors['error']) : null,
        );
      }
      
      print('Theme settings imported successfully');
    } catch (e) {
      print('Error importing theme settings: $e');
      rethrow;
    }
  }

  // Theme reset
  Future<void> resetToDefault() async {
    await setThemeMode(ThemeMode.system);
    await setCustomColors(
      primaryColor: const Color(0xFF2196F3),
      secondaryColor: const Color(0xFF03DAC6),
      accentColor: const Color(0xFFFF4081),
      errorColor: const Color(0xFFB00020),
    );
    
    print('Theme reset to default');
  }

  // Theme preview
  ThemeData getThemePreview(ThemeMode themeMode, {bool isDark = false}) {
    switch (themeMode) {
      case ThemeMode.light:
        return getLightTheme();
      case ThemeMode.dark:
        return getDarkTheme();
      case ThemeMode.system:
        return isDark ? getDarkTheme() : getLightTheme();
    }
  }

  // White-label tema güncelleme
  void updateWhiteLabelTheme({
    String? brandName,
    String? brandTagline,
    String? supportEmail,
    String? website,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    bool? isCustomTheme,
    Map<String, dynamic>? customFeatures,
    Map<String, String>? customTexts,
    Map<String, String>? customUrls,
  }) {
    _whiteLabelConfig.updateConfig(
      brandName: brandName,
      brandTagline: brandTagline,
      supportEmail: supportEmail,
      website: website,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      isCustomTheme: isCustomTheme,
      customFeatures: customFeatures,
      customTexts: customTexts,
      customUrls: customUrls,
    );
    notifyListeners();
  }

  // White-label tema yükleme
  void loadPredefinedTheme(String themeName) {
    _whiteLabelConfig.loadPredefinedTheme(themeName);
    notifyListeners();
  }

  // White-label tema sıfırlama
  void resetWhiteLabelTheme() {
    _whiteLabelConfig.resetToDefault();
    notifyListeners();
  }

  // White-label konfigürasyon durumu
  String get whiteLabelConfigStatus => _whiteLabelConfig.getConfigStatus();
  
  bool get isWhiteLabelCustomized => _whiteLabelConfig.isCustomTheme;
  
  String get whiteLabelBrandName => _whiteLabelConfig.brandName;
  
  Color get whiteLabelPrimaryColor => _whiteLabelConfig.primaryColor;
  
  Color get whiteLabelSecondaryColor => _whiteLabelConfig.secondaryColor;
  
  Color get whiteLabelAccentColor => _whiteLabelConfig.accentColor;

  void dispose() {
    final bool isTestEnv = const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
    if (!isTestEnv) {
      _themeModeController.close();
      _darkModeController.close();
      _primaryColorController.close();
      super.dispose();
    }
  }
}

// Lifecycle event handler
class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? detachedCallBack;
  final Future<void> Function()? stateChangeCallBack;
  final Future<void> Function()? resumedCallBack;
  final Future<void> Function()? inactiveCallBack;
  final Future<void> Function()? pausedCallBack;

  LifecycleEventHandler({
    this.detachedCallBack,
    this.stateChangeCallBack,
    this.resumedCallBack,
    this.inactiveCallBack,
    this.pausedCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumedCallBack != null) {
          await resumedCallBack!();
        }
        break;
      case AppLifecycleState.inactive:
        if (inactiveCallBack != null) {
          await inactiveCallBack!();
        }
        break;
      case AppLifecycleState.paused:
        if (pausedCallBack != null) {
          await pausedCallBack!();
        }
        break;
      case AppLifecycleState.detached:
        if (detachedCallBack != null) {
          await detachedCallBack!();
        }
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state if needed
        break;
    }
  }
}
