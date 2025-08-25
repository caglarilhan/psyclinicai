import 'package:json_annotation/json_annotation.dart';

part 'session_models.g.dart';

/// Session data model for therapy sessions
@JsonSerializable()
class SessionData {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime date;
  final int duration;
  final String type;
  final String status;
  final String location;
  final String notes;
  final List<String> goals;
  final List<String> interventions;
  final List<String> assessments;
  final List<String> progressNotes;
  final List<String> symptoms;
  final String patientResponse;
  final String treatmentPlan;
  final List<String> nextSteps;
  final List<String> homework;
  final String recommendations;
  final String followUpPlan;
  final List<String> referrals;
  final String? summary;
  final List<String> attachments;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionData({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.date,
    required this.duration,
    required this.type,
    required this.status,
    required this.location,
    required this.notes,
    required this.goals,
    required this.interventions,
    required this.assessments,
    required this.progressNotes,
    required this.symptoms,
    required this.patientResponse,
    required this.treatmentPlan,
    required this.nextSteps,
    required this.homework,
    required this.recommendations,
    required this.followUpPlan,
    required this.referrals,
    this.summary,
    required this.attachments,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) =>
      _$SessionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionDataToJson(this);
}
