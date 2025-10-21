import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class HomeworkAssignment {
  final String id;
  final String clientId;
  final String clinicianId;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int estimatedDuration;
  final String? customInstructions;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime assignedDate;
  final DateTime? completedDate;
  final String? notes;
  final HomeworkStatus status;

  HomeworkAssignment({
    String? id,
    required this.clientId,
    required this.clinicianId,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
    this.customInstructions,
    required this.dueDate,
    this.isCompleted = false,
    required this.assignedDate,
    this.completedDate,
    this.notes,
    this.status = HomeworkStatus.pending,
  }) : id = id ?? const Uuid().v4();

  HomeworkAssignment copyWith({
    String? id,
    String? clientId,
    String? clinicianId,
    String? title,
    String? description,
    String? category,
    String? difficulty,
    int? estimatedDuration,
    String? customInstructions,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? assignedDate,
    DateTime? completedDate,
    String? notes,
    HomeworkStatus? status,
  }) {
    return HomeworkAssignment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clinicianId: clinicianId ?? this.clinicianId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      customInstructions: customInstructions ?? this.customInstructions,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedDate: assignedDate ?? this.assignedDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clinicianId': clinicianId,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'customInstructions': customInstructions,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'assignedDate': assignedDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'notes': notes,
      'status': status.name,
    };
  }

  factory HomeworkAssignment.fromJson(Map<String, dynamic> json) {
    return HomeworkAssignment(
      id: json['id'],
      clientId: json['clientId'],
      clinicianId: json['clinicianId'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      difficulty: json['difficulty'],
      estimatedDuration: json['estimatedDuration'],
      customInstructions: json['customInstructions'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      assignedDate: DateTime.parse(json['assignedDate']),
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      notes: json['notes'],
      status: HomeworkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HomeworkStatus.pending,
      ),
    );
  }
}

enum HomeworkStatus {
  pending,
  completed,
  overdue,
  cancelled,
}
