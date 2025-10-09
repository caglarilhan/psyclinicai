import 'package:flutter/material.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../utils/theme.dart';

class AITreatmentSuggestionsWidget extends StatefulWidget {
  final String primaryDiagnosis;
  final String sessionNotes;
  final ProfessionalType professionalType;
  final Function(TreatmentSuggestion)? onSuggestionGenerated;

  const AITreatmentSuggestionsWidget({
    super.key,
    required this.primaryDiagnosis,
    required this.sessionNotes,
    required this.professionalType,
    this.onSuggestionGenerated,
  });

  @override
  State<AITreatmentSuggestionsWidget> createState() => _AITreatmentSuggestionsWidgetState();
}

class _AITreatmentSuggestionsWidgetState extends State<AITreatmentSuggestionsWidget> {
  final _aiService = AIService();
  TreatmentSuggestion? _suggestion;
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
                  'AI Tedavi Önerileri',
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
            
            // Diagnosis Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tanı: ${widget.primaryDiagnosis}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
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
                  label: Text(_isGenerating ? 'AI Tedavi Planı Hazırlıyor...' : 'AI ile Tedavi Planı Oluştur'),
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
        // Recommended Interventions
        _buildSection(
          'Önerilen Müdahaleler',
          Icons.medical_services,
          suggestion.recommendedInterventions,
          Colors.blue,
        ),
        
        const SizedBox(height: 12),
        
        // Therapeutic Techniques
        _buildSection(
          'Terapötik Teknikler',
          Icons.psychology,
          suggestion.therapeuticTechniques,
          Colors.green,
        ),
        
        const SizedBox(height: 12),
        
        // Medication Considerations (only for psychiatrists)
        if (widget.professionalType == ProfessionalType.psychiatrist && suggestion.medicationConsiderations.isNotEmpty)
          _buildSection(
            'İlaç Değerlendirmeleri',
            Icons.medication,
            suggestion.medicationConsiderations,
            Colors.red,
          ),
        
        if (widget.professionalType == ProfessionalType.psychiatrist && suggestion.medicationConsiderations.isNotEmpty)
          const SizedBox(height: 12),
        
        // Session Goals
        _buildSection(
          'Seans Hedefleri',
          Icons.flag,
          suggestion.sessionGoals,
          Colors.orange,
        ),
        
        const SizedBox(height: 12),
        
        // Treatment Plan Details
        _buildTreatmentPlanDetails(suggestion.treatmentPlan),
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

  Widget _buildTreatmentPlanDetails(Map<String, dynamic> treatmentPlan) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppTheme.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Tedavi Planı Detayları',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (treatmentPlan['duration'] != null)
            _buildDetailItem('Süre', '${treatmentPlan['duration']} hafta'),
          if (treatmentPlan['frequency'] != null)
            _buildDetailItem('Sıklık', treatmentPlan['frequency']),
          if (treatmentPlan['modalities'] != null)
            _buildDetailItem('Modaliteler', (treatmentPlan['modalities'] as List).join(', ')),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
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
            onPressed: _regenerateSuggestion,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Üret'),
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
      final suggestion = await _aiService.generateTreatmentSuggestion(
        primaryDiagnosis: widget.primaryDiagnosis,
        sessionNotes: widget.sessionNotes,
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
          content: Text('AI tedavi önerisi başarıyla oluşturuldu'),
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
        content: Text('Tedavi önerisi onaylandı ve kaydedildi'),
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
