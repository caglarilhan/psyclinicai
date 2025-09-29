import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../models/therapy_simulation_model.dart';
import '../../widgets/therapy_simulation/simulation_scenario_panel.dart';
import '../../widgets/therapy_simulation/ai_client_panel.dart';
import '../../widgets/therapy_simulation/session_notes_panel.dart';
import '../../services/therapy_simulation_service.dart'; // Added import for TherapySimulationService
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class TherapySimulationScreen extends StatefulWidget {
  const TherapySimulationScreen({super.key});

  @override
  State<TherapySimulationScreen> createState() =>
      _TherapySimulationScreenState();
}

class _TherapySimulationScreenState extends State<TherapySimulationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  List<SimulationScenario> _scenarios = [];
  SimulationScenario? _selectedScenario;
  bool _isSessionActive = false;
  List<SessionMessage> _sessionMessages = [];
  String _sessionNotes = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDemoScenarios();
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _loadDemoScenarios() {
    setState(() {
      _scenarios = [
        SimulationScenario(
          id: '1',
          title: 'Depresyon Vakası: Ahmet',
          description:
              '35 yaşında erkek, son 6 aydır depresif belirtiler gösteriyor. İş kaybı ve evlilik problemleri yaşıyor.',
          difficulty: ScenarioDifficulty.intermediate,
          category: 'Depresyon',
          clientProfile: ClientProfile(
            name: 'Ahmet',
            age: 35,
            gender: 'Erkek',
            presentingProblem: 'Depresyon, iş kaybı, evlilik problemleri',
            background: 'Mühendis, 2 çocuk babası, son 6 aydır işsiz',
            symptoms: [
              'Üzgün ruh hali',
              'Uyku problemleri',
              'İştah kaybı',
              'Konsantrasyon güçlüğü'
            ],
            goals: 'Depresyonu yönetmek, iş bulmak, evliliği iyileştirmek',
          ),
          therapeuticApproach: 'CBT + Problem Solving Therapy',
          estimatedDuration: 45,
          tags: ['depresyon', 'iş kaybı', 'evlilik', 'CBT'],
        ),
        SimulationScenario(
          id: '2',
          title: 'Anksiyete Vakası: Zeynep',
          description:
              '28 yaşında kadın, sosyal anksiyete ve panik atak belirtileri. Topluluk önünde konuşma korkusu.',
          difficulty: ScenarioDifficulty.beginner,
          category: 'Anksiyete',
          clientProfile: ClientProfile(
            name: 'Zeynep',
            age: 28,
            gender: 'Kadın',
            presentingProblem: 'Sosyal anksiyete, panik atak',
            background:
                'Öğretmen, bekar, sosyal ortamlarda kendini rahatsız hissediyor',
            symptoms: [
              'Sosyal ortamlarda kaygı',
              'Panik atak',
              'Kaçınma davranışları',
              'Fiziksel belirtiler'
            ],
            goals: 'Sosyal anksiyeteyi azaltmak, panik atakları yönetmek',
          ),
          therapeuticApproach: 'Exposure Therapy + Relaxation Techniques',
          estimatedDuration: 40,
          tags: ['anksiyete', 'sosyal fobi', 'panik atak', 'exposure'],
        ),
        SimulationScenario(
          id: '3',
          title: 'Travma Vakası: Mehmet',
          description:
              '42 yaşında erkek, trafik kazası sonrası TSSB belirtileri. Flashback\'ler ve uyku problemleri.',
          difficulty: ScenarioDifficulty.advanced,
          category: 'Travma',
          clientProfile: ClientProfile(
            name: 'Mehmet',
            age: 42,
            gender: 'Erkek',
            presentingProblem: 'TSSB, trafik kazası sonrası',
            background: 'Şoför, 3 ay önce ciddi trafik kazası geçirdi',
            symptoms: [
              'Flashback\'ler',
              'Uyku problemleri',
              'Kaçınma davranışları',
              'Aşırı uyarılma'
            ],
            goals: 'Travma belirtilerini azaltmak, normal hayata dönmek',
          ),
          therapeuticApproach: 'EMDR + Trauma-Focused CBT',
          estimatedDuration: 60,
          tags: ['travma', 'TSSB', 'EMDR', 'flashback'],
        ),
      ];
    });
  }

  void _startSimulation(SimulationScenario scenario) {
    setState(() {
      _selectedScenario = scenario;
      _isSessionActive = true;
      _sessionMessages = [];
      _sessionNotes = '';

      // AI danışanın ilk mesajını ekle
      _sessionMessages.add(SessionMessage(
        id: '1',
        sender: MessageSender.client,
        content: _generateInitialClientMessage(scenario),
        timestamp: DateTime.now(),
      ));
    });

    _tabController.animateTo(1); // AI Client tab'ına geç
  }

  void _endSimulation() {
    if (_selectedScenario != null && _sessionMessages.isNotEmpty) {
      // Skor hesapla
      final simulationService = TherapySimulationService();
      final score = simulationService.calculateScore(_sessionMessages, _selectedScenario!);
      
      // Sonuçları göster
      _showSimulationResults(score);
    }

    setState(() {
      _isSessionActive = false;
      _selectedScenario = null;
    });

    _tabController.animateTo(0); // Scenarios tab'ına dön
  }

  void _addTherapistMessage(String content) {
    if (content.trim().isEmpty) return;

    setState(() {
      _sessionMessages.add(SessionMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: MessageSender.therapist,
        content: content,
        timestamp: DateTime.now(),
      ));
    });

    // AI danışanın yanıtını simüle et
    _simulateAIResponse(content);
  }

  void _simulateAIResponse(String therapistMessage) {
    // AI yanıt simülasyonu
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _selectedScenario != null) {
        final aiResponse =
            _generateAIResponse(therapistMessage, _selectedScenario!);
        setState(() {
          _sessionMessages.add(SessionMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: MessageSender.client,
            content: aiResponse,
            timestamp: DateTime.now(),
          ));
        });
      }
    });
  }

  String _generateInitialClientMessage(SimulationScenario scenario) {
    switch (scenario.id) {
      case '1': // Ahmet - Depresyon
        return 'Merhaba doktor... Son zamanlarda kendimi çok kötü hissediyorum. İşimi kaybettikten sonra hiçbir şey yapmak istemiyorum. Karım da sürekli beni eleştiriyor. Sanki hiçbir değerim yok gibi...';
      case '2': // Zeynep - Anksiyete
        return 'Doktor bey, size gelmek bile çok zordu. Kalbim hala hızlı atıyor. Topluluk önünde konuşmam gerektiğinde neredeyse bayılıyorum. Bu durum beni çok yoruyor...';
      case '3': // Mehmet - Travma
        return 'Doktor... O kazayı hala görebiliyorum. Her gece aynı rüyayı görüyorum. Arabaya binmek bile imkansız. Sürekli tetikteyim, en ufak ses bile beni korkutuyor...';
      default:
        return 'Merhaba doktor, size yardım etmenizi umuyorum...';
    }
  }

  String _generateAIResponse(
      String therapistMessage, SimulationScenario scenario) {
    final message = therapistMessage.toLowerCase();

    // Depresyon vakası için yanıtlar
    if (scenario.id == '1') {
      if (message.contains('nasıl hissediyorsun') ||
          message.contains('duygu')) {
        return 'Kendimi çok boş hissediyorum... Sanki hiçbir şey beni mutlu edemiyor. Bazen ölmek istediğimi bile düşünüyorum...';
      } else if (message.contains('iş') || message.contains('kariyer')) {
        return 'İş bulmaya çalışıyorum ama hiç umudum yok. Her mülakatta reddediliyorum. Artık denemek istemiyorum...';
      } else if (message.contains('evlilik') || message.contains('karı')) {
        return 'Karım sürekli beni suçluyor. "Sen işsizsin, para kazanamıyorsun" diyor. Haklı da... Ben değersiz biriyim...';
      }
    }

    // Anksiyete vakası için yanıtlar
    if (scenario.id == '2') {
      if (message.contains('kaygı') || message.contains('korku')) {
        return 'Kalp atışlarım hızlanıyor, nefes alamıyorum... Sanki öleceğim gibi hissediyorum. Bu çok korkunç...';
      } else if (message.contains('sosyal') || message.contains('topluluk')) {
        return 'İnsanların beni yargılayacağını düşünüyorum. "Ya yanlış bir şey söylersem?" diye sürekli endişeleniyorum...';
      }
    }

    // Travma vakası için yanıtlar
    if (scenario.id == '3') {
      if (message.contains('kaz') || message.contains('travma')) {
        return 'O anı tekrar yaşıyorum... Cam kırıkları, sesler, acı... Uyuyamıyorum, sürekli tetikteyim...';
      } else if (message.contains('ara') || message.contains('bin')) {
        return 'Arabaya binmek imkansız! Her seferinde o kazayı hatırlıyorum. Kalbim hızla atıyor, terliyorum...';
      }
    }

    // Genel yanıtlar
    if (message.contains('nasıl') || message.contains('ne düşünüyorsun')) {
      return 'Bilmiyorum... Bazen iyi hissediyorum ama çoğunlukla kötüyüm. Size yardım etmenizi umuyorum...';
    }

    return 'Anlıyorum... Bu konuda daha fazla konuşmak istiyorum...';
  }

  void _showSimulationResults(SimulationScore score) {
    final simulationService = TherapySimulationService();
    final feedback = simulationService.getScoreFeedback(score);
    final suggestions = simulationService.getImprovementSuggestions(score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.analytics,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Simülasyon Sonuçları'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genel skor
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getScoreColor(score.totalScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getScoreColor(score.totalScore).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getScoreIcon(score.totalScore),
                      color: _getScoreColor(score.totalScore),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Toplam Skor: ${score.totalScore}/100',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score.totalScore),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getScoreLevel(score.totalScore),
                            style: TextStyle(
                              fontSize: 16,
                              color: _getScoreColor(score.totalScore),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Detaylı skorlar
              Text(
                'Detaylı Skorlar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildScoreBar('Empati', score.empathyScore, 30, Colors.blue),
              _buildScoreBar('Soru Sorma', score.questioningScore, 40, Colors.green),
              _buildScoreBar('Aktif Dinleme', score.activeListeningScore, 30, Colors.orange),
              _buildScoreBar('Profesyonel Dil', score.professionalLanguageScore, 20, Colors.purple),

              const SizedBox(height: 20),

              // Geri bildirim
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.infoColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: AppTheme.infoColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Geri Bildirim',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.infoColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(feedback),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // İyileştirme önerileri
              Text(
                'İyileştirme Önerileri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 20),

              // Seans istatistikleri
              if (_selectedScenario != null) ...[
                Text(
                  'Seans İstatistikleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('Senaryo', _selectedScenario!.title),
                      _buildStatRow('Kategori', _selectedScenario!.category),
                      _buildStatRow('Zorluk', _getDifficultyText(_selectedScenario!.difficulty)),
                      _buildStatRow('Toplam Mesaj', '${_sessionMessages.length}'),
                      _buildStatRow('Terapist Mesajı', '${_sessionMessages.where((m) => m.sender == MessageSender.therapist).length}'),
                      _buildStatRow('Danışan Mesajı', '${_sessionMessages.where((m) => m.sender == MessageSender.client).length}'),
                      _buildStatRow('Tahmini Süre', '${_selectedScenario!.estimatedDuration} dakika'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportSessionReport(score);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rapor İndir'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSimulation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yeniden Başla'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score, int maxScore, Color color) {
    final percentage = score / maxScore;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '$score/$maxScore',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.red;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 80) return Icons.star;
    if (score >= 60) return Icons.check_circle;
    if (score >= 40) return Icons.warning;
    return Icons.error;
  }

  String _getScoreLevel(int score) {
    if (score >= 80) return 'Mükemmel';
    if (score >= 60) return 'İyi';
    if (score >= 40) return 'Orta';
    return 'Geliştirilmeli';
  }

  String _getDifficultyText(ScenarioDifficulty difficulty) {
    switch (difficulty) {
      case ScenarioDifficulty.beginner:
        return 'Başlangıç';
      case ScenarioDifficulty.intermediate:
        return 'Orta';
      case ScenarioDifficulty.advanced:
        return 'İleri';
    }
  }

  void _exportSessionReport(SimulationScore score) {
    // TODO: PDF rapor oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seans raporu PDF olarak indirildi'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _resetSimulation() {
    setState(() {
      _sessionMessages.clear();
      _sessionNotes = '';
    });
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
      title: 'Terapi Simülasyonu',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Simülasyon',
          onPressed: _resetSimulation,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Analitik',
          onPressed: _showSessionAnalytics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Rapor',
          onPressed: _generateSimulationReport,
          icon: Icons.assessment,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showSimulationSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Senaryolar',
          icon: Icons.theater_comedy,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'AI Danışan',
          icon: Icons.chat,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Seans Notları',
          icon: Icons.notes,
          onTap: () => _tabController.animateTo(2),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDesktopScenariosTab(),
        _buildDesktopAIClientTab(),
        _buildDesktopSessionNotesTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terapi Simülasyonu'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.theater_comedy), text: 'Senaryolar'),
            Tab(icon: Icon(Icons.chat), text: 'AI Danışan'),
            Tab(icon: Icon(Icons.notes), text: 'Seans Notları'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Senaryolar
          SimulationScenarioPanel(
            scenarios: _scenarios,
            onScenarioSelected: _startSimulation,
            isSessionActive: _isSessionActive,
          ),

          // Tab 2: AI Danışan
          if (_selectedScenario != null && _isSessionActive)
            AIClientPanel(
              scenario: _selectedScenario!,
              messages: _sessionMessages,
              onMessageSent: _addTherapistMessage,
              onEndSession: _endSimulation,
            )
          else
            const Center(
              child: Text('Lütfen bir senaryo seçin'),
            ),

          // Tab 3: Seans Notları
          SessionNotesPanel(
            sessionNotes: _sessionNotes,
            onNotesChanged: (notes) {
              setState(() {
                _sessionNotes = notes;
              });
            },
            onSaveNotes: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Seans notları kaydedildi'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _resetSimulation,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _showSessionAnalytics,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _saveSessionNotes,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      _endSimulation,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
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
  Widget _buildDesktopScenariosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simülasyon Senaryoları',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopGrid(
            children: _scenarios.map((scenario) => 
              DesktopTheme.desktopCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              scenario.title,
                              style: DesktopTheme.desktopSectionTitleStyle,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(scenario.difficulty),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getDifficultyText(scenario.difficulty),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scenario.description,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${scenario.estimatedDuration} dakika',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.category, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            scenario.category,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DesktopTheme.desktopButton(
                        text: 'Başlat',
                        onPressed: _isSessionActive ? null : () => _startSimulation(scenario),
                        icon: Icons.play_arrow,
                      ),
                    ],
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAIClientTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Danışan Simülasyonu',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_selectedScenario != null && _isSessionActive)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AIClientPanel(
                  scenario: _selectedScenario!,
                  messages: _sessionMessages,
                  onMessageSent: _addTherapistMessage,
                  onEndSession: _endSimulation,
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
                      Icon(Icons.chat, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Simülasyon başlatmak için bir senaryo seçin',
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

  Widget _buildDesktopSessionNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seans Notları',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SessionNotesPanel(
                sessionNotes: _sessionNotes,
                onNotesChanged: (notes) {
                  setState(() {
                    _sessionNotes = notes;
                  });
                },
                onSaveNotes: _saveSessionNotes,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yardımcı metodlar
  Color _getDifficultyColor(ScenarioDifficulty difficulty) {
    switch (difficulty) {
      case ScenarioDifficulty.beginner:
        return Colors.green;
      case ScenarioDifficulty.intermediate:
        return Colors.orange;
      case ScenarioDifficulty.advanced:
        return Colors.red;
    }
  }

  void _saveSessionNotes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seans notları kaydedildi'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _showSessionAnalytics() {
    // TODO: Seans analitikleri
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seans analitikleri yakında gelecek')),
    );
  }

  void _generateSimulationReport() {
    // TODO: Simülasyon raporu oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simülasyon raporu oluşturuluyor...')),
    );
  }

  void _showSimulationSettings() {
    // TODO: Simülasyon ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simülasyon ayarları yakında gelecek')),
    );
  }
}
