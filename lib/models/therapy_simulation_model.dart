import 'package:flutter/material.dart';

enum ScenarioDifficulty { beginner, intermediate, advanced }
enum MessageSender { therapist, client }

class SimulationScenario {
  final String id;
  final String title;
  final String description;
  final ScenarioDifficulty difficulty;
  final String category;
  final ClientProfile clientProfile;
  final String therapeuticApproach;
  final int estimatedDuration;
  final List<String> tags;

  SimulationScenario({
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

  factory SimulationScenario.fromJson(Map<String, dynamic> json) {
    return SimulationScenario(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      difficulty: ScenarioDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      category: json['category'],
      clientProfile: ClientProfile.fromJson(json['clientProfile']),
      therapeuticApproach: json['therapeuticApproach'],
      estimatedDuration: json['estimatedDuration'],
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty.toString().split('.').last,
      'category': category,
      'clientProfile': clientProfile.toJson(),
      'therapeuticApproach': therapeuticApproach,
      'estimatedDuration': estimatedDuration,
      'tags': tags,
    };
  }
}

class ClientProfile {
  final String name;
  final int age;
  final String gender;
  final String presentingProblem;
  final String background;
  final List<String> symptoms;
  final String goals;

  ClientProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.presentingProblem,
    required this.background,
    required this.symptoms,
    required this.goals,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      presentingProblem: json['presentingProblem'],
      background: json['background'],
      symptoms: List<String>.from(json['symptoms']),
      goals: json['goals'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'presentingProblem': presentingProblem,
      'background': background,
      'symptoms': symptoms,
      'goals': goals,
    };
  }
}

class SessionMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;

  SessionMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    return SessionMessage(
      id: json['id'],
      sender: MessageSender.values.firstWhere(
        (e) => e.toString().split('.').last == json['sender'],
      ),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toString().split('.').last,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SimulationResult {
  final String scenarioId;
  final DateTime startTime;
  final DateTime endTime;
  final List<SessionMessage> messages;
  final String sessionNotes;
  final SimulationScore score;

  SimulationResult({
    required this.scenarioId,
    required this.startTime,
    required this.endTime,
    required this.messages,
    required this.sessionNotes,
    required this.score,
  });

  Duration get duration => endTime.difference(startTime);

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      scenarioId: json['scenarioId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      messages: (json['messages'] as List)
          .map((m) => SessionMessage.fromJson(m))
          .toList(),
      sessionNotes: json['sessionNotes'],
      score: SimulationScore.fromJson(json['score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scenarioId': scenarioId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'sessionNotes': sessionNotes,
      'score': score.toJson(),
    };
  }
}

class SimulationScore {
  final int empathyScore;
  final int questioningScore;
  final int activeListeningScore;
  final int professionalLanguageScore;
  final int totalScore;

  SimulationScore({
    required this.empathyScore,
    required this.questioningScore,
    required this.activeListeningScore,
    required this.professionalLanguageScore,
    required this.totalScore,
  });

  factory SimulationScore.fromJson(Map<String, dynamic> json) {
    return SimulationScore(
      empathyScore: json['empathyScore'],
      questioningScore: json['questioningScore'],
      activeListeningScore: json['activeListeningScore'],
      professionalLanguageScore: json['professionalLanguageScore'],
      totalScore: json['totalScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empathyScore': empathyScore,
      'questioningScore': questioningScore,
      'activeListeningScore': activeListeningScore,
      'professionalLanguageScore': professionalLanguageScore,
      'totalScore': totalScore,
    };
  }
}
