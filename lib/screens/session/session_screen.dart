import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/pdf_export_service.dart';
import '../../services/therapy_note_service.dart';

class SessionScreen extends StatefulWidget {
  final String sessionId;
  final String clientId;
  final String clientName;

  const SessionScreen({
    super.key,
    required this.sessionId,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _aiPromptController = TextEditingController();
  bool _isGeneratingAI = false;
  String _aiSummary = '';
  int _selectedPanelIndex = 0;
  
  // Seans durumu
  bool _isSessionActive = false;
  DateTime? _sessionStartTime;
  Duration _sessionDuration = Duration.zero;
  
  // Timer için
  late Timer _sessionTimer;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _sessionTimer.cancel();
    _notesController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _sessionStartTime = DateTime.now();
    });
    
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _sessionDuration = DateTime.now().difference(_sessionStartTime!);
        });
      }
    });
  }

  void _endSession() {
    setState(() {
      _isSessionActive = false;
    });
    _sessionTimer.cancel();
    
    // Seans sonlandırma dialog'u
    _showSessionEndDialog();
  }

  void _showSessionEndDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seans Sonlandırıldı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seans süresi: ${_formatDuration(_sessionDuration)}'),
            const SizedBox(height: 16),
            const Text('Seans notunu kaydetmek istiyor musunuz?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _saveSessionNotes();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _saveSessionNotes() async {
    final noteText = _notesController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilecek bir seans notu bulunamadı')),
      );
      return;
    }

    try {
      final therapyNoteService = context.read<TherapyNoteService>();
      await therapyNoteService.createEntry(
        sessionId: widget.sessionId,
        clinicianId: 'demo_clinician',
        clientId: widget.clientId,
        templateId: 'session_note',
        values: {
          'notes': noteText,
          'aiSummary': _aiSummary,
          'aiPrompt': _aiPromptController.text.trim(),
          'sessionDuration': _sessionDuration.inSeconds,
          'savedAt': DateTime.now().toIso8601String(),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seans notu kaydedildi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not kaydedilemedi: $e')),
      );
    }
  }

  Future<void> _generateAISummary() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce seans notu yazın')),
      );
      return;
    }

    setState(() {
      _isGeneratingAI = true;
    });

    // Simüle edilmiş AI işlemi
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _aiSummary = '''
🔍 **AI Özeti**

**Duygu Durumu:** ${_analyzeEmotion(_notesController.text)}
**Ana Tema:** ${_analyzeTheme(_notesController.text)}
**ICD Önerisi:** ${_suggestICD(_notesController.text)}
**Risk Faktörleri:** ${_analyzeRisk(_notesController.text)}
**Sonraki Seans Önerisi:** ${_suggestNextSession(_notesController.text)}

*Bu özet AI destekli olarak oluşturulmuştur. Klinik karar için değerlendirmeniz gerekir.*
''';
      _isGeneratingAI = false;
    });
  }

  String _analyzeEmotion(String text) {
    if (text.toLowerCase().contains('üzgün') || text.toLowerCase().contains('depresif')) {
      return 'Depresif duygu durumu';
    } else if (text.toLowerCase().contains('kaygı') || text.toLowerCase().contains('anksiyete')) {
      return 'Anksiyöz duygu durumu';
    } else if (text.toLowerCase().contains('öfke') || text.toLowerCase().contains('sinir')) {
      return 'Öfkeli duygu durumu';
    }
    return 'Nötr duygu durumu';
  }

  String _analyzeTheme(String text) {
    if (text.toLowerCase().contains('ilişki') || text.toLowerCase().contains('aile')) {
      return 'İlişki problemleri';
    } else if (text.toLowerCase().contains('iş') || text.toLowerCase().contains('kariyer')) {
      return 'İş/kariyer problemleri';
    } else if (text.toLowerCase().contains('travma') || text.toLowerCase().contains('geçmiş')) {
      return 'Travmatik deneyimler';
    }
    return 'Genel yaşam problemleri';
  }

  String _suggestICD(String text) {
    if (text.toLowerCase().contains('depresyon') || text.toLowerCase().contains('üzgün')) {
      return 'F32.1 - Orta depresif bozukluk';
    } else if (text.toLowerCase().contains('anksiyete') || text.toLowerCase().contains('kaygı')) {
      return 'F41.1 - Anksiyete bozukluğu';
    } else if (text.toLowerCase().contains('travma')) {
      return 'F43.1 - Travma sonrası stres bozukluğu';
    }
    return 'F99 - Belirtilmemiş mental bozukluk';
  }

  String _analyzeRisk(String text) {
    List<String> risks = [];
    if (text.toLowerCase().contains('intihar') || text.toLowerCase().contains('ölüm')) {
      risks.add('İntihar riski');
    }
    if (text.toLowerCase().contains('şiddet') || text.toLowerCase().contains('zarar')) {
      risks.add('Şiddet riski');
    }
    if (text.toLowerCase().contains('madde') || text.toLowerCase().contains('alkol')) {
      risks.add('Madde kullanımı');
    }
    
    return risks.isEmpty ? 'Acil risk tespit edilmedi' : risks.join(', ');
  }

  String _suggestNextSession(String text) {
    if (text.toLowerCase().contains('kriz') || text.toLowerCase().contains('acil')) {
      return '24-48 saat içinde takip seansı';
    } else if (text.toLowerCase().contains('iyileşme') || text.toLowerCase().contains('gelişme')) {
      return '1 hafta sonra rutin takip';
    }
    return '1-2 hafta sonra rutin takip';
  }

  Future<void> _exportToPDF() async {
    try {
      // PDF servisini import et
      final pdfService = PDFExportService();
      
      // PDF oluştur
      final pdfBytes = await pdfService.generateSessionPDF(
        clientName: widget.clientName,
        sessionId: widget.sessionId,
        sessionNotes: _notesController.text,
        aiSummary: _aiSummary,
        sessionDate: _sessionStartTime ?? DateTime.now(),
        sessionDuration: _sessionDuration,
        therapistName: 'Dr. Terapist', // TODO: Gerçek terapist adını al
      );
      
      // PDF'i yazdır
      await pdfService.printPDF(pdfBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF başarıyla oluşturuldu ve yazdırıcıya gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF oluşturulurken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Eksik metodlar
  void _clearNotes() {
    setState(() {
      _notesController.clear();
      _aiSummary = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notlar temizlendi'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Helper methods for extracting information from AI summary
  String _extractEmotionFromSummary() {
    // Simple extraction logic - can be improved with regex
    if (_aiSummary.toLowerCase().contains('üzgün') || _aiSummary.toLowerCase().contains('sad')) {
      return 'Üzgün';
    } else if (_aiSummary.toLowerCase().contains('mutlu') || _aiSummary.toLowerCase().contains('happy')) {
      return 'Mutlu';
    } else if (_aiSummary.toLowerCase().contains('kaygılı') || _aiSummary.toLowerCase().contains('anxious')) {
      return 'Kaygılı';
    } else if (_aiSummary.toLowerCase().contains('öfkeli') || _aiSummary.toLowerCase().contains('angry')) {
      return 'Öfkeli';
    }
    return 'Nötr';
  }

  String _extractThemeFromSummary() {
    if (_aiSummary.toLowerCase().contains('aile') || _aiSummary.toLowerCase().contains('family')) {
      return 'Aile İlişkileri';
    } else if (_aiSummary.toLowerCase().contains('iş') || _aiSummary.toLowerCase().contains('work')) {
      return 'İş Hayatı';
    } else if (_aiSummary.toLowerCase().contains('ilişki') || _aiSummary.toLowerCase().contains('relationship')) {
      return 'İlişki Sorunları';
    } else if (_aiSummary.toLowerCase().contains('travma') || _aiSummary.toLowerCase().contains('trauma')) {
      return 'Travma';
    }
    return 'Genel';
  }

  String _extractICDFromSummary() {
    // Extract ICD codes from summary
    RegExp icdRegex = RegExp(r'[A-Z]\d{2}\.\d+');
    Match? match = icdRegex.firstMatch(_aiSummary);
    return match?.group(0) ?? 'ICD-10 kodu bulunamadı';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.clientName[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clientName,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Seans ID: ${widget.sessionId}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Seans süresi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isSessionActive ? Icons.timer : Icons.timer_off,
                  size: 16,
                  color: _isSessionActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(_sessionDuration),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Seans kontrol butonları
          if (_isSessionActive)
            IconButton(
              onPressed: _endSession,
              icon: const Icon(Icons.stop_circle),
              tooltip: 'Seansı Sonlandır',
            )
          else
            IconButton(
              onPressed: _startSession,
              icon: const Icon(Icons.play_circle),
              tooltip: 'Seansı Başlat',
            ),
          IconButton(
            onPressed: _exportToPDF,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Export',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sol panel - Seans notu
          Expanded(
            flex: 2,
            child: _buildNotesPanel(),
          ),
          // Orta panel - AI özeti
          Expanded(
            flex: 1,
            child: _buildAIPanel(),
          ),
          // Sağ panel - Danışan bilgileri
          Expanded(
            flex: 1,
            child: _buildClientInfoPanel(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildNotesPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Seans Notu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _saveSessionNotes();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Not yazma alanı
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Seans notlarınızı buraya yazın...\n\nÖrnek:\n- Danışanın bugünkü ruh hali\n- Ana problemler\n- Kullanılan teknikler\n- Sonraki adımlar',
                  border: InputBorder.none,
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'AI Asistan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _generateAISummary,
                  icon: Icon(
                    _isGeneratingAI ? Icons.hourglass_empty : Icons.refresh,
                    color: Colors.blue,
                  ),
                  tooltip: 'AI Özeti Oluştur',
                ),
              ],
            ),
          ),
          // AI özeti
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isGeneratingAI
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('AI özeti oluşturuluyor...'),
                        ],
                      ),
                    )
                  : _aiSummary.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.psychology_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'AI özeti oluşturmak için\n"Yenile" butonuna tıklayın',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Text(
                            _aiSummary,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Danışan Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Danışan bilgileri
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('Kişisel Bilgiler', [
                    'Ad: ${widget.clientName}',
                    'ID: ${widget.clientId}',
                    'Seans Tarihi: ${DateTime.now().toString().split(' ')[0]}',
                    'Seans Saati: ${DateTime.now().toString().split(' ')[1].substring(0, 5)}',
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('Seans Durumu', [
                    'Durum: ${_isSessionActive ? "Aktif" : "Pasif"}',
                    'Başlangıç: ${_sessionStartTime?.toString().split(' ')[1].substring(0, 5) ?? "Başlatılmadı"}',
                    'Süre: ${_formatDuration(_sessionDuration)}',
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('Hızlı Erişim', [
                    'Önceki Seanslar',
                    'Tedavi Planı',
                    'İlaç Listesi',
                    'Acil İletişim',
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $item',
              style: const TextStyle(fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Klavye kısayolları bilgisi
          Expanded(
            child: Text(
              '💡 Kısayollar: Ctrl+S (Kaydet) | Ctrl+P (PDF) | Ctrl+N (Yeni)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          // Hızlı aksiyonlar
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today),
            label: const Text('Randevu'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.medical_services),
            label: const Text('Reçete'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.flag),
            label: const Text('Flag'),
          ),
        ],
      ),
    );
  }
}
