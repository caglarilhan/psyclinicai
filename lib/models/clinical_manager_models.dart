import 'dart:convert';

enum DepartmentType { psychiatry, psychology, therapy, counseling, socialWork, administration }
enum PerformanceMetric { patientSatisfaction, treatmentOutcomes, sessionAttendance, documentationQuality, compliance }
enum ComplianceType { hipaa, gdpr, kvkk, pipeda, jcaho, carf }

class ClinicalDepartment {
  final String id;
  final String name;
  final DepartmentType type;
  final String managerId;
  final List<String> staffIds;
  final int budget;
  final int targetPatientCapacity;
  final int currentPatientCount;
  final Map<String, dynamic> performanceMetrics;
  final List<String> complianceRequirements;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  ClinicalDepartment({
    required this.id,
    required this.name,
    required this.type,
    required this.managerId,
    required this.staffIds,
    required this.budget,
    required this.targetPatientCapacity,
    required this.currentPatientCount,
    required this.performanceMetrics,
    required this.complianceRequirements,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'managerId': managerId,
      'staffIds': staffIds,
      'budget': budget,
      'targetPatientCapacity': targetPatientCapacity,
      'currentPatientCount': currentPatientCount,
      'performanceMetrics': performanceMetrics,
      'complianceRequirements': complianceRequirements,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ClinicalDepartment.fromJson(Map<String, dynamic> json) {
    return ClinicalDepartment(
      id: json['id'],
      name: json['name'],
      type: DepartmentType.values.firstWhere((e) => e.name == json['type']),
      managerId: json['managerId'],
      staffIds: List<String>.from(json['staffIds']),
      budget: json['budget'],
      targetPatientCapacity: json['targetPatientCapacity'],
      currentPatientCount: json['currentPatientCount'],
      performanceMetrics: Map<String, dynamic>.from(json['performanceMetrics']),
      complianceRequirements: List<String>.from(json['complianceRequirements']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class StaffPerformance {
  final String id;
  final String staffId;
  final String departmentId;
  final DateTime evaluationDate;
  final Map<PerformanceMetric, double> metrics;
  final double overallScore;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> developmentGoals;
  final String evaluatorId;
  final String evaluationNotes;
  final DateTime nextEvaluationDate;
  final Map<String, dynamic> metadata;

  StaffPerformance({
    required this.id,
    required this.staffId,
    required this.departmentId,
    required this.evaluationDate,
    required this.metrics,
    required this.overallScore,
    required this.strengths,
    required this.areasForImprovement,
    required this.developmentGoals,
    required this.evaluatorId,
    required this.evaluationNotes,
    required this.nextEvaluationDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'departmentId': departmentId,
      'evaluationDate': evaluationDate.toIso8601String(),
      'metrics': metrics.map((k, v) => MapEntry(k.name, v)),
      'overallScore': overallScore,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'developmentGoals': developmentGoals,
      'evaluatorId': evaluatorId,
      'evaluationNotes': evaluationNotes,
      'nextEvaluationDate': nextEvaluationDate.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory StaffPerformance.fromJson(Map<String, dynamic> json) {
    return StaffPerformance(
      id: json['id'],
      staffId: json['staffId'],
      departmentId: json['departmentId'],
      evaluationDate: DateTime.parse(json['evaluationDate']),
      metrics: (json['metrics'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(PerformanceMetric.values.firstWhere((e) => e.name == k), v.toDouble()),
      ),
      overallScore: json['overallScore'].toDouble(),
      strengths: List<String>.from(json['strengths']),
      areasForImprovement: List<String>.from(json['areasForImprovement']),
      developmentGoals: List<String>.from(json['developmentGoals']),
      evaluatorId: json['evaluatorId'],
      evaluationNotes: json['evaluationNotes'],
      nextEvaluationDate: DateTime.parse(json['nextEvaluationDate']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class ComplianceAudit {
  final String id;
  final String organizationId;
  final ComplianceType complianceType;
  final DateTime auditDate;
  final String auditorId;
  final List<ComplianceCheck> checks;
  final double complianceScore;
  final List<String> violations;
  final List<String> recommendations;
  final DateTime nextAuditDate;
  final String auditReport;
  final Map<String, dynamic> metadata;

  ComplianceAudit({
    required this.id,
    required this.organizationId,
    required this.complianceType,
    required this.auditDate,
    required this.auditorId,
    required this.checks,
    required this.complianceScore,
    required this.violations,
    required this.recommendations,
    required this.nextAuditDate,
    required this.auditReport,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'complianceType': complianceType.name,
      'auditDate': auditDate.toIso8601String(),
      'auditorId': auditorId,
      'checks': checks.map((c) => c.toJson()).toList(),
      'complianceScore': complianceScore,
      'violations': violations,
      'recommendations': recommendations,
      'nextAuditDate': nextAuditDate.toIso8601String(),
      'auditReport': auditReport,
      'metadata': metadata,
    };
  }

  factory ComplianceAudit.fromJson(Map<String, dynamic> json) {
    return ComplianceAudit(
      id: json['id'],
      organizationId: json['organizationId'],
      complianceType: ComplianceType.values.firstWhere((e) => e.name == json['complianceType']),
      auditDate: DateTime.parse(json['auditDate']),
      auditorId: json['auditorId'],
      checks: (json['checks'] as List).map((c) => ComplianceCheck.fromJson(c)).toList(),
      complianceScore: json['complianceScore'].toDouble(),
      violations: List<String>.from(json['violations']),
      recommendations: List<String>.from(json['recommendations']),
      nextAuditDate: DateTime.parse(json['nextAuditDate']),
      auditReport: json['auditReport'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class ComplianceCheck {
  final String id;
  final String title;
  final String description;
  final bool isCompliant;
  final String? nonComplianceReason;
  final String? correctiveAction;
  final DateTime? correctiveActionDate;
  final String checkedBy;
  final Map<String, dynamic> metadata;

  ComplianceCheck({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompliant,
    this.nonComplianceReason,
    this.correctiveAction,
    this.correctiveActionDate,
    required this.checkedBy,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompliant': isCompliant,
      'nonComplianceReason': nonComplianceReason,
      'correctiveAction': correctiveAction,
      'correctiveActionDate': correctiveActionDate?.toIso8601String(),
      'checkedBy': checkedBy,
      'metadata': metadata,
    };
  }

  factory ComplianceCheck.fromJson(Map<String, dynamic> json) {
    return ComplianceCheck(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompliant: json['isCompliant'],
      nonComplianceReason: json['nonComplianceReason'],
      correctiveAction: json['correctiveAction'],
      correctiveActionDate: json['correctiveActionDate'] != null ? DateTime.parse(json['correctiveActionDate']) : null,
      checkedBy: json['checkedBy'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class FinancialReport {
  final String id;
  final String organizationId;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalRevenue;
  final double totalExpenses;
  final double netIncome;
  final Map<String, double> revenueByDepartment;
  final Map<String, double> expensesByCategory;
  final List<FinancialAlert> alerts;
  final String reportSummary;
  final Map<String, dynamic> metadata;

  FinancialReport({
    required this.id,
    required this.organizationId,
    required this.reportDate,
    required this.periodStart,
    required this.periodEnd,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netIncome,
    required this.revenueByDepartment,
    required this.expensesByCategory,
    required this.alerts,
    required this.reportSummary,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'reportDate': reportDate.toIso8601String(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'netIncome': netIncome,
      'revenueByDepartment': revenueByDepartment,
      'expensesByCategory': expensesByCategory,
      'alerts': alerts.map((a) => a.toJson()).toList(),
      'reportSummary': reportSummary,
      'metadata': metadata,
    };
  }

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      id: json['id'],
      organizationId: json['organizationId'],
      reportDate: DateTime.parse(json['reportDate']),
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      totalRevenue: json['totalRevenue'].toDouble(),
      totalExpenses: json['totalExpenses'].toDouble(),
      netIncome: json['netIncome'].toDouble(),
      revenueByDepartment: Map<String, double>.from(json['revenueByDepartment']),
      expensesByCategory: Map<String, double>.from(json['expensesByCategory']),
      alerts: (json['alerts'] as List).map((a) => FinancialAlert.fromJson(a)).toList(),
      reportSummary: json['reportSummary'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class FinancialAlert {
  final String id;
  final String type;
  final String severity;
  final String message;
  final double amount;
  final DateTime alertDate;
  final bool isResolved;
  final String? resolution;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  FinancialAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.amount,
    required this.alertDate,
    this.isResolved = false,
    this.resolution,
    this.resolvedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'message': message,
      'amount': amount,
      'alertDate': alertDate.toIso8601String(),
      'isResolved': isResolved,
      'resolution': resolution,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory FinancialAlert.fromJson(Map<String, dynamic> json) {
    return FinancialAlert(
      id: json['id'],
      type: json['type'],
      severity: json['severity'],
      message: json['message'],
      amount: json['amount'].toDouble(),
      alertDate: DateTime.parse(json['alertDate']),
      isResolved: json['isResolved'] ?? false,
      resolution: json['resolution'],
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      metadata: json['metadata'] ?? {},
    );
  }
}

class QualityMetrics {
  final String id;
  final String organizationId;
  final DateTime reportDate;
  final Map<String, double> patientSatisfaction;
  final Map<String, double> treatmentOutcomes;
  final Map<String, double> staffPerformance;
  final Map<String, double> complianceScores;
  final List<String> improvementAreas;
  final List<String> bestPractices;
  final String overallAssessment;
  final Map<String, dynamic> metadata;

  QualityMetrics({
    required this.id,
    required this.organizationId,
    required this.reportDate,
    required this.patientSatisfaction,
    required this.treatmentOutcomes,
    required this.staffPerformance,
    required this.complianceScores,
    required this.improvementAreas,
    required this.bestPractices,
    required this.overallAssessment,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'reportDate': reportDate.toIso8601String(),
      'patientSatisfaction': patientSatisfaction,
      'treatmentOutcomes': treatmentOutcomes,
      'staffPerformance': staffPerformance,
      'complianceScores': complianceScores,
      'improvementAreas': improvementAreas,
      'bestPractices': bestPractices,
      'overallAssessment': overallAssessment,
      'metadata': metadata,
    };
  }

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      id: json['id'],
      organizationId: json['organizationId'],
      reportDate: DateTime.parse(json['reportDate']),
      patientSatisfaction: Map<String, double>.from(json['patientSatisfaction']),
      treatmentOutcomes: Map<String, double>.from(json['treatmentOutcomes']),
      staffPerformance: Map<String, double>.from(json['staffPerformance']),
      complianceScores: Map<String, double>.from(json['complianceScores']),
      improvementAreas: List<String>.from(json['improvementAreas']),
      bestPractices: List<String>.from(json['bestPractices']),
      overallAssessment: json['overallAssessment'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class ResourceAllocation {
  final String id;
  final String organizationId;
  final DateTime allocationDate;
  final Map<String, int> staffAllocation; // department -> staff count
  final Map<String, double> budgetAllocation; // department -> budget
  final Map<String, int> roomAllocation; // department -> room count
  final Map<String, int> equipmentAllocation; // department -> equipment count
  final String allocationRationale;
  final DateTime reviewDate;
  final Map<String, dynamic> metadata;

  ResourceAllocation({
    required this.id,
    required this.organizationId,
    required this.allocationDate,
    required this.staffAllocation,
    required this.budgetAllocation,
    required this.roomAllocation,
    required this.equipmentAllocation,
    required this.allocationRationale,
    required this.reviewDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'allocationDate': allocationDate.toIso8601String(),
      'staffAllocation': staffAllocation,
      'budgetAllocation': budgetAllocation,
      'roomAllocation': roomAllocation,
      'equipmentAllocation': equipmentAllocation,
      'allocationRationale': allocationRationale,
      'reviewDate': reviewDate.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ResourceAllocation.fromJson(Map<String, dynamic> json) {
    return ResourceAllocation(
      id: json['id'],
      organizationId: json['organizationId'],
      allocationDate: DateTime.parse(json['allocationDate']),
      staffAllocation: Map<String, int>.from(json['staffAllocation']),
      budgetAllocation: Map<String, double>.from(json['budgetAllocation']),
      roomAllocation: Map<String, int>.from(json['roomAllocation']),
      equipmentAllocation: Map<String, int>.from(json['equipmentAllocation']),
      allocationRationale: json['allocationRationale'],
      reviewDate: DateTime.parse(json['reviewDate']),
      metadata: json['metadata'] ?? {},
    );
  }
}
