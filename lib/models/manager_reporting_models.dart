import 'package:flutter/foundation.dart';

enum ReportType { financial, patient, staff, system, performance, compliance, custom }
enum ReportStatus { draft, generated, published, archived }
enum ReportFrequency { daily, weekly, monthly, quarterly, yearly, onDemand }
enum MetricType { count, percentage, average, sum, trend, comparison }

class ManagerReport {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final ReportStatus status;
  final ReportFrequency frequency;
  final DateTime createdAt;
  DateTime? generatedAt;
  DateTime? publishedAt;
  final String createdBy;
  final String? generatedBy;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> data;
  final List<ReportMetric> metrics;
  final List<ReportChart> charts;
  final String? filePath;
  final String? notes;

  ManagerReport({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = ReportStatus.draft,
    required this.frequency,
    required this.createdAt,
    this.generatedAt,
    this.publishedAt,
    required this.createdBy,
    this.generatedBy,
    this.parameters = const {},
    this.data = const {},
    this.metrics = const [],
    this.charts = const [],
    this.filePath,
    this.notes,
  });

  ManagerReport copyWith({
    String? id,
    String? title,
    String? description,
    ReportType? type,
    ReportStatus? status,
    ReportFrequency? frequency,
    DateTime? createdAt,
    DateTime? generatedAt,
    DateTime? publishedAt,
    String? createdBy,
    String? generatedBy,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? data,
    List<ReportMetric>? metrics,
    List<ReportChart>? charts,
    String? filePath,
    String? notes,
  }) {
    return ManagerReport(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      generatedAt: generatedAt ?? this.generatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      createdBy: createdBy ?? this.createdBy,
      generatedBy: generatedBy ?? this.generatedBy,
      parameters: parameters ?? this.parameters,
      data: data ?? this.data,
      metrics: metrics ?? this.metrics,
      charts: charts ?? this.charts,
      filePath: filePath ?? this.filePath,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'frequency': frequency.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'generatedAt': generatedAt?.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'createdBy': createdBy,
      'generatedBy': generatedBy,
      'parameters': parameters,
      'data': data,
      'metrics': metrics.map((metric) => metric.toJson()).toList(),
      'charts': charts.map((chart) => chart.toJson()).toList(),
      'filePath': filePath,
      'notes': notes,
    };
  }

  factory ManagerReport.fromJson(Map<String, dynamic> json) {
    return ManagerReport(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ReportType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      status: ReportStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      frequency: ReportFrequency.values.firstWhere(
          (e) => e.toString().split('.').last == json['frequency'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      generatedBy: json['generatedBy'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>,
      data: json['data'] as Map<String, dynamic>,
      metrics: (json['metrics'] as List)
          .map((metric) => ReportMetric.fromJson(metric as Map<String, dynamic>))
          .toList(),
      charts: (json['charts'] as List)
          .map((chart) => ReportChart.fromJson(chart as Map<String, dynamic>))
          .toList(),
      filePath: json['filePath'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class ReportMetric {
  final String id;
  final String name;
  final String description;
  final MetricType type;
  final dynamic value;
  final String unit;
  final DateTime calculatedAt;
  final Map<String, dynamic>? metadata;

  ReportMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.unit,
    required this.calculatedAt,
    this.metadata,
  });

  ReportMetric copyWith({
    String? id,
    String? name,
    String? description,
    MetricType? type,
    dynamic value,
    String? unit,
    DateTime? calculatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ReportMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'unit': unit,
      'calculatedAt': calculatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ReportMetric.fromJson(Map<String, dynamic> json) {
    return ReportMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: MetricType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      value: json['value'],
      unit: json['unit'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class ReportChart {
  final String id;
  final String title;
  final String chartType;
  final Map<String, dynamic> data;
  final Map<String, dynamic> options;
  final DateTime createdAt;

  ReportChart({
    required this.id,
    required this.title,
    required this.chartType,
    required this.data,
    required this.options,
    required this.createdAt,
  });

  ReportChart copyWith({
    String? id,
    String? title,
    String? chartType,
    Map<String, dynamic>? data,
    Map<String, dynamic>? options,
    DateTime? createdAt,
  }) {
    return ReportChart(
      id: id ?? this.id,
      title: title ?? this.title,
      chartType: chartType ?? this.chartType,
      data: data ?? this.data,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chartType': chartType,
      'data': data,
      'options': options,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportChart.fromJson(Map<String, dynamic> json) {
    return ReportChart(
      id: json['id'] as String,
      title: json['title'] as String,
      chartType: json['chartType'] as String,
      data: json['data'] as Map<String, dynamic>,
      options: json['options'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class DashboardWidget {
  final String id;
  final String title;
  final String widgetType;
  final Map<String, dynamic> configuration;
  final int position;
  final bool isVisible;
  final DateTime createdAt;
  final String createdBy;

  DashboardWidget({
    required this.id,
    required this.title,
    required this.widgetType,
    required this.configuration,
    required this.position,
    this.isVisible = true,
    required this.createdAt,
    required this.createdBy,
  });

  DashboardWidget copyWith({
    String? id,
    String? title,
    String? widgetType,
    Map<String, dynamic>? configuration,
    int? position,
    bool? isVisible,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return DashboardWidget(
      id: id ?? this.id,
      title: title ?? this.title,
      widgetType: widgetType ?? this.widgetType,
      configuration: configuration ?? this.configuration,
      position: position ?? this.position,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'widgetType': widgetType,
      'configuration': configuration,
      'position': position,
      'isVisible': isVisible,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory DashboardWidget.fromJson(Map<String, dynamic> json) {
    return DashboardWidget(
      id: json['id'] as String,
      title: json['title'] as String,
      widgetType: json['widgetType'] as String,
      configuration: json['configuration'] as Map<String, dynamic>,
      position: json['position'] as int,
      isVisible: json['isVisible'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }
}

class PerformanceMetric {
  final String id;
  final String name;
  final String description;
  final String category;
  final dynamic currentValue;
  final dynamic previousValue;
  final dynamic targetValue;
  final String unit;
  final DateTime calculatedAt;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.currentValue,
    required this.previousValue,
    required this.targetValue,
    required this.unit,
    required this.calculatedAt,
    this.metadata,
  });

  PerformanceMetric copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    dynamic currentValue,
    dynamic previousValue,
    dynamic targetValue,
    String? unit,
    DateTime? calculatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      currentValue: currentValue ?? this.currentValue,
      previousValue: previousValue ?? this.previousValue,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'currentValue': currentValue,
      'previousValue': previousValue,
      'targetValue': targetValue,
      'unit': unit,
      'calculatedAt': calculatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      currentValue: json['currentValue'],
      previousValue: json['previousValue'],
      targetValue: json['targetValue'],
      unit: json['unit'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
