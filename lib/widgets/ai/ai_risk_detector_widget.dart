import 'package:flutter/material.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../utils/theme.dart';

class AIRiskDetectorWidget extends StatefulWidget {
  final String sessionNotes;
  final ProfessionalType professionalType;
  final Function(RiskAssessment)? onRiskAssessed;

  const AIRiskDetectorWidget({
    super.key,
    required this.sessionNotes,
    required this.professionalType,
    this.onRiskAssessed,
  });

  @override
  State<AIRiskDetectorWidget> createState() => _AIRiskDetectorWidgetState();
}

class _AIRiskDetectorWidgetState extends State<AIRiskDetectorWidget> {
  final _aiService = AIService();
  RiskAssessment? _assessment;
  bool _isAnalyzing = false;

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
                  Icons.security,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Risk Dedektörü',
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
            
            // Analyze Button
            if (_assessment == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeRisk,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isAnalyzing ? 'AI Risk Analizi Yapıyor...' : 'AI ile Risk Analizi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            // Risk Assessment Content
            if (_assessment != null) ...[
              _buildRiskAssessmentContent(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessmentContent() {
    final assessment = _assessment!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk Level Alert
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getRiskLevelColor(assessment.riskLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getRiskLevelColor(assessment.riskLevel).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                _getRiskLevelIcon(assessment.riskLevel),
                color: _getRiskLevelColor(assessment.riskLevel),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Seviyesi: ${assessment.riskLevel}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRiskLevelColor(assessment.riskLevel),
                      ),
                    ),
                    Text(
                      'Risk Skoru: ${(assessment.riskScore * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getRiskLevelColor(assessment.riskLevel),
                      ),
                    ),
                  ],
                ),
              ),
              if (assessment.requiresImmediateAttention)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACİL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Risk Factors
        _buildSection(
          'Risk Faktörleri',
          Icons.warning,
          assessment.riskFactors,
          Colors.red,
        ),
        
        const SizedBox(height: 12),
        
        // Protective Factors
        _buildSection(
          'Koruyucu Faktörler',
          Icons.shield,
          assessment.protectiveFactors,
          Colors.green,
        ),
        
        const SizedBox(height: 12),
        
        // Immediate Actions
        _buildSection(
          'Acil Eylemler',
          Icons.flash_on,
          assessment.immediateActions,
          Colors.orange,
        ),
        
        const SizedBox(height: 12),
        
        // Follow-up Actions
        _buildSection(
          'Takip Eylemleri',
          Icons.schedule,
          assessment.followUpActions,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'Tespit edilmedi',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reanalyzeRisk,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Analiz'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _approveAssessment,
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

  Future<void> _analyzeRisk() async {
    setState(() => _isAnalyzing = true);
    
    try {
      final assessment = await _aiService.assessRisk(
        sessionNotes: widget.sessionNotes,
        professionalType: widget.professionalType,
      );
      
      setState(() {
        _assessment = assessment;
        _isAnalyzing = false;
      });
      
      if (widget.onRiskAssessed != null) {
        widget.onRiskAssessed!(assessment);
      }
      
      // High risk durumunda uyarı göster
      if (assessment.requiresImmediateAttention) {
        _showHighRiskAlert(assessment);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI risk analizi tamamlandı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showHighRiskAlert(RiskAssessment assessment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Yüksek Risk Tespit Edildi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Seviyesi: ${assessment.riskLevel}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Acil eylemler gerekli:'),
            const SizedBox(height: 8),
            ...assessment.immediateActions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(action)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCrisisProtocol();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kriz Protokolü'),
          ),
        ],
      ),
    );
  }

  void _showCrisisProtocol() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kriz Protokolü'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acil Durum Adımları:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Hasta güvenliğini sağla'),
              Text('2. Acil servisi ara (112)'),
              Text('3. Aile/arkadaşları bilgilendir'),
              Text('4. Güvenlik planı oluştur'),
              Text('5. 24 saat takip planla'),
              Text('6. Konsültasyon iste'),
              Text('7. Belgelendirme yap'),
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

  void _reanalyzeRisk() {
    setState(() => _assessment = null);
    _analyzeRisk();
  }

  void _approveAssessment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Risk değerlendirmesi onaylandı ve kaydedildi'),
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

  Color _getRiskLevelColor(String riskLevel) {
    switch (riskLevel) {
      case 'Kritik':
        return Colors.red[800]!;
      case 'Yüksek':
        return Colors.red;
      case 'Orta':
        return Colors.orange;
      case 'Düşük':
        return Colors.yellow[700]!;
      case 'Minimal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskLevelIcon(String riskLevel) {
    switch (riskLevel) {
      case 'Kritik':
        return Icons.error;
      case 'Yüksek':
        return Icons.warning;
      case 'Orta':
        return Icons.info;
      case 'Düşük':
        return Icons.check_circle;
      case 'Minimal':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}
