import 'dart:convert';

enum ProfessionalType { psychologist, psychiatrist, therapist, counselor, socialWorker }
enum AIServiceType { sessionSummary, diagnostic, riskAssessment, treatmentSuggestion, billingCode, appointmentOptimization, pdfEnhancement }

class AIRequest {
  final String id;
  final String userId;
  final ProfessionalType professionalType;
  final AIServiceType serviceType;
  final String inputText;
  final Map<String, dynamic> context;
  final DateTime requestedAt;
  final String? responseId;

  AIRequest({
    required this.id,
    required this.userId,
    required this.professionalType,
    required this.serviceType,
    required this.inputText,
    this.context = const {},
    required this.requestedAt,
    this.responseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'professionalType': professionalType.name,
      'serviceType': serviceType.name,
      'inputText': inputText,
      'context': context,
      'requestedAt': requestedAt.toIso8601String(),
      'responseId': responseId,
    };
  }

  factory AIRequest.fromJson(Map<String, dynamic> json) {
    return AIRequest(
      id: json['id'],
      userId: json['userId'],
      professionalType: ProfessionalType.values.firstWhere((e) => e.name == json['professionalType']),
      serviceType: AIServiceType.values.firstWhere((e) => e.name == json['serviceType']),
      inputText: json['inputText'],
      context: json['context'] ?? {},
      requestedAt: DateTime.parse(json['requestedAt']),
      responseId: json['responseId'],
    );
  }
}

class AIResponse {
  final String id;
  final String requestId;
  final String content;
  final double confidence;
  final List<String> suggestions;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;
  final bool isApproved;
  final DateTime? approvedAt;
  final String? approvedBy;

  AIResponse({
    required this.id,
    required this.requestId,
    required this.content,
    required this.confidence,
    this.suggestions = const [],
    this.metadata = const {},
    required this.generatedAt,
    this.isApproved = false,
    this.approvedAt,
    this.approvedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'content': content,
      'confidence': confidence,
      'suggestions': suggestions,
      'metadata': metadata,
      'generatedAt': generatedAt.toIso8601String(),
      'isApproved': isApproved,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      id: json['id'],
      requestId: json['requestId'],
      content: json['content'],
      confidence: json['confidence'].toDouble(),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      metadata: json['metadata'] ?? {},
      generatedAt: DateTime.parse(json['generatedAt']),
      isApproved: json['isApproved'] ?? false,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      approvedBy: json['approvedBy'],
    );
  }
}

class SessionSummaryRequest {
  final String sessionNotes;
  final ProfessionalType professionalType;
  final String clientId;
  final String sessionId;
  final Map<String, dynamic> assessmentScores;
  final List<String> keyTopics;

  SessionSummaryRequest({
    required this.sessionNotes,
    required this.professionalType,
    required this.clientId,
    required this.sessionId,
    this.assessmentScores = const {},
    this.keyTopics = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionNotes': sessionNotes,
      'professionalType': professionalType.name,
      'clientId': clientId,
      'sessionId': sessionId,
      'assessmentScores': assessmentScores,
      'keyTopics': keyTopics,
    };
  }
}

class SessionSummaryResponse {
  final String summary;
  final List<String> keyFindings;
  final List<String> actionItems;
  final List<String> followUpTasks;
  final Map<String, dynamic> insights;
  final double confidence;

  SessionSummaryResponse({
    required this.summary,
    required this.keyFindings,
    required this.actionItems,
    required this.followUpTasks,
    this.insights = const {},
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'keyFindings': keyFindings,
      'actionItems': actionItems,
      'followUpTasks': followUpTasks,
      'insights': insights,
      'confidence': confidence,
    };
  }

  factory SessionSummaryResponse.fromJson(Map<String, dynamic> json) {
    return SessionSummaryResponse(
      summary: json['summary'],
      keyFindings: List<String>.from(json['keyFindings']),
      actionItems: List<String>.from(json['actionItems']),
      followUpTasks: List<String>.from(json['followUpTasks']),
      insights: json['insights'] ?? {},
      confidence: json['confidence'].toDouble(),
    );
  }
}

class DiagnosticSuggestion {
  final String assessmentType;
  final int score;
  final String severity;
  final List<String> possibleDiagnoses;
  final List<String> recommendations;
  final List<String> warningSigns;
  final Map<String, dynamic> clinicalNotes;

  DiagnosticSuggestion({
    required this.assessmentType,
    required this.score,
    required this.severity,
    required this.possibleDiagnoses,
    required this.recommendations,
    this.warningSigns = const [],
    this.clinicalNotes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'assessmentType': assessmentType,
      'score': score,
      'severity': severity,
      'possibleDiagnoses': possibleDiagnoses,
      'recommendations': recommendations,
      'warningSigns': warningSigns,
      'clinicalNotes': clinicalNotes,
    };
  }

  factory DiagnosticSuggestion.fromJson(Map<String, dynamic> json) {
    return DiagnosticSuggestion(
      assessmentType: json['assessmentType'],
      score: json['score'],
      severity: json['severity'],
      possibleDiagnoses: List<String>.from(json['possibleDiagnoses']),
      recommendations: List<String>.from(json['recommendations']),
      warningSigns: List<String>.from(json['warningSigns'] ?? []),
      clinicalNotes: json['clinicalNotes'] ?? {},
    );
  }
}

class RiskAssessment {
  final String riskType;
  final String riskLevel;
  final double riskScore;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final List<String> immediateActions;
  final List<String> followUpActions;
  final bool requiresImmediateAttention;

  RiskAssessment({
    required this.riskType,
    required this.riskLevel,
    required this.riskScore,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.immediateActions,
    required this.followUpActions,
    this.requiresImmediateAttention = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'riskType': riskType,
      'riskLevel': riskLevel,
      'riskScore': riskScore,
      'riskFactors': riskFactors,
      'protectiveFactors': protectiveFactors,
      'immediateActions': immediateActions,
      'followUpActions': followUpActions,
      'requiresImmediateAttention': requiresImmediateAttention,
    };
  }

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      riskType: json['riskType'],
      riskLevel: json['riskLevel'],
      riskScore: json['riskScore'].toDouble(),
      riskFactors: List<String>.from(json['riskFactors']),
      protectiveFactors: List<String>.from(json['protectiveFactors']),
      immediateActions: List<String>.from(json['immediateActions']),
      followUpActions: List<String>.from(json['followUpActions']),
      requiresImmediateAttention: json['requiresImmediateAttention'] ?? false,
    );
  }
}

class TreatmentSuggestion {
  final ProfessionalType professionalType;
  final String primaryDiagnosis;
  final List<String> recommendedInterventions;
  final List<String> therapeuticTechniques;
  final List<String> medicationConsiderations;
  final List<String> sessionGoals;
  final Map<String, dynamic> treatmentPlan;

  TreatmentSuggestion({
    required this.professionalType,
    required this.primaryDiagnosis,
    required this.recommendedInterventions,
    required this.therapeuticTechniques,
    this.medicationConsiderations = const [],
    required this.sessionGoals,
    this.treatmentPlan = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'professionalType': professionalType.name,
      'primaryDiagnosis': primaryDiagnosis,
      'recommendedInterventions': recommendedInterventions,
      'therapeuticTechniques': therapeuticTechniques,
      'medicationConsiderations': medicationConsiderations,
      'sessionGoals': sessionGoals,
      'treatmentPlan': treatmentPlan,
    };
  }

  factory TreatmentSuggestion.fromJson(Map<String, dynamic> json) {
    return TreatmentSuggestion(
      professionalType: ProfessionalType.values.firstWhere((e) => e.name == json['professionalType']),
      primaryDiagnosis: json['primaryDiagnosis'],
      recommendedInterventions: List<String>.from(json['recommendedInterventions']),
      therapeuticTechniques: List<String>.from(json['therapeuticTechniques']),
      medicationConsiderations: List<String>.from(json['medicationConsiderations'] ?? []),
      sessionGoals: List<String>.from(json['sessionGoals']),
      treatmentPlan: json['treatmentPlan'] ?? {},
    );
  }
}

class BillingCodeSuggestion {
  final ProfessionalType professionalType;
  final String sessionType;
  final String primaryDiagnosis;
  final int sessionDuration;
  final List<String> recommendedCPTCodes;
  final List<String> recommendedICDCodes;
  final String region;
  final Map<String, dynamic> billingNotes;

  BillingCodeSuggestion({
    required this.professionalType,
    required this.sessionType,
    required this.primaryDiagnosis,
    required this.sessionDuration,
    required this.recommendedCPTCodes,
    required this.recommendedICDCodes,
    required this.region,
    this.billingNotes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'professionalType': professionalType.name,
      'sessionType': sessionType,
      'primaryDiagnosis': primaryDiagnosis,
      'sessionDuration': sessionDuration,
      'recommendedCPTCodes': recommendedCPTCodes,
      'recommendedICDCodes': recommendedICDCodes,
      'region': region,
      'billingNotes': billingNotes,
    };
  }

  factory BillingCodeSuggestion.fromJson(Map<String, dynamic> json) {
    return BillingCodeSuggestion(
      professionalType: ProfessionalType.values.firstWhere((e) => e.name == json['professionalType']),
      sessionType: json['sessionType'],
      primaryDiagnosis: json['primaryDiagnosis'],
      sessionDuration: json['sessionDuration'],
      recommendedCPTCodes: List<String>.from(json['recommendedCPTCodes']),
      recommendedICDCodes: List<String>.from(json['recommendedICDCodes']),
      region: json['region'],
      billingNotes: json['billingNotes'] ?? {},
    );
  }
}
