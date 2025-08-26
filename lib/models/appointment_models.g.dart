// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentReminder _$AppointmentReminderFromJson(Map<String, dynamic> json) =>
    AppointmentReminder(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      channel: $enumDecode(_$ReminderChannelEnumMap, json['channel']),
      offset: Duration(microseconds: (json['offset'] as num).toInt()),
      isEnabled: json['isEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AppointmentReminderToJson(
  AppointmentReminder instance,
) => <String, dynamic>{
  'id': instance.id,
  'appointmentId': instance.appointmentId,
  'channel': _$ReminderChannelEnumMap[instance.channel]!,
  'offset': instance.offset.inMicroseconds,
  'isEnabled': instance.isEnabled,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

const _$ReminderChannelEnumMap = {
  ReminderChannel.sms: 'sms',
  ReminderChannel.email: 'email',
  ReminderChannel.push: 'push',
  ReminderChannel.call: 'call',
};

RecurrenceRule _$RecurrenceRuleFromJson(Map<String, dynamic> json) =>
    RecurrenceRule(
      frequency: $enumDecode(_$RecurrenceFrequencyEnumMap, json['frequency']),
      interval: (json['interval'] as num?)?.toInt(),
      until: json['until'] == null
          ? null
          : DateTime.parse(json['until'] as String),
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecurrenceRuleToJson(RecurrenceRule instance) =>
    <String, dynamic>{
      'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
      'interval': instance.interval,
      'until': instance.until?.toIso8601String(),
      'count': instance.count,
    };

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.none: 'none',
  RecurrenceFrequency.daily: 'daily',
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.monthly: 'monthly',
};

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  location: json['location'] as String,
  modality: json['modality'] as String,
  status: $enumDecode(_$AppointmentStatusEnumMap, json['status']),
  title: json['title'] as String,
  notes: json['notes'] as String?,
  reminders: (json['reminders'] as List<dynamic>)
      .map((e) => AppointmentReminder.fromJson(e as Map<String, dynamic>))
      .toList(),
  recurrence: json['recurrence'] == null
      ? null
      : RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>),
  isFirstSession: json['isFirstSession'] as bool,
  requiresPreAssessment: json['requiresPreAssessment'] as bool,
  isBillable: json['isBillable'] as bool,
  billingInfo: json['billingInfo'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'location': instance.location,
      'modality': instance.modality,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'title': instance.title,
      'notes': instance.notes,
      'reminders': instance.reminders,
      'recurrence': instance.recurrence,
      'isFirstSession': instance.isFirstSession,
      'requiresPreAssessment': instance.requiresPreAssessment,
      'isBillable': instance.isBillable,
      'billingInfo': instance.billingInfo,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.scheduled: 'scheduled',
  AppointmentStatus.confirmed: 'confirmed',
  AppointmentStatus.checked_in: 'checked_in',
  AppointmentStatus.completed: 'completed',
  AppointmentStatus.cancelled: 'cancelled',
  AppointmentStatus.no_show: 'no_show',
  AppointmentStatus.rescheduled: 'rescheduled',
};

NoShowPrediction _$NoShowPredictionFromJson(Map<String, dynamic> json) =>
    NoShowPrediction(
      appointmentId: json['appointmentId'] as String,
      riskScore: (json['riskScore'] as num).toDouble(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      modelVersion: json['modelVersion'] as String,
      predictedAt: DateTime.parse(json['predictedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$NoShowPredictionToJson(NoShowPrediction instance) =>
    <String, dynamic>{
      'appointmentId': instance.appointmentId,
      'riskScore': instance.riskScore,
      'riskFactors': instance.riskFactors,
      'modelVersion': instance.modelVersion,
      'predictedAt': instance.predictedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

CalendarIntegrationSetting _$CalendarIntegrationSettingFromJson(
  Map<String, dynamic> json,
) => CalendarIntegrationSetting(
  therapistId: json['therapistId'] as String,
  googleCalendarEnabled: json['googleCalendarEnabled'] as bool,
  appleCalendarEnabled: json['appleCalendarEnabled'] as bool,
  outlookCalendarEnabled: json['outlookCalendarEnabled'] as bool,
  timezone: json['timezone'] as String,
  defaultSessionMinutes: (json['defaultSessionMinutes'] as num).toInt(),
  autoConfirm: json['autoConfirm'] as bool,
  metadata: json['metadata'] as Map<String, dynamic>,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CalendarIntegrationSettingToJson(
  CalendarIntegrationSetting instance,
) => <String, dynamic>{
  'therapistId': instance.therapistId,
  'googleCalendarEnabled': instance.googleCalendarEnabled,
  'appleCalendarEnabled': instance.appleCalendarEnabled,
  'outlookCalendarEnabled': instance.outlookCalendarEnabled,
  'timezone': instance.timezone,
  'defaultSessionMinutes': instance.defaultSessionMinutes,
  'autoConfirm': instance.autoConfirm,
  'metadata': instance.metadata,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
