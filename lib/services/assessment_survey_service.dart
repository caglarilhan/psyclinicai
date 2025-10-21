import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assessment_survey_models.dart';

class AssessmentSurveyService {
  static final AssessmentSurveyService _instance = AssessmentSurveyService._internal();
  factory AssessmentSurveyService() => _instance;
  AssessmentSurveyService._internal();

  final List<AssessmentSurvey> _surveys = [];
  final List<SurveyResponse> _responses = [];
  final List<SurveySchedule> _schedules = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadSurveys();
    await _loadResponses();
    await _loadSchedules();
  }

  // Load surveys from storage
  Future<void> _loadSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surveysJson = prefs.getStringList('assessment_surveys') ?? [];
      _surveys.clear();
      
      for (final surveyJson in surveysJson) {
        final survey = AssessmentSurvey.fromJson(jsonDecode(surveyJson));
        _surveys.add(survey);
      }
    } catch (e) {
      print('Error loading assessment surveys: $e');
      _surveys.clear();
    }
  }

  // Save surveys to storage
  Future<void> _saveSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surveysJson = _surveys
          .map((survey) => jsonEncode(survey.toJson()))
          .toList();
      await prefs.setStringList('assessment_surveys', surveysJson);
    } catch (e) {
      print('Error saving assessment surveys: $e');
    }
  }

  // Load responses from storage
  Future<void> _loadResponses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final responsesJson = prefs.getStringList('survey_responses') ?? [];
      _responses.clear();
      
      for (final responseJson in responsesJson) {
        final response = SurveyResponse.fromJson(jsonDecode(responseJson));
        _responses.add(response);
      }
    } catch (e) {
      print('Error loading survey responses: $e');
      _responses.clear();
    }
  }

  // Save responses to storage
  Future<void> _saveResponses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final responsesJson = _responses
          .map((response) => jsonEncode(response.toJson()))
          .toList();
      await prefs.setStringList('survey_responses', responsesJson);
    } catch (e) {
      print('Error saving survey responses: $e');
    }
  }

  // Load schedules from storage
  Future<void> _loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getStringList('survey_schedules') ?? [];
      _schedules.clear();
      
      for (final scheduleJson in schedulesJson) {
        final schedule = SurveySchedule.fromJson(jsonDecode(scheduleJson));
        _schedules.add(schedule);
      }
    } catch (e) {
      print('Error loading survey schedules: $e');
      _schedules.clear();
    }
  }

  // Save schedules to storage
  Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = _schedules
          .map((schedule) => jsonEncode(schedule.toJson()))
          .toList();
      await prefs.setStringList('survey_schedules', schedulesJson);
    } catch (e) {
      print('Error saving survey schedules: $e');
    }
  }

  // Create new survey
  Future<AssessmentSurvey> createSurvey({
    required String name,
    required String description,
    required SurveyType type,
    required List<SurveyQuestion> questions,
    required SurveySettings settings,
    String? instructions,
    String? completionMessage,
    required String createdBy,
    List<String>? targetDisorders,
    List<String>? targetAudience,
  }) async {
    final survey = AssessmentSurvey(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      type: type,
      questions: questions,
      settings: settings,
      instructions: instructions,
      completionMessage: completionMessage,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      targetDisorders: targetDisorders ?? [],
      targetAudience: targetAudience ?? [],
    );

    _surveys.add(survey);
    await _saveSurveys();

    return survey;
  }

  // Get all active surveys
  List<AssessmentSurvey> getAllSurveys() {
    return _surveys
        .where((survey) => survey.isActive)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get surveys by type
  List<AssessmentSurvey> getSurveysByType(SurveyType type) {
    return _surveys
        .where((survey) => survey.isActive && survey.type == type)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get surveys for disorder
  List<AssessmentSurvey> getSurveysForDisorder(String disorder) {
    return _surveys
        .where((survey) => 
            survey.isActive && 
            survey.targetDisorders.contains(disorder))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Start survey response
  Future<SurveyResponse> startSurveyResponse({
    required String surveyId,
    required String patientId,
  }) async {
    final response = SurveyResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surveyId: surveyId,
      patientId: patientId,
      startedAt: DateTime.now(),
      responses: {},
      status: SurveyStatus.inProgress,
    );

    _responses.add(response);
    await _saveResponses();

    return response;
  }

  // Update survey response
  Future<bool> updateSurveyResponse({
    required String responseId,
    required Map<String, dynamic> responses,
    String? notes,
  }) async {
    try {
      final index = _responses.indexWhere((response) => response.id == responseId);
      if (index == -1) return false;

      final response = _responses[index];
      final updatedResponse = SurveyResponse(
        id: response.id,
        surveyId: response.surveyId,
        patientId: response.patientId,
        startedAt: response.startedAt,
        completedAt: response.completedAt,
        responses: responses,
        status: response.status,
        scores: response.scores,
        interpretation: response.interpretation,
        notes: notes ?? response.notes,
        duration: response.duration,
      );

      _responses[index] = updatedResponse;
      await _saveResponses();
      return true;
    } catch (e) {
      print('Error updating survey response: $e');
      return false;
    }
  }

  // Complete survey response
  Future<bool> completeSurveyResponse({
    required String responseId,
    required Map<String, dynamic> responses,
    String? notes,
  }) async {
    try {
      final index = _responses.indexWhere((response) => response.id == responseId);
      if (index == -1) return false;

      final response = _responses[index];
      final survey = _surveys.firstWhere((s) => s.id == response.surveyId);
      
      // Calculate scores
      final scores = _calculateSurveyScores(survey, responses);
      
      // Generate interpretation
      final interpretation = _generateInterpretation(survey, scores);

      final updatedResponse = SurveyResponse(
        id: response.id,
        surveyId: response.surveyId,
        patientId: response.patientId,
        startedAt: response.startedAt,
        completedAt: DateTime.now(),
        responses: responses,
        status: SurveyStatus.completed,
        scores: scores,
        interpretation: interpretation,
        notes: notes ?? response.notes,
        duration: DateTime.now().difference(response.startedAt),
      );

      _responses[index] = updatedResponse;
      await _saveResponses();

      // Update schedule if exists
      await _updateScheduleStatus(response.patientId, response.surveyId);

      return true;
    } catch (e) {
      print('Error completing survey response: $e');
      return false;
    }
  }

  // Calculate survey scores
  Map<String, dynamic> _calculateSurveyScores(AssessmentSurvey survey, Map<String, dynamic> responses) {
    final scores = <String, dynamic>{};
    
    switch (survey.type) {
      case SurveyType.symptom:
        return _calculateSymptomScores(survey, responses);
      case SurveyType.outcome:
        return _calculateOutcomeScores(survey, responses);
      case SurveyType.satisfaction:
        return _calculateSatisfactionScores(survey, responses);
      default:
        return _calculateGenericScores(survey, responses);
    }
  }

  // Calculate symptom scores (e.g., PHQ-9, GAD-7)
  Map<String, dynamic> _calculateSymptomScores(AssessmentSurvey survey, Map<String, dynamic> responses) {
    final scores = <String, dynamic>{};
    int totalScore = 0;
    int answeredQuestions = 0;

    for (final question in survey.questions) {
      final response = responses[question.id];
      if (response != null && question.scoring != null) {
        final score = question.scoring!['${response}'] as int? ?? 0;
        totalScore += score;
        answeredQuestions++;
      }
    }

    scores['totalScore'] = totalScore;
    scores['answeredQuestions'] = answeredQuestions;
    scores['maxScore'] = survey.questions.length * 3; // Assuming max 3 points per question
    scores['percentage'] = answeredQuestions > 0 ? (totalScore / (answeredQuestions * 3)) * 100 : 0;

    // Add severity level
    if (survey.name.contains('PHQ-9')) {
      scores['severity'] = _getPHQ9Severity(totalScore);
    } else if (survey.name.contains('GAD-7')) {
      scores['severity'] = _getGAD7Severity(totalScore);
    }

    return scores;
  }

  // Calculate outcome scores
  Map<String, dynamic> _calculateOutcomeScores(AssessmentSurvey survey, Map<String, dynamic> responses) {
    final scores = <String, dynamic>{};
    double totalScore = 0;
    int answeredQuestions = 0;

    for (final question in survey.questions) {
      final response = responses[question.id];
      if (response != null && question.scoring != null) {
        final score = question.scoring!['${response}'] as double? ?? 0;
        totalScore += score;
        answeredQuestions++;
      }
    }

    scores['totalScore'] = totalScore;
    scores['averageScore'] = answeredQuestions > 0 ? totalScore / answeredQuestions : 0;
    scores['answeredQuestions'] = answeredQuestions;

    return scores;
  }

  // Calculate satisfaction scores
  Map<String, dynamic> _calculateSatisfactionScores(AssessmentSurvey survey, Map<String, dynamic> responses) {
    final scores = <String, dynamic>{};
    double totalScore = 0;
    int answeredQuestions = 0;

    for (final question in survey.questions) {
      final response = responses[question.id];
      if (response != null) {
        totalScore += (response as num).toDouble();
        answeredQuestions++;
      }
    }

    scores['totalScore'] = totalScore;
    scores['averageScore'] = answeredQuestions > 0 ? totalScore / answeredQuestions : 0;
    scores['satisfactionLevel'] = _getSatisfactionLevel(totalScore / answeredQuestions);

    return scores;
  }

  // Calculate generic scores
  Map<String, dynamic> _calculateGenericScores(AssessmentSurvey survey, Map<String, dynamic> responses) {
    final scores = <String, dynamic>{};
    scores['totalResponses'] = responses.length;
    scores['completionRate'] = (responses.length / survey.questions.length) * 100;
    return scores;
  }

  // Generate interpretation
  String _generateInterpretation(AssessmentSurvey survey, Map<String, dynamic> scores) {
    switch (survey.type) {
      case SurveyType.symptom:
        return _generateSymptomInterpretation(survey, scores);
      case SurveyType.outcome:
        return _generateOutcomeInterpretation(survey, scores);
      case SurveyType.satisfaction:
        return _generateSatisfactionInterpretation(survey, scores);
      default:
        return 'Anket tamamlandı. Sonuçlar değerlendirilmiştir.';
    }
  }

  // Generate symptom interpretation
  String _generateSymptomInterpretation(AssessmentSurvey survey, Map<String, dynamic> scores) {
    final totalScore = scores['totalScore'] as int? ?? 0;
    final severity = scores['severity'] as String? ?? 'Bilinmiyor';

    if (survey.name.contains('PHQ-9')) {
      return 'PHQ-9 Depresyon Skoru: $totalScore\nŞiddet: $severity\n\n$severity düzeyinde depresyon belirtileri tespit edilmiştir.';
    } else if (survey.name.contains('GAD-7')) {
      return 'GAD-7 Anksiyete Skoru: $totalScore\nŞiddet: $severity\n\n$severity düzeyinde anksiyete belirtileri tespit edilmiştir.';
    }

    return 'Semptom skoru: $totalScore\nŞiddet: $severity';
  }

  // Generate outcome interpretation
  String _generateOutcomeInterpretation(AssessmentSurvey survey, Map<String, dynamic> scores) {
    final averageScore = scores['averageScore'] as double? ?? 0;
    return 'Ortalama sonuç skoru: ${averageScore.toStringAsFixed(1)}\n\nTedavi sonuçları değerlendirilmiştir.';
  }

  // Generate satisfaction interpretation
  String _generateSatisfactionInterpretation(AssessmentSurvey survey, Map<String, dynamic> scores) {
    final satisfactionLevel = scores['satisfactionLevel'] as String? ?? 'Orta';
    return 'Memnuniyet düzeyi: $satisfactionLevel\n\nHasta memnuniyeti değerlendirilmiştir.';
  }

  // Get PHQ-9 severity
  String _getPHQ9Severity(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Hafif';
    if (score <= 14) return 'Orta';
    if (score <= 19) return 'Orta-Şiddetli';
    return 'Şiddetli';
  }

  // Get GAD-7 severity
  String _getGAD7Severity(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Hafif';
    if (score <= 14) return 'Orta';
    return 'Şiddetli';
  }

  // Get satisfaction level
  String _getSatisfactionLevel(double averageScore) {
    if (averageScore >= 4.5) return 'Çok Yüksek';
    if (averageScore >= 3.5) return 'Yüksek';
    if (averageScore >= 2.5) return 'Orta';
    if (averageScore >= 1.5) return 'Düşük';
    return 'Çok Düşük';
  }

  // Schedule survey
  Future<SurveySchedule> scheduleSurvey({
    required String surveyId,
    required String patientId,
    required ScheduleType type,
    required DateTime scheduledAt,
    String? reminderMessage,
  }) async {
    final schedule = SurveySchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surveyId: surveyId,
      patientId: patientId,
      type: type,
      scheduledAt: scheduledAt,
      reminderMessage: reminderMessage,
    );

    _schedules.add(schedule);
    await _saveSchedules();

    return schedule;
  }

  // Update schedule status
  Future<void> _updateScheduleStatus(String patientId, String surveyId) async {
    final index = _schedules.indexWhere((schedule) => 
        schedule.patientId == patientId && 
        schedule.surveyId == surveyId &&
        schedule.status == ScheduleStatus.pending);

    if (index != -1) {
      final schedule = _schedules[index];
      final updatedSchedule = SurveySchedule(
        id: schedule.id,
        surveyId: schedule.surveyId,
        patientId: schedule.patientId,
        type: schedule.type,
        scheduledAt: schedule.scheduledAt,
        completedAt: DateTime.now(),
        status: ScheduleStatus.completed,
        reminderMessage: schedule.reminderMessage,
        reminderCount: schedule.reminderCount,
        lastReminderSent: schedule.lastReminderSent,
        metadata: schedule.metadata,
      );

      _schedules[index] = updatedSchedule;
      await _saveSchedules();
    }
  }

  // Get responses for patient
  List<SurveyResponse> getResponsesForPatient(String patientId) {
    return _responses
        .where((response) => response.patientId == patientId)
        .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // Get responses for survey
  List<SurveyResponse> getResponsesForSurvey(String surveyId) {
    return _responses
        .where((response) => response.surveyId == surveyId)
        .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // Get pending schedules
  List<SurveySchedule> getPendingSchedules() {
    return _schedules
        .where((schedule) => schedule.status == ScheduleStatus.pending)
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Get overdue schedules
  List<SurveySchedule> getOverdueSchedules() {
    return _schedules
        .where((schedule) => schedule.isOverdue)
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Get survey statistics
  Map<String, dynamic> getSurveyStatistics() {
    final totalSurveys = _surveys.length;
    final activeSurveys = _surveys.where((survey) => survey.isActive).length;

    final totalResponses = _responses.length;
    final completedResponses = _responses
        .where((response) => response.status == SurveyStatus.completed)
        .length;
    final inProgressResponses = _responses
        .where((response) => response.status == SurveyStatus.inProgress)
        .length;

    final totalSchedules = _schedules.length;
    final pendingSchedules = _schedules
        .where((schedule) => schedule.status == ScheduleStatus.pending)
        .length;
    final completedSchedules = _schedules
        .where((schedule) => schedule.status == ScheduleStatus.completed)
        .length;

    return {
      'totalSurveys': totalSurveys,
      'activeSurveys': activeSurveys,
      'totalResponses': totalResponses,
      'completedResponses': completedResponses,
      'inProgressResponses': inProgressResponses,
      'totalSchedules': totalSchedules,
      'pendingSchedules': pendingSchedules,
      'completedSchedules': completedSchedules,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_surveys.isNotEmpty) return;

    // Add demo surveys
    final demoSurveys = [
      AssessmentSurvey(
        id: 'survey_001',
        name: 'PHQ-9 Depresyon Ölçeği',
        description: 'Depresyon belirtilerini değerlendiren 9 maddelik ölçek',
        type: SurveyType.symptom,
        questions: [
          SurveyQuestion(
            id: 'q_001',
            text: 'Son 2 hafta içinde, aşağıdaki sorunlardan hangisini ne sıklıkla yaşadınız?',
            type: QuestionType.multipleChoice,
            order: 1,
            options: [
              QuestionOption(id: 'opt_001', text: 'Hiç', value: 0),
              QuestionOption(id: 'opt_002', text: 'Birkaç gün', value: 1),
              QuestionOption(id: 'opt_003', text: 'Yarıdan fazla gün', value: 2),
              QuestionOption(id: 'opt_004', text: 'Neredeyse her gün', value: 3),
            ],
            scoring: {'0': 0, '1': 1, '2': 2, '3': 3},
          ),
        ],
        settings: const SurveySettings(
          allowSkip: false,
          showProgress: true,
          requireCompletion: true,
        ),
        instructions: 'Son 2 hafta içindeki durumunuzu düşünerek cevaplayın.',
        completionMessage: 'PHQ-9 ölçeği tamamlandı. Teşekkürler.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'admin',
        targetDisorders: ['Depresyon', 'Major Depresif Bozukluk'],
        targetAudience: ['Hasta'],
      ),
      AssessmentSurvey(
        id: 'survey_002',
        name: 'GAD-7 Anksiyete Ölçeği',
        description: 'Anksiyete belirtilerini değerlendiren 7 maddelik ölçek',
        type: SurveyType.symptom,
        questions: [
          SurveyQuestion(
            id: 'q_002',
            text: 'Son 2 hafta içinde, aşağıdaki sorunlardan hangisini ne sıklıkla yaşadınız?',
            type: QuestionType.multipleChoice,
            order: 1,
            options: [
              QuestionOption(id: 'opt_005', text: 'Hiç', value: 0),
              QuestionOption(id: 'opt_006', text: 'Birkaç gün', value: 1),
              QuestionOption(id: 'opt_007', text: 'Yarıdan fazla gün', value: 2),
              QuestionOption(id: 'opt_008', text: 'Neredeyse her gün', value: 3),
            ],
            scoring: {'0': 0, '1': 1, '2': 2, '3': 3},
          ),
        ],
        settings: const SurveySettings(
          allowSkip: false,
          showProgress: true,
          requireCompletion: true,
        ),
        instructions: 'Son 2 hafta içindeki durumunuzu düşünerek cevaplayın.',
        completionMessage: 'GAD-7 ölçeği tamamlandı. Teşekkürler.',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        createdBy: 'admin',
        targetDisorders: ['Anksiyete', 'Yaygın Anksiyete Bozukluğu'],
        targetAudience: ['Hasta'],
      ),
    ];

    for (final survey in demoSurveys) {
      _surveys.add(survey);
    }

    await _saveSurveys();

    // Add demo responses
    final demoResponses = [
      SurveyResponse(
        id: 'response_001',
        surveyId: 'survey_001',
        patientId: '1',
        startedAt: DateTime.now().subtract(const Duration(days: 5)),
        completedAt: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
        responses: {'q_001': 2},
        status: SurveyStatus.completed,
        scores: {'totalScore': 2, 'severity': 'Hafif'},
        interpretation: 'PHQ-9 Depresyon Skoru: 2\nŞiddet: Hafif\n\nHafif düzeyde depresyon belirtileri tespit edilmiştir.',
        duration: const Duration(minutes: 5),
      ),
    ];

    for (final response in demoResponses) {
      _responses.add(response);
    }

    await _saveResponses();

    print('✅ Demo assessment surveys created: ${demoSurveys.length}');
    print('✅ Demo survey responses created: ${demoResponses.length}');
  }
}
