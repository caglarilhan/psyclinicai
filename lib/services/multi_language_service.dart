import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MultiLanguageService {
  static final MultiLanguageService _instance = MultiLanguageService._internal();
  factory MultiLanguageService() => _instance;
  MultiLanguageService._internal();

  bool _isInitialized = false;
  String _currentLanguage = 'tr';
  List<String> _supportedLanguages = ['tr', 'en', 'de', 'fr', 'es', 'ar'];
  
  Map<String, Map<String, String>> _translations = {};
  
  final StreamController<String> _languageController = StreamController<String>.broadcast();
  Stream<String> get languageStream => _languageController.stream;

  bool get isInitialized => _isInitialized;
  String get currentLanguage => _currentLanguage;
  List<String> get supportedLanguages => List.unmodifiable(_supportedLanguages);

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadLanguageSettings();
    await _loadTranslations();
    _isInitialized = true;
  }

  Future<void> _loadLanguageSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('current_language') ?? 'tr';
  }

  Future<void> _saveLanguageSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_language', _currentLanguage);
  }

  Future<void> _loadTranslations() async {
    _translations = {
      'tr': {
        'app_name': 'PsyClinic AI',
        'welcome': 'Hoş Geldiniz',
        'dashboard': 'Ana Sayfa',
        'clients': 'Müşteriler',
        'sessions': 'Seanslar',
        'settings': 'Ayarlar',
        'save': 'Kaydet',
        'cancel': 'İptal',
        'delete': 'Sil',
        'edit': 'Düzenle',
        'add': 'Ekle',
        'search': 'Ara',
        'loading': 'Yükleniyor...',
        'error': 'Hata',
        'success': 'Başarılı',
      },
      'en': {
        'app_name': 'PsyClinic AI',
        'welcome': 'Welcome',
        'dashboard': 'Dashboard',
        'clients': 'Clients',
        'sessions': 'Sessions',
        'settings': 'Settings',
        'save': 'Save',
        'cancel': 'Cancel',
        'delete': 'Delete',
        'edit': 'Edit',
        'add': 'Add',
        'search': 'Search',
        'loading': 'Loading...',
        'error': 'Error',
        'success': 'Success',
      },
      'de': {
        'app_name': 'PsyClinic AI',
        'welcome': 'Willkommen',
        'dashboard': 'Dashboard',
        'clients': 'Klienten',
        'sessions': 'Sitzungen',
        'settings': 'Einstellungen',
        'save': 'Speichern',
        'cancel': 'Abbrechen',
        'delete': 'Löschen',
        'edit': 'Bearbeiten',
        'add': 'Hinzufügen',
        'search': 'Suchen',
        'loading': 'Laden...',
        'error': 'Fehler',
        'success': 'Erfolg',
      },
    };
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!_supportedLanguages.contains(languageCode)) {
      throw Exception('Unsupported language: $languageCode');
    }

    _currentLanguage = languageCode;
    await _saveLanguageSettings();
    _languageController.add(languageCode);
  }

  String translate(String key) {
    final translations = _translations[_currentLanguage];
    if (translations != null && translations.containsKey(key)) {
      return translations[key]!;
    }
    
    final englishTranslations = _translations['en'];
    if (englishTranslations != null && englishTranslations.containsKey(key)) {
      return englishTranslations[key]!;
    }
    
    return key;
  }

  String t(String key) => translate(key);

  Locale get currentLocale => Locale(_currentLanguage);

  List<Locale> get supportedLocales {
    return _supportedLanguages.map((lang) => Locale(lang)).toList();
  }

  TextDirection get textDirection {
    return _currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  Map<String, dynamic> getLanguageStats() {
    return {
      'currentLanguage': _currentLanguage,
      'supportedLanguages': _supportedLanguages.length,
      'translationsCount': _translations[_currentLanguage]?.length ?? 0,
      'textDirection': textDirection.name,
    };
  }

  void dispose() {
    _languageController.close();
  }
}


