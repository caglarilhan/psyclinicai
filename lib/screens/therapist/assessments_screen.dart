import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/assessment_scoring_service.dart';
import '../../utils/theme.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  final _phq9 = List<int>.filled(9, 0);
  final _gad7 = List<int>.filled(7, 0);
  List<Map<String, dynamic>> _recentAssessments = [];
  List<Map<String, dynamic>> _favoriteScales = [];

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

  Widget _buildScale(String title, int length, List<int> target) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(length, (i) {
                return DropdownButton<int>(
                  value: target[i],
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0')),
                    DropdownMenuItem(value: 1, child: Text('1')),
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                  ],
                  onChanged: (v) => setState(() => target[i] = v ?? 0),
                );
              }),
            ),
          ],
        ),
      ),
    );
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
      title: 'Değerlendirme Araçları',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Değerlendirme',
          onPressed: _createNewAssessment,
          icon: Icons.add,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'AI Analiz',
          onPressed: _generateAIAnalysis,
          icon: Icons.auto_awesome,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'İstatistikler',
          onPressed: _showAssessmentStatistics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportAssessmentReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showAssessmentSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'PHQ-9 & GAD-7',
          icon: Icons.assessment,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Son Değerlendirmeler',
          icon: Icons.history,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Favori Ölçekler',
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
        _buildDesktopScalesTab(),
        _buildDesktopRecentTab(),
        _buildDesktopFavoritesTab(),
        _buildDesktopReportsTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final scoring = context.watch<AssessmentScoringService>();
    final phqScore = scoring.scorePhq9(_phq9);
    final phqLevel = scoring.interpretPhq9(phqScore);
    final gadScore = scoring.scoreGad7(_gad7);
    final gadLevel = scoring.interpretGad7(gadScore);

    return Scaffold(
      appBar: AppBar(title: const Text('Ölçekler (PHQ‑9 / GAD‑7)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildScale('PHQ‑9', 9, _phq9),
            _buildScale('GAD‑7', 7, _gad7),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('PHQ‑9: $phqScore ($phqLevel)'),
                subtitle: Text('GAD‑7: $gadScore ($gadLevel)'),
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
      _createNewAssessment,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _generateAIAnalysis,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _showAssessmentStatistics,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      _exportAssessmentReport,
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
  Widget _buildDesktopScalesTab() {
    final scoring = context.watch<AssessmentScoringService>();
    final phqScore = scoring.scorePhq9(_phq9);
    final phqLevel = scoring.interpretPhq9(phqScore);
    final gadScore = scoring.scoreGad7(_gad7);
    final gadLevel = scoring.interpretGad7(gadScore);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PHQ-9 & GAD-7 Değerlendirme',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDesktopScale('PHQ-9', 9, _phq9),
                  const SizedBox(height: 24),
                  _buildDesktopScale('GAD-7', 7, _gad7),
                  const SizedBox(height: 24),
                  _buildDesktopResults(phqScore, phqLevel, gadScore, gadLevel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopScale(String title, int length, List<int> target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: length,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      'Soru ${index + 1}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    DropdownButton<int>(
                      value: target[index],
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('0')),
                        DropdownMenuItem(value: 1, child: Text('1')),
                        DropdownMenuItem(value: 2, child: Text('2')),
                        DropdownMenuItem(value: 3, child: Text('3')),
                      ],
                      onChanged: (v) => setState(() => target[index] = v ?? 0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopResults(int phqScore, String phqLevel, int gadScore, String gadLevel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Değerlendirme Sonuçları',
              style: DesktopTheme.desktopSectionTitleStyle,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResultCard('PHQ-9', phqScore.toString(), phqLevel, AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildResultCard('GAD-7', gadScore.toString(), gadLevel, AppTheme.accentColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String score, String level, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              score,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
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
            'Son Değerlendirmeler',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_recentAssessments.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son ${_recentAssessments.length} Değerlendirme',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._recentAssessments.map((assessment) => _buildAssessmentListItem(assessment)),
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
                        'Henüz değerlendirme yapılmadı',
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
            'Favori Ölçekler',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_favoriteScales.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_favoriteScales.length} Favori Ölçek',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._favoriteScales.map((scale) => _buildScaleListItem(scale)),
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
                        'Henüz favori ölçek eklenmedi',
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
            'Değerlendirme Raporları',
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

  Widget _buildAssessmentListItem(Map<String, dynamic> assessment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            assessment['id'],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(assessment['patientName'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${assessment['scale']} - ${assessment['score']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: assessment['level'] == 'Severe' ? AppTheme.errorColor : AppTheme.successColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                assessment['level'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showAssessmentDetails(assessment),
            ),
          ],
        ),
        onTap: () => _showAssessmentDetails(assessment),
      ),
    );
  }

  Widget _buildScaleListItem(Map<String, dynamic> scale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor,
          child: Icon(Icons.assessment, color: Colors.white),
        ),
        title: Text(scale['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(scale['description']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _removeFromFavorites(scale),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showScaleDetails(scale),
            ),
          ],
        ),
        onTap: () => _showScaleDetails(scale),
      ),
    );
  }

  // Yeni özellikler için metodlar
  void _loadInitialData() {
    setState(() {
      _recentAssessments = _getDemoAssessments();
      _favoriteScales = _getDemoFavoriteScales();
    });
  }

  List<Map<String, dynamic>> _getDemoAssessments() {
    return [
      {
        'id': '1',
        'patientName': 'Ahmet Yılmaz',
        'scale': 'PHQ-9',
        'score': '15',
        'level': 'Moderate',
        'date': '2024-01-15',
      },
      {
        'id': '2',
        'patientName': 'Fatma Demir',
        'scale': 'GAD-7',
        'score': '12',
        'level': 'Moderate',
        'date': '2024-01-10',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoFavoriteScales() {
    return [
      {
        'name': 'PHQ-9',
        'description': 'Depresyon şiddetini ölçen 9 soruluk ölçek',
        'questions': 9,
        'maxScore': 27,
      },
      {
        'name': 'GAD-7',
        'description': 'Anksiyete şiddetini ölçen 7 soruluk ölçek',
        'questions': 7,
        'maxScore': 21,
      },
    ];
  }

  void _addToFavorites(Map<String, dynamic> scale) {
    setState(() {
      if (!_favoriteScales.contains(scale)) {
        _favoriteScales.add(scale);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${scale['name']} favorilere eklendi'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _removeFromFavorites(Map<String, dynamic> scale) {
    setState(() {
      _favoriteScales.remove(scale);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${scale['name']} favorilerden çıkarıldı'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _addToRecent(Map<String, dynamic> assessment) {
    setState(() {
      _recentAssessments.remove(assessment); // Eğer varsa kaldır
      _recentAssessments.insert(0, assessment); // Başa ekle
      if (_recentAssessments.length > 10) {
        _recentAssessments.removeLast(); // Son 10 değerlendirmeyi tut
      }
    });
  }

  void _createNewAssessment() {
    // TODO: Yeni değerlendirme oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni değerlendirme oluşturuluyor...')),
    );
  }

  void _generateAIAnalysis() {
    // TODO: AI analiz oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI analiz oluşturuluyor...')),
    );
  }

  void _showAssessmentStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değerlendirme İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticItem('Toplam Değerlendirme', '${_recentAssessments.length}'),
            _buildStatisticItem('Favori Ölçekler', '${_favoriteScales.length}'),
            _buildStatisticItem('En Popüler Ölçek', 'PHQ-9'),
            _buildStatisticItem('Ortalama PHQ-9 Skoru', '12.5'),
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

  void _exportAssessmentReport() {
    // TODO: Değerlendirme raporu export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Değerlendirme raporu PDF olarak export ediliyor...')),
    );
  }

  void _showAssessmentSettings() {
    // TODO: Değerlendirme ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Değerlendirme ayarları yakında gelecek')),
    );
  }

  void _showAssessmentDetails(Map<String, dynamic> assessment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Değerlendirme #${assessment['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Hasta', assessment['patientName']),
            _buildDetailRow('Ölçek', assessment['scale']),
            _buildDetailRow('Skor', assessment['score']),
            _buildDetailRow('Seviye', assessment['level']),
            _buildDetailRow('Tarih', assessment['date']),
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

  void _showScaleDetails(Map<String, dynamic> scale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scale['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Açıklama', scale['description']),
            _buildDetailRow('Soru Sayısı', scale['questions'].toString()),
            _buildDetailRow('Maksimum Skor', scale['maxScore'].toString()),
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
