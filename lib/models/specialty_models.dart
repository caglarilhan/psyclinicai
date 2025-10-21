import 'package:flutter/foundation.dart';

enum SpecialtyType {
  psychiatrist,
  psychologist,
  nurse,
  secretary,
  administrator,
  patient
}

class SpecialtyRecommendation {
  final String id;
  final String title;
  final String description;
  final SpecialtyType targetSpecialty;
  final String category;
  final List<String> features;
  final String priority;
  final String? icon;
  final String? color;

  SpecialtyRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.targetSpecialty,
    required this.category,
    required this.features,
    required this.priority,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetSpecialty': targetSpecialty.toString().split('.').last,
      'category': category,
      'features': features,
      'priority': priority,
      'icon': icon,
      'color': color,
    };
  }

  factory SpecialtyRecommendation.fromJson(Map<String, dynamic> json) {
    return SpecialtyRecommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetSpecialty: SpecialtyType.values.firstWhere(
          (e) => e.toString().split('.').last == json['targetSpecialty'] as String),
      category: json['category'] as String,
      features: List<String>.from(json['features'] as List),
      priority: json['priority'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}

class SpecialtyWorkflow {
  final String id;
  final String title;
  final String description;
  final SpecialtyType targetSpecialty;
  final List<String> steps;
  final String category;
  final bool isAutomated;
  final String? estimatedTime;

  SpecialtyWorkflow({
    required this.id,
    required this.title,
    required this.description,
    required this.targetSpecialty,
    required this.steps,
    required this.category,
    this.isAutomated = false,
    this.estimatedTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetSpecialty': targetSpecialty.toString().split('.').last,
      'steps': steps,
      'category': category,
      'isAutomated': isAutomated,
      'estimatedTime': estimatedTime,
    };
  }

  factory SpecialtyWorkflow.fromJson(Map<String, dynamic> json) {
    return SpecialtyWorkflow(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetSpecialty: SpecialtyType.values.firstWhere(
          (e) => e.toString().split('.').last == json['targetSpecialty'] as String),
      steps: List<String>.from(json['steps'] as List),
      category: json['category'] as String,
      isAutomated: json['isAutomated'] as bool,
      estimatedTime: json['estimatedTime'] as String?,
    );
  }
}

class SpecialtyTool {
  final String id;
  final String name;
  final String description;
  final SpecialtyType targetSpecialty;
  final String category;
  final String? url;
  final bool isIntegrated;
  final String? icon;

  SpecialtyTool({
    required this.id,
    required this.name,
    required this.description,
    required this.targetSpecialty,
    required this.category,
    this.url,
    this.isIntegrated = false,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetSpecialty': targetSpecialty.toString().split('.').last,
      'category': category,
      'url': url,
      'isIntegrated': isIntegrated,
      'icon': icon,
    };
  }

  factory SpecialtyTool.fromJson(Map<String, dynamic> json) {
    return SpecialtyTool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      targetSpecialty: SpecialtyType.values.firstWhere(
          (e) => e.toString().split('.').last == json['targetSpecialty'] as String),
      category: json['category'] as String,
      url: json['url'] as String?,
      isIntegrated: json['isIntegrated'] as bool,
      icon: json['icon'] as String?,
    );
  }
}
