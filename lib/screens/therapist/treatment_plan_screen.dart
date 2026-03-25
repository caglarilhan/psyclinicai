import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class TreatmentPlanScreen extends StatefulWidget {
  const TreatmentPlanScreen({super.key});

  @override
  State<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService =
      KeyboardShortcutsService();
  late TabController _tabController;

  final List<_TreatmentPlan> _activePlans = [
    _TreatmentPlan('Ahmet Yılmaz', 'Major Depresif Bozukluk', 'BDT',
        '01.01.2026', '01.05.2026', 0.65, 12,
        ['Olumsuz düşünce kalıplarını tanımlama', 'Davranışsal aktivasyon', 'Bilişsel yeniden yapılandırma']),
    _TreatmentPlan('Ayşe Demir', 'Yaygın Anksiyete Bozukluğu', 'BDT',
        '15.01.2026', '15.06.2026', 0.45, 8,
        ['Gevşeme teknikleri', 'Endişe maruz bırakma', 'Problem çözme becerileri']),
    _TreatmentPlan('Mehmet Kaya', 'TSSB', 'EMDR',
        '01.02.2026', '01.07.2026', 0.30, 6,
        ['Travma işleme', 'Duyarsızlaştırma', 'Yeniden işleme']),
    _TreatmentPlan('Fatma Çelik', 'Sosyal Fobi', 'BDT',
        '10.02.2026', '10.06.2026', 0.55, 10,
        ['Sosyal beceri eğitimi', 'Kademeli maruz bırakma', 'Bilişsel yeniden yapılandırma']),
    _TreatmentPlan('Ali Öztürk', 'OKB', 'Maruz Bırakma ve Tepki Önleme',
        '20.02.2026', '20.08.2026', 0.20, 4,
        ['Obsesyon hiyerarşisi', 'Kademeli maruz bırakma', 'Tepki önleme']),
    _TreatmentPlan('Zeynep Aydın', 'Bipolar Bozukluk', 'Psikodinamik',
        '01.12.2025', '01.06.2026', 0.80, 18,
        ['Duygudurum takibi', 'İlaç uyumu', 'Psikoeğitim', 'Stres yönetimi']),
  ];

  final List<_TreatmentPlan> _completedPlans = [
    _TreatmentPlan('Burak Şahin', 'Major Depresif Bozukluk', 'BDT',
        '01.06.2025', '01.12.2025', 1.0, 20,
        ['Tamamlandı'], outcome: 'Başarılı'),
    _TreatmentPlan('Selin Koç', 'Panik Bozukluk', 'BDT',
        '01.07.2025', '01.01.2026', 1.0, 16,
        ['Tamamlandı'], outcome: 'Başarılı'),
    _TreatmentPlan('Emre Yıldız', 'Yaygın Anksiyete', 'EMDR',
        '01.08.2025', '01.02.2026', 1.0, 14,
        ['Tamamlandı'], outcome: 'Kısmen Başarılı'),
  ];

  final List<_PlanTemplate> _templates = [
    _PlanTemplate('Depresyon BDT Planı', 'BDT', '16 Hafta',
        'Major depresif bozukluk için standart BDT protokolü. Bilişsel yeniden yapılandırma ve davranışsal aktivasyon odaklı.'),
    _PlanTemplate('Anksiyete Maruz Bırakma', 'BDT', '12 Hafta',
        'Yaygın anksiyete ve fobiler için kademeli maruz bırakma protokolü. Gevşeme teknikleri ve hiyerarşik maruz bırakma.'),
    _PlanTemplate('Travma EMDR Protokolü', 'EMDR', '20 Hafta',
        'TSSB ve travma sonrası stres için EMDR protokolü. 8 fazlı standart EMDR uygulaması.'),
    _PlanTemplate('OKB Tepki Önleme', 'Maruz Bırakma', '24 Hafta',
        'OKB için maruz bırakma ve tepki önleme protokolü. Obsesyon hiyerarşisi ve sistematik duyarsızlaştırma.'),
    _PlanTemplate('Psikodinamik Terapi Planı', 'Psikodinamik', '32 Hafta',
        'Kişilik bozuklukları ve kronik durumlar için uzun süreli psikodinamik terapi planı.'),
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
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () {},
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      () {},
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

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Tedavi Planı',
      child: Column(
        children: [
          _buildKPICards(),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Aktif Planlar'),
              Tab(text: 'Tamamlanan'),
              Tab(text: 'Şablonlar'),
              Tab(text: 'İstatistikler'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActivePlansTab(),
                _buildCompletedTab(),
                _buildTemplatesTab(),
                _buildStatsTab(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.save)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Yeni Tedavi Planı',
          icon: Icons.add,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Aktif Planlar',
          icon: Icons.medical_services,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Tamamlanan Planlar',
          icon: Icons.check_circle,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Şablonlar',
          icon: Icons.description,
          onTap: () => _tabController.animateTo(2),
        ),
      ],
    );
  }

  Widget _buildKPICards() {
    return Row(
      children: [
        Expanded(
            child: _buildKPI(
                'Aktif Plan', '18', Icons.medical_services, AppTheme.primaryColor)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildKPI(
                'Tamamlanan', '89', Icons.check_circle, AppTheme.successColor)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildKPI(
                'Ort. Süre', '16 Hafta', Icons.schedule, AppTheme.accentColor)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildKPI(
                'İlerleme', '%72', Icons.trending_up, AppTheme.warningColor)),
      ],
    );
  }

  Widget _buildKPI(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // --- Aktif Planlar ---
  Widget _buildActivePlansTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _activePlans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = _activePlans[index];
        return _buildPlanCard(p);
      },
    );
  }

  Widget _buildPlanCard(_TreatmentPlan plan) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(plan.patient[0],
                      style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.patient,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(plan.diagnosis,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _therapyTypeBadge(plan.therapyType),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.calendar_today, plan.startDate),
                const SizedBox(width: 12),
                _infoChip(Icons.flag, plan.targetDate),
                const SizedBox(width: 12),
                _infoChip(Icons.event_note, '${plan.sessionCount} Seans'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: plan.progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                          plan.progress >= 0.7
                              ? AppTheme.successColor
                              : plan.progress >= 0.4
                                  ? AppTheme.warningColor
                                  : AppTheme.accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(plan.progress * 100).toInt()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Hedefler',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor)),
            const SizedBox(height: 4),
            ...plan.goals.map((g) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text(g,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _therapyTypeBadge(String type) {
    Color color;
    switch (type) {
      case 'BDT':
        color = AppTheme.primaryColor;
        break;
      case 'EMDR':
        color = AppTheme.successColor;
        break;
      case 'Psikodinamik':
        color = AppTheme.accentColor;
        break;
      default:
        color = AppTheme.warningColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(type,
          style:
              TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  // --- Tamamlanan ---
  Widget _buildCompletedTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _completedPlans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = _completedPlans[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
              child: const Icon(Icons.check, color: AppTheme.successColor),
            ),
            title: Text(p.patient,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
                '${p.diagnosis}  |  ${p.therapyType}  |  ${p.sessionCount} Seans'),
            trailing: _outcomeBadge(p.outcome ?? ''),
          ),
        );
      },
    );
  }

  Widget _outcomeBadge(String outcome) {
    Color color;
    switch (outcome) {
      case 'Başarılı':
        color = AppTheme.successColor;
        break;
      case 'Kısmen Başarılı':
        color = AppTheme.warningColor;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(outcome,
          style:
              TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // --- Şablonlar ---
  Widget _buildTemplatesTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = _templates[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    _therapyTypeBadge(t.therapyType),
                  ],
                ),
                const SizedBox(height: 8),
                Text(t.description,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text('Süre: ${t.duration}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Kullan', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- İstatistikler ---
  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tedavi İstatistikleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _statCard('Toplam Plan', '107', AppTheme.primaryColor)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Ortalama Seans', '14.5', AppTheme.accentColor)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Başarı Oranı', '%83', AppTheme.successColor)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Terapi Türü Dağılımı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _distributionBar('BDT', 0.55, AppTheme.primaryColor),
          const SizedBox(height: 8),
          _distributionBar('EMDR', 0.20, AppTheme.successColor),
          const SizedBox(height: 8),
          _distributionBar('Psikodinamik', 0.15, AppTheme.accentColor),
          const SizedBox(height: 8),
          _distributionBar('Diğer', 0.10, AppTheme.warningColor),
          const SizedBox(height: 24),
          const Text('Tanı Bazlı Dağılım',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _distributionBar('Depresyon', 0.35, AppTheme.primaryColor),
          const SizedBox(height: 8),
          _distributionBar('Anksiyete', 0.28, AppTheme.accentColor),
          const SizedBox(height: 8),
          _distributionBar('Travma/TSSB', 0.18, AppTheme.warningColor),
          const SizedBox(height: 8),
          _distributionBar('OKB', 0.12, AppTheme.successColor),
          const SizedBox(height: 8),
          _distributionBar('Diğer', 0.07, Colors.grey),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _distributionBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 20,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text('${(value * 100).toInt()}%',
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }
}

class _TreatmentPlan {
  final String patient;
  final String diagnosis;
  final String therapyType;
  final String startDate;
  final String targetDate;
  final double progress;
  final int sessionCount;
  final List<String> goals;
  final String? outcome;

  _TreatmentPlan(this.patient, this.diagnosis, this.therapyType,
      this.startDate, this.targetDate, this.progress, this.sessionCount,
      this.goals, {this.outcome});
}

class _PlanTemplate {
  final String title;
  final String therapyType;
  final String duration;
  final String description;
  _PlanTemplate(this.title, this.therapyType, this.duration, this.description);
}
