import 'package:flutter/material.dart';
import '../../config/country_config.dart';
import '../../utils/theme.dart';
import '../../widgets/common/country_selector_widget.dart';
import '../../widgets/prescription/prescription_form.dart';
import '../../widgets/prescription/interaction_checker.dart';
import '../../widgets/prescription/ai_recommendation_panel.dart';

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
  
  String _selectedCountry = CountryConfig.currentCountry;
  bool _showCountryInfo = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
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
}
