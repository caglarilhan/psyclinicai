import 'dart:convert';

enum ComplianceRegion { US, EU, TR, CA, AU }
enum ComplianceStatus { compliant, nonCompliant, partial, pending }
enum ComplianceType { HIPAA, GDPR, KVKK, PIPEDA, PrivacyAct }

class ComplianceReport {
  final String id;
  final ComplianceRegion region;
  final ComplianceType type;
  final ComplianceStatus status;
  final DateTime generatedAt;
  final DateTime validUntil;
  final String generatedBy;
  final List<ComplianceCheck> checks;
  final List<ComplianceViolation> violations;
  final List<ComplianceRecommendation> recommendations;
  final Map<String, dynamic> metadata;

  ComplianceReport({
    required this.id,
    required this.region,
    required this.type,
    required this.status,
    required this.generatedAt,
    required this.validUntil,
    required this.generatedBy,
    required this.checks,
    required this.violations,
    required this.recommendations,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region.name,
      'type': type.name,
      'status': status.name,
      'generatedAt': generatedAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'generatedBy': generatedBy,
      'checks': checks.map((c) => c.toJson()).toList(),
      'violations': violations.map((v) => v.toJson()).toList(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory ComplianceReport.fromJson(Map<String, dynamic> json) {
    return ComplianceReport(
      id: json['id'],
      region: ComplianceRegion.values.firstWhere((e) => e.name == json['region']),
      type: ComplianceType.values.firstWhere((e) => e.name == json['type']),
      status: ComplianceStatus.values.firstWhere((e) => e.name == json['status']),
      generatedAt: DateTime.parse(json['generatedAt']),
      validUntil: DateTime.parse(json['validUntil']),
      generatedBy: json['generatedBy'],
      checks: (json['checks'] as List).map((c) => ComplianceCheck.fromJson(c)).toList(),
      violations: (json['violations'] as List).map((v) => ComplianceViolation.fromJson(v)).toList(),
      recommendations: (json['recommendations'] as List).map((r) => ComplianceRecommendation.fromJson(r)).toList(),
      metadata: json['metadata'] ?? {},
    );
  }
}

class ComplianceCheck {
  final String id;
  final String title;
  final String description;
  final ComplianceStatus status;
  final String? details;
  final DateTime checkedAt;
  final String checkedBy;
  final Map<String, dynamic> evidence;

  ComplianceCheck({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.details,
    required this.checkedAt,
    required this.checkedBy,
    this.evidence = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'details': details,
      'checkedAt': checkedAt.toIso8601String(),
      'checkedBy': checkedBy,
      'evidence': evidence,
    };
  }

  factory ComplianceCheck.fromJson(Map<String, dynamic> json) {
    return ComplianceCheck(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: ComplianceStatus.values.firstWhere((e) => e.name == json['status']),
      details: json['details'],
      checkedAt: DateTime.parse(json['checkedAt']),
      checkedBy: json['checkedBy'],
      evidence: json['evidence'] ?? {},
    );
  }
}

class ComplianceViolation {
  final String id;
  final String title;
  final String description;
  final ComplianceSeverity severity;
  final DateTime detectedAt;
  final String detectedBy;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolution;
  final Map<String, dynamic> details;

  ComplianceViolation({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.detectedAt,
    required this.detectedBy,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
    this.details = const {},
  });

  bool get isResolved => resolvedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity.name,
      'detectedAt': detectedAt.toIso8601String(),
      'detectedBy': detectedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'resolution': resolution,
      'details': details,
    };
  }

  factory ComplianceViolation.fromJson(Map<String, dynamic> json) {
    return ComplianceViolation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      severity: ComplianceSeverity.values.firstWhere((e) => e.name == json['severity']),
      detectedAt: DateTime.parse(json['detectedAt']),
      detectedBy: json['detectedBy'],
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      resolvedBy: json['resolvedBy'],
      resolution: json['resolution'],
      details: json['details'] ?? {},
    );
  }
}

enum ComplianceSeverity { low, medium, high, critical }

class ComplianceRecommendation {
  final String id;
  final String title;
  final String description;
  final CompliancePriority priority;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? implementedAt;
  final String? implementedBy;
  final String? implementation;
  final Map<String, dynamic> details;

  ComplianceRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    required this.createdBy,
    this.implementedAt,
    this.implementedBy,
    this.implementation,
    this.details = const {},
  });

  bool get isImplemented => implementedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'implementedAt': implementedAt?.toIso8601String(),
      'implementedBy': implementedBy,
      'implementation': implementation,
      'details': details,
    };
  }

  factory ComplianceRecommendation.fromJson(Map<String, dynamic> json) {
    return ComplianceRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: CompliancePriority.values.firstWhere((e) => e.name == json['priority']),
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      implementedAt: json['implementedAt'] != null ? DateTime.parse(json['implementedAt']) : null,
      implementedBy: json['implementedBy'],
      implementation: json['implementation'],
      details: json['details'] ?? {},
    );
  }
}

enum CompliancePriority { low, medium, high, urgent }

class DataProcessingRecord {
  final String id;
  final String purpose;
  final String legalBasis;
  final List<String> dataCategories;
  final List<String> recipients;
  final String? thirdCountryTransfer;
  final DateTime retentionPeriod;
  final String dataController;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> details;

  DataProcessingRecord({
    required this.id,
    required this.purpose,
    required this.legalBasis,
    required this.dataCategories,
    required this.recipients,
    this.thirdCountryTransfer,
    required this.retentionPeriod,
    required this.dataController,
    required this.createdAt,
    required this.updatedAt,
    this.details = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purpose': purpose,
      'legalBasis': legalBasis,
      'dataCategories': dataCategories,
      'recipients': recipients,
      'thirdCountryTransfer': thirdCountryTransfer,
      'retentionPeriod': retentionPeriod.toIso8601String(),
      'dataController': dataController,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'details': details,
    };
  }

  factory DataProcessingRecord.fromJson(Map<String, dynamic> json) {
    return DataProcessingRecord(
      id: json['id'],
      purpose: json['purpose'],
      legalBasis: json['legalBasis'],
      dataCategories: List<String>.from(json['dataCategories']),
      recipients: List<String>.from(json['recipients']),
      thirdCountryTransfer: json['thirdCountryTransfer'],
      retentionPeriod: DateTime.parse(json['retentionPeriod']),
      dataController: json['dataController'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      details: json['details'] ?? {},
    );
  }
}

class PrivacyImpactAssessment {
  final String id;
  final String title;
  final String description;
  final ComplianceRegion region;
  final ComplianceType type;
  final List<String> dataSubjects;
  final List<String> dataCategories;
  final String processingPurpose;
  final String legalBasis;
  final List<String> risks;
  final List<String> mitigations;
  final ComplianceStatus status;
  final DateTime assessedAt;
  final String assessedBy;
  final DateTime? approvedAt;
  final String? approvedBy;
  final Map<String, dynamic> details;

  PrivacyImpactAssessment({
    required this.id,
    required this.title,
    required this.description,
    required this.region,
    required this.type,
    required this.dataSubjects,
    required this.dataCategories,
    required this.processingPurpose,
    required this.legalBasis,
    required this.risks,
    required this.mitigations,
    required this.status,
    required this.assessedAt,
    required this.assessedBy,
    this.approvedAt,
    this.approvedBy,
    this.details = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'region': region.name,
      'type': type.name,
      'dataSubjects': dataSubjects,
      'dataCategories': dataCategories,
      'processingPurpose': processingPurpose,
      'legalBasis': legalBasis,
      'risks': risks,
      'mitigations': mitigations,
      'status': status.name,
      'assessedAt': assessedAt.toIso8601String(),
      'assessedBy': assessedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'details': details,
    };
  }

  factory PrivacyImpactAssessment.fromJson(Map<String, dynamic> json) {
    return PrivacyImpactAssessment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      region: ComplianceRegion.values.firstWhere((e) => e.name == json['region']),
      type: ComplianceType.values.firstWhere((e) => e.name == json['type']),
      dataSubjects: List<String>.from(json['dataSubjects']),
      dataCategories: List<String>.from(json['dataCategories']),
      processingPurpose: json['processingPurpose'],
      legalBasis: json['legalBasis'],
      risks: List<String>.from(json['risks']),
      mitigations: List<String>.from(json['mitigations']),
      status: ComplianceStatus.values.firstWhere((e) => e.name == json['status']),
      assessedAt: DateTime.parse(json['assessedAt']),
      assessedBy: json['assessedBy'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      approvedBy: json['approvedBy'],
      details: json['details'] ?? {},
    );
  }
}

class ComplianceDashboard {
  final String id;
  final String userId;
  final List<ComplianceReport> reports;
  final List<ComplianceViolation> activeViolations;
  final List<ComplianceRecommendation> pendingRecommendations;
  final Map<ComplianceRegion, ComplianceStatus> regionalStatus;
  final DateTime generatedAt;
  final Map<String, dynamic> summary;

  ComplianceDashboard({
    required this.id,
    required this.userId,
    required this.reports,
    required this.activeViolations,
    required this.pendingRecommendations,
    required this.regionalStatus,
    required this.generatedAt,
    required this.summary,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'reports': reports.map((r) => r.toJson()).toList(),
      'activeViolations': activeViolations.map((v) => v.toJson()).toList(),
      'pendingRecommendations': pendingRecommendations.map((r) => r.toJson()).toList(),
      'regionalStatus': regionalStatus.map((k, v) => MapEntry(k.name, v.name)),
      'generatedAt': generatedAt.toIso8601String(),
      'summary': summary,
    };
  }

  factory ComplianceDashboard.fromJson(Map<String, dynamic> json) {
    return ComplianceDashboard(
      id: json['id'],
      userId: json['userId'],
      reports: (json['reports'] as List).map((r) => ComplianceReport.fromJson(r)).toList(),
      activeViolations: (json['activeViolations'] as List).map((v) => ComplianceViolation.fromJson(v)).toList(),
      pendingRecommendations: (json['pendingRecommendations'] as List).map((r) => ComplianceRecommendation.fromJson(r)).toList(),
      regionalStatus: (json['regionalStatus'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          ComplianceRegion.values.firstWhere((e) => e.name == k),
          ComplianceStatus.values.firstWhere((e) => e.name == v),
        ),
      ),
      generatedAt: DateTime.parse(json['generatedAt']),
      summary: json['summary'] ?? {},
    );
  }
}
