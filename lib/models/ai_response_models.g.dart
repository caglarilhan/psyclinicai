// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSummaryResponse _$SessionSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    SessionSummaryResponse(
      affect: json['affect'] as String,
      theme: json['theme'] as String,
      icdSuggestion: json['icdSuggestion'] as String,
      riskLevel: json['riskLevel'] as String,
      recommendedIntervention: json['recommendedIntervention'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$SessionSummaryResponseToJson(
        SessionSummaryResponse instance) =>
    <String, dynamic>{
      'affect': instance.affect,
      'theme': instance.theme,
      'icdSuggestion': instance.icdSuggestion,
      'riskLevel': instance.riskLevel,
      'recommendedIntervention': instance.recommendedIntervention,
      'confidence': instance.confidence,
    };

MedicationSuggestion _$MedicationSuggestionFromJson(
        Map<String, dynamic> json) =>
    MedicationSuggestion(
      medication: json['medication'] as String,
      dosage: json['dosage'] as String,
      rationale: json['rationale'] as String,
      contraindications: json['contraindications'] as String,
    );

Map<String, dynamic> _$MedicationSuggestionToJson(
        MedicationSuggestion instance) =>
    <String, dynamic>{
      'medication': instance.medication,
      'dosage': instance.dosage,
      'rationale': instance.rationale,
      'contraindications': instance.contraindications,
    };

MedicationSuggestionResponse _$MedicationSuggestionResponseFromJson(
        Map<String, dynamic> json) =>
    MedicationSuggestionResponse(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => MedicationSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      interactions: json['interactions'] as String,
    );

Map<String, dynamic> _$MedicationSuggestionResponseToJson(
        MedicationSuggestionResponse instance) =>
    <String, dynamic>{
      'suggestions': instance.suggestions,
      'interactions': instance.interactions,
    };

EducationalContentRecommendation _$EducationalContentRecommendationFromJson(
        Map<String, dynamic> json) =>
    EducationalContentRecommendation(
      title: json['title'] as String,
      type: json['type'] as String,
      duration: json['duration'] as String,
      level: json['level'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$EducationalContentRecommendationToJson(
        EducationalContentRecommendation instance) =>
    <String, dynamic>{
      'title': instance.title,
      'type': instance.type,
      'duration': instance.duration,
      'level': instance.level,
      'description': instance.description,
    };

EducationalContentResponse _$EducationalContentResponseFromJson(
        Map<String, dynamic> json) =>
    EducationalContentResponse(
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => EducationalContentRecommendation.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      priority: json['priority'] as String,
    );

Map<String, dynamic> _$EducationalContentResponseToJson(
        EducationalContentResponse instance) =>
    <String, dynamic>{
      'recommendations': instance.recommendations,
      'priority': instance.priority,
    };

AIErrorResponse _$AIErrorResponseFromJson(Map<String, dynamic> json) =>
    AIErrorResponse(
      error: json['error'] as String,
      message: json['message'] as String,
      details: json['details'] as String?,
    );

Map<String, dynamic> _$AIErrorResponseToJson(AIErrorResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
      'details': instance.details,
    };
