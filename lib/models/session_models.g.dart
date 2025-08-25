// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionData _$SessionDataFromJson(Map<String, dynamic> json) => SessionData(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  therapistId: json['therapistId'] as String,
  date: DateTime.parse(json['date'] as String),
  duration: (json['duration'] as num).toInt(),
  type: json['type'] as String,
  status: json['status'] as String,
  location: json['location'] as String,
  notes: json['notes'] as String,
  goals: (json['goals'] as List<dynamic>).map((e) => e as String).toList(),
  interventions: (json['interventions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  assessments: (json['assessments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  progressNotes: (json['progressNotes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  patientResponse: json['patientResponse'] as String,
  treatmentPlan: json['treatmentPlan'] as String,
  nextSteps: (json['nextSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  homework: (json['homework'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: json['recommendations'] as String,
  followUpPlan: json['followUpPlan'] as String,
  referrals: (json['referrals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  summary: json['summary'] as String?,
  attachments: (json['attachments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SessionDataToJson(SessionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'therapistId': instance.therapistId,
      'date': instance.date.toIso8601String(),
      'duration': instance.duration,
      'type': instance.type,
      'status': instance.status,
      'location': instance.location,
      'notes': instance.notes,
      'goals': instance.goals,
      'interventions': instance.interventions,
      'assessments': instance.assessments,
      'progressNotes': instance.progressNotes,
      'symptoms': instance.symptoms,
      'patientResponse': instance.patientResponse,
      'treatmentPlan': instance.treatmentPlan,
      'nextSteps': instance.nextSteps,
      'homework': instance.homework,
      'recommendations': instance.recommendations,
      'followUpPlan': instance.followUpPlan,
      'referrals': instance.referrals,
      'summary': instance.summary,
      'attachments': instance.attachments,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
