import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treatment_plan_models.dart';
import 'database_service.dart';

class TreatmentPlanService {
  static final TreatmentPlanService _instance = TreatmentPlanService._internal();
  factory TreatmentPlanService() => _instance;
  TreatmentPlanService._internal();

  final DatabaseService _databaseService = DatabaseService();
  List<TreatmentPlan> _treatmentPlans = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadTreatmentPlans();
  }

  // Load treatment plans from database
  Future<void> _loadTreatmentPlans() async {
    try {
      // TODO: Implement database loading
      _treatmentPlans = [];
    } catch (e) {
      print('Error loading treatment plans: $e');
      _treatmentPlans = [];
    }
  }

  // Save treatment plan to database
  Future<void> _saveTreatmentPlan(TreatmentPlan plan) async {
    try {
      // TODO: Implement database saving
      _treatmentPlans.add(plan);
    } catch (e) {
      print('Error saving treatment plan: $e');
    }
  }

  // Get all treatment plans
  List<TreatmentPlan> getAllTreatmentPlans() {
    return List.unmodifiable(_treatmentPlans);
  }

  // Get treatment plans by client
  List<TreatmentPlan> getTreatmentPlansByClient(String clientId) {
    return _treatmentPlans.where((plan) => plan.clientId == clientId).toList();
  }

  // Get treatment plans by therapist
  List<TreatmentPlan> getTreatmentPlansByTherapist(String therapistId) {
    return _treatmentPlans.where((plan) => plan.therapistId == therapistId).toList();
  }

  // Get treatment plan by ID
  TreatmentPlan? getTreatmentPlanById(String id) {
    try {
      return _treatmentPlans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new treatment plan
  Future<TreatmentPlan> createTreatmentPlan(TreatmentPlan plan) async {
    await _saveTreatmentPlan(plan);
    return plan;
  }

  // Update treatment plan
  Future<bool> updateTreatmentPlan(TreatmentPlan updatedPlan) async {
    try {
      final index = _treatmentPlans.indexWhere((plan) => plan.id == updatedPlan.id);
      if (index == -1) {
        return false;
      }

      _treatmentPlans[index] = updatedPlan;
      await _saveTreatmentPlan(updatedPlan);
      return true;
    } catch (e) {
      print('Error updating treatment plan: $e');
      return false;
    }
  }

  // Delete treatment plan
  Future<bool> deleteTreatmentPlan(String id) async {
    try {
      final index = _treatmentPlans.indexWhere((plan) => plan.id == id);
      if (index == -1) {
        return false;
      }

      _treatmentPlans.removeAt(index);
      return true;
    } catch (e) {
      print('Error deleting treatment plan: $e');
      return false;
    }
  }

  // Add progress to treatment plan
  Future<bool> addProgress(String planId, TreatmentProgress progress) async {
    try {
      final plan = getTreatmentPlanById(planId);
      if (plan == null) return false;

      final updatedPlan = TreatmentPlan(
        id: plan.id,
        clientId: plan.clientId,
        therapistId: plan.therapistId,
        title: plan.title,
        description: plan.description,
        type: plan.type,
        modality: plan.modality,
        startDate: plan.startDate,
        endDate: plan.endDate,
        estimatedSessions: plan.estimatedSessions,
        completedSessions: plan.completedSessions + 1,
        status: plan.status,
        goals: plan.goals,
        interventions: plan.interventions,
        progress: [...plan.progress, progress],
        notes: plan.notes,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
      );

      return await updateTreatmentPlan(updatedPlan);
    } catch (e) {
      print('Error adding progress: $e');
      return false;
    }
  }

  // Update treatment goal
  Future<bool> updateGoal(String planId, TreatmentGoal updatedGoal) async {
    try {
      final plan = getTreatmentPlanById(planId);
      if (plan == null) return false;

      final updatedGoals = plan.goals.map((goal) {
        return goal.id == updatedGoal.id ? updatedGoal : goal;
      }).toList();

      final updatedPlan = TreatmentPlan(
        id: plan.id,
        clientId: plan.clientId,
        therapistId: plan.therapistId,
        title: plan.title,
        description: plan.description,
        type: plan.type,
        modality: plan.modality,
        startDate: plan.startDate,
        endDate: plan.endDate,
        estimatedSessions: plan.estimatedSessions,
        completedSessions: plan.completedSessions,
        status: plan.status,
        goals: updatedGoals,
        interventions: plan.interventions,
        progress: plan.progress,
        notes: plan.notes,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
      );

      return await updateTreatmentPlan(updatedPlan);
    } catch (e) {
      print('Error updating goal: $e');
      return false;
    }
  }

  // Complete intervention
  Future<bool> completeIntervention(String planId, String interventionId, String notes) async {
    try {
      final plan = getTreatmentPlanById(planId);
      if (plan == null) return false;

      final updatedInterventions = plan.interventions.map((intervention) {
        if (intervention.id == interventionId) {
          return TreatmentIntervention(
            id: intervention.id,
            title: intervention.title,
            description: intervention.description,
            type: intervention.type,
            category: intervention.category,
            scheduledDate: intervention.scheduledDate,
            isCompleted: true,
            completedDate: DateTime.now(),
            notes: notes,
            outcomes: intervention.outcomes,
          );
        }
        return intervention;
      }).toList();

      final updatedPlan = TreatmentPlan(
        id: plan.id,
        clientId: plan.clientId,
        therapistId: plan.therapistId,
        title: plan.title,
        description: plan.description,
        type: plan.type,
        modality: plan.modality,
        startDate: plan.startDate,
        endDate: plan.endDate,
        estimatedSessions: plan.estimatedSessions,
        completedSessions: plan.completedSessions,
        status: plan.status,
        goals: plan.goals,
        interventions: updatedInterventions,
        progress: plan.progress,
        notes: plan.notes,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
      );

      return await updateTreatmentPlan(updatedPlan);
    } catch (e) {
      print('Error completing intervention: $e');
      return false;
    }
  }

  // Get treatment plan statistics
  Map<String, dynamic> getTreatmentPlanStatistics() {
    final totalPlans = _treatmentPlans.length;
    final activePlans = _treatmentPlans.where((plan) => plan.isActive).length;
    final completedPlans = _treatmentPlans.where((plan) => plan.isCompleted).length;
    final pausedPlans = _treatmentPlans.where((plan) => plan.isPaused).length;

    final typeCounts = <String, int>{};
    for (final plan in _treatmentPlans) {
      final type = plan.type.name;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    final modalityCounts = <String, int>{};
    for (final plan in _treatmentPlans) {
      final modality = plan.modality.name;
      modalityCounts[modality] = (modalityCounts[modality] ?? 0) + 1;
    }

    return {
      'totalPlans': totalPlans,
      'activePlans': activePlans,
      'completedPlans': completedPlans,
      'pausedPlans': pausedPlans,
      'typeCounts': typeCounts,
      'modalityCounts': modalityCounts,
    };
  }

  // Get client treatment history
  List<Map<String, dynamic>> getClientTreatmentHistory(String clientId) {
    final clientPlans = getTreatmentPlansByClient(clientId);
    
    return clientPlans.map((plan) => {
      'id': plan.id,
      'title': plan.title,
      'type': plan.type.name,
      'status': plan.status.name,
      'startDate': plan.startDate.toIso8601String(),
      'endDate': plan.endDate?.toIso8601String(),
      'progressPercentage': plan.progressPercentage,
      'completedSessions': plan.completedSessions,
      'estimatedSessions': plan.estimatedSessions,
      'goals': plan.goals.map((goal) => {
        'title': goal.title,
        'isAchieved': goal.isAchieved,
        'priority': goal.priority.name,
      }).toList(),
    }).toList();
  }

  // Generate treatment plan report
  Map<String, dynamic> generateTreatmentPlanReport(String planId) {
    final plan = getTreatmentPlanById(planId);
    
    if (plan == null) {
      return {
        'error': 'Treatment plan not found',
      };
    }

    final report = {
      'planId': plan.id,
      'title': plan.title,
      'description': plan.description,
      'type': plan.type.name,
      'modality': plan.modality.name,
      'status': plan.status.name,
      'startDate': plan.startDate.toIso8601String(),
      'endDate': plan.endDate?.toIso8601String(),
      'progressPercentage': plan.progressPercentage,
      'completedSessions': plan.completedSessions,
      'estimatedSessions': plan.estimatedSessions,
      'goals': plan.goals.map((goal) => {
        'title': goal.title,
        'description': goal.description,
        'type': goal.type.name,
        'priority': goal.priority.name,
        'isAchieved': goal.isAchieved,
        'targetDate': goal.targetDate.toIso8601String(),
        'achievedDate': goal.achievedDate?.toIso8601String(),
        'notes': goal.notes,
      }).toList(),
      'interventions': plan.interventions.map((intervention) => {
        'title': intervention.title,
        'description': intervention.description,
        'type': intervention.type.name,
        'category': intervention.category.name,
        'isCompleted': intervention.isCompleted,
        'scheduledDate': intervention.scheduledDate.toIso8601String(),
        'completedDate': intervention.completedDate?.toIso8601String(),
        'notes': intervention.notes,
        'outcomes': intervention.outcomes,
      }).toList(),
      'progress': plan.progress.map((p) => {
        'date': p.date.toIso8601String(),
        'type': p.type.name,
        'description': p.description,
        'metrics': p.metrics,
        'notes': p.notes,
      }).toList(),
      'notes': plan.notes,
    };

    return report;
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_treatmentPlans.isNotEmpty) return;

    final demoPlans = [
      TreatmentPlanTemplates.createDepressionPlan(
        clientId: '1',
        therapistId: 'therapist_001',
      ),
      TreatmentPlanTemplates.createAnxietyPlan(
        clientId: '2',
        therapistId: 'therapist_001',
      ),
      TreatmentPlanTemplates.createTraumaPlan(
        clientId: '3',
        therapistId: 'therapist_001',
      ),
    ];

    for (final plan in demoPlans) {
      await createTreatmentPlan(plan);
    }

    print('✅ Demo treatment plans created: ${demoPlans.length}');
  }
}