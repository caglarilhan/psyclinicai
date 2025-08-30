import 'package:flutter/material.dart';
import '../services/multi_language_service.dart';
import '../utils/theme.dart';

// Language Selector Widget
class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({super.key});

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  final MultiLanguageService _languageService = MultiLanguageService();
  String _currentLanguage = 'tr';

  @override
  void initState() {
    super.initState();
    _currentLanguage = _languageService.currentLanguage;
    
    // Listen to language changes
    _languageService.languageStream.listen((language) {
      setState(() {
        _currentLanguage = language;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dil Seçimi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Language options
            ..._languageService.supportedLanguages.map((language) => 
              _buildLanguageOption(language),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String languageCode) {
    final isSelected = _currentLanguage == languageCode;
    final languageName = _getLanguageName(languageCode);
    final flag = _getLanguageFlag(languageCode);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey[300],
        child: Text(
          flag,
          style: TextStyle(
            fontSize: 20,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
      title: Text(
        languageName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(_getLanguageNativeName(languageCode)),
      trailing: isSelected 
          ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : null,
      onTap: () => _changeLanguage(languageCode),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'ar':
        return 'العربية';
      default:
        return languageCode.toUpperCase();
    }
  }

  String _getLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'ar':
        return 'العربية';
      default:
        return languageCode.toUpperCase();
    }
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇺🇸';
      case 'de':
        return '🇩🇪';
      case 'fr':
        return '🇫🇷';
      case 'es':
        return '🇪🇸';
      case 'ar':
        return '🇸🇦';
      default:
        return '🌐';
    }
  }

  void _changeLanguage(String languageCode) async {
    try {
      await _languageService.changeLanguage(languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dil ${_getLanguageName(languageCode)} olarak değiştirildi'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dil değiştirme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Language Settings Widget
class LanguageSettingsWidget extends StatefulWidget {
  const LanguageSettingsWidget({super.key});

  @override
  State<LanguageSettingsWidget> createState() => _LanguageSettingsWidgetState();
}

class _LanguageSettingsWidgetState extends State<LanguageSettingsWidget> {
  final MultiLanguageService _languageService = MultiLanguageService();
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _stats = _languageService.getLanguageStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dil Ayarları',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatItem(
              'Mevcut Dil',
              _getLanguageName(_stats['currentLanguage'] ?? 'tr'),
              Icons.language,
              Colors.blue,
            ),
            
            _buildStatItem(
              'Desteklenen Diller',
              '${_stats['supportedLanguages'] ?? 0}',
              Icons.translate,
              Colors.green,
            ),
            
            _buildStatItem(
              'Çeviri Sayısı',
              '${_stats['translationsCount'] ?? 0}',
              Icons.text_fields,
              Colors.orange,
            ),
            
            _buildStatItem(
              'Metin Yönü',
              _stats['textDirection'] == 'rtl' ? 'Sağdan Sola' : 'Soldan Sağa',
              Icons.format_textdirection_ltr,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'ar':
        return 'العربية';
      default:
        return languageCode.toUpperCase();
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Translation Test Widget
class TranslationTestWidget extends StatefulWidget {
  const TranslationTestWidget({super.key});

  @override
  State<TranslationTestWidget> createState() => _TranslationTestWidgetState();
}

class _TranslationTestWidgetState extends State<TranslationTestWidget> {
  final MultiLanguageService _languageService = MultiLanguageService();
  final List<String> _testKeys = [
    'app_name',
    'welcome',
    'dashboard',
    'clients',
    'sessions',
    'settings',
    'save',
    'cancel',
    'delete',
    'edit',
    'add',
    'search',
    'loading',
    'error',
    'success',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.translate,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Çeviri Testi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Mevcut Dil: ${_getLanguageName(_languageService.currentLanguage)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Test translations
            ..._testKeys.map((key) => _buildTranslationItem(key)),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationItem(String key) {
    final translation = _languageService.translate(key);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              translation,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'ar':
        return 'العربية';
      default:
        return languageCode.toUpperCase();
    }
  }
}
