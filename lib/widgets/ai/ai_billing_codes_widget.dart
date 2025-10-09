import 'package:flutter/material.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../utils/theme.dart';

class AIBillingCodesWidget extends StatefulWidget {
  final String sessionType;
  final String primaryDiagnosis;
  final int sessionDuration;
  final ProfessionalType professionalType;
  final String region;
  final Function(BillingCodeSuggestion)? onSuggestionGenerated;

  const AIBillingCodesWidget({
    super.key,
    required this.sessionType,
    required this.primaryDiagnosis,
    required this.sessionDuration,
    required this.professionalType,
    required this.region,
    this.onSuggestionGenerated,
  });

  @override
  State<AIBillingCodesWidget> createState() => _AIBillingCodesWidgetState();
}

class _AIBillingCodesWidgetState extends State<AIBillingCodesWidget> {
  final _aiService = AIService();
  BillingCodeSuggestion? _suggestion;
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
                  Icons.receipt,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Faturalama Kodları',
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
            
            // Session Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Seans Türü', widget.sessionType),
                  _buildInfoRow('Tanı', widget.primaryDiagnosis),
                  _buildInfoRow('Süre', '${widget.sessionDuration} dakika'),
                  _buildInfoRow('Bölge', _getRegionDisplayName(widget.region)),
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
                  label: Text(_isGenerating ? 'AI Kod Önerisi Hazırlanıyor...' : 'AI ile Kod Önerisi Al'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
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

  Widget _buildSuggestionContent() {
    final suggestion = _suggestion!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CPT Codes
        _buildCodeSection(
          'CPT Kodları',
          Icons.code,
          suggestion.recommendedCPTCodes,
          Colors.blue,
        ),
        
        const SizedBox(height: 12),
        
        // ICD Codes
        _buildCodeSection(
          'ICD Kodları',
          Icons.medical_services,
          suggestion.recommendedICDCodes,
          Colors.green,
        ),
        
        const SizedBox(height: 12),
        
        // Billing Notes
        if (suggestion.billingNotes.isNotEmpty)
          _buildBillingNotes(suggestion.billingNotes),
      ],
    );
  }

  Widget _buildCodeSection(String title, IconData icon, List<String> codes, Color color) {
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: codes.map((code) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.copy,
                  size: 12,
                  color: color,
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildBillingNotes(Map<String, dynamic> notes) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                color: Colors.orange[700],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Faturalama Notları',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...notes.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          )),
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
      final suggestion = await _aiService.generateBillingCodeSuggestion(
        sessionType: widget.sessionType,
        primaryDiagnosis: widget.primaryDiagnosis,
        sessionDuration: widget.sessionDuration,
        professionalType: widget.professionalType,
        region: widget.region,
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
          content: Text('AI faturalama kodu önerisi başarıyla oluşturuldu'),
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
        content: Text('Faturalama kodu önerisi onaylandı ve kaydedildi'),
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

  String _getRegionDisplayName(String region) {
    switch (region) {
      case 'TR':
        return 'Türkiye';
      case 'US':
        return 'ABD';
      case 'EU':
        return 'Avrupa';
      case 'CA':
        return 'Kanada';
      case 'AU':
        return 'Avustralya';
      default:
        return region;
    }
  }
}
