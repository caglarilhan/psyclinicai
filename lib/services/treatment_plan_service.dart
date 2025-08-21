import 'package:flutter/foundation.dart';
import '../models/treatment_plan_models.dart';

class TreatmentPlanService extends ChangeNotifier {
  static final TreatmentPlanService _instance = TreatmentPlanService._internal();
  factory TreatmentPlanService() => _instance;
  TreatmentPlanService._internal();

  final Map<String, TreatmentPlan> _plansByClient = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    notifyListeners();
  }

  TreatmentPlan getOrCreatePlan({
    required String clientId,
    required String clinicianId,
  }) {
    if (_plansByClient.containsKey(clientId)) return _plansByClient[clientId]!;
    final plan = TreatmentPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      clinicianId: clinicianId,
      goals: [],
      createdAt: DateTime.now(),
    );
    _plansByClient[clientId] = plan;
    notifyListeners();
    return plan;
  }

  void addGoal(String clientId, SmartGoal goal) {
    final plan = _plansByClient[clientId];
    if (plan == null) return;
    plan.goals.add(goal);
    notifyListeners();
  }

  void toggleTask(String clientId, String goalId, String taskId, bool done) {
    final plan = _plansByClient[clientId];
    if (plan == null) return;
    for (final goal in plan.goals) {
      if (goal.id == goalId) {
        for (final task in goal.tasks) {
          if (task.id == taskId) {
            final idx = goal.tasks.indexOf(task);
            goal.tasks[idx] = TreatmentTask(id: task.id, title: task.title, notes: task.notes, done: done);
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  TreatmentPlan? getPlan(String clientId) => _plansByClient[clientId];
}
