import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class TherapySimulationScreen extends StatefulWidget {
  const TherapySimulationScreen({super.key});

  @override
  State<TherapySimulationScreen> createState() =>
      _TherapySimulationScreenState();
}

class _TherapySimulationScreenState extends State<TherapySimulationScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late TabController _tabController;

  final List<_SimulationScenario> _scenarios = [
    _SimulationScenario(
      id: '1',
      name: 'Depresif Hasta ile Ilk Gorusme',
      difficulty: 'Baslangic',
      therapyType: 'BDT',
      estimatedDuration: '25 dk',
      description:
          'Majör depresif bozukluk tanisi almis bir hasta ile ilk klinik gorusmeyi simule eder. Terapotik iliski kurma ve ilk degerlendirme becerilerini olcer.',
      objectives: [
        'Terapotik iliski kurma',
        'Depresyon semptomlarini degerlendirme',
        'Risk faktorlerini belirleme',
        'Tedavi planini olusturma',
      ],
    ),
    _SimulationScenario(
      id: '2',
      name: 'Intihar Riski Degerlendirmesi',
      difficulty: 'Ileri',
      therapyType: 'Kriz Mudahalesi',
      estimatedDuration: '30 dk',
      description:
          'Intihar dusunceleri bildiren bir hasta ile acil degerlendirme gorusmesini simule eder. Guvenlik planlama ve kriz mudahalesi becerilerini test eder.',
      objectives: [
        'Intihar riskini degerlendirme',
        'Guvenlik plani olusturma',
        'Kriz mudahalesi uygulama',
        'Uygun sevk karari verme',
      ],
    ),
    _SimulationScenario(
      id: '3',
      name: 'Aile Terapisi - Catisma Yonetimi',
      difficulty: 'Orta',
      therapyType: 'Sistemik Terapi',
      estimatedDuration: '35 dk',
      description:
          'Ergen-ebeveyn catismasi yasayan bir aile ile terapi seansini simule eder. Aile dinamiklerini anlama ve catisma cozme becerilerini olcer.',
      objectives: [
        'Aile dinamiklerini analiz etme',
        'Tarafsizligi koruma',
        'Iletisim kaliplarini degistirme',
        'Ortak hedef belirleme',
      ],
    ),
    _SimulationScenario(
      id: '4',
      name: 'Cocuk Terapi - Oyun Terapisi',
      difficulty: 'Orta',
      therapyType: 'Oyun Terapisi',
      estimatedDuration: '20 dk',
      description:
          'Kaygi bozuklugu olan 7 yasinda bir cocuk ile oyun terapisi seansini simule eder. Cocuga uygun terapotik teknikleri uygulama becerisini degerlendirir.',
      objectives: [
        'Cocukla guven iliskisi kurma',
        'Oyun yoluyla degerlendirme yapma',
        'Yas grubuna uygun mudahale',
        'Ebeveyn geri bildirimi hazirlama',
      ],
    ),
    _SimulationScenario(
      id: '5',
      name: 'Travma Sonrasi Stres',
      difficulty: 'Ileri',
      therapyType: 'EMDR',
      estimatedDuration: '40 dk',
      description:
          'TSSB tanisi almis bir hasta ile EMDR terapisi seansini simule eder. Travma odakli mudahale ve duygu regulasyonu becerilerini olcer.',
      objectives: [
        'Travma hikayesini guvenli sekilde alma',
        'EMDR protokolunu uygulama',
        'Duygu regulasyonu teknikleri',
        'Seans sonrasi stabilizasyon',
      ],
    ),
  ];

  final List<_CompletedSimulation> _completedSimulations = [
    _CompletedSimulation(
      scenarioName: 'Depresif Hasta ile Ilk Gorusme',
      score: 4.5,
      date: '2026-03-20',
      feedbackSummary:
          'Terapotik iliski kurma konusunda basarili performans. Acik uclu sorularin kullanimi etkili. Degerlendirme surecinde daha fazla yapi oneriliyor.',
    ),
    _CompletedSimulation(
      scenarioName: 'Aile Terapisi - Catisma Yonetimi',
      score: 3.8,
      date: '2026-03-18',
      feedbackSummary:
          'Tarafsizlik konusunda gelistirme alani mevcut. Aile uyelerinin bireysel ihtiyaclarini dengeleme becerisi gelismeli. Catisma cozme teknikleri iyi uygulandi.',
    ),
    _CompletedSimulation(
      scenarioName: 'Cocuk Terapi - Oyun Terapisi',
      score: 4.7,
      date: '2026-03-15',
      feedbackSummary:
          'Cocukla iletisim ve guven iliskisi kurma konusunda mukemmel performans. Oyun terapisi teknikleri dogru ve etkili uygulandi.',
    ),
    _CompletedSimulation(
      scenarioName: 'Intihar Riski Degerlendirmesi',
      score: 4.0,
      date: '2026-03-12',
      feedbackSummary:
          'Risk degerlendirmesi kapsamli yapildi. Guvenlik plani olusturma basarili. Kriz mudahalesinde zaman yonetimi gelistirilebilir.',
    ),
    _CompletedSimulation(
      scenarioName: 'Travma Sonrasi Stres',
      score: 3.5,
      date: '2026-03-08',
      feedbackSummary:
          'EMDR protokolune hakimiyet gelisiyor. Duygu regulasyonu tekniklerinde daha fazla pratik oneriliyor. Hastanin stabilizasyonuna dikkat edilmeli.',
    ),
  ];

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
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      () {
        // Simulasyonu baslat
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      () {
        // Simulasyonu sonlandir
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Terapi Simulasyonu',
      child: Column(
        children: [
          _buildKpiRow(),
          const SizedBox(height: 16),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSimulationsTab(),
                _buildScenariosTab(),
                _buildHistoryTab(),
                _buildPerformanceTab(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow),
          tooltip: 'Simulasyonu Baslat',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
          tooltip: 'Ayarlar',
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Yeni Simulasyon',
          icon: Icons.add,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Simulasyon Gecmisi',
          icon: Icons.history,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Senaryolar',
          icon: Icons.theater_comedy,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Performans Analizi',
          icon: Icons.analytics,
          onTap: () {},
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // KPI Cards
  // ---------------------------------------------------------------------------

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            title: 'Tamamlanan Simulasyon',
            value: '34',
            icon: Icons.check_circle_outline,
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'Ortalama Puan',
            value: '4.2/5',
            icon: Icons.star_outline,
            color: AppTheme.warningColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'En Cok Kullanilan',
            value: 'BDT',
            icon: Icons.psychology_outlined,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'Aktif Senaryo',
            value: '8',
            icon: Icons.description_outlined,
            color: AppTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
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
          fontWeight: FontWeight.w500,
        ),
        dividerHeight: 0,
        tabs: const [
          Tab(text: 'Simulasyonlar'),
          Tab(text: 'Senaryolar'),
          Tab(text: 'Gecmis'),
          Tab(text: 'Performans'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Simulasyonlar Tab
  // ---------------------------------------------------------------------------

  Widget _buildSimulationsTab() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scenario = _scenarios[index];
        return _buildSimulationCard(scenario);
      },
    );
  }

  Widget _buildSimulationCard(_SimulationScenario scenario) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  scenario.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              _buildDifficultyBadge(scenario.difficulty),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scenario.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(Icons.local_hospital_outlined, scenario.therapyType),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.schedule_outlined, scenario.estimatedDuration),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Baslat'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color bgColor;
    Color textColor;

    switch (difficulty) {
      case 'Baslangic':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      case 'Orta':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFF9A3412);
        break;
      case 'Ileri':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Senaryolar Tab
  // ---------------------------------------------------------------------------

  Widget _buildScenariosTab() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scenario = _scenarios[index];
        return _buildScenarioDetailCard(scenario);
      },
    );
  }

  Widget _buildScenarioDetailCard(_SimulationScenario scenario) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${scenario.therapyType}  --  ${scenario.estimatedDuration}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              _buildDifficultyBadge(scenario.difficulty),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            scenario.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hedefler',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          ...scenario.objectives.map(
            (obj) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      obj,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Gecmis Tab
  // ---------------------------------------------------------------------------

  Widget _buildHistoryTab() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _completedSimulations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _completedSimulations[index];
        return _buildHistoryCard(item);
      },
    );
  }

  Widget _buildHistoryCard(_CompletedSimulation item) {
    final Color scoreColor;
    if (item.score >= 4.5) {
      scoreColor = const Color(0xFF10B981);
    } else if (item.score >= 3.5) {
      scoreColor = const Color(0xFFF59E0B);
    } else {
      scoreColor = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item.score.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.scenarioName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.date,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      return Icon(
                        i < item.score.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: const Color(0xFFF59E0B),
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      '${item.score.toStringAsFixed(1)}/5',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.feedbackSummary,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF6B7280),
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
  // Performans Tab
  // ---------------------------------------------------------------------------

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceSummaryRow(),
          const SizedBox(height: 24),
          const Text(
            'Yetkinlik Alanlari',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 14),
          _buildProgressItem('Terapotik Iliski Kurma', 0.88),
          _buildProgressItem('Risk Degerlendirmesi', 0.75),
          _buildProgressItem('Kriz Mudahalesi', 0.62),
          _buildProgressItem('Aile Terapisi Teknikleri', 0.70),
          _buildProgressItem('Cocuk / Ergen Terapisi', 0.82),
          _buildProgressItem('Travma Odakli Mudahale', 0.58),
          _buildProgressItem('Duygu Regulasyonu', 0.73),
          _buildProgressItem('Etik Karar Verme', 0.90),
          const SizedBox(height: 24),
          const Text(
            'Terapi Turu Bazinda Performans',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 14),
          _buildProgressItem('BDT', 0.85),
          _buildProgressItem('EMDR', 0.55),
          _buildProgressItem('Sistemik Terapi', 0.68),
          _buildProgressItem('Oyun Terapisi', 0.80),
          _buildProgressItem('Kriz Mudahalesi', 0.72),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPerformanceMetric(
            'Genel Basari',
            '% 78',
            0.78,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPerformanceMetric(
            'Tamamlanma Orani',
            '% 85',
            0.85,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPerformanceMetric(
            'Ortalama Sure',
            '28 dk',
            0.70,
            AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetric(
    String title,
    String value,
    double progress,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double value) {
    final Color barColor;
    if (value >= 0.8) {
      barColor = const Color(0xFF10B981);
    } else if (value >= 0.6) {
      barColor = const Color(0xFFF59E0B);
    } else {
      barColor = const Color(0xFFEF4444);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 44,
              child: Text(
                '% ${(value * 100).toInt()}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Data Models
// -----------------------------------------------------------------------------

class _SimulationScenario {
  final String id;
  final String name;
  final String difficulty;
  final String therapyType;
  final String estimatedDuration;
  final String description;
  final List<String> objectives;

  const _SimulationScenario({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.therapyType,
    required this.estimatedDuration,
    required this.description,
    required this.objectives,
  });
}

class _CompletedSimulation {
  final String scenarioName;
  final double score;
  final String date;
  final String feedbackSummary;

  const _CompletedSimulation({
    required this.scenarioName,
    required this.score,
    required this.date,
    required this.feedbackSummary,
  });
}
