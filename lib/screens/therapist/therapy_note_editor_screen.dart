import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/therapy_note_service.dart';
import '../../models/therapy_note_models.dart';
import '../../utils/theme.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class TherapyNoteEditorScreen extends StatefulWidget {
  const TherapyNoteEditorScreen({super.key});

  @override
  State<TherapyNoteEditorScreen> createState() => _TherapyNoteEditorScreenState();
}

class _TherapyNoteEditorScreenState extends State<TherapyNoteEditorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  TherapyNoteTemplate? _selectedTemplate;
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;
  List<Map<String, dynamic>> _recentNotes = [];
  List<Map<String, dynamic>> _favoriteTemplates = [];

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
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTemplateChanged(TherapyNoteTemplate template) {
    setState(() {
      _selectedTemplate = template;
      // Reset controllers
      for (final c in _controllers.values) {
        c.dispose();
      }
      _controllers.clear();
      for (final f in template.fields) {
        _controllers[f.key] = TextEditingController();
      }
    });
  }

  Future<void> _saveNote() async {
    if (_selectedTemplate == null) return;
    setState(() => _saving = true);
    try {
      final values = <String, dynamic>{};
      for (final entry in _controllers.entries) {
        values[entry.key] = entry.value.text.trim();
      }
      await context.read<TherapyNoteService>().createEntry(
            sessionId: 'demo_session_001',
            clinicianId: 'demo_therapist_001',
            clientId: 'demo_client_001',
            templateId: _selectedTemplate!.id,
            values: values,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not kaydedildi')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
      title: 'Seans Notu Editörü',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Not',
          onPressed: _createNewNote,
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
          onPressed: _showNoteStatistics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportNoteReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showNoteSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Not Editörü',
          icon: Icons.edit,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Son Notlar',
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
        _buildDesktopEditorTab(),
        _buildDesktopRecentTab(),
        _buildDesktopFavoritesTab(),
        _buildDesktopReportsTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final templates = context.watch<TherapyNoteService>().templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seans Notu (DAP/SOAP)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<TherapyNoteTemplate>(
              isExpanded: true,
              hint: const Text('Şablon seçin'),
              value: _selectedTemplate,
              items: templates
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name),
                      ))
                  .toList(),
              onChanged: (t) {
                if (t != null) _onTemplateChanged(t);
              },
            ),
            const SizedBox(height: 16),
            if (_selectedTemplate != null)
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      _selectedTemplate!.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ..._selectedTemplate!.fields.map((f) {
                      final c = _controllers[f.key]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: c,
                          maxLines: f.type == NoteFieldType.longText ? 5 : 1,
                          decoration: InputDecoration(
                            labelText: f.label,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedTemplate == null || _saving ? null : _saveNote,
                    icon: const Icon(Icons.save),
                    label: _saving
                        ? const Text('Kaydediliyor...')
                        : const Text('Kaydet'),
                  ),
                ),
              ],
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
      _createNewNote,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _generateAIRecommendation,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _saveNote,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      _exportNoteReport,
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
  Widget _buildDesktopEditorTab() {
    final templates = context.watch<TherapyNoteService>().templates;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seans Notu Editörü',
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
                    'Şablon Seçimi',
                    style: DesktopTheme.desktopSectionTitleStyle,
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<TherapyNoteTemplate>(
                    isExpanded: true,
                    hint: const Text('Şablon seçin'),
                    value: _selectedTemplate,
                    items: templates
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name),
                            ))
                        .toList(),
                    onChanged: (t) {
                      if (t != null) _onTemplateChanged(t);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_selectedTemplate != null) ...[
                    Text(
                      'Not İçeriği',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedTemplate!.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ..._selectedTemplate!.fields.map((f) {
                      final c = _controllers[f.key]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextField(
                          controller: c,
                          maxLines: f.type == NoteFieldType.longText ? 5 : 1,
                          decoration: InputDecoration(
                            labelText: f.label,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _saveNote,
                            icon: const Icon(Icons.save),
                            label: _saving
                                ? const Text('Kaydediliyor...')
                                : const Text('Kaydet'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _createNewNote,
                          icon: const Icon(Icons.add),
                          label: const Text('Yeni Not'),
                        ),
                      ],
                    ),
                  ],
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
            'Son Notlar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_recentNotes.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son ${_recentNotes.length} Not',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._recentNotes.map((note) => _buildNoteListItem(note)),
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
                        'Henüz not yazılmadı',
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
            'Not Raporları',
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

  Widget _buildNoteListItem(Map<String, dynamic> note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            note['id'],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(note['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${note['client']} - ${note['date']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Kaydedildi',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showNoteDetails(note),
            ),
          ],
        ),
        onTap: () => _showNoteDetails(note),
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

  // Yeni özellikler için metodlar
  void _loadInitialData() {
    setState(() {
      _recentNotes = _getDemoNotes();
      _favoriteTemplates = _getDemoFavoriteTemplates();
    });
  }

  List<Map<String, dynamic>> _getDemoNotes() {
    return [
      {
        'id': '1',
        'title': 'DAP Notu',
        'client': 'Ahmet Yılmaz',
        'date': '2024-01-15',
        'template': 'DAP',
      },
      {
        'id': '2',
        'title': 'SOAP Notu',
        'client': 'Fatma Demir',
        'date': '2024-01-10',
        'template': 'SOAP',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoFavoriteTemplates() {
    return [
      {
        'name': 'DAP Notu',
        'description': 'Data, Assessment, Plan formatında seans notu',
        'fields': 4,
        'category': 'Standard',
      },
      {
        'name': 'SOAP Notu',
        'description': 'Subjective, Objective, Assessment, Plan formatında not',
        'fields': 4,
        'category': 'Standard',
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

  void _addToRecent(Map<String, dynamic> note) {
    setState(() {
      _recentNotes.remove(note); // Eğer varsa kaldır
      _recentNotes.insert(0, note); // Başa ekle
      if (_recentNotes.length > 10) {
        _recentNotes.removeLast(); // Son 10 notu tut
      }
    });
  }

  void _createNewNote() {
    // TODO: Yeni not oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni not oluşturuluyor...')),
    );
  }

  void _generateAIRecommendation() {
    // TODO: AI öneri oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI öneri oluşturuluyor...')),
    );
  }

  void _showNoteStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticItem('Toplam Not', '${_recentNotes.length}'),
            _buildStatisticItem('Favori Şablonlar', '${_favoriteTemplates.length}'),
            _buildStatisticItem('En Popüler Şablon', 'DAP'),
            _buildStatisticItem('Bu Ay Yazılan', '5'),
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

  void _exportNoteReport() {
    // TODO: Not raporu export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not raporu PDF olarak export ediliyor...')),
    );
  }

  void _showNoteSettings() {
    // TODO: Not ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not ayarları yakında gelecek')),
    );
  }

  void _showNoteDetails(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Not #${note['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Başlık', note['title']),
            _buildDetailRow('Danışan', note['client']),
            _buildDetailRow('Tarih', note['date']),
            _buildDetailRow('Şablon', note['template']),
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
            _buildDetailRow('Alan Sayısı', template['fields'].toString()),
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
