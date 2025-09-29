import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../models/medication_guide_model.dart';
import '../../widgets/medication_guide/medication_search_panel.dart';
import '../../widgets/medication_guide/medication_details_panel.dart';
import '../../widgets/medication_guide/interaction_checker_panel.dart';
import '../../widgets/medication_guide/patient_guide_panel.dart';
import '../../widgets/medication_guide/treatment_protocol_panel.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class MedicationGuideScreen extends StatefulWidget {
  const MedicationGuideScreen({super.key});

  @override
  State<MedicationGuideScreen> createState() => _MedicationGuideScreenState();
}

class _MedicationGuideScreenState extends State<MedicationGuideScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  List<MedicationModel> _allMedications = [];
  MedicationModel? _selectedMedication;
  List<MedicationModel> _searchResults = [];
  List<MedicationModel> _recentMedications = [];
  List<MedicationModel> _favoriteMedications = [];
  bool _isSearching = false;
  String _selectedCategory = 'Tümü';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDemoMedications();
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _loadDemoMedications() {
    setState(() {
      _allMedications = [
        // Antidepresanlar
        MedicationModel(
          id: '1',
          name: 'Escitalopram',
          genericName: 'Escitalopram oxalate',
          brandNames: ['Lexapro', 'Cipralex', 'Esertia'],
          internationalNames: ['Escitalopram', 'Escitalopramum'],
          category: MedicationCategory.antidepressant,
          subcategory: 'SSRI',
          indications: [
            'Major Depressive Disorder',
            'Generalized Anxiety Disorder',
            'Panic Disorder'
          ],
          offLabelIndications: [
            'Premenstrual Dysphoric Disorder',
            'Social Anxiety Disorder'
          ],
          dosage: '10-20mg daily',
          administration: 'Oral, with or without food',
          mechanism: 'Selective serotonin reuptake inhibitor (SSRI)',
          sideEffects: [
            'Mide bulantısı',
            'Uyku bozukluğu',
            'Cinsel işlev bozukluğu',
            'Baş ağrısı',
            'Terleme'
          ],
          seriousSideEffects: [
            'Serotonin sendromu',
            'Suicidal thoughts',
            'Bleeding risk',
            'Hyponatremia'
          ],
          contraindications: [
            'MAOI kullanımı (14 gün ara)',
            'Serotonin sendromu riski',
            'Gebelik (C kategorisi)',
            'Emzirme dönemi'
          ],
          interactions: [
            'MAOI: Serotonin sendromu riski',
            'NSAID: Kanama riski artışı',
            'Warfarin: INR artışı',
            'St. John\'s Wort: Etki azalması'
          ],
          warnings: [
            '18 yaş altında intihar düşüncesi artabilir',
            'Aniden kesmeyin, dozu kademeli azaltın',
            'Serotonin sendromu belirtilerini izleyin'
          ],
          precautions: [
            'Liver function monitoring',
            'Renal function monitoring',
            'Bleeding risk assessment'
          ],
          pregnancyCategory: 'C',
          lactationCategory: 'L3',
          pediatricUse: 'Limited data, monitor closely',
          geriatricUse: 'Start with lower dose',
          hepaticImpairment: 'Use with caution',
          renalImpairment: 'No dose adjustment needed',
          halfLife: '27-32 saat',
          metabolism: 'CYP2C19, CYP3A4',
          excretion: 'Renal (8-10%)',
          approvalStatus: {
            'FDA': 'Approved',
            'EMA': 'Approved',
            'TİTCK': 'Approved',
          },
          approvalDates: {
            'FDA': DateTime(2002, 8, 14),
            'EMA': DateTime(2001, 3, 15),
            'TİTCK': DateTime(2003, 1, 20),
          },
          regulatoryStatus: {
            'FDA': 'Active',
            'EMA': 'Active',
            'TİTCK': 'Active',
          },
          cost: 'Orta',
          availability: 'Yaygın',
          alternatives: ['Sertraline', 'Fluoxetine', 'Paroxetine'],
          combinationProducts: ['Escitalopram + Bupropion'],
          clinicalData: {
            'efficacy': 'High',
            'safety': 'Good',
            'tolerability': 'Moderate'
          },
          clinicalTrials: [],
          publications: [],
          guidelines: {
            'APA': 'First-line treatment for MDD',
            'NICE': 'Recommended for GAD'
          },
          notes: 'Well-tolerated SSRI with good efficacy',
          dataSource: 'FDA, EMA, TİTCK databases',
          evidenceQuality: 'A',
        ),
      ];
    });
  }

  void _onMedicationSelected(MedicationModel medication) {
    setState(() {
      _selectedMedication = medication;
    });
    _tabController.animateTo(1); // Details tab'ına geç
  }

  void _onSearchPerformed(String query, List<MedicationModel> results) {
    setState(() {
      _searchResults = results;
      _isSearching = true;
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
    return DesktopLayout(
      title: 'İlaç Rehberi',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Arama',
          onPressed: _clearSearch,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'AI Öneri',
          onPressed: _generateAIRecommendation,
          icon: Icons.auto_awesome,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'İstatistikler',
          onPressed: _showMedicationStatistics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportMedicationReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showMedicationSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'İlaç Arama',
          icon: Icons.search,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'İlaç Detayları',
          icon: Icons.medication,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Etkileşim Kontrolü',
          icon: Icons.warning,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Danışan Rehberi',
          icon: Icons.description,
          onTap: () => _tabController.animateTo(3),
        ),
        DesktopSidebarItem(
          title: 'Tedavi Protokolleri',
          icon: Icons.medical_services,
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
        _buildDesktopSearchTab(),
        _buildDesktopDetailsTab(),
        _buildDesktopInteractionTab(),
        _buildDesktopPatientGuideTab(),
        _buildDesktopProtocolTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlaç Rehberi'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'İlaç Arama'),
            Tab(icon: Icon(Icons.medication), text: 'İlaç Detayları'),
            Tab(icon: Icon(Icons.warning), text: 'Etkileşim Kontrolü'),
            Tab(icon: Icon(Icons.description), text: 'Danışan Rehberi'),
            Tab(
                icon: Icon(Icons.medical_services),
                text: 'Tedavi Protokolleri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: İlaç Arama
          MedicationSearchPanel(
            allMedications: _allMedications,
            searchResults: _searchResults,
            isSearching: _isSearching,
            onMedicationSelected: _onMedicationSelected,
            onSearchPerformed: _onSearchPerformed,
          ),

          // Tab 2: İlaç Detayları
          if (_selectedMedication != null)
            MedicationDetailsPanel(
              medication: _selectedMedication!,
            )
          else
            const Center(
              child: Text('Lütfen bir ilaç seçin'),
            ),

          // Tab 3: Etkileşim Kontrolü
          InteractionCheckerPanel(
            allMedications: _allMedications,
          ),

          // Tab 4: Danışan Rehberi
          PatientGuidePanel(
            selectedMedication: _selectedMedication,
          ),

          // Tab 5: Tedavi Protokolleri
          TreatmentProtocolPanel(
            selectedMedication: _selectedMedication,
          ),
        ],
      ),
    );
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
      () => _focusSearch(),
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _clearSearch,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _generateAIRecommendation,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _showMedicationSettings,
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
            'İlaç Arama',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: MedicationSearchPanel(
                allMedications: _allMedications,
                searchResults: _searchResults,
                isSearching: _isSearching,
                onMedicationSelected: _onMedicationSelected,
                onSearchPerformed: _onSearchPerformed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İlaç Detayları',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_selectedMedication != null)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: MedicationDetailsPanel(
                  medication: _selectedMedication!,
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
                      Icon(Icons.medication, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Lütfen bir ilaç seçin',
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

  Widget _buildDesktopInteractionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Etkileşim Kontrolü',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: InteractionCheckerPanel(
                allMedications: _allMedications,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPatientGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danışan Rehberi',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: PatientGuidePanel(
                selectedMedication: _selectedMedication,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProtocolTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tedavi Protokolleri',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: TreatmentProtocolPanel(
                selectedMedication: _selectedMedication,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yeni özellikler için metodlar
  void _loadDemoMedications() {
    setState(() {
      _allMedications = [
        // Antidepresanlar
        MedicationModel(
          id: '1',
          name: 'Escitalopram',
          genericName: 'Escitalopram oxalate',
          brandNames: ['Lexapro', 'Cipralex', 'Esertia'],
          internationalNames: ['Escitalopram', 'Escitalopramum'],
          category: MedicationCategory.antidepressant,
          subcategory: 'SSRI',
          indications: [
            'Major Depressive Disorder',
            'Generalized Anxiety Disorder',
            'Panic Disorder'
          ],
          offLabelIndications: [
            'Premenstrual Dysphoric Disorder',
            'Social Anxiety Disorder'
          ],
          dosage: '10-20mg daily',
          administration: 'Oral, with or without food',
          mechanism: 'Selective serotonin reuptake inhibitor (SSRI)',
          sideEffects: [
            'Mide bulantısı',
            'Uyku bozukluğu',
            'Cinsel işlev bozukluğu',
            'Baş ağrısı',
            'Terleme'
          ],
          seriousSideEffects: [
            'Serotonin sendromu',
            'Suicidal thoughts',
            'Bleeding risk',
            'Hyponatremia'
          ],
          contraindications: [
            'MAOI kullanımı (14 gün ara)',
            'Serotonin sendromu riski',
            'Gebelik (C kategorisi)',
            'Emzirme dönemi'
          ],
          interactions: [
            'MAOI: Serotonin sendromu riski',
            'NSAID: Kanama riski artışı',
            'Warfarin: INR artışı',
            'St. John\'s Wort: Etki azalması'
          ],
          warnings: [
            '18 yaş altında intihar düşüncesi artabilir',
            'Aniden kesmeyin, dozu kademeli azaltın',
            'Serotonin sendromu belirtilerini izleyin'
          ],
          precautions: [
            'Liver function monitoring',
            'Renal function monitoring',
            'Bleeding risk assessment'
          ],
          pregnancyCategory: 'C',
          lactationCategory: 'L3',
          pediatricUse: 'Limited data, monitor closely',
          geriatricUse: 'Start with lower dose',
          alternatives: ['Sertraline', 'Fluoxetine', 'Paroxetine'],
          combinationProducts: ['Escitalopram + Bupropion'],
          clinicalData: {
            'efficacy': 'High',
            'safety': 'Good',
            'tolerability': 'Moderate'
          },
          clinicalTrials: [],
          publications: [],
          guidelines: {
            'APA': 'First-line treatment for MDD',
            'NICE': 'Recommended for GAD'
          },
          notes: 'Well-tolerated SSRI with good efficacy',
          dataSource: 'FDA, EMA, TİTCK databases',
          evidenceQuality: 'A',
        ),
      ];
      _recentMedications = _getDemoRecentMedications();
      _favoriteMedications = _getDemoFavoriteMedications();
    });
  }

  List<MedicationModel> _getDemoRecentMedications() {
    return [
      _allMedications.first,
    ];
  }

  List<MedicationModel> _getDemoFavoriteMedications() {
    return [
      _allMedications.first,
    ];
  }

  void _addToFavorites(MedicationModel medication) {
    setState(() {
      if (!_favoriteMedications.contains(medication)) {
        _favoriteMedications.add(medication);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication.name} favorilere eklendi'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _removeFromFavorites(MedicationModel medication) {
    setState(() {
      _favoriteMedications.remove(medication);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication.name} favorilerden çıkarıldı'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _addToRecent(MedicationModel medication) {
    setState(() {
      _recentMedications.remove(medication); // Eğer varsa kaldır
      _recentMedications.insert(0, medication); // Başa ekle
      if (_recentMedications.length > 10) {
        _recentMedications.removeLast(); // Son 10 ilacı tut
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchResults.clear();
      _isSearching = false;
    });
  }

  void _focusSearch() {
    // TODO: Arama alanına odaklanma
  }

  void _generateAIRecommendation() {
    // TODO: AI öneri oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI öneri oluşturuluyor...')),
    );
  }

  void _showMedicationStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlaç İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticItem('Toplam İlaç', '${_allMedications.length}'),
            _buildStatisticItem('Son Aramalar', '${_recentMedications.length}'),
            _buildStatisticItem('Favoriler', '${_favoriteMedications.length}'),
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

  void _exportMedicationReport() {
    // TODO: İlaç raporu export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İlaç raporu PDF olarak export ediliyor...')),
    );
  }

  void _showMedicationSettings() {
    // TODO: İlaç ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İlaç ayarları yakında gelecek')),
    );
  }
}
