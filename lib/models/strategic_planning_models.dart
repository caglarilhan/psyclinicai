import 'dart:convert';

enum MarketSegment { individual, family, corporate, insurance, government }
enum GrowthStrategy { organic, acquisition, partnership, expansion, innovation }
enum CompetitivePosition { leader, challenger, follower, nicher }

class MarketAnalysis {
  final String id;
  final String organizationId;
  final DateTime analysisDate;
  final Map<String, double> marketSize; // segment -> size
  final Map<String, double> marketShare; // segment -> share
  final List<Competitor> competitors;
  final List<MarketTrend> trends;
  final List<Opportunity> opportunities;
  final List<Threat> threats;
  final String summary;
  final Map<String, dynamic> metadata;

  MarketAnalysis({
    required this.id,
    required this.organizationId,
    required this.analysisDate,
    required this.marketSize,
    required this.marketShare,
    required this.competitors,
    required this.trends,
    required this.opportunities,
    required this.threats,
    required this.summary,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'analysisDate': analysisDate.toIso8601String(),
      'marketSize': marketSize,
      'marketShare': marketShare,
      'competitors': competitors.map((c) => c.toJson()).toList(),
      'trends': trends.map((t) => t.toJson()).toList(),
      'opportunities': opportunities.map((o) => o.toJson()).toList(),
      'threats': threats.map((t) => t.toJson()).toList(),
      'summary': summary,
      'metadata': metadata,
    };
  }

  factory MarketAnalysis.fromJson(Map<String, dynamic> json) {
    return MarketAnalysis(
      id: json['id'],
      organizationId: json['organizationId'],
      analysisDate: DateTime.parse(json['analysisDate']),
      marketSize: Map<String, double>.from(json['marketSize']),
      marketShare: Map<String, double>.from(json['marketShare']),
      competitors: (json['competitors'] as List).map((c) => Competitor.fromJson(c)).toList(),
      trends: (json['trends'] as List).map((t) => MarketTrend.fromJson(t)).toList(),
      opportunities: (json['opportunities'] as List).map((o) => Opportunity.fromJson(o)).toList(),
      threats: (json['threats'] as List).map((t) => Threat.fromJson(t)).toList(),
      summary: json['summary'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class Competitor {
  final String id;
  final String name;
  final String description;
  final CompetitivePosition position;
  final Map<String, double> strengths;
  final Map<String, double> weaknesses;
  final List<String> services;
  final Map<String, dynamic> pricing;
  final String marketShare;
  final Map<String, dynamic> metadata;

  Competitor({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.strengths,
    required this.weaknesses,
    required this.services,
    required this.pricing,
    required this.marketShare,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'position': position.name,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'services': services,
      'pricing': pricing,
      'marketShare': marketShare,
      'metadata': metadata,
    };
  }

  factory Competitor.fromJson(Map<String, dynamic> json) {
    return Competitor(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      position: CompetitivePosition.values.firstWhere((e) => e.name == json['position']),
      strengths: Map<String, double>.from(json['strengths']),
      weaknesses: Map<String, double>.from(json['weaknesses']),
      services: List<String>.from(json['services']),
      pricing: Map<String, dynamic>.from(json['pricing']),
      marketShare: json['marketShare'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class MarketTrend {
  final String id;
  final String name;
  final String description;
  final String category;
  final double impact; // -1 to 1
  final double probability; // 0 to 1
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> affectedSegments;
  final Map<String, dynamic> metadata;

  MarketTrend({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.impact,
    required this.probability,
    required this.startDate,
    this.endDate,
    required this.affectedSegments,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'impact': impact,
      'probability': probability,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'affectedSegments': affectedSegments,
      'metadata': metadata,
    };
  }

  factory MarketTrend.fromJson(Map<String, dynamic> json) {
    return MarketTrend(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      impact: json['impact'].toDouble(),
      probability: json['probability'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      affectedSegments: List<String>.from(json['affectedSegments']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class Opportunity {
  final String id;
  final String title;
  final String description;
  final String category;
  final double potential; // 0 to 1
  final double feasibility; // 0 to 1
  final DateTime identifiedDate;
  final DateTime? targetDate;
  final List<String> requiredResources;
  final Map<String, dynamic> metadata;

  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.potential,
    required this.feasibility,
    required this.identifiedDate,
    this.targetDate,
    required this.requiredResources,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'potential': potential,
      'feasibility': feasibility,
      'identifiedDate': identifiedDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'requiredResources': requiredResources,
      'metadata': metadata,
    };
  }

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      potential: json['potential'].toDouble(),
      feasibility: json['feasibility'].toDouble(),
      identifiedDate: DateTime.parse(json['identifiedDate']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      requiredResources: List<String>.from(json['requiredResources']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class Threat {
  final String id;
  final String title;
  final String description;
  final String category;
  final double severity; // 0 to 1
  final double probability; // 0 to 1
  final DateTime identifiedDate;
  final DateTime? expectedDate;
  final List<String> mitigationStrategies;
  final Map<String, dynamic> metadata;

  Threat({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.probability,
    required this.identifiedDate,
    this.expectedDate,
    required this.mitigationStrategies,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'probability': probability,
      'identifiedDate': identifiedDate.toIso8601String(),
      'expectedDate': expectedDate?.toIso8601String(),
      'mitigationStrategies': mitigationStrategies,
      'metadata': metadata,
    };
  }

  factory Threat.fromJson(Map<String, dynamic> json) {
    return Threat(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      severity: json['severity'].toDouble(),
      probability: json['probability'].toDouble(),
      identifiedDate: DateTime.parse(json['identifiedDate']),
      expectedDate: json['expectedDate'] != null ? DateTime.parse(json['expectedDate']) : null,
      mitigationStrategies: List<String>.from(json['mitigationStrategies']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class GrowthProjection {
  final String id;
  final String organizationId;
  final DateTime projectionDate;
  final Map<String, double> revenueProjection; // year -> revenue
  final Map<String, double> patientProjection; // year -> patients
  final Map<String, double> staffProjection; // year -> staff
  final Map<String, double> marketShareProjection; // year -> share
  final List<GrowthStrategy> strategies;
  final Map<String, dynamic> assumptions;
  final String confidence; // high, medium, low
  final Map<String, dynamic> metadata;

  GrowthProjection({
    required this.id,
    required this.organizationId,
    required this.projectionDate,
    required this.revenueProjection,
    required this.patientProjection,
    required this.staffProjection,
    required this.marketShareProjection,
    required this.strategies,
    required this.assumptions,
    required this.confidence,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'projectionDate': projectionDate.toIso8601String(),
      'revenueProjection': revenueProjection,
      'patientProjection': patientProjection,
      'staffProjection': staffProjection,
      'marketShareProjection': marketShareProjection,
      'strategies': strategies.map((s) => s.name).toList(),
      'assumptions': assumptions,
      'confidence': confidence,
      'metadata': metadata,
    };
  }

  factory GrowthProjection.fromJson(Map<String, dynamic> json) {
    return GrowthProjection(
      id: json['id'],
      organizationId: json['organizationId'],
      projectionDate: DateTime.parse(json['projectionDate']),
      revenueProjection: Map<String, double>.from(json['revenueProjection']),
      patientProjection: Map<String, double>.from(json['patientProjection']),
      staffProjection: Map<String, double>.from(json['staffProjection']),
      marketShareProjection: Map<String, double>.from(json['marketShareProjection']),
      strategies: (json['strategies'] as List).map((s) => GrowthStrategy.values.firstWhere((e) => e.name == s)).toList(),
      assumptions: Map<String, dynamic>.from(json['assumptions']),
      confidence: json['confidence'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class PatientSegmentation {
  final String id;
  final String organizationId;
  final DateTime analysisDate;
  final List<PatientSegment> segments;
  final Map<String, double> segmentDistribution;
  final Map<String, double> segmentValue;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  PatientSegmentation({
    required this.id,
    required this.organizationId,
    required this.analysisDate,
    required this.segments,
    required this.segmentDistribution,
    required this.segmentValue,
    required this.recommendations,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'analysisDate': analysisDate.toIso8601String(),
      'segments': segments.map((s) => s.toJson()).toList(),
      'segmentDistribution': segmentDistribution,
      'segmentValue': segmentValue,
      'recommendations': recommendations,
      'metadata': metadata,
    };
  }

  factory PatientSegmentation.fromJson(Map<String, dynamic> json) {
    return PatientSegmentation(
      id: json['id'],
      organizationId: json['organizationId'],
      analysisDate: DateTime.parse(json['analysisDate']),
      segments: (json['segments'] as List).map((s) => PatientSegment.fromJson(s)).toList(),
      segmentDistribution: Map<String, double>.from(json['segmentDistribution']),
      segmentValue: Map<String, double>.from(json['segmentValue']),
      recommendations: List<String>.from(json['recommendations']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class PatientSegment {
  final String id;
  final String name;
  final String description;
  final MarketSegment type;
  final Map<String, dynamic> characteristics;
  final double size;
  final double value;
  final List<String> needs;
  final List<String> preferences;
  final Map<String, dynamic> metadata;

  PatientSegment({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.characteristics,
    required this.size,
    required this.value,
    required this.needs,
    required this.preferences,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'characteristics': characteristics,
      'size': size,
      'value': value,
      'needs': needs,
      'preferences': preferences,
      'metadata': metadata,
    };
  }

  factory PatientSegment.fromJson(Map<String, dynamic> json) {
    return PatientSegment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: MarketSegment.values.firstWhere((e) => e.name == json['type']),
      characteristics: Map<String, dynamic>.from(json['characteristics']),
      size: json['size'].toDouble(),
      value: json['value'].toDouble(),
      needs: List<String>.from(json['needs']),
      preferences: List<String>.from(json['preferences']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class StrategicPlan {
  final String id;
  final String organizationId;
  final DateTime planDate;
  final DateTime validUntil;
  final String vision;
  final String mission;
  final List<String> strategicGoals;
  final List<StrategicObjective> objectives;
  final List<StrategicInitiative> initiatives;
  final Map<String, dynamic> budget;
  final Map<String, dynamic> timeline;
  final String status;
  final Map<String, dynamic> metadata;

  StrategicPlan({
    required this.id,
    required this.organizationId,
    required this.planDate,
    required this.validUntil,
    required this.vision,
    required this.mission,
    required this.strategicGoals,
    required this.objectives,
    required this.initiatives,
    required this.budget,
    required this.timeline,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'planDate': planDate.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'vision': vision,
      'mission': mission,
      'strategicGoals': strategicGoals,
      'objectives': objectives.map((o) => o.toJson()).toList(),
      'initiatives': initiatives.map((i) => i.toJson()).toList(),
      'budget': budget,
      'timeline': timeline,
      'status': status,
      'metadata': metadata,
    };
  }

  factory StrategicPlan.fromJson(Map<String, dynamic> json) {
    return StrategicPlan(
      id: json['id'],
      organizationId: json['organizationId'],
      planDate: DateTime.parse(json['planDate']),
      validUntil: DateTime.parse(json['validUntil']),
      vision: json['vision'],
      mission: json['mission'],
      strategicGoals: List<String>.from(json['strategicGoals']),
      objectives: (json['objectives'] as List).map((o) => StrategicObjective.fromJson(o)).toList(),
      initiatives: (json['initiatives'] as List).map((i) => StrategicInitiative.fromJson(i)).toList(),
      budget: Map<String, dynamic>.from(json['budget']),
      timeline: Map<String, dynamic>.from(json['timeline']),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class StrategicObjective {
  final String id;
  final String title;
  final String description;
  final String category;
  final double priority; // 0 to 1
  final DateTime targetDate;
  final Map<String, double> metrics;
  final List<String> responsibleParties;
  final String status;
  final Map<String, dynamic> metadata;

  StrategicObjective({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.targetDate,
    required this.metrics,
    required this.responsibleParties,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'targetDate': targetDate.toIso8601String(),
      'metrics': metrics,
      'responsibleParties': responsibleParties,
      'status': status,
      'metadata': metadata,
    };
  }

  factory StrategicObjective.fromJson(Map<String, dynamic> json) {
    return StrategicObjective(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'].toDouble(),
      targetDate: DateTime.parse(json['targetDate']),
      metrics: Map<String, double>.from(json['metrics']),
      responsibleParties: List<String>.from(json['responsibleParties']),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class StrategicInitiative {
  final String id;
  final String title;
  final String description;
  final String category;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> deliverables;
  final List<String> stakeholders;
  final String status;
  final Map<String, dynamic> progress;
  final Map<String, dynamic> metadata;

  StrategicInitiative({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.deliverables,
    required this.stakeholders,
    required this.status,
    this.progress = const {},
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'budget': budget,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'deliverables': deliverables,
      'stakeholders': stakeholders,
      'status': status,
      'progress': progress,
      'metadata': metadata,
    };
  }

  factory StrategicInitiative.fromJson(Map<String, dynamic> json) {
    return StrategicInitiative(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      budget: json['budget'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      deliverables: List<String>.from(json['deliverables']),
      stakeholders: List<String>.from(json['stakeholders']),
      status: json['status'],
      progress: json['progress'] ?? {},
      metadata: json['metadata'] ?? {},
    );
  }
}
