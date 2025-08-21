class SmartGoal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? targetDate;
  final GoalStatus status;
  final List<TreatmentTask> tasks;

  SmartGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.targetDate,
    required this.status,
    required this.tasks,
  });
}

enum GoalStatus { active, onHold, completed }

class TreatmentTask {
  final String id;
  final String title;
  final String? notes;
  final bool done;

  TreatmentTask({
    required this.id,
    required this.title,
    this.notes,
    this.done = false,
  });
}

class TreatmentPlan {
  final String id;
  final String clientId;
  final String clinicianId;
  final List<SmartGoal> goals;
  final DateTime createdAt;

  TreatmentPlan({
    required this.id,
    required this.clientId,
    required this.clinicianId,
    required this.goals,
    required this.createdAt,
  });
}
