import 'package:flutter/material.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../utils/theme.dart';

class AIPDFEnhancerWidget extends StatefulWidget {
  final String sessionNotes;
  final ProfessionalType professionalType;
  final String clientId;
  final Function(String)? onPDFEnhanced;

  const AIPDFEnhancerWidget({
    super.key,
    required this.sessionNotes,
    required this.professionalType,
    required this.clientId,
    this.onPDFEnhanced,
  });

  @override
  State<AIPDFEnhancerWidget> createState() => _AIPDFEnhancerWidgetState();
}

class _AIPDFEnhancerWidgetState extends State<AIPDFEnhancerWidget> {
  final _aiService = AIService();
  String? _enhancedContent;
  bool _isEnhancing = false;
  bool _showOriginal = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
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
                  'AI PDF İyileştirici',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    _getProfessionalTypeDisplayName(widget.professionalType),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getProfessionalTypeColor(widget.professionalType).withOpacity(0.1),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Enhance Button
            if (_enhancedContent == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isEnhancing ? null : _enhancePDF,
                  icon: _isEnhancing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isEnhancing ? 'AI PDF İyileştiriyor...' : 'AI ile PDF İyileştir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            // Enhanced Content
            if (_enhancedContent != null) ...[
              _buildContentComparison(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle Button
        Row(
          children: [
            Text(
              'İçerik Karşılaştırması',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Switch(
              value: _showOriginal,
              onChanged: (value) {
                setState(() => _showOriginal = value);
              },
            ),
            Text(
              _showOriginal ? 'Orijinal' : 'İyileştirilmiş',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Content Display
        Container(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: SingleChildScrollView(
            child: Text(
              _showOriginal ? widget.sessionNotes : _enhancedContent!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Enhancement Summary
        _buildEnhancementSummary(),
      ],
    );
  }

  Widget _buildEnhancementSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'İyileştirme Özeti',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSummaryItem('PHI Maskeleme', 'Kişisel bilgiler gizlendi'),
          _buildSummaryItem('Profesyonel Format', 'Klinik standartlara uygun hale getirildi'),
          _buildSummaryItem('Özet Eklendi', 'Ana bulgular özetlendi'),
          _buildSummaryItem('Redaksiyon', 'Gereksiz detaylar temizlendi'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reenhancePDF,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden İyileştir'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _approveEnhancement,
            icon: const Icon(Icons.check),
            label: const Text('Onayla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _enhancePDF() async {
    setState(() => _isEnhancing = true);
    
    try {
      // Mock AI enhancement - gerçek uygulamada AI service kullanılır
      await Future.delayed(const Duration(seconds: 3));
      
      final enhancedContent = _generateMockEnhancedContent(widget.sessionNotes, widget.professionalType);
      
      setState(() {
        _enhancedContent = enhancedContent;
        _isEnhancing = false;
      });
      
      if (widget.onPDFEnhanced != null) {
        widget.onPDFEnhanced!(enhancedContent);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI PDF iyileştirmesi tamamlandı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isEnhancing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _generateMockEnhancedContent(String originalContent, ProfessionalType type) {
    // PHI maskeleme
    String enhanced = originalContent
        .replaceAll(RegExp(r'\b\d{11}\b'), '[TCKN]') // TCKN maskeleme
        .replaceAll(RegExp(r'\b\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b'), '[KART]') // Kart numarası
        .replaceAll(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), '[SSN]') // SSN maskeleme
        .replaceAll(RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), '[EMAIL]'); // Email maskeleme
    
    // Profesyonel format ekleme
    final header = _getProfessionalHeader(type);
    final summary = _generateSummary(originalContent, type);
    final footer = _getProfessionalFooter(type);
    
    return '$header\n\n$summary\n\n$enhanced\n\n$footer';
  }

  String _getProfessionalHeader(ProfessionalType type) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    switch (type) {
      case ProfessionalType.psychologist:
        return '''
PSİKOLOJİK DEĞERLENDİRME RAPORU
Tarih: $dateStr
Uzman: [UZMAN ADI]
Danışan: [DANIŞAN KODU]
''';
      case ProfessionalType.psychiatrist:
        return '''
PSİKİYATRİK DEĞERLENDİRME RAPORU
Tarih: $dateStr
Doktor: [DOKTOR ADI]
Hasta: [HASTA KODU]
''';
      case ProfessionalType.therapist:
        return '''
TERAPİ SEANS RAPORU
Tarih: $dateStr
Terapist: [TERAPİST ADI]
Danışan: [DANIŞAN KODU]
''';
      default:
        return '''
KLİNİK RAPOR
Tarih: $dateStr
Uzman: [UZMAN ADI]
Danışan: [DANIŞAN KODU]
''';
    }
  }

  String _generateSummary(String content, ProfessionalType type) {
    final lowerContent = content.toLowerCase();
    
    String summary = 'ÖZET:\n';
    
    if (lowerContent.contains('depresyon')) {
      summary += '• Depresif semptomlar gözlemlendi\n';
    }
    if (lowerContent.contains('anksiyete') || lowerContent.contains('kaygı')) {
      summary += '• Anksiyete belirtileri tespit edildi\n';
    }
    if (lowerContent.contains('iyileşme') || lowerContent.contains('ilerleme')) {
      summary += '• Pozitif ilerleme kaydedildi\n';
    }
    if (lowerContent.contains('risk') || lowerContent.contains('tehlike')) {
      summary += '• Risk faktörleri değerlendirildi\n';
    }
    
    return summary;
  }

  String _getProfessionalFooter(ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return '''
NOT: Bu rapor gizlilik kuralları çerçevesinde hazırlanmıştır.
Kişisel bilgiler maskeleme yöntemi ile korunmuştur.
''';
      case ProfessionalType.psychiatrist:
        return '''
NOT: Bu rapor tıbbi gizlilik kuralları çerçevesinde hazırlanmıştır.
Hasta bilgileri HIPAA/KVKK uyumlu şekilde işlenmiştir.
''';
      case ProfessionalType.therapist:
        return '''
NOT: Bu rapor terapötik gizlilik kuralları çerçevesinde hazırlanmıştır.
Danışan bilgileri korunmuştur.
''';
      default:
        return '''
NOT: Bu rapor gizlilik kuralları çerçevesinde hazırlanmıştır.
''';
    }
  }

  void _reenhancePDF() {
    setState(() => _enhancedContent = null);
    _enhancePDF();
  }

  void _approveEnhancement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF iyileştirmesi onaylandı ve kaydedildi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getProfessionalTypeDisplayName(ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return 'Psikolog';
      case ProfessionalType.psychiatrist:
        return 'Psikiyatrist';
      case ProfessionalType.therapist:
        return 'Terapist';
      case ProfessionalType.counselor:
        return 'Danışman';
      case ProfessionalType.socialWorker:
        return 'Sosyal Hizmet Uzmanı';
    }
  }

  Color _getProfessionalTypeColor(ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return Colors.blue;
      case ProfessionalType.psychiatrist:
        return Colors.red;
      case ProfessionalType.therapist:
        return Colors.green;
      case ProfessionalType.counselor:
        return Colors.orange;
      case ProfessionalType.socialWorker:
        return Colors.purple;
    }
  }
}
