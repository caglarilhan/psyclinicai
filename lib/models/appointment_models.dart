import 'package:json_annotation/json_annotation.dart';

part 'appointment_models.g.dart';

/// Appointment Status - Randevu durumu
enum AppointmentStatus {
  @JsonValue('scheduled') scheduled,
  @JsonValue('confirmed') confirmed,
  @JsonValue('checked_in') checked_in,
  @JsonValue('completed') completed,
  @JsonValue('cancelled') cancelled,
  @JsonValue('no_show') no_show,
  @JsonValue('rescheduled') rescheduled,
}

/// Reminder Channel - Hatırlatıcı kanalı
enum ReminderChannel {
  @JsonValue('sms') sms,
  @JsonValue('email') email,
  @JsonValue('push') push,
  @JsonValue('call') call,
}

/// Recurrence Rule - Tekrarlama kuralı
enum RecurrenceFrequency {
  @JsonValue('none') none,
  @JsonValue('daily') daily,
  @JsonValue('weekly') weekly,
  @JsonValue('monthly') monthly,
}

@JsonSerializable()
class AppointmentReminder {
  final String id;
  final String appointmentId;
  final ReminderChannel channel;
  final Duration offset; // randevuya kaç süre kala
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const AppointmentReminder({
    required this.id,
    required this.appointmentId,
    required this.channel,
    required this.offset,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory AppointmentReminder.fromJson(Map<String, dynamic> json) =>
      _$AppointmentReminderFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentReminderToJson(this);
}

@JsonSerializable()
class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int? interval; // her n günde/haftada vb
  final DateTime? until; // bitiş tarihi
  final int? count; // tekrar sayısı

  const RecurrenceRule({
    required this.frequency,
    this.interval,
    this.until,
    this.count,
  });

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceRuleFromJson(json);
  Map<String, dynamic> toJson() => _$RecurrenceRuleToJson(this);
}

@JsonSerializable()
class Appointment {
  final String id;
  final String clientId;
  final String therapistId;
  final DateTime startTime;
  final DateTime endTime;
  final String location; // Office, Video, Phone
  final String modality; // in-person, video, phone
  final AppointmentStatus status;
  final String title;
  final String? notes;
  final List<AppointmentReminder> reminders;
  final RecurrenceRule? recurrence;
  final bool isFirstSession;
  final bool requiresPreAssessment;
  final bool isBillable;
  final Map<String, dynamic> billingInfo;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.modality,
    required this.status,
    required this.title,
    this.notes,
    required this.reminders,
    this.recurrence,
    required this.isFirstSession,
    required this.requiresPreAssessment,
    required this.isBillable,
    required this.billingInfo,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}

@JsonSerializable()
class NoShowPrediction {
  final String appointmentId;
  final double riskScore; // 0-1
  final List<String> riskFactors;
  final String modelVersion;
  final DateTime predictedAt;
  final Map<String, dynamic> metadata;

  const NoShowPrediction({
    required this.appointmentId,
    required this.riskScore,
    required this.riskFactors,
    required this.modelVersion,
    required this.predictedAt,
    required this.metadata,
  });

  factory NoShowPrediction.fromJson(Map<String, dynamic> json) =>
      _$NoShowPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$NoShowPredictionToJson(this);
}

@JsonSerializable()
class CalendarIntegrationSetting {
  final String therapistId;
  final bool googleCalendarEnabled;
  final bool appleCalendarEnabled;
  final bool outlookCalendarEnabled;
  final String timezone;
  final int defaultSessionMinutes;
  final bool autoConfirm;
  final Map<String, dynamic> metadata;
  final DateTime updatedAt;

  const CalendarIntegrationSetting({
    required this.therapistId,
    required this.googleCalendarEnabled,
    required this.appleCalendarEnabled,
    required this.outlookCalendarEnabled,
    required this.timezone,
    required this.defaultSessionMinutes,
    required this.autoConfirm,
    required this.metadata,
    required this.updatedAt,
  });

  factory CalendarIntegrationSetting.fromJson(Map<String, dynamic> json) =>
      _$CalendarIntegrationSettingFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarIntegrationSettingToJson(this);
}
