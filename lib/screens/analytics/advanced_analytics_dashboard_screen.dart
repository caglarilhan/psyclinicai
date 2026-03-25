import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../services/keyboard_shortcuts_service.dart';

class AdvancedAnalyticsDashboardScreen extends StatefulWidget {
  const AdvancedAnalyticsDashboardScreen({super.key});

  @override
  State<AdvancedAnalyticsDashboardScreen> createState() =>
      _AdvancedAnalyticsDashboardScreenState();
}

class _AdvancedAnalyticsDashboardScreenState
    extends State<AdvancedAnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late TabController _tabController;
  String _selectedPeriod = 'Son 30 Gun';
  final List<String> _periods = [
    'Son 7 Gun',
    'Son 30 Gun',
    'Son 3 Ay',
    'Son 1 Yil',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _setupShortcuts();
  }

  void _setupShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.f5),
      _refreshData,
    );
  }

  void _refreshData() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Gelismis Analitik Dashboard',
      actions: [
        _buildPeriodSelector(),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Verileri Yenile (F5)',
          onPressed: _refreshData,
        ),
        IconButton(
          icon: const Icon(Icons.file_download_outlined),
          tooltip: 'Rapor Indir',
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPatientAnalyticsTab(),
                _buildPerformanceTab(),
                _buildPredictiveTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Period selector
  // ---------------------------------------------------------------

  Widget _buildPeriodSelector() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
          items: _periods.map((p) {
            return DropdownMenuItem(value: p, child: Text(p));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedPeriod = val);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tab bar
  // ---------------------------------------------------------------

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
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Genel Bakis'),
          Tab(text: 'Hasta Analitikleri'),
          Tab(text: 'Performans'),
          Tab(text: 'Tahminsel Analiz'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // TAB 1 - Genel Bakis
  // ---------------------------------------------------------------

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiRow(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildChartCard('Aylik Seans Trendi', 'Cizgi grafik - Son 12 ay seans sayilari', 320)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildChartCard('Tani Dagilimi', 'Pasta grafik - Anksiyete %32, Depresyon %28, OKB %15, TSSB %12, Diger %13', 320)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildChartCard('Haftalik Yogunluk', 'Bar grafik - Pzt: 12, Sal: 15, Car: 18, Per: 14, Cum: 16, Cts: 8, Paz: 3', 260)),
              const SizedBox(width: 16),
              Expanded(child: _buildChartCard('Gelir Analizi', 'Alan grafik - Ocak: 45.200 TL, Sub: 48.700 TL, Mar: 52.300 TL, Nis: 49.800 TL, May: 55.100 TL', 260)),
            ],
          ),
          const SizedBox(height: 24),
          _buildRecentSessionsTable(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // KPI Cards
  // ---------------------------------------------------------------

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            'Toplam Hasta',
            '247',
            '+12',
            '%5.1 artis',
            Icons.people_outline,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'Aylik Seans',
            '186',
            '+23',
            '%14.1 artis',
            Icons.calendar_today_outlined,
            AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'Basari Orani',
            '%78.4',
            '+2.3',
            'Onceki aya gore',
            Icons.trending_up,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            'Gelir',
            '52.300 TL',
            '+7.200 TL',
            '%16 artis',
            Icons.account_balance_wallet_outlined,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String change,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final bool isPositive = change.startsWith('+');
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Chart placeholder card
  // ---------------------------------------------------------------

  Widget _buildChartCard(String title, String description, double height) {
    return Container(
      height: height,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 48,
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
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

  // ---------------------------------------------------------------
  // Recent sessions table
  // ---------------------------------------------------------------

  Widget _buildRecentSessionsTable() {
    return _buildTableCard(
      title: 'Son Seanslar',
      columns: const ['Hasta', 'Tarih', 'Tur', 'Sure', 'Durum'],
      rows: const [
        ['Ayse Yilmaz', '24.03.2026', 'BDT', '50 dk', 'Tamamlandi'],
        ['Mehmet Kaya', '24.03.2026', 'EMDR', '60 dk', 'Tamamlandi'],
        ['Fatma Demir', '23.03.2026', 'Bireysel', '45 dk', 'Tamamlandi'],
        ['Ali Ozturk', '23.03.2026', 'Aile', '90 dk', 'Tamamlandi'],
        ['Zeynep Arslan', '22.03.2026', 'BDT', '50 dk', 'Iptal Edildi'],
        ['Can Sahin', '22.03.2026', 'Bireysel', '50 dk', 'Tamamlandi'],
        ['Elif Celik', '21.03.2026', 'Grup', '120 dk', 'Tamamlandi'],
      ],
    );
  }

  // ---------------------------------------------------------------
  // TAB 2 - Hasta Analitikleri
  // ---------------------------------------------------------------

  Widget _buildPatientAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Hasta Demografisi'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartCard(
                  'Yas Dagilimi',
                  'Bar grafik - 18-25: %22, 26-35: %34, 36-45: %24, 46-55: %14, 55+: %6',
                  280,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Cinsiyet Dagilimi',
                  'Halka grafik - Kadin: %58 (143), Erkek: %39 (96), Diger: %3 (8)',
                  280,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Basvuru Kanali',
                  'Pasta grafik - Tavsiye: %42, Internet: %28, Sosyal Medya: %18, Diger: %12',
                  280,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Tedavi Sureleri ve Sonuclari'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildChartCard(
                  'Ortalama Tedavi Suresi (Hafta)',
                  'Yatay bar - Anksiyete: 14 hafta, Depresyon: 18 hafta, OKB: 22 hafta, TSSB: 24 hafta, Uyum Bozuklugu: 10 hafta',
                  300,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildStatisticsCard(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPatientRetentionTable(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      height: 300,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temel Istatistikler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const Divider(height: 24),
          _buildStatRow('Ortalama seans sayisi', '12.4 seans'),
          _buildStatRow('Medyan tedavi suresi', '16 hafta'),
          _buildStatRow('Tedavi tamamlama', '%68.2'),
          _buildStatRow('Erken birakma', '%18.5'),
          _buildStatRow('Tekrar basvuru', '%13.3'),
          _buildStatRow('Ortalama memnuniyet', '4.6 / 5.0'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientRetentionTable() {
    return _buildTableCard(
      title: 'Hasta Tutma Oranlari (Kohort Analizi)',
      columns: const ['Kohort', 'Baslangic', '1. Ay', '3. Ay', '6. Ay', '12. Ay'],
      rows: const [
        ['2025 Q1', '62', '%92', '%78', '%65', '%52'],
        ['2025 Q2', '58', '%90', '%76', '%62', '%48'],
        ['2025 Q3', '71', '%94', '%82', '%70', '%55'],
        ['2025 Q4', '65', '%91', '%80', '%68', '-'],
        ['2026 Q1', '54', '%93', '%81', '-', '-'],
      ],
    );
  }

  // ---------------------------------------------------------------
  // TAB 3 - Performans
  // ---------------------------------------------------------------

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Terapist Performansi'),
          const SizedBox(height: 16),
          _buildTherapistPerformanceTable(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartCard(
                  'Seans Doluluk Orani',
                  'Cizgi grafik - Oca: %82, Sub: %85, Mar: %88, Nis: %84, May: %90, Haz: %87, Tem: %72, Agu: %68, Eyl: %86, Eki: %89, Kas: %91, Ara: %78',
                  280,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Iptal ve Erteleme Oranlari',
                  'Gruplanmis bar - Iptal: %8.2, Erteleme: %12.5, Gelmeme: %3.8',
                  280,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartCard(
                  'Gelir / Gider Karsilastirmasi',
                  'Cift eksenli grafik - Gelir: 52.300 TL, Gider: 31.400 TL, Net Kar: 20.900 TL, Kar Marji: %40',
                  280,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Seans Basi Ortalama Gelir',
                  'Cizgi grafik - BDT: 850 TL, EMDR: 1.200 TL, Bireysel: 750 TL, Aile: 1.400 TL, Grup: 450 TL/kisi',
                  280,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFinancialSummaryTable(),
        ],
      ),
    );
  }

  Widget _buildTherapistPerformanceTable() {
    return _buildTableCard(
      title: 'Terapist Bazli Performans',
      columns: const [
        'Terapist',
        'Hasta Sayisi',
        'Aylik Seans',
        'Basari Orani',
        'Memnuniyet',
        'Doluluk',
      ],
      rows: const [
        ['Dr. Selin Karaca', '48', '42', '%82.1', '4.8', '%92'],
        ['Dr. Emre Yildiz', '52', '46', '%76.3', '4.5', '%88'],
        ['Dr. Nur Aksoy', '38', '34', '%80.5', '4.7', '%85'],
        ['Dr. Burak Cetin', '44', '38', '%74.8', '4.4', '%90'],
        ['Dr. Deniz Koc', '35', '30', '%79.2', '4.6', '%82'],
        ['Dr. Gizem Polat', '30', '26', '%81.7', '4.9', '%78'],
      ],
    );
  }

  Widget _buildFinancialSummaryTable() {
    return _buildTableCard(
      title: 'Aylik Finansal Ozet',
      columns: const ['Ay', 'Gelir', 'Gider', 'Net Kar', 'Seans Sayisi', 'Ort. Gelir/Seans'],
      rows: const [
        ['Mart 2026', '52.300 TL', '31.400 TL', '20.900 TL', '186', '281 TL'],
        ['Subat 2026', '48.700 TL', '29.800 TL', '18.900 TL', '172', '283 TL'],
        ['Ocak 2026', '45.200 TL', '28.500 TL', '16.700 TL', '158', '286 TL'],
        ['Aralik 2025', '41.800 TL', '27.200 TL', '14.600 TL', '148', '282 TL'],
        ['Kasim 2025', '47.500 TL', '30.100 TL', '17.400 TL', '168', '283 TL'],
      ],
    );
  }

  // ---------------------------------------------------------------
  // TAB 4 - Tahminsel Analiz
  // ---------------------------------------------------------------

  Widget _buildPredictiveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tahminsel Modeller'),
          const SizedBox(height: 16),
          _buildPredictiveAlertCards(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartCard(
                  'Hasta Kaybi Riski Tahmini',
                  'Isil harita - Dusuk risk: 168 hasta (%68), Orta risk: 52 hasta (%21), Yuksek risk: 27 hasta (%11)',
                  300,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Gelir Projeksiyonu (6 Ay)',
                  'Cizgi grafik - Nis: 54.800 TL, May: 57.200 TL, Haz: 55.900 TL, Tem: 48.300 TL, Agu: 42.100 TL, Eyl: 56.700 TL',
                  300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartCard(
                  'Tedavi Basari Tahmin Modeli',
                  'Dagilim grafik - Model dogruluk: %84.2, AUC-ROC: 0.87, Precision: %81, Recall: %79',
                  280,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Mevsimsel Talep Tahmini',
                  'Alan grafik - Bahar: yuksek talep, Yaz: dusuk talep, Sonbahar: yuksek talep, Kis: orta talep',
                  280,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildRiskPatientsTable(),
        ],
      ),
    );
  }

  Widget _buildPredictiveAlertCards() {
    return Row(
      children: [
        Expanded(
          child: _buildAlertCard(
            'Yuksek Risk',
            '27 hasta tedaviyi birakma riski tasimaktadir',
            Icons.warning_amber_rounded,
            const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAlertCard(
            'Kapasite Tahmini',
            'Nisan ayi icin %94 doluluk beklenmektedir',
            Icons.event_available,
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAlertCard(
            'Olumlu Trend',
            'Tedavi basari orani son 3 ayda %6.2 artmistir',
            Icons.trending_up,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskPatientsTable() {
    return _buildTableCard(
      title: 'Yuksek Riskli Hastalar',
      columns: const [
        'Hasta',
        'Tani',
        'Son Seans',
        'Devamsizlik',
        'Risk Skoru',
        'Onerilen Aksiyon',
      ],
      rows: const [
        ['Zeynep Arslan', 'Depresyon', '15.03.2026', '3 seans', '%87', 'Acil gorusme planla'],
        ['Kemal Tas', 'Anksiyete', '10.03.2026', '2 seans', '%74', 'Telefon gorusmesi'],
        ['Seda Bayrak', 'TSSB', '08.03.2026', '4 seans', '%92', 'Acil gorusme planla'],
        ['Omer Gul', 'OKB', '18.03.2026', '2 seans', '%68', 'Hatirlatma gonder'],
        ['Hale Kilic', 'Depresyon', '12.03.2026', '3 seans', '%81', 'Telefon gorusmesi'],
      ],
    );
  }

  // ---------------------------------------------------------------
  // Shared widgets
  // ---------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildTableCard({
    required String title,
    required List<String> columns,
    required List<List<String>> rows,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text('Disari Aktar', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
              headingTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              dataTextStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
              columnSpacing: 32,
              horizontalMargin: 20,
              columns: columns
                  .map((c) => DataColumn(label: Text(c)))
                  .toList(),
              rows: rows.map((row) {
                return DataRow(
                  cells: row.map((cell) {
                    final isStatus = cell == 'Tamamlandi' ||
                        cell == 'Iptal Edildi' ||
                        cell.contains('%') && !cell.contains('TL');
                    if (cell == 'Tamamlandi') {
                      return DataCell(_buildStatusBadge(cell, const Color(0xFF10B981)));
                    } else if (cell == 'Iptal Edildi') {
                      return DataCell(_buildStatusBadge(cell, const Color(0xFFEF4444)));
                    } else if (cell == 'Acil gorusme planla') {
                      return DataCell(_buildStatusBadge(cell, const Color(0xFFEF4444)));
                    } else if (cell == 'Telefon gorusmesi') {
                      return DataCell(_buildStatusBadge(cell, const Color(0xFFF59E0B)));
                    } else if (cell == 'Hatirlatma gonder') {
                      return DataCell(_buildStatusBadge(cell, AppTheme.primaryColor));
                    }
                    return DataCell(Text(cell));
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
