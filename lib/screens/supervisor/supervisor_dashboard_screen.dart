import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late final TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
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
        _showNewSupervisionDialog();
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      () {
        _tabController.animateTo(3);
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
  }

  void _showNewSupervisionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Supervizyon Seansı'),
        content: const Text(
          'Yeni supervizyon seansı olusturma formu burada yer alacaktır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Olustur'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Supervizor Paneli',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiCards(),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSupervisionSessionsTab(),
                _buildTherapistPerformanceTab(),
                _buildQualityMetricsTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showNewSupervisionDialog,
          icon: const Icon(Icons.add),
          tooltip: 'Yeni Supervizyon (Ctrl+N)',
        ),
        IconButton(
          onPressed: () {
            _tabController.animateTo(3);
          },
          icon: const Icon(Icons.assessment),
          tooltip: 'Raporlar (Ctrl+R)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
          tooltip: 'Ayarlar',
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Supervizyon Seansları',
          icon: Icons.supervisor_account,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Terapist Performansı',
          icon: Icons.analytics,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Kalite Metrikleri',
          icon: Icons.star,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Raporlar',
          icon: Icons.assessment,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // KPI Cards
  // ---------------------------------------------------------------------------

  Widget _buildKpiCards() {
    final kpis = [
      _KpiData(
        title: 'Aktif Terapist',
        value: '12',
        subtitle: 'Toplam kadro',
        icon: Icons.people_alt_outlined,
        color: AppTheme.primaryColor,
      ),
      _KpiData(
        title: 'Haftalık Seans',
        value: '48',
        subtitle: 'Bu hafta',
        icon: Icons.calendar_today_outlined,
        color: AppTheme.successColor,
      ),
      _KpiData(
        title: 'Ortalama Puan',
        value: '4.3/5',
        subtitle: 'Hasta memnuniyeti',
        icon: Icons.star_outline,
        color: AppTheme.accentColor,
      ),
      _KpiData(
        title: 'Bekleyen Degerlendirme',
        value: '7',
        subtitle: 'Inceleme bekliyor',
        icon: Icons.pending_actions_outlined,
        color: AppTheme.warningColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 500
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.4,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _buildKpiCard(kpis[index]),
        );
      },
    );
  }

  Widget _buildKpiCard(_KpiData data) {
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: data.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab Bar
  // ---------------------------------------------------------------------------

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
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: AppTheme.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        dividerHeight: 0,
        tabs: const [
          Tab(text: 'Supervizyon Seansları'),
          Tab(text: 'Terapist Performansı'),
          Tab(text: 'Kalite Metrikleri'),
          Tab(text: 'Raporlar'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1 - Supervizyon Seansları
  // ---------------------------------------------------------------------------

  Widget _buildSupervisionSessionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Yaklasan Seanslar',
            Icons.upcoming_outlined,
          ),
          const SizedBox(height: 12),
          ..._upcomingSessions.map(_buildSessionCard),
          const SizedBox(height: 28),
          _buildSectionHeader(
            'Son Tamamlanan Seanslar',
            Icons.history_outlined,
          ),
          const SizedBox(height: 12),
          ..._recentSessions.map(_buildSessionCard),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(_SessionData session) {
    final isUpcoming = session.status == 'Planlandı';
    final statusColor =
        isUpcoming ? AppTheme.warningColor : AppTheme.successColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
            child: Text(
              session.therapistInitials,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.therapistName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.topic,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2 - Terapist Performansı
  // ---------------------------------------------------------------------------

  Widget _buildTherapistPerformanceTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Terapist Degerlendirmeleri',
            Icons.analytics_outlined,
          ),
          const SizedBox(height: 16),
          ..._therapists.map(_buildTherapistRow),
        ],
      ),
    );
  }

  Widget _buildTherapistRow(_TherapistData therapist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
            child: Text(
              therapist.initials,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  therapist.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  therapist.specialty,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          _buildMetricColumn(
            'Seans',
            therapist.sessionCount.toString(),
            null,
          ),
          const SizedBox(width: 28),
          _buildMetricColumn(
            'Memnuniyet',
            therapist.satisfaction.toStringAsFixed(1),
            therapist.satisfaction / 5.0,
          ),
          const SizedBox(width: 28),
          _buildMetricColumn(
            'Tamamlanma',
            '%${therapist.completionRate}',
            therapist.completionRate / 100.0,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, double? progress) {
    Color progressColor;
    if (progress != null) {
      if (progress >= 0.8) {
        progressColor = AppTheme.successColor;
      } else if (progress >= 0.6) {
        progressColor = AppTheme.warningColor;
      } else {
        progressColor = AppTheme.errorColor;
      }
    } else {
      progressColor = AppTheme.primaryColor;
    }

    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: progress != null ? progressColor : const Color(0xFF1F2937),
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3 - Kalite Metrikleri
  // ---------------------------------------------------------------------------

  Widget _buildQualityMetricsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Kalite Gostergeleri',
            Icons.verified_outlined,
          ),
          const SizedBox(height: 16),
          ..._qualityMetrics.map(_buildQualityMetricCard),
        ],
      ),
    );
  }

  Widget _buildQualityMetricCard(_QualityMetric metric) {
    Color barColor;
    if (metric.score >= 80) {
      barColor = AppTheme.successColor;
    } else if (metric.score >= 60) {
      barColor = AppTheme.warningColor;
    } else {
      barColor = AppTheme.errorColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(metric.icon, size: 20, color: barColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  metric.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                '%${metric.score}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            metric.description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: metric.score / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          if (metric.target != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Hedef: %${metric.target}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4 - Raporlar
  // ---------------------------------------------------------------------------

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Ozet Raporlar', Icons.summarize_outlined),
          const SizedBox(height: 16),
          ..._reports.map(_buildReportCard),
        ],
      ),
    );
  }

  Widget _buildReportCard(_ReportData report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: report.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(report.icon, color: report.color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                report.date,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Indir', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  foregroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mock Data
  // ---------------------------------------------------------------------------

  List<_SessionData> get _upcomingSessions => const [
        _SessionData(
          therapistName: 'Dr. Elif Yılmaz',
          therapistInitials: 'EY',
          topic: 'Vaka tartısması - Anksiyete bozuklugu',
          date: '26 Mar 2026, 10:00',
          status: 'Planlandı',
        ),
        _SessionData(
          therapistName: 'Dr. Ahmet Kaya',
          therapistInitials: 'AK',
          topic: 'Bireysel supervizyon - Terapi sureci degerlendirme',
          date: '27 Mar 2026, 14:00',
          status: 'Planlandı',
        ),
        _SessionData(
          therapistName: 'Dr. Selin Demir',
          therapistInitials: 'SD',
          topic: 'Grup supervizyon - Etik vaka incelemesi',
          date: '28 Mar 2026, 11:00',
          status: 'Planlandı',
        ),
      ];

  List<_SessionData> get _recentSessions => const [
        _SessionData(
          therapistName: 'Dr. Mehmet Arslan',
          therapistInitials: 'MA',
          topic: 'Cocuk terapisi vaka incelemesi',
          date: '24 Mar 2026, 09:30',
          status: 'Tamamlandı',
        ),
        _SessionData(
          therapistName: 'Dr. Zeynep Ozturk',
          therapistInitials: 'ZO',
          topic: 'Aile terapisi surec degerlendirme',
          date: '23 Mar 2026, 15:00',
          status: 'Tamamlandı',
        ),
        _SessionData(
          therapistName: 'Dr. Burak Celik',
          therapistInitials: 'BC',
          topic: 'Travma odaklı BDT uygulaması',
          date: '22 Mar 2026, 13:00',
          status: 'Tamamlandı',
        ),
      ];

  List<_TherapistData> get _therapists => const [
        _TherapistData(
          name: 'Dr. Elif Yılmaz',
          initials: 'EY',
          specialty: 'Bilissel Davranıscı Terapi',
          sessionCount: 24,
          satisfaction: 4.7,
          completionRate: 95,
        ),
        _TherapistData(
          name: 'Dr. Ahmet Kaya',
          initials: 'AK',
          specialty: 'Psikodinamik Terapi',
          sessionCount: 18,
          satisfaction: 4.4,
          completionRate: 88,
        ),
        _TherapistData(
          name: 'Dr. Selin Demir',
          initials: 'SD',
          specialty: 'Aile ve Cift Terapisi',
          sessionCount: 21,
          satisfaction: 4.6,
          completionRate: 92,
        ),
        _TherapistData(
          name: 'Dr. Mehmet Arslan',
          initials: 'MA',
          specialty: 'Cocuk ve Ergen Terapisi',
          sessionCount: 16,
          satisfaction: 4.2,
          completionRate: 85,
        ),
        _TherapistData(
          name: 'Dr. Zeynep Ozturk',
          initials: 'ZO',
          specialty: 'EMDR ve Travma Terapisi',
          sessionCount: 20,
          satisfaction: 4.5,
          completionRate: 91,
        ),
        _TherapistData(
          name: 'Dr. Burak Celik',
          initials: 'BC',
          specialty: 'Varoluşcu Terapi',
          sessionCount: 14,
          satisfaction: 4.1,
          completionRate: 82,
        ),
      ];

  List<_QualityMetric> get _qualityMetrics => const [
        _QualityMetric(
          title: 'Seans Tamamlanma Oranı',
          description: 'Planlanan seanslarin tamamlanma yuzdesi',
          score: 91,
          target: 95,
          icon: Icons.check_circle_outline,
        ),
        _QualityMetric(
          title: 'Hasta Memnuniyeti',
          description: 'Hasta geri bildirim anketlerinin ortalama puanı',
          score: 86,
          target: 90,
          icon: Icons.sentiment_satisfied_alt_outlined,
        ),
        _QualityMetric(
          title: 'Dokumantasyon Kalitesi',
          description: 'Seans notlari ve raporlarin eksiksizlik oranı',
          score: 78,
          target: 85,
          icon: Icons.description_outlined,
        ),
        _QualityMetric(
          title: 'Etik Uyumluluk',
          description: 'Mesleki etik standartlara uygunluk degerlendirmesi',
          score: 94,
          target: 95,
          icon: Icons.gavel_outlined,
        ),
        _QualityMetric(
          title: 'Mesleki Gelisim',
          description:
              'Egitim ve supervizyon katılım oranı',
          score: 72,
          target: 80,
          icon: Icons.school_outlined,
        ),
        _QualityMetric(
          title: 'Tedavi Planı Uyumu',
          description: 'Kanıta dayalı tedavi protokollerine uygunluk',
          score: 88,
          target: 90,
          icon: Icons.assignment_turned_in_outlined,
        ),
      ];

  List<_ReportData> get _reports => [
        _ReportData(
          title: 'Aylık Performans Raporu',
          description:
              'Mart 2026 terapist performans ozeti ve degerlendirmeleri',
          date: 'Mart 2026',
          icon: Icons.bar_chart_outlined,
          color: AppTheme.primaryColor,
        ),
        _ReportData(
          title: 'Supervizyon Ozet Raporu',
          description:
              'Son 30 gunluk supervizyon seanslari ve sonuclari',
          date: '25 Mar 2026',
          icon: Icons.supervisor_account_outlined,
          color: AppTheme.accentColor,
        ),
        _ReportData(
          title: 'Kalite Guvence Raporu',
          description: 'Q1 2026 kalite metrikleri ve iyilestirme onerileri',
          date: 'Q1 2026',
          icon: Icons.verified_outlined,
          color: AppTheme.successColor,
        ),
        _ReportData(
          title: 'Hasta Memnuniyeti Analizi',
          description:
              'Hasta geri bildirimleri ve memnuniyet trendi analizi',
          date: 'Mart 2026',
          icon: Icons.sentiment_satisfied_outlined,
          color: AppTheme.warningColor,
        ),
        _ReportData(
          title: 'Egitim ve Gelisim Raporu',
          description:
              'Terapist mesleki gelisim takibi ve egitim katılım ozeti',
          date: 'Q1 2026',
          icon: Icons.school_outlined,
          color: AppTheme.secondaryColor,
        ),
      ];
}

// =============================================================================
// Data Classes
// =============================================================================

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _SessionData {
  final String therapistName;
  final String therapistInitials;
  final String topic;
  final String date;
  final String status;

  const _SessionData({
    required this.therapistName,
    required this.therapistInitials,
    required this.topic,
    required this.date,
    required this.status,
  });
}

class _TherapistData {
  final String name;
  final String initials;
  final String specialty;
  final int sessionCount;
  final double satisfaction;
  final int completionRate;

  const _TherapistData({
    required this.name,
    required this.initials,
    required this.specialty,
    required this.sessionCount,
    required this.satisfaction,
    required this.completionRate,
  });
}

class _QualityMetric {
  final String title;
  final String description;
  final int score;
  final int? target;
  final IconData icon;

  const _QualityMetric({
    required this.title,
    required this.description,
    required this.score,
    this.target,
    required this.icon,
  });
}

class _ReportData {
  final String title;
  final String description;
  final String date;
  final IconData icon;
  final Color color;

  const _ReportData({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.color,
  });
}
