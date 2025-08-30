import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/homework_service.dart';
import '../../utils/theme.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  List<Map<String, dynamic>> _recentAssignments = [];
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
      title: 'Ev Ödevi Yönetimi',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Ödev',
          onPressed: _createNewHomework,
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
          onPressed: _showHomeworkStatistics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportHomeworkReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showHomeworkSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Ödev Atama',
          icon: Icons.assignment,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Son Ödevler',
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
        _buildDesktopAssignmentTab(),
        _buildDesktopRecentTab(),
        _buildDesktopFavoritesTab(),
        _buildDesktopReportsTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final service = context.watch<HomeworkService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ev Ödevi Atama')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Şablon'),
                    items: service.templates
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      await service.assign(
                        clientId: 'demo_client_001',
                        clinicianId: 'demo_therapist_001',
                        templateId: v,
                        customInstructions: 'Kısa talimat',
                        dueDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ödev atandı')));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: service.assignments.length,
                itemBuilder: (context, i) {
                  final a = service.assignments[i];
                  return Card(
                    child: ListTile(
                      title: Text(a.templateId),
                      subtitle: Text('Son tarih: ${a.dueDate?.toIso8601String() ?? '-'}'),
                      trailing: a.completed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.done),
                              onPressed: () => service.markCompleted(a.id),
                            ),
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
      _createNewHomework,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _generateAIRecommendation,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _showHomeworkStatistics,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      _exportHomeworkReport,
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
  Widget _buildDesktopAssignmentTab() {
    final service = context.watch<HomeworkService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ev Ödevi Atama',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni Ödev Atama',
                    style: DesktopTheme.desktopSectionTitleStyle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Şablon Seçin',
                          ),
                          items: service.templates
                              .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                              .toList(),
                          onChanged: (v) async {
                            if (v == null) return;
                            await service.assign(
                              clientId: 'demo_client_001',
                              clinicianId: 'demo_therapist_001',
                              templateId: v,
                              customInstructions: 'Kısa talimat',
                              dueDate: DateTime.now().add(const Duration(days: 7)),
                            );
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ödev atandı')));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _createNewHomework,
                        child: const Text('Yeni Ödev Oluştur'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mevcut Ödevler',
                    style: DesktopTheme.desktopSectionTitleStyle,
                  ),
                  const SizedBox(height: 16),
                  if (service.assignments.isNotEmpty)
                    ...service.assignments.map((a) => _buildHomeworkListItem(a))
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Henüz ödev atanmamış',
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
            'Son Ödevler',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_recentAssignments.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son ${_recentAssignments.length} Ödev',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._recentAssignments.map((assignment) => _buildAssignmentListItem(assignment)),
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
                        'Henüz ödev atanmamış',
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
            'Ev Ödevi Raporları',
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

  Widget _buildHomeworkListItem(dynamic assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: assignment.completed ? AppTheme.successColor : AppTheme.primaryColor,
          child: Icon(
            assignment.completed ? Icons.check : Icons.assignment,
            color: Colors.white,
          ),
        ),
        title: Text(assignment.templateId, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Son tarih: ${assignment.dueDate?.toIso8601String() ?? '-'}'),
        trailing: assignment.completed
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.done),
                onPressed: () {
                  // TODO: Mark as completed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ödev tamamlandı olarak işaretlendi')),
                  );
                },
              ),
        onTap: () => _showHomeworkDetails(assignment),
      ),
    );
  }

  Widget _buildAssignmentListItem(Map<String, dynamic> assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            assignment['id'],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(assignment['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${assignment['client']} - ${assignment['dueDate']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: assignment['status'] == 'Completed' ? AppTheme.successColor : AppTheme.warningColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                assignment['status'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showAssignmentDetails(assignment),
            ),
          ],
        ),
        onTap: () => _showAssignmentDetails(assignment),
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
        title: Text(template['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
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

  // Yeni özellikler için metodlar
  void _loadInitialData() {
    setState(() {
      _recentAssignments = _getDemoAssignments();
      _favoriteTemplates = _getDemoFavoriteTemplates();
    });
  }

  List<Map<String, dynamic>> _getDemoAssignments() {
    return [
      {
        'id': '1',
        'title': 'Günlük Kayıt Tutma',
        'client': 'Ahmet Yılmaz',
        'dueDate': '2024-01-20',
        'status': 'Pending',
      },
      {
        'id': '2',
        'title': 'Nefes Egzersizleri',
        'client': 'Fatma Demir',
        'dueDate': '2024-01-18',
        'status': 'Completed',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoFavoriteTemplates() {
    return [
      {
        'title': 'Günlük Kayıt Tutma',
        'description': 'Günlük duygu ve düşünce kayıtları',
        'duration': '15 dakika',
        'category': 'Mindfulness',
      },
      {
        'title': 'Nefes Egzersizleri',
        'description': 'Gevşeme ve nefes kontrolü egzersizleri',
        'duration': '10 dakika',
        'category': 'Relaxation',
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
        content: Text('${template['title']} favorilere eklendi'),
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
        content: Text('${template['title']} favorilerden çıkarıldı'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _addToRecent(Map<String, dynamic> assignment) {
    setState(() {
      _recentAssignments.remove(assignment); // Eğer varsa kaldır
      _recentAssignments.insert(0, assignment); // Başa ekle
      if (_recentAssignments.length > 10) {
        _recentAssignments.removeLast(); // Son 10 ödevi tut
      }
    });
  }

  void _createNewHomework() {
    // TODO: Yeni ödev oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni ödev oluşturuluyor...')),
    );
  }

  void _generateAIRecommendation() {
    // TODO: AI öneri oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI öneri oluşturuluyor...')),
    );
  }

  void _showHomeworkStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ev Ödevi İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticItem('Toplam Ödev', '${_recentAssignments.length}'),
            _buildStatisticItem('Favori Şablonlar', '${_favoriteTemplates.length}'),
            _buildStatisticItem('Tamamlanan Ödevler', '1'),
            _buildStatisticItem('Bekleyen Ödevler', '1'),
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

  void _exportHomeworkReport() {
    // TODO: Ev ödevi raporu export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ev ödevi raporu PDF olarak export ediliyor...')),
    );
  }

  void _showHomeworkSettings() {
    // TODO: Ev ödevi ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ev ödevi ayarları yakında gelecek')),
    );
  }

  void _showHomeworkDetails(dynamic assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ödev #${assignment.templateId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Şablon', assignment.templateId),
            _buildDetailRow('Son Tarih', assignment.dueDate?.toIso8601String() ?? '-'),
            _buildDetailRow('Durum', assignment.completed ? 'Tamamlandı' : 'Bekliyor'),
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

  void _showAssignmentDetails(Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ödev #${assignment['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Başlık', assignment['title']),
            _buildDetailRow('Danışan', assignment['client']),
            _buildDetailRow('Son Tarih', assignment['dueDate']),
            _buildDetailRow('Durum', assignment['status']),
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
        title: Text(template['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Açıklama', template['description']),
            _buildDetailRow('Süre', template['duration']),
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
