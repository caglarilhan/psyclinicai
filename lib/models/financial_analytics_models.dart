import 'dart:convert';

enum CashFlowType { operating, investing, financing }
enum InvestmentType { equipment, technology, marketing, facility, research }
enum CostCategory { personnel, facility, equipment, supplies, marketing, administration }
enum FinancialMetric { revenue, profit, margin, roi, npv, irr }

class CashFlow {
  final String id;
  final String organizationId;
  final DateTime flowDate;
  final CashFlowType type;
  final String description;
  final double amount;
  final String category;
  final String? reference;
  final Map<String, dynamic> metadata;

  CashFlow({
    required this.id,
    required this.organizationId,
    required this.flowDate,
    required this.type,
    required this.description,
    required this.amount,
    required this.category,
    this.reference,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'flowDate': flowDate.toIso8601String(),
      'type': type.name,
      'description': description,
      'amount': amount,
      'category': category,
      'reference': reference,
      'metadata': metadata,
    };
  }

  factory CashFlow.fromJson(Map<String, dynamic> json) {
    return CashFlow(
      id: json['id'],
      organizationId: json['organizationId'],
      flowDate: DateTime.parse(json['flowDate']),
      type: CashFlowType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      reference: json['reference'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class Investment {
  final String id;
  final String organizationId;
  final DateTime investmentDate;
  final InvestmentType type;
  final String title;
  final String description;
  final double amount;
  final double expectedReturn;
  final DateTime expectedReturnDate;
  final String status;
  final Map<String, dynamic> roi;
  final Map<String, dynamic> metadata;

  Investment({
    required this.id,
    required this.organizationId,
    required this.investmentDate,
    required this.type,
    required this.title,
    required this.description,
    required this.amount,
    required this.expectedReturn,
    required this.expectedReturnDate,
    required this.status,
    required this.roi,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'investmentDate': investmentDate.toIso8601String(),
      'type': type.name,
      'title': title,
      'description': description,
      'amount': amount,
      'expectedReturn': expectedReturn,
      'expectedReturnDate': expectedReturnDate.toIso8601String(),
      'status': status,
      'roi': roi,
      'metadata': metadata,
    };
  }

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      organizationId: json['organizationId'],
      investmentDate: DateTime.parse(json['investmentDate']),
      type: InvestmentType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      expectedReturn: json['expectedReturn'].toDouble(),
      expectedReturnDate: DateTime.parse(json['expectedReturnDate']),
      status: json['status'],
      roi: Map<String, dynamic>.from(json['roi']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class CostAnalysis {
  final String id;
  final String organizationId;
  final DateTime analysisDate;
  final Map<String, double> costsByCategory;
  final Map<String, double> costsByDepartment;
  final Map<String, double> costsByPeriod;
  final List<CostOptimization> optimizations;
  final Map<String, dynamic> trends;
  final Map<String, dynamic> metadata;

  CostAnalysis({
    required this.id,
    required this.organizationId,
    required this.analysisDate,
    required this.costsByCategory,
    required this.costsByDepartment,
    required this.costsByPeriod,
    required this.optimizations,
    required this.trends,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'analysisDate': analysisDate.toIso8601String(),
      'costsByCategory': costsByCategory,
      'costsByDepartment': costsByDepartment,
      'costsByPeriod': costsByPeriod,
      'optimizations': optimizations.map((o) => o.toJson()).toList(),
      'trends': trends,
      'metadata': metadata,
    };
  }

  factory CostAnalysis.fromJson(Map<String, dynamic> json) {
    return CostAnalysis(
      id: json['id'],
      organizationId: json['organizationId'],
      analysisDate: DateTime.parse(json['analysisDate']),
      costsByCategory: Map<String, double>.from(json['costsByCategory']),
      costsByDepartment: Map<String, double>.from(json['costsByDepartment']),
      costsByPeriod: Map<String, double>.from(json['costsByPeriod']),
      optimizations: (json['optimizations'] as List).map((o) => CostOptimization.fromJson(o)).toList(),
      trends: Map<String, dynamic>.from(json['trends']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class CostOptimization {
  final String id;
  final String title;
  final String description;
  final CostCategory category;
  final double currentCost;
  final double optimizedCost;
  final double savings;
  final List<String> implementationSteps;
  final DateTime targetDate;
  final String status;
  final Map<String, dynamic> metadata;

  CostOptimization({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.currentCost,
    required this.optimizedCost,
    required this.savings,
    required this.implementationSteps,
    required this.targetDate,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'currentCost': currentCost,
      'optimizedCost': optimizedCost,
      'savings': savings,
      'implementationSteps': implementationSteps,
      'targetDate': targetDate.toIso8601String(),
      'status': status,
      'metadata': metadata,
    };
  }

  factory CostOptimization.fromJson(Map<String, dynamic> json) {
    return CostOptimization(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: CostCategory.values.firstWhere((e) => e.name == json['category']),
      currentCost: json['currentCost'].toDouble(),
      optimizedCost: json['optimizedCost'].toDouble(),
      savings: json['savings'].toDouble(),
      implementationSteps: List<String>.from(json['implementationSteps']),
      targetDate: DateTime.parse(json['targetDate']),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class FinancialProjection {
  final String id;
  final String organizationId;
  final DateTime projectionDate;
  final Map<String, double> revenueProjection;
  final Map<String, double> expenseProjection;
  final Map<String, double> profitProjection;
  final Map<String, double> cashFlowProjection;
  final List<String> assumptions;
  final String confidence;
  final Map<String, dynamic> scenarios;
  final Map<String, dynamic> metadata;

  FinancialProjection({
    required this.id,
    required this.organizationId,
    required this.projectionDate,
    required this.revenueProjection,
    required this.expenseProjection,
    required this.profitProjection,
    required this.cashFlowProjection,
    required this.assumptions,
    required this.confidence,
    required this.scenarios,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'projectionDate': projectionDate.toIso8601String(),
      'revenueProjection': revenueProjection,
      'expenseProjection': expenseProjection,
      'profitProjection': profitProjection,
      'cashFlowProjection': cashFlowProjection,
      'assumptions': assumptions,
      'confidence': confidence,
      'scenarios': scenarios,
      'metadata': metadata,
    };
  }

  factory FinancialProjection.fromJson(Map<String, dynamic> json) {
    return FinancialProjection(
      id: json['id'],
      organizationId: json['organizationId'],
      projectionDate: DateTime.parse(json['projectionDate']),
      revenueProjection: Map<String, double>.from(json['revenueProjection']),
      expenseProjection: Map<String, double>.from(json['expenseProjection']),
      profitProjection: Map<String, double>.from(json['profitProjection']),
      cashFlowProjection: Map<String, double>.from(json['cashFlowProjection']),
      assumptions: List<String>.from(json['assumptions']),
      confidence: json['confidence'],
      scenarios: Map<String, dynamic>.from(json['scenarios']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class FinancialMetrics {
  final String id;
  final String organizationId;
  final DateTime reportDate;
  final Map<String, double> revenueMetrics;
  final Map<String, double> profitMetrics;
  final Map<String, double> marginMetrics;
  final Map<String, double> roiMetrics;
  final List<FinancialTrend> trends;
  final Map<String, dynamic> benchmarks;
  final Map<String, dynamic> metadata;

  FinancialMetrics({
    required this.id,
    required this.organizationId,
    required this.reportDate,
    required this.revenueMetrics,
    required this.profitMetrics,
    required this.marginMetrics,
    required this.roiMetrics,
    required this.trends,
    required this.benchmarks,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'reportDate': reportDate.toIso8601String(),
      'revenueMetrics': revenueMetrics,
      'profitMetrics': profitMetrics,
      'marginMetrics': marginMetrics,
      'roiMetrics': roiMetrics,
      'trends': trends.map((t) => t.toJson()).toList(),
      'benchmarks': benchmarks,
      'metadata': metadata,
    };
  }

  factory FinancialMetrics.fromJson(Map<String, dynamic> json) {
    return FinancialMetrics(
      id: json['id'],
      organizationId: json['organizationId'],
      reportDate: DateTime.parse(json['reportDate']),
      revenueMetrics: Map<String, double>.from(json['revenueMetrics']),
      profitMetrics: Map<String, double>.from(json['profitMetrics']),
      marginMetrics: Map<String, double>.from(json['marginMetrics']),
      roiMetrics: Map<String, double>.from(json['roiMetrics']),
      trends: (json['trends'] as List).map((t) => FinancialTrend.fromJson(t)).toList(),
      benchmarks: Map<String, dynamic>.from(json['benchmarks']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class FinancialTrend {
  final String id;
  final String metricName;
  final FinancialMetric metricType;
  final List<double> values;
  final List<DateTime> dates;
  final double trend; // -1 to 1
  final String direction; // increasing, decreasing, stable
  final Map<String, dynamic> metadata;

  FinancialTrend({
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

  factory FinancialTrend.fromJson(Map<String, dynamic> json) {
    return FinancialTrend(
      id: json['id'],
      metricName: json['metricName'],
      metricType: FinancialMetric.values.firstWhere((e) => e.name == json['metricType']),
      values: List<double>.from(json['values']),
      dates: (json['dates'] as List).map((d) => DateTime.parse(d)).toList(),
      trend: json['trend'].toDouble(),
      direction: json['direction'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class Budget {
  final String id;
  final String organizationId;
  final DateTime budgetDate;
  final DateTime validUntil;
  final Map<String, double> revenueBudget;
  final Map<String, double> expenseBudget;
  final Map<String, double> departmentBudgets;
  final List<String> assumptions;
  final String status;
  final Map<String, dynamic> variance;
  final Map<String, dynamic> metadata;

  Budget({
    required this.id,
    required this.organizationId,
    required this.budgetDate,
    required this.validUntil,
    required this.revenueBudget,
    required this.expenseBudget,
    required this.departmentBudgets,
    required this.assumptions,
    required this.status,
    required this.variance,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'budgetDate': budgetDate.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'revenueBudget': revenueBudget,
      'expenseBudget': expenseBudget,
      'departmentBudgets': departmentBudgets,
      'assumptions': assumptions,
      'status': status,
      'variance': variance,
      'metadata': metadata,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      organizationId: json['organizationId'],
      budgetDate: DateTime.parse(json['budgetDate']),
      validUntil: DateTime.parse(json['validUntil']),
      revenueBudget: Map<String, double>.from(json['revenueBudget']),
      expenseBudget: Map<String, double>.from(json['expenseBudget']),
      departmentBudgets: Map<String, double>.from(json['departmentBudgets']),
      assumptions: List<String>.from(json['assumptions']),
      status: json['status'],
      variance: Map<String, dynamic>.from(json['variance']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class FinancialReport {
  final String id;
  final String organizationId;
  final DateTime reportDate;
  final String reportType;
  final Map<String, dynamic> summary;
  final Map<String, dynamic> details;
  final List<String> keyFindings;
  final List<String> recommendations;
  final String status;
  final Map<String, dynamic> metadata;

  FinancialReport({
    required this.id,
    required this.organizationId,
    required this.reportDate,
    required this.reportType,
    required this.summary,
    required this.details,
    required this.keyFindings,
    required this.recommendations,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'reportDate': reportDate.toIso8601String(),
      'reportType': reportType,
      'summary': summary,
      'details': details,
      'keyFindings': keyFindings,
      'recommendations': recommendations,
      'status': status,
      'metadata': metadata,
    };
  }

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      id: json['id'],
      organizationId: json['organizationId'],
      reportDate: DateTime.parse(json['reportDate']),
      reportType: json['reportType'],
      summary: Map<String, dynamic>.from(json['summary']),
      details: Map<String, dynamic>.from(json['details']),
      keyFindings: List<String>.from(json['keyFindings']),
      recommendations: List<String>.from(json['recommendations']),
      status: json['status'],
      metadata: json['metadata'] ?? {},
    );
  }
}
