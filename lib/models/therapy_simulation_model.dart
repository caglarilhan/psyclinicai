import 'package:flutter/material.dart';

enum ScenarioDifficulty { beginner, intermediate, advanced }

class ClientProfile {
  final String name;
  final int age;
  final String gender;
  final String presentingProblem;
  final String background;
  final List<String> symptoms;
  final String goals;

  const ClientProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.presentingProblem,
    required this.background,
    required this.symptoms,
    required this.goals,
  });
}

class SimulationScenario {
  final String id;
  final String title;
  final String description;
  final ScenarioDifficulty difficulty;
  final String category;
  final ClientProfile clientProfile;
  final String therapeuticApproach;
  final int estimatedDuration; // minutes
  final List<String> tags;

  const SimulationScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.clientProfile,
    required this.therapeuticApproach,
    required this.estimatedDuration,
    required this.tags,
  });
}

enum MessageSender { therapist, client }

class SessionMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;

  const SessionMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}
