import 'package:json_annotation/json_annotation.dart';

part 'ai_response_models.g.dart';

@JsonSerializable()
class SessionSummaryResponse {
  final String affect;
  final String theme;
  final String icdSuggestion;
  final String riskLevel;
  final String recommendedIntervention;
  final double confidence;

  SessionSummaryResponse({
    required this.affect,
    required this.theme,
    required this.icdSuggestion,
    required this.riskLevel,
    required this.recommendedIntervention,
    required this.confidence,
  });

  factory SessionSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSummaryResponseToJson(this);
}

@JsonSerializable()
class MedicationSuggestion {
  final String medication;
  final String dosage;
  final String rationale;
  final String contraindications;

  MedicationSuggestion({
    required this.medication,
    required this.dosage,
    required this.rationale,
    required this.contraindications,
  });

  factory MedicationSuggestion.fromJson(Map<String, dynamic> json) =>
      _$MedicationSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationSuggestionToJson(this);
}

@JsonSerializable()
class MedicationSuggestionResponse {
  final List<MedicationSuggestion> suggestions;
  final String interactions;

  MedicationSuggestionResponse({
    required this.suggestions,
    required this.interactions,
  });

  factory MedicationSuggestionResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicationSuggestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationSuggestionResponseToJson(this);
}

@JsonSerializable()
class EducationalContentRecommendation {
  final String title;
  final String type;
  final String duration;
  final String level;
  final String description;

  EducationalContentRecommendation({
    required this.title,
    required this.type,
    required this.duration,
    required this.level,
    required this.description,
  });

  factory EducationalContentRecommendation.fromJson(Map<String, dynamic> json) =>
      _$EducationalContentRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$EducationalContentRecommendationToJson(this);
}

@JsonSerializable()
class EducationalContentResponse {
  final List<EducationalContentRecommendation> recommendations;
  final String priority;

  EducationalContentResponse({
    required this.recommendations,
    required this.priority,
  });

  factory EducationalContentResponse.fromJson(Map<String, dynamic> json) =>
      _$EducationalContentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EducationalContentResponseToJson(this);
}

@JsonSerializable()
class AIErrorResponse {
  final String error;
  final String message;
  final String? details;

  AIErrorResponse({
    required this.error,
    required this.message,
    this.details,
  });

  factory AIErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$AIErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AIErrorResponseToJson(this);
}
