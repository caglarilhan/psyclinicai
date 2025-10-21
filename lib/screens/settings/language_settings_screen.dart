import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final languageService = Provider.of<LanguageService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageService.translate('language_settings')),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showLanguageInfo(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current language card
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageService.translate('select_language'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            languageService.supportedLanguages[languageService.currentLocale.languageCode] ?? 
                            languageService.currentLocale.languageCode.toUpperCase(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        languageService.currentLocale.languageCode.toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Language selection
            Text(
              languageService.translate('select_language'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...languageService.supportedLocales.map((locale) {
              final isSelected = locale == languageService.currentLocale;
              final languageName = languageService.supportedLanguages[locale.languageCode] ?? 
                                 locale.languageCode.toUpperCase();
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? colorScheme.primary 
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        locale.languageCode.toUpperCase(),
                        style: TextStyle(
                          color: isSelected 
                              ? colorScheme.onPrimary 
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    languageName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(_getLanguageDescription(locale.languageCode)),
                  trailing: isSelected 
                      ? Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                        )
                      : null,
                  onTap: () => _changeLanguage(context, locale),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Language features info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          languageService.translate('info'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      languageService.translate('language_changed'),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      languageService.translate('restart_required'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Translation coverage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Çeviri Kapsamı',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTranslationCoverageItem('Türkçe', '100%', Colors.green),
                    _buildTranslationCoverageItem('English', '100%', Colors.green),
                    _buildTranslationCoverageItem('Deutsch', '95%', Colors.orange),
                    _buildTranslationCoverageItem('Français', '90%', Colors.orange),
                    _buildTranslationCoverageItem('Español', '85%', Colors.orange),
                    _buildTranslationCoverageItem('العربية', '80%', Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Language statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dil İstatistikleri',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Toplam Dil',
                            '${languageService.supportedLocales.length}',
                            Icons.language,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Çeviri Anahtarı',
                            '${_getTranslationKeyCount()}',
                            Icons.translate,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationCoverageItem(String language, String coverage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(language),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              coverage,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkiye\'de kullanılan resmi dil';
      case 'en':
        return 'English language for international users';
      case 'de':
        return 'Deutsche Sprache für deutsche Benutzer';
      case 'fr':
        return 'Langue française pour les utilisateurs français';
      case 'es':
        return 'Idioma español para usuarios españoles';
      case 'ar':
        return 'اللغة العربية للمستخدمين العرب';
      default:
        return 'Language description';
    }
  }

  int _getTranslationKeyCount() {
    // This would normally come from the language service
    return 200; // Approximate number of translation keys
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageService.translate('select_language')),
        content: Text(
          '${languageService.supportedLanguages[locale.languageCode]} diline geçmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageService.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              languageService.changeLanguage(locale);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(languageService.translate('language_changed')),
                  action: SnackBarAction(
                    label: 'Tamam',
                    onPressed: () {},
                  ),
                ),
              );
            },
            child: Text(languageService.translate('ok')),
          ),
        ],
      ),
    );
  }

  void _showLanguageInfo(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageService.translate('language_settings')),
        content: const Text(
          'PsyClinic AI çoklu dil desteği ile kullanıcıların tercih ettikleri dilde sistemi kullanabilmelerini sağlar.\n\n'
          'Desteklenen diller:\n'
          '• Türkçe (Tam destek)\n'
          '• English (Full support)\n'
          '• Deutsch (95% destek)\n'
          '• Français (90% destek)\n'
          '• Español (85% destek)\n'
          '• العربية (80% destek)\n\n'
          'Dil değişiklikleri anında uygulanır ve kullanıcı tercihleri kaydedilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageService.translate('ok')),
          ),
        ],
      ),
    );
  }
}
