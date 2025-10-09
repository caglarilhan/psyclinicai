import 'dart:convert';

enum AppointmentRequestStatus { pending, approved, rejected, rescheduled }
enum PaymentStatus { pending, paid, failed, refunded }

class PatientPortalUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final DateTime dateOfBirth;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;

  PatientPortalUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dateOfBirth,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory PatientPortalUser.fromJson(Map<String, dynamic> json) {
    return PatientPortalUser(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}

class AppointmentRequest {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime preferredDate;
  final String preferredTime;
  final String reason;
  final String notes;
  final AppointmentRequestStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;
  final DateTime? scheduledDateTime;

  AppointmentRequest({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.preferredDate,
    required this.preferredTime,
    required this.reason,
    this.notes = '',
    this.status = AppointmentRequestStatus.pending,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.scheduledDateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'therapistId': therapistId,
      'preferredDate': preferredDate.toIso8601String(),
      'preferredTime': preferredTime,
      'reason': reason,
      'notes': notes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
      'scheduledDateTime': scheduledDateTime?.toIso8601String(),
    };
  }

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    return AppointmentRequest(
      id: json['id'],
      patientId: json['patientId'],
      therapistId: json['therapistId'],
      preferredDate: DateTime.parse(json['preferredDate']),
      preferredTime: json['preferredTime'],
      reason: json['reason'],
      notes: json['notes'] ?? '',
      status: AppointmentRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt']) 
          : null,
      approvedBy: json['approvedBy'],
      rejectionReason: json['rejectionReason'],
      scheduledDateTime: json['scheduledDateTime'] != null 
          ? DateTime.parse(json['scheduledDateTime']) 
          : null,
    );
  }
}

class PatientPayment {
  final String id;
  final String patientId;
  final String appointmentId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? stripePaymentIntentId;
  final String? stripeSessionId;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  PatientPayment({
    required this.id,
    required this.patientId,
    required this.appointmentId,
    required this.amount,
    this.currency = 'USD',
    this.status = PaymentStatus.pending,
    this.stripePaymentIntentId,
    this.stripeSessionId,
    required this.createdAt,
    this.paidAt,
    this.failureReason,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'stripePaymentIntentId': stripePaymentIntentId,
      'stripeSessionId': stripeSessionId,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  factory PatientPayment.fromJson(Map<String, dynamic> json) {
    return PatientPayment(
      id: json['id'],
      patientId: json['patientId'],
      appointmentId: json['appointmentId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'USD',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      stripePaymentIntentId: json['stripePaymentIntentId'],
      stripeSessionId: json['stripeSessionId'],
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null 
          ? DateTime.parse(json['paidAt']) 
          : null,
      failureReason: json['failureReason'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class PatientDocument {
  final String id;
  final String patientId;
  final String fileName;
  final String filePath;
  final String mimeType;
  final int fileSize;
  final String category; // consent, assessment, report, etc.
  final DateTime uploadedAt;
  final String uploadedBy;
  final bool isSharedWithPatient;

  PatientDocument({
    required this.id,
    required this.patientId,
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
    required this.category,
    required this.uploadedAt,
    required this.uploadedBy,
    this.isSharedWithPatient = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'fileName': fileName,
      'filePath': filePath,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'category': category,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'isSharedWithPatient': isSharedWithPatient,
    };
  }

  factory PatientDocument.fromJson(Map<String, dynamic> json) {
    return PatientDocument(
      id: json['id'],
      patientId: json['patientId'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      mimeType: json['mimeType'],
      fileSize: json['fileSize'],
      category: json['category'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      uploadedBy: json['uploadedBy'],
      isSharedWithPatient: json['isSharedWithPatient'] ?? false,
    );
  }
}

class PatientMessage {
  final String id;
  final String patientId;
  final String therapistId;
  final String message;
  final bool isFromPatient;
  final DateTime sentAt;
  final bool isRead;
  final DateTime? readAt;
  final List<String> attachments;

  PatientMessage({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.message,
    required this.isFromPatient,
    required this.sentAt,
    this.isRead = false,
    this.readAt,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'therapistId': therapistId,
      'message': message,
      'isFromPatient': isFromPatient,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'attachments': attachments,
    };
  }

  factory PatientMessage.fromJson(Map<String, dynamic> json) {
    return PatientMessage(
      id: json['id'],
      patientId: json['patientId'],
      therapistId: json['therapistId'],
      message: json['message'],
      isFromPatient: json['isFromPatient'],
      sentAt: DateTime.parse(json['sentAt']),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt']) 
          : null,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }
}

class PatientAssessment {
  final String id;
  final String patientId;
  final String assessmentType; // PHQ-9, GAD-7, etc.
  final Map<String, dynamic> responses;
  final int totalScore;
  final String severityLevel;
  final String interpretation;
  final DateTime completedAt;
  final String? therapistNotes;

  PatientAssessment({
    required this.id,
    required this.patientId,
    required this.assessmentType,
    required this.responses,
    required this.totalScore,
    required this.severityLevel,
    required this.interpretation,
    required this.completedAt,
    this.therapistNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'assessmentType': assessmentType,
      'responses': responses,
      'totalScore': totalScore,
      'severityLevel': severityLevel,
      'interpretation': interpretation,
      'completedAt': completedAt.toIso8601String(),
      'therapistNotes': therapistNotes,
    };
  }

  factory PatientAssessment.fromJson(Map<String, dynamic> json) {
    return PatientAssessment(
      id: json['id'],
      patientId: json['patientId'],
      assessmentType: json['assessmentType'],
      responses: json['responses'],
      totalScore: json['totalScore'],
      severityLevel: json['severityLevel'],
      interpretation: json['interpretation'],
      completedAt: DateTime.parse(json['completedAt']),
      therapistNotes: json['therapistNotes'],
    );
  }
}
