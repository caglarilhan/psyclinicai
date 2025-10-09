import 'package:flutter/material.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../utils/theme.dart';

class AIDiagnosticAssistantWidget extends StatefulWidget {
  final String assessmentType;
  final int score;
  final ProfessionalType professionalType;
  final Function(DiagnosticSuggestion)? onSuggestionGenerated;

  const AIDiagnosticAssistantWidget({
    super.key,
    required this.assessmentType,
    required this.score,
    required this.professionalType,
    this.onSuggestionGenerated,
  });

  @override
  State<AIDiagnosticAssistantWidget> createState() => _AIDiagnosticAssistantWidgetState();
}

class _AIDiagnosticAssistantWidgetState extends State<AIDiagnosticAssistantWidget> {
  final _aiService = AIService();
  DiagnosticSuggestion? _suggestion;
  bool _isGenerating = false;

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
                  Icons.medical_services,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Tanı Asistanı',
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
            
            // Assessment Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Değerlendirme: ${widget.assessmentType}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Puan: ${widget.score}',
                          style: TextStyle(
                            color: _getScoreColor(widget.score),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(widget.score).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getScoreLabel(widget.score),
                      style: TextStyle(
                        color: _getScoreColor(widget.score),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Generate Button
            if (_suggestion == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateSuggestion,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'AI Analiz Ediyor...' : 'AI ile Analiz Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            // Suggestion Content
            if (_suggestion != null) ...[
              _buildSuggestionContent(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionContent() {
    final suggestion = _suggestion!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Severity
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getSeverityColor(suggestion.severity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getSeverityColor(suggestion.severity).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                _getSeverityIcon(suggestion.severity),
                color: _getSeverityColor(suggestion.severity),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Şiddet: ${suggestion.severity}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getSeverityColor(suggestion.severity),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Possible Diagnoses
        _buildSection(
          'Olası Tanılar',
          Icons.psychology,
          suggestion.possibleDiagnoses,
          Colors.blue,
        ),
        
        const SizedBox(height: 12),
        
        // Recommendations
        _buildSection(
          'Öneriler',
          Icons.lightbulb,
          suggestion.recommendations,
          Colors.green,
        ),
        
        const SizedBox(height: 12),
        
        // Warning Signs
        if (suggestion.warningSigns.isNotEmpty)
          _buildSection(
            'Uyarı İşaretleri',
            Icons.warning,
            suggestion.warningSigns,
            Colors.red,
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
            onPressed: _regenerateSuggestion,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Analiz'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _approveSuggestion,
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

  Future<void> _generateSuggestion() async {
    setState(() => _isGenerating = true);
    
    try {
      final suggestion = await _aiService.generateDiagnosticSuggestion(
        assessmentType: widget.assessmentType,
        score: widget.score,
        professionalType: widget.professionalType,
      );
      
      setState(() {
        _suggestion = suggestion;
        _isGenerating = false;
      });
      
      if (widget.onSuggestionGenerated != null) {
        widget.onSuggestionGenerated!(suggestion);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI tanı analizi başarıyla oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _regenerateSuggestion() {
    setState(() => _suggestion = null);
    _generateSuggestion();
  }

  void _approveSuggestion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tanı önerisi onaylandı ve kaydedildi'),
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

  Color _getScoreColor(int score) {
    if (score >= 20) return Colors.red[800]!;
    if (score >= 15) return Colors.red;
    if (score >= 10) return Colors.orange;
    if (score >= 5) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _getScoreLabel(int score) {
    if (score >= 20) return 'Ağır';
    if (score >= 15) return 'Orta-Ağır';
    if (score >= 10) return 'Orta';
    if (score >= 5) return 'Hafif';
    return 'Minimal';
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Ağır':
        return Colors.red[800]!;
      case 'Orta-Ağır':
        return Colors.red;
      case 'Orta':
        return Colors.orange;
      case 'Hafif':
        return Colors.yellow[700]!;
      case 'Minimal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'Ağır':
        return Icons.error;
      case 'Orta-Ağır':
        return Icons.warning;
      case 'Orta':
        return Icons.info;
      case 'Hafif':
        return Icons.check_circle;
      case 'Minimal':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}
