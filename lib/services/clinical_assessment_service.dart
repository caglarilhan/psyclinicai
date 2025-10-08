import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clinical_assessment_models.dart';
import 'database_service.dart';

class ClinicalAssessmentService {
  static final ClinicalAssessmentService _instance = ClinicalAssessmentService._internal();
  factory ClinicalAssessmentService() => _instance;
  ClinicalAssessmentService._internal();

  final DatabaseService _databaseService = DatabaseService();
  List<ClinicalAssessment> _assessments = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadAssessments();
  }

  // Load assessments from database
  Future<void> _loadAssessments() async {
    try {
      // TODO: Implement database loading
      _assessments = [];
    } catch (e) {
      print('Error loading assessments: $e');
      _assessments = [];
    }
  }

  // Save assessment to database
  Future<void> _saveAssessment(ClinicalAssessment assessment) async {
    try {
      // TODO: Implement database saving
      _assessments.add(assessment);
    } catch (e) {
      print('Error saving assessment: $e');
    }
  }

  // Get all assessments
  List<ClinicalAssessment> getAllAssessments() {
    return List.unmodifiable(_assessments);
  }

  // Get assessments by client
  List<ClinicalAssessment> getAssessmentsByClient(String clientId) {
    return _assessments.where((assessment) => assessment.clientId == clientId).toList();
  }

  // Get assessments by type
  List<ClinicalAssessment> getAssessmentsByType(AssessmentType type) {
    return _assessments.where((assessment) => assessment.type == type).toList();
  }

  // Get assessment by ID
  ClinicalAssessment? getAssessmentById(String id) {
    try {
      return _assessments.firstWhere((assessment) => assessment.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new assessment
  Future<ClinicalAssessment> createAssessment({
    required String clientId,
    required String therapistId,
    required AssessmentType type,
    required Map<String, dynamic> responses,
  }) async {
    final assessmentId = DateTime.now().millisecondsSinceEpoch.toString();
    final assessmentDate = DateTime.now();

    // Calculate scores based on type
    Map<String, dynamic> scores = {};
    String interpretation = '';
    AssessmentSeverity severity = AssessmentSeverity.minimal;
    List<String> recommendations = [];

    switch (type) {
      case AssessmentType.phq9:
        scores = PHQ9Template.calculateScore(responses);
        interpretation = scores['interpretation'] as String;
        severity = AssessmentSeverity.values.firstWhere(
          (e) => e.name == scores['severity'],
        );
        recommendations = List<String>.from(scores['recommendations']);
        break;
      case AssessmentType.gad7:
        scores = GAD7Template.calculateScore(responses);
        interpretation = scores['interpretation'] as String;
        severity = AssessmentSeverity.values.firstWhere(
          (e) => e.name == scores['severity'],
        );
        recommendations = List<String>.from(scores['recommendations']);
        break;
      default:
        interpretation = 'Değerlendirme tamamlandı. Sonuçlar incelenmelidir.';
        recommendations = ['Klinik değerlendirme', 'Takip önerilir'];
    }

    final assessment = ClinicalAssessment(
      id: assessmentId,
      clientId: clientId,
      therapistId: therapistId,
      type: type,
      assessmentDate: assessmentDate,
      responses: responses,
      scores: scores,
      interpretation: interpretation,
      severity: severity,
      recommendations: recommendations,
      isCompleted: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _saveAssessment(assessment);
    return assessment;
  }

  // Update assessment
  Future<bool> updateAssessment(ClinicalAssessment updatedAssessment) async {
    try {
      final index = _assessments.indexWhere((assessment) => assessment.id == updatedAssessment.id);
      if (index == -1) {
        return false;
      }

      _assessments[index] = updatedAssessment;
      await _saveAssessment(updatedAssessment);
      return true;
    } catch (e) {
      print('Error updating assessment: $e');
      return false;
    }
  }

  // Delete assessment
  Future<bool> deleteAssessment(String id) async {
    try {
      final index = _assessments.indexWhere((assessment) => assessment.id == id);
      if (index == -1) {
        return false;
      }

      _assessments.removeAt(index);
      return true;
    } catch (e) {
      print('Error deleting assessment: $e');
      return false;
    }
  }

  // Get assessment questions by type
  List<AssessmentQuestion> getAssessmentQuestions(AssessmentType type) {
    switch (type) {
      case AssessmentType.phq9:
        return PHQ9Template.getQuestions();
      case AssessmentType.gad7:
        return GAD7Template.getQuestions();
      default:
        return [];
    }
  }

  // Get assessment statistics
  Map<String, dynamic> getAssessmentStatistics() {
    final totalAssessments = _assessments.length;
    final completedAssessments = _assessments.where((a) => a.isCompleted).length;
    final phq9Count = _assessments.where((a) => a.type == AssessmentType.phq9).length;
    final gad7Count = _assessments.where((a) => a.type == AssessmentType.gad7).length;

    final severityCounts = <String, int>{};
    for (final assessment in _assessments) {
      final severity = assessment.severity.name;
      severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
    }

    return {
      'totalAssessments': totalAssessments,
      'completedAssessments': completedAssessments,
      'phq9Count': phq9Count,
      'gad7Count': gad7Count,
      'severityCounts': severityCounts,
    };
  }

  // Get client progress over time
  List<Map<String, dynamic>> getClientProgress(String clientId, AssessmentType type) {
    final clientAssessments = _assessments
        .where((assessment) => 
            assessment.clientId == clientId && 
            assessment.type == type &&
            assessment.isCompleted)
        .toList();

    clientAssessments.sort((a, b) => a.assessmentDate.compareTo(b.assessmentDate));

    return clientAssessments.map((assessment) => {
      'date': assessment.assessmentDate.toIso8601String(),
      'score': assessment.scores['totalScore'] ?? 0,
      'severity': assessment.severity.name,
      'interpretation': assessment.interpretation,
    }).toList();
  }

  // Generate assessment report
  Map<String, dynamic> generateAssessmentReport(String clientId) {
    final clientAssessments = getAssessmentsByClient(clientId);
    
    if (clientAssessments.isEmpty) {
      return {
        'clientId': clientId,
        'message': 'Bu hasta için değerlendirme bulunamadı.',
        'assessments': [],
      };
    }

    final report = {
      'clientId': clientId,
      'totalAssessments': clientAssessments.length,
      'lastAssessmentDate': clientAssessments
          .map((a) => a.assessmentDate)
          .reduce((a, b) => a.isAfter(b) ? a : b)
          .toIso8601String(),
      'assessments': clientAssessments.map((assessment) => {
        'id': assessment.id,
        'type': assessment.type.name,
        'date': assessment.assessmentDate.toIso8601String(),
        'severity': assessment.severity.name,
        'score': assessment.scores['totalScore'] ?? 0,
        'interpretation': assessment.interpretation,
        'recommendations': assessment.recommendations,
      }).toList(),
      'progress': {
        'phq9': getClientProgress(clientId, AssessmentType.phq9),
        'gad7': getClientProgress(clientId, AssessmentType.gad7),
      },
    };

    return report;
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_assessments.isNotEmpty) return;

    final demoAssessments = [
      await createAssessment(
        clientId: '1',
        therapistId: 'therapist_001',
        type: AssessmentType.phq9,
        responses: {
          'phq9_1': 2,
          'phq9_2': 3,
          'phq9_3': 2,
          'phq9_4': 3,
          'phq9_5': 1,
          'phq9_6': 2,
          'phq9_7': 2,
          'phq9_8': 1,
          'phq9_9': 0,
        },
      ),
      await createAssessment(
        clientId: '2',
        therapistId: 'therapist_001',
        type: AssessmentType.gad7,
        responses: {
          'gad7_1': 2,
          'gad7_2': 2,
          'gad7_3': 3,
          'gad7_4': 2,
          'gad7_5': 1,
          'gad7_6': 2,
          'gad7_7': 1,
        },
      ),
      await createAssessment(
        clientId: '3',
        therapistId: 'therapist_001',
        type: AssessmentType.phq9,
        responses: {
          'phq9_1': 1,
          'phq9_2': 1,
          'phq9_3': 1,
          'phq9_4': 2,
          'phq9_5': 1,
          'phq9_6': 1,
          'phq9_7': 1,
          'phq9_8': 0,
          'phq9_9': 0,
        },
      ),
    ];

    print('✅ Demo clinical assessments created: ${demoAssessments.length}');
  }
}
