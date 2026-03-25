import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

// ---------------------------------------------------------------------------
// Mock veri modelleri
// ---------------------------------------------------------------------------

enum CasePriority { yuksek, orta, dusuk }

enum CaseStatus { aktif, tamamlanan, arsiv }

class CaseRecord {
  final String id;
  final String patientName;
  final String diagnosis;
  final String therapist;
  final String startDate;
  final int sessionCount;
  final CasePriority priority;
  final CaseStatus status;
  final String? endDate;
  final String? outcome;

  const CaseRecord({
    required this.id,
    required this.patientName,
    required this.diagnosis,
    required this.therapist,
    required this.startDate,
    required this.sessionCount,
    required this.priority,
    required this.status,
    this.endDate,
    this.outcome,
  });
}

// ---------------------------------------------------------------------------
// Mock veriler
// ---------------------------------------------------------------------------

final List<CaseRecord> _mockCases = [
  // Aktif vakalar
  const CaseRecord(
    id: 'VK-2024-001',
    patientName: 'Elif Yilmaz',
    diagnosis: 'Yaygin Anksiyete Bozuklugu',
    therapist: 'Dr. Ahmet Kaya',
    startDate: '12.01.2026',
    sessionCount: 8,
    priority: CasePriority.yuksek,
    status: CaseStatus.aktif,
  ),
  const CaseRecord(
    id: 'VK-2024-002',
    patientName: 'Mehmet Demir',
    diagnosis: 'Major Depresif Bozukluk',
    therapist: 'Dr. Ayse Celik',
    startDate: '03.02.2026',
    sessionCount: 5,
    priority: CasePriority.yuksek,
    status: CaseStatus.aktif,
  ),
  const CaseRecord(
    id: 'VK-2024-003',
    patientName: 'Zeynep Arslan',
    diagnosis: 'Sosyal Anksiyete Bozuklugu',
    therapist: 'Dr. Ahmet Kaya',
    startDate: '15.02.2026',
    sessionCount: 4,
    priority: CasePriority.orta,
    status: CaseStatus.aktif,
  ),
  const CaseRecord(
    id: 'VK-2024-004',
    patientName: 'Ali Ozturk',
    diagnosis: 'Obsesif Kompulsif Bozukluk',
    therapist: 'Dr. Fatma Sahin',
    startDate: '20.01.2026',
    sessionCount: 7,
    priority: CasePriority.orta,
    status: CaseStatus.aktif,
  ),
  const CaseRecord(
    id: 'VK-2024-005',
    patientName: 'Fatma Korkmaz',
    diagnosis: 'Panik Bozukluk',
    therapist: 'Dr. Ayse Celik',
    startDate: '01.03.2026',
    sessionCount: 3,
    priority: CasePriority.dusuk,
    status: CaseStatus.aktif,
  ),
  const CaseRecord(
    id: 'VK-2024-006',
    patientName: 'Hasan Cetin',
    diagnosis: 'Travma Sonrasi Stres Bozuklugu',
    therapist: 'Dr. Ahmet Kaya',
    startDate: '10.12.2025',
    sessionCount: 14,
    priority: CasePriority.yuksek,
    status: CaseStatus.aktif,
  ),
  const CaseRecord(
    id: 'VK-2024-007',
    patientName: 'Ayse Dogan',
    diagnosis: 'Bipolar Bozukluk Tip II',
    therapist: 'Dr. Fatma Sahin',
    startDate: '25.02.2026',
    sessionCount: 3,
    priority: CasePriority.orta,
    status: CaseStatus.aktif,
  ),
  // Tamamlanan vakalar
  const CaseRecord(
    id: 'VK-2023-042',
    patientName: 'Mustafa Yildiz',
    diagnosis: 'Yaygin Anksiyete Bozuklugu',
    therapist: 'Dr. Ahmet Kaya',
    startDate: '05.03.2025',
    sessionCount: 16,
    priority: CasePriority.orta,
    status: CaseStatus.tamamlanan,
    endDate: '18.09.2025',
    outcome: 'Basarili - Belirtilerde belirgin azalma',
  ),
  const CaseRecord(
    id: 'VK-2023-051',
    patientName: 'Seda Aydin',
    diagnosis: 'Major Depresif Bozukluk',
    therapist: 'Dr. Ayse Celik',
    startDate: '12.05.2025',
    sessionCount: 12,
    priority: CasePriority.yuksek,
    status: CaseStatus.tamamlanan,
    endDate: '20.11.2025',
    outcome: 'Basarili - Tam remisyon',
  ),
  const CaseRecord(
    id: 'VK-2023-063',
    patientName: 'Emre Koc',
    diagnosis: 'Sosyal Anksiyete Bozuklugu',
    therapist: 'Dr. Fatma Sahin',
    startDate: '01.07.2025',
    sessionCount: 10,
    priority: CasePriority.orta,
    status: CaseStatus.tamamlanan,
    endDate: '15.12.2025',
    outcome: 'Kismi iyilesme - Takip onerisi',
  ),
  const CaseRecord(
    id: 'VK-2023-078',
    patientName: 'Derya Polat',
    diagnosis: 'Panik Bozukluk',
    therapist: 'Dr. Ahmet Kaya',
    startDate: '20.08.2025',
    sessionCount: 8,
    priority: CasePriority.dusuk,
    status: CaseStatus.tamamlanan,
    endDate: '10.01.2026',
    outcome: 'Basarili - Belirtiler kontrol altinda',
  ),
  // Arsiv vakalari
  const CaseRecord(
    id: 'VK-2022-015',
    patientName: 'Burak Erdogan',
    diagnosis: 'Obsesif Kompulsif Bozukluk',
    therapist: 'Dr. Ayse Celik',
    startDate: '10.01.2024',
    sessionCount: 24,
    priority: CasePriority.yuksek,
    status: CaseStatus.arsiv,
    endDate: '30.08.2024',
    outcome: 'Basarili - Uzun sureli takip tamamlandi',
  ),
  const CaseRecord(
    id: 'VK-2022-023',
    patientName: 'Gizem Sahin',
    diagnosis: 'Major Depresif Bozukluk',
    therapist: 'Dr. Fatma Sahin',
    startDate: '15.03.2024',
    sessionCount: 18,
    priority: CasePriority.orta,
    status: CaseStatus.arsiv,
    endDate: '20.10.2024',
    outcome: 'Basarili - Ilac tedavisi ile birlesirildi',
  ),
  const CaseRecord(
    id: 'VK-2022-031',
    patientName: 'Cem Aksoy',
    diagnosis: 'Travma Sonrasi Stres Bozuklugu',
    therapist: 'Dr. Ahmet Kaya',
    startDate: '05.06.2024',
    sessionCount: 20,
    priority: CasePriority.yuksek,
    status: CaseStatus.arsiv,
    endDate: '15.01.2025',
    outcome: 'Kismi iyilesme - Baska merkeze sevk',
  ),
];

// ---------------------------------------------------------------------------
// Ana ekran
// ---------------------------------------------------------------------------

class CaseManagementScreen extends StatefulWidget {
  const CaseManagementScreen({super.key});

  @override
  State<CaseManagementScreen> createState() => _CaseManagementScreenState();
}

class _CaseManagementScreenState extends State<CaseManagementScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late final TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () {
        // Yeni vaka
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      () {
        // Vaka ara
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
  }

  // -- Yardimci getter'lar --------------------------------------------------

  List<CaseRecord> get _activeCases =>
      _mockCases.where((c) => c.status == CaseStatus.aktif).toList();

  List<CaseRecord> get _completedCases =>
      _mockCases.where((c) => c.status == CaseStatus.tamamlanan).toList();

  List<CaseRecord> get _archivedCases =>
      _mockCases.where((c) => c.status == CaseStatus.arsiv).toList();

  List<CaseRecord> _filterCases(List<CaseRecord> cases) {
    if (_searchQuery.isEmpty) return cases;
    final q = _searchQuery.toLowerCase();
    return cases.where((c) {
      return c.patientName.toLowerCase().contains(q) ||
          c.diagnosis.toLowerCase().contains(q) ||
          c.therapist.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q);
    }).toList();
  }

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Vaka Yonetimi',
      child: Column(
        children: [
          _buildKpiRow(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add),
          tooltip: 'Yeni Vaka (Ctrl+N)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
          tooltip: 'Ara (Ctrl+S)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
          tooltip: 'Ayarlar',
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Yeni Vaka',
          icon: Icons.add,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Aktif Vakalar',
          icon: Icons.folder_open,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Tamamlanan Vakalar',
          icon: Icons.folder,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Arsiv',
          icon: Icons.archive,
          onTap: () => _tabController.animateTo(2),
        ),
      ],
    );
  }

  // -- KPI satirlari ---------------------------------------------------------

  Widget _buildKpiRow() {
    return Row(
      children: [
        _buildKpiCard('Aktif Vaka', '23', Icons.folder_open,
            AppTheme.primaryColor),
        const SizedBox(width: 12),
        _buildKpiCard('Tamamlanan', '156', Icons.check_circle,
            AppTheme.successColor),
        const SizedBox(width: 12),
        _buildKpiCard('Ortalama Sure', '12 Seans', Icons.timer,
            AppTheme.accentColor),
        const SizedBox(width: 12),
        _buildKpiCard('Basari Orani', '%78', Icons.trending_up,
            AppTheme.warningColor),
      ],
    );
  }

  Widget _buildKpiCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Arama cubugu -----------------------------------------------------------

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: const InputDecoration(
          hintText: 'Vaka ara (hasta adi, tani, terapist veya vaka no)...',
          hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // -- Tab bar ----------------------------------------------------------------

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: AppTheme.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        tabs: [
          Tab(text: 'Aktif Vakalar (${_activeCases.length})'),
          Tab(text: 'Tamamlanan (${_completedCases.length})'),
          Tab(text: 'Arsiv (${_archivedCases.length})'),
          const Tab(text: 'Istatistikler'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildActiveCasesTab(),
        _buildCompletedCasesTab(),
        _buildArchiveTab(),
        _buildStatisticsTab(),
      ],
    );
  }

  // -- Aktif Vakalar ----------------------------------------------------------

  Widget _buildActiveCasesTab() {
    final cases = _filterCases(_activeCases);
    if (cases.isEmpty) return _buildEmptyState('Aktif vaka bulunamadi.');
    return _buildCaseTable(
      cases: cases,
      columns: const [
        'Vaka No',
        'Hasta',
        'Tani',
        'Terapist',
        'Baslangic',
        'Seans',
        'Oncelik',
      ],
      rowBuilder: (c) => [
        _cellText(c.id),
        _cellBoldText(c.patientName),
        _cellText(c.diagnosis),
        _cellText(c.therapist),
        _cellText(c.startDate),
        _cellText('${c.sessionCount}'),
        _priorityBadge(c.priority),
      ],
    );
  }

  // -- Tamamlanan -------------------------------------------------------------

  Widget _buildCompletedCasesTab() {
    final cases = _filterCases(_completedCases);
    if (cases.isEmpty) return _buildEmptyState('Tamamlanan vaka bulunamadi.');
    return _buildCaseTable(
      cases: cases,
      columns: const [
        'Vaka No',
        'Hasta',
        'Tani',
        'Terapist',
        'Baslangic',
        'Bitis',
        'Seans',
        'Sonuc',
      ],
      rowBuilder: (c) => [
        _cellText(c.id),
        _cellBoldText(c.patientName),
        _cellText(c.diagnosis),
        _cellText(c.therapist),
        _cellText(c.startDate),
        _cellText(c.endDate ?? '-'),
        _cellText('${c.sessionCount}'),
        _outcomeBadge(c.outcome ?? ''),
      ],
    );
  }

  // -- Arsiv ------------------------------------------------------------------

  Widget _buildArchiveTab() {
    final cases = _filterCases(_archivedCases);
    if (cases.isEmpty) return _buildEmptyState('Arsivde vaka bulunamadi.');
    return _buildCaseTable(
      cases: cases,
      columns: const [
        'Vaka No',
        'Hasta',
        'Tani',
        'Terapist',
        'Baslangic',
        'Bitis',
        'Seans',
        'Sonuc',
      ],
      rowBuilder: (c) => [
        _cellText(c.id),
        _cellBoldText(c.patientName),
        _cellText(c.diagnosis),
        _cellText(c.therapist),
        _cellText(c.startDate),
        _cellText(c.endDate ?? '-'),
        _cellText('${c.sessionCount}'),
        _outcomeBadge(c.outcome ?? ''),
      ],
    );
  }

  // -- Istatistikler ----------------------------------------------------------

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Row(
            children: [
              _statCard('Toplam Vaka',
                  '${_mockCases.length}', Icons.folder, AppTheme.primaryColor),
              const SizedBox(width: 12),
              _statCard('Aktif', '${_activeCases.length}',
                  Icons.folder_open, AppTheme.accentColor),
              const SizedBox(width: 12),
              _statCard('Tamamlanan', '${_completedCases.length}',
                  Icons.check_circle, AppTheme.successColor),
              const SizedBox(width: 12),
              _statCard('Arsivlenen', '${_archivedCases.length}',
                  Icons.archive, const Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 24),
          _buildStatSection('Tanilara Gore Dagilim', [
            _statRow('Yaygin Anksiyete Bozuklugu', 4),
            _statRow('Major Depresif Bozukluk', 4),
            _statRow('Sosyal Anksiyete Bozuklugu', 2),
            _statRow('Obsesif Kompulsif Bozukluk', 2),
            _statRow('Panik Bozukluk', 2),
            _statRow('Travma Sonrasi Stres Bozuklugu', 2),
            _statRow('Bipolar Bozukluk Tip II', 1),
          ]),
          const SizedBox(height: 16),
          _buildStatSection('Terapiste Gore Dagilim', [
            _statRow('Dr. Ahmet Kaya', 6),
            _statRow('Dr. Ayse Celik', 4),
            _statRow('Dr. Fatma Sahin', 4),
          ]),
          const SizedBox(height: 16),
          _buildStatSection('Oncelik Dagilimi', [
            _statRow('Yuksek', 5),
            _statRow('Orta', 6),
            _statRow('Dusuk', 3),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _statRow(String label, int count) {
    final maxCount = 6;
    final ratio = count / maxCount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: Text(
              label,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF334155)),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Ortak widget'lar -------------------------------------------------------

  Widget _buildCaseTable({
    required List<CaseRecord> cases,
    required List<String> columns,
    required List<Widget> Function(CaseRecord) rowBuilder,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Baslik satiri
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: columns
                  .map((col) => Expanded(
                        child: Text(
                          col,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          // Veri satirlari
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: cases.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = cases[index];
                final cells = rowBuilder(c);
                return InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: cells
                          .map((w) => Expanded(child: w))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _cellBoldText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _priorityBadge(CasePriority priority) {
    late final String label;
    late final Color color;
    switch (priority) {
      case CasePriority.yuksek:
        label = 'Yuksek';
        color = const Color(0xFFEF4444);
        break;
      case CasePriority.orta:
        label = 'Orta';
        color = const Color(0xFFF59E0B);
        break;
      case CasePriority.dusuk:
        label = 'Dusuk';
        color = const Color(0xFF10B981);
        break;
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
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
      ),
    );
  }

  Widget _outcomeBadge(String outcome) {
    final isSuccess = outcome.toLowerCase().contains('basarili');
    final color =
        isSuccess ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          outcome,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text(
            message,
            style:
                const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
