import 'package:flutter/material.dart';
import 'package:psyclinicai/models/global_language_models.dart';
import 'package:psyclinicai/services/multi_language_service.dart';

/// Multi-Language Dashboard Widget for PsyClinicAI
/// Provides comprehensive language management and localization features
class MultiLanguageDashboardWidget extends StatefulWidget {
  const MultiLanguageDashboardWidget({Key? key}) : super(key: key);

  @override
  State<MultiLanguageDashboardWidget> createState() => _MultiLanguageDashboardWidgetState();
}

class _MultiLanguageDashboardWidgetState extends State<MultiLanguageDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final MultiLanguageService _languageService = MultiLanguageService();

  // State variables
  bool _isLoading = false;
  List<Language> _supportedLanguages = [];
  List<RegionalConfig> _regionalConfigs = [];
  Language? _currentLanguage;
  RegionalConfig? _currentRegion;
  CulturalAdaptation? _culturalAdaptation;
  LocalizationReport? _localizationReport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadLanguageData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load language data
  Future<void> _loadLanguageData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _languageService.initialize();
      await _languageService.loadUserPreferences();
      
      _supportedLanguages = _languageService.getSupportedLanguages();
      _regionalConfigs = _languageService.getAllRegionalConfigs();
      _currentLanguage = _languageService.currentLanguageObject;
      _currentRegion = _languageService.currentRegionalConfig;
      _culturalAdaptation = _languageService.getCulturalAdaptation();
      _localizationReport = await _languageService.getLocalizationReport();
      
      print('✅ Multi-language data loaded successfully');
    } catch (e) {
      print('❌ Failed to load language data: $e');
      _showErrorSnackBar('Failed to load language data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 Multi-Language Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLanguageData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.language), text: 'Languages'),
            Tab(icon: Icon(Icons.public), text: 'Regions'),
            Tab(icon: Icon(Icons.translate), text: 'Translations'),
            Tab(icon: Icon(Icons.psychology), text: 'Cultural'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLanguagesTab(),
                _buildRegionsTab(),
                _buildTranslationsTab(),
                _buildCulturalTab(),
                _buildAnalyticsTab(),
              ],
            ),
    );
  }

  /// Languages Tab
  Widget _buildLanguagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🌍 Supported Languages',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildLanguageSelector(),
            ],
          ),
          const SizedBox(height: 16),
          _buildLanguageGrid(),
          const SizedBox(height: 24),
          _buildCurrentLanguageInfo(),
        ],
      ),
    );
  }

  /// Language Selector
  Widget _buildLanguageSelector() {
    return DropdownButtonFormField<String>(
      value: _currentLanguage?.code,
      decoration: const InputDecoration(
        labelText: 'Current Language',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _supportedLanguages.map((language) {
        return DropdownMenuItem(
          value: language.code,
          child: Row(
            children: [
              Text(language.flag),
              const SizedBox(width: 8),
              Text(language.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (languageCode) async {
        if (languageCode != null) {
          try {
            await _languageService.changeLanguage(languageCode);
            await _loadLanguageData();
          } catch (e) {
            _showErrorSnackBar('Failed to change language: $e');
          }
        }
      },
    );
  }

  /// Language Grid
  Widget _buildLanguageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _supportedLanguages.length,
      itemBuilder: (context, index) {
        final language = _supportedLanguages[index];
        final isCurrent = language.code == _currentLanguage?.code;
        
        return Card(
          elevation: isCurrent ? 4 : 2,
          color: isCurrent ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          child: InkWell(
            onTap: () async {
              try {
                await _languageService.changeLanguage(language.code);
                await _loadLanguageData();
              } catch (e) {
                _showErrorSnackBar('Failed to change language: $e');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              language.nativeName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: language.completionPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            language.completionPercentage >= 90
                                ? Colors.green
                                : language.completionPercentage >= 70
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${language.completionPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        language.isRTL ? Icons.format_align_right : Icons.format_align_left,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        language.isRTL ? 'RTL' : 'LTR',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      if (language.needsUpdate)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Current Language Info
  Widget _buildCurrentLanguageInfo() {
    if (_currentLanguage == null) return Container();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📱 Current Language Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  _currentLanguage!.flag,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentLanguage!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentLanguage!.nativeName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Direction: ${_currentLanguage!.isRTL ? "Right-to-Left" : "Left-to-Right"}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Regions: ${_currentLanguage!.regions.join(", ")}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Regions Tab
  Widget _buildRegionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🌐 Regional Configurations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildRegionSelector(),
            ],
          ),
          const SizedBox(height: 16),
          _buildRegionCards(),
        ],
      ),
    );
  }

  /// Region Selector
  Widget _buildRegionSelector() {
    return DropdownButtonFormField<String>(
      value: _currentRegion?.regionCode,
      decoration: const InputDecoration(
        labelText: 'Current Region',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _regionalConfigs.map((region) {
        return DropdownMenuItem(
          value: region.regionCode,
          child: Text(region.regionName),
        );
      }).toList(),
      onChanged: (regionCode) async {
        if (regionCode != null) {
          try {
            await _languageService.changeRegion(regionCode);
            await _loadLanguageData();
          } catch (e) {
            _showErrorSnackBar('Failed to change region: $e');
          }
        }
      },
    );
  }

  /// Region Cards
  Widget _buildRegionCards() {
    return Column(
      children: _regionalConfigs.map((region) {
        final isCurrent = region.regionCode == _currentRegion?.regionCode;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: isCurrent ? 4 : 2,
          color: isCurrent ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                region.regionName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Current',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Code: ${region.regionCode}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          region.currency,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          region.timezone,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildRegionInfoItem(
                        'Languages',
                        region.supportedLanguages.join(', '),
                        Icons.language,
                      ),
                    ),
                    Expanded(
                      child: _buildRegionInfoItem(
                        'Date Format',
                        region.dateFormat,
                        Icons.calendar_today,
                      ),
                    ),
                    Expanded(
                      child: _buildRegionInfoItem(
                        'Number Format',
                        region.numberFormat,
                        Icons.format_list_numbered,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Compliance: ${region.complianceFrameworks.join(", ")}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Region Info Item
  Widget _buildRegionInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Translations Tab
  Widget _buildTranslationsTab() {
    return const Center(
      child: Text('Translation management features coming soon...'),
    );
  }

  /// Cultural Tab
  Widget _buildCulturalTab() {
    if (_culturalAdaptation == null) {
      return const Center(
        child: Text('No cultural adaptation data available for current region/language'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧠 Cultural Adaptation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildCulturalSection(
            'Communication Preferences',
            _culturalAdaptation!.culturalPreferences,
            Icons.chat,
          ),
          const SizedBox(height: 16),
          _buildCulturalSection(
            'Sensitive Topics',
            _culturalAdaptation!.sensitiveTopics.map((key, value) => MapEntry(key, value.join(', '))),
            Icons.warning,
          ),
          const SizedBox(height: 16),
          _buildCulturalSection(
            'Color Meanings',
            _culturalAdaptation!.colorMeanings,
            Icons.palette,
          ),
          const SizedBox(height: 16),
          _buildCulturalSection(
            'Symbol Meanings',
            _culturalAdaptation!.symbolMeanings,
            Icons.emoji_symbols,
          ),
        ],
      ),
    );
  }

  /// Cultural Section
  Widget _buildCulturalSection(String title, Map<String, String> data, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Analytics Tab
  Widget _buildAnalyticsTab() {
    if (_localizationReport == null) {
      return const Center(
        child: Text('Localization analytics data not available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Localization Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsOverview(),
          const SizedBox(height: 24),
          _buildLanguageMetrics(),
        ],
      ),
    );
  }

  /// Analytics Overview
  Widget _buildAnalyticsOverview() {
    final report = _localizationReport!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsItem(
                    'Languages',
                    report.languageMetrics.length.toString(),
                    Icons.language,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticsItem(
                    'Active Projects',
                    report.activeProjects.length.toString(),
                    Icons.work,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticsItem(
                    'Needs Attention',
                    report.languagesNeedingAttention.length.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Analytics Item
  Widget _buildAnalyticsItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Language Metrics
  Widget _buildLanguageMetrics() {
    final report = _localizationReport!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌍 Language Performance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...report.languageMetrics.values.map((metrics) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        metrics.languageCode.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${metrics.completionRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: metrics.completionRate >= 90
                              ? Colors.green
                              : metrics.completionRate >= 70
                                  ? Colors.orange
                                  : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: metrics.completionRate / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      metrics.completionRate >= 90
                          ? Colors.green
                          : metrics.completionRate >= 70
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${metrics.translatedKeys}/${metrics.totalKeys} keys • ${metrics.accuracyRate.toStringAsFixed(1)}% accuracy',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Helper methods
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
