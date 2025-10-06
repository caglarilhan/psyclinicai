import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../services/pdf_export_service.dart';
import '../../services/audit_log_service.dart';
import '../../utils/access_control.dart';
import '../../utils/theme.dart';
import '../../models/ai_response_models.dart';

class PDFExportPanel extends StatefulWidget {
  final String sessionNotes;
  final SessionSummaryResponse? aiSummary;
  final String? clientName;
  final String? therapistName;
  final Map<String, dynamic>? clientInfo;
  final Map<String, dynamic>? sessionMetrics;

  const PDFExportPanel({
    super.key,
    required this.sessionNotes,
    this.aiSummary,
    this.clientName,
    this.therapistName,
    this.clientInfo,
    this.sessionMetrics,
  });

  @override
  State<PDFExportPanel> createState() => _PDFExportPanelState();
}

class _PDFExportPanelState extends State<PDFExportPanel> {
  final PDFExportService _pdfService = PDFExportService();
  bool _isGeneratingPDF = false;
  bool _isOpeningPDF = false;
  bool _isSharingPDF = false;
  File? _generatedPDF;
  String? _error;

  late final TextEditingController _notesController;
  final List<Uint8List> _attachments = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'PDF Export',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Content
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isGeneratingPDF) {
      return _buildGeneratingState(context);
    } else if (_error != null) {
      return _buildErrorState(context);
    } else if (_generatedPDF != null) {
      return _buildSuccessState(context);
    } else {
      return _buildInitialState(context);
    }
  }

  Widget _buildInitialState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seans notlarınızı profesyonel PDF raporu olarak dışa aktarın',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        
        const SizedBox(height: 20),

        // Manual notes editor
        Text(
          'Seans Notları',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Notlarınızı buraya yazın veya yapıştırın...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),

        // Quick templates
        Text(
          'Hazır Şablonlar',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _presetChip('SOAP', _soapTemplate()),
            _presetChip('CBT', _cbtTemplate()),
            _presetChip('EMDR', _emdrTemplate()),
            _presetChip('Aile Seansı', _familyTemplate()),
            _presetChip('Kriz Müdahalesi', _crisisTemplate()),
          ],
        ),
        const SizedBox(height: 16),

        // Attachments row
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Fotoğraf / Görsel Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            if (_attachments.isNotEmpty)
              Text('${_attachments.length} görsel eklendi',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Export Options
        _buildExportOption(
          context,
          icon: Icons.description,
          title: 'Seans Raporu',
          description: 'Seans notları, AI özeti ve ekler ile birlikte',
          onTap: _generateSessionReport,
        ),
        
        const SizedBox(height: 12),
        
        _buildExportOption(
          context,
          icon: Icons.medical_services,
          title: 'Tedavi Planı',
          description: 'Tanı, hedefler ve müdahaleler (yakında)',
          onTap: () => _showComingSoon('Tedavi Planı'),
        ),
        
        const SizedBox(height: 12),
        
        _buildExportOption(
          context,
          icon: Icons.trending_up,
          title: 'İlerleme Raporu',
          description: 'Seans geçmişi ve ilerleme metrikleri (yakında)',
          onTap: () => _showComingSoon('İlerleme Raporu'),
        ),
        
        const SizedBox(height: 20),
        
        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.infoColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PDF\'ler cihazınıza kaydedilir ve paylaşılabilir',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.infoColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _presetChip(String label, String content) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.note_add, size: 18),
      backgroundColor: AppTheme.infoColor.withValues(alpha: 0.08),
      onPressed: () {
        setState(() {
          _notesController.text = content;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$label" şablonu uygulandı'),
            backgroundColor: AppTheme.infoColor,
          ),
        );
      },
    );
  }

  String _soapTemplate() =>
      'S: Danışan son hafta yoğun kaygı ve uyku sorunları bildirdi.\n'
      'O: Seans boyunca huzursuzluk, nefes egzersizleri ile kısmi rahatlama.\n'
      'A: Yaygın anksiyete belirtileri, bilişsel çarpıtmalar gözlendi.\n'
      'P: Günlük 2x nefes egzersizi, düşünce kaydı, bir hafta sonra kontrol.';

  String _cbtTemplate() =>
      'Hedef: Kaygı yönetimi ve işlevsel düşünceleri artırma.\n'
      'Teknik: Düşünce-duygu-davranış zinciri, bilişsel yeniden yapılandırma.\n'
      'Ev Ödevi: Düşünce kaydı formu (en az 3 kayıt), 4-7-8 nefes.';

  String _emdrTemplate() =>
      'Hedef Anı: Son trafik kazası anısı (SUD: 7).\n'
      'Olumsuz İnanç: “Kontrolde değilim”.\n'
      'Pozitif İnanç: “Güvendeyim ve yönetebilirim”.\n'
      'Prosedür: BLS ile 6 set, SUD 7→3, VoC 3→5.';

  String _familyTemplate() =>
      'Katılımcılar: Danışan + ebeveynler.\n'
      'Odak: İletişim kalıpları, sınır koyma, rol çatışmaları.\n'
      'Müdahale: Yansıtıcı dinleme, ben dili, hafta içi 2 aile rutini.';

  String _crisisTemplate() =>
      'Durum: Akut panik atağı sonrası başvuru.\n'
      'Risk: İntihar düşüncesi yok, zarar verme yok.\n'
      'Plan: Güvenlik planı, tetikleyici yönetimi, kısa nefes egzersizleri.';

  Widget _buildGeneratingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'PDF oluşturuluyor...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen bekleyin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF başarıyla oluşturuldu!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _generatedPDF!.path.split('/').last,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isOpeningPDF ? null : _openPDF,
                icon: _isOpeningPDF
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.open_in_new),
                label: Text(_isOpeningPDF ? 'Açılıyor...' : 'PDF\'i Aç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSharingPDF ? null : _sharePDF,
                icon: _isSharingPDF
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.share),
                label: Text(_isSharingPDF ? 'Paylaşılıyor...' : 'Paylaş'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // New PDF button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _resetState,
            icon: const Icon(Icons.add),
            label: const Text('Yeni PDF Oluştur'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: AppTheme.errorColor,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'PDF oluşturulamadı',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.errorColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Bilinmeyen bir hata oluştu',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _resetState,
          icon: const Icon(Icons.refresh),
          label: const Text('Tekrar Dene'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Generate Session Report
  Future<void> _generateSessionReport() async {
    setState(() {
      _isGeneratingPDF = true;
      _error = null;
    });

    try {
      // PDF oluştur
      final pdfBytes = await _pdfService.generateSessionPDF(
        clientName: widget.clientName ?? 'Bilinmeyen Danışan',
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : widget.sessionNotes,
        aiSummary: widget.aiSummary?.recommendedIntervention ?? '',
        sessionDate: DateTime.now(),
        sessionDuration: const Duration(minutes: 50),
        therapistName: widget.therapistName ?? 'Terapist',
        attachments: _attachments,
      );

      // PDF'i dosyaya kaydet
      final fileName = 'seans_raporu_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = await _pdfService.savePDFToFile(pdfBytes, fileName);
      // audit: generate
      unawaited(AuditLogService().insertLog(
        action: 'pdf.generate',
        actor: widget.therapistName ?? 'unknown',
        target: (widget.clientName ?? 'unknown') + '|' + fileName,
        metadataJson: '{"attachments": ${_attachments.length}}',
      ));
      
      setState(() {
        _generatedPDF = File(filePath);
        _isGeneratingPDF = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF başarıyla oluşturuldu: ${fileName}.pdf'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isGeneratingPDF = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF oluşturma hatası: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title PDF çıktısı yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  // Open PDF
  Future<void> _openPDF() async {
    if (_generatedPDF == null) return;

    setState(() {
      _isOpeningPDF = true;
    });

    try {
      // PDF'i açmak için printing paketi kullan
      await _pdfService.printPDF(await _generatedPDF!.readAsBytes());
      // audit: open
      final actor = widget.therapistName ?? 'unknown';
      final target = (widget.clientName ?? 'unknown') + '|' + (_generatedPDF!.path.split('/').last);
      unawaited(AuditLogService().insertLog(
        action: 'pdf.open',
        actor: actor,
        target: target,
        metadataJson: '{}',
      ));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF açılıyor...'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF açılamadı: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isOpeningPDF = false;
      });
    }
  }

  // Share PDF (using share_plus directly)
  Future<void> _sharePDF() async {
    if (_generatedPDF == null) return;

    setState(() {
      _isSharingPDF = true;
    });

    try {
      // Role check: varsayılan rol therapist, gerçek kimlik yönetimine bağlanabilir
      const currentRole = AccessControl.roleTherapist;
      if (!AccessControl.isAllowed(currentRole, AccessControl.actPdfShare)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bu eylem için yetkiniz yok'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      await Share.shareXFiles([XFile(_generatedPDF!.path)], text: 'PsyClinicAI PDF');
      // audit: share
      final actor = widget.therapistName ?? 'unknown';
      final target = (widget.clientName ?? 'unknown') + '|' + (_generatedPDF!.path.split('/').last);
      unawaited(AuditLogService().insertLog(
        action: 'pdf.share',
        actor: actor,
        target: target,
        metadataJson: '{"method": "share_plus"}',
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF paylaşılamadı: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isSharingPDF = false;
      });
    }
  }

  // Reset state
  void _resetState() {
    setState(() {
      _generatedPDF = null;
      _error = null;
      _isGeneratingPDF = false;
      _isOpeningPDF = false;
      _isSharingPDF = false;
      _attachments.clear();
      _notesController.text = widget.sessionNotes;
    });
  }

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.sessionNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result == null) return;
      final added = <Uint8List>[];
      for (final f in result.files) {
        if (f.bytes != null) {
          added.add(f.bytes!);
        } else if (f.path != null) {
          added.add(await File(f.path!).readAsBytes());
        }
      }
      if (added.isNotEmpty) {
        setState(() {
          _attachments.addAll(added);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görsel seçilemedi: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
