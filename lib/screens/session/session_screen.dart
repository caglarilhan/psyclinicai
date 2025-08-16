import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../services/ai_service.dart';
import '../../models/ai_response_models.dart';
import '../../widgets/session/session_note_editor.dart';
import '../../widgets/session/ai_summary_panel.dart';
import '../../widgets/session/pdf_export_panel.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final TextEditingController _noteController = TextEditingController();
  final AIService _aiService = AIService();
  
  SessionSummaryResponse? _aiSummary;
  bool _isGeneratingAI = false;
  bool _isExportingPDF = false;
  String? _aiError;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _generateAISummary() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce seans notu yazın'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingAI = true;
      _aiError = null;
    });

    try {
      // API anahtarı kontrolü
      final hasValidKey = await _aiService.hasValidApiKey();
      if (!hasValidKey) {
        _showApiKeyDialog();
        return;
      }

      // AI özeti oluştur
      final summary = await _aiService.generateSessionSummary(_noteController.text.trim());
      
      setState(() {
        _aiSummary = summary;
        _aiError = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('AI özeti başarıyla oluşturuldu'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } catch (e) {
      setState(() {
        _aiError = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI özeti hatası: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isGeneratingAI = false);
    }
  }

  void _showApiKeyDialog() {
    final apiKeyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OpenAI API Anahtarı Gerekli'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI özelliklerini kullanmak için OpenAI API anahtarınızı girmeniz gerekiyor.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'OpenAI API Anahtarı',
                hintText: 'sk-...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Text(
              'API anahtarınız güvenli bir şekilde cihazınızda saklanacaktır.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (apiKeyController.text.trim().isNotEmpty) {
                await _aiService.saveApiKey(apiKeyController.text.trim());
                Navigator.pop(context);
                
                // API anahtarı kaydedildikten sonra AI özetini oluştur
                _generateAISummary();
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce seans notu yazın'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isExportingPDF = true);

    try {
      // TODO: PDF export service
      await Future.delayed(const Duration(seconds: 2)); // Simülasyon

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF başarıyla oluşturuldu'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF export hatası: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isExportingPDF = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seans Notu + AI Özet'),
        actions: [
          // API durumu göstergesi
          FutureBuilder<bool>(
            future: _aiService.hasValidApiKey(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _showApiStatus(context),
                  tooltip: 'API Bağlantısı Aktif',
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.error, color: Colors.orange),
                  onPressed: () => _showApiKeyDialog(),
                  tooltip: 'API Anahtarı Gerekli',
                );
              }
            },
          ),
          // Klavye kısayolları bilgisi
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: () {
              _showKeyboardShortcuts(context);
            },
            tooltip: 'Klavye Kısayolları',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sol panel: Seans notu editörü
          Expanded(
            flex: 2,
            child: SessionNoteEditor(
              controller: _noteController,
              onGenerateAI: _generateAISummary,
              isGeneratingAI: _isGeneratingAI,
            ),
          ),

          // Sağ panel: AI özeti ve PDF export
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // AI Özeti Paneli
                  Expanded(
                    flex: 2,
                    child: AISummaryPanel(
                      summary: _aiSummary,
                      error: _aiError,
                      onRegenerate: _generateAISummary,
                      isGenerating: _isGeneratingAI,
                    ),
                  ),

                  // PDF Export Panel
                  Expanded(
                    flex: 1,
                    child: PDFExportPanel(
                      sessionNotes: _noteController.text,
                      aiSummary: _aiSummary,
                      clientName: 'Ahmet Yılmaz', // Mock data
                      therapistName: 'Dr. Ayşe Demir', // Mock data
                      clientInfo: {
                        'Yaş': '28',
                        'Cinsiyet': 'Erkek',
                        'Meslek': 'Mühendis',
                        'İlk Seans': '2024-01-15',
                      },
                      sessionMetrics: {
                        'Seans Süresi': '50 dakika',
                        'Mood Skoru': '6/10',
                        'Anksiyete Seviyesi': 'Orta',
                        'Ev Ödevi Tamamlanma': '%80',
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _noteController.text.trim().isNotEmpty ? _generateAISummary : null,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI Özeti'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showApiStatus(BuildContext context) {
    final status = _aiService.getRateLimitStatus();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Durumu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('API Bağlantısı', 'Aktif', Colors.green),
            _buildStatusRow('Kullanılan İstek', '${status['requestsUsed']}', Colors.blue),
            _buildStatusRow('Kalan İstek', '${status['requestsRemaining']}', Colors.blue),
            _buildStatusRow('Sıfırlama Süresi', '${status['timeUntilReset']} saniye', Colors.orange),
            _buildStatusRow('Rate Limit', status['isLimited'] ? 'Aşıldı' : 'Normal', 
                status['isLimited'] ? Colors.red : Colors.green),
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

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showKeyboardShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Klavye Kısayolları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AppConstants.keyboardShortcuts.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            );
          }).toList(),
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
}
