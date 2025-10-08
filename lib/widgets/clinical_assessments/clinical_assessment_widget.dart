import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/clinical_assessment_models.dart';
import '../../services/clinical_assessment_service.dart';
import '../../services/client_service.dart';
import '../../models/client_model.dart';

class ClinicalAssessmentWidget extends StatefulWidget {
  final String clientId;
  final String therapistId;

  const ClinicalAssessmentWidget({
    super.key,
    required this.clientId,
    required this.therapistId,
  });

  @override
  State<ClinicalAssessmentWidget> createState() => _ClinicalAssessmentWidgetState();
}

class _ClinicalAssessmentWidgetState extends State<ClinicalAssessmentWidget> {
  final ClinicalAssessmentService _assessmentService = ClinicalAssessmentService();
  final ClientService _clientService = ClientService();
  
  List<ClinicalAssessment> _assessments = [];
  Client? _client;
  bool _isLoading = true;
  AssessmentType _selectedType = AssessmentType.phq9;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await _assessmentService.initialize();
      await _assessmentService.generateDemoData();
      
      final assessments = _assessmentService.getAssessmentsByClient(widget.clientId);
      final client = _clientService.getClientById(widget.clientId);
      
      setState(() {
        _assessments = assessments;
        _client = client;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Değerlendirmeler yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Klinik Değerlendirmeler - ${_client?.fullName ?? 'Hasta'}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAssessmentTypeDialog,
            tooltip: 'Yeni Değerlendirme',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Assessment Type Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<AssessmentType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Değerlendirme Türü',
                            border: OutlineInputBorder(),
                          ),
                          items: AssessmentType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_getAssessmentTypeName(type)),
                            );
                          }).toList(),
                          onChanged: (type) {
                            setState(() {
                              _selectedType = type!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _startNewAssessment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Yeni Değerlendirme'),
                      ),
                    ],
                  ),
                ),
                
                // Assessments List
                Expanded(
                  child: _assessments.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _assessments.length,
                          itemBuilder: (context, index) {
                            final assessment = _assessments[index];
                            return _buildAssessmentCard(assessment);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz değerlendirme yapılmamış',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk değerlendirmeyi başlatmak için + butonuna tıklayın',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(ClinicalAssessment assessment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getSeverityColor(assessment.severity).withValues(alpha: 0.1),
          child: Icon(
            _getAssessmentIcon(assessment.type),
            color: _getSeverityColor(assessment.severity),
          ),
        ),
        title: Text(
          _getAssessmentTypeName(assessment.type),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_formatDate(assessment.assessmentDate)}'),
            Text('Skor: ${assessment.scores['totalScore'] ?? 'N/A'}'),
            Text('Şiddet: ${_getSeverityName(assessment.severity)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interpretation
                Text(
                  'Değerlendirme:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(assessment.interpretation),
                
                const SizedBox(height: 16),
                
                // Recommendations
                Text(
                  'Öneriler:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...assessment.recommendations.map((recommendation) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(recommendation)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _viewAssessmentDetails(assessment),
                        child: const Text('Detayları Görüntüle'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _generateReport(assessment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Rapor Oluştur'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAssessmentTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değerlendirme Türü Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AssessmentType.values.map((type) {
            return ListTile(
              leading: Icon(_getAssessmentIcon(type)),
              title: Text(_getAssessmentTypeName(type)),
              subtitle: Text(_getAssessmentDescription(type)),
              onTap: () {
                Navigator.pop(context);
                _startAssessment(type);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _startNewAssessment() {
    _startAssessment(_selectedType);
  }

  void _startAssessment(AssessmentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentFormScreen(
          clientId: widget.clientId,
          therapistId: widget.therapistId,
          assessmentType: type,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _viewAssessmentDetails(ClinicalAssessment assessment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentDetailScreen(assessment: assessment),
      ),
    );
  }

  void _generateReport(ClinicalAssessment assessment) {
    // TODO: Implement report generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor oluşturuluyor...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getAssessmentTypeName(AssessmentType type) {
    switch (type) {
      case AssessmentType.phq9:
        return 'PHQ-9 (Depresyon)';
      case AssessmentType.gad7:
        return 'GAD-7 (Anksiyete)';
      case AssessmentType.bdi:
        return 'BDI (Beck Depresyon)';
      case AssessmentType.bai:
        return 'BAI (Beck Anksiyete)';
      case AssessmentType.pcl5:
        return 'PCL-5 (Travma)';
      case AssessmentType.ybocs:
        return 'Y-BOCS (OKB)';
      case AssessmentType.mmpi2:
        return 'MMPI-2';
      case AssessmentType.wisc:
        return 'WISC (Çocuk Zeka)';
      case AssessmentType.wais:
        return 'WAIS (Yetişkin Zeka)';
      case AssessmentType.rorschach:
        return 'Rorschach Testi';
      case AssessmentType.thematic:
        return 'TAT (Tematik Algı)';
      case AssessmentType.hamilton:
        return 'Hamilton Depresyon';
      case AssessmentType.hamiltonAnxiety:
        return 'Hamilton Anksiyete';
      case AssessmentType.mini:
        return 'MINI (Klinik Görüşme)';
      case AssessmentType.scid:
        return 'SCID (Yapılandırılmış Görüşme)';
      case AssessmentType.custom:
        return 'Özel Değerlendirme';
      case AssessmentType.mmpi:
        return 'MMPI (Minnesota Çok Boyutlu Kişilik Envanteri)';
      case AssessmentType.mmpi2:
        return 'MMPI-2 (Minnesota Çok Boyutlu Kişilik Envanteri-2)';
      case AssessmentType.mmpi:
        return 'MMPI (Minnesota Çok Boyutlu Kişilik Envanteri)';
    }
  }

  String _getAssessmentDescription(AssessmentType type) {
    switch (type) {
      case AssessmentType.phq9:
        return 'Depresyon belirtilerini değerlendirir';
      case AssessmentType.gad7:
        return 'Anksiyete belirtilerini değerlendirir';
      case AssessmentType.bdi:
        return 'Beck Depresyon Envanteri';
      case AssessmentType.bai:
        return 'Beck Anksiyete Envanteri';
      case AssessmentType.pcl5:
        return 'Travma sonrası stres bozukluğu';
      case AssessmentType.ybocs:
        return 'Obsesif kompulsif bozukluk';
      case AssessmentType.mmpi2:
        return 'Kişilik değerlendirmesi';
      case AssessmentType.wisc:
        return 'Çocuk zeka testi';
      case AssessmentType.wais:
        return 'Yetişkin zeka testi';
      case AssessmentType.rorschach:
        return 'Projektif kişilik testi';
      case AssessmentType.thematic:
        return 'Tematik algı testi';
      case AssessmentType.hamilton:
        return 'Depresyon şiddeti ölçeği';
      case AssessmentType.hamiltonAnxiety:
        return 'Anksiyete şiddeti ölçeği';
      case AssessmentType.mini:
        return 'Mini uluslararası nöropsikiyatrik görüşme';
      case AssessmentType.scid:
        return 'DSM için yapılandırılmış klinik görüşme';
      case AssessmentType.custom:
        return 'Özel olarak tasarlanmış değerlendirme';
    }
  }

  IconData _getAssessmentIcon(AssessmentType type) {
    switch (type) {
      case AssessmentType.phq9:
      case AssessmentType.bdi:
      case AssessmentType.hamilton:
        return Icons.sentiment_dissatisfied;
      case AssessmentType.gad7:
      case AssessmentType.bai:
      case AssessmentType.hamiltonAnxiety:
        return Icons.psychology;
      case AssessmentType.pcl5:
        return Icons.flash_on;
      case AssessmentType.ybocs:
        return Icons.loop;
      case AssessmentType.mmpi2:
        return Icons.person;
      case AssessmentType.wisc:
      case AssessmentType.wais:
        return Icons.psychology_alt;
      case AssessmentType.rorschach:
        return Icons.auto_awesome;
      case AssessmentType.thematic:
        return Icons.palette;
      case AssessmentType.mini:
      case AssessmentType.scid:
        return Icons.record_voice_over;
      case AssessmentType.custom:
        return Icons.tune;
      case AssessmentType.mmpi:
        return Icons.psychology_alt;
      case AssessmentType.mmpi2:
        return Icons.psychology_alt;
    }
  }

  Color _getSeverityColor(AssessmentSeverity severity) {
    switch (severity) {
      case AssessmentSeverity.minimal:
        return Colors.green;
      case AssessmentSeverity.mild:
        return Colors.yellow;
      case AssessmentSeverity.moderate:
        return Colors.orange;
      case AssessmentSeverity.severe:
        return Colors.red;
      case AssessmentSeverity.extreme:
        return Colors.purple;
    }
  }

  String _getSeverityName(AssessmentSeverity severity) {
    switch (severity) {
      case AssessmentSeverity.minimal:
        return 'Minimal';
      case AssessmentSeverity.mild:
        return 'Hafif';
      case AssessmentSeverity.moderate:
        return 'Orta';
      case AssessmentSeverity.severe:
        return 'Şiddetli';
      case AssessmentSeverity.extreme:
        return 'Aşırı Şiddetli';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Assessment Form Screen
class AssessmentFormScreen extends StatefulWidget {
  final String clientId;
  final String therapistId;
  final AssessmentType assessmentType;

  const AssessmentFormScreen({
    super.key,
    required this.clientId,
    required this.therapistId,
    required this.assessmentType,
  });

  @override
  State<AssessmentFormScreen> createState() => _AssessmentFormScreenState();
}

class _AssessmentFormScreenState extends State<AssessmentFormScreen> {
  final ClinicalAssessmentService _assessmentService = ClinicalAssessmentService();
  final Map<String, dynamic> _responses = {};
  List<AssessmentQuestion> _questions = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _questions = _assessmentService.getAssessmentQuestions(widget.assessmentType);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAssessmentTypeName(widget.assessmentType)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitAssessment,
              child: const Text(
                'Kaydet',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assessment Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getAssessmentTypeName(widget.assessmentType),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_getAssessmentDescription(widget.assessmentType)),
                          const SizedBox(height: 16),
                          Text(
                            'Lütfen her soruyu dikkatlice okuyun ve en uygun seçeneği işaretleyin.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Questions
                  ..._questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return _buildQuestionCard(question, index + 1);
                  }).toList(),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Değerlendirmeyi Tamamla',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionCard(AssessmentQuestion question, int questionNumber) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Number and Text
            Text(
              'Soru $questionNumber',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (question.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                question.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Options
            ...question.options.map((option) => RadioListTile<int>(
              title: Text(option.text),
              subtitle: option.description.isNotEmpty 
                  ? Text(option.description) 
                  : null,
              value: option.value,
              groupValue: _responses[question.id],
              onChanged: (value) {
                setState(() {
                  _responses[question.id] = value;
                });
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAssessment() async {
    // Check if all questions are answered
    for (final question in _questions) {
      if (question.isRequired && _responses[question.id] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lütfen tüm soruları yanıtlayın. Soru ${_questions.indexOf(question) + 1} eksik.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      await _assessmentService.createAssessment(
        clientId: widget.clientId,
        therapistId: widget.therapistId,
        type: widget.assessmentType,
        responses: _responses,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Değerlendirme başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Değerlendirme kaydedilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getAssessmentTypeName(AssessmentType type) {
    switch (type) {
      case AssessmentType.phq9:
        return 'PHQ-9 (Depresyon Değerlendirmesi)';
      case AssessmentType.gad7:
        return 'GAD-7 (Anksiyete Değerlendirmesi)';
      case AssessmentType.bdi:
        return 'BDI (Beck Depresyon Envanteri)';
      case AssessmentType.bai:
        return 'BAI (Beck Anksiyete Envanteri)';
      case AssessmentType.pcl5:
        return 'PCL-5 (Travma Değerlendirmesi)';
      case AssessmentType.ybocs:
        return 'Y-BOCS (OKB Değerlendirmesi)';
      case AssessmentType.mmpi2:
        return 'MMPI-2 (Kişilik Değerlendirmesi)';
      case AssessmentType.wisc:
        return 'WISC (Çocuk Zeka Testi)';
      case AssessmentType.wais:
        return 'WAIS (Yetişkin Zeka Testi)';
      case AssessmentType.rorschach:
        return 'Rorschach Testi';
      case AssessmentType.thematic:
        return 'TAT (Tematik Algı Testi)';
      case AssessmentType.hamilton:
        return 'Hamilton Depresyon Ölçeği';
      case AssessmentType.hamiltonAnxiety:
        return 'Hamilton Anksiyete Ölçeği';
      case AssessmentType.mini:
        return 'MINI (Klinik Görüşme)';
      case AssessmentType.scid:
        return 'SCID (Yapılandırılmış Görüşme)';
      case AssessmentType.custom:
        return 'Özel Değerlendirme';
      case AssessmentType.mmpi:
        return 'MMPI (Minnesota Çok Boyutlu Kişilik Envanteri)';
      case AssessmentType.mmpi2:
        return 'MMPI-2 (Minnesota Çok Boyutlu Kişilik Envanteri-2)';
      case AssessmentType.mmpi:
        return 'MMPI (Minnesota Çok Boyutlu Kişilik Envanteri)';
    }
  }

  String _getAssessmentDescription(AssessmentType type) {
    switch (type) {
      case AssessmentType.phq9:
        return 'Bu değerlendirme, son 2 hafta boyunca yaşadığınız depresyon belirtilerini ölçer.';
      case AssessmentType.gad7:
        return 'Bu değerlendirme, son 2 hafta boyunca yaşadığınız anksiyete belirtilerini ölçer.';
      case AssessmentType.bdi:
        return 'Beck Depresyon Envanteri, depresyon belirtilerinin şiddetini değerlendirir.';
      case AssessmentType.bai:
        return 'Beck Anksiyete Envanteri, anksiyete belirtilerinin şiddetini değerlendirir.';
      case AssessmentType.pcl5:
        return 'Travma sonrası stres bozukluğu belirtilerini değerlendirir.';
      case AssessmentType.ybocs:
        return 'Obsesif kompulsif bozukluk belirtilerini değerlendirir.';
      case AssessmentType.mmpi2:
        return 'Kişilik özelliklerini ve psikopatolojik belirtileri değerlendirir.';
      case AssessmentType.wisc:
        return 'Çocuklar için zeka seviyesini değerlendirir.';
      case AssessmentType.wais:
        return 'Yetişkinler için zeka seviyesini değerlendirir.';
      case AssessmentType.rorschach:
        return 'Projektif kişilik değerlendirmesi yapar.';
      case AssessmentType.thematic:
        return 'Tematik algı testi ile kişilik değerlendirmesi yapar.';
      case AssessmentType.hamilton:
        return 'Depresyon şiddetini klinik olarak değerlendirir.';
      case AssessmentType.hamiltonAnxiety:
        return 'Anksiyete şiddetini klinik olarak değerlendirir.';
      case AssessmentType.mini:
        return 'Mini uluslararası nöropsikiyatrik görüşme yapar.';
      case AssessmentType.scid:
        return 'DSM tanı kriterleri için yapılandırılmış görüşme yapar.';
      case AssessmentType.custom:
        return 'Özel olarak tasarlanmış değerlendirme yapar.';
      case AssessmentType.mmpi:
        return 'Minnesota Çok Boyutlu Kişilik Envanteri ile kişilik değerlendirmesi yapar.';
    }
  }
}

// Assessment Detail Screen
class AssessmentDetailScreen extends StatelessWidget {
  final ClinicalAssessment assessment;

  const AssessmentDetailScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAssessmentTypeName(assessment.type)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assessment Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAssessmentTypeName(assessment.type),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Tarih: ${_formatDate(assessment.assessmentDate)}'),
                    Text('Skor: ${assessment.scores['totalScore'] ?? 'N/A'}'),
                    Text('Şiddet: ${_getSeverityName(assessment.severity)}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Interpretation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Değerlendirme Sonucu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(assessment.interpretation),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recommendations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Öneriler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...assessment.recommendations.map((recommendation) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(recommendation)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Responses
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yanıtlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...assessment.responses.entries.map((entry) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAssessmentTypeName(AssessmentType type) {
    switch (type) {
      case AssessmentType.phq9:
        return 'PHQ-9 (Depresyon)';
      case AssessmentType.gad7:
        return 'GAD-7 (Anksiyete)';
      case AssessmentType.bdi:
        return 'BDI (Beck Depresyon)';
      case AssessmentType.bai:
        return 'BAI (Beck Anksiyete)';
      case AssessmentType.pcl5:
        return 'PCL-5 (Travma)';
      case AssessmentType.ybocs:
        return 'Y-BOCS (OKB)';
      case AssessmentType.mmpi2:
        return 'MMPI-2';
      case AssessmentType.wisc:
        return 'WISC (Çocuk Zeka)';
      case AssessmentType.wais:
        return 'WAIS (Yetişkin Zeka)';
      case AssessmentType.rorschach:
        return 'Rorschach Testi';
      case AssessmentType.thematic:
        return 'TAT (Tematik Algı)';
      case AssessmentType.hamilton:
        return 'Hamilton Depresyon';
      case AssessmentType.hamiltonAnxiety:
        return 'Hamilton Anksiyete';
      case AssessmentType.mini:
        return 'MINI (Klinik Görüşme)';
      case AssessmentType.scid:
        return 'SCID (Yapılandırılmış Görüşme)';
      case AssessmentType.custom:
        return 'Özel Değerlendirme';
      case AssessmentType.mmpi:
        return 'MMPI (Minnesota Çok Boyutlu Kişilik Envanteri)';
      case AssessmentType.mmpi2:
        return 'MMPI-2 (Minnesota Çok Boyutlu Kişilik Envanteri-2)';
      case AssessmentType.mmpi:
        return 'MMPI (Minnesota Çok Boyutlu Kişilik Envanteri)';
    }
  }

  String _getSeverityName(AssessmentSeverity severity) {
    switch (severity) {
      case AssessmentSeverity.minimal:
        return 'Minimal';
      case AssessmentSeverity.mild:
        return 'Hafif';
      case AssessmentSeverity.moderate:
        return 'Orta';
      case AssessmentSeverity.severe:
        return 'Şiddetli';
      case AssessmentSeverity.extreme:
        return 'Aşırı Şiddetli';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
