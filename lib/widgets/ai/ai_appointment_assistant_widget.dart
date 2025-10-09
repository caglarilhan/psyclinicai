import 'package:flutter/material.dart';
import '../../models/ai_models.dart';
import '../../services/ai_service.dart';
import '../../utils/theme.dart';

class AIAppointmentAssistantWidget extends StatefulWidget {
  final ProfessionalType professionalType;
  final String clientId;
  final Function(Map<String, dynamic>)? onAppointmentOptimized;

  const AIAppointmentAssistantWidget({
    super.key,
    required this.professionalType,
    required this.clientId,
    this.onAppointmentOptimized,
  });

  @override
  State<AIAppointmentAssistantWidget> createState() => _AIAppointmentAssistantWidgetState();
}

class _AIAppointmentAssistantWidgetState extends State<AIAppointmentAssistantWidget> {
  final _aiService = AIService();
  final _textController = TextEditingController();
  Map<String, dynamic>? _optimization;
  bool _isOptimizing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
                  Icons.schedule,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Randevu Asistanı',
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
            
            // Input Field
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Randevu talebi veya notları',
                hintText: 'Örn: "Hasta depresyon şikayeti ile geliyor, 1 saat sürmeli"',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Optimize Button
            if (_optimization == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isOptimizing ? null : _optimizeAppointment,
                  icon: _isOptimizing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isOptimizing ? 'AI Randevu Optimize Ediyor...' : 'AI ile Randevu Optimize Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            // Optimization Content
            if (_optimization != null) ...[
              _buildOptimizationContent(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationContent() {
    final optimization = _optimization!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Suggested Duration
        _buildOptimizationCard(
          'Önerilen Süre',
          Icons.access_time,
          '${optimization['suggestedDuration'] ?? 60} dakika',
          Colors.blue,
        ),
        
        const SizedBox(height: 12),
        
        // Suggested Time
        _buildOptimizationCard(
          'Önerilen Zaman',
          Icons.schedule,
          optimization['suggestedTime'] ?? 'Uygun zaman',
          Colors.green,
        ),
        
        const SizedBox(height: 12),
        
        // No-show Risk
        _buildOptimizationCard(
          'No-Show Riski',
          Icons.warning,
          '${optimization['noShowRisk'] ?? 'Orta'} risk',
          _getNoShowRiskColor(optimization['noShowRisk'] ?? 'Orta'),
        ),
        
        const SizedBox(height: 12),
        
        // Preparation Notes
        if (optimization['preparationNotes'] != null)
          _buildPreparationNotes(optimization['preparationNotes']),
      ],
    );
  }

  Widget _buildOptimizationCard(String title, IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationNotes(List<String> notes) {
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
                'Hazırlık Notları',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...notes.map((note) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[700],
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    note,
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
            onPressed: _reoptimizeAppointment,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Optimize Et'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _approveOptimization,
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

  Future<void> _optimizeAppointment() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen randevu talebi veya notları girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isOptimizing = true);
    
    try {
      // Mock AI optimization - gerçek uygulamada AI service kullanılır
      await Future.delayed(const Duration(seconds: 2));
      
      final optimization = _generateMockOptimization(_textController.text, widget.professionalType);
      
      setState(() {
        _optimization = optimization;
        _isOptimizing = false;
      });
      
      if (widget.onAppointmentOptimized != null) {
        widget.onAppointmentOptimized!(optimization);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI randevu optimizasyonu tamamlandı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isOptimizing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _generateMockOptimization(String text, ProfessionalType type) {
    final lowerText = text.toLowerCase();
    
    // Süre tahmini
    int suggestedDuration = 60; // varsayılan
    if (lowerText.contains('kısa') || lowerText.contains('hızlı')) {
      suggestedDuration = 30;
    } else if (lowerText.contains('uzun') || lowerText.contains('detaylı')) {
      suggestedDuration = 90;
    } else if (lowerText.contains('ilk') || lowerText.contains('yeni')) {
      suggestedDuration = 90;
    }
    
    // Zaman önerisi
    String suggestedTime = 'Sabah (09:00-12:00)';
    if (lowerText.contains('akşam') || lowerText.contains('geç')) {
      suggestedTime = 'Akşam (17:00-19:00)';
    } else if (lowerText.contains('öğle') || lowerText.contains('orta')) {
      suggestedTime = 'Öğle (12:00-15:00)';
    }
    
    // No-show riski
    String noShowRisk = 'Düşük';
    if (lowerText.contains('kronik') || lowerText.contains('düzenli')) {
      noShowRisk = 'Düşük';
    } else if (lowerText.contains('yeni') || lowerText.contains('ilk')) {
      noShowRisk = 'Orta';
    } else if (lowerText.contains('iptal') || lowerText.contains('gelmedi')) {
      noShowRisk = 'Yüksek';
    }
    
    // Hazırlık notları
    List<String> preparationNotes = [];
    
    switch (type) {
      case ProfessionalType.psychologist:
        preparationNotes.addAll([
          'Terapi materyalleri hazırla',
          'Değerlendirme formları kontrol et',
          'Ev ödevleri gözden geçir',
        ]);
        break;
      case ProfessionalType.psychiatrist:
        preparationNotes.addAll([
          'İlaç listesi gözden geçir',
          'Laboratuvar sonuçları kontrol et',
          'Yan etki değerlendirmesi hazırla',
        ]);
        break;
      case ProfessionalType.therapist:
        preparationNotes.addAll([
          'Terapötik teknikler planla',
          'Danışan dosyası gözden geçir',
          'Hedefler belirle',
        ]);
        break;
    }
    
    if (lowerText.contains('depresyon')) {
      preparationNotes.add('PHQ-9 değerlendirmesi hazırla');
    }
    if (lowerText.contains('anksiyete') || lowerText.contains('kaygı')) {
      preparationNotes.add('GAD-7 değerlendirmesi hazırla');
    }
    if (lowerText.contains('kriz') || lowerText.contains('acil')) {
      preparationNotes.add('Kriz müdahale protokolü hazırla');
    }
    
    return {
      'suggestedDuration': suggestedDuration,
      'suggestedTime': suggestedTime,
      'noShowRisk': noShowRisk,
      'preparationNotes': preparationNotes,
      'professionalType': type.name,
      'clientId': widget.clientId,
    };
  }

  void _reoptimizeAppointment() {
    setState(() => _optimization = null);
    _optimizeAppointment();
  }

  void _approveOptimization() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu optimizasyonu onaylandı ve kaydedildi'),
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

  Color _getNoShowRiskColor(String risk) {
    switch (risk) {
      case 'Düşük':
        return Colors.green;
      case 'Orta':
        return Colors.orange;
      case 'Yüksek':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
