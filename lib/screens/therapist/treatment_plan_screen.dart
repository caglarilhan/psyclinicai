import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/treatment_plan_service.dart';
import '../../models/treatment_plan_models.dart';
import '../../utils/theme.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class TreatmentPlanScreen extends StatefulWidget {
  const TreatmentPlanScreen({super.key});

  @override
  State<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  List<Map<String, dynamic>> _recentPlans = [];
  List<Map<String, dynamic>> _favoriteTemplates = [];
  String _selectedStatus = 'Tümü';

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
    _removeKeyboardShortcuts();
    super.dispose();
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
      title: 'Tedavi Planı Yönetimi',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Plan',
          onPressed: _createNewPlan,
          icon: Icons.add,
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
          onPressed: _showPlanStatistics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportPlanReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showPlanSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'SMART Hedefler',
          icon: Icons.flag,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Son Planlar',
          icon: Icons.history,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Favori Şablonlar',
          icon: Icons.favorite,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Raporlar',
          icon: Icons.analytics,
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
        _buildDesktopGoalsTab(),
        _buildDesktopRecentTab(),
        _buildDesktopFavoritesTab(),
        _buildDesktopReportsTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final service = context.watch<TreatmentPlanService>();
    final plan = service.getOrCreatePlan(
      clientId: 'demo_client_001',
      clinicianId: 'demo_therapist_001',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tedavi Planı / SMART Hedefler')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final goal = SmartGoal(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Yeni Hedef',
                        description: 'Kısa açıklama',
                        createdAt: DateTime.now(),
                        targetDate: DateTime.now().add(const Duration(days: 30)),
                        status: GoalStatus.active,
                        tasks: [
                          TreatmentTask(id: 't1', title: 'İlk görev'),
                        ],
                      );
                      service.addGoal(plan.clientId, goal);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Hedef Ekle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: plan.goals.length,
                itemBuilder: (context, i) {
                  final g = plan.goals[i];
                  return Card(
                    child: ExpansionTile(
                      title: Text(g.title),
                      subtitle: Text(g.description),
                      children: [
                        ListTile(
                          title: Text('Durum: ${g.status.name}'),
                          subtitle: Text('Hedef Tarih: ${g.targetDate?.toIso8601String() ?? '-'}'),
                        ),
                        ...g.tasks.map((t) => CheckboxListTile(
                              value: t.done,
                              title: Text(t.title),
                              subtitle: t.notes != null ? Text(t.notes!) : null,
                              onChanged: (v) => service.toggleTask(plan.clientId, g.id, t.id, v ?? false),
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      _createNewPlan,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _generateAIRecommendation,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _showPlanStatistics,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      _exportPlanReport,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
    );
  }

  // Masaüstü tab metodları
  Widget _buildDesktopGoalsTab() {
    final service = context.watch<TreatmentPlanService>();
    final plan = service.getOrCreatePlan(
      clientId: 'demo_client_001',
      clinicianId: 'demo_therapist_001',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SMART Hedefler',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final goal = SmartGoal(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: 'Yeni Hedef',
                              description: 'Kısa açıklama',
                              createdAt: DateTime.now(),
                              targetDate: DateTime.now().add(const Duration(days: 30)),
                              status: GoalStatus.active,
                              tasks: [
                                TreatmentTask(id: 't1', title: 'İlk görev'),
                              ],
                            );
                            service.addGoal(plan.clientId, goal);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Hedef Ekle'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _createNewPlan,
                        icon: const Icon(Icons.flag),
                        label: const Text('Yeni Plan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mevcut Hedefler',
                    style: DesktopTheme.desktopSectionTitleStyle,
                  ),
                  const SizedBox(height: 16),
                  if (plan.goals.isNotEmpty)
                    ...plan.goals.map((g) => _buildGoalCard(g, plan.clientId, service))
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Henüz hedef eklenmemiş',
                          style: TextStyle(color: Colors.grey),
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

  Widget _buildDesktopRecentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Planlar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_recentPlans.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son ${_recentPlans.length} Plan',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._recentPlans.map((plan) => _buildPlanListItem(plan)),
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
                        'Henüz plan oluşturulmamış',
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
            'Favori Şablonlar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_favoriteTemplates.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_favoriteTemplates.length} Favori Şablon',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._favoriteTemplates.map((template) => _buildTemplateListItem(template)),
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
                        'Henüz favori şablon eklenmedi',
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

  Widget _buildDesktopReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tedavi Planı Raporları',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.analytics, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Raporlar yakında gelecek',
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

  Widget _buildGoalCard(SmartGoal goal, String clientId, TreatmentPlanService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(goal.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(goal.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        goal.status.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Hedef Tarih: ${goal.targetDate?.toIso8601String() ?? '-'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Görevler',
                  style: DesktopTheme.desktopSectionTitleStyle,
                ),
                const SizedBox(height: 8),
                ...goal.tasks.map((t) => CheckboxListTile(
                      value: t.done,
                      title: Text(t.title),
                      subtitle: t.notes != null ? Text(t.notes!) : null,
                      onChanged: (v) => service.toggleTask(clientId, goal.id, t.id, v ?? false),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanListItem(Map<String, dynamic> plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            plan['id'],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(plan['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${plan['client']} - ${plan['date']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                plan['status'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showPlanDetails(plan),
            ),
          ],
        ),
        onTap: () => _showPlanDetails(plan),
      ),
    );
  }

  Widget _buildTemplateListItem(Map<String, dynamic> template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor,
          child: Icon(Icons.description, color: Colors.white),
        ),
        title: Text(template['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(template['description']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _removeFromFavorites(template),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showTemplateDetails(template),
            ),
          ],
        ),
        onTap: () => _showTemplateDetails(template),
      ),
    );
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return AppTheme.primaryColor;
      case GoalStatus.onHold:
        return AppTheme.warningColor;
      case GoalStatus.completed:
        return AppTheme.successColor;
      case GoalStatus.paused:
        return AppTheme.warningColor;
      case GoalStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  // Yeni özellikler için metodlar
  void _loadInitialData() {
    setState(() {
      _recentPlans = _getDemoPlans();
      _favoriteTemplates = _getDemoFavoriteTemplates();
    });
  }

  List<Map<String, dynamic>> _getDemoPlans() {
    return [
      {
        'id': '1',
        'title': 'Depresyon Tedavi Planı',
        'client': 'Ahmet Yılmaz',
        'date': '2024-01-15',
        'status': 'Aktif',
      },
      {
        'id': '2',
        'title': 'Anksiyete Tedavi Planı',
        'client': 'Fatma Demir',
        'date': '2024-01-10',
        'status': 'Tamamlandı',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoFavoriteTemplates() {
    return [
      {
        'name': 'Depresyon Tedavi Planı',
        'description': 'Depresyon için kapsamlı tedavi planı',
        'goals': 5,
        'category': 'Mood Disorders',
      },
      {
        'name': 'Anksiyete Tedavi Planı',
        'description': 'Anksiyete için bilişsel davranışçı terapi planı',
        'goals': 4,
        'category': 'Anxiety Disorders',
      },
    ];
  }

  void _addToFavorites(Map<String, dynamic> template) {
    setState(() {
      if (!_favoriteTemplates.contains(template)) {
        _favoriteTemplates.add(template);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template['name']} favorilere eklendi'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _removeFromFavorites(Map<String, dynamic> template) {
    setState(() {
      _favoriteTemplates.remove(template);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template['name']} favorilerden çıkarıldı'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _addToRecent(Map<String, dynamic> plan) {
    setState(() {
      _recentPlans.remove(plan); // Eğer varsa kaldır
      _recentPlans.insert(0, plan); // Başa ekle
      if (_recentPlans.length > 10) {
        _recentPlans.removeLast(); // Son 10 planı tut
      }
    });
  }

  void _createNewPlan() {
    // TODO: Yeni plan oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni plan oluşturuluyor...')),
    );
  }

  void _generateAIRecommendation() {
    // TODO: AI öneri oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI öneri oluşturuluyor...')),
    );
  }

  void _showPlanStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tedavi Planı İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticItem('Toplam Plan', '${_recentPlans.length}'),
            _buildStatisticItem('Favori Şablonlar', '${_favoriteTemplates.length}'),
            _buildStatisticItem('Aktif Hedefler', '3'),
            _buildStatisticItem('Tamamlanan Hedefler', '2'),
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

  void _exportPlanReport() {
    // TODO: Tedavi planı raporu export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tedavi planı raporu PDF olarak export ediliyor...')),
    );
  }

  void _showPlanSettings() {
    // TODO: Tedavi planı ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tedavi planı ayarları yakında gelecek')),
    );
  }

  void _showPlanDetails(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Plan #${plan['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Başlık', plan['title']),
            _buildDetailRow('Danışan', plan['client']),
            _buildDetailRow('Tarih', plan['date']),
            _buildDetailRow('Durum', plan['status']),
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

  void _showTemplateDetails(Map<String, dynamic> template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Açıklama', template['description']),
            _buildDetailRow('Hedef Sayısı', template['goals'].toString()),
            _buildDetailRow('Kategori', template['category']),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
