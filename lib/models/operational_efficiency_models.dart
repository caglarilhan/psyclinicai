import 'dart:convert';

enum OptimizationType { appointment, resource, workflow, quality, cost }
enum EfficiencyMetric { utilization, throughput, quality, cost, satisfaction }
enum ResourceType { staff, room, equipment, time, budget }

class AppointmentOptimization {
  final String id;
  final String organizationId;
  final DateTime optimizationDate;
  final Map<String, double> currentMetrics;
  final Map<String, double> optimizedMetrics;
  final List<OptimizationRecommendation> recommendations;
  final double improvementPercentage;
  final String status;
  final Map<String, dynamic> metadata;

  AppointmentOptimization({
    required this.id,
    required this.organizationId,
    required this.optimizationDate,
    required this.currentMetrics,
    required this.optimizedMetrics,
    required this.recommendations,
    required this.improvementPercentage,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'optimizationDate': optimizationDate.toIso8601String(),
      'currentMetrics': currentMetrics,
      'optimizedMetrics': optimizedMetrics,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'improvementPercentage': improvementPercentage,
      'status': status,
      'metadata': metadata,
    };
  }

  factory AppointmentOptimization.fromJson(Map<String, dynamic> json) {
    return AppointmentOptimization(
      id: json['id'],
      organizationId: json['organizationId'],
      optimizationDate: DateTime.parse(json['optimizationDate']),
      currentMetrics: Map<String, double>.from(json['currentMetrics']),
      optimizedMetrics: Map<String, double>.from(json['optimizedMetrics']),
      recommendations: (json['recommendations'] as List).map((r) => OptimizationRecommendation.fromJson(r)).toList(),
      improvementPercentage: json['improvementPercentage'].toDouble(),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class OptimizationRecommendation {
  final String id;
  final String title;
  final String description;
  final OptimizationType type;
  final double impact; // 0 to 1
  final double effort; // 0 to 1
  final double priority; // 0 to 1
  final List<String> requiredResources;
  final DateTime targetDate;
  final String status;
  final Map<String, dynamic> metadata;

  OptimizationRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.effort,
    required this.priority,
    required this.requiredResources,
    required this.targetDate,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'impact': impact,
      'effort': effort,
      'priority': priority,
      'requiredResources': requiredResources,
      'targetDate': targetDate.toIso8601String(),
      'status': status,
      'metadata': metadata,
    };
  }

  factory OptimizationRecommendation.fromJson(Map<String, dynamic> json) {
    return OptimizationRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: OptimizationType.values.firstWhere((e) => e.name == json['type']),
      impact: json['impact'].toDouble(),
      effort: json['effort'].toDouble(),
      priority: json['priority'].toDouble(),
      requiredResources: List<String>.from(json['requiredResources']),
      targetDate: DateTime.parse(json['targetDate']),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class ResourcePlanning {
  final String id;
  final String organizationId;
  final DateTime planningDate;
  final Map<String, ResourceAllocation> resourceAllocations;
  final Map<String, double> utilizationTargets;
  final List<ResourceConstraint> constraints;
  final List<ResourceOptimization> optimizations;
  final String status;
  final Map<String, dynamic> metadata;

  ResourcePlanning({
    required this.id,
    required this.organizationId,
    required this.planningDate,
    required this.resourceAllocations,
    required this.utilizationTargets,
    required this.constraints,
    required this.optimizations,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'planningDate': planningDate.toIso8601String(),
      'resourceAllocations': resourceAllocations.map((k, v) => MapEntry(k, v.toJson())),
      'utilizationTargets': utilizationTargets,
      'constraints': constraints.map((c) => c.toJson()).toList(),
      'optimizations': optimizations.map((o) => o.toJson()).toList(),
      'status': status,
      'metadata': metadata,
    };
  }

  factory ResourcePlanning.fromJson(Map<String, dynamic> json) {
    return ResourcePlanning(
      id: json['id'],
      organizationId: json['organizationId'],
      planningDate: DateTime.parse(json['planningDate']),
      resourceAllocations: (json['resourceAllocations'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, ResourceAllocation.fromJson(v)),
      ),
      utilizationTargets: Map<String, double>.from(json['utilizationTargets']),
      constraints: (json['constraints'] as List).map((c) => ResourceConstraint.fromJson(c)).toList(),
      optimizations: (json['optimizations'] as List).map((o) => ResourceOptimization.fromJson(o)).toList(),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class ResourceAllocation {
  final String id;
  final ResourceType type;
  final String resourceId;
  final String department;
  final double capacity;
  final double utilization;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> assignedTasks;
  final Map<String, dynamic> metadata;

  ResourceAllocation({
    required this.id,
    required this.type,
    required this.resourceId,
    required this.department,
    required this.capacity,
    required this.utilization,
    required this.startDate,
    required this.endDate,
    required this.assignedTasks,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'resourceId': resourceId,
      'department': department,
      'capacity': capacity,
      'utilization': utilization,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'assignedTasks': assignedTasks,
      'metadata': metadata,
    };
  }

  factory ResourceAllocation.fromJson(Map<String, dynamic> json) {
    return ResourceAllocation(
      id: json['id'],
      type: ResourceType.values.firstWhere((e) => e.name == json['type']),
      resourceId: json['resourceId'],
      department: json['department'],
      capacity: json['capacity'].toDouble(),
      utilization: json['utilization'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      assignedTasks: List<String>.from(json['assignedTasks']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class ResourceConstraint {
  final String id;
  final String title;
  final String description;
  final ResourceType resourceType;
  final String constraintType;
  final double impact; // 0 to 1
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> affectedResources;
  final Map<String, dynamic> metadata;

  ResourceConstraint({
    required this.id,
    required this.title,
    required this.description,
    required this.resourceType,
    required this.constraintType,
    required this.impact,
    required this.startDate,
    this.endDate,
    required this.affectedResources,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'resourceType': resourceType.name,
      'constraintType': constraintType,
      'impact': impact,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'affectedResources': affectedResources,
      'metadata': metadata,
    };
  }

  factory ResourceConstraint.fromJson(Map<String, dynamic> json) {
    return ResourceConstraint(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      resourceType: ResourceType.values.firstWhere((e) => e.name == json['resourceType']),
      constraintType: json['constraintType'],
      impact: json['impact'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      affectedResources: List<String>.from(json['affectedResources']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class ResourceOptimization {
  final String id;
  final String title;
  final String description;
  final ResourceType resourceType;
  final double currentEfficiency;
  final double targetEfficiency;
  final List<String> optimizationActions;
  final double expectedImprovement;
  final DateTime targetDate;
  final String status;
  final Map<String, dynamic> metadata;

  ResourceOptimization({
    required this.id,
    required this.title,
    required this.description,
    required this.resourceType,
    required this.currentEfficiency,
    required this.targetEfficiency,
    required this.optimizationActions,
    required this.expectedImprovement,
    required this.targetDate,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'resourceType': resourceType.name,
      'currentEfficiency': currentEfficiency,
      'targetEfficiency': targetEfficiency,
      'optimizationActions': optimizationActions,
      'expectedImprovement': expectedImprovement,
      'targetDate': targetDate.toIso8601String(),
      'status': status,
      'metadata': metadata,
    };
  }

  factory ResourceOptimization.fromJson(Map<String, dynamic> json) {
    return ResourceOptimization(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      resourceType: ResourceType.values.firstWhere((e) => e.name == json['resourceType']),
      currentEfficiency: json['currentEfficiency'].toDouble(),
      targetEfficiency: json['targetEfficiency'].toDouble(),
      optimizationActions: List<String>.from(json['optimizationActions']),
      expectedImprovement: json['expectedImprovement'].toDouble(),
      targetDate: DateTime.parse(json['targetDate']),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class QualityControl {
  final String id;
  final String organizationId;
  final DateTime controlDate;
  final String controlType;
  final Map<String, double> qualityMetrics;
  final List<QualityIssue> issues;
  final List<QualityImprovement> improvements;
  final double overallScore;
  final String status;
  final Map<String, dynamic> metadata;

  QualityControl({
    required this.id,
    required this.organizationId,
    required this.controlDate,
    required this.controlType,
    required this.qualityMetrics,
    required this.issues,
    required this.improvements,
    required this.overallScore,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'controlDate': controlDate.toIso8601String(),
      'controlType': controlType,
      'qualityMetrics': qualityMetrics,
      'issues': issues.map((i) => i.toJson()).toList(),
      'improvements': improvements.map((i) => i.toJson()).toList(),
      'overallScore': overallScore,
      'status': status,
      'metadata': metadata,
    };
  }

  factory QualityControl.fromJson(Map<String, dynamic> json) {
    return QualityControl(
      id: json['id'],
      organizationId: json['organizationId'],
      controlDate: DateTime.parse(json['controlDate']),
      controlType: json['controlType'],
      qualityMetrics: Map<String, double>.from(json['qualityMetrics']),
      issues: (json['issues'] as List).map((i) => QualityIssue.fromJson(i)).toList(),
      improvements: (json['improvements'] as List).map((i) => QualityImprovement.fromJson(i)).toList(),
      overallScore: json['overallScore'].toDouble(),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class QualityIssue {
  final String id;
  final String title;
  final String description;
  final String category;
  final double severity; // 0 to 1
  final String department;
  final String responsiblePerson;
  final DateTime identifiedDate;
  final DateTime? resolvedDate;
  final String status;
  final List<String> correctiveActions;
  final Map<String, dynamic> metadata;

  QualityIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.department,
    required this.responsiblePerson,
    required this.identifiedDate,
    this.resolvedDate,
    required this.status,
    required this.correctiveActions,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'department': department,
      'responsiblePerson': responsiblePerson,
      'identifiedDate': identifiedDate.toIso8601String(),
      'resolvedDate': resolvedDate?.toIso8601String(),
      'status': status,
      'correctiveActions': correctiveActions,
      'metadata': metadata,
    };
  }

  factory QualityIssue.fromJson(Map<String, dynamic> json) {
    return QualityIssue(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      severity: json['severity'].toDouble(),
      department: json['department'],
      responsiblePerson: json['responsiblePerson'],
      identifiedDate: DateTime.parse(json['identifiedDate']),
      resolvedDate: json['resolvedDate'] != null ? DateTime.parse(json['resolvedDate']) : null,
      status: json['status'],
      correctiveActions: List<String>.from(json['correctiveActions']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class QualityImprovement {
  final String id;
  final String title;
  final String description;
  final String category;
  final double expectedImpact; // 0 to 1
  final String department;
  final String responsiblePerson;
  final DateTime startDate;
  final DateTime targetDate;
  final String status;
  final List<String> implementationSteps;
  final Map<String, dynamic> metadata;

  QualityImprovement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.expectedImpact,
    required this.department,
    required this.responsiblePerson,
    required this.startDate,
    required this.targetDate,
    required this.status,
    required this.implementationSteps,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'expectedImpact': expectedImpact,
      'department': department,
      'responsiblePerson': responsiblePerson,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'status': status,
      'implementationSteps': implementationSteps,
      'metadata': metadata,
    };
  }

  factory QualityImprovement.fromJson(Map<String, dynamic> json) {
    return QualityImprovement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      expectedImpact: json['expectedImpact'].toDouble(),
      department: json['department'],
      responsiblePerson: json['responsiblePerson'],
      startDate: DateTime.parse(json['startDate']),
      targetDate: DateTime.parse(json['targetDate']),
      status: json['status'],
      implementationSteps: List<String>.from(json['implementationSteps']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class EfficiencyMetrics {
  final String id;
  final String organizationId;
  final DateTime reportDate;
  final Map<String, double> utilizationRates;
  final Map<String, double> throughputMetrics;
  final Map<String, double> qualityScores;
  final Map<String, double> costMetrics;
  final Map<String, double> satisfactionScores;
  final List<EfficiencyTrend> trends;
  final Map<String, dynamic> metadata;

  EfficiencyMetrics({
    required this.id,
    required this.organizationId,
    required this.reportDate,
    required this.utilizationRates,
    required this.throughputMetrics,
    required this.qualityScores,
    required this.costMetrics,
    required this.satisfactionScores,
    required this.trends,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'reportDate': reportDate.toIso8601String(),
      'utilizationRates': utilizationRates,
      'throughputMetrics': throughputMetrics,
      'qualityScores': qualityScores,
      'costMetrics': costMetrics,
      'satisfactionScores': satisfactionScores,
      'trends': trends.map((t) => t.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory EfficiencyMetrics.fromJson(Map<String, dynamic> json) {
    return EfficiencyMetrics(
      id: json['id'],
      organizationId: json['organizationId'],
      reportDate: DateTime.parse(json['reportDate']),
      utilizationRates: Map<String, double>.from(json['utilizationRates']),
      throughputMetrics: Map<String, double>.from(json['throughputMetrics']),
      qualityScores: Map<String, double>.from(json['qualityScores']),
      costMetrics: Map<String, double>.from(json['costMetrics']),
      satisfactionScores: Map<String, double>.from(json['satisfactionScores']),
      trends: (json['trends'] as List).map((t) => EfficiencyTrend.fromJson(t)).toList(),
      metadata: json['metadata'] ?? {},
    );
  }
}

class EfficiencyTrend {
  final String id;
  final String metricName;
  final EfficiencyMetric metricType;
  final List<double> values;
  final List<DateTime> dates;
  final double trend; // -1 to 1
  final String direction; // increasing, decreasing, stable
  final Map<String, dynamic> metadata;

  EfficiencyTrend({
    required this.id,
    required this.metricName,
    required this.metricType,
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
      'metricType': metricType.name,
      'values': values,
      'dates': dates.map((d) => d.toIso8601String()).toList(),
      'trend': trend,
      'direction': direction,
      'metadata': metadata,
    };
  }

  factory EfficiencyTrend.fromJson(Map<String, dynamic> json) {
    return EfficiencyTrend(
      id: json['id'],
      metricName: json['metricName'],
      metricType: EfficiencyMetric.values.firstWhere((e) => e.name == json['metricType']),
      values: List<double>.from(json['values']),
      dates: (json['dates'] as List).map((d) => DateTime.parse(d)).toList(),
      trend: json['trend'].toDouble(),
      direction: json['direction'],
      metadata: json['metadata'] ?? {},
    );
  }
}
