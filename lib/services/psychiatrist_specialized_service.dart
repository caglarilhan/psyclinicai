import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/psychiatrist_specialized_models.dart';
import 'audit_log_service.dart';

class PsychiatristSpecializedService {
  static final PsychiatristSpecializedService _instance = PsychiatristSpecializedService._internal();
  factory PsychiatristSpecializedService() => _instance;
  PsychiatristSpecializedService._internal();

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
    return 'psychiatrist-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        generic_name TEXT NOT NULL,
        type TEXT NOT NULL,
        indications TEXT NOT NULL,
        contraindications TEXT NOT NULL,
        side_effects TEXT NOT NULL,
        dosing TEXT NOT NULL,
        interactions TEXT NOT NULL,
        pregnancy_category TEXT NOT NULL,
        requires_monitoring INTEGER NOT NULL,
        required_labs TEXT NOT NULL,
        half_life TEXT NOT NULL,
        metabolism TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prescriptions (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        psychiatrist_id TEXT NOT NULL,
        medications TEXT NOT NULL,
        prescribed_at TEXT NOT NULL,
        valid_until TEXT,
        instructions TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        is_refillable INTEGER NOT NULL,
        refill_count INTEGER NOT NULL,
        pharmacy_notes TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE side_effect_reports (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        prescription_id TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        side_effect TEXT NOT NULL,
        severity TEXT NOT NULL,
        reported_at TEXT NOT NULL,
        reported_by TEXT NOT NULL,
        description TEXT NOT NULL,
        requires_action INTEGER NOT NULL,
        action_taken TEXT,
        resolved_at TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE lab_tests (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        psychiatrist_id TEXT NOT NULL,
        type TEXT NOT NULL,
        test_name TEXT NOT NULL,
        ordered_at TEXT NOT NULL,
        completed_at TEXT,
        results TEXT,
        interpretation TEXT,
        is_abnormal INTEGER NOT NULL,
        abnormal_values TEXT,
        recommendations TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE psychiatric_assessments (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        psychiatrist_id TEXT NOT NULL,
        assessment_date TEXT NOT NULL,
        mental_status_exam TEXT NOT NULL,
        cognitive_assessment TEXT NOT NULL,
        mood_assessment TEXT NOT NULL,
        anxiety_assessment TEXT NOT NULL,
        psychotic_symptoms TEXT NOT NULL,
        substance_use TEXT NOT NULL,
        risk_assessment TEXT NOT NULL,
        differential_diagnoses TEXT NOT NULL,
        primary_diagnosis TEXT NOT NULL,
        treatment_plan TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        next_appointment TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultMedications(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultMedications(Database db) async {
    final medications = [
      Medication(
        id: 'med_001',
        name: 'Sertralin',
        genericName: 'Sertraline',
        type: MedicationType.antidepressant,
        indications: ['Major Depressive Disorder', 'Panic Disorder', 'Social Anxiety Disorder'],
        contraindications: ['MAOI use', 'Hypersensitivity'],
        sideEffects: ['Nausea', 'Headache', 'Insomnia', 'Sexual dysfunction'],
        dosing: {
          'adult': '50-200mg daily',
          'elderly': '25-100mg daily',
          'pediatric': '25-100mg daily',
        },
        interactions: ['MAOIs', 'Warfarin', 'Lithium'],
        pregnancyCategory: 'C',
        requiresMonitoring: true,
        requiredLabs: [LabTestType.blood],
        halfLife: '26 hours',
        metabolism: 'Hepatic',
      ),
      Medication(
        id: 'med_002',
        name: 'Fluoksetin',
        genericName: 'Fluoxetine',
        type: MedicationType.antidepressant,
        indications: ['Major Depressive Disorder', 'Obsessive-Compulsive Disorder', 'Bulimia'],
        contraindications: ['MAOI use', 'Hypersensitivity'],
        sideEffects: ['Nausea', 'Headache', 'Anxiety', 'Insomnia'],
        dosing: {
          'adult': '20-80mg daily',
          'elderly': '10-40mg daily',
          'pediatric': '10-60mg daily',
        },
        interactions: ['MAOIs', 'Tricyclics', 'Lithium'],
        pregnancyCategory: 'C',
        requiresMonitoring: true,
        requiredLabs: [LabTestType.blood],
        halfLife: '4-6 days',
        metabolism: 'Hepatic',
      ),
      Medication(
        id: 'med_003',
        name: 'Alprazolam',
        genericName: 'Alprazolam',
        type: MedicationType.anxiolytic,
        indications: ['Generalized Anxiety Disorder', 'Panic Disorder'],
        contraindications: ['Acute narrow-angle glaucoma', 'Hypersensitivity'],
        sideEffects: ['Drowsiness', 'Dizziness', 'Confusion', 'Dependency'],
        dosing: {
          'adult': '0.25-4mg daily',
          'elderly': '0.125-2mg daily',
          'pediatric': 'Not recommended',
        },
        interactions: ['Alcohol', 'Opioids', 'Other CNS depressants'],
        pregnancyCategory: 'D',
        requiresMonitoring: true,
        requiredLabs: [LabTestType.blood],
        halfLife: '11-16 hours',
        metabolism: 'Hepatic',
      ),
    ];

    for (final medication in medications) {
      await db.insert('medications', {
        ...medication.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Medication Management
  Future<List<Medication>> searchMedications(String query) async {
    final db = await database;
    final result = await db.query(
      'medications',
      where: 'name LIKE ? OR generic_name LIKE ? OR indications LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    
    return result.map((json) => Medication.fromJson(json)).toList();
  }

  Future<Medication?> getMedication(String medicationId) async {
    final db = await database;
    final result = await db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [medicationId],
    );
    
    if (result.isEmpty) return null;
    return Medication.fromJson(result.first);
  }

  Future<List<Medication>> getMedicationsByType(MedicationType type) async {
    final db = await database;
    final result = await db.query(
      'medications',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'name ASC',
    );
    
    return result.map((json) => Medication.fromJson(json)).toList();
  }

  // Prescription Management
  Future<String> createPrescription({
    required String patientId,
    required String psychiatristId,
    required List<PrescribedMedication> medications,
    required String instructions,
    required String diagnosis,
    bool isRefillable = false,
    int refillCount = 0,
    String? pharmacyNotes,
  }) async {
    final db = await database;
    final prescriptionId = 'rx_${DateTime.now().millisecondsSinceEpoch}';
    
    final prescription = Prescription(
      id: prescriptionId,
      patientId: patientId,
      psychiatristId: psychiatristId,
      medications: medications,
      prescribedAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 30)),
      instructions: instructions,
      diagnosis: diagnosis,
      isRefillable: isRefillable,
      refillCount: refillCount,
      pharmacyNotes: pharmacyNotes,
    );
    
    await db.insert('prescriptions', {
      ...prescription.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'prescription.create',
      details: 'Prescription created: $prescriptionId',
      userId: psychiatristId,
      resourceId: prescriptionId,
    );
    
    return prescriptionId;
  }

  Future<List<Prescription>> getPatientPrescriptions(String patientId) async {
    final db = await database;
    final result = await db.query(
      'prescriptions',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'prescribed_at DESC',
    );
    
    return result.map((json) => Prescription.fromJson(json)).toList();
  }

  Future<List<Prescription>> getPsychiatristPrescriptions(String psychiatristId) async {
    final db = await database;
    final result = await db.query(
      'prescriptions',
      where: 'psychiatrist_id = ?',
      whereArgs: [psychiatristId],
      orderBy: 'prescribed_at DESC',
    );
    
    return result.map((json) => Prescription.fromJson(json)).toList();
  }

  // Side Effect Management
  Future<String> reportSideEffect({
    required String patientId,
    required String prescriptionId,
    required String medicationName,
    required String sideEffect,
    required SideEffectSeverity severity,
    required String description,
    required String reportedBy,
  }) async {
    final db = await database;
    final reportId = 'se_${DateTime.now().millisecondsSinceEpoch}';
    
    final report = SideEffectReport(
      id: reportId,
      patientId: patientId,
      prescriptionId: prescriptionId,
      medicationName: medicationName,
      sideEffect: sideEffect,
      severity: severity,
      reportedAt: DateTime.now(),
      reportedBy: reportedBy,
      description: description,
      requiresAction: severity == SideEffectSeverity.severe || severity == SideEffectSeverity.lifeThreatening,
    );
    
    await db.insert('side_effect_reports', {
      ...report.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'side_effect.report',
      details: 'Side effect reported: $reportId',
      userId: reportedBy,
      resourceId: reportId,
    );
    
    return reportId;
  }

  Future<List<SideEffectReport>> getSideEffectReports(String patientId) async {
    final db = await database;
    final result = await db.query(
      'side_effect_reports',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'reported_at DESC',
    );
    
    return result.map((json) => SideEffectReport.fromJson(json)).toList();
  }

  Future<List<SideEffectReport>> getActiveSideEffectReports() async {
    final db = await database;
    final result = await db.query(
      'side_effect_reports',
      where: 'requires_action = 1 AND resolved_at IS NULL',
      orderBy: 'reported_at DESC',
    );
    
    return result.map((json) => SideEffectReport.fromJson(json)).toList();
  }

  // Lab Test Management
  Future<String> orderLabTest({
    required String patientId,
    required String psychiatristId,
    required LabTestType type,
    required String testName,
  }) async {
    final db = await database;
    final testId = 'lab_${DateTime.now().millisecondsSinceEpoch}';
    
    final labTest = LabTest(
      id: testId,
      patientId: patientId,
      psychiatristId: psychiatristId,
      type: type,
      testName: testName,
      orderedAt: DateTime.now(),
    );
    
    await db.insert('lab_tests', {
      ...labTest.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'lab_test.order',
      details: 'Lab test ordered: $testId',
      userId: psychiatristId,
      resourceId: testId,
    );
    
    return testId;
  }

  Future<bool> updateLabTestResults({
    required String testId,
    required String results,
    required String interpretation,
    required bool isAbnormal,
    String? abnormalValues,
    String? recommendations,
  }) async {
    final db = await database;
    
    final result = await db.update(
      'lab_tests',
      {
        'results': results,
        'interpretation': interpretation,
        'is_abnormal': isAbnormal ? 1 : 0,
        'abnormal_values': abnormalValues,
        'recommendations': recommendations,
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [testId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'lab_test.update',
        details: 'Lab test results updated: $testId',
        userId: 'system',
        resourceId: testId,
      );
    }
    
    return result > 0;
  }

  Future<List<LabTest>> getPatientLabTests(String patientId) async {
    final db = await database;
    final result = await db.query(
      'lab_tests',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'ordered_at DESC',
    );
    
    return result.map((json) => LabTest.fromJson(json)).toList();
  }

  Future<List<LabTest>> getPendingLabTests(String psychiatristId) async {
    final db = await database;
    final result = await db.query(
      'lab_tests',
      where: 'psychiatrist_id = ? AND completed_at IS NULL',
      whereArgs: [psychiatristId],
      orderBy: 'ordered_at ASC',
    );
    
    return result.map((json) => LabTest.fromJson(json)).toList();
  }

  // Psychiatric Assessment Management
  Future<String> createPsychiatricAssessment({
    required String patientId,
    required String psychiatristId,
    required String mentalStatusExam,
    required Map<String, dynamic> cognitiveAssessment,
    required Map<String, dynamic> moodAssessment,
    required Map<String, dynamic> anxietyAssessment,
    required Map<String, dynamic> psychoticSymptoms,
    required Map<String, dynamic> substanceUse,
    required Map<String, dynamic> riskAssessment,
    required List<String> differentialDiagnoses,
    required String primaryDiagnosis,
    required String treatmentPlan,
    required List<String> recommendations,
    required DateTime nextAppointment,
  }) async {
    final db = await database;
    final assessmentId = 'pa_${DateTime.now().millisecondsSinceEpoch}';
    
    final assessment = PsychiatricAssessment(
      id: assessmentId,
      patientId: patientId,
      psychiatristId: psychiatristId,
      assessmentDate: DateTime.now(),
      mentalStatusExam: mentalStatusExam,
      cognitiveAssessment: cognitiveAssessment,
      moodAssessment: moodAssessment,
      anxietyAssessment: anxietyAssessment,
      psychoticSymptoms: psychoticSymptoms,
      substanceUse: substanceUse,
      riskAssessment: riskAssessment,
      differentialDiagnoses: differentialDiagnoses,
      primaryDiagnosis: primaryDiagnosis,
      treatmentPlan: treatmentPlan,
      recommendations: recommendations,
      nextAppointment: nextAppointment,
    );
    
    await db.insert('psychiatric_assessments', {
      ...assessment.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'psychiatric_assessment.create',
      details: 'Psychiatric assessment created: $assessmentId',
      userId: psychiatristId,
      resourceId: assessmentId,
    );
    
    return assessmentId;
  }

  Future<List<PsychiatricAssessment>> getPatientAssessments(String patientId) async {
    final db = await database;
    final result = await db.query(
      'psychiatric_assessments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'assessment_date DESC',
    );
    
    return result.map((json) => PsychiatricAssessment.fromJson(json)).toList();
  }

  // AI-Powered Features for Psychiatrists
  Future<Map<String, dynamic>> generateMedicationRecommendation({
    required String diagnosis,
    required List<String> currentMedications,
    required Map<String, dynamic> patientFactors,
  }) async {
    // Mock AI recommendation - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final recommendations = <String>[];
    final interactions = <String>[];
    final monitoring = <String>[];
    
    switch (diagnosis) {
      case 'Major Depressive Disorder':
        if (!currentMedications.any((m) => m.toLowerCase().contains('sertralin'))) {
          recommendations.add('Sertralin 50mg başlangıç dozu');
          monitoring.add('4-6 hafta sonra yanıt değerlendirmesi');
          monitoring.add('Yan etki takibi');
        }
        break;
      case 'Generalized Anxiety Disorder':
        if (!currentMedications.any((m) => m.toLowerCase().contains('sertralin'))) {
          recommendations.add('Sertralin 25mg başlangıç dozu');
          monitoring.add('Anksiyete semptomları takibi');
        }
        break;
    }
    
    // İlaç etkileşimleri kontrolü
    if (currentMedications.isNotEmpty) {
      interactions.add('Mevcut ilaçlarla etkileşim kontrolü gerekli');
    }
    
    return {
      'recommendations': recommendations,
      'interactions': interactions,
      'monitoring': monitoring,
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'evidence': 'Evidence-based treatment guidelines',
    };
  }

  Future<Map<String, dynamic>> analyzeLabResults({
    required String testType,
    required Map<String, dynamic> results,
    required List<String> currentMedications,
  }) async {
    // Mock AI lab analysis - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 1));
    
    final interpretations = <String>[];
    final alerts = <String>[];
    final recommendations = <String>[];
    
    switch (testType) {
      case 'blood':
        if (results['lithium'] != null && results['lithium'] > 1.2) {
          alerts.add('Lityum toksisitesi riski - acil değerlendirme gerekli');
          recommendations.add('Lityum dozajını azalt');
          recommendations.add('24 saat içinde tekrar ölç');
        }
        break;
      case 'liver':
        if (results['alt'] != null && results['alt'] > 100) {
          alerts.add('Karaciğer fonksiyon bozukluğu');
          recommendations.add('İlaç dozajını gözden geçir');
          recommendations.add('Hepatolog konsültasyonu');
        }
        break;
    }
    
    return {
      'interpretations': interpretations,
      'alerts': alerts,
      'recommendations': recommendations,
      'confidence': 0.90 + (Random().nextDouble() * 0.05),
    };
  }

  Future<Map<String, dynamic>> generateTreatmentPlan({
    required String diagnosis,
    required Map<String, dynamic> patientFactors,
    required List<String> previousTreatments,
  }) async {
    // Mock AI treatment plan - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 3));
    
    final medications = <String>[];
    final psychotherapy = <String>[];
    final monitoring = <String>[];
    final timeline = <String>[];
    
    switch (diagnosis) {
      case 'Major Depressive Disorder':
        medications.add('SSRI (Sertralin 50mg)');
        medications.add('4-6 hafta yanıt bekle');
        psychotherapy.add('CBT haftalık seanslar');
        psychotherapy.add('Davranış aktivasyonu');
        monitoring.add('PHQ-9 haftalık');
        monitoring.add('Yan etki takibi');
        timeline.add('Hafta 1-2: İlaç başlangıcı');
        timeline.add('Hafta 4-6: Yanıt değerlendirmesi');
        timeline.add('Hafta 8-12: Dozaj optimizasyonu');
        break;
      case 'Bipolar Disorder':
        medications.add('Mood stabilizer (Lityum)');
        medications.add('Antipsikotik (Olanzapin)');
        monitoring.add('Lityum seviyesi haftalık');
        monitoring.add('Tiroid fonksiyonları');
        timeline.add('Hafta 1: Akut tedavi');
        timeline.add('Hafta 2-4: Stabilizasyon');
        timeline.add('Hafta 8+: Sürdürme tedavisi');
        break;
    }
    
    return {
      'medications': medications,
      'psychotherapy': psychotherapy,
      'monitoring': monitoring,
      'timeline': timeline,
      'confidence': 0.88 + (Random().nextDouble() * 0.07),
      'evidence': 'Clinical practice guidelines',
    };
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getPsychiatristStatistics(String psychiatristId) async {
    final db = await database;
    
    final prescriptionsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM prescriptions 
      WHERE psychiatrist_id = ?
    ''', [psychiatristId]);
    
    final sideEffectsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM side_effect_reports 
      WHERE reported_by = ?
    ''', [psychiatristId]);
    
    final labTestsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM lab_tests 
      WHERE psychiatrist_id = ?
    ''', [psychiatristId]);
    
    final assessmentsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM psychiatric_assessments 
      WHERE psychiatrist_id = ?
    ''', [psychiatristId]);
    
    return {
      'totalPrescriptions': prescriptionsResult.first['count'] as int,
      'totalSideEffectReports': sideEffectsResult.first['count'] as int,
      'totalLabTests': labTestsResult.first['count'] as int,
      'totalAssessments': assessmentsResult.first['count'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getMedicationUsageStats(String psychiatristId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        m.name,
        m.type,
        COUNT(p.id) as prescription_count,
        AVG(CASE WHEN ser.severity = 'severe' THEN 1 ELSE 0 END) as severe_side_effect_rate
      FROM medications m
      LEFT JOIN prescriptions p ON JSON_EXTRACT(p.medications, '$[0].medicationId') = m.id
      LEFT JOIN side_effect_reports ser ON ser.medication_name = m.name
      WHERE p.psychiatrist_id = ?
      GROUP BY m.id, m.name, m.type
      ORDER BY prescription_count DESC
    ''', [psychiatristId]);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getTreatmentOutcomes(String psychiatristId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        pa.primary_diagnosis,
        COUNT(*) as patient_count,
        AVG(CASE WHEN ser.severity IN ('mild', 'none') THEN 1 ELSE 0 END) as treatment_success_rate
      FROM psychiatric_assessments pa
      LEFT JOIN side_effect_reports ser ON ser.patient_id = pa.patient_id
      WHERE pa.psychiatrist_id = ?
      GROUP BY pa.primary_diagnosis
      ORDER BY patient_count DESC
    ''', [psychiatristId]);
    
    return result;
  }
}
