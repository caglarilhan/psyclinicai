import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/clinical_psychologist_models.dart';
import 'audit_log_service.dart';

class ClinicalPsychologistService {
  static final ClinicalPsychologistService _instance = ClinicalPsychologistService._internal();
  factory ClinicalPsychologistService() => _instance;
  ClinicalPsychologistService._internal();

  static const _secureStorage = FlutterSecureStorage();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'psyclinicai.enc.db');
    String? encryptionKey = await _getEncryptionKey();
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      password: encryptionKey,
    );
  }

  Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: 'db_encryption_key');
    if (key == null) {
      key = _generateRandomKey();
      await _secureStorage.write(key: 'db_encryption_key', value: key);
    }
    return key;
  }

  String _generateRandomKey() {
    return 'clinical-psychologist-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE psychological_tests (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        abbreviation TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        age_range_min INTEGER NOT NULL,
        age_range_max INTEGER NOT NULL,
        administration_type TEXT NOT NULL,
        estimated_duration INTEGER NOT NULL,
        scoring_method TEXT NOT NULL,
        qualifications TEXT NOT NULL,
        languages TEXT NOT NULL,
        publisher TEXT NOT NULL,
        copyright_year TEXT NOT NULL,
        norms TEXT NOT NULL,
        subtests TEXT NOT NULL,
        interpretation TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE test_administrations (
        id TEXT PRIMARY KEY,
        test_id TEXT NOT NULL,
        patient_id TEXT NOT NULL,
        psychologist_id TEXT NOT NULL,
        administration_date TEXT NOT NULL,
        completion_date TEXT,
        administration_type TEXT NOT NULL,
        environment TEXT NOT NULL,
        examiner_notes TEXT NOT NULL,
        raw_scores TEXT NOT NULL,
        scaled_scores TEXT NOT NULL,
        percentile_ranks TEXT NOT NULL,
        interpretation TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE psychological_reports (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        psychologist_id TEXT NOT NULL,
        report_date TEXT NOT NULL,
        report_type TEXT NOT NULL,
        referral_question TEXT NOT NULL,
        background TEXT NOT NULL,
        behavioral_observations TEXT NOT NULL,
        test_administrations TEXT NOT NULL,
        test_results TEXT NOT NULL,
        interpretation TEXT NOT NULL,
        diagnostic_impressions TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        prognosis TEXT NOT NULL,
        signature TEXT NOT NULL,
        license_number TEXT NOT NULL,
        is_finalized INTEGER NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE supervision_sessions (
        id TEXT PRIMARY KEY,
        supervisee_id TEXT NOT NULL,
        supervisor_id TEXT NOT NULL,
        session_date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        session_type TEXT NOT NULL,
        cases_discussed TEXT NOT NULL,
        session_notes TEXT NOT NULL,
        learning_objectives TEXT NOT NULL,
        competencies_addressed TEXT NOT NULL,
        feedback TEXT NOT NULL,
        action_items TEXT NOT NULL,
        next_session_date TEXT NOT NULL,
        evaluation TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE competency_assessments (
        id TEXT PRIMARY KEY,
        psychologist_id TEXT NOT NULL,
        supervisor_id TEXT NOT NULL,
        assessment_date TEXT NOT NULL,
        competency_ratings TEXT NOT NULL,
        strengths TEXT NOT NULL,
        areas_for_improvement TEXT NOT NULL,
        development_goals TEXT NOT NULL,
        overall_assessment TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        next_assessment_date TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE test_batteries (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        test_ids TEXT NOT NULL,
        purpose TEXT NOT NULL,
        estimated_total_duration INTEGER NOT NULL,
        required_qualifications TEXT NOT NULL,
        administration_order TEXT NOT NULL,
        interpretation_guidelines TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultTests(db);
    await _createDefaultTestBatteries(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultTests(Database db) async {
    final tests = [
      PsychologicalTest(
        id: 'test_001',
        name: 'Wechsler Adult Intelligence Scale - Fourth Edition',
        abbreviation: 'WAIS-IV',
        category: TestCategory.intelligence,
        description: 'Comprehensive assessment of adult intellectual functioning',
        ageRangeMin: 16,
        ageRangeMax: 90,
        administrationType: TestAdministrationType.individual,
        estimatedDuration: 90,
        scoringMethod: ScoringMethod.computerAssisted,
        qualifications: ['Licensed Psychologist', 'Neuropsychologist'],
        languages: ['English', 'Spanish'],
        publisher: 'Pearson',
        copyrightYear: '2008',
        norms: {
          'ageGroups': ['16-17', '18-19', '20-24', '25-29', '30-34', '35-44', '45-54', '55-64', '65-69', '70-74', '75-79', '80-84', '85-90'],
          'standardization': 'US population',
          'sampleSize': 2200,
        },
        subtests: [
          'Block Design',
          'Similarities',
          'Digit Span',
          'Matrix Reasoning',
          'Vocabulary',
          'Arithmetic',
          'Symbol Search',
          'Visual Puzzles',
          'Information',
          'Coding',
          'Letter-Number Sequencing',
          'Figure Weights',
          'Comprehension',
          'Cancellation',
        ],
        interpretation: {
          'fullScaleIQ': 'Overall intellectual functioning',
          'indexScores': ['Verbal Comprehension', 'Perceptual Reasoning', 'Working Memory', 'Processing Speed'],
          'subtestScores': 'Individual cognitive abilities',
        },
      ),
      PsychologicalTest(
        id: 'test_002',
        name: 'Minnesota Multiphasic Personality Inventory-2',
        abbreviation: 'MMPI-2',
        category: TestCategory.personality,
        description: 'Comprehensive personality assessment and psychopathology screening',
        ageRangeMin: 18,
        ageRangeMax: 99,
        administrationType: TestAdministrationType.computer,
        estimatedDuration: 60,
        scoringMethod: ScoringMethod.automated,
        qualifications: ['Licensed Psychologist', 'Clinical Psychologist'],
        languages: ['English', 'Spanish'],
        publisher: 'University of Minnesota Press',
        copyrightYear: '1989',
        norms: {
          'ageGroups': ['18-24', '25-34', '35-44', '45-54', '55-64', '65+'],
          'standardization': 'US population',
          'sampleSize': 2600,
        },
        subtests: [
          'L (Lie)',
          'F (Infrequency)',
          'K (Defensiveness)',
          'Hs (Hypochondriasis)',
          'D (Depression)',
          'Hy (Hysteria)',
          'Pd (Psychopathic Deviate)',
          'Mf (Masculinity-Femininity)',
          'Pa (Paranoia)',
          'Pt (Psychasthenia)',
          'Sc (Schizophrenia)',
          'Ma (Hypomania)',
          'Si (Social Introversion)',
        ],
        interpretation: {
          'validityScales': ['L', 'F', 'K'],
          'clinicalScales': ['Hs', 'D', 'Hy', 'Pd', 'Mf', 'Pa', 'Pt', 'Sc', 'Ma', 'Si'],
          'contentScales': 'Specific symptom areas',
        },
      ),
      PsychologicalTest(
        id: 'test_003',
        name: 'Beck Depression Inventory-II',
        abbreviation: 'BDI-II',
        category: TestCategory.behavioral,
        description: 'Self-report measure of depression severity',
        ageRangeMin: 13,
        ageRangeMax: 99,
        administrationType: TestAdministrationType.paper,
        estimatedDuration: 10,
        scoringMethod: ScoringMethod.manual,
        qualifications: ['Licensed Mental Health Professional'],
        languages: ['English', 'Spanish', 'Turkish'],
        publisher: 'Pearson',
        copyrightYear: '1996',
        norms: {
          'ageGroups': ['13-17', '18-29', '30-39', '40-49', '50-59', '60+'],
          'standardization': 'US population',
          'sampleSize': 500,
        },
        subtests: [
          'Sadness',
          'Pessimism',
          'Past Failure',
          'Loss of Pleasure',
          'Guilty Feelings',
          'Punishment Feelings',
          'Self-Dislike',
          'Self-Criticalness',
          'Suicidal Thoughts',
          'Crying',
          'Agitation',
          'Loss of Interest',
          'Indecisiveness',
          'Worthlessness',
          'Loss of Energy',
          'Changes in Sleeping Pattern',
          'Irritability',
          'Changes in Appetite',
          'Concentration Difficulty',
          'Tiredness or Fatigue',
          'Loss of Interest in Sex',
        ],
        interpretation: {
          'severityLevels': {
            '0-13': 'Minimal depression',
            '14-19': 'Mild depression',
            '20-28': 'Moderate depression',
            '29-63': 'Severe depression',
          },
          'cutoffScore': 14,
        },
      ),
    ];

    for (final test in tests) {
      await db.insert('psychological_tests', {
        ...test.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _createDefaultTestBatteries(Database db) async {
    final batteries = [
      TestBattery(
        id: 'battery_001',
        name: 'Comprehensive Psychological Evaluation',
        description: 'Standard battery for comprehensive psychological assessment',
        testIds: ['test_001', 'test_002', 'test_003'],
        purpose: 'Comprehensive psychological evaluation for diagnostic purposes',
        estimatedTotalDuration: 180,
        requiredQualifications: ['Licensed Psychologist'],
        administrationOrder: {
          '1': 'test_003', // BDI-II (quick)
          '2': 'test_001', // WAIS-IV (long)
          '3': 'test_002', // MMPI-2 (medium)
        },
        interpretationGuidelines: [
          'Consider test-taking attitude and motivation',
          'Compare results to normative data',
          'Look for patterns across tests',
          'Consider cultural and linguistic factors',
        ],
      ),
      TestBattery(
        id: 'battery_002',
        name: 'Depression Assessment Battery',
        description: 'Focused battery for depression evaluation',
        testIds: ['test_003'],
        purpose: 'Assessment of depression severity and symptoms',
        estimatedTotalDuration: 15,
        requiredQualifications: ['Licensed Mental Health Professional'],
        administrationOrder: {
          '1': 'test_003',
        },
        interpretationGuidelines: [
          'Consider severity level',
          'Monitor for suicidal ideation',
          'Assess functional impairment',
          'Plan treatment accordingly',
        ],
      ),
    ];

    for (final battery in batteries) {
      await db.insert('test_batteries', {
        ...battery.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Test Management
  Future<List<PsychologicalTest>> getAvailableTests() async {
    final db = await database;
    final result = await db.query(
      'psychological_tests',
      orderBy: 'name ASC',
    );
    
    return result.map((json) => PsychologicalTest.fromJson(json)).toList();
  }

  Future<List<PsychologicalTest>> getTestsByCategory(TestCategory category) async {
    final db = await database;
    final result = await db.query(
      'psychological_tests',
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'name ASC',
    );
    
    return result.map((json) => PsychologicalTest.fromJson(json)).toList();
  }

  Future<PsychologicalTest?> getTest(String testId) async {
    final db = await database;
    final result = await db.query(
      'psychological_tests',
      where: 'id = ?',
      whereArgs: [testId],
    );
    
    if (result.isEmpty) return null;
    return PsychologicalTest.fromJson(result.first);
  }

  // Test Administration Management
  Future<String> startTestAdministration({
    required String testId,
    required String patientId,
    required String psychologistId,
    required TestAdministrationType administrationType,
    required String environment,
  }) async {
    final db = await database;
    final administrationId = 'ta_${DateTime.now().millisecondsSinceEpoch}';
    
    final administration = TestAdministration(
      id: administrationId,
      testId: testId,
      patientId: patientId,
      psychologistId: psychologistId,
      administrationDate: DateTime.now(),
      administrationType: administrationType,
      environment: environment,
      examinerNotes: '',
      rawScores: {},
      scaledScores: {},
      percentileRanks: {},
      interpretation: '',
      recommendations: [],
    );
    
    await db.insert('test_administrations', {
      ...administration.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'test_administration.start',
      details: 'Test administration started: $administrationId',
      userId: psychologistId,
      resourceId: administrationId,
    );
    
    return administrationId;
  }

  Future<bool> completeTestAdministration({
    required String administrationId,
    required String examinerNotes,
    required Map<String, dynamic> rawScores,
    required Map<String, dynamic> scaledScores,
    required Map<String, dynamic> percentileRanks,
    required String interpretation,
    required List<String> recommendations,
  }) async {
    final db = await database;
    
    final result = await db.update(
      'test_administrations',
      {
        'completion_date': DateTime.now().toIso8601String(),
        'examiner_notes': examinerNotes,
        'raw_scores': jsonEncode(rawScores),
        'scaled_scores': jsonEncode(scaledScores),
        'percentile_ranks': jsonEncode(percentileRanks),
        'interpretation': interpretation,
        'recommendations': jsonEncode(recommendations),
        'is_completed': 1,
      },
      where: 'id = ?',
      whereArgs: [administrationId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'test_administration.complete',
        details: 'Test administration completed: $administrationId',
        userId: 'system',
        resourceId: administrationId,
      );
    }
    
    return result > 0;
  }

  Future<List<TestAdministration>> getPatientTestAdministrations(String patientId) async {
    final db = await database;
    final result = await db.query(
      'test_administrations',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'administration_date DESC',
    );
    
    return result.map((json) => TestAdministration.fromJson(json)).toList();
  }

  Future<List<TestAdministration>> getPsychologistTestAdministrations(String psychologistId) async {
    final db = await database;
    final result = await db.query(
      'test_administrations',
      where: 'psychologist_id = ?',
      whereArgs: [psychologistId],
      orderBy: 'administration_date DESC',
    );
    
    return result.map((json) => TestAdministration.fromJson(json)).toList();
  }

  // Psychological Report Management
  Future<String> createPsychologicalReport({
    required String patientId,
    required String psychologistId,
    required String reportType,
    required String referralQuestion,
    required String background,
    required String behavioralObservations,
    required List<TestAdministration> testAdministrations,
    required String testResults,
    required String interpretation,
    required String diagnosticImpressions,
    required List<String> recommendations,
    required String prognosis,
    required String signature,
    required String licenseNumber,
  }) async {
    final db = await database;
    final reportId = 'pr_${DateTime.now().millisecondsSinceEpoch}';
    
    final report = PsychologicalReport(
      id: reportId,
      patientId: patientId,
      psychologistId: psychologistId,
      reportDate: DateTime.now(),
      reportType: reportType,
      referralQuestion: referralQuestion,
      background: background,
      behavioralObservations: behavioralObservations,
      testAdministrations: testAdministrations,
      testResults: testResults,
      interpretation: interpretation,
      diagnosticImpressions: diagnosticImpressions,
      recommendations: recommendations,
      prognosis: prognosis,
      signature: signature,
      licenseNumber: licenseNumber,
    );
    
    await db.insert('psychological_reports', {
      ...report.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'psychological_report.create',
      details: 'Psychological report created: $reportId',
      userId: psychologistId,
      resourceId: reportId,
    );
    
    return reportId;
  }

  Future<List<PsychologicalReport>> getPatientReports(String patientId) async {
    final db = await database;
    final result = await db.query(
      'psychological_reports',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'report_date DESC',
    );
    
    return result.map((json) => PsychologicalReport.fromJson(json)).toList();
  }

  Future<List<PsychologicalReport>> getPsychologistReports(String psychologistId) async {
    final db = await database;
    final result = await db.query(
      'psychological_reports',
      where: 'psychologist_id = ?',
      whereArgs: [psychologistId],
      orderBy: 'report_date DESC',
    );
    
    return result.map((json) => PsychologicalReport.fromJson(json)).toList();
  }

  // Supervision Management
  Future<String> createSupervisionSession({
    required String superviseeId,
    required String supervisorId,
    required int duration,
    required String sessionType,
    required List<String> casesDiscussed,
    required String sessionNotes,
    required List<String> learningObjectives,
    required List<String> competenciesAddressed,
    required String feedback,
    required List<String> actionItems,
    required DateTime nextSessionDate,
    required Map<String, dynamic> evaluation,
  }) async {
    final db = await database;
    final sessionId = 'ss_${DateTime.now().millisecondsSinceEpoch}';
    
    final session = SupervisionSession(
      id: sessionId,
      superviseeId: superviseeId,
      supervisorId: supervisorId,
      sessionDate: DateTime.now(),
      duration: duration,
      sessionType: sessionType,
      casesDiscussed: casesDiscussed,
      sessionNotes: sessionNotes,
      learningObjectives: learningObjectives,
      competenciesAddressed: competenciesAddressed,
      feedback: feedback,
      actionItems: actionItems,
      nextSessionDate: nextSessionDate,
      evaluation: evaluation,
    );
    
    await db.insert('supervision_sessions', {
      ...session.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'supervision_session.create',
      details: 'Supervision session created: $sessionId',
      userId: supervisorId,
      resourceId: sessionId,
    );
    
    return sessionId;
  }

  Future<List<SupervisionSession>> getSupervisionSessions(String superviseeId) async {
    final db = await database;
    final result = await db.query(
      'supervision_sessions',
      where: 'supervisee_id = ?',
      whereArgs: [superviseeId],
      orderBy: 'session_date DESC',
    );
    
    return result.map((json) => SupervisionSession.fromJson(json)).toList();
  }

  // Competency Assessment Management
  Future<String> createCompetencyAssessment({
    required String psychologistId,
    required String supervisorId,
    required Map<String, int> competencyRatings,
    required List<String> strengths,
    required List<String> areasForImprovement,
    required List<String> developmentGoals,
    required String overallAssessment,
    required List<String> recommendations,
    required DateTime nextAssessmentDate,
  }) async {
    final db = await database;
    final assessmentId = 'ca_${DateTime.now().millisecondsSinceEpoch}';
    
    final assessment = CompetencyAssessment(
      id: assessmentId,
      psychologistId: psychologistId,
      supervisorId: supervisorId,
      assessmentDate: DateTime.now(),
      competencyRatings: competencyRatings,
      strengths: strengths,
      areasForImprovement: areasForImprovement,
      developmentGoals: developmentGoals,
      overallAssessment: overallAssessment,
      recommendations: recommendations,
      nextAssessmentDate: nextAssessmentDate,
    );
    
    await db.insert('competency_assessments', {
      ...assessment.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'competency_assessment.create',
      details: 'Competency assessment created: $assessmentId',
      userId: supervisorId,
      resourceId: assessmentId,
    );
    
    return assessmentId;
  }

  Future<List<CompetencyAssessment>> getCompetencyAssessments(String psychologistId) async {
    final db = await database;
    final result = await db.query(
      'competency_assessments',
      where: 'psychologist_id = ?',
      whereArgs: [psychologistId],
      orderBy: 'assessment_date DESC',
    );
    
    return result.map((json) => CompetencyAssessment.fromJson(json)).toList();
  }

  // Test Battery Management
  Future<List<TestBattery>> getAvailableTestBatteries() async {
    final db = await database;
    final result = await db.query(
      'test_batteries',
      orderBy: 'name ASC',
    );
    
    return result.map((json) => TestBattery.fromJson(json)).toList();
  }

  Future<TestBattery?> getTestBattery(String batteryId) async {
    final db = await database;
    final result = await db.query(
      'test_batteries',
      where: 'id = ?',
      whereArgs: [batteryId],
    );
    
    if (result.isEmpty) return null;
    return TestBattery.fromJson(result.first);
  }

  // AI-Powered Features for Clinical Psychologists
  Future<Map<String, dynamic>> generateTestInterpretation({
    required String testId,
    required Map<String, dynamic> rawScores,
    required Map<String, dynamic> patientFactors,
  }) async {
    // Mock AI interpretation - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final interpretations = <String>[];
    final recommendations = <String>[];
    final alerts = <String>[];
    
    switch (testId) {
      case 'test_001': // WAIS-IV
        final fullScaleIQ = rawScores['fullScaleIQ'] as int? ?? 100;
        if (fullScaleIQ < 70) {
          interpretations.add('Zihinsel engel alanında');
          recommendations.add('Özel eğitim değerlendirmesi');
        } else if (fullScaleIQ > 130) {
          interpretations.add('Üstün zeka alanında');
          recommendations.add('Üstün yetenekli eğitim değerlendirmesi');
        } else {
          interpretations.add('Normal zeka aralığında');
        }
        break;
      case 'test_002': // MMPI-2
        final clinicalScales = rawScores['clinicalScales'] as Map<String, dynamic>? ?? {};
        if (clinicalScales['D'] != null && clinicalScales['D'] > 70) {
          interpretations.add('Depresif semptomlar belirgin');
          recommendations.add('Depresyon değerlendirmesi');
        }
        if (clinicalScales['Sc'] != null && clinicalScales['Sc'] > 80) {
          alerts.add('Psikotik semptomlar - acil değerlendirme');
        }
        break;
      case 'test_003': // BDI-II
        final totalScore = rawScores['totalScore'] as int? ?? 0;
        if (totalScore >= 29) {
          interpretations.add('Ağır depresyon');
          alerts.add('İntihar riski değerlendirmesi gerekli');
          recommendations.add('Acil psikiyatrik konsültasyon');
        } else if (totalScore >= 20) {
          interpretations.add('Orta depresyon');
          recommendations.add('Psikoterapi değerlendirmesi');
        } else if (totalScore >= 14) {
          interpretations.add('Hafif depresyon');
          recommendations.add('Hafif müdahale önerileri');
        }
        break;
    }
    
    return {
      'interpretations': interpretations,
      'recommendations': recommendations,
      'alerts': alerts,
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'evidence': 'Standardized test interpretation guidelines',
    };
  }

  Future<Map<String, dynamic>> generateReportSummary({
    required List<TestAdministration> testAdministrations,
    required String referralQuestion,
    required Map<String, dynamic> patientFactors,
  }) async {
    // Mock AI report summary - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 3));
    
    final summary = <String>[];
    final keyFindings = <String>[];
    final recommendations = <String>[];
    
    // Test sonuçlarına göre özet
    for (final administration in testAdministrations) {
      if (administration.isCompleted) {
        final test = await getTest(administration.testId);
        if (test != null) {
          keyFindings.add('${test.abbreviation}: ${administration.interpretation}');
        }
      }
    }
    
    // Referral question'a göre öneriler
    if (referralQuestion.toLowerCase().contains('depresyon')) {
      recommendations.add('Depresyon değerlendirmesi tamamlandı');
      recommendations.add('Psikoterapi önerisi');
      recommendations.add('İlaç değerlendirmesi için psikiyatrist konsültasyonu');
    }
    
    if (referralQuestion.toLowerCase().contains('zeka') || referralQuestion.toLowerCase().contains('bilişsel')) {
      recommendations.add('Bilişsel değerlendirme tamamlandı');
      recommendations.add('Eğitim planı önerisi');
      recommendations.add('Aile danışmanlığı');
    }
    
    summary.add('Kapsamlı psikolojik değerlendirme tamamlandı');
    summary.add('Test sonuçları tutarlı ve güvenilir');
    summary.add('Öneriler hasta ihtiyaçlarına uygun');
    
    return {
      'summary': summary,
      'keyFindings': keyFindings,
      'recommendations': recommendations,
      'confidence': 0.90 + (Random().nextDouble() * 0.05),
      'evidence': 'Standardized assessment procedures',
    };
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getClinicalPsychologistStatistics(String psychologistId) async {
    final db = await database;
    
    final testAdministrationsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM test_administrations 
      WHERE psychologist_id = ?
    ''', [psychologistId]);
    
    final reportsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM psychological_reports 
      WHERE psychologist_id = ?
    ''', [psychologistId]);
    
    final supervisionSessionsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM supervision_sessions 
      WHERE supervisee_id = ?
    ''', [psychologistId]);
    
    final competencyAssessmentsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM competency_assessments 
      WHERE psychologist_id = ?
    ''', [psychologistId]);
    
    return {
      'totalTestAdministrations': testAdministrationsResult.first['count'] as int,
      'totalReports': reportsResult.first['count'] as int,
      'totalSupervisionSessions': supervisionSessionsResult.first['count'] as int,
      'totalCompetencyAssessments': competencyAssessmentsResult.first['count'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getTestUsageStats(String psychologistId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        pt.name,
        pt.category,
        COUNT(ta.id) as administration_count,
        AVG(CASE WHEN ta.is_completed = 1 THEN 1 ELSE 0 END) as completion_rate
      FROM psychological_tests pt
      LEFT JOIN test_administrations ta ON ta.test_id = pt.id
      WHERE ta.psychologist_id = ?
      GROUP BY pt.id, pt.name, pt.category
      ORDER BY administration_count DESC
    ''', [psychologistId]);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getDiagnosticAccuracy(String psychologistId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        pr.diagnostic_impressions,
        COUNT(*) as case_count,
        AVG(CASE WHEN pr.is_finalized = 1 THEN 1 ELSE 0 END) as finalization_rate
      FROM psychological_reports pr
      WHERE pr.psychologist_id = ?
      GROUP BY pr.diagnostic_impressions
      ORDER BY case_count DESC
    ''', [psychologistId]);
    
    return result;
  }
}
