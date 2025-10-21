import 'package:flutter/foundation.dart';

enum AppointmentStatus { scheduled, confirmed, inProgress, completed, cancelled, noShow, rescheduled }
enum AppointmentType { consultation, followUp, emergency, group, assessment, therapy }
enum NotificationType { sms, email, push, phone }
enum PriorityLevel { low, normal, high, urgent }

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String secretaryId;
  final DateTime scheduledTime;
  final Duration duration;
  final AppointmentType type;
  final AppointmentStatus status;
  final PriorityLevel priority;
  final String? notes;
  final String? reason;
  final String? location;
  final bool isTelemedicine;
  final String? telemedicineLink;
  final DateTime createdAt;
  DateTime? updatedAt;
  final List<AppointmentReminder> reminders;
  final List<AppointmentHistory> history;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.secretaryId,
    required this.scheduledTime,
    required this.duration,
    required this.type,
    this.status = AppointmentStatus.scheduled,
    this.priority = PriorityLevel.normal,
    this.notes,
    this.reason,
    this.location,
    this.isTelemedicine = false,
    this.telemedicineLink,
    required this.createdAt,
    this.updatedAt,
    this.reminders = const [],
    this.history = const [],
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? secretaryId,
    DateTime? scheduledTime,
    Duration? duration,
    AppointmentType? type,
    AppointmentStatus? status,
    PriorityLevel? priority,
    String? notes,
    String? reason,
    String? location,
    bool? isTelemedicine,
    String? telemedicineLink,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AppointmentReminder>? reminders,
    List<AppointmentHistory>? history,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      secretaryId: secretaryId ?? this.secretaryId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      isTelemedicine: isTelemedicine ?? this.isTelemedicine,
      telemedicineLink: telemedicineLink ?? this.telemedicineLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminders: reminders ?? this.reminders,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'secretaryId': secretaryId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'duration': duration.inMinutes,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'notes': notes,
      'reason': reason,
      'location': location,
      'isTelemedicine': isTelemedicine,
      'telemedicineLink': telemedicineLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
      'history': history.map((h) => h.toJson()).toList(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      secretaryId: json['secretaryId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      duration: Duration(minutes: json['duration'] as int),
      type: AppointmentType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      status: AppointmentStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      priority: PriorityLevel.values.firstWhere(
          (e) => e.toString().split('.').last == json['priority'] as String),
      notes: json['notes'] as String?,
      reason: json['reason'] as String?,
      location: json['location'] as String?,
      isTelemedicine: json['isTelemedicine'] as bool,
      telemedicineLink: json['telemedicineLink'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      reminders: (json['reminders'] as List)
          .map((reminder) => AppointmentReminder.fromJson(reminder as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List)
          .map((h) => AppointmentHistory.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AppointmentReminder {
  final String id;
  final String appointmentId;
  final DateTime reminderTime;
  final NotificationType type;
  final String? message;
  final bool isSent;
  final DateTime? sentAt;
  final String? sentTo;

  AppointmentReminder({
    required this.id,
    required this.appointmentId,
    required this.reminderTime,
    required this.type,
    this.message,
    this.isSent = false,
    this.sentAt,
    this.sentTo,
  });

  AppointmentReminder copyWith({
    String? id,
    String? appointmentId,
    DateTime? reminderTime,
    NotificationType? type,
    String? message,
    bool? isSent,
    DateTime? sentAt,
    String? sentTo,
  }) {
    return AppointmentReminder(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      reminderTime: reminderTime ?? this.reminderTime,
      type: type ?? this.type,
      message: message ?? this.message,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      sentTo: sentTo ?? this.sentTo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'reminderTime': reminderTime.toIso8601String(),
      'type': type.toString().split('.').last,
      'message': message,
      'isSent': isSent,
      'sentAt': sentAt?.toIso8601String(),
      'sentTo': sentTo,
    };
  }

  factory AppointmentReminder.fromJson(Map<String, dynamic> json) {
    return AppointmentReminder(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      reminderTime: DateTime.parse(json['reminderTime'] as String),
      type: NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      message: json['message'] as String?,
      isSent: json['isSent'] as bool,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      sentTo: json['sentTo'] as String?,
    );
  }
}

class AppointmentHistory {
  final String id;
  final String appointmentId;
  final String action;
  final String? description;
  final String performedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AppointmentHistory({
    required this.id,
    required this.appointmentId,
    required this.action,
    this.description,
    required this.performedBy,
    required this.timestamp,
    this.metadata,
  });

  AppointmentHistory copyWith({
    String? id,
    String? appointmentId,
    String? action,
    String? description,
    String? performedBy,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return AppointmentHistory(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      action: action ?? this.action,
      description: description ?? this.description,
      performedBy: performedBy ?? this.performedBy,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'action': action,
      'description': description,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AppointmentHistory.fromJson(Map<String, dynamic> json) {
    return AppointmentHistory(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      action: json['action'] as String,
      description: json['description'] as String?,
      performedBy: json['performedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class WaitingList {
  final String id;
  final String patientId;
  final String doctorId;
  final String secretaryId;
  final AppointmentType preferredType;
  final PriorityLevel priority;
  final DateTime requestedDate;
  final String? preferredTime;
  final String? notes;
  final String? reason;
  final bool isActive;
  final DateTime createdAt;
  DateTime? assignedAt;
  final String? assignedAppointmentId;

  WaitingList({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.secretaryId,
    required this.preferredType,
    this.priority = PriorityLevel.normal,
    required this.requestedDate,
    this.preferredTime,
    this.notes,
    this.reason,
    this.isActive = true,
    required this.createdAt,
    this.assignedAt,
    this.assignedAppointmentId,
  });

  WaitingList copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? secretaryId,
    AppointmentType? preferredType,
    PriorityLevel? priority,
    DateTime? requestedDate,
    String? preferredTime,
    String? notes,
    String? reason,
    bool? isActive,
    DateTime? createdAt,
    DateTime? assignedAt,
    String? assignedAppointmentId,
  }) {
    return WaitingList(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      secretaryId: secretaryId ?? this.secretaryId,
      preferredType: preferredType ?? this.preferredType,
      priority: priority ?? this.priority,
      requestedDate: requestedDate ?? this.requestedDate,
      preferredTime: preferredTime ?? this.preferredTime,
      notes: notes ?? this.notes,
      reason: reason ?? this.reason,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedAppointmentId: assignedAppointmentId ?? this.assignedAppointmentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'secretaryId': secretaryId,
      'preferredType': preferredType.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'requestedDate': requestedDate.toIso8601String(),
      'preferredTime': preferredTime,
      'notes': notes,
      'reason': reason,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'assignedAt': assignedAt?.toIso8601String(),
      'assignedAppointmentId': assignedAppointmentId,
    };
  }

  factory WaitingList.fromJson(Map<String, dynamic> json) {
    return WaitingList(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      secretaryId: json['secretaryId'] as String,
      preferredType: AppointmentType.values.firstWhere(
          (e) => e.toString().split('.').last == json['preferredType'] as String),
      priority: PriorityLevel.values.firstWhere(
          (e) => e.toString().split('.').last == json['priority'] as String),
      requestedDate: DateTime.parse(json['requestedDate'] as String),
      preferredTime: json['preferredTime'] as String?,
      notes: json['notes'] as String?,
      reason: json['reason'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : null,
      assignedAppointmentId: json['assignedAppointmentId'] as String?,
    );
  }
}

class DoctorSchedule {
  final String id;
  final String doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final bool isAvailable;
  final String? notes;
  final List<String> availableTypes;
  final Duration defaultDuration;

  DoctorSchedule({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    this.location,
    this.isAvailable = true,
    this.notes,
    this.availableTypes = const [],
    this.defaultDuration = const Duration(minutes: 30),
  });

  DoctorSchedule copyWith({
    String? id,
    String? doctorId,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isAvailable,
    String? notes,
    List<String>? availableTypes,
    Duration? defaultDuration,
  }) {
    return DoctorSchedule(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
      availableTypes: availableTypes ?? this.availableTypes,
      defaultDuration: defaultDuration ?? this.defaultDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'isAvailable': isAvailable,
      'notes': notes,
      'availableTypes': availableTypes,
      'defaultDuration': defaultDuration.inMinutes,
    };
  }

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String?,
      isAvailable: json['isAvailable'] as bool,
      notes: json['notes'] as String?,
      availableTypes: List<String>.from(json['availableTypes'] as List),
      defaultDuration: Duration(minutes: json['defaultDuration'] as int),
    );
  }
}
