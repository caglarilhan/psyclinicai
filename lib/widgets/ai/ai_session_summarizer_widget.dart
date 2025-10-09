import 'package:flutter/material.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../utils/theme.dart';

class AISessionSummarizerWidget extends StatefulWidget {
  final String sessionNotes;
  final ProfessionalType professionalType;
  final String clientId;
  final String sessionId;
  final Function(SessionSummaryResponse)? onSummaryGenerated;

  const AISessionSummarizerWidget({
    super.key,
    required this.sessionNotes,
    required this.professionalType,
    required this.clientId,
    required this.sessionId,
    this.onSummaryGenerated,
  });

  @override
  State<AISessionSummarizerWidget> createState() => _AISessionSummarizerWidgetState();
}

class _AISessionSummarizerWidgetState extends State<AISessionSummarizerWidget> {
  final _aiService = AIService();
  SessionSummaryResponse? _summary;
  bool _isGenerating = false;
  bool _isExpanded = false;

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
                  Icons.psychology,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Seans Özetleyici',
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
            
            // Generate Button
            if (_summary == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateSummary,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'AI Özet Hazırlanıyor...' : 'AI ile Özetle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            // Summary Content
            if (_summary != null) ...[
              _buildSummaryContent(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContent() {
    final summary = _summary!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Confidence Indicator
        Row(
          children: [
            Icon(
              Icons.psychology,
              color: _getConfidenceColor(summary.confidence),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Güven: ${(summary.confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: _getConfidenceColor(summary.confidence),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Summary Text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            summary.summary,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Key Findings
        _buildSection(
          'Ana Bulgular',
          Icons.lightbulb,
          summary.keyFindings,
          Colors.orange,
        ),
        
        const SizedBox(height: 12),
        
        // Action Items
        _buildSection(
          'Aksiyon Öğeleri',
          Icons.checklist,
          summary.actionItems,
          Colors.green,
        ),
        
        const SizedBox(height: 12),
        
        // Follow-up Tasks
        _buildSection(
          'Takip Görevleri',
          Icons.schedule,
          summary.followUpTasks,
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
            onPressed: _regenerateSummary,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Üret'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _approveSummary,
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

  Future<void> _generateSummary() async {
    setState(() => _isGenerating = true);
    
    try {
      final summary = await _aiService.generateSessionSummary(
        sessionNotes: widget.sessionNotes,
        professionalType: widget.professionalType,
        clientId: widget.clientId,
        sessionId: widget.sessionId,
      );
      
      setState(() {
        _summary = summary;
        _isGenerating = false;
      });
      
      if (widget.onSummaryGenerated != null) {
        widget.onSummaryGenerated!(summary);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI özet başarıyla oluşturuldu'),
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

  void _regenerateSummary() {
    setState(() => _summary = null);
    _generateSummary();
  }

  void _approveSummary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Özet onaylandı ve kaydedildi'),
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

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
