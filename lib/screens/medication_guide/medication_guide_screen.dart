import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../services/keyboard_shortcuts_service.dart';

class MedicationGuideScreen extends StatefulWidget {
  const MedicationGuideScreen({super.key});

  @override
  State<MedicationGuideScreen> createState() => _MedicationGuideScreenState();
}

class _MedicationGuideScreenState extends State<MedicationGuideScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const _kCardRadius = 12.0;
  static const _kSectionSpacing = 24.0;

  final List<_MedicationData> _medications = const [
    _MedicationData(
      name: 'Sertralin 50mg',
      activeIngredient: 'Sertralin HCl',
      form: 'Film Tablet',
      dose: '50 mg',
      category: 'Antidepresan (SSRI)',
      color: Color(0xFF6B46C1),
    ),
    _MedicationData(
      name: 'Fluoksetin 20mg',
      activeIngredient: 'Fluoksetin HCl',
      form: 'Kapsul',
      dose: '20 mg',
      category: 'Antidepresan (SSRI)',
      color: Color(0xFF7C3AED),
    ),
    _MedicationData(
      name: 'Alprazolam 0.5mg',
      activeIngredient: 'Alprazolam',
      form: 'Tablet',
      dose: '0.5 mg',
      category: 'Anksiyolitik (Benzodiazepin)',
      color: Color(0xFF2563EB),
    ),
    _MedicationData(
      name: 'Ketiapin 25mg',
      activeIngredient: 'Ketiapin Fumarat',
      form: 'Film Tablet',
      dose: '25 mg',
      category: 'Atipik Antipsikotik',
      color: Color(0xFFDC2626),
    ),
    _MedicationData(
      name: 'Lithium 300mg',
      activeIngredient: 'Lityum Karbonat',
      form: 'Tablet',
      dose: '300 mg',
      category: 'Duygudurum Dengeleyici',
      color: Color(0xFF059669),
    ),
    _MedicationData(
      name: 'Venlafaksin 75mg',
      activeIngredient: 'Venlafaksin HCl',
      form: 'Uzatilmis Salimli Kapsul',
      dose: '75 mg',
      category: 'Antidepresan (SNRI)',
      color: Color(0xFFD97706),
    ),
  ];

  final List<_CategoryData> _categories = const [
    _CategoryData(
      name: 'Antidepresanlar',
      icon: Icons.psychology_outlined,
      count: 14,
      color: Color(0xFF6B46C1),
      description: 'SSRI, SNRI, TCA, MAO-I ve diger antidepresan ilaclar',
    ),
    _CategoryData(
      name: 'Anksiyolitikler',
      icon: Icons.self_improvement,
      count: 8,
      color: Color(0xFF2563EB),
      description: 'Benzodiazepinler ve benzodiazepin disi anksiyolitikler',
    ),
    _CategoryData(
      name: 'Antipsikotikler',
      icon: Icons.medical_services_outlined,
      count: 10,
      color: Color(0xFFDC2626),
      description: 'Tipik ve atipik antipsikotik ilaclar',
    ),
    _CategoryData(
      name: 'Duygudurum Dengeleyicileri',
      icon: Icons.balance_outlined,
      count: 5,
      color: Color(0xFF059669),
      description: 'Lityum, valproat ve diger duygudurum dengeleyiciler',
    ),
    _CategoryData(
      name: 'Uyku Ilaclari',
      icon: Icons.nightlight_outlined,
      count: 6,
      color: Color(0xFF7C3AED),
      description: 'Hipnotikler ve sedatif etki gosteren ilaclar',
    ),
  ];

  final List<_InteractionData> _interactions = const [
    _InteractionData(
      drug1: 'Sertralin',
      drug2: 'MAO Inhibitorleri',
      severity: 'Ciddi',
      description:
          'Serotonin sendromu riski. Birlikte kullanim kontrendikedir. MAO-I kesilmesinden sonra en az 14 gun beklenmeli.',
      severityColor: Color(0xFFDC2626),
    ),
    _InteractionData(
      drug1: 'Alprazolam',
      drug2: 'Opioidler',
      severity: 'Ciddi',
      description:
          'SSS depresyonu riski artar. Solunum depresyonu ve asiri sedasyon olusabilir. Birlikte kullanim kacinilmalidir.',
      severityColor: Color(0xFFDC2626),
    ),
    _InteractionData(
      drug1: 'Lithium',
      drug2: 'NSAID Grubu',
      severity: 'Orta',
      description:
          'NSAID ilaclar lityum klerensini azaltarak serum duzeyini yukseltebilir. Lityum duzeyi yakından izlenmeli.',
      severityColor: Color(0xFFF59E0B),
    ),
    _InteractionData(
      drug1: 'Fluoksetin',
      drug2: 'Tramadol',
      severity: 'Orta',
      description:
          'Serotonin sendromu ve nobetler gelisebilir. Birlikte kullanimda dikkatli olunmali.',
      severityColor: Color(0xFFF59E0B),
    ),
    _InteractionData(
      drug1: 'Ketiapin',
      drug2: 'Ketokonazol',
      severity: 'Hafif',
      description:
          'CYP3A4 inhibisyonu ile ketiapin duzeylerinde artis olabilir. Doz ayarlamasi gerekebilir.',
      severityColor: Color(0xFF2563EB),
    ),
  ];

  final List<_GuidelineData> _guidelines = const [
    _GuidelineData(
      title: 'Antidepresan Baslangiç Protokolu',
      subtitle: 'Ilk recete ve dozaj yonetimi',
      icon: Icons.playlist_add_check_outlined,
      items: [
        'Dusuk dozla baslanmali, yavas titre edilmeli',
        'Tam terapotik etki 4-6 haftada beklenir',
        'Ilk 2 haftada intihar riski artisina dikkat',
        'Hasta ve yakinlari yan etkiler hakkinda bilgilendirilmeli',
        'Tedavi suresi: ilk atak icin en az 6-9 ay',
      ],
    ),
    _GuidelineData(
      title: 'Benzodiazepin Kullanim Kurallari',
      subtitle: 'Guvenli recete ilkeleri',
      icon: Icons.warning_amber_outlined,
      items: [
        'Kisa sureli kullanim onerilir (2-4 hafta)',
        'Tolerans ve bagimlilik riski hasta ile paylasilmali',
        'Ani kesilme nobete yol acabilir; yavas azaltilmali',
        'Yasli hastalarda dusuk doz tercih edilmeli',
        'Alkol ve opioid birlikte kullanimdan kacinilmali',
      ],
    ),
    _GuidelineData(
      title: 'Lityum Izlem Rehberi',
      subtitle: 'Laboratuvar takibi ve guvenlik',
      icon: Icons.science_outlined,
      items: [
        'Hedef serum duzeyi: 0.6-1.2 mEq/L',
        'Baslangiçta haftalik, sonra aylik kan duzeyi takibi',
        'Tiroid fonksiyon testleri 6 ayda bir kontrol',
        'Borek fonksiyon testleri duzenli izlenmeli',
        'Dehidratasyon ve tuz kisitlamasindan kacinilmali',
      ],
    ),
    _GuidelineData(
      title: 'Antipsikotik Metabolik Takip',
      subtitle: 'Metabolik sendrom taramasi',
      icon: Icons.monitor_heart_outlined,
      items: [
        'Baslangicta vucut agirligi, bel cevresi, AKS olcumu',
        'Lipid profili ve HbA1c baslangicta ve 3 ayda bir',
        'Kilo degisimi her vizitte degerlendirilmeli',
        'Prolaktin duzeyi semptom varliginda kontrol',
        'EKG, QTc uzamasi riski olan ilaclarda zorunlu',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupShortcuts();
  }

  void _setupShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyF),
      () => _focusSearch(),
    );
  }

  void _focusSearch() {
    // placeholder for Ctrl+F focus
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_MedicationData> get _filteredMedications {
    if (_searchQuery.isEmpty) return _medications;
    final q = _searchQuery.toLowerCase();
    return _medications.where((m) {
      return m.name.toLowerCase().contains(q) ||
          m.activeIngredient.toLowerCase().contains(q) ||
          m.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Ilac Rehberi',
      actions: [
        IconButton(
          icon: const Icon(Icons.print_outlined, size: 20),
          tooltip: 'Yazdir',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.file_download_outlined, size: 20),
          tooltip: 'Disari Aktar',
          onPressed: () {},
        ),
      ],
      child: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicationSearchTab(),
                _buildCategoriesTab(),
                _buildInteractionsTab(),
                _buildGuidelinesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search Bar
  // ---------------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Ilac adi, etken madde veya kategori ara...',
          hintStyle: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab Bar
  // ---------------------------------------------------------------------------
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.search, size: 18),
            text: 'Ilac Arama',
          ),
          Tab(
            icon: Icon(Icons.category_outlined, size: 18),
            text: 'Kategoriler',
          ),
          Tab(
            icon: Icon(Icons.compare_arrows, size: 18),
            text: 'Etkilesimler',
          ),
          Tab(
            icon: Icon(Icons.menu_book_outlined, size: 18),
            text: 'Rehber',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1 : Ilac Arama
  // ---------------------------------------------------------------------------
  Widget _buildMedicationSearchTab() {
    final meds = _filteredMedications;
    if (meds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Aramanizla eslesen ilac bulunamadi.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: meds.length,
      itemBuilder: (context, index) => _buildMedicationCard(meds[index]),
    );
  }

  Widget _buildMedicationCard(_MedicationData med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_kCardRadius),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color indicator
                Container(
                  width: 4,
                  height: 72,
                  decoration: BoxDecoration(
                    color: med.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: med.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.medication_outlined,
                      color: med.color, size: 24),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Etken Madde', med.activeIngredient),
                      const SizedBox(height: 4),
                      _buildInfoRow('Form', med.form),
                      const SizedBox(height: 4),
                      _buildInfoRow('Doz', med.dose),
                    ],
                  ),
                ),
                // Category badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: med.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: med.color.withOpacity(0.2)),
                  ),
                  child: Text(
                    med.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: med.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2 : Kategoriler
  // ---------------------------------------------------------------------------
  Widget _buildCategoriesTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 560
                ? 2
                : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.65,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) =>
              _buildCategoryCard(_categories[index]),
        );
      },
    );
  }

  Widget _buildCategoryCard(_CategoryData cat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_kCardRadius),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 22),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${cat.count} ilac',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cat.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  cat.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    cat.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
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
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3 : Etkilesimler
  // ---------------------------------------------------------------------------
  Widget _buildInteractionsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Severity legend
        Container(
          margin: const EdgeInsets.only(bottom: _kSectionSpacing),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 12),
              const Text(
                'Siddet Dereceleri:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 16),
              _buildSeverityBadge('Ciddi', const Color(0xFFDC2626)),
              const SizedBox(width: 10),
              _buildSeverityBadge('Orta', const Color(0xFFF59E0B)),
              const SizedBox(width: 10),
              _buildSeverityBadge('Hafif', const Color(0xFF2563EB)),
            ],
          ),
        ),
        ..._interactions.map(_buildInteractionCard),
      ],
    );
  }

  Widget _buildSeverityBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInteractionCard(_InteractionData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: item.severityColor.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(_kCardRadius),
              ),
              border: Border(
                bottom: BorderSide(
                  color: item.severityColor.withOpacity(0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.medication_outlined,
                    size: 18, color: item.severityColor),
                const SizedBox(width: 8),
                Text(
                  item.drug1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.compare_arrows,
                      size: 18, color: item.severityColor),
                ),
                Text(
                  item.drug2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                _buildSeverityBadge(item.severity, item.severityColor),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_outlined,
                    size: 18, color: item.severityColor.withOpacity(0.7)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4 : Rehber
  // ---------------------------------------------------------------------------
  Widget _buildGuidelinesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _guidelines.length,
      itemBuilder: (context, index) =>
          _buildGuidelineCard(_guidelines[index]),
    );
  }

  Widget _buildGuidelineCard(_GuidelineData guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(_kCardRadius),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(guide.icon, color: AppTheme.primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        guide.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: guide.items
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4B5563),
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Data Models
// =============================================================================

class _MedicationData {
  final String name;
  final String activeIngredient;
  final String form;
  final String dose;
  final String category;
  final Color color;

  const _MedicationData({
    required this.name,
    required this.activeIngredient,
    required this.form,
    required this.dose,
    required this.category,
    required this.color,
  });
}

class _CategoryData {
  final String name;
  final IconData icon;
  final int count;
  final Color color;
  final String description;

  const _CategoryData({
    required this.name,
    required this.icon,
    required this.count,
    required this.color,
    required this.description,
  });
}

class _InteractionData {
  final String drug1;
  final String drug2;
  final String severity;
  final String description;
  final Color severityColor;

  const _InteractionData({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
    required this.severityColor,
  });
}

class _GuidelineData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> items;

  const _GuidelineData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });
}
