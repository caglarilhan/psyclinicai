import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/therapy_session_models.dart';

class TherapySessionService {
  static final TherapySessionService _instance = TherapySessionService._internal();
  factory TherapySessionService() => _instance;
  TherapySessionService._internal();

  final List<TherapySession> _sessions = [];
  final List<SessionNote> _notes = [];
  final List<SessionGoal> _goals = [];
  final List<SessionIntervention> _interventions = [];
  final List<SessionHomework> _homework = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadSessions();
    await _loadNotes();
    await _loadGoals();
    await _loadInterventions();
    await _loadHomework();
  }

  // Load sessions from storage
  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('therapy_sessions') ?? [];
      _sessions.clear();
      
      for (final sessionJson in sessionsJson) {
        final session = TherapySession.fromJson(jsonDecode(sessionJson));
        _sessions.add(session);
      }
    } catch (e) {
      print('Error loading therapy sessions: $e');
      _sessions.clear();
    }
  }

  // Save sessions to storage
  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _sessions
          .map((session) => jsonEncode(session.toJson()))
          .toList();
      await prefs.setStringList('therapy_sessions', sessionsJson);
    } catch (e) {
      print('Error saving therapy sessions: $e');
    }
  }

  // Load notes from storage
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList('session_notes') ?? [];
      _notes.clear();
      
      for (final noteJson in notesJson) {
        final note = SessionNote.fromJson(jsonDecode(noteJson));
        _notes.add(note);
      }
    } catch (e) {
      print('Error loading session notes: $e');
      _notes.clear();
    }
  }

  // Save notes to storage
  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = _notes
          .map((note) => jsonEncode(note.toJson()))
          .toList();
      await prefs.setStringList('session_notes', notesJson);
    } catch (e) {
      print('Error saving session notes: $e');
    }
  }

  // Load goals from storage
  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getStringList('session_goals') ?? [];
      _goals.clear();
      
      for (final goalJson in goalsJson) {
        final goal = SessionGoal.fromJson(jsonDecode(goalJson));
        _goals.add(goal);
      }
    } catch (e) {
      print('Error loading session goals: $e');
      _goals.clear();
    }
  }

  // Save goals to storage
  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = _goals
          .map((goal) => jsonEncode(goal.toJson()))
          .toList();
      await prefs.setStringList('session_goals', goalsJson);
    } catch (e) {
      print('Error saving session goals: $e');
    }
  }

  // Load interventions from storage
  Future<void> _loadInterventions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interventionsJson = prefs.getStringList('session_interventions') ?? [];
      _interventions.clear();
      
      for (final interventionJson in interventionsJson) {
        final intervention = SessionIntervention.fromJson(jsonDecode(interventionJson));
        _interventions.add(intervention);
      }
    } catch (e) {
      print('Error loading session interventions: $e');
      _interventions.clear();
    }
  }

  // Save interventions to storage
  Future<void> _saveInterventions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interventionsJson = _interventions
          .map((intervention) => jsonEncode(intervention.toJson()))
          .toList();
      await prefs.setStringList('session_interventions', interventionsJson);
    } catch (e) {
      print('Error saving session interventions: $e');
    }
  }

  // Load homework from storage
  Future<void> _loadHomework() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final homeworkJson = prefs.getStringList('session_homework') ?? [];
      _homework.clear();
      
      for (final homeworkItemJson in homeworkJson) {
        final homeworkItem = SessionHomework.fromJson(jsonDecode(homeworkItemJson));
        _homework.add(homeworkItem);
      }
    } catch (e) {
      print('Error loading session homework: $e');
      _homework.clear();
    }
  }

  // Save homework to storage
  Future<void> _saveHomework() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final homeworkJson = _homework
          .map((homeworkItem) => jsonEncode(homeworkItem.toJson()))
          .toList();
      await prefs.setStringList('session_homework', homeworkJson);
    } catch (e) {
      print('Error saving session homework: $e');
    }
  }

  // Schedule new therapy session
  Future<TherapySession> scheduleSession({
    required String patientId,
    required String therapistId,
    required DateTime scheduledAt,
    required Duration duration,
    required SessionType type,
    String? notes,
    String? goals,
    String? location,
    bool isTelehealth = false,
    String? telehealthLink,
    List<String>? attendees,
  }) async {
    final session = TherapySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      therapistId: therapistId,
      scheduledAt: scheduledAt,
      duration: duration,
      type: type,
      notes: notes,
      goals: goals,
      location: location,
      isTelehealth: isTelehealth,
      telehealthLink: telehealthLink,
      attendees: attendees ?? [],
      createdAt: DateTime.now(),
    );

    _sessions.add(session);
    await _saveSessions();

    return session;
  }

  // Start therapy session
  Future<bool> startSession(String sessionId) async {
    try {
      final index = _sessions.indexWhere((session) => session.id == sessionId);
      if (index == -1) return false;

      final session = _sessions[index];
      final updatedSession = TherapySession(
        id: session.id,
        patientId: session.patientId,
        therapistId: session.therapistId,
        scheduledAt: session.scheduledAt,
        duration: session.duration,
        type: session.type,
        status: SessionStatus.inProgress,
        notes: session.notes,
        goals: session.goals,
        interventions: session.interventions,
        homework: session.homework,
        nextSessionPlan: session.nextSessionPlan,
        startedAt: DateTime.now(),
        endedAt: session.endedAt,
        sessionData: session.sessionData,
        attendees: session.attendees,
        location: session.location,
        isTelehealth: session.isTelehealth,
        telehealthLink: session.telehealthLink,
        createdAt: session.createdAt,
        updatedAt: DateTime.now(),
      );

      _sessions[index] = updatedSession;
      await _saveSessions();
      return true;
    } catch (e) {
      print('Error starting session: $e');
      return false;
    }
  }

  // End therapy session
  Future<bool> endSession({
    required String sessionId,
    String? notes,
    String? interventions,
    String? homework,
    String? nextSessionPlan,
  }) async {
    try {
      final index = _sessions.indexWhere((session) => session.id == sessionId);
      if (index == -1) return false;

      final session = _sessions[index];
      final updatedSession = TherapySession(
        id: session.id,
        patientId: session.patientId,
        therapistId: session.therapistId,
        scheduledAt: session.scheduledAt,
        duration: session.duration,
        type: session.type,
        status: SessionStatus.completed,
        notes: notes ?? session.notes,
        goals: session.goals,
        interventions: interventions ?? session.interventions,
        homework: homework ?? session.homework,
        nextSessionPlan: nextSessionPlan ?? session.nextSessionPlan,
        startedAt: session.startedAt,
        endedAt: DateTime.now(),
        sessionData: session.sessionData,
        attendees: session.attendees,
        location: session.location,
        isTelehealth: session.isTelehealth,
        telehealthLink: session.telehealthLink,
        createdAt: session.createdAt,
        updatedAt: DateTime.now(),
      );

      _sessions[index] = updatedSession;
      await _saveSessions();
      return true;
    } catch (e) {
      print('Error ending session: $e');
      return false;
    }
  }

  // Cancel session
  Future<bool> cancelSession(String sessionId, {String? reason}) async {
    try {
      final index = _sessions.indexWhere((session) => session.id == sessionId);
      if (index == -1) return false;

      final session = _sessions[index];
      final updatedSession = TherapySession(
        id: session.id,
        patientId: session.patientId,
        therapistId: session.therapistId,
        scheduledAt: session.scheduledAt,
        duration: session.duration,
        type: session.type,
        status: SessionStatus.cancelled,
        notes: reason ?? session.notes,
        goals: session.goals,
        interventions: session.interventions,
        homework: session.homework,
        nextSessionPlan: session.nextSessionPlan,
        startedAt: session.startedAt,
        endedAt: session.endedAt,
        sessionData: session.sessionData,
        attendees: session.attendees,
        location: session.location,
        isTelehealth: session.isTelehealth,
        telehealthLink: session.telehealthLink,
        createdAt: session.createdAt,
        updatedAt: DateTime.now(),
      );

      _sessions[index] = updatedSession;
      await _saveSessions();
      return true;
    } catch (e) {
      print('Error cancelling session: $e');
      return false;
    }
  }

  // Get sessions for patient
  List<TherapySession> getSessionsForPatient(String patientId) {
    return _sessions
        .where((session) => session.patientId == patientId)
        .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  // Get sessions for therapist
  List<TherapySession> getSessionsForTherapist(String therapistId) {
    return _sessions
        .where((session) => session.therapistId == therapistId)
        .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  // Get upcoming sessions
  List<TherapySession> getUpcomingSessions({int days = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    return _sessions
        .where((session) => 
            session.status == SessionStatus.scheduled &&
            session.scheduledAt.isAfter(DateTime.now()) &&
            session.scheduledAt.isBefore(cutoffDate))
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Get overdue sessions
  List<TherapySession> getOverdueSessions() {
    return _sessions
        .where((session) => session.isOverdue)
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Add session note
  Future<SessionNote> addSessionNote({
    required String sessionId,
    required String therapistId,
    required String content,
    required NoteType type,
    List<String>? tags,
    bool isConfidential = false,
    String? followUpAction,
  }) async {
    final note = SessionNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      therapistId: therapistId,
      createdAt: DateTime.now(),
      content: content,
      type: type,
      tags: tags ?? [],
      isConfidential: isConfidential,
      followUpAction: followUpAction,
    );

    _notes.add(note);
    await _saveNotes();

    return note;
  }

  // Get notes for session
  List<SessionNote> getNotesForSession(String sessionId) {
    return _notes
        .where((note) => note.sessionId == sessionId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Add session goal
  Future<SessionGoal> addSessionGoal({
    required String sessionId,
    required String description,
    String? notes,
  }) async {
    final goal = SessionGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      description: description,
      createdAt: DateTime.now(),
      notes: notes,
    );

    _goals.add(goal);
    await _saveGoals();

    return goal;
  }

  // Update goal status
  Future<bool> updateGoalStatus(String goalId, GoalStatus status, {String? notes}) async {
    try {
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index == -1) return false;

      final goal = _goals[index];
      final updatedGoal = SessionGoal(
        id: goal.id,
        sessionId: goal.sessionId,
        description: goal.description,
        status: status,
        createdAt: goal.createdAt,
        achievedAt: status == GoalStatus.achieved ? DateTime.now() : goal.achievedAt,
        notes: notes ?? goal.notes,
      );

      _goals[index] = updatedGoal;
      await _saveGoals();
      return true;
    } catch (e) {
      print('Error updating goal status: $e');
      return false;
    }
  }

  // Get goals for session
  List<SessionGoal> getGoalsForSession(String sessionId) {
    return _goals
        .where((goal) => goal.sessionId == sessionId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Add session intervention
  Future<SessionIntervention> addSessionIntervention({
    required String sessionId,
    required String name,
    required InterventionType type,
    required String description,
    required Duration duration,
    String? outcome,
    String? notes,
  }) async {
    final intervention = SessionIntervention(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      name: name,
      type: type,
      description: description,
      duration: duration,
      outcome: outcome,
      notes: notes,
      timestamp: DateTime.now(),
    );

    _interventions.add(intervention);
    await _saveInterventions();

    return intervention;
  }

  // Get interventions for session
  List<SessionIntervention> getInterventionsForSession(String sessionId) {
    return _interventions
        .where((intervention) => intervention.sessionId == sessionId)
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Assign homework
  Future<SessionHomework> assignHomework({
    required String sessionId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    final homework = SessionHomework(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      title: title,
      description: description,
      assignedAt: DateTime.now(),
      dueDate: dueDate,
    );

    _homework.add(homework);
    await _saveHomework();

    return homework;
  }

  // Complete homework
  Future<bool> completeHomework(String homeworkId, String completionNotes) async {
    try {
      final index = _homework.indexWhere((hw) => hw.id == homeworkId);
      if (index == -1) return false;

      final homework = _homework[index];
      final updatedHomework = SessionHomework(
        id: homework.id,
        sessionId: homework.sessionId,
        title: homework.title,
        description: homework.description,
        assignedAt: homework.assignedAt,
        dueDate: homework.dueDate,
        status: HomeworkStatus.completed,
        completionNotes: completionNotes,
        completedAt: DateTime.now(),
        feedback: homework.feedback,
      );

      _homework[index] = updatedHomework;
      await _saveHomework();
      return true;
    } catch (e) {
      print('Error completing homework: $e');
      return false;
    }
  }

  // Get homework for session
  List<SessionHomework> getHomeworkForSession(String sessionId) {
    return _homework
        .where((hw) => hw.sessionId == sessionId)
        .toList()
        ..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
  }

  // Get overdue homework
  List<SessionHomework> getOverdueHomework() {
    return _homework
        .where((hw) => hw.isOverdue)
        .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get session statistics
  Map<String, dynamic> getSessionStatistics() {
    final totalSessions = _sessions.length;
    final completedSessions = _sessions
        .where((session) => session.status == SessionStatus.completed)
        .length;
    final cancelledSessions = _sessions
        .where((session) => session.status == SessionStatus.cancelled)
        .length;
    final noShowSessions = _sessions
        .where((session) => session.status == SessionStatus.noShow)
        .length;

    final totalNotes = _notes.length;
    final confidentialNotes = _notes
        .where((note) => note.isConfidential)
        .length;

    final totalGoals = _goals.length;
    final achievedGoals = _goals
        .where((goal) => goal.status == GoalStatus.achieved)
        .length;

    final totalHomework = _homework.length;
    final completedHomework = _homework
        .where((hw) => hw.status == HomeworkStatus.completed)
        .length;
    final overdueHomework = _homework
        .where((hw) => hw.isOverdue)
        .length;

    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'cancelledSessions': cancelledSessions,
      'noShowSessions': noShowSessions,
      'totalNotes': totalNotes,
      'confidentialNotes': confidentialNotes,
      'totalGoals': totalGoals,
      'achievedGoals': achievedGoals,
      'totalHomework': totalHomework,
      'completedHomework': completedHomework,
      'overdueHomework': overdueHomework,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_sessions.isNotEmpty) return;

    final demoSessions = [
      TherapySession(
        id: 'session_001',
        patientId: '1',
        therapistId: 'therapist_001',
        scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
        duration: const Duration(minutes: 50),
        type: SessionType.individual,
        status: SessionStatus.completed,
        notes: 'Hasta depresif belirtiler hakkında konuştu. CBT teknikleri uygulandı.',
        goals: 'Anksiyete yönetimi, düşünce kayıtları',
        interventions: 'Düşünce kayıtları, nefes egzersizleri',
        homework: 'Günlük düşünce kayıtları tutmak',
        nextSessionPlan: 'Anksiyete teknikleri üzerinde çalışmaya devam',
        startedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        endedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TherapySession(
        id: 'session_002',
        patientId: '1',
        therapistId: 'therapist_001',
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
        duration: const Duration(minutes: 50),
        type: SessionType.individual,
        status: SessionStatus.scheduled,
        goals: 'Anksiyete teknikleri, gevşeme egzersizleri',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    for (final session in demoSessions) {
      _sessions.add(session);
    }

    await _saveSessions();

    // Add demo notes
    final demoNotes = [
      SessionNote(
        id: 'note_001',
        sessionId: 'session_001',
        therapistId: 'therapist_001',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        content: 'Hasta bugün daha iyi görünüyordu. Ödevlerini yapmış.',
        type: NoteType.progress,
        tags: ['progress', 'homework'],
      ),
    ];

    for (final note in demoNotes) {
      _notes.add(note);
    }

    await _saveNotes();

    print('✅ Demo therapy sessions created: ${demoSessions.length}');
    print('✅ Demo session notes created: ${demoNotes.length}');
  }
}
