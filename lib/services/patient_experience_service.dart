import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/patient_experience_models.dart';
import 'audit_log_service.dart';

class PatientExperienceService {
  static final PatientExperienceService _instance = PatientExperienceService._internal();
  factory PatientExperienceService() => _instance;
  PatientExperienceService._internal();

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
    return 'patient-experience-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patient_satisfactions (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        organization_id TEXT NOT NULL,
        survey_date TEXT NOT NULL,
        experience_type TEXT NOT NULL,
        ratings TEXT NOT NULL,
        comments TEXT,
        suggestions TEXT,
        overall_score REAL NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_complaints (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        organization_id TEXT NOT NULL,
        complaint_date TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        status TEXT NOT NULL,
        assigned_to TEXT,
        resolution_date TEXT,
        resolution TEXT,
        follow_up_notes TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_loyalties (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        organization_id TEXT NOT NULL,
        assessment_date TEXT NOT NULL,
        level TEXT NOT NULL,
        loyalty_score REAL NOT NULL,
        loyalty_factors TEXT NOT NULL,
        risk_factors TEXT NOT NULL,
        recommendations TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE experience_journeys (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        organization_id TEXT NOT NULL,
        journey_date TEXT NOT NULL,
        steps TEXT NOT NULL,
        touchpoint_scores TEXT NOT NULL,
        pain_points TEXT NOT NULL,
        positive_moments TEXT NOT NULL,
        overall_experience TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_feedbacks (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        organization_id TEXT NOT NULL,
        feedback_date TEXT NOT NULL,
        feedback_type TEXT NOT NULL,
        content TEXT NOT NULL,
        sentiment_score REAL NOT NULL,
        keywords TEXT NOT NULL,
        category TEXT,
        priority TEXT,
        response TEXT,
        response_date TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE experience_metrics (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        report_date TEXT NOT NULL,
        satisfaction_scores TEXT NOT NULL,
        complaint_counts TEXT NOT NULL,
        loyalty_scores TEXT NOT NULL,
        journey_scores TEXT NOT NULL,
        trends TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_retentions (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        organization_id TEXT NOT NULL,
        assessment_date TEXT NOT NULL,
        retention_probability REAL NOT NULL,
        retention_factors TEXT NOT NULL,
        churn_risk_factors TEXT NOT NULL,
        retention_strategy TEXT,
        next_assessment_date TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultSatisfactions(db);
    await _createDefaultComplaints(db);
    await _createDefaultLoyalties(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultSatisfactions(Database db) async {
    final satisfactions = [
      PatientSatisfaction(
        id: 'ps_001',
        patientId: 'patient_001',
        organizationId: 'org_001',
        surveyDate: DateTime.now().subtract(const Duration(days: 5)),
        experienceType: ExperienceType.appointment,
        ratings: {
          'appointment_scheduling': SatisfactionLevel.satisfied,
          'waiting_time': SatisfactionLevel.neutral,
          'staff_friendliness': SatisfactionLevel.verySatisfied,
          'facility_cleanliness': SatisfactionLevel.satisfied,
        },
        comments: 'Randevu süreci kolaydı, personel çok yardımcıydı.',
        suggestions: 'Bekleme süresi biraz uzun olabilir.',
        overallScore: 4.2,
      ),
      PatientSatisfaction(
        id: 'ps_002',
        patientId: 'patient_002',
        organizationId: 'org_001',
        surveyDate: DateTime.now().subtract(const Duration(days: 10)),
        experienceType: ExperienceType.treatment,
        ratings: {
          'treatment_effectiveness': SatisfactionLevel.verySatisfied,
          'communication': SatisfactionLevel.satisfied,
          'follow_up': SatisfactionLevel.satisfied,
          'overall_care': SatisfactionLevel.verySatisfied,
        },
        comments: 'Tedavi süreci çok etkiliydi, doktor çok ilgiliydi.',
        suggestions: 'Daha fazla takip randevusu olabilir.',
        overallScore: 4.6,
      ),
    ];

    for (final satisfaction in satisfactions) {
      await db.insert('patient_satisfactions', {
        ...satisfaction.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _createDefaultComplaints(Database db) async {
    final complaints = [
      PatientComplaint(
        id: 'pc_001',
        patientId: 'patient_003',
        organizationId: 'org_001',
        complaintDate: DateTime.now().subtract(const Duration(days: 3)),
        title: 'Randevu İptali',
        description: 'Randevum son dakikada iptal edildi, alternatif seçenek sunulmadı.',
        category: 'Appointment',
        status: ComplaintStatus.inProgress,
        assignedTo: 'manager_001',
        followUpNotes: 'Hasta ile iletişime geçildi, yeni randevu planlandı.',
      ),
      PatientComplaint(
        id: 'pc_002',
        patientId: 'patient_004',
        organizationId: 'org_001',
        complaintDate: DateTime.now().subtract(const Duration(days: 7)),
        title: 'Fatura Sorunu',
        description: 'Faturamda hatalı ücretlendirme var.',
        category: 'Billing',
        status: ComplaintStatus.resolved,
        assignedTo: 'billing_001',
        resolutionDate: DateTime.now().subtract(const Duration(days: 2)),
        resolution: 'Fatura düzeltildi, özür dilendi.',
        followUpNotes: 'Hasta memnun, sorun çözüldü.',
      ),
    ];

    for (final complaint in complaints) {
      await db.insert('patient_complaints', {
        ...complaint.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _createDefaultLoyalties(Database db) async {
    final loyalties = [
      PatientLoyalty(
        id: 'pl_001',
        patientId: 'patient_001',
        organizationId: 'org_001',
        assessmentDate: DateTime.now().subtract(const Duration(days: 15)),
        level: LoyaltyLevel.high,
        loyaltyScore: 8.5,
        loyaltyFactors: [
          'Excellent treatment outcomes',
          'Friendly staff',
          'Convenient location',
          'Good communication',
        ],
        riskFactors: [
          'Long waiting times',
          'Limited appointment slots',
        ],
        recommendations: 'Bekleme sürelerini azaltmak için ek personel alımı düşünülebilir.',
      ),
      PatientLoyalty(
        id: 'pl_002',
        patientId: 'patient_002',
        organizationId: 'org_001',
        assessmentDate: DateTime.now().subtract(const Duration(days: 20)),
        level: LoyaltyLevel.veryHigh,
        loyaltyScore: 9.2,
        loyaltyFactors: [
          'Outstanding care quality',
          'Personalized treatment',
          'Quick response to concerns',
          'Modern facilities',
        ],
        riskFactors: [],
        recommendations: 'Bu hasta referans verebilir, mükemmel deneyim yaşamış.',
      ),
    ];

    for (final loyalty in loyalties) {
      await db.insert('patient_loyalties', {
        ...loyalty.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Patient Satisfaction Management
  Future<String> createPatientSatisfaction({
    required String patientId,
    required String organizationId,
    required ExperienceType experienceType,
    required Map<String, SatisfactionLevel> ratings,
    String? comments,
    String? suggestions,
  }) async {
    final db = await database;
    final satisfactionId = 'ps_${DateTime.now().millisecondsSinceEpoch}';
    
    // Calculate overall score from ratings
    final scores = ratings.values.map((level) {
      switch (level) {
        case SatisfactionLevel.veryDissatisfied: return 1.0;
        case SatisfactionLevel.dissatisfied: return 2.0;
        case SatisfactionLevel.neutral: return 3.0;
        case SatisfactionLevel.satisfied: return 4.0;
        case SatisfactionLevel.verySatisfied: return 5.0;
      }
    }).toList();
    
    final overallScore = scores.reduce((a, b) => a + b) / scores.length;
    
    final satisfaction = PatientSatisfaction(
      id: satisfactionId,
      patientId: patientId,
      organizationId: organizationId,
      surveyDate: DateTime.now(),
      experienceType: experienceType,
      ratings: ratings,
      comments: comments,
      suggestions: suggestions,
      overallScore: overallScore,
    );
    
    await db.insert('patient_satisfactions', {
      ...satisfaction.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'patient_satisfaction.create',
      details: 'Patient satisfaction created: $satisfactionId',
      userId: 'system',
      resourceId: satisfactionId,
    );
    
    return satisfactionId;
  }

  Future<List<PatientSatisfaction>> getPatientSatisfactions(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'patient_satisfactions',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'survey_date DESC',
    );
    
    return result.map((json) => PatientSatisfaction.fromJson(json)).toList();
  }

  // Patient Complaint Management
  Future<String> createPatientComplaint({
    required String patientId,
    required String organizationId,
    required String title,
    required String description,
    required String category,
    String? assignedTo,
  }) async {
    final db = await database;
    final complaintId = 'pc_${DateTime.now().millisecondsSinceEpoch}';
    
    final complaint = PatientComplaint(
      id: complaintId,
      patientId: patientId,
      organizationId: organizationId,
      complaintDate: DateTime.now(),
      title: title,
      description: description,
      category: category,
      status: ComplaintStatus.open,
      assignedTo: assignedTo,
    );
    
    await db.insert('patient_complaints', {
      ...complaint.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'patient_complaint.create',
      details: 'Patient complaint created: $complaintId',
      userId: 'system',
      resourceId: complaintId,
    );
    
    return complaintId;
  }

  Future<List<PatientComplaint>> getPatientComplaints(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'patient_complaints',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'complaint_date DESC',
    );
    
    return result.map((json) => PatientComplaint.fromJson(json)).toList();
  }

  Future<bool> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
    String? resolution,
    String? followUpNotes,
  }) async {
    final db = await database;
    
    final updateData = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (resolution != null) {
      updateData['resolution'] = resolution;
      updateData['resolution_date'] = DateTime.now().toIso8601String();
    }
    
    if (followUpNotes != null) {
      updateData['follow_up_notes'] = followUpNotes;
    }
    
    final result = await db.update(
      'patient_complaints',
      updateData,
      where: 'id = ?',
      whereArgs: [complaintId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'patient_complaint.update',
        details: 'Patient complaint status updated: $complaintId',
        userId: 'system',
        resourceId: complaintId,
      );
    }
    
    return result > 0;
  }

  // Patient Loyalty Management
  Future<String> createPatientLoyalty({
    required String patientId,
    required String organizationId,
    required LoyaltyLevel level,
    required double loyaltyScore,
    required List<String> loyaltyFactors,
    required List<String> riskFactors,
    String? recommendations,
  }) async {
    final db = await database;
    final loyaltyId = 'pl_${DateTime.now().millisecondsSinceEpoch}';
    
    final loyalty = PatientLoyalty(
      id: loyaltyId,
      patientId: patientId,
      organizationId: organizationId,
      assessmentDate: DateTime.now(),
      level: level,
      loyaltyScore: loyaltyScore,
      loyaltyFactors: loyaltyFactors,
      riskFactors: riskFactors,
      recommendations: recommendations,
    );
    
    await db.insert('patient_loyalties', {
      ...loyalty.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'patient_loyalty.create',
      details: 'Patient loyalty created: $loyaltyId',
      userId: 'system',
      resourceId: loyaltyId,
    );
    
    return loyaltyId;
  }

  Future<List<PatientLoyalty>> getPatientLoyalties(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'patient_loyalties',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'assessment_date DESC',
    );
    
    return result.map((json) => PatientLoyalty.fromJson(json)).toList();
  }

  // Patient Feedback Management
  Future<String> createPatientFeedback({
    required String patientId,
    required String organizationId,
    required String feedbackType,
    required String content,
    required double sentimentScore,
    required List<String> keywords,
    String? category,
    String? priority,
  }) async {
    final db = await database;
    final feedbackId = 'pf_${DateTime.now().millisecondsSinceEpoch}';
    
    final feedback = PatientFeedback(
      id: feedbackId,
      patientId: patientId,
      organizationId: organizationId,
      feedbackDate: DateTime.now(),
      feedbackType: feedbackType,
      content: content,
      sentimentScore: sentimentScore,
      keywords: keywords,
      category: category,
      priority: priority,
    );
    
    await db.insert('patient_feedbacks', {
      ...feedback.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'patient_feedback.create',
      details: 'Patient feedback created: $feedbackId',
      userId: 'system',
      resourceId: feedbackId,
    );
    
    return feedbackId;
  }

  Future<List<PatientFeedback>> getPatientFeedbacks(String organizationId) async {
    final db = await database;
    final result = await db.query(
      'patient_feedbacks',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'feedback_date DESC',
    );
    
    return result.map((json) => PatientFeedback.fromJson(json)).toList();
  }

  // AI-Powered Features for Patient Experience
  Future<Map<String, dynamic>> generateSatisfactionInsights({
    required String organizationId,
    required Map<String, dynamic> satisfactionData,
  }) async {
    // Mock AI satisfaction insights - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final insights = <String>[];
    final recommendations = <String>[];
    final trends = <String>[];
    final actionItems = <String>[];
    
    final overallScore = satisfactionData['overall_score'] as double? ?? 0.0;
    final appointmentScore = satisfactionData['appointment_score'] as double? ?? 0.0;
    final treatmentScore = satisfactionData['treatment_score'] as double? ?? 0.0;
    final communicationScore = satisfactionData['communication_score'] as double? ?? 0.0;
    
    if (overallScore < 4.0) {
      insights.add('Genel memnuniyet skoru hedefin altında');
      recommendations.add('Hasta deneyimi iyileştirme programı başlat');
      actionItems.add('Hasta geri bildirim sistemi güçlendir');
    }
    
    if (appointmentScore < 3.5) {
      insights.add('Randevu deneyimi sorunlu');
      recommendations.add('Randevu süreçlerini optimize et');
      actionItems.add('Online randevu sistemi geliştir');
    }
    
    if (treatmentScore < 4.0) {
      insights.add('Tedavi kalitesi iyileştirilmeli');
      recommendations.add('Klinik kalite standartlarını gözden geçir');
      actionItems.add('Personel eğitim programları düzenle');
    }
    
    if (communicationScore < 3.8) {
      insights.add('İletişim kalitesi düşük');
      recommendations.add('İletişim protokollerini güncelle');
      actionItems.add('Personel iletişim eğitimi');
    }
    
    trends.add('Memnuniyet skorları son 3 ayda %8 artış gösteriyor');
    trends.add('Randevu deneyimi iyileşme trendinde');
    trends.add('Tedavi kalitesi stabil seviyede');
    
    return {
      'insights': insights,
      'recommendations': recommendations,
      'trends': trends,
      'actionItems': actionItems,
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'evidence': 'Patient satisfaction surveys and experience analytics',
    };
  }

  Future<Map<String, dynamic>> generateComplaintAnalysis({
    required String organizationId,
    required Map<String, dynamic> complaintData,
  }) async {
    // Mock AI complaint analysis - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 3));
    
    final analysis = <String>[];
    final patterns = <String>[];
    final recommendations = <String>[];
    final preventionStrategies = <String>[];
    
    final complaintCount = complaintData['complaint_count'] as int? ?? 0;
    final topCategories = complaintData['top_categories'] as List<String>? ?? [];
    final resolutionTime = complaintData['avg_resolution_time'] as double? ?? 0.0;
    
    if (complaintCount > 10) {
      analysis.add('Şikayet sayısı yüksek seviyede');
      recommendations.add('Şikayet önleme stratejileri geliştir');
      preventionStrategies.add('Proaktif hasta iletişimi');
    }
    
    if (topCategories.contains('Appointment')) {
      patterns.add('Randevu ile ilgili şikayetler en yaygın');
      recommendations.add('Randevu süreçlerini gözden geçir');
      preventionStrategies.add('Randevu hatırlatma sistemi');
    }
    
    if (topCategories.contains('Billing')) {
      patterns.add('Faturalama şikayetleri önemli bir sorun');
      recommendations.add('Faturalama süreçlerini şeffaflaştır');
      preventionStrategies.add('Önceden fiyat bilgilendirmesi');
    }
    
    if (resolutionTime > 7) {
      analysis.add('Şikayet çözüm süresi uzun');
      recommendations.add('Şikayet yönetim süreçlerini hızlandır');
      preventionStrategies.add('Hızlı müdahale protokolleri');
    }
    
    return {
      'analysis': analysis,
      'patterns': patterns,
      'recommendations': recommendations,
      'preventionStrategies': preventionStrategies,
      'confidence': 0.80 + (Random().nextDouble() * 0.15),
      'evidence': 'Complaint data analysis and resolution patterns',
    };
  }

  Future<Map<String, dynamic>> generateLoyaltyInsights({
    required String organizationId,
    required Map<String, dynamic> loyaltyData,
  }) async {
    // Mock AI loyalty insights - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final insights = <String>[];
    final loyaltyDrivers = <String>[];
    final riskFactors = <String>[];
    final retentionStrategies = <String>[];
    
    final avgLoyaltyScore = loyaltyData['avg_loyalty_score'] as double? ?? 0.0;
    final highLoyaltyRate = loyaltyData['high_loyalty_rate'] as double? ?? 0.0;
    final churnRisk = loyaltyData['churn_risk'] as double? ?? 0.0;
    
    if (avgLoyaltyScore > 8.0) {
      insights.add('Ortalama sadakat skoru yüksek');
      loyaltyDrivers.add('Mükemmel tedavi kalitesi');
      loyaltyDrivers.add('Kişisel ilgi ve bakım');
    }
    
    if (highLoyaltyRate > 0.7) {
      insights.add('Yüksek sadakat oranı mevcut');
      retentionStrategies.add('Mevcut hastaları koruma programı');
      retentionStrategies.add('Referans programı geliştir');
    }
    
    if (churnRisk > 0.3) {
      insights.add('Hasta kaybı riski yüksek');
      riskFactors.add('Uzun bekleme süreleri');
      riskFactors.add('İletişim eksiklikleri');
      retentionStrategies.add('Risk altındaki hastalar için özel program');
    }
    
    return {
      'insights': insights,
      'loyaltyDrivers': loyaltyDrivers,
      'riskFactors': riskFactors,
      'retentionStrategies': retentionStrategies,
      'confidence': 0.88 + (Random().nextDouble() * 0.07),
      'evidence': 'Loyalty analytics and patient retention models',
    };
  }

  Future<Map<String, dynamic>> generateExperienceJourney({
    required String organizationId,
    required String patientId,
    required Map<String, dynamic> journeyData,
  }) async {
    // Mock AI experience journey - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 4));
    
    final journeySteps = <String>[];
    final touchpoints = <String>[];
    final painPoints = <String>[];
    final positiveMoments = <String>[];
    final improvements = <String>[];
    
    // Simulated journey analysis
    journeySteps.addAll([
      'Online randevu alma',
      'Randevu onayı',
      'Randevu hatırlatması',
      'Klinik geliş',
      'Kayıt işlemleri',
      'Bekleme süresi',
      'Doktor görüşmesi',
      'Tedavi planı',
      'Takip randevusu',
      'Faturalama',
    ]);
    
    touchpoints.addAll([
      'Website randevu formu',
      'SMS/E-mail hatırlatma',
      'Resepsiyon',
      'Bekleme alanı',
      'Muayene odası',
      'Ödeme sistemi',
    ]);
    
    painPoints.addAll([
      'Randevu formu karmaşık',
      'Bekleme süresi uzun',
      'Fatura bilgilendirmesi eksik',
    ]);
    
    positiveMoments.addAll([
      'Personel samimi yaklaşımı',
      'Doktor detaylı açıklamaları',
      'Temiz ve modern tesis',
      'Hızlı ödeme işlemleri',
    ]);
    
    improvements.addAll([
      'Randevu formunu sadeleştir',
      'Bekleme sürelerini azalt',
      'Fatura öncesi bilgilendirme',
      'Online ödeme seçenekleri',
    ]);
    
    return {
      'journeySteps': journeySteps,
      'touchpoints': touchpoints,
      'painPoints': painPoints,
      'positiveMoments': positiveMoments,
      'improvements': improvements,
      'confidence': 0.82 + (Random().nextDouble() * 0.13),
      'evidence': 'Patient journey mapping and touchpoint analysis',
    };
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getPatientExperienceStatistics(String organizationId) async {
    final db = await database;
    
    final satisfactionsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM patient_satisfactions 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final complaintsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM patient_complaints 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final loyaltiesResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM patient_loyalties 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    final feedbacksResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM patient_feedbacks 
      WHERE organization_id = ?
    ''', [organizationId]);
    
    return {
      'totalSatisfactions': satisfactionsResult.first['count'] as int,
      'totalComplaints': complaintsResult.first['count'] as int,
      'totalLoyalties': loyaltiesResult.first['count'] as int,
      'totalFeedbacks': feedbacksResult.first['count'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getSatisfactionTrends(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        ps.survey_date,
        ps.overall_score,
        ps.experience_type
      FROM patient_satisfactions ps
      WHERE ps.organization_id = ?
      ORDER BY ps.survey_date DESC
      LIMIT 12
    ''', [organizationId]);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getComplaintTrends(String organizationId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        pc.complaint_date,
        pc.category,
        pc.status
      FROM patient_complaints pc
      WHERE pc.organization_id = ?
      ORDER BY pc.complaint_date DESC
      LIMIT 12
    ''', [organizationId]);
    
    return result;
  }
}
