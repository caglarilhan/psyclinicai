import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../../config/country_config.dart';
import '../../utils/theme.dart';
import '../../widgets/common/country_selector_widget.dart';
import '../../widgets/prescription/prescription_form.dart';
import '../../widgets/prescription/interaction_checker.dart';
import '../../widgets/prescription/ai_recommendation_panel.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  
  String _selectedCountry = CountryConfig.currentCountry;
  bool _showCountryInfo = false;
  List<Map<String, dynamic>> _recentPrescriptions = [];
  List<Map<String, dynamic>> _favoriteMedications = [];
  String _selectedCategory = 'Tümü';
  String _selectedSeverity = 'Tümü';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _setupKeyboardShortcuts();
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _onCountryChanged(String countryCode) {
    setState(() {
      _selectedCountry = countryCode;
      _showCountryInfo = true;
    });
    
    // 3 saniye sonra ülke bilgisini gizle
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showCountryInfo = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (DesktopTheme.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    final countryInfo = CountryConfig.supportedCountries[_selectedCountry]!;
    
    return DesktopLayout(
      title: 'Reçete Sistemi',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Reçete',
          onPressed: _createNewPrescription,
          icon: Icons.add,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'AI Öneri',
          onPressed: _generateAIRecommendation,
          icon: Icons.auto_awesome,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Etkileşim Kontrolü',
          onPressed: _checkInteractions,
          icon: Icons.medical_services,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'İstatistikler',
          onPressed: _showPrescriptionStatistics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportPrescriptionReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showPrescriptionSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Reçete Formu',
          icon: Icons.medical_services,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'AI Öneriler',
          icon: Icons.auto_awesome,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Etkileşim Kontrolü',
          icon: Icons.warning,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Son Reçeteler',
          icon: Icons.history,
          onTap: () => _tabController.animateTo(3),
        ),
        DesktopSidebarItem(
          title: 'Favori İlaçlar',
          icon: Icons.favorite,
          onTap: () => _tabController.animateTo(4),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDesktopPrescriptionFormTab(),
        _buildDesktopAIRecommendationsTab(),
        _buildDesktopInteractionCheckerTab(),
        _buildDesktopRecentTab(),
        _buildDesktopFavoritesTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final countryInfo = CountryConfig.supportedCountries[_selectedCountry]!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Reçete Sistemi',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              countryInfo['flag'],
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showCountrySelector(),
            icon: Icon(
              Icons.public,
              color: AppTheme.primaryColor,
            ),
            tooltip: 'Ülke Seçimi',
          ),
        ],
      ),
      body: Column(
        children: [
          // Ülke Bilgi Kartı
          if (_showCountryInfo)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${countryInfo['name']} İlaç Sistemi Aktif',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Birincil Sistem: ${countryInfo['primarySystem']}',
                          style: TextStyle(
                            color: AppTheme.primaryColor.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Düzenleyici: ${countryInfo['regulatoryBody']}',
                          style: TextStyle(
                            color: AppTheme.primaryColor.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showCountryInfo = false),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: Icon(Icons.medication, size: 20),
                  text: 'Reçete',
                ),
                Tab(
                  icon: Icon(Icons.warning, size: 20),
                  text: 'Etkileşim',
                ),
                Tab(
                  icon: Icon(Icons.psychology, size: 20),
                  text: 'AI Öneri',
                ),
                Tab(
                  icon: Icon(Icons.settings, size: 20),
                  text: 'Ayarlar',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Reçete Formu
                  _buildPrescriptionTab(),
                  
                  // Etkileşim Kontrolü
                  _buildInteractionTab(),
                  
                  // AI Öneri
                  _buildAIRecommendationTab(),
                  
                  // Ayarlar
                  _buildSettingsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionTab() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: PrescriptionForm(
        onPrescriptionCreated: (prescription) {
          // Handle prescription creation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reçete oluşturuldu: ${prescription.id}')),
          );
        },
      ),
    );
  }

  Widget _buildInteractionTab() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InteractionChecker(
        medications: ['Sertraline', 'Alprazolam'], // Mock medications
        onInteractionsFound: (interactions) {
          // Handle interactions found
          if (interactions.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${interactions.length} etkileşim bulundu')),
            );
          }
        },
      ),
    );
  }

  Widget _buildAIRecommendationTab() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: AIRecommendationPanel(
        onGenerateRecommendation: (diagnosis, medications) {
          // Handle AI recommendation generation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI önerisi oluşturuluyor...')),
          );
        },
        recommendation: 'AI önerisi burada görünecek',
        isGenerating: false,
      ),
    );
  }

  Widget _buildSettingsTab() {
    final countryInfo = CountryConfig.supportedCountries[_selectedCountry]!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ülke Ayarları
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          countryInfo['flag'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ülke Ayarları',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                countryInfo['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showCountrySelector(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Değiştir'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingRow('Birincil Sistem', countryInfo['primarySystem']),
                    _buildSettingRow('Düzenleyici Kurum', countryInfo['regulatoryBody']),
                    _buildSettingRow('İlaç Veritabanı', countryInfo['drugDatabase']),
                    _buildSettingRow('Para Birimi', countryInfo['currency']),
                    _buildSettingRow('Dil', countryInfo['language']),
                    _buildSettingRow('Zaman Dilimi', countryInfo['timezone']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sistem Özellikleri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sistem Özellikleri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow('Patent Sistemi', countryInfo['patentSystem']),
                    _buildFeatureRow('Jenerik İkame', countryInfo['genericSubstitution']),
                    _buildFeatureRow('Reçete Gerekli', countryInfo['prescriptionRequired']),
                    _buildFeatureRow('OTC Mevcut', countryInfo['otcAvailable']),
                    _buildFeatureRow('Böbrek Ayarlamaları', countryInfo['renalAdjustments']),
                    _buildFeatureRow('Karaciğer Ayarlamaları', countryInfo['hepaticAdjustments']),
                    _buildFeatureRow('Genetik Test', countryInfo['geneticTesting']),
                    _buildFeatureRow('Farmakogenomik', countryInfo['pharmacogenomics']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sigorta ve Düzenleme
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sigorta ve Düzenleme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingRow('Sigorta Kapsamı', countryInfo['insuranceCoverage']),
                    _buildSettingRow('Eczane Düzenlemesi', countryInfo['pharmacyRegulation']),
                    _buildSettingRow('Klinik Rehberleri', countryInfo['clinicalGuidelines']),
                    _buildSettingRow('İlaç Etkileşimleri', countryInfo['drugInteractions']),
                    _buildSettingRow('Yan Etkiler', countryInfo['sideEffects']),
                    _buildSettingRow('Doz Rehberleri', countryInfo['dosageGuidelines']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Gebelik ve Emzirme Kategorileri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gebelik ve Emzirme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildListSettingRow('Gebelik Kategorileri', countryInfo['pregnancyCategories']),
                    _buildListSettingRow('Emzirme Kategorileri', countryInfo['lactationCategories']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? AppTheme.successColor : AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            value ? 'Mevcut' : 'Mevcut Değil',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: value ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSettingRow(String label, List<dynamic> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: values.map((value) => Chip(
              label: Text(
                value.toString(),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: AppTheme.primaryColor),
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _showCountrySelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ülke Seçimi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              CountrySelectorWidget(
                onCountryChanged: _onCountryChanged,
                initialCountry: _selectedCountry,
                showLabel: false,
                width: 300,
              ),
              const SizedBox(height: 16),
              Text(
                'Seçilen ülkeye göre ilaç sistemi ve özellikler otomatik olarak ayarlanır',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      _createNewPrescription,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _generateAIRecommendation,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyI, LogicalKeyboardKey.control),
      _checkInteractions,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _showPrescriptionSettings,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyI, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
  }

  // Masaüstü tab metodları
  Widget _buildDesktopPrescriptionFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reçete Formu',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: PrescriptionForm(
                selectedCountry: _selectedCountry,
                onCountryChanged: _onCountryChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAIRecommendationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI İlaç Önerileri',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AIRecommendationPanel(
                selectedCountry: _selectedCountry,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopInteractionCheckerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İlaç Etkileşim Kontrolü',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: InteractionChecker(
                selectedCountry: _selectedCountry,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopRecentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Reçeteler',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_recentPrescriptions.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son ${_recentPrescriptions.length} Reçete',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._recentPrescriptions.map((prescription) => _buildPrescriptionListItem(prescription)),
                  ],
                ),
              ),
            )
          else
            DesktopTheme.desktopCard(
              child: const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Henüz reçete oluşturulmadı',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopFavoritesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favori İlaçlar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_favoriteMedications.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_favoriteMedications.length} Favori İlaç',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._favoriteMedications.map((medication) => _buildMedicationListItem(medication)),
                  ],
                ),
              ),
            )
          else
            DesktopTheme.desktopCard(
              child: const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Henüz favori ilaç eklenmedi',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionListItem(Map<String, dynamic> prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            prescription['id'],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(prescription['patientName'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${prescription['medication']} - ${prescription['dosage']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: prescription['status'] == 'Active' ? AppTheme.successColor : AppTheme.errorColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                prescription['status'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showPrescriptionDetails(prescription),
            ),
          ],
        ),
        onTap: () => _showPrescriptionDetails(prescription),
      ),
    );
  }

  Widget _buildMedicationListItem(Map<String, dynamic> medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor,
          child: Icon(Icons.medical_services, color: Colors.white),
        ),
        title: Text(medication['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${medication['dosage']} - ${medication['category']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _removeFromFavorites(medication),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showMedicationDetails(medication),
            ),
          ],
        ),
        onTap: () => _showMedicationDetails(medication),
      ),
    );
  }

  void _showPrescriptionDetails(Map<String, dynamic> prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reçete #${prescription['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Hasta', prescription['patientName']),
            _buildDetailRow('İlaç', prescription['medication']),
            _buildDetailRow('Dozaj', prescription['dosage']),
            _buildDetailRow('Süre', prescription['duration']),
            _buildDetailRow('Tarih', prescription['date']),
            _buildDetailRow('Durum', prescription['status']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Yardımcı metodlar
  void _createNewPrescription() {
    // TODO: Yeni reçete oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni reçete oluşturuluyor...')),
    );
  }

  void _generateAIRecommendation() {
    // TODO: AI öneri oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI öneri oluşturuluyor...')),
    );
  }

  void _checkInteractions() {
    // TODO: Etkileşim kontrolü
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İlaç etkileşimleri kontrol ediliyor...')),
    );
  }

  void _showPrescriptionHistory() {
    // TODO: Reçete geçmişi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reçete geçmişi yakında gelecek')),
    );
  }

  void _showPrescriptionSettings() {
    // TODO: Reçete ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reçete ayarları yakında gelecek')),
    );
  }

  // Yeni özellikler için metodlar
  void _loadInitialData() {
    setState(() {
      _recentPrescriptions = _getDemoPrescriptions();
      _favoriteMedications = _getDemoFavoriteMedications();
    });
  }

  List<Map<String, dynamic>> _getDemoPrescriptions() {
    return [
      {
        'id': '1',
        'patientName': 'Ahmet Yılmaz',
        'medication': 'Sertraline 50mg',
        'dosage': '1 tablet daily',
        'duration': '30 days',
        'date': '2024-01-15',
        'status': 'Active',
      },
      {
        'id': '2',
        'patientName': 'Fatma Demir',
        'medication': 'Escitalopram 10mg',
        'dosage': '1 tablet daily',
        'duration': '60 days',
        'date': '2024-01-10',
        'status': 'Active',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoFavoriteMedications() {
    return [
      {
        'name': 'Sertraline',
        'dosage': '50mg',
        'category': 'Antidepressant',
        'frequency': 'Daily',
        'notes': 'SSRI - First line treatment for depression',
      },
      {
        'name': 'Escitalopram',
        'dosage': '10mg',
        'category': 'Antidepressant',
        'frequency': 'Daily',
        'notes': 'SSRI - Well tolerated, low side effects',
      },
    ];
  }

  void _addToFavorites(Map<String, dynamic> medication) {
    setState(() {
      if (!_favoriteMedications.contains(medication)) {
        _favoriteMedications.add(medication);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} favorilere eklendi'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _removeFromFavorites(Map<String, dynamic> medication) {
    setState(() {
      _favoriteMedications.remove(medication);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} favorilerden çıkarıldı'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _addToRecent(Map<String, dynamic> prescription) {
    setState(() {
      _recentPrescriptions.remove(prescription); // Eğer varsa kaldır
      _recentPrescriptions.insert(0, prescription); // Başa ekle
      if (_recentPrescriptions.length > 10) {
        _recentPrescriptions.removeLast(); // Son 10 reçeteyi tut
      }
    });
  }

  List<String> _getCategories() {
    return ['Tümü', 'Antidepressant', 'Anxiolytic', 'Antipsychotic', 'Mood Stabilizer'];
  }

  List<String> _getSeverities() {
    return ['Tümü', 'Mild', 'Moderate', 'Severe'];
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _filterBySeverity(String severity) {
    setState(() {
      _selectedSeverity = severity;
      _applyFilters();
    });
  }

  void _applyFilters() {
    // TODO: Filtreleme mantığı
  }

  void _exportPrescriptionReport() {
    // TODO: Reçete raporu export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reçete raporu PDF olarak export ediliyor...')),
    );
  }

  void _showPrescriptionStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reçete İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticItem('Toplam Reçete', '${_recentPrescriptions.length}'),
            _buildStatisticItem('Aktif Reçeteler', '${_recentPrescriptions.where((p) => p['status'] == 'Active').length}'),
            _buildStatisticItem('Favori İlaçlar', '${_favoriteMedications.length}'),
            _buildStatisticItem('En Popüler Kategori', 'Antidepressant'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showMedicationDetails(Map<String, dynamic> medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medication['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Dozaj', medication['dosage']),
            _buildDetailRow('Kategori', medication['category']),
            _buildDetailRow('Frekans', medication['frequency']),
            _buildDetailRow('Notlar', medication['notes']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addToFavorites(medication);
            },
            child: const Text('Favorilere Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
