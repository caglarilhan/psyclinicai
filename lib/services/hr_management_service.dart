import 'dart:convert';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/hr_management_models.dart';
import 'audit_log_service.dart';

class HRManagementService {
  static final HRManagementService _instance = HRManagementService._internal();
  factory HRManagementService() => _instance;
  HRManagementService._internal();

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
    return 'hr-management-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        employee_number TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        position TEXT NOT NULL,
        department TEXT NOT NULL,
        status TEXT NOT NULL,
        hire_date TEXT NOT NULL,
        termination_date TEXT,
        salary REAL NOT NULL,
        manager_id TEXT NOT NULL,
        skills TEXT NOT NULL,
        personal_info TEXT NOT NULL,
        emergency_contacts TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE performance_reviews (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        reviewer_id TEXT NOT NULL,
        review_date TEXT NOT NULL,
        review_period_start TEXT NOT NULL,
        review_period_end TEXT NOT NULL,
        ratings TEXT NOT NULL,
        goals TEXT NOT NULL,
        strengths TEXT NOT NULL,
        areas_for_improvement TEXT NOT NULL,
        development_goals TEXT NOT NULL,
        overall_comment TEXT NOT NULL,
        employee_comment TEXT NOT NULL,
        reviewer_comment TEXT NOT NULL,
        next_review_date TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recruitments (
        id TEXT PRIMARY KEY,
        position TEXT NOT NULL,
        department TEXT NOT NULL,
        description TEXT NOT NULL,
        requirements TEXT NOT NULL,
        responsibilities TEXT NOT NULL,
        salary_range REAL NOT NULL,
        status TEXT NOT NULL,
        posted_date TEXT NOT NULL,
        closing_date TEXT,
        hiring_manager_id TEXT NOT NULL,
        applicants TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE job_applications (
        id TEXT PRIMARY KEY,
        recruitment_id TEXT NOT NULL,
        applicant_name TEXT NOT NULL,
        applicant_email TEXT NOT NULL,
        applicant_phone TEXT NOT NULL,
        resume TEXT NOT NULL,
        cover_letter TEXT NOT NULL,
        experience TEXT NOT NULL,
        skills TEXT NOT NULL,
        education TEXT NOT NULL,
        status TEXT NOT NULL,
        application_date TEXT NOT NULL,
        interview_date TEXT,
        notes TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE training_programs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        provider TEXT NOT NULL,
        duration INTEGER NOT NULL,
        cost REAL NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        target_audience TEXT NOT NULL,
        objectives TEXT NOT NULL,
        prerequisites TEXT NOT NULL,
        format TEXT NOT NULL,
        max_participants INTEGER NOT NULL,
        enrolled_employees TEXT NOT NULL,
        status TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE training_records (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        training_program_id TEXT NOT NULL,
        enrollment_date TEXT NOT NULL,
        completion_date TEXT,
        status TEXT NOT NULL,
        score REAL,
        certificate TEXT,
        feedback TEXT,
        progress TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE career_developments (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        current_position TEXT NOT NULL,
        target_position TEXT NOT NULL,
        career_goals TEXT NOT NULL,
        required_skills TEXT NOT NULL,
        current_skills TEXT NOT NULL,
        skill_gaps TEXT NOT NULL,
        development_actions TEXT NOT NULL,
        target_date TEXT NOT NULL,
        mentor_id TEXT NOT NULL,
        status TEXT NOT NULL,
        progress TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE hr_metrics (
        id TEXT PRIMARY KEY,
        organization_id TEXT NOT NULL,
        report_date TEXT NOT NULL,
        headcount_by_department TEXT NOT NULL,
        turnover_rate TEXT NOT NULL,
        retention_rate TEXT NOT NULL,
        satisfaction_score TEXT NOT NULL,
        training_completion_rate TEXT NOT NULL,
        average_performance_rating TEXT NOT NULL,
        time_to_hire TEXT NOT NULL,
        cost_per_hire TEXT NOT NULL,
        diversity_metrics TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDefaultEmployees(db);
    await _createDefaultTrainingPrograms(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultEmployees(Database db) async {
    final employees = [
      Employee(
        id: 'emp_001',
        employeeNumber: 'EMP001',
        firstName: 'Dr. Ayşe',
        lastName: 'Yılmaz',
        email: 'ayse.yilmaz@psyclinicai.com',
        phone: '+90 532 123 4567',
        position: 'Chief Medical Officer',
        department: 'Medical',
        status: EmploymentStatus.active,
        hireDate: DateTime.now().subtract(const Duration(days: 365)),
        salary: 150000,
        managerId: 'manager_001',
        skills: ['Leadership', 'Clinical Management', 'Strategic Planning'],
        personalInfo: {
          'dateOfBirth': '1980-05-15',
          'address': 'İstanbul, Türkiye',
          'education': 'MD, Psychiatry',
        },
        emergencyContacts: {
          'contact1': 'Mehmet Yılmaz - +90 532 987 6543',
          'contact2': 'Fatma Yılmaz - +90 532 555 1234',
        },
      ),
      Employee(
        id: 'emp_002',
        employeeNumber: 'EMP002',
        firstName: 'Dr. Mehmet',
        lastName: 'Kaya',
        email: 'mehmet.kaya@psyclinicai.com',
        phone: '+90 532 234 5678',
        position: 'Senior Psychiatrist',
        department: 'Psychiatry',
        status: EmploymentStatus.active,
        hireDate: DateTime.now().subtract(const Duration(days: 730)),
        salary: 120000,
        managerId: 'emp_001',
        skills: ['Psychiatry', 'Medication Management', 'Patient Care'],
        personalInfo: {
          'dateOfBirth': '1975-03-20',
          'address': 'Ankara, Türkiye',
          'education': 'MD, Psychiatry',
        },
        emergencyContacts: {
          'contact1': 'Zeynep Kaya - +90 532 111 2222',
        },
      ),
      Employee(
        id: 'emp_003',
        employeeNumber: 'EMP003',
        firstName: 'Psikolog',
        lastName: 'Elif',
        email: 'elif.demir@psyclinicai.com',
        phone: '+90 532 345 6789',
        position: 'Clinical Psychologist',
        department: 'Psychology',
        status: EmploymentStatus.active,
        hireDate: DateTime.now().subtract(const Duration(days: 500)),
        salary: 80000,
        managerId: 'emp_001',
        skills: ['Clinical Psychology', 'Assessment', 'Therapy'],
        personalInfo: {
          'dateOfBirth': '1985-08-10',
          'address': 'İzmir, Türkiye',
          'education': 'PhD, Clinical Psychology',
        },
        emergencyContacts: {
          'contact1': 'Ali Demir - +90 532 333 4444',
        },
      ),
    ];

    for (final employee in employees) {
      await db.insert('employees', {
        ...employee.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _createDefaultTrainingPrograms(Database db) async {
    final trainingPrograms = [
      TrainingProgram(
        id: 'tp_001',
        title: 'HIPAA Compliance Training',
        description: 'Comprehensive training on HIPAA regulations and patient privacy',
        category: 'Compliance',
        provider: 'PsyClinicAI Academy',
        duration: 4,
        cost: 500,
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 37)),
        targetAudience: ['All Staff'],
        objectives: [
          'Understand HIPAA requirements',
          'Learn patient privacy protocols',
          'Practice secure communication',
        ],
        prerequisites: ['Basic computer skills'],
        format: 'online',
        maxParticipants: 50,
        enrolledEmployees: ['emp_001', 'emp_002', 'emp_003'],
        status: TrainingStatus.pending,
      ),
      TrainingProgram(
        id: 'tp_002',
        title: 'AI-Powered Assessment Tools',
        description: 'Training on using AI tools for patient assessment and diagnosis',
        category: 'Technology',
        provider: 'PsyClinicAI Academy',
        duration: 8,
        cost: 800,
        startDate: DateTime.now().add(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 52)),
        targetAudience: ['Psychiatrists', 'Psychologists'],
        objectives: [
          'Master AI assessment tools',
          'Interpret AI-generated insights',
          'Integrate AI into clinical workflow',
        ],
        prerequisites: ['Clinical experience', 'Basic AI knowledge'],
        format: 'hybrid',
        maxParticipants: 20,
        enrolledEmployees: ['emp_002', 'emp_003'],
        status: TrainingStatus.pending,
      ),
    ];

    for (final program in trainingPrograms) {
      await db.insert('training_programs', {
        ...program.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Employee Management
  Future<String> createEmployee({
    required String employeeNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String position,
    required String department,
    required double salary,
    required String managerId,
    required List<String> skills,
    required Map<String, dynamic> personalInfo,
    required Map<String, dynamic> emergencyContacts,
  }) async {
    final db = await database;
    final employeeId = 'emp_${DateTime.now().millisecondsSinceEpoch}';
    
    final employee = Employee(
      id: employeeId,
      employeeNumber: employeeNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      position: position,
      department: department,
      status: EmploymentStatus.active,
      hireDate: DateTime.now(),
      salary: salary,
      managerId: managerId,
      skills: skills,
      personalInfo: personalInfo,
      emergencyContacts: emergencyContacts,
    );
    
    await db.insert('employees', {
      ...employee.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'employee.create',
      details: 'Employee created: $employeeId',
      userId: 'system',
      resourceId: employeeId,
    );
    
    return employeeId;
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;
    final result = await db.query(
      'employees',
      where: 'status = ?',
      whereArgs: [EmploymentStatus.active.name],
      orderBy: 'hire_date DESC',
    );
    
    return result.map((json) => Employee.fromJson(json)).toList();
  }

  Future<Employee?> getEmployee(String employeeId) async {
    final db = await database;
    final result = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [employeeId],
    );
    
    if (result.isEmpty) return null;
    return Employee.fromJson(result.first);
  }

  // Performance Review Management
  Future<String> createPerformanceReview({
    required String employeeId,
    required String reviewerId,
    required DateTime reviewPeriodStart,
    required DateTime reviewPeriodEnd,
    required Map<String, PerformanceRating> ratings,
    required Map<String, double> goals,
    required List<String> strengths,
    required List<String> areasForImprovement,
    required List<String> developmentGoals,
    required String overallComment,
    required String employeeComment,
    required String reviewerComment,
    required DateTime nextReviewDate,
  }) async {
    final db = await database;
    final reviewId = 'pr_${DateTime.now().millisecondsSinceEpoch}';
    
    final review = PerformanceReview(
      id: reviewId,
      employeeId: employeeId,
      reviewerId: reviewerId,
      reviewDate: DateTime.now(),
      reviewPeriodStart: reviewPeriodStart,
      reviewPeriodEnd: reviewPeriodEnd,
      ratings: ratings,
      goals: goals,
      strengths: strengths,
      areasForImprovement: areasForImprovement,
      developmentGoals: developmentGoals,
      overallComment: overallComment,
      employeeComment: employeeComment,
      reviewerComment: reviewerComment,
      nextReviewDate: nextReviewDate,
    );
    
    await db.insert('performance_reviews', {
      ...review.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'performance_review.create',
      details: 'Performance review created: $reviewId',
      userId: reviewerId,
      resourceId: reviewId,
    );
    
    return reviewId;
  }

  Future<List<PerformanceReview>> getEmployeePerformanceReviews(String employeeId) async {
    final db = await database;
    final result = await db.query(
      'performance_reviews',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'review_date DESC',
    );
    
    return result.map((json) => PerformanceReview.fromJson(json)).toList();
  }

  // Recruitment Management
  Future<String> createRecruitment({
    required String position,
    required String department,
    required String description,
    required List<String> requirements,
    required List<String> responsibilities,
    required double salaryRange,
    required String hiringManagerId,
    DateTime? closingDate,
  }) async {
    final db = await database;
    final recruitmentId = 'rec_${DateTime.now().millisecondsSinceEpoch}';
    
    final recruitment = Recruitment(
      id: recruitmentId,
      position: position,
      department: department,
      description: description,
      requirements: requirements,
      responsibilities: responsibilities,
      salaryRange: salaryRange,
      status: RecruitmentStatus.open,
      postedDate: DateTime.now(),
      closingDate: closingDate,
      hiringManagerId: hiringManagerId,
      applicants: [],
    );
    
    await db.insert('recruitments', {
      ...recruitment.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'recruitment.create',
      details: 'Recruitment created: $recruitmentId',
      userId: hiringManagerId,
      resourceId: recruitmentId,
    );
    
    return recruitmentId;
  }

  Future<List<Recruitment>> getActiveRecruitments() async {
    final db = await database;
    final result = await db.query(
      'recruitments',
      where: 'status IN (?, ?, ?)',
      whereArgs: [
        RecruitmentStatus.open.name,
        RecruitmentStatus.screening.name,
        RecruitmentStatus.interviewing.name,
      ],
      orderBy: 'posted_date DESC',
    );
    
    return result.map((json) => Recruitment.fromJson(json)).toList();
  }

  // Job Application Management
  Future<String> createJobApplication({
    required String recruitmentId,
    required String applicantName,
    required String applicantEmail,
    required String applicantPhone,
    required String resume,
    required String coverLetter,
    required Map<String, dynamic> experience,
    required List<String> skills,
    required List<String> education,
    String? notes,
  }) async {
    final db = await database;
    final applicationId = 'app_${DateTime.now().millisecondsSinceEpoch}';
    
    final application = JobApplication(
      id: applicationId,
      recruitmentId: recruitmentId,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      applicantPhone: applicantPhone,
      resume: resume,
      coverLetter: coverLetter,
      experience: experience,
      skills: skills,
      education: education,
      status: RecruitmentStatus.screening,
      applicationDate: DateTime.now(),
      notes: notes ?? '',
    );
    
    await db.insert('job_applications', {
      ...application.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'job_application.create',
      details: 'Job application created: $applicationId',
      userId: 'system',
      resourceId: applicationId,
    );
    
    return applicationId;
  }

  Future<List<JobApplication>> getJobApplications(String recruitmentId) async {
    final db = await database;
    final result = await db.query(
      'job_applications',
      where: 'recruitment_id = ?',
      whereArgs: [recruitmentId],
      orderBy: 'application_date DESC',
    );
    
    return result.map((json) => JobApplication.fromJson(json)).toList();
  }

  // Training Management
  Future<String> createTrainingProgram({
    required String title,
    required String description,
    required String category,
    required String provider,
    required int duration,
    required double cost,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> targetAudience,
    required List<String> objectives,
    required List<String> prerequisites,
    required String format,
    required int maxParticipants,
  }) async {
    final db = await database;
    final programId = 'tp_${DateTime.now().millisecondsSinceEpoch}';
    
    final program = TrainingProgram(
      id: programId,
      title: title,
      description: description,
      category: category,
      provider: provider,
      duration: duration,
      cost: cost,
      startDate: startDate,
      endDate: endDate,
      targetAudience: targetAudience,
      objectives: objectives,
      prerequisites: prerequisites,
      format: format,
      maxParticipants: maxParticipants,
      enrolledEmployees: [],
      status: TrainingStatus.pending,
    );
    
    await db.insert('training_programs', {
      ...program.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'training_program.create',
      details: 'Training program created: $programId',
      userId: 'system',
      resourceId: programId,
    );
    
    return programId;
  }

  Future<List<TrainingProgram>> getTrainingPrograms() async {
    final db = await database;
    final result = await db.query(
      'training_programs',
      orderBy: 'start_date ASC',
    );
    
    return result.map((json) => TrainingProgram.fromJson(json)).toList();
  }

  Future<String> enrollInTraining({
    required String employeeId,
    required String trainingProgramId,
  }) async {
    final db = await database;
    final enrollmentId = 'tr_${DateTime.now().millisecondsSinceEpoch}';
    
    final record = TrainingRecord(
      id: enrollmentId,
      employeeId: employeeId,
      trainingProgramId: trainingProgramId,
      enrollmentDate: DateTime.now(),
      status: TrainingStatus.pending,
    );
    
    await db.insert('training_records', {
      ...record.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'training_enrollment.create',
      details: 'Training enrollment created: $enrollmentId',
      userId: employeeId,
      resourceId: enrollmentId,
    );
    
    return enrollmentId;
  }

  Future<List<TrainingRecord>> getEmployeeTrainingRecords(String employeeId) async {
    final db = await database;
    final result = await db.query(
      'training_records',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'enrollment_date DESC',
    );
    
    return result.map((json) => TrainingRecord.fromJson(json)).toList();
  }

  // Career Development Management
  Future<String> createCareerDevelopment({
    required String employeeId,
    required String currentPosition,
    required String targetPosition,
    required List<String> careerGoals,
    required List<String> requiredSkills,
    required List<String> currentSkills,
    required List<String> developmentActions,
    required DateTime targetDate,
    required String mentorId,
  }) async {
    final db = await database;
    final developmentId = 'cd_${DateTime.now().millisecondsSinceEpoch}';
    
    final skillGaps = requiredSkills.where((skill) => !currentSkills.contains(skill)).toList();
    
    final development = CareerDevelopment(
      id: developmentId,
      employeeId: employeeId,
      currentPosition: currentPosition,
      targetPosition: targetPosition,
      careerGoals: careerGoals,
      requiredSkills: requiredSkills,
      currentSkills: currentSkills,
      skillGaps: skillGaps,
      developmentActions: developmentActions,
      targetDate: targetDate,
      mentorId: mentorId,
      status: 'active',
    );
    
    await db.insert('career_developments', {
      ...development.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await AuditLogService().insertLog(
      action: 'career_development.create',
      details: 'Career development created: $developmentId',
      userId: employeeId,
      resourceId: developmentId,
    );
    
    return developmentId;
  }

  Future<List<CareerDevelopment>> getEmployeeCareerDevelopment(String employeeId) async {
    final db = await database;
    final result = await db.query(
      'career_developments',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'target_date ASC',
    );
    
    return result.map((json) => CareerDevelopment.fromJson(json)).toList();
  }

  // AI-Powered Features for HR Management
  Future<Map<String, dynamic>> generatePerformanceInsights({
    required String employeeId,
    required Map<String, dynamic> performanceData,
  }) async {
    // Mock AI performance insights - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final insights = <String>[];
    final recommendations = <String>[];
    final strengths = <String>[];
    final areasForImprovement = <String>[];
    
    final ratings = performanceData['ratings'] as Map<String, dynamic>? ?? {};
    final goals = performanceData['goals'] as Map<String, double>? ?? {};
    
    // Performans değerlendirmelerine göre analiz
    ratings.forEach((metric, rating) {
      if (rating == 'excellent') {
        strengths.add('$metric alanında mükemmel performans');
      } else if (rating == 'needsImprovement') {
        areasForImprovement.add('$metric alanında gelişim gerekli');
        recommendations.add('$metric için hedefli eğitim programı');
      }
    });
    
    // Hedeflere göre analiz
    goals.forEach((goal, achievement) {
      if (achievement >= 0.9) {
        insights.add('$goal hedefi başarıyla tamamlandı');
      } else if (achievement < 0.7) {
        insights.add('$goal hedefinde eksiklik var');
        recommendations.add('$goal için destekleyici kaynaklar sağla');
      }
    });
    
    return {
      'insights': insights,
      'recommendations': recommendations,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'evidence': 'Performance analytics and goal tracking',
    };
  }

  Future<Map<String, dynamic>> generateRecruitmentRecommendations({
    required String position,
    required String department,
    required Map<String, dynamic> requirements,
  }) async {
    // Mock AI recruitment recommendations - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 3));
    
    final recommendations = <String>[];
    final sourcingChannels = <String>[];
    final interviewQuestions = <String>[];
    final assessmentMethods = <String>[];
    
    switch (position.toLowerCase()) {
      case 'psychiatrist':
        recommendations.add('Board certification gerekli');
        recommendations.add('Minimum 3 yıl deneyim');
        sourcingChannels.add('Medical school partnerships');
        sourcingChannels.add('Professional associations');
        interviewQuestions.add('Complex case management scenarios');
        assessmentMethods.add('Clinical case presentation');
        break;
      case 'psychologist':
        recommendations.add('PhD veya PsyD derecesi');
        recommendations.add('Licensed practitioner');
        sourcingChannels.add('Psychology graduate programs');
        sourcingChannels.add('Clinical psychology networks');
        interviewQuestions.add('Assessment tool proficiency');
        assessmentMethods.add('Psychological assessment demonstration');
        break;
      case 'therapist':
        recommendations.add('Master\'s degree in counseling');
        recommendations.add('Licensed clinical counselor');
        sourcingChannels.add('Counseling programs');
        sourcingChannels.add('Therapy networks');
        interviewQuestions.add('Therapeutic approach demonstration');
        assessmentMethods.add('Role-play therapy session');
        break;
    }
    
    return {
      'recommendations': recommendations,
      'sourcingChannels': sourcingChannels,
      'interviewQuestions': interviewQuestions,
      'assessmentMethods': assessmentMethods,
      'confidence': 0.80 + (Random().nextDouble() * 0.15),
      'evidence': 'Industry best practices and role requirements',
    };
  }

  Future<Map<String, dynamic>> generateTrainingRecommendations({
    required String employeeId,
    required List<String> currentSkills,
    required String targetPosition,
    required Map<String, dynamic> performanceData,
  }) async {
    // Mock AI training recommendations - gerçek uygulamada AI service kullanılır
    await Future.delayed(const Duration(seconds: 2));
    
    final recommendations = <String>[];
    final trainingPrograms = <Map<String, dynamic>>[];
    final skillGaps = <String>[];
    final priorities = <String>[];
    
    // Performans verilerine göre öneriler
    final ratings = performanceData['ratings'] as Map<String, dynamic>? ?? {};
    ratings.forEach((metric, rating) {
      if (rating == 'needsImprovement') {
        skillGaps.add(metric);
        priorities.add('$metric için acil eğitim gerekli');
      }
    });
    
    // Pozisyon hedefine göre öneriler
    switch (targetPosition.toLowerCase()) {
      case 'senior psychiatrist':
        if (!currentSkills.contains('Leadership')) {
          recommendations.add('Leadership eğitimi');
          trainingPrograms.add({
            'title': 'Medical Leadership Program',
            'duration': 40,
            'priority': 'high',
          });
        }
        if (!currentSkills.contains('Research')) {
          recommendations.add('Klinik araştırma eğitimi');
          trainingPrograms.add({
            'title': 'Clinical Research Methods',
            'duration': 24,
            'priority': 'medium',
          });
        }
        break;
      case 'clinical supervisor':
        if (!currentSkills.contains('Supervision')) {
          recommendations.add('Süpervizyon eğitimi');
          trainingPrograms.add({
            'title': 'Clinical Supervision Training',
            'duration': 32,
            'priority': 'high',
          });
        }
        break;
    }
    
    return {
      'recommendations': recommendations,
      'trainingPrograms': trainingPrograms,
      'skillGaps': skillGaps,
      'priorities': priorities,
      'confidence': 0.88 + (Random().nextDouble() * 0.07),
      'evidence': 'Career development frameworks and performance analysis',
    };
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getHRStatistics(String organizationId) async {
    final db = await database;
    
    final employeesResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM employees 
      WHERE status = 'active'
    ''');
    
    final performanceReviewsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM performance_reviews
    ''');
    
    final recruitmentsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM recruitments
    ''');
    
    final trainingProgramsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM training_programs
    ''');
    
    return {
      'totalEmployees': employeesResult.first['count'] as int,
      'totalPerformanceReviews': performanceReviewsResult.first['count'] as int,
      'totalRecruitments': recruitmentsResult.first['count'] as int,
      'totalTrainingPrograms': trainingProgramsResult.first['count'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getDepartmentHeadcount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        department,
        COUNT(*) as headcount,
        AVG(salary) as avg_salary
      FROM employees
      WHERE status = 'active'
      GROUP BY department
      ORDER BY headcount DESC
    ''');
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getPerformanceTrends() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        pr.review_date,
        COUNT(*) as review_count,
        AVG(CASE WHEN pr.ratings LIKE '%excellent%' THEN 1 ELSE 0 END) as excellent_rate
      FROM performance_reviews pr
      GROUP BY DATE(pr.review_date)
      ORDER BY pr.review_date DESC
      LIMIT 12
    ''');
    
    return result;
  }
}
