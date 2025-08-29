import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../models/session_models.dart';
import '../../services/session_service.dart';
import '../../services/ai_service.dart';
import '../../widgets/session/session_notes_editor.dart';
import '../../widgets/session/ai_summary_widget.dart';
import '../../widgets/session/client_info_panel.dart';
import '../../widgets/session/session_timeline.dart';
import '../../widgets/session/emotion_tracker.dart';
import '../../widgets/session/goal_progress_tracker.dart';
import '../../widgets/session/homework_assignment.dart';
import '../../widgets/session/next_session_planner.dart';

class SessionManagementScreen extends StatefulWidget {
  final String? sessionId;
  final String? clientId;

  const SessionManagementScreen({
    super.key,
    this.sessionId,
    this.clientId,
  });

  @override
  State<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final SessionService _sessionService = SessionService();
  final AIService _aiService = AIService();
  
  bool _isLoading = true;
  Session? _currentSession;
  Client? _currentClient;
  List<Session> _clientSessions = [];
  List<SessionNote> _sessionNotes = [];
  AISummary? _aiSummary;
  bool _isSaving = false;
  bool _isGeneratingSummary = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _goalsController = TextEditingController();
  final _homeworkController = TextEditingController();
  final _nextSessionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.sessionId != null) {
        _currentSession = await _sessionService.getSession(widget.sessionId!);
        _sessionNotes = await _sessionService.getSessionNotes(widget.sessionId!);
        _aiSummary = await _sessionService.getAISummary(widget.sessionId!);
      }
      
      if (widget.clientId != null) {
        _currentClient = await _sessionService.getClient(widget.clientId!);
        _clientSessions = await _sessionService.getClientSessions(widget.clientId!);
      }
      
      if (_currentSession != null) {
        _titleController.text = _currentSession!.title;
        _notesController.text = _currentSession!.notes;
        _goalsController.text = _currentSession!.goals.join('\n');
        _homeworkController.text = _currentSession!.homework;
        _nextSessionController.text = _currentSession!.nextSessionPlan;
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    _goalsController.dispose();
    _homeworkController.dispose();
    _nextSessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentSession?.title ?? 'Yeni Seans'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note), text: 'Seans Notları'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Özet'),
            Tab(icon: Icon(Icons.person), text: 'Danışan Bilgileri'),
            Tab(icon: Icon(Icons.timeline), text: 'Seans Geçmişi'),
            Tab(icon: Icon(Icons.emoji_emotions), text: 'Duygu Takibi'),
            Tab(icon: Icon(Icons.flag), text: 'Hedef & Ödev'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveSession,
            tooltip: 'Seansı Kaydet',
          ),
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: _isGeneratingSummary ? null : _generateAISummary,
            tooltip: 'AI Özet Oluştur',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
            tooltip: 'Daha Fazla',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Seans verileri yükleniyor...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Seans Notları Tab'ı
                _buildSessionNotesTab(),
                
                // AI Özet Tab'ı
                _buildAISummaryTab(),
                
                // Danışan Bilgileri Tab'ı
                _buildClientInfoTab(),
                
                // Seans Geçmişi Tab'ı
                _buildSessionHistoryTab(),
                
                // Duygu Takibi Tab'ı
                _buildEmotionTrackingTab(),
                
                // Hedef & Ödev Tab'ı
                _buildGoalsHomeworkTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveSession,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'Kaydediliyor...' : 'Seansı Kaydet'),
      ),
    );
  }

  // Seans Notları Tab'ı
  Widget _buildSessionNotesTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seans Başlığı
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Seans Başlığı',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.title),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Seans Notları Editörü
          Expanded(
            child: SessionNotesEditor(
              controller: _notesController,
              onContentChanged: (content) {
                // Notlar değiştiğinde otomatik kaydetme
                _autoSaveNotes();
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Hızlı Notlar
          _buildQuickNotesSection(),
        ],
      ),
    );
  }

  // AI Özet Tab'ı
  Widget _buildAISummaryTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Özet Widget'ı
          if (_aiSummary != null) ...[
            AISummaryWidget(summary: _aiSummary!),
            const SizedBox(height: 20),
          ],
          
          // AI Özet Oluşturma Butonu
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingSummary ? null : _generateAISummary,
              icon: _isGeneratingSummary
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGeneratingSummary 
                  ? 'AI Özet Oluşturuluyor...' 
                  : 'AI Özet Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // AI Özellikleri
          _buildAIFeaturesSection(),
        ],
      ),
    );
  }

  // Danışan Bilgileri Tab'ı
  Widget _buildClientInfoTab() {
    if (_currentClient == null) {
      return const Center(
        child: Text('Danışan bilgileri bulunamadı'),
      );
    }
    
    return ClientInfoPanel(
      client: _currentClient!,
      onClientUpdated: _loadSessionData,
    );
  }

  // Seans Geçmişi Tab'ı
  Widget _buildSessionHistoryTab() {
    return SessionTimeline(
      sessions: _clientSessions,
      currentSessionId: _currentSession?.id,
      onSessionSelected: (sessionId) {
        // Seans seçildiğinde yeni seans yükle
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SessionManagementScreen(
              sessionId: sessionId,
              clientId: widget.clientId,
            ),
          ),
        );
      },
    );
  }

  // Duygu Takibi Tab'ı
  Widget _buildEmotionTrackingTab() {
    return EmotionTracker(
      sessionId: _currentSession?.id,
      onEmotionUpdated: _loadSessionData,
    );
  }

  // Hedef & Ödev Tab'ı
  Widget _buildGoalsHomeworkTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hedefler
          Text(
            'Seans Hedefleri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _goalsController,
            decoration: InputDecoration(
              hintText: 'Bu seansta hedeflenen değişiklikler...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 4,
          ),
          
          const SizedBox(height: 24),
          
          // Ödevler
          Text(
            'Ev Ödevi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _homeworkController,
            decoration: InputDecoration(
              hintText: 'Danışanın yapması gereken ödevler...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 4,
          ),
          
          const SizedBox(height: 24),
          
          // Sonraki Seans Planı
          Text(
            'Sonraki Seans Planı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nextSessionController,
            decoration: InputDecoration(
              hintText: 'Bir sonraki seansta ele alınacak konular...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 3,
          ),
          
          const SizedBox(height: 24),
          
          // Hedef İlerleme Takibi
          if (_currentClient != null) ...[
            GoalProgressTracker(
              clientId: _currentClient!.id,
              sessionId: _currentSession?.id,
            ),
            const SizedBox(height: 20),
            
            // Ödev Takibi
            HomeworkAssignment(
              clientId: _currentClient!.id,
              sessionId: _currentSession?.id,
            ),
          ],
        ],
      ),
    );
  }

  // Hızlı Notlar Bölümü
  Widget _buildQuickNotesSection() {
    final quickNotes = [
      'Danışan bugün çok endişeli görünüyordu',
      'Hedefler konusunda ilerleme kaydedildi',
      'Ev ödevleri tamamlanmamış',
      'Aile desteği artıyor',
      'İlaç yan etkileri azaldı',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Notlar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickNotes.map((note) => ActionChip(
            label: Text(note),
            onPressed: () => _addQuickNote(note),
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            labelStyle: TextStyle(color: AppTheme.primaryColor),
          )).toList(),
        ),
      ],
    );
  }

  // AI Özellikleri Bölümü
  Widget _buildAIFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Destekli Özellikler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildAIFeatureItem(
            'Otomatik Özet',
            'Seans notlarından AI destekli özet oluşturur',
            Icons.summarize,
          ),
          _buildAIFeatureItem(
            'Duygu Analizi',
            'Notlardan duygu durumu analiz eder',
            Icons.emoji_emotions,
          ),
          _buildAIFeatureItem(
            'Hedef Takibi',
            'Hedef ilerlemesini otomatik değerlendirir',
            Icons.flag,
          ),
          _buildAIFeatureItem(
            'Sonraki Seans Önerisi',
            'Bir sonraki seansta ele alınacak konuları önerir',
            Icons.lightbulb,
          ),
        ],
      ),
    );
  }

  Widget _buildAIFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hızlı not ekleme
  void _addQuickNote(String note) {
    final currentNotes = _notesController.text;
    if (currentNotes.isNotEmpty) {
      _notesController.text = '$currentNotes\n\n• $note';
    } else {
      _notesController.text = '• $note';
    }
    _autoSaveNotes();
  }

  // Otomatik not kaydetme
  void _autoSaveNotes() {
    // Debounce ile otomatik kaydetme
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentSession != null) {
        _saveSessionNotes();
      }
    });
  }

  // Not kaydetme
  Future<void> _saveSessionNotes() async {
    if (_currentSession == null) return;
    
    try {
      final updatedSession = _currentSession!.copyWith(
        notes: _notesController.text,
        updatedAt: DateTime.now(),
      );
      
      await _sessionService.updateSession(updatedSession);
      _currentSession = updatedSession;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notlar kaydedilirken hata: $e')),
        );
      }
    }
  }

  // Seans kaydetme
  Future<void> _saveSession() async {
    setState(() => _isSaving = true);
    
    try {
      if (_currentSession == null) {
        // Yeni seans oluştur
        final newSession = Session(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          clientId: widget.clientId ?? '',
          title: _titleController.text,
          notes: _notesController.text,
          goals: _goalsController.text.split('\n').where((g) => g.isNotEmpty).toList(),
          homework: _homeworkController.text,
          nextSessionPlan: _nextSessionController.text,
          sessionDate: DateTime.now(),
          duration: const Duration(minutes: 60),
          status: SessionStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _sessionService.createSession(newSession);
        _currentSession = newSession;
      } else {
        // Mevcut seansı güncelle
        final updatedSession = _currentSession!.copyWith(
          title: _titleController.text,
          notes: _notesController.text,
          goals: _goalsController.text.split('\n').where((g) => g.isNotEmpty).toList(),
          homework: _homeworkController.text,
          nextSessionPlan: _nextSessionController.text,
          updatedAt: DateTime.now(),
        );
        
        await _sessionService.updateSession(updatedSession);
        _currentSession = updatedSession;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seans başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seans kaydedilirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // AI Özet oluşturma
  Future<void> _generateAISummary() async {
    if (_currentSession == null || _notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce seans notları yazın'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isGeneratingSummary = true);
    
    try {
      final summary = await _aiService.generateSessionSummary(
        sessionNotes: _notesController.text,
        clientGoals: _goalsController.text,
        previousSessions: _clientSessions,
      );
      
      if (summary != null) {
        await _sessionService.saveAISummary(_currentSession!.id, summary);
        _aiSummary = summary;
        setState(() {});
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI özet başarıyla oluşturuldu'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI özet oluşturulurken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isGeneratingSummary = false);
    }
  }

  // Daha fazla seçenekler
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('PDF Olarak İndir'),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Paylaş'),
              onTap: () {
                Navigator.pop(context);
                _shareSession();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Arşivle'),
              onTap: () {
                Navigator.pop(context);
                _archiveSession();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                _deleteSession();
              },
            ),
          ],
        ),
      ),
    );
  }

  // PDF export
  void _exportToPDF() {
    // TODO: PDF export implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export özelliği yakında gelecek')),
    );
  }

  // Paylaş
  void _shareSession() {
    // TODO: Paylaşım implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşım özelliği yakında gelecek')),
    );
  }

  // Arşivle
  void _archiveSession() {
    // TODO: Arşivleme implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arşivleme özelliği yakında gelecek')),
    );
  }

  // Sil
  void _deleteSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seansı Sil'),
        content: const Text('Bu seansı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (_currentSession != null) {
                await _sessionService.deleteSession(_currentSession!.id);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
