import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/psychiatric_assessment_models.dart';

class PsychiatricAssessmentService {
  static final PsychiatricAssessmentService _instance = PsychiatricAssessmentService._internal();
  factory PsychiatricAssessmentService() => _instance;
  PsychiatricAssessmentService._internal();

  final List<PsychiatricAssessment> _assessments = [];
  final List<PsychologicalTest> _tests = [];
  final List<TestResult> _testResults = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadAssessments();
    await _loadTests();
    await _loadTestResults();
  }

  // Load assessments from storage
  Future<void> _loadAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = prefs.getStringList('psychiatric_assessments') ?? [];
      _assessments.clear();
      
      for (final assessmentJson in assessmentsJson) {
        final assessment = PsychiatricAssessment.fromJson(jsonDecode(assessmentJson));
        _assessments.add(assessment);
      }
    } catch (e) {
      print('Error loading psychiatric assessments: $e');
      _assessments.clear();
    }
  }

  // Save assessments to storage
  Future<void> _saveAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = _assessments
          .map((assessment) => jsonEncode(assessment.toJson()))
          .toList();
      await prefs.setStringList('psychiatric_assessments', assessmentsJson);
    } catch (e) {
      print('Error saving psychiatric assessments: $e');
    }
  }

  // Load tests from storage
  Future<void> _loadTests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final testsJson = prefs.getStringList('psychological_tests') ?? [];
      _tests.clear();
      
      for (final testJson in testsJson) {
        final test = PsychologicalTest.fromJson(jsonDecode(testJson));
        _tests.add(test);
      }
    } catch (e) {
      print('Error loading psychological tests: $e');
      _tests.clear();
    }
  }

  // Save tests to storage
  Future<void> _saveTests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final testsJson = _tests
          .map((test) => jsonEncode(test.toJson()))
          .toList();
      await prefs.setStringList('psychological_tests', testsJson);
    } catch (e) {
      print('Error saving psychological tests: $e');
    }
  }

  // Load test results from storage
  Future<void> _loadTestResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = prefs.getStringList('test_results') ?? [];
      _testResults.clear();
      
      for (final resultJson in resultsJson) {
        final result = TestResult.fromJson(jsonDecode(resultJson));
        _testResults.add(result);
      }
    } catch (e) {
      print('Error loading test results: $e');
      _tests.clear();
    }
  }

  // Save test results to storage
  Future<void> _saveTestResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = _testResults
          .map((result) => jsonEncode(result.toJson()))
          .toList();
      await prefs.setStringList('test_results', resultsJson);
    } catch (e) {
      print('Error saving test results: $e');
    }
  }

  // Create new psychiatric assessment
  Future<PsychiatricAssessment> createAssessment({
    required String patientId,
    required String clinicianId,
    required AssessmentType type,
    required String chiefComplaint,
    required String historyOfPresentIllness,
    required String psychiatricHistory,
    required String familyHistory,
    required String socialHistory,
    required String medicalHistory,
    required MentalStatusExamination mse,
    required List<String> diagnoses,
    required String clinicalFormulation,
    required String treatmentRecommendations,
    String? notes,
  }) async {
    final assessment = PsychiatricAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      clinicianId: clinicianId,
      type: type,
      assessmentDate: DateTime.now(),
      chiefComplaint: chiefComplaint,
      historyOfPresentIllness: historyOfPresentIllness,
      psychiatricHistory: psychiatricHistory,
      familyHistory: familyHistory,
      socialHistory: socialHistory,
      medicalHistory: medicalHistory,
      mse: mse,
      diagnoses: diagnoses,
      clinicalFormulation: clinicalFormulation,
      treatmentRecommendations: treatmentRecommendations,
      notes: notes,
      status: AssessmentStatus.completed,
      createdAt: DateTime.now(),
    );

    _assessments.add(assessment);
    await _saveAssessments();

    return assessment;
  }

  // Get assessments for patient
  List<PsychiatricAssessment> getAssessmentsForPatient(String patientId) {
    return _assessments
        .where((assessment) => assessment.patientId == patientId)
        .toList()
        ..sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));
  }

  // Get latest assessment for patient
  PsychiatricAssessment? getLatestAssessmentForPatient(String patientId) {
    final assessments = getAssessmentsForPatient(patientId);
    return assessments.isNotEmpty ? assessments.first : null;
  }

  // Get assessments by type
  List<PsychiatricAssessment> getAssessmentsByType(AssessmentType type) {
    return _assessments
        .where((assessment) => assessment.type == type)
        .toList()
        ..sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));
  }

  // Get all psychological tests
  List<PsychologicalTest> getAllTests() {
    return _tests.where((test) => test.isActive).toList();
  }

  // Get tests by category
  List<PsychologicalTest> getTestsByCategory(TestCategory category) {
    return _tests
        .where((test) => test.isActive && test.category == category)
        .toList();
  }

  // Get tests for age range
  List<PsychologicalTest> getTestsForAge(int age) {
    return _tests
        .where((test) => 
            test.isActive && 
            age >= test.ageRangeMin && 
            age <= test.ageRangeMax)
        .toList();
  }

  // Administer psychological test
  Future<TestResult> administerTest({
    required String testId,
    required String patientId,
    required String administeredBy,
    required Map<String, dynamic> responses,
    String? notes,
  }) async {
    final test = _tests.firstWhere((t) => t.id == testId);
    
    // Calculate scores based on responses
    final scores = _calculateTestScores(test, responses);
    
    // Generate interpretation
    final interpretation = _generateInterpretation(test, scores);
    
    // Generate recommendations
    final recommendations = _generateRecommendations(test, scores);

    final result = TestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: testId,
      patientId: patientId,
      administeredBy: administeredBy,
      administeredAt: DateTime.now(),
      responses: responses,
      scores: scores,
      interpretation: interpretation,
      recommendations: recommendations,
      validity: _assessTestValidity(test, responses),
      notes: notes,
    );

    _testResults.add(result);
    await _saveTestResults();

    return result;
  }

  // Calculate test scores
  Map<String, dynamic> _calculateTestScores(PsychologicalTest test, Map<String, dynamic> responses) {
    final scores = <String, dynamic>{};
    
    switch (test.scoringMethod) {
      case ScoringMethod.sum:
        int totalScore = 0;
        for (final question in test.questions) {
          final response = responses[question.id];
          if (response != null && question.scoring != null) {
            totalScore += question.scoring![response.toString()] ?? 0;
          }
        }
        scores['totalScore'] = totalScore;
        scores['maxScore'] = test.questions.length * 4; // Assuming max 4 points per question
        scores['percentage'] = (totalScore / (test.questions.length * 4)) * 100;
        break;
        
      case ScoringMethod.average:
        double totalScore = 0;
        int validResponses = 0;
        for (final question in test.questions) {
          final response = responses[question.id];
          if (response != null && question.scoring != null) {
            totalScore += question.scoring![response.toString()] ?? 0;
            validResponses++;
          }
        }
        scores['averageScore'] = validResponses > 0 ? totalScore / validResponses : 0;
        break;
        
      case ScoringMethod.weighted:
        // Implement weighted scoring based on test-specific weights
        scores['weightedScore'] = 0; // Placeholder
        break;
        
      default:
        scores['rawScore'] = responses.length;
    }
    
    return scores;
  }

  // Generate interpretation
  String _generateInterpretation(PsychologicalTest test, Map<String, dynamic> scores) {
    final totalScore = scores['totalScore'] as int? ?? 0;
    final percentage = scores['percentage'] as double? ?? 0;
    
    switch (test.category) {
      case TestCategory.mood:
        if (percentage >= 70) {
          return 'Yüksek depresyon belirtileri gözlenmektedir. Acil müdahale önerilir.';
        } else if (percentage >= 50) {
          return 'Orta düzeyde depresyon belirtileri mevcuttur. Tedavi planı gözden geçirilmelidir.';
        } else if (percentage >= 30) {
          return 'Hafif depresyon belirtileri görülmektedir. Takip önerilir.';
        } else {
          return 'Depresyon belirtileri minimal düzeydedir.';
        }
        
      case TestCategory.anxiety:
        if (percentage >= 70) {
          return 'Yüksek anksiyete düzeyi tespit edilmiştir. Anksiyete tedavisi önerilir.';
        } else if (percentage >= 50) {
          return 'Orta düzeyde anksiyete belirtileri mevcuttur.';
        } else if (percentage >= 30) {
          return 'Hafif anksiyete belirtileri görülmektedir.';
        } else {
          return 'Anksiyete düzeyi normal sınırlar içindedir.';
        }
        
      case TestCategory.personality:
        return 'Kişilik değerlendirmesi tamamlanmıştır. Detaylı analiz için ek değerlendirmeler önerilir.';
        
      default:
        return 'Test sonuçları değerlendirilmiştir. Klinik görüşme ile birlikte yorumlanmalıdır.';
    }
  }

  // Generate recommendations
  String _generateRecommendations(PsychologicalTest test, Map<String, dynamic> scores) {
    final percentage = scores['percentage'] as double? ?? 0;
    
    switch (test.category) {
      case TestCategory.mood:
        if (percentage >= 70) {
          return '1. Acil psikiyatrik değerlendirme\n2. İntihar riski değerlendirmesi\n3. Antidepresan tedavi düşünülmeli\n4. Psikoterapi önerilir';
        } else if (percentage >= 50) {
          return '1. Psikoterapi başlatılmalı\n2. İlaç tedavisi değerlendirilmeli\n3. Düzenli takip\n4. Aile desteği sağlanmalı';
        } else {
          return '1. Psikoeğitim\n2. Yaşam tarzı değişiklikleri\n3. Düzenli takip\n4. Erken müdahale için hazırlık';
        }
        
      case TestCategory.anxiety:
        if (percentage >= 70) {
          return '1. Anksiyete tedavisi başlatılmalı\n2. Nefes egzersizleri\n3. Anksiyolitik ilaç değerlendirmesi\n4. CBT önerilir';
        } else if (percentage >= 50) {
          return '1. Anksiyete yönetimi teknikleri\n2. Gevşeme egzersizleri\n3. Psikoterapi\n4. Stres yönetimi';
        } else {
          return '1. Anksiyete önleme stratejileri\n2. Sağlıklı yaşam tarzı\n3. Düzenli egzersiz\n4. Takip';
        }
        
      default:
        return 'Test sonuçlarına göre uygun müdahale stratejileri belirlenmelidir.';
    }
  }

  // Assess test validity
  TestValidity _assessTestValidity(PsychologicalTest test, Map<String, dynamic> responses) {
    // Check if all questions are answered
    if (responses.length < test.questions.length) {
      return TestValidity.incomplete;
    }
    
    // Check for random responding (same answer pattern)
    final values = responses.values.toList();
    if (values.length > 5) {
      final firstValue = values.first;
      if (values.every((value) => value == firstValue)) {
        return TestValidity.questionable;
      }
    }
    
    return TestValidity.valid;
  }

  // Get test results for patient
  List<TestResult> getTestResultsForPatient(String patientId) {
    return _testResults
        .where((result) => result.patientId == patientId)
        .toList()
        ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));
  }

  // Get test results for test
  List<TestResult> getTestResultsForTest(String testId) {
    return _testResults
        .where((result) => result.testId == testId)
        .toList()
        ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));
  }

  // Get assessment statistics
  Map<String, dynamic> getAssessmentStatistics() {
    final totalAssessments = _assessments.length;
    final initialAssessments = _assessments
        .where((assessment) => assessment.type == AssessmentType.initial)
        .length;
    final followUpAssessments = _assessments
        .where((assessment) => assessment.type == AssessmentType.followUp)
        .length;
    final crisisAssessments = _assessments
        .where((assessment) => assessment.type == AssessmentType.crisis)
        .length;

    final totalTests = _testResults.length;
    final validTests = _testResults
        .where((result) => result.validity == TestValidity.valid)
        .length;
    final invalidTests = _testResults
        .where((result) => result.validity == TestValidity.invalid)
        .length;

    return {
      'totalAssessments': totalAssessments,
      'initialAssessments': initialAssessments,
      'followUpAssessments': followUpAssessments,
      'crisisAssessments': crisisAssessments,
      'totalTests': totalTests,
      'validTests': validTests,
      'invalidTests': invalidTests,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_assessments.isNotEmpty) return;

    // Add demo psychological tests
    final demoTests = [
      PsychologicalTest(
        id: 'test_001',
        name: 'Beck Depresyon Envanteri (BDI-II)',
        description: 'Depresyon belirtilerini değerlendiren 21 maddelik ölçek',
        category: TestCategory.mood,
        ageRangeMin: 13,
        ageRangeMax: 80,
        estimatedDuration: const Duration(minutes: 10),
        languages: ['tr', 'en'],
        questions: [
          TestQuestion(
            id: 'q_001',
            questionText: 'Üzüntü hissetmiyorum',
            type: QuestionType.multipleChoice,
            options: ['Hiç', 'Hafif', 'Orta', 'Şiddetli'],
            scoring: {'0': 0, '1': 1, '2': 2, '3': 3},
          ),
          TestQuestion(
            id: 'q_002',
            questionText: 'Geleceğe karşı umutsuzum',
            type: QuestionType.multipleChoice,
            options: ['Hiç', 'Hafif', 'Orta', 'Şiddetli'],
            scoring: {'0': 0, '1': 1, '2': 2, '3': 3},
          ),
        ],
        scoringMethod: ScoringMethod.sum,
        instructions: 'Son 2 hafta içindeki durumunuzu düşünerek cevaplayın.',
      ),
      PsychologicalTest(
        id: 'test_002',
        name: 'Beck Anksiyete Envanteri (BAI)',
        description: 'Anksiyete belirtilerini değerlendiren 21 maddelik ölçek',
        category: TestCategory.anxiety,
        ageRangeMin: 17,
        ageRangeMax: 80,
        estimatedDuration: const Duration(minutes: 8),
        languages: ['tr', 'en'],
        questions: [
          TestQuestion(
            id: 'q_003',
            questionText: 'Uyuşma ve karıncalanma',
            type: QuestionType.multipleChoice,
            options: ['Hiç', 'Hafif', 'Orta', 'Şiddetli'],
            scoring: {'0': 0, '1': 1, '2': 2, '3': 3},
          ),
          TestQuestion(
            id: 'q_004',
            questionText: 'Sıcak basması',
            type: QuestionType.multipleChoice,
            options: ['Hiç', 'Hafif', 'Orta', 'Şiddetli'],
            scoring: {'0': 0, '1': 1, '2': 2, '3': 3},
          ),
        ],
        scoringMethod: ScoringMethod.sum,
        instructions: 'Son hafta içinde yaşadığınız belirtileri değerlendirin.',
      ),
    ];

    for (final test in demoTests) {
      _tests.add(test);
    }

    await _saveTests();

    // Add demo assessments
    final demoAssessments = [
      PsychiatricAssessment(
        id: 'assess_001',
        patientId: '1',
        clinicianId: 'psychiatrist_001',
        type: AssessmentType.initial,
        assessmentDate: DateTime.now().subtract(const Duration(days: 7)),
        chiefComplaint: 'Depresyon, uykusuzluk, iştahsızlık',
        historyOfPresentIllness: 'Son 3 aydır devam eden depresif belirtiler...',
        psychiatricHistory: 'Geçmişte panik atak öyküsü var',
        familyHistory: 'Anne tarafında depresyon öyküsü',
        socialHistory: 'Evli, 2 çocuk, öğretmen',
        medicalHistory: 'Hipertansiyon, diyabet',
        mse: const MentalStatusExamination(
          appearance: 'Bakımsız, üzgün görünüm',
          behavior: 'Yavaş hareketler, göz teması az',
          speech: 'Yavaş, monoton',
          mood: 'Depresif',
          affect: 'Kısıtlı',
          thoughtProcess: 'Yavaş',
          thoughtContent: 'Umutsuzluk düşünceleri',
          perceptions: 'Normal',
          cognition: 'Orientasyon tam',
          insight: 'İyi',
          judgment: 'İyi',
          suicidalIdeation: 'Pasif ölüm düşünceleri',
          homicidalIdeation: 'Yok',
          substanceUse: 'Yok',
        ),
        diagnoses: ['Major Depresif Bozukluk', 'Uyku Bozukluğu'],
        clinicalFormulation: 'Stres faktörleri ile tetiklenen depresif epizod',
        treatmentRecommendations: 'SSRI başlatılmalı, psikoterapi önerilir',
        status: AssessmentStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    for (final assessment in demoAssessments) {
      _assessments.add(assessment);
    }

    await _saveAssessments();

    print('✅ Demo psychiatric assessments created: ${demoAssessments.length}');
    print('✅ Demo psychological tests created: ${demoTests.length}');
  }
}
