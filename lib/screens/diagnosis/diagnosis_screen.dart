import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/diagnosis/diagnosis_search_bar.dart';
import '../../widgets/diagnosis/diagnosis_results.dart';
import '../../widgets/diagnosis/ai_diagnosis_panel.dart';
import '../../models/diagnosis_model.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  String _selectedCountry = AppConstants.targetCountries.first;
  List<DiagnosisModel> _searchResults = [];
  List<DiagnosisModel> _recentDiagnoses = [];
  List<DiagnosisModel> _favoriteDiagnoses = [];
  bool _isSearching = false;
  String _aiSuggestion = '';
  String _selectedCategory = 'Tümü';
  String _selectedSeverity = 'Tümü';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Demo veriler
    setState(() {
      _searchResults = _getDemoDiagnoses();
      _recentDiagnoses = _getRecentDiagnoses();
      _favoriteDiagnoses = _getFavoriteDiagnoses();
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isSearching = true);

    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simülasyon

      // AI destekli arama
      final results = _searchDiagnoses(query, _selectedCountry);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arama hatası: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  List<DiagnosisModel> _searchDiagnoses(String query, String country) {
    final standard = AppConstants.diagnosisStandards[country] ?? 'ICD-10';
    final allDiagnoses = _getAllDiagnoses(standard);

    return allDiagnoses.where((diagnosis) {
      return diagnosis.code.toLowerCase().contains(query.toLowerCase()) ||
          diagnosis.name.toLowerCase().contains(query.toLowerCase()) ||
          diagnosis.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<DiagnosisModel> _getAllDiagnoses(String standard) {
    if (standard.contains('DSM')) {
      return _getDSMDiagnoses();
    } else {
      return _getICDDiagnoses();
    }
  }

  List<DiagnosisModel> _getDSMDiagnoses() {
    return [
      DiagnosisModel(
        code: '296.32',
        name: 'Major Depressive Disorder, Moderate',
        description: 'Depresif duygudurum, ilgi kaybı, kilo değişikliği',
        category: 'Mood Disorders',
        severity: 'Moderate',
        standard: 'DSM-5-TR',
        symptoms: ['Üzgün duygudurum', 'İlgi kaybı', 'Uyku bozukluğu'],
        treatments: ['CBT', 'SSRI', 'Psikoterapi'],
      ),
      DiagnosisModel(
        code: '300.02',
        name: 'Generalized Anxiety Disorder',
        description: 'Sürekli endişe, huzursuzluk, konsantrasyon güçlüğü',
        category: 'Anxiety Disorders',
        severity: 'Mild to Moderate',
        standard: 'DSM-5-TR',
        symptoms: ['Aşırı endişe', 'Huzursuzluk', 'Yorgunluk'],
        treatments: ['CBT', 'Benzodiazepin', 'Relaksasyon'],
      ),
      DiagnosisModel(
        code: '309.81',
        name: 'Posttraumatic Stress Disorder',
        description: 'Travma sonrası stres bozukluğu, flashback\'ler',
        category: 'Trauma and Stressor-Related Disorders',
        severity: 'Severe',
        standard: 'DSM-5-TR',
        symptoms: ['Flashback\'ler', 'Kaçınma', 'Hipervijilans'],
        treatments: ['EMDR', 'Prolonged Exposure', 'SSRI'],
      ),
    ];
  }

  List<DiagnosisModel> _getICDDiagnoses() {
    return [
      DiagnosisModel(
        code: 'F32.1',
        name: 'Moderate depressive episode',
        description: 'Orta şiddette depresif dönem',
        category: 'Mood Disorders',
        severity: 'Moderate',
        standard: 'ICD-11',
        symptoms: [
          'Depresif duygudurum',
          'Enerji kaybı',
          'Konsantrasyon güçlüğü'
        ],
        treatments: ['CBT', 'Antidepresan', 'Psikoterapi'],
      ),
      DiagnosisModel(
        code: 'F41.1',
        name: 'Generalized anxiety disorder',
        description: 'Yaygın anksiyete bozukluğu',
        category: 'Anxiety Disorders',
        severity: 'Mild to Moderate',
        standard: 'ICD-11',
        symptoms: ['Sürekli endişe', 'Huzursuzluk', 'Uyku bozukluğu'],
        treatments: ['CBT', 'Anksiyolitik', 'Relaksasyon'],
      ),
      DiagnosisModel(
        code: 'F43.1',
        name: 'Post-traumatic stress disorder',
        description: 'Travma sonrası stres bozukluğu',
        category: 'Trauma and Stressor-Related Disorders',
        severity: 'Severe',
        standard: 'ICD-11',
        symptoms: [
          'Travma hatıraları',
          'Kaçınma davranışları',
          'Aşırı uyarılma'
        ],
        treatments: ['EMDR', 'Maruz bırakma', 'Antidepresan'],
      ),
    ];
  }

  List<DiagnosisModel> _getDemoDiagnoses() {
    return _getDSMDiagnoses() + _getICDDiagnoses();
  }

  @override
  Widget build(BuildContext context) {
    if (DesktopTheme.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return DesktopLayout(
      title: 'Tanı Sistemi',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Arama',
          onPressed: _clearSearch,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'AI Analiz',
          onPressed: _generateAIAnalysis,
          icon: Icons.auto_awesome,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'İstatistikler',
          onPressed: _showDiagnosisStatistics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportDiagnosisReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showDiagnosisSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Tanı Arama',
          icon: Icons.search,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'AI Öneriler',
          icon: Icons.auto_awesome,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Son Aramalar',
          icon: Icons.history,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Favoriler',
          icon: Icons.favorite,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDesktopSearchTab(),
        _buildDesktopAIRecommendationsTab(),
        _buildDesktopRecentTab(),
        _buildDesktopFavoritesTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanı Arama Sistemi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Arama'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Öneri'),
            Tab(icon: Icon(Icons.history), text: 'Son Aramalar'),
            Tab(icon: Icon(Icons.favorite), text: 'Favoriler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Tanı Arama
          _buildSearchTab(),

          // Tab 2: AI Öneri
          _buildAIRecommendationTab(),

          // Tab 3: Son Aramalar
          _buildRecentTab(),

          // Tab 4: Favoriler
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Üst panel - Ülke seçimi ve arama
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Ülke seçimi
              Row(
                children: [
                  Icon(
                    Icons.public,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tanı Standardı:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      '${_selectedCountry} (${AppConstants.diagnosisStandards[_selectedCountry]})',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showCountrySelectionDialog(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Değiştir'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Arama çubuğu
              DiagnosisSearchBar(
                controller: _searchController,
                onSearch: _performSearch,
                isSearching: _isSearching,
                placeholder: 'ICD/DSM kodu veya tanı adı ile arayın...',
              ),
            ],
          ),
        ),

        // Arama sonuçları
        Expanded(
          child: DiagnosisResults(
            results: _searchResults,
            isSearching: _isSearching,
            onDiagnosisSelected: (diagnosis) {
              _showDiagnosisDetail(context, diagnosis);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAIRecommendationTab() {
    return AIDiagnosisPanel(
      onGenerateRecommendation: _generateAIRecommendation,
      suggestion: _aiSuggestion,
    );
  }

  Widget _buildRecentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Aramalar',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_recentDiagnoses.isNotEmpty)
            ..._recentDiagnoses.map((diagnosis) => _buildDiagnosisListItem(diagnosis, true))
          else
            const Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz arama yapılmadı',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favori Tanılar',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_favoriteDiagnoses.isNotEmpty)
            ..._favoriteDiagnoses.map((diagnosis) => _buildDiagnosisListItem(diagnosis, false))
          else
            const Center(
              child: Column(
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz favori tanı eklenmedi',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _generateAIRecommendation(String symptoms) async {
    // TODO: AI service entegrasyonu
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _aiSuggestion = '''
Önerilen Tanı: Major Depressive Disorder (F32.1)

Güven Skoru: 85%

Belirtiler Eşleşmesi:
✅ Üzgün duygudurum (100%)
✅ İlgi kaybı (90%)
✅ Uyku bozukluğu (85%)
✅ Enerji kaybı (80%)

Önerilen Müdahale:
1. CBT (Bilişsel Davranışçı Terapi)
2. SSRI (Selektif Serotonin Geri Alım İnhibitörü)
3. Psikoeğitim
4. Sosyal destek grupları

Not: Bu öneri AI tarafından oluşturulmuştur. 
Kesin tanı için klinik değerlendirme gerekir.
        '''
          .trim();
    });
  }

  void _showCountrySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tanı Standardı Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.targetCountries.map((country) {
            final standard = AppConstants.diagnosisStandards[country];
            return RadioListTile<String>(
              title: Text(country),
              subtitle: Text(standard ?? 'Bilinmiyor'),
              value: country,
              groupValue: _selectedCountry,
              onChanged: (value) {
                setState(() => _selectedCountry = value!);
                Navigator.pop(context);
                _performSearch(_searchController.text);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDiagnosisDetail(BuildContext context, DiagnosisModel diagnosis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(diagnosis.name),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                diagnosis.code,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                diagnosis.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildDetailSection('Kategori', diagnosis.category),
              _buildDetailSection('Şiddet', diagnosis.severity),
              _buildDetailSection('Standard', diagnosis.standard),
              const SizedBox(height: 16),
              Text(
                'Belirtiler:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...diagnosis.symptoms.map(
                (symptom) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: AppTheme.accentColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text(symptom)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tedaviler:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...diagnosis.treatments.map(
                (treatment) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services,
                          size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text(treatment)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Tanıyı seans notuna ekle
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${diagnosis.name} seans notuna eklendi'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
            child: const Text('Seans Notuna Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
      () => _searchController.requestFocus(),
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _clearSearch,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _generateAIAnalysis,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _showDiagnosisSettings,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
  }

  // Masaüstü tab metodları
  Widget _buildDesktopSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanı Arama',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ülke seçimi
                  Row(
                    children: [
                      Icon(Icons.public, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tanı Standardı:',
                        style: DesktopTheme.desktopSectionTitleStyle,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Text(
                          '${_selectedCountry} (${AppConstants.diagnosisStandards[_selectedCountry]})',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      DesktopTheme.desktopButton(
                        text: 'Değiştir',
                        onPressed: () => _showCountrySelectionDialog(context),
                        icon: Icons.edit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Arama çubuğu
                  DiagnosisSearchBar(
                    controller: _searchController,
                    onSearch: _performSearch,
                    isSearching: _isSearching,
                    placeholder: 'ICD/DSM kodu veya tanı adı ile arayın...',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Arama sonuçları
          if (_searchResults.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arama Sonuçları (${_searchResults.length})',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    DiagnosisResults(
                      results: _searchResults,
                      onDiagnosisSelected: _showDiagnosisDetails,
                    ),
                  ],
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
            'AI Tanı Önerileri',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AIDiagnosisPanel(
                onGenerateSuggestion: _generateAISuggestion,
                suggestion: _aiSuggestion,
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
            'Son Aramalar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_recentDiagnoses.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son ${_recentDiagnoses.length} Arama',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._recentDiagnoses.map((diagnosis) => _buildDiagnosisListItem(diagnosis, true)),
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
                        'Henüz arama yapılmadı',
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
            'Favori Tanılar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_favoriteDiagnoses.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_favoriteDiagnoses.length} Favori Tanı',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._favoriteDiagnoses.map((diagnosis) => _buildDiagnosisListItem(diagnosis, false)),
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
                        'Henüz favori tanı eklenmedi',
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

  Widget _buildDiagnosisListItem(DiagnosisModel diagnosis, bool isRecent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            diagnosis.code.split('.').first,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(diagnosis.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(diagnosis.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _favoriteDiagnoses.contains(diagnosis) ? Icons.favorite : Icons.favorite_border,
                color: _favoriteDiagnoses.contains(diagnosis) ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                if (_favoriteDiagnoses.contains(diagnosis)) {
                  _removeFromFavorites(diagnosis);
                } else {
                  _addToFavorites(diagnosis);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showDiagnosisDetails(diagnosis),
            ),
          ],
        ),
        onTap: () {
          _addToRecent(diagnosis);
          _showDiagnosisDetails(diagnosis);
        },
      ),
    );
  }

  // Yardımcı metodlar
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
    });
  }

  void _generateAIAnalysis() {
    // TODO: AI analiz oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI analiz oluşturuluyor...')),
    );
  }

  void _generateDiagnosisReport() {
    // TODO: Tanı raporu oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tanı raporu oluşturuluyor...')),
    );
  }

  void _showDiagnosisSettings() {
    // TODO: Tanı ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tanı ayarları yakında gelecek')),
    );
  }

  // Yeni özellikler için metodlar
  List<DiagnosisModel> _getRecentDiagnoses() {
    return [
      DiagnosisModel(
        code: 'F32.1',
        name: 'Orta Depresif Epizod',
        description: 'Depresif duygudurum bozukluğu',
        category: 'Mood Disorders',
        severity: 'Moderate',
        standard: 'ICD-10',
        symptoms: ['Depresif duygudurum', 'İlgi kaybı', 'Kilo değişikliği'],
        treatments: ['Psikoterapi', 'Antidepresan'],
      ),
      DiagnosisModel(
        code: 'F41.1',
        name: 'Anksiyete Bozukluğu',
        description: 'Genelleşmiş anksiyete bozukluğu',
        category: 'Anxiety Disorders',
        severity: 'Mild',
        standard: 'ICD-10',
        symptoms: ['Aşırı endişe', 'Huzursuzluk', 'Konsantrasyon güçlüğü'],
        treatments: ['Bilişsel Davranışçı Terapi', 'Anksiyolitik'],
      ),
    ];
  }

  List<DiagnosisModel> _getFavoriteDiagnoses() {
    return [
      DiagnosisModel(
        code: 'F33.2',
        name: 'Bipolar Bozukluk',
        description: 'Manik depresif bozukluk',
        category: 'Mood Disorders',
        severity: 'Severe',
        standard: 'ICD-10',
        symptoms: ['Manik epizodlar', 'Depresif epizodlar', 'Duygudurum değişiklikleri'],
        treatments: ['Mood Stabilizer', 'Psikoterapi'],
      ),
    ];
  }

  void _addToFavorites(DiagnosisModel diagnosis) {
    setState(() {
      if (!_favoriteDiagnoses.contains(diagnosis)) {
        _favoriteDiagnoses.add(diagnosis);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${diagnosis.name} favorilere eklendi'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _removeFromFavorites(DiagnosisModel diagnosis) {
    setState(() {
      _favoriteDiagnoses.remove(diagnosis);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${diagnosis.name} favorilerden çıkarıldı'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _addToRecent(DiagnosisModel diagnosis) {
    setState(() {
      _recentDiagnoses.remove(diagnosis); // Eğer varsa kaldır
      _recentDiagnoses.insert(0, diagnosis); // Başa ekle
      if (_recentDiagnoses.length > 10) {
        _recentDiagnoses.removeLast(); // Son 10 tanıyı tut
      }
    });
  }

  List<String> _getCategories() {
    return ['Tümü', 'Mood Disorders', 'Anxiety Disorders', 'Psychotic Disorders', 'Personality Disorders'];
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
    if (_selectedCategory == 'Tümü' && _selectedSeverity == 'Tümü') {
      _searchResults = _getDemoDiagnoses();
    } else {
      _searchResults = _getDemoDiagnoses().where((diagnosis) {
        bool categoryMatch = _selectedCategory == 'Tümü' || diagnosis.category == _selectedCategory;
        bool severityMatch = _selectedSeverity == 'Tümü' || diagnosis.severity == _selectedSeverity;
        return categoryMatch && severityMatch;
      }).toList();
    }
  }

  void _exportDiagnosisReport() {
    // TODO: Tanı raporu export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tanı raporu PDF olarak export ediliyor...')),
    );
  }

  void _showDiagnosisStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tanı İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticItem('Toplam Tanı', '${_getDemoDiagnoses().length}'),
            _buildStatisticItem('Son Aramalar', '${_recentDiagnoses.length}'),
            _buildStatisticItem('Favoriler', '${_favoriteDiagnoses.length}'),
            _buildStatisticItem('En Popüler Kategori', 'Mood Disorders'),
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
}
