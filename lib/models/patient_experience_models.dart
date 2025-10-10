import 'dart:convert';

enum SatisfactionLevel { veryDissatisfied, dissatisfied, neutral, satisfied, verySatisfied }
enum ComplaintStatus { open, inProgress, resolved, closed }
enum LoyaltyLevel { low, medium, high, veryHigh }
enum ExperienceType { appointment, treatment, communication, facility, overall }

class PatientSatisfaction {
  final String id;
  final String patientId;
  final String organizationId;
  final DateTime surveyDate;
  final ExperienceType experienceType;
  final Map<String, SatisfactionLevel> ratings;
  final String? comments;
  final String? suggestions;
  final double overallScore;
  final Map<String, dynamic> metadata;

  PatientSatisfaction({
    required this.id,
    required this.patientId,
    required this.organizationId,
    required this.surveyDate,
    required this.experienceType,
    required this.ratings,
    this.comments,
    this.suggestions,
    required this.overallScore,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'organizationId': organizationId,
      'surveyDate': surveyDate.toIso8601String(),
      'experienceType': experienceType.name,
      'ratings': ratings.map((k, v) => MapEntry(k, v.name)),
      'comments': comments,
      'suggestions': suggestions,
      'overallScore': overallScore,
      'metadata': metadata,
    };
  }

  factory PatientSatisfaction.fromJson(Map<String, dynamic> json) {
    return PatientSatisfaction(
      id: json['id'],
      patientId: json['patientId'],
      organizationId: json['organizationId'],
      surveyDate: DateTime.parse(json['surveyDate']),
      experienceType: ExperienceType.values.firstWhere((e) => e.name == json['experienceType']),
      ratings: (json['ratings'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, SatisfactionLevel.values.firstWhere((e) => e.name == v)),
      ),
      comments: json['comments'],
      suggestions: json['suggestions'],
      overallScore: json['overallScore'].toDouble(),
      metadata: json['metadata'] ?? {},
    );
  }
}

class PatientComplaint {
  final String id;
  final String patientId;
  final String organizationId;
  final DateTime complaintDate;
  final String title;
  final String description;
  final String category;
  final ComplaintStatus status;
  final String? assignedTo;
  final DateTime? resolutionDate;
  final String? resolution;
  final String? followUpNotes;
  final Map<String, dynamic> metadata;

  PatientComplaint({
    required this.id,
    required this.patientId,
    required this.organizationId,
    required this.complaintDate,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.assignedTo,
    this.resolutionDate,
    this.resolution,
    this.followUpNotes,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'organizationId': organizationId,
      'complaintDate': complaintDate.toIso8601String(),
      'title': title,
      'description': description,
      'category': category,
      'status': status.name,
      'assignedTo': assignedTo,
      'resolutionDate': resolutionDate?.toIso8601String(),
      'resolution': resolution,
      'followUpNotes': followUpNotes,
      'metadata': metadata,
    };
  }

  factory PatientComplaint.fromJson(Map<String, dynamic> json) {
    return PatientComplaint(
      id: json['id'],
      patientId: json['patientId'],
      organizationId: json['organizationId'],
      complaintDate: DateTime.parse(json['complaintDate']),
      title: json['title'],
      description: json['description'],
      category: json['category'],
      status: ComplaintStatus.values.firstWhere((e) => e.name == json['status']),
      assignedTo: json['assignedTo'],
      resolutionDate: json['resolutionDate'] != null ? DateTime.parse(json['resolutionDate']) : null,
      resolution: json['resolution'],
      followUpNotes: json['followUpNotes'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class PatientLoyalty {
  final String id;
  final String patientId;
  final String organizationId;
  final DateTime assessmentDate;
  final LoyaltyLevel level;
  final double loyaltyScore;
  final List<String> loyaltyFactors;
  final List<String> riskFactors;
  final String? recommendations;
  final Map<String, dynamic> metadata;

  PatientLoyalty({
    required this.id,
    required this.patientId,
    required this.organizationId,
    required this.assessmentDate,
    required this.level,
    required this.loyaltyScore,
    required this.loyaltyFactors,
    required this.riskFactors,
    this.recommendations,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'organizationId': organizationId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'level': level.name,
      'loyaltyScore': loyaltyScore,
      'loyaltyFactors': loyaltyFactors,
      'riskFactors': riskFactors,
      'recommendations': recommendations,
      'metadata': metadata,
    };
  }

  factory PatientLoyalty.fromJson(Map<String, dynamic> json) {
    return PatientLoyalty(
      id: json['id'],
      patientId: json['patientId'],
      organizationId: json['organizationId'],
      assessmentDate: DateTime.parse(json['assessmentDate']),
      level: LoyaltyLevel.values.firstWhere((e) => e.name == json['level']),
      loyaltyScore: json['loyaltyScore'].toDouble(),
      loyaltyFactors: List<String>.from(json['loyaltyFactors']),
      riskFactors: List<String>.from(json['riskFactors']),
      recommendations: json['recommendations'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class ExperienceJourney {
  final String id;
  final String patientId;
  final String organizationId;
  final DateTime journeyDate;
  final List<JourneyStep> steps;
  final Map<String, double> touchpointScores;
  final List<String> painPoints;
  final List<String> positiveMoments;
  final String? overallExperience;
  final Map<String, dynamic> metadata;

  ExperienceJourney({
    required this.id,
    required this.patientId,
    required this.organizationId,
    required this.journeyDate,
    required this.steps,
    required this.touchpointScores,
    required this.painPoints,
    required this.positiveMoments,
    this.overallExperience,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'organizationId': organizationId,
      'journeyDate': journeyDate.toIso8601String(),
      'steps': steps.map((s) => s.toJson()).toList(),
      'touchpointScores': touchpointScores,
      'painPoints': painPoints,
      'positiveMoments': positiveMoments,
      'overallExperience': overallExperience,
      'metadata': metadata,
    };
  }

  factory ExperienceJourney.fromJson(Map<String, dynamic> json) {
    return ExperienceJourney(
      id: json['id'],
      patientId: json['patientId'],
      organizationId: json['organizationId'],
      journeyDate: DateTime.parse(json['journeyDate']),
      steps: (json['steps'] as List).map((s) => JourneyStep.fromJson(s)).toList(),
      touchpointScores: Map<String, double>.from(json['touchpointScores']),
      painPoints: List<String>.from(json['painPoints']),
      positiveMoments: List<String>.from(json['positiveMoments']),
      overallExperience: json['overallExperience'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class JourneyStep {
  final String id;
  final String stepName;
  final String description;
  final DateTime stepDate;
  final double satisfactionScore;
  final List<String> emotions;
  final String? notes;
  final Map<String, dynamic> metadata;

  JourneyStep({
    required this.id,
    required this.stepName,
    required this.description,
    required this.stepDate,
    required this.satisfactionScore,
    required this.emotions,
    this.notes,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepName': stepName,
      'description': description,
      'stepDate': stepDate.toIso8601String(),
      'satisfactionScore': satisfactionScore,
      'emotions': emotions,
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory JourneyStep.fromJson(Map<String, dynamic> json) {
    return JourneyStep(
      id: json['id'],
      stepName: json['stepName'],
      description: json['description'],
      stepDate: DateTime.parse(json['stepDate']),
      satisfactionScore: json['satisfactionScore'].toDouble(),
      emotions: List<String>.from(json['emotions']),
      notes: json['notes'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class PatientFeedback {
  final String id;
  final String patientId;
  final String organizationId;
  final DateTime feedbackDate;
  final String feedbackType;
  final String content;
  final double sentimentScore;
  final List<String> keywords;
  final String? category;
  final String? priority;
  final String? response;
  final DateTime? responseDate;
  final Map<String, dynamic> metadata;

  PatientFeedback({
    required this.id,
    required this.patientId,
    required this.organizationId,
    required this.feedbackDate,
    required this.feedbackType,
    required this.content,
    required this.sentimentScore,
    required this.keywords,
    this.category,
    this.priority,
    this.response,
    this.responseDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'organizationId': organizationId,
      'feedbackDate': feedbackDate.toIso8601String(),
      'feedbackType': feedbackType,
      'content': content,
      'sentimentScore': sentimentScore,
      'keywords': keywords,
      'category': category,
      'priority': priority,
      'response': response,
      'responseDate': responseDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PatientFeedback.fromJson(Map<String, dynamic> json) {
    return PatientFeedback(
      id: json['id'],
      patientId: json['patientId'],
      organizationId: json['organizationId'],
      feedbackDate: DateTime.parse(json['feedbackDate']),
      feedbackType: json['feedbackType'],
      content: json['content'],
      sentimentScore: json['sentimentScore'].toDouble(),
      keywords: List<String>.from(json['keywords']),
      category: json['category'],
      priority: json['priority'],
      response: json['response'],
      responseDate: json['responseDate'] != null ? DateTime.parse(json['responseDate']) : null,
      metadata: json['metadata'] ?? {},
    );
  }
}

class ExperienceMetrics {
  final String id;
  final String organizationId;
  final DateTime reportDate;
  final Map<String, double> satisfactionScores;
  final Map<String, int> complaintCounts;
  final Map<String, double> loyaltyScores;
  final Map<String, double> journeyScores;
  final List<ExperienceTrend> trends;
  final Map<String, dynamic> metadata;

  ExperienceMetrics({
    required this.id,
    required this.organizationId,
    required this.reportDate,
    required this.satisfactionScores,
    required this.complaintCounts,
    required this.loyaltyScores,
    required this.journeyScores,
    required this.trends,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'reportDate': reportDate.toIso8601String(),
      'satisfactionScores': satisfactionScores,
      'complaintCounts': complaintCounts,
      'loyaltyScores': loyaltyScores,
      'journeyScores': journeyScores,
      'trends': trends.map((t) => t.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory ExperienceMetrics.fromJson(Map<String, dynamic> json) {
    return ExperienceMetrics(
      id: json['id'],
      organizationId: json['organizationId'],
      reportDate: DateTime.parse(json['reportDate']),
      satisfactionScores: Map<String, double>.from(json['satisfactionScores']),
      complaintCounts: Map<String, int>.from(json['complaintCounts']),
      loyaltyScores: Map<String, double>.from(json['loyaltyScores']),
      journeyScores: Map<String, double>.from(json['journeyScores']),
      trends: (json['trends'] as List).map((t) => ExperienceTrend.fromJson(t)).toList(),
      metadata: json['metadata'] ?? {},
    );
  }
}

class ExperienceTrend {
  final String id;
  final String metricName;
  final List<double> values;
  final List<DateTime> dates;
  final double trend; // -1 to 1
  final String direction; // increasing, decreasing, stable
  final Map<String, dynamic> metadata;

  ExperienceTrend({
    required this.id,
    required this.metricName,
    required this.values,
    required this.dates,
    required this.trend,
    required this.direction,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metricName': metricName,
      'values': values,
      'dates': dates.map((d) => d.toIso8601String()).toList(),
      'trend': trend,
      'direction': direction,
      'metadata': metadata,
    };
  }

  factory ExperienceTrend.fromJson(Map<String, dynamic> json) {
    return ExperienceTrend(
      id: json['id'],
      metricName: json['metricName'],
      values: List<double>.from(json['values']),
      dates: (json['dates'] as List).map((d) => DateTime.parse(d)).toList(),
      trend: json['trend'].toDouble(),
      direction: json['direction'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class PatientRetention {
  final String id;
  final String patientId;
  final String organizationId;
  final DateTime assessmentDate;
  final double retentionProbability;
  final List<String> retentionFactors;
  final List<String> churnRiskFactors;
  final String? retentionStrategy;
  final DateTime? nextAssessmentDate;
  final Map<String, dynamic> metadata;

  PatientRetention({
    required this.id,
    required this.patientId,
    required this.organizationId,
    required this.assessmentDate,
    required this.retentionProbability,
    required this.retentionFactors,
    required this.churnRiskFactors,
    this.retentionStrategy,
    this.nextAssessmentDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'organizationId': organizationId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'retentionProbability': retentionProbability,
      'retentionFactors': retentionFactors,
      'churnRiskFactors': churnRiskFactors,
      'retentionStrategy': retentionStrategy,
      'nextAssessmentDate': nextAssessmentDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PatientRetention.fromJson(Map<String, dynamic> json) {
    return PatientRetention(
      id: json['id'],
      patientId: json['patientId'],
      organizationId: json['organizationId'],
      assessmentDate: DateTime.parse(json['assessmentDate']),
      retentionProbability: json['retentionProbability'].toDouble(),
      retentionFactors: List<String>.from(json['retentionFactors']),
      churnRiskFactors: List<String>.from(json['churnRiskFactors']),
      retentionStrategy: json['retentionStrategy'],
      nextAssessmentDate: json['nextAssessmentDate'] != null ? DateTime.parse(json['nextAssessmentDate']) : null,
      metadata: json['metadata'] ?? {},
    );
  }
}
