import 'package:json_annotation/json_annotation.dart';

part 'appointment_models.g.dart';

enum AppointmentType {
  individual,
  group,
  emergency,
  followUp,
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  cancelled,
  noShow,
}

class Appointment {
  final String id;
  final String title;
  final String description;
  final String clientName;
  final DateTime dateTime;
  final AppointmentType type;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? therapistId;
  final String? notes;
  final Duration? duration;
  final bool isRecurring;
  final String? recurringPattern;

  const Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.dateTime,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.therapistId,
    this.notes,
    this.duration,
    this.isRecurring = false,
    this.recurringPattern,
  });

  Appointment copyWith({
    String? id,
    String? title,
    String? description,
    String? clientName,
    DateTime? dateTime,
    AppointmentType? type,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? therapistId,
    String? notes,
    Duration? duration,
    bool? isRecurring,
    String? recurringPattern,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientName: clientName ?? this.clientName,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      therapistId: therapistId ?? this.therapistId,
      notes: notes ?? this.notes,
      duration: duration ?? this.duration,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'clientName': clientName,
      'dateTime': dateTime.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'therapistId': therapistId,
      'notes': notes,
      'duration': duration?.inMinutes,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      clientName: json['clientName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      type: AppointmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppointmentType.individual,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      therapistId: json['therapistId'] as String?,
      notes: json['notes'] as String?,
      duration: json['duration'] != null
          ? Duration(minutes: json['duration'] as int)
          : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringPattern: json['recurringPattern'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Appointment(id: $id, title: $title, clientName: $clientName, dateTime: $dateTime, type: $type, status: $status)';
  }
}

class AppointmentReminder {
  final String id;
  final String appointmentId;
  final DateTime reminderTime;
  final ReminderType type;
  final bool isSent;
  final DateTime? sentAt;
  final String? message;

  const AppointmentReminder({
    required this.id,
    required this.appointmentId,
    required this.reminderTime,
    required this.type,
    this.isSent = false,
    this.sentAt,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'reminderTime': reminderTime.toIso8601String(),
      'type': type.name,
      'isSent': isSent,
      'sentAt': sentAt?.toIso8601String(),
      'message': message,
    };
  }

  factory AppointmentReminder.fromJson(Map<String, dynamic> json) {
    return AppointmentReminder(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      reminderTime: DateTime.parse(json['reminderTime'] as String),
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.sms,
      ),
      isSent: json['isSent'] as bool? ?? false,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      message: json['message'] as String?,
    );
  }
}

enum ReminderType {
  sms,
  email,
  push,
  inApp,
}

class AppointmentConflict {
  final String id;
  final String appointmentId;
  final String conflictingAppointmentId;
  final ConflictType type;
  final String description;
  final DateTime detectedAt;
  final bool isResolved;

  const AppointmentConflict({
    required this.id,
    required this.appointmentId,
    required this.conflictingAppointmentId,
    required this.type,
    required this.description,
    required this.detectedAt,
    this.isResolved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'conflictingAppointmentId': conflictingAppointmentId,
      'type': type.name,
      'description': description,
      'detectedAt': detectedAt.toIso8601String(),
      'isResolved': isResolved,
    };
  }

  factory AppointmentConflict.fromJson(Map<String, dynamic> json) {
    return AppointmentConflict(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      conflictingAppointmentId: json['conflictingAppointmentId'] as String,
      type: ConflictType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConflictType.timeOverlap,
      ),
      description: json['description'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      isResolved: json['isResolved'] as bool? ?? false,
    );
  }
}

enum ConflictType {
  timeOverlap,
  therapistUnavailable,
  roomConflict,
  clientConflict,
}

class AppointmentStatistics {
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int noShowAppointments;
  final double completionRate;
  final double cancellationRate;
  final double noShowRate;
  final Duration averageDuration;
  final Map<AppointmentType, int> appointmentsByType;
  final Map<String, int> appointmentsByTherapist;

  const AppointmentStatistics({
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.noShowAppointments,
    required this.completionRate,
    required this.cancellationRate,
    required this.noShowRate,
    required this.averageDuration,
    required this.appointmentsByType,
    required this.appointmentsByTherapist,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalAppointments': totalAppointments,
      'completedAppointments': completedAppointments,
      'cancelledAppointments': cancelledAppointments,
      'noShowAppointments': noShowAppointments,
      'completionRate': completionRate,
      'cancellationRate': cancellationRate,
      'noShowRate': noShowRate,
      'averageDuration': averageDuration.inMinutes,
      'appointmentsByType': appointmentsByType.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'appointmentsByTherapist': appointmentsByTherapist,
    };
  }

  factory AppointmentStatistics.fromJson(Map<String, dynamic> json) {
    return AppointmentStatistics(
      totalAppointments: json['totalAppointments'] as int,
      completedAppointments: json['completedAppointments'] as int,
      cancelledAppointments: json['cancelledAppointments'] as int,
      noShowAppointments: json['noShowAppointments'] as int,
      completionRate: json['completionRate'] as double,
      cancellationRate: json['cancellationRate'] as double,
      noShowRate: json['noShowRate'] as double,
      averageDuration: Duration(minutes: json['averageDuration'] as int),
      appointmentsByType: (json['appointmentsByType'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          AppointmentType.values.firstWhere(
            (e) => e.name == key,
            orElse: () => AppointmentType.individual,
          ),
          value as int,
        ),
      ),
      appointmentsByTherapist: (json['appointmentsByTherapist'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }
}
