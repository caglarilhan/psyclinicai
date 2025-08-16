import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
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
  String _aiSummary = '';
  bool _isGeneratingAI = false;
  bool _isExportingPDF = false;

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

    setState(() => _isGeneratingAI = true);

    try {
      // TODO: AI service entegrasyonu
      await Future.delayed(const Duration(seconds: 3)); // Simülasyon

      setState(() {
        _aiSummary = '''
Duygu: Üzgün ve umutsuz
Tema: Değersizlik hissi ve sosyal izolasyon
ICD Önerisi: 6B00.0 (Depresif bozukluk)
Risk Seviyesi: Orta
Önerilen Müdahale: CBT + Sosyal destek grupları
        '''
            .trim();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('AI özeti oluşturuldu'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } catch (e) {
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
                      onRegenerate: _generateAISummary,
                      isGenerating: _isGeneratingAI,
                    ),
                  ),

                  // PDF Export Paneli
                  Expanded(
                    flex: 1,
                    child: PDFExportPanel(
                      onExport: _exportToPDF,
                      isExporting: _isExportingPDF,
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
