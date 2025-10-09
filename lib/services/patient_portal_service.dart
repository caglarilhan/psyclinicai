import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/patient_portal_models.dart';
import 'audit_log_service.dart';

class PatientPortalService {
  static final PatientPortalService _instance = PatientPortalService._internal();
  factory PatientPortalService() => _instance;
  PatientPortalService._internal();

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
    return 'patient-portal-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patient_portal_users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        profile_image_url TEXT,
        created_at TEXT NOT NULL,
        last_login_at TEXT NOT NULL,
        is_active INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE appointment_requests (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        therapist_id TEXT NOT NULL,
        preferred_date TEXT NOT NULL,
        preferred_time TEXT NOT NULL,
        reason TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        approved_at TEXT,
        approved_by TEXT,
        rejection_reason TEXT,
        scheduled_date_time TEXT,
        FOREIGN KEY (patient_id) REFERENCES patient_portal_users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_payments (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        appointment_id TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        status TEXT NOT NULL,
        stripe_payment_intent_id TEXT,
        stripe_session_id TEXT,
        created_at TEXT NOT NULL,
        paid_at TEXT,
        failure_reason TEXT,
        metadata TEXT,
        FOREIGN KEY (patient_id) REFERENCES patient_portal_users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_documents (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        mime_type TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        category TEXT NOT NULL,
        uploaded_at TEXT NOT NULL,
        uploaded_by TEXT NOT NULL,
        is_shared_with_patient INTEGER NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patient_portal_users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_messages (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        therapist_id TEXT NOT NULL,
        message TEXT NOT NULL,
        is_from_patient INTEGER NOT NULL,
        sent_at TEXT NOT NULL,
        is_read INTEGER NOT NULL,
        read_at TEXT,
        attachments TEXT,
        FOREIGN KEY (patient_id) REFERENCES patient_portal_users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_assessments (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        assessment_type TEXT NOT NULL,
        responses TEXT NOT NULL,
        total_score INTEGER NOT NULL,
        severity_level TEXT NOT NULL,
        interpretation TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        therapist_notes TEXT,
        FOREIGN KEY (patient_id) REFERENCES patient_portal_users (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Patient Portal User Management
  Future<String> createPatientPortalUser({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    final db = await database;
    final userId = 'patient_${DateTime.now().millisecondsSinceEpoch}';
    
    final user = PatientPortalUser(
      id: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      dateOfBirth: dateOfBirth,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    await db.insert('patient_portal_users', user.toJson());
    
    await AuditLogService().insertLog(
      action: 'patient_portal.user_create',
      details: 'Patient portal user created: $userId',
      userId: userId,
      resourceId: userId,
    );
    
    return userId;
  }

  Future<PatientPortalUser?> getPatientPortalUser(String userId) async {
    final db = await database;
    final result = await db.query(
      'patient_portal_users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (result.isEmpty) return null;
    return PatientPortalUser.fromJson(result.first);
  }

  Future<PatientPortalUser?> getPatientPortalUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'patient_portal_users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (result.isEmpty) return null;
    return PatientPortalUser.fromJson(result.first);
  }

  Future<bool> updatePatientPortalUser(String userId, Map<String, dynamic> updates) async {
    final db = await database;
    
    updates['last_login_at'] = DateTime.now().toIso8601String();
    
    final result = await db.update(
      'patient_portal_users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'patient_portal.user_update',
        details: 'Patient portal user updated: $userId',
        userId: userId,
        resourceId: userId,
      );
    }
    
    return result > 0;
  }

  // Appointment Request Management
  Future<String> createAppointmentRequest({
    required String patientId,
    required String therapistId,
    required DateTime preferredDate,
    required String preferredTime,
    required String reason,
    String notes = '',
  }) async {
    final db = await database;
    final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    
    final request = AppointmentRequest(
      id: requestId,
      patientId: patientId,
      therapistId: therapistId,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      reason: reason,
      notes: notes,
      createdAt: DateTime.now(),
    );
    
    await db.insert('appointment_requests', request.toJson());
    
    await AuditLogService().insertLog(
      action: 'patient_portal.appointment_request',
      details: 'Appointment request created: $requestId',
      userId: patientId,
      resourceId: requestId,
    );
    
    return requestId;
  }

  Future<List<AppointmentRequest>> getAppointmentRequests(String patientId) async {
    final db = await database;
    final result = await db.query(
      'appointment_requests',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    
    return result.map((json) => AppointmentRequest.fromJson(json)).toList();
  }

  Future<List<AppointmentRequest>> getPendingAppointmentRequests(String therapistId) async {
    final db = await database;
    final result = await db.query(
      'appointment_requests',
      where: 'therapist_id = ? AND status = ?',
      whereArgs: [therapistId, AppointmentRequestStatus.pending.name],
      orderBy: 'created_at ASC',
    );
    
    return result.map((json) => AppointmentRequest.fromJson(json)).toList();
  }

  Future<bool> updateAppointmentRequestStatus({
    required String requestId,
    required AppointmentRequestStatus status,
    String? approvedBy,
    String? rejectionReason,
    DateTime? scheduledDateTime,
  }) async {
    final db = await database;
    
    final updates = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (status == AppointmentRequestStatus.approved) {
      updates['approved_at'] = DateTime.now().toIso8601String();
      updates['approved_by'] = approvedBy;
      if (scheduledDateTime != null) {
        updates['scheduled_date_time'] = scheduledDateTime.toIso8601String();
      }
    } else if (status == AppointmentRequestStatus.rejected) {
      updates['rejection_reason'] = rejectionReason;
    }
    
    final result = await db.update(
      'appointment_requests',
      updates,
      where: 'id = ?',
      whereArgs: [requestId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'patient_portal.appointment_request_update',
        details: 'Appointment request status updated: $requestId to ${status.name}',
        userId: approvedBy ?? 'system',
        resourceId: requestId,
      );
    }
    
    return result > 0;
  }

  // Payment Management
  Future<String> createPayment({
    required String patientId,
    required String appointmentId,
    required double amount,
    String currency = 'USD',
  }) async {
    final db = await database;
    final paymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}';
    
    final payment = PatientPayment(
      id: paymentId,
      patientId: patientId,
      appointmentId: appointmentId,
      amount: amount,
      currency: currency,
      createdAt: DateTime.now(),
    );
    
    await db.insert('patient_payments', payment.toJson());
    
    await AuditLogService().insertLog(
      action: 'patient_portal.payment_create',
      details: 'Payment created: $paymentId',
      userId: patientId,
      resourceId: paymentId,
    );
    
    return paymentId;
  }

  Future<List<PatientPayment>> getPatientPayments(String patientId) async {
    final db = await database;
    final result = await db.query(
      'patient_payments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    
    return result.map((json) => PatientPayment.fromJson(json)).toList();
  }

  Future<bool> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? stripePaymentIntentId,
    String? stripeSessionId,
    String? failureReason,
  }) async {
    final db = await database;
    
    final updates = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (status == PaymentStatus.paid) {
      updates['paid_at'] = DateTime.now().toIso8601String();
    }
    
    if (stripePaymentIntentId != null) {
      updates['stripe_payment_intent_id'] = stripePaymentIntentId;
    }
    
    if (stripeSessionId != null) {
      updates['stripe_session_id'] = stripeSessionId;
    }
    
    if (failureReason != null) {
      updates['failure_reason'] = failureReason;
    }
    
    final result = await db.update(
      'patient_payments',
      updates,
      where: 'id = ?',
      whereArgs: [paymentId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'patient_portal.payment_update',
        details: 'Payment status updated: $paymentId to ${status.name}',
        userId: 'system',
        resourceId: paymentId,
      );
    }
    
    return result > 0;
  }

  // Document Management
  Future<String> uploadDocument({
    required String patientId,
    required String fileName,
    required String filePath,
    required String mimeType,
    required int fileSize,
    required String category,
    required String uploadedBy,
    bool isSharedWithPatient = false,
  }) async {
    final db = await database;
    final documentId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    
    final document = PatientDocument(
      id: documentId,
      patientId: patientId,
      fileName: fileName,
      filePath: filePath,
      mimeType: mimeType,
      fileSize: fileSize,
      category: category,
      uploadedAt: DateTime.now(),
      uploadedBy: uploadedBy,
      isSharedWithPatient: isSharedWithPatient,
    );
    
    await db.insert('patient_documents', document.toJson());
    
    await AuditLogService().insertLog(
      action: 'patient_portal.document_upload',
      details: 'Document uploaded: $documentId',
      userId: uploadedBy,
      resourceId: documentId,
    );
    
    return documentId;
  }

  Future<List<PatientDocument>> getPatientDocuments(String patientId) async {
    final db = await database;
    final result = await db.query(
      'patient_documents',
      where: 'patient_id = ? AND is_shared_with_patient = 1',
      whereArgs: [patientId],
      orderBy: 'uploaded_at DESC',
    );
    
    return result.map((json) => PatientDocument.fromJson(json)).toList();
  }

  // Message Management
  Future<String> sendMessage({
    required String patientId,
    required String therapistId,
    required String message,
    required bool isFromPatient,
    List<String> attachments = const [],
  }) async {
    final db = await database;
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    
    final patientMessage = PatientMessage(
      id: messageId,
      patientId: patientId,
      therapistId: therapistId,
      message: message,
      isFromPatient: isFromPatient,
      sentAt: DateTime.now(),
      attachments: attachments,
    );
    
    await db.insert('patient_messages', patientMessage.toJson());
    
    await AuditLogService().insertLog(
      action: 'patient_portal.message_send',
      details: 'Message sent: $messageId',
      userId: isFromPatient ? patientId : therapistId,
      resourceId: messageId,
    );
    
    return messageId;
  }

  Future<List<PatientMessage>> getPatientMessages(String patientId) async {
    final db = await database;
    final result = await db.query(
      'patient_messages',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'sent_at ASC',
    );
    
    return result.map((json) => PatientMessage.fromJson(json)).toList();
  }

  Future<bool> markMessageAsRead(String messageId) async {
    final db = await database;
    
    final result = await db.update(
      'patient_messages',
      {
        'is_read': 1,
        'read_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [messageId],
    );
    
    return result > 0;
  }

  // Assessment Management
  Future<String> savePatientAssessment({
    required String patientId,
    required String assessmentType,
    required Map<String, dynamic> responses,
    required int totalScore,
    required String severityLevel,
    required String interpretation,
    String? therapistNotes,
  }) async {
    final db = await database;
    final assessmentId = 'assess_${DateTime.now().millisecondsSinceEpoch}';
    
    final assessment = PatientAssessment(
      id: assessmentId,
      patientId: patientId,
      assessmentType: assessmentType,
      responses: responses,
      totalScore: totalScore,
      severityLevel: severityLevel,
      interpretation: interpretation,
      completedAt: DateTime.now(),
      therapistNotes: therapistNotes,
    );
    
    await db.insert('patient_assessments', assessment.toJson());
    
    await AuditLogService().insertLog(
      action: 'patient_portal.assessment_save',
      details: 'Assessment saved: $assessmentId',
      userId: patientId,
      resourceId: assessmentId,
    );
    
    return assessmentId;
  }

  Future<List<PatientAssessment>> getPatientAssessments(String patientId) async {
    final db = await database;
    final result = await db.query(
      'patient_assessments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'completed_at DESC',
    );
    
    return result.map((json) => PatientAssessment.fromJson(json)).toList();
  }

  // Statistics
  Future<Map<String, dynamic>> getPatientPortalStatistics(String patientId) async {
    final db = await database;
    
    final appointmentRequestsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM appointment_requests 
      WHERE patient_id = ?
    ''', [patientId]);
    
    final pendingRequestsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM appointment_requests 
      WHERE patient_id = ? AND status = ?
    ''', [patientId, AppointmentRequestStatus.pending.name]);
    
    final totalPaymentsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM patient_payments 
      WHERE patient_id = ?
    ''', [patientId]);
    
    final paidPaymentsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM patient_payments 
      WHERE patient_id = ? AND status = ?
    ''', [patientId, PaymentStatus.paid.name]);
    
    final unreadMessagesResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM patient_messages 
      WHERE patient_id = ? AND is_from_patient = 0 AND is_read = 0
    ''', [patientId]);
    
    return {
      'totalAppointmentRequests': appointmentRequestsResult.first['count'] as int,
      'pendingAppointmentRequests': pendingRequestsResult.first['count'] as int,
      'totalPayments': totalPaymentsResult.first['count'] as int,
      'paidPayments': paidPaymentsResult.first['count'] as int,
      'unreadMessages': unreadMessagesResult.first['count'] as int,
    };
  }
}
