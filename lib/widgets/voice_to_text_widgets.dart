import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/voice_to_text_service.dart';
import '../utils/theme.dart';

// Voice Recording Widget
class VoiceRecordingWidget extends StatefulWidget {
  const VoiceRecordingWidget({super.key});

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget> {
  final VoiceToTextService _voiceService = VoiceToTextService();
  String _currentText = '';
  Map<String, dynamic>? _currentInsights;

  @override
  void initState() {
    super.initState();
    _voiceService.loadRecordingSessions();
    
    // Listen to text stream
    _voiceService.textStream.listen((text) {
      setState(() {
        _currentText = text;
      });
    });
    
    // Listen to insights stream
    _voiceService.insightsStream.listen((insights) {
      setState(() {
        _currentInsights = insights;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sesli Not Alma',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Recording button
            Center(
              child: GestureDetector(
                onTap: _voiceService.isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _voiceService.isRecording ? Colors.red : AppTheme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: (_voiceService.isRecording ? Colors.red : AppTheme.primaryColor).withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _voiceService.isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recording status
            Center(
              child: Text(
                _voiceService.isRecording 
                    ? 'Kayıt yapılıyor...' 
                    : _voiceService.isProcessing 
                        ? 'İşleniyor...' 
                        : 'Kayıt başlatmak için tıklayın',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            
            if (_voiceService.isRecording) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            
            if (_voiceService.isProcessing) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Current text
            if (_currentText.isNotEmpty) ...[
              Text(
                'Mevcut Metin:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_currentText),
              ),
            ],
            
            // AI Insights
            if (_currentInsights != null) ...[
              const SizedBox(height: 16),
              _buildInsightsCard(_currentInsights!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(Map<String, dynamic> insights) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'AI Analizi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sentiment
            _buildInsightItem('Duygu Durumu', insights['sentiment'], Icons.mood),
            
            // Keywords
            if (insights['keywords'].isNotEmpty)
              _buildInsightItem('Anahtar Kelimeler', insights['keywords'].join(', '), Icons.tag),
            
            // Topics
            if (insights['topics'].isNotEmpty)
              _buildInsightItem('Konular', insights['topics'].join(', '), Icons.topic),
            
            // Risk Level
            _buildInsightItem('Risk Seviyesi', insights['riskLevel'], Icons.warning),
            
            // Suggestions
            if (insights['suggestions'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Öneriler:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...insights['suggestions'].map((suggestion) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(suggestion)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    await _voiceService.startRecording();
  }

  Future<void> _stopRecording() async {
    await _voiceService.stopRecording();
  }
}

// Voice Sessions Browser Widget
class VoiceSessionsBrowserWidget extends StatefulWidget {
  const VoiceSessionsBrowserWidget({super.key});

  @override
  State<VoiceSessionsBrowserWidget> createState() => _VoiceSessionsBrowserWidgetState();
}

class _VoiceSessionsBrowserWidgetState extends State<VoiceSessionsBrowserWidget> {
  final VoiceToTextService _voiceService = VoiceToTextService();
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    setState(() {
      _sessions = _voiceService.recordedSessions.map((session) {
        return json.decode(session);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sesli Not Geçmişi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _clearAllSessions,
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Tümünü Temizle',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              '${_sessions.length} kayıt bulundu',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 16),
            
            // Sessions list
            Expanded(
              child: _sessions.isEmpty
                  ? const Center(
                      child: Text('Henüz sesli not kaydı yok'),
                    )
                  : ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        return _buildSessionItem(session);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    final text = session['text'] as String? ?? '';
    final insights = session['insights'] as Map<String, dynamic>? ?? {};
    final timestamp = session['timestamp'] as String? ?? '';
    final sentiment = insights['sentiment'] as String? ?? 'N/A';
    final riskLevel = insights['riskLevel'] as String? ?? 'N/A';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSentimentColor(sentiment),
          child: Icon(
            _getSentimentIcon(sentiment),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          text.length > 50 ? '${text.substring(0, 50)}...' : text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duygu: $sentiment | Risk: $riskLevel'),
            Text(
              'Tarih: ${_formatDate(timestamp)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: const Text('Görüntüle'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Text('Sil'),
            ),
          ],
          onSelected: (value) => _handleSessionAction(value, session),
        ),
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'Pozitif':
        return Colors.green;
      case 'Negatif':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment) {
      case 'Pozitif':
        return Icons.sentiment_satisfied;
      case 'Negatif':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Geçersiz tarih';
    }
  }

  void _handleSessionAction(String action, Map<String, dynamic> session) {
    switch (action) {
      case 'view':
        _viewSession(session);
        break;
      case 'delete':
        _deleteSession(session);
        break;
    }
  }

  void _viewSession(Map<String, dynamic> session) {
    final text = session['text'] as String? ?? '';
    final insights = session['insights'] as Map<String, dynamic>? ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sesli Not Detayı'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Metin:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(text),
              ),
              const SizedBox(height: 16),
              Text(
                'AI Analizi:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...insights.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(entry.value.toString()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Future<void> _deleteSession(Map<String, dynamic> session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kayıt Sil'),
        content: const Text('Bu sesli notu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _voiceService.deleteSession(session['id']);
      _loadSessions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesli not silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _clearAllSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Kayıtları Temizle'),
        content: const Text('Tüm sesli notları silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Temizle'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _voiceService.clearAllSessions();
      _loadSessions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tüm sesli notlar temizlendi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

// Voice Analytics Widget
class VoiceAnalyticsWidget extends StatefulWidget {
  const VoiceAnalyticsWidget({super.key});

  @override
  State<VoiceAnalyticsWidget> createState() => _VoiceAnalyticsWidgetState();
}

class _VoiceAnalyticsWidgetState extends State<VoiceAnalyticsWidget> {
  final VoiceToTextService _voiceService = VoiceToTextService();
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _stats = _voiceService.getVoiceStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sesli Not Analizi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Total sessions
            _buildStatItem(
              'Toplam Kayıt',
              '${_stats['totalSessions'] ?? 0}',
              Icons.history,
              Colors.blue,
            ),
            
            // Total duration
            _buildStatItem(
              'Toplam Süre',
              '${_stats['totalDuration'] ?? 0} dakika',
              Icons.timer,
              Colors.green,
            ),
            
            // Average sentiment
            _buildStatItem(
              'Ortalama Duygu',
              _stats['averageSentiment'] ?? 'N/A',
              Icons.mood,
              _getSentimentColor(_stats['averageSentiment'] ?? 'Nötr'),
            ),
            
            // Most common topics
            if (_stats['mostCommonTopics'] != null && (_stats['mostCommonTopics'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'En Çok Konuşulan Konular:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...(_stats['mostCommonTopics'] as List).map((topic) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.topic, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(topic),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'Pozitif':
        return Colors.green;
      case 'Negatif':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
