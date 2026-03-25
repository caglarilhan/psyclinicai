import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _Diagnosis {
  final String icdCode;
  final String dsmCode;
  final String name;
  final String description;
  final String category;
  final String system; // 'DSM-5', 'ICD-11', or 'both'

  const _Diagnosis({
    required this.icdCode,
    required this.dsmCode,
    required this.name,
    required this.description,
    required this.category,
    this.system = 'both',
  });
}

class _DiagnosisCategory {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final String description;

  const _DiagnosisCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.description,
  });
}

class _AiSuggestion {
  final _Diagnosis diagnosis;
  final double confidence;
  final List<String> matchingSymptoms;

  const _AiSuggestion({
    required this.diagnosis,
    required this.confidence,
    required this.matchingSymptoms,
  });
}

class _RecentDiagnosis {
  final _Diagnosis diagnosis;
  final int patientCount;
  final DateTime lastUsed;

  const _RecentDiagnosis({
    required this.diagnosis,
    required this.patientCount,
    required this.lastUsed,
  });
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

const List<_Diagnosis> _mockDiagnoses = [
  _Diagnosis(
    icdCode: 'F32.1',
    dsmCode: '296.22',
    name: 'Major Depresif Bozukluk',
    description:
        'En az iki hafta suren, belirgin depresif duygudurum veya ilgi/zevk kaybi ile karakterize ruhsal bozukluk. Uyku, istah, enerji ve konsantrasyon degisiklikleri eslik edebilir.',
    category: 'Duygudurum Bozukluklari',
  ),
  _Diagnosis(
    icdCode: 'F41.1',
    dsmCode: '300.02',
    name: 'Yaygin Anksiyete Bozuklugu',
    description:
        'En az alti aydir suren, kontrol edilmesi guc, asiri kaygi ve endise durumu. Huzursuzluk, yorgunluk, konsantrasyon guclugu, kas gerginligi ve uyku bozukluklari eslik eder.',
    category: 'Anksiyete Bozukluklari',
  ),
  _Diagnosis(
    icdCode: 'F43.1',
    dsmCode: '309.81',
    name: 'Travma Sonrasi Stres Bozuklugu (TSSB)',
    description:
        'Travmatik bir olayin ardindan gelisen, yeniden yasama, kacinma, olumsuz bilis ve duygudurum degisiklikleri ile asiri uyarilmislik belirtileri gosteren bozukluk.',
    category: 'Travma ve Stresle Iliskili Bozukluklar',
  ),
  _Diagnosis(
    icdCode: 'F40.10',
    dsmCode: '300.23',
    name: 'Sosyal Anksiyete Bozuklugu (Sosyal Fobi)',
    description:
        'Sosyal durumlarda baskalari tarafindan degerlendirilme korkusu ile karakterize, belirgin anksiyete ve kacinma davranisi gosteren bozukluk.',
    category: 'Anksiyete Bozukluklari',
  ),
  _Diagnosis(
    icdCode: 'F42',
    dsmCode: '300.3',
    name: 'Obsesif Kompulsif Bozukluk (OKB)',
    description:
        'Tekrarlayan, istemsiz dusunceler (obsesyonlar) ve bu dusunceleri azaltmak icin yapilan tekrarlayici davranislar (kompulsiyonlar) ile karakterize bozukluk.',
    category: 'Anksiyete Bozukluklari',
  ),
  _Diagnosis(
    icdCode: 'F31.9',
    dsmCode: '296.80',
    name: 'Bipolar Bozukluk',
    description:
        'Manik, hipomanik ve depresif donemlerle karakterize duygudurum bozuklugu. Enerji, aktivite duzeyi ve gunluk islevsellikte belirgin dalgalanmalar gorulur.',
    category: 'Duygudurum Bozukluklari',
  ),
  _Diagnosis(
    icdCode: 'F50.0',
    dsmCode: '307.1',
    name: 'Anoreksiya Nervoza',
    description:
        'Kilo almaktan yogun korku, bozulmus beden algisi ve belirgin dusuk vucut agirligi ile karakterize yeme bozuklugu. Ciddi tibbi komplikasyonlara yol acabilir.',
    category: 'Yeme Bozukluklari',
  ),
  _Diagnosis(
    icdCode: 'F90.0',
    dsmCode: '314.01',
    name: 'Dikkat Eksikligi Hiperaktivite Bozuklugu (DEHB)',
    description:
        'Dikkat eksikligi, hiperaktivite ve durtuselllik belirtileri ile karakterize norogelisimsel bozukluk. Cocuklukta baslar ve eriskinlikte devam edebilir.',
    category: 'Norogelisimsel Bozukluklar',
  ),
];

const List<_DiagnosisCategory> _mockCategories = [
  _DiagnosisCategory(
    title: 'Duygudurum Bozukluklari',
    icon: Icons.mood,
    color: Color(0xFF6B46C1),
    count: 12,
    description: 'Depresyon, bipolar bozukluk ve iliskili durumlar',
  ),
  _DiagnosisCategory(
    title: 'Anksiyete Bozukluklari',
    icon: Icons.psychology_alt,
    color: Color(0xFF2563EB),
    count: 9,
    description: 'Yaygin anksiyete, sosyal fobi, OKB ve panik bozukluk',
  ),
  _DiagnosisCategory(
    title: 'Travma ve Stresle Iliskili',
    icon: Icons.flash_on,
    color: Color(0xFFDC2626),
    count: 6,
    description: 'TSSB, akut stres bozuklugu ve uyum bozukluklari',
  ),
  _DiagnosisCategory(
    title: 'Kisilik Bozukluklari',
    icon: Icons.person_outline,
    color: Color(0xFFD97706),
    count: 10,
    description: 'Sinirda, narsisistik, antisosyal ve diger kisilik bozukluklari',
  ),
  _DiagnosisCategory(
    title: 'Yeme Bozukluklari',
    icon: Icons.restaurant,
    color: Color(0xFF059669),
    count: 5,
    description: 'Anoreksiya, bulimiya ve tiksinma bozuklugu',
  ),
  _DiagnosisCategory(
    title: 'Norogelisimsel Bozukluklar',
    icon: Icons.hub,
    color: Color(0xFF7C3AED),
    count: 8,
    description: 'DEHB, otizm spektrum bozuklugu ve ogrenme guclugu',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final TabController _tabController;

  String _selectedFilter = 'Tumu';
  String _searchQuery = '';
  int _selectedDiagnosisIndex = -1;

  // AI suggestions mock
  late final List<_AiSuggestion> _aiSuggestions;
  late final List<_RecentDiagnosis> _recentDiagnoses;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _setupKeyboardShortcuts();
    _initMockData();
  }

  void _initMockData() {
    _aiSuggestions = [
      _AiSuggestion(
        diagnosis: _mockDiagnoses[0],
        confidence: 0.87,
        matchingSymptoms: [
          'Depresif duygudurum',
          'Uyku bozuklugu',
          'Istah degisikligi',
          'Enerji kaybi',
        ],
      ),
      _AiSuggestion(
        diagnosis: _mockDiagnoses[1],
        confidence: 0.72,
        matchingSymptoms: [
          'Asiri endise',
          'Huzursuzluk',
          'Kas gerginligi',
        ],
      ),
      _AiSuggestion(
        diagnosis: _mockDiagnoses[5],
        confidence: 0.54,
        matchingSymptoms: [
          'Duygudurum dalgalanmasi',
          'Enerji degisiklikleri',
        ],
      ),
    ];

    final now = DateTime.now();
    _recentDiagnoses = [
      _RecentDiagnosis(
        diagnosis: _mockDiagnoses[0],
        patientCount: 24,
        lastUsed: now.subtract(const Duration(hours: 2)),
      ),
      _RecentDiagnosis(
        diagnosis: _mockDiagnoses[1],
        patientCount: 18,
        lastUsed: now.subtract(const Duration(hours: 5)),
      ),
      _RecentDiagnosis(
        diagnosis: _mockDiagnoses[2],
        patientCount: 11,
        lastUsed: now.subtract(const Duration(days: 1)),
      ),
      _RecentDiagnosis(
        diagnosis: _mockDiagnoses[4],
        patientCount: 9,
        lastUsed: now.subtract(const Duration(days: 1, hours: 8)),
      ),
      _RecentDiagnosis(
        diagnosis: _mockDiagnoses[7],
        patientCount: 7,
        lastUsed: now.subtract(const Duration(days: 2)),
      ),
      _RecentDiagnosis(
        diagnosis: _mockDiagnoses[3],
        patientCount: 6,
        lastUsed: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Keyboard shortcuts
  // -------------------------------------------------------------------------

  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
      () => _searchFocusNode.requestFocus(),
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _clearSearch,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  // -------------------------------------------------------------------------
  // Filtering helpers
  // -------------------------------------------------------------------------

  List<_Diagnosis> get _filteredDiagnoses {
    var list = _mockDiagnoses.toList();

    if (_selectedFilter == 'DSM-5') {
      list = list.where((d) => d.system == 'DSM-5' || d.system == 'both').toList();
    } else if (_selectedFilter == 'ICD-11') {
      list = list.where((d) => d.system == 'ICD-11' || d.system == 'both').toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((d) {
        return d.name.toLowerCase().contains(q) ||
            d.icdCode.toLowerCase().contains(q) ||
            d.dsmCode.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q) ||
            d.category.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Tani Rehberi',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.file_download_outlined),
          tooltip: 'Disa Aktar',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Ayarlar',
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Tani Arama',
          icon: Icons.search,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Kategoriler',
          icon: Icons.category_outlined,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'AI Onerileri',
          icon: Icons.auto_awesome_outlined,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Son Tanilar',
          icon: Icons.history,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
      child: Column(
        children: [
          // Search bar + filter chips
          _buildSearchHeader(),
          const SizedBox(height: 4),
          // Tab bar
          _buildTabBar(),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildCategoriesTab(),
                _buildAiSuggestionsTab(),
                _buildRecentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Search header
  // -------------------------------------------------------------------------

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Tani kodu veya isim ile arayiniz... (Ctrl+F)',
              hintStyle: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: _clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8F9FC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.textTertiary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          Row(
            children: [
              const Text(
                'Siniflandirma:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterChip('Tumu'),
              const SizedBox(width: 8),
              _buildFilterChip('DSM-5'),
              const SizedBox(width: 8),
              _buildFilterChip('ICD-11'),
              const Spacer(),
              Text(
                '${_filteredDiagnoses.length} tani listeleniyor',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = label),
      selectedColor: AppTheme.primaryColor,
      backgroundColor: const Color(0xFFF3F4F6),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  // -------------------------------------------------------------------------
  // Tab bar
  // -------------------------------------------------------------------------

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2.5,
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: 'Tani Arama'),
          Tab(text: 'Kategoriler'),
          Tab(text: 'AI Onerileri'),
          Tab(text: 'Son Tanilar'),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 1 : Tani Arama
  // -------------------------------------------------------------------------

  Widget _buildSearchTab() {
    final diagnoses = _filteredDiagnoses;

    if (diagnoses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Aramanizla eslesen tani bulunamadi.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: diagnoses.length,
      itemBuilder: (context, index) {
        final d = diagnoses[index];
        final isSelected = index == _selectedDiagnosisIndex;
        return _buildDiagnosisCard(d, isSelected, () {
          setState(() => _selectedDiagnosisIndex = index);
        });
      },
    );
  }

  Widget _buildDiagnosisCard(
    _Diagnosis d,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Material(
        color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.4)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Code badge
                Column(
                  children: [
                    _buildCodeBadge(d.icdCode, const Color(0xFF2563EB)),
                    const SizedBox(height: 6),
                    _buildCodeBadge(d.dsmCode, const Color(0xFF7C3AED)),
                  ],
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBadge(String code, Color color) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        code,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 2 : Kategoriler
  // -------------------------------------------------------------------------

  Widget _buildCategoriesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.6,
        ),
        itemCount: _mockCategories.length,
        itemBuilder: (context, index) {
          final cat = _mockCategories[index];
          return _buildCategoryCard(cat);
        },
      ),
    );
  }

  Widget _buildCategoryCard(_DiagnosisCategory cat) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _searchController.text = cat.title;
            _searchQuery = cat.title;
            _tabController.animateTo(0);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${cat.count} tani',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cat.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                cat.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  cat.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 3 : AI Onerileri
  // -------------------------------------------------------------------------

  Widget _buildAiSuggestionsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.06),
                AppTheme.accentColor.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yapay Zeka Tani Onerileri',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hasta semptomlarini analiz ederek olasilikli tanilari siralamaktadir. '
                      'Oneriler klinik kararin yerini almaz.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Suggestions
        ..._aiSuggestions.map((s) => _buildAiSuggestionCard(s)),
      ],
    );
  }

  Widget _buildAiSuggestionCard(_AiSuggestion s) {
    final pct = (s.confidence * 100).toStringAsFixed(0);
    final color = s.confidence >= 0.8
        ? AppTheme.successColor
        : s.confidence >= 0.6
            ? AppTheme.warningColor
            : AppTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: code + name + confidence
            Row(
              children: [
                _buildCodeBadge(s.diagnosis.icdCode, const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                _buildCodeBadge(s.diagnosis.dsmCode, const Color(0xFF7C3AED)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    s.diagnosis.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '%$pct eslesme',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Confidence bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: s.confidence,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 14),
            // Matching symptoms
            const Text(
              'Eslesen Semptomlar:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: s.matchingSymptoms.map((symptom) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    symptom,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 4 : Son Tanilar
  // -------------------------------------------------------------------------

  Widget _buildRecentTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Summary row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.history, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 10),
              Text(
                'Son 30 gunde kullanilan tanilar (${_recentDiagnoses.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._recentDiagnoses.map((r) => _buildRecentCard(r)),
      ],
    );
  }

  Widget _buildRecentCard(_RecentDiagnosis r) {
    final d = r.diagnosis;
    final ago = _timeAgo(r.lastUsed);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            // Codes
            Column(
              children: [
                _buildCodeBadge(d.icdCode, const Color(0xFF2563EB)),
                const SizedBox(height: 6),
                _buildCodeBadge(d.dsmCode, const Color(0xFF7C3AED)),
              ],
            ),
            const SizedBox(width: 16),
            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Patient count + last used
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${r.patientCount} hasta',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ago,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk once';
    if (diff.inHours < 24) return '${diff.inHours} saat once';
    return '${diff.inDays} gun once';
  }
}
