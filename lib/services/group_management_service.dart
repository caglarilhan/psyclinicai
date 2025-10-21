import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/group_management_models.dart';

class GroupManagementService {
  static final GroupManagementService _instance = GroupManagementService._internal();
  factory GroupManagementService() => _instance;
  GroupManagementService._internal();

  final List<GroupSession> _sessions = [];
  final List<GroupParticipant> _participants = [];
  final List<GroupActivity> _activities = [];
  final List<GroupFeedback> _feedbacks = [];
  final List<GroupTemplate> _templates = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadSessions();
    await _loadParticipants();
    await _loadActivities();
    await _loadFeedbacks();
    await _loadTemplates();
  }

  // Load sessions from storage
  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('group_sessions') ?? [];
      _sessions.clear();
      
      for (final sessionJson in sessionsJson) {
        final session = GroupSession.fromJson(jsonDecode(sessionJson));
        _sessions.add(session);
      }
    } catch (e) {
      print('Error loading group sessions: $e');
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
      await prefs.setStringList('group_sessions', sessionsJson);
    } catch (e) {
      print('Error saving group sessions: $e');
    }
  }

  // Load participants from storage
  Future<void> _loadParticipants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final participantsJson = prefs.getStringList('group_participants') ?? [];
      _participants.clear();
      
      for (final participantJson in participantsJson) {
        final participant = GroupParticipant.fromJson(jsonDecode(participantJson));
        _participants.add(participant);
      }
    } catch (e) {
      print('Error loading group participants: $e');
      _participants.clear();
    }
  }

  // Save participants to storage
  Future<void> _saveParticipants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final participantsJson = _participants
          .map((participant) => jsonEncode(participant.toJson()))
          .toList();
      await prefs.setStringList('group_participants', participantsJson);
    } catch (e) {
      print('Error saving group participants: $e');
    }
  }

  // Load activities from storage
  Future<void> _loadActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = prefs.getStringList('group_activities') ?? [];
      _activities.clear();
      
      for (final activityJson in activitiesJson) {
        final activity = GroupActivity.fromJson(jsonDecode(activityJson));
        _activities.add(activity);
      }
    } catch (e) {
      print('Error loading group activities: $e');
      _activities.clear();
    }
  }

  // Save activities to storage
  Future<void> _saveActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = _activities
          .map((activity) => jsonEncode(activity.toJson()))
          .toList();
      await prefs.setStringList('group_activities', activitiesJson);
    } catch (e) {
      print('Error saving group activities: $e');
    }
  }

  // Load feedbacks from storage
  Future<void> _loadFeedbacks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbacksJson = prefs.getStringList('group_feedbacks') ?? [];
      _feedbacks.clear();
      
      for (final feedbackJson in feedbacksJson) {
        final feedback = GroupFeedback.fromJson(jsonDecode(feedbackJson));
        _feedbacks.add(feedback);
      }
    } catch (e) {
      print('Error loading group feedbacks: $e');
      _feedbacks.clear();
    }
  }

  // Save feedbacks to storage
  Future<void> _saveFeedbacks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbacksJson = _feedbacks
          .map((feedback) => jsonEncode(feedback.toJson()))
          .toList();
      await prefs.setStringList('group_feedbacks', feedbacksJson);
    } catch (e) {
      print('Error saving group feedbacks: $e');
    }
  }

  // Load templates from storage
  Future<void> _loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList('group_templates') ?? [];
      _templates.clear();
      
      for (final templateJson in templatesJson) {
        final template = GroupTemplate.fromJson(jsonDecode(templateJson));
        _templates.add(template);
      }
    } catch (e) {
      print('Error loading group templates: $e');
      _templates.clear();
    }
  }

  // Save templates to storage
  Future<void> _saveTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = _templates
          .map((template) => jsonEncode(template.toJson()))
          .toList();
      await prefs.setStringList('group_templates', templatesJson);
    } catch (e) {
      print('Error saving group templates: $e');
    }
  }

  // Create group session
  Future<GroupSession> createGroupSession({
    required String title,
    required String description,
    required GroupType type,
    required String facilitatorId,
    required List<String> participantIds,
    required DateTime scheduledAt,
    required Duration duration,
    required String location,
    String? notes,
    List<String>? objectives,
    List<String>? materials,
  }) async {
    final session = GroupSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      facilitatorId: facilitatorId,
      participantIds: participantIds,
      scheduledAt: scheduledAt,
      duration: duration,
      location: location,
      notes: notes,
      objectives: objectives ?? [],
      materials: materials ?? [],
    );

    _sessions.add(session);
    await _saveSessions();

    // Add participants
    for (final participantId in participantIds) {
      await addParticipant(
        groupId: session.id,
        patientId: participantId,
        role: ParticipantRole.member,
      );
    }

    return session;
  }

  // Add participant to group
  Future<GroupParticipant> addParticipant({
    required String groupId,
    required String patientId,
    ParticipantRole role = ParticipantRole.member,
    String? notes,
  }) async {
    final participant = GroupParticipant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: groupId,
      patientId: patientId,
      role: role,
      joinedAt: DateTime.now(),
      notes: notes,
    );

    _participants.add(participant);
    await _saveParticipants();

    return participant;
  }

  // Remove participant from group
  Future<bool> removeParticipant(String participantId) async {
    try {
      final index = _participants.indexWhere((p) => p.id == participantId);
      if (index == -1) return false;

      final participant = _participants[index];
      final updatedParticipant = GroupParticipant(
        id: participant.id,
        groupId: participant.groupId,
        patientId: participant.patientId,
        role: participant.role,
        joinedAt: participant.joinedAt,
        leftAt: DateTime.now(),
        status: ParticipantStatus.removed,
        notes: participant.notes,
        metadata: participant.metadata,
      );

      _participants[index] = updatedParticipant;
      await _saveParticipants();
      return true;
    } catch (e) {
      print('Error removing participant: $e');
      return false;
    }
  }

  // Start group session
  Future<bool> startGroupSession(String sessionId) async {
    try {
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index == -1) return false;

      final session = _sessions[index];
      final updatedSession = GroupSession(
        id: session.id,
        title: session.title,
        description: session.description,
        type: session.type,
        facilitatorId: session.facilitatorId,
        participantIds: session.participantIds,
        scheduledAt: session.scheduledAt,
        duration: session.duration,
        location: session.location,
        status: SessionStatus.active,
        startedAt: DateTime.now(),
        endedAt: session.endedAt,
        notes: session.notes,
        objectives: session.objectives,
        materials: session.materials,
        metadata: session.metadata,
      );

      _sessions[index] = updatedSession;
      await _saveSessions();
      return true;
    } catch (e) {
      print('Error starting group session: $e');
      return false;
    }
  }

  // End group session
  Future<bool> endGroupSession(String sessionId, String? notes) async {
    try {
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index == -1) return false;

      final session = _sessions[index];
      final updatedSession = GroupSession(
        id: session.id,
        title: session.title,
        description: session.description,
        type: session.type,
        facilitatorId: session.facilitatorId,
        participantIds: session.participantIds,
        scheduledAt: session.scheduledAt,
        duration: session.duration,
        location: session.location,
        status: SessionStatus.completed,
        startedAt: session.startedAt,
        endedAt: DateTime.now(),
        notes: notes ?? session.notes,
        objectives: session.objectives,
        materials: session.materials,
        metadata: session.metadata,
      );

      _sessions[index] = updatedSession;
      await _saveSessions();
      return true;
    } catch (e) {
      print('Error ending group session: $e');
      return false;
    }
  }

  // Add group activity
  Future<GroupActivity> addGroupActivity({
    required String groupId,
    required String sessionId,
    required String title,
    required String description,
    required ActivityType type,
    required DateTime startTime,
    String? facilitatorId,
    List<String>? participantIds,
    String? notes,
  }) async {
    final activity = GroupActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: groupId,
      sessionId: sessionId,
      title: title,
      description: description,
      type: type,
      startTime: startTime,
      facilitatorId: facilitatorId,
      participantIds: participantIds ?? [],
      notes: notes,
    );

    _activities.add(activity);
    await _saveActivities();

    return activity;
  }

  // Start group activity
  Future<bool> startGroupActivity(String activityId) async {
    try {
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index == -1) return false;

      final activity = _activities[index];
      final updatedActivity = GroupActivity(
        id: activity.id,
        groupId: activity.groupId,
        sessionId: activity.sessionId,
        title: activity.title,
        description: activity.description,
        type: activity.type,
        startTime: activity.startTime,
        endTime: DateTime.now(),
        facilitatorId: activity.facilitatorId,
        participantIds: activity.participantIds,
        status: ActivityStatus.active,
        notes: activity.notes,
        results: activity.results,
        metadata: activity.metadata,
      );

      _activities[index] = updatedActivity;
      await _saveActivities();
      return true;
    } catch (e) {
      print('Error starting group activity: $e');
      return false;
    }
  }

  // Complete group activity
  Future<bool> completeGroupActivity({
    required String activityId,
    String? notes,
    Map<String, dynamic>? results,
  }) async {
    try {
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index == -1) return false;

      final activity = _activities[index];
      final updatedActivity = GroupActivity(
        id: activity.id,
        groupId: activity.groupId,
        sessionId: activity.sessionId,
        title: activity.title,
        description: activity.description,
        type: activity.type,
        startTime: activity.startTime,
        endTime: DateTime.now(),
        facilitatorId: activity.facilitatorId,
        participantIds: activity.participantIds,
        status: ActivityStatus.completed,
        notes: notes ?? activity.notes,
        results: results ?? activity.results,
        metadata: activity.metadata,
      );

      _activities[index] = updatedActivity;
      await _saveActivities();
      return true;
    } catch (e) {
      print('Error completing group activity: $e');
      return false;
    }
  }

  // Submit group feedback
  Future<GroupFeedback> submitGroupFeedback({
    required String groupId,
    required String sessionId,
    required String participantId,
    required FeedbackType type,
    required Map<String, dynamic> responses,
    String? facilitatorId,
    String? notes,
  }) async {
    final feedback = GroupFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: groupId,
      sessionId: sessionId,
      participantId: participantId,
      facilitatorId: facilitatorId,
      type: type,
      responses: responses,
      submittedAt: DateTime.now(),
      notes: notes,
    );

    _feedbacks.add(feedback);
    await _saveFeedbacks();

    return feedback;
  }

  // Create group template
  Future<GroupTemplate> createGroupTemplate({
    required String name,
    required String description,
    required GroupType type,
    required List<String> objectives,
    required List<String> materials,
    required Duration duration,
    required int maxParticipants,
    required String createdBy,
    bool isPublic = false,
    List<String>? sharedWith,
  }) async {
    final template = GroupTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      type: type,
      objectives: objectives,
      materials: materials,
      duration: duration,
      maxParticipants: maxParticipants,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      isPublic: isPublic,
      sharedWith: sharedWith ?? [],
    );

    _templates.add(template);
    await _saveTemplates();

    return template;
  }

  // Get sessions for facilitator
  List<GroupSession> getSessionsForFacilitator(String facilitatorId) {
    return _sessions
        .where((session) => session.facilitatorId == facilitatorId)
        .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  // Get sessions for participant
  List<GroupSession> getSessionsForParticipant(String participantId) {
    return _sessions
        .where((session) => session.participantIds.contains(participantId))
        .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  // Get active sessions
  List<GroupSession> getActiveSessions() {
    return _sessions
        .where((session) => session.isActive)
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Get overdue sessions
  List<GroupSession> getOverdueSessions() {
    return _sessions
        .where((session) => session.isOverdue)
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Get participants for group
  List<GroupParticipant> getParticipantsForGroup(String groupId) {
    return _participants
        .where((participant) => participant.groupId == groupId)
        .toList()
        ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
  }

  // Get active participants for group
  List<GroupParticipant> getActiveParticipantsForGroup(String groupId) {
    return _participants
        .where((participant) => 
            participant.groupId == groupId && 
            participant.isActive)
        .toList()
        ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
  }

  // Get activities for session
  List<GroupActivity> getActivitiesForSession(String sessionId) {
    return _activities
        .where((activity) => activity.sessionId == sessionId)
        .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get feedbacks for session
  List<GroupFeedback> getFeedbacksForSession(String sessionId) {
    return _feedbacks
        .where((feedback) => feedback.sessionId == sessionId)
        .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  // Get templates for user
  List<GroupTemplate> getTemplatesForUser(String userId) {
    return _templates
        .where((template) => template.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get templates by type
  List<GroupTemplate> getTemplatesByType(GroupType type, String userId) {
    return _templates
        .where((template) => 
            template.type == type && 
            template.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalSessions = _sessions.length;
    final activeSessions = _sessions
        .where((session) => session.isActive)
        .length;
    final completedSessions = _sessions
        .where((session) => session.isCompleted)
        .length;
    final overdueSessions = _sessions
        .where((session) => session.isOverdue)
        .length;

    final totalParticipants = _participants.length;
    final activeParticipants = _participants
        .where((participant) => participant.isActive)
        .length;

    final totalActivities = _activities.length;
    final completedActivities = _activities
        .where((activity) => activity.isCompleted)
        .length;

    final totalFeedbacks = _feedbacks.length;
    final totalTemplates = _templates.length;

    return {
      'totalSessions': totalSessions,
      'activeSessions': activeSessions,
      'completedSessions': completedSessions,
      'overdueSessions': overdueSessions,
      'totalParticipants': totalParticipants,
      'activeParticipants': activeParticipants,
      'totalActivities': totalActivities,
      'completedActivities': completedActivities,
      'totalFeedbacks': totalFeedbacks,
      'totalTemplates': totalTemplates,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_sessions.isNotEmpty) return;

    // Add demo sessions
    final demoSessions = [
      GroupSession(
        id: 'session_001',
        title: 'Depresyon Destek Grubu',
        description: 'Depresyon yaşayan hastalar için destek grubu',
        type: GroupType.support,
        facilitatorId: 'clinician_001',
        participantIds: ['1', '2', '3'],
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        duration: const Duration(minutes: 90),
        location: 'Klinik Odası 1',
        objectives: [
          'Hastaların birbirlerine destek olması',
          'Deneyim paylaşımı',
          'Başa çıkma stratejileri öğrenme',
        ],
        materials: [
          'Çalışma sayfaları',
          'Kalemler',
          'Flipchart',
        ],
      ),
      GroupSession(
        id: 'session_002',
        title: 'Anksiyete Yönetimi Atölyesi',
        description: 'Anksiyete yönetimi teknikleri öğrenme atölyesi',
        type: GroupType.psychoeducation,
        facilitatorId: 'clinician_001',
        participantIds: ['4', '5', '6'],
        scheduledAt: DateTime.now().add(const Duration(days: 3)),
        duration: const Duration(minutes: 120),
        location: 'Klinik Odası 2',
        objectives: [
          'Anksiyete belirtilerini tanıma',
          'Nefes egzersizleri öğrenme',
          'Gevşeme teknikleri uygulama',
        ],
        materials: [
          'Nefes egzersizi rehberi',
          'Gevşeme müziği',
          'Çalışma sayfaları',
        ],
      ),
    ];

    for (final session in demoSessions) {
      _sessions.add(session);
    }

    await _saveSessions();

    // Add demo participants
    final demoParticipants = [
      GroupParticipant(
        id: 'participant_001',
        groupId: 'session_001',
        patientId: '1',
        role: ParticipantRole.member,
        joinedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      GroupParticipant(
        id: 'participant_002',
        groupId: 'session_001',
        patientId: '2',
        role: ParticipantRole.member,
        joinedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      GroupParticipant(
        id: 'participant_003',
        groupId: 'session_001',
        patientId: '3',
        role: ParticipantRole.member,
        joinedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    for (final participant in demoParticipants) {
      _participants.add(participant);
    }

    await _saveParticipants();

    // Add demo activities
    final demoActivities = [
      GroupActivity(
        id: 'activity_001',
        groupId: 'session_001',
        sessionId: 'session_001',
        title: 'Tanışma ve Açılış',
        description: 'Grup üyelerinin tanışması ve grup kurallarının belirlenmesi',
        type: ActivityType.discussion,
        startTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        facilitatorId: 'clinician_001',
        participantIds: ['1', '2', '3'],
      ),
      GroupActivity(
        id: 'activity_002',
        groupId: 'session_001',
        sessionId: 'session_001',
        title: 'Deneyim Paylaşımı',
        description: 'Hastaların deneyimlerini paylaşması',
        type: ActivityType.discussion,
        startTime: DateTime.now().add(const Duration(days: 1, hours: 1, minutes: 30)),
        facilitatorId: 'clinician_001',
        participantIds: ['1', '2', '3'],
      ),
    ];

    for (final activity in demoActivities) {
      _activities.add(activity);
    }

    await _saveActivities();

    // Add demo templates
    final demoTemplates = [
      GroupTemplate(
        id: 'template_001',
        name: 'Depresyon Destek Grubu Şablonu',
        description: 'Depresyon yaşayan hastalar için destek grubu şablonu',
        type: GroupType.support,
        objectives: [
          'Hastaların birbirlerine destek olması',
          'Deneyim paylaşımı',
          'Başa çıkma stratejileri öğrenme',
        ],
        materials: [
          'Çalışma sayfaları',
          'Kalemler',
          'Flipchart',
        ],
        duration: const Duration(minutes: 90),
        maxParticipants: 8,
        createdBy: 'clinician_001',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        isPublic: true,
      ),
    ];

    for (final template in demoTemplates) {
      _templates.add(template);
    }

    await _saveTemplates();

    print('✅ Demo group sessions created: ${demoSessions.length}');
    print('✅ Demo group participants created: ${demoParticipants.length}');
    print('✅ Demo group activities created: ${demoActivities.length}');
    print('✅ Demo group templates created: ${demoTemplates.length}');
  }
}
