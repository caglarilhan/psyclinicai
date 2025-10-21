import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/supervision_models.dart';

class SupervisionService {
  static final SupervisionService _instance = SupervisionService._internal();
  factory SupervisionService() => _instance;
  SupervisionService._internal();

  final List<SupervisionSession> _sessions = [];
  final List<SupervisionNote> _notes = [];
  final List<SupervisionGoal> _goals = [];
  final List<TeamMember> _teamMembers = [];
  final List<TeamMeeting> _meetings = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadSessions();
    await _loadNotes();
    await _loadGoals();
    await _loadTeamMembers();
    await _loadMeetings();
  }

  // Load sessions from storage
  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('supervision_sessions') ?? [];
      _sessions.clear();
      
      for (final sessionJson in sessionsJson) {
        final session = SupervisionSession.fromJson(jsonDecode(sessionJson));
        _sessions.add(session);
      }
    } catch (e) {
      print('Error loading supervision sessions: $e');
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
      await prefs.setStringList('supervision_sessions', sessionsJson);
    } catch (e) {
      print('Error saving supervision sessions: $e');
    }
  }

  // Load notes from storage
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList('supervision_notes') ?? [];
      _notes.clear();
      
      for (final noteJson in notesJson) {
        final note = SupervisionNote.fromJson(jsonDecode(noteJson));
        _notes.add(note);
      }
    } catch (e) {
      print('Error loading supervision notes: $e');
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
      await prefs.setStringList('supervision_notes', notesJson);
    } catch (e) {
      print('Error saving supervision notes: $e');
    }
  }

  // Load goals from storage
  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getStringList('supervision_goals') ?? [];
      _goals.clear();
      
      for (final goalJson in goalsJson) {
        final goal = SupervisionGoal.fromJson(jsonDecode(goalJson));
        _goals.add(goal);
      }
    } catch (e) {
      print('Error loading supervision goals: $e');
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
      await prefs.setStringList('supervision_goals', goalsJson);
    } catch (e) {
      print('Error saving supervision goals: $e');
    }
  }

  // Load team members from storage
  Future<void> _loadTeamMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final membersJson = prefs.getStringList('team_members') ?? [];
      _teamMembers.clear();
      
      for (final memberJson in membersJson) {
        final member = TeamMember.fromJson(jsonDecode(memberJson));
        _teamMembers.add(member);
      }
    } catch (e) {
      print('Error loading team members: $e');
      _teamMembers.clear();
    }
  }

  // Save team members to storage
  Future<void> _saveTeamMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final membersJson = _teamMembers
          .map((member) => jsonEncode(member.toJson()))
          .toList();
      await prefs.setStringList('team_members', membersJson);
    } catch (e) {
      print('Error saving team members: $e');
    }
  }

  // Load meetings from storage
  Future<void> _loadMeetings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final meetingsJson = prefs.getStringList('team_meetings') ?? [];
      _meetings.clear();
      
      for (final meetingJson in meetingsJson) {
        final meeting = TeamMeeting.fromJson(jsonDecode(meetingJson));
        _meetings.add(meeting);
      }
    } catch (e) {
      print('Error loading team meetings: $e');
      _meetings.clear();
    }
  }

  // Save meetings to storage
  Future<void> _saveMeetings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final meetingsJson = _meetings
          .map((meeting) => jsonEncode(meeting.toJson()))
          .toList();
      await prefs.setStringList('team_meetings', meetingsJson);
    } catch (e) {
      print('Error saving team meetings: $e');
    }
  }

  // Schedule supervision session
  Future<SupervisionSession> scheduleSupervisionSession({
    required String supervisorId,
    required String superviseeId,
    required DateTime scheduledAt,
    required Duration duration,
    required SupervisionType type,
    String? agenda,
    String? location,
    bool isTelehealth = false,
    String? telehealthLink,
    List<String>? attendees,
  }) async {
    final session = SupervisionSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supervisorId: supervisorId,
      superviseeId: superviseeId,
      scheduledAt: scheduledAt,
      duration: duration,
      type: type,
      agenda: agenda,
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

  // Start supervision session
  Future<bool> startSupervisionSession(String sessionId) async {
    try {
      final index = _sessions.indexWhere((session) => session.id == sessionId);
      if (index == -1) return false;

      final session = _sessions[index];
      final updatedSession = SupervisionSession(
        id: session.id,
        supervisorId: session.supervisorId,
        superviseeId: session.superviseeId,
        scheduledAt: session.scheduledAt,
        duration: session.duration,
        type: session.type,
        status: SupervisionStatus.inProgress,
        agenda: session.agenda,
        notes: session.notes,
        feedback: session.feedback,
        actionItems: session.actionItems,
        startedAt: DateTime.now(),
        endedAt: session.endedAt,
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
      print('Error starting supervision session: $e');
      return false;
    }
  }

  // End supervision session
  Future<bool> endSupervisionSession({
    required String sessionId,
    String? notes,
    String? feedback,
    String? actionItems,
  }) async {
    try {
      final index = _sessions.indexWhere((session) => session.id == sessionId);
      if (index == -1) return false;

      final session = _sessions[index];
      final updatedSession = SupervisionSession(
        id: session.id,
        supervisorId: session.supervisorId,
        superviseeId: session.superviseeId,
        scheduledAt: session.scheduledAt,
        duration: session.duration,
        type: session.type,
        status: SupervisionStatus.completed,
        agenda: session.agenda,
        notes: notes ?? session.notes,
        feedback: feedback ?? session.feedback,
        actionItems: actionItems ?? session.actionItems,
        startedAt: session.startedAt,
        endedAt: DateTime.now(),
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
      print('Error ending supervision session: $e');
      return false;
    }
  }

  // Get supervision sessions for supervisor
  List<SupervisionSession> getSessionsForSupervisor(String supervisorId) {
    return _sessions
        .where((session) => session.supervisorId == supervisorId)
        .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  // Get supervision sessions for supervisee
  List<SupervisionSession> getSessionsForSupervisee(String superviseeId) {
    return _sessions
        .where((session) => session.superviseeId == superviseeId)
        .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  // Get upcoming supervision sessions
  List<SupervisionSession> getUpcomingSessions({int days = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    return _sessions
        .where((session) => 
            session.status == SupervisionStatus.scheduled &&
            session.scheduledAt.isAfter(DateTime.now()) &&
            session.scheduledAt.isBefore(cutoffDate))
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Add supervision note
  Future<SupervisionNote> addSupervisionNote({
    required String sessionId,
    required String supervisorId,
    required String content,
    required NoteType type,
    List<String>? tags,
    bool isConfidential = false,
    String? followUpAction,
  }) async {
    final note = SupervisionNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      supervisorId: supervisorId,
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
  List<SupervisionNote> getNotesForSession(String sessionId) {
    return _notes
        .where((note) => note.sessionId == sessionId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Add supervision goal
  Future<SupervisionGoal> addSupervisionGoal({
    required String sessionId,
    required String description,
    String? notes,
  }) async {
    final goal = SupervisionGoal(
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
  Future<bool> updateSupervisionGoalStatus(String goalId, GoalStatus status, {String? notes}) async {
    try {
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index == -1) return false;

      final goal = _goals[index];
      final updatedGoal = SupervisionGoal(
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
      print('Error updating supervision goal status: $e');
      return false;
    }
  }

  // Get goals for session
  List<SupervisionGoal> getGoalsForSession(String sessionId) {
    return _goals
        .where((goal) => goal.sessionId == sessionId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Add team member
  Future<TeamMember> addTeamMember({
    required String name,
    required String email,
    required String phone,
    required TeamRole role,
    List<String>? specialties,
    String? licenseNumber,
    DateTime? licenseExpiry,
    List<String>? certifications,
    String? supervisorId,
  }) async {
    final member = TeamMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      role: role,
      specialties: specialties ?? [],
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      certifications: certifications ?? [],
      joinedAt: DateTime.now(),
      supervisorId: supervisorId,
    );

    _teamMembers.add(member);
    await _saveTeamMembers();

    return member;
  }

  // Get all team members
  List<TeamMember> getAllTeamMembers() {
    return _teamMembers
        .where((member) => member.isActive)
        .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get team members by role
  List<TeamMember> getTeamMembersByRole(TeamRole role) {
    return _teamMembers
        .where((member) => member.isActive && member.role == role)
        .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get supervisees for supervisor
  List<TeamMember> getSuperviseesForSupervisor(String supervisorId) {
    return _teamMembers
        .where((member) => member.isActive && member.supervisorId == supervisorId)
        .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get team members with expired licenses
  List<TeamMember> getTeamMembersWithExpiredLicenses() {
    return _teamMembers
        .where((member) => member.isActive && member.isLicenseExpired)
        .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get team members with expiring licenses
  List<TeamMember> getTeamMembersWithExpiringLicenses() {
    return _teamMembers
        .where((member) => member.isActive && member.isLicenseExpiringSoon)
        .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Schedule team meeting
  Future<TeamMeeting> scheduleTeamMeeting({
    required String title,
    required String description,
    required DateTime scheduledAt,
    required Duration duration,
    required String location,
    required List<String> attendees,
    required String organizedBy,
    required MeetingType type,
    String? agenda,
  }) async {
    final meeting = TeamMeeting(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      scheduledAt: scheduledAt,
      duration: duration,
      location: location,
      attendees: attendees,
      organizedBy: organizedBy,
      type: type,
      agenda: agenda,
    );

    _meetings.add(meeting);
    await _saveMeetings();

    return meeting;
  }

  // Get team meetings
  List<TeamMeeting> getTeamMeetings() {
    return _meetings
        .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  // Get upcoming team meetings
  List<TeamMeeting> getUpcomingTeamMeetings({int days = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    return _meetings
        .where((meeting) => 
            meeting.status == MeetingStatus.scheduled &&
            meeting.scheduledAt.isAfter(DateTime.now()) &&
            meeting.scheduledAt.isBefore(cutoffDate))
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Get supervision statistics
  Map<String, dynamic> getSupervisionStatistics() {
    final totalSessions = _sessions.length;
    final completedSessions = _sessions
        .where((session) => session.status == SupervisionStatus.completed)
        .length;
    final cancelledSessions = _sessions
        .where((session) => session.status == SupervisionStatus.cancelled)
        .length;

    final totalNotes = _notes.length;
    final confidentialNotes = _notes
        .where((note) => note.isConfidential)
        .length;

    final totalGoals = _goals.length;
    final achievedGoals = _goals
        .where((goal) => goal.status == GoalStatus.achieved)
        .length;

    final totalTeamMembers = _teamMembers.length;
    final activeTeamMembers = _teamMembers
        .where((member) => member.isActive)
        .length;
    final expiredLicenses = _teamMembers
        .where((member) => member.isLicenseExpired)
        .length;
    final expiringLicenses = _teamMembers
        .where((member) => member.isLicenseExpiringSoon)
        .length;

    final totalMeetings = _meetings.length;
    final completedMeetings = _meetings
        .where((meeting) => meeting.status == MeetingStatus.completed)
        .length;

    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'cancelledSessions': cancelledSessions,
      'totalNotes': totalNotes,
      'confidentialNotes': confidentialNotes,
      'totalGoals': totalGoals,
      'achievedGoals': achievedGoals,
      'totalTeamMembers': totalTeamMembers,
      'activeTeamMembers': activeTeamMembers,
      'expiredLicenses': expiredLicenses,
      'expiringLicenses': expiringLicenses,
      'totalMeetings': totalMeetings,
      'completedMeetings': completedMeetings,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_sessions.isNotEmpty) return;

    // Add demo team members
    final demoTeamMembers = [
      TeamMember(
        id: 'member_001',
        name: 'Dr. Ayşe Yılmaz',
        email: 'ayse.yilmaz@clinic.com',
        phone: '+90 532 123 4567',
        role: TeamRole.psychiatrist,
        specialties: ['Depresyon', 'Anksiyete', 'Bipolar Bozukluk'],
        licenseNumber: 'PSY-001',
        licenseExpiry: DateTime.now().add(const Duration(days: 365)),
        certifications: ['CBT', 'DBT'],
        joinedAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      TeamMember(
        id: 'member_002',
        name: 'Psikolog Can Demir',
        email: 'can.demir@clinic.com',
        phone: '+90 533 234 5678',
        role: TeamRole.psychologist,
        specialties: ['Çocuk Psikolojisi', 'Aile Terapisi'],
        licenseNumber: 'PSY-002',
        licenseExpiry: DateTime.now().add(const Duration(days: 180)),
        certifications: ['Play Therapy', 'Family Therapy'],
        joinedAt: DateTime.now().subtract(const Duration(days: 180)),
        supervisorId: 'member_001',
      ),
      TeamMember(
        id: 'member_003',
        name: 'Terapist Zeynep Kara',
        email: 'zeynep.kara@clinic.com',
        phone: '+90 534 345 6789',
        role: TeamRole.therapist,
        specialties: ['Trauma', 'EMDR'],
        licenseNumber: 'PSY-003',
        licenseExpiry: DateTime.now().add(const Duration(days: 30)),
        certifications: ['EMDR', 'Trauma Therapy'],
        joinedAt: DateTime.now().subtract(const Duration(days: 90)),
        supervisorId: 'member_001',
      ),
    ];

    for (final member in demoTeamMembers) {
      _teamMembers.add(member);
    }

    await _saveTeamMembers();

    // Add demo supervision sessions
    final demoSessions = [
      SupervisionSession(
        id: 'session_001',
        supervisorId: 'member_001',
        superviseeId: 'member_002',
        scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
        duration: const Duration(minutes: 60),
        type: SupervisionType.individual,
        status: SupervisionStatus.completed,
        agenda: 'Çocuk vakası değerlendirmesi',
        notes: 'Vaka sunumu yapıldı, müdahale stratejileri tartışıldı.',
        feedback: 'Güçlü analiz, daha fazla aile katılımı önerildi.',
        actionItems: 'Aile görüşmesi planlanacak, takip randevusu verilecek.',
        startedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        endedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      SupervisionSession(
        id: 'session_002',
        supervisorId: 'member_001',
        superviseeId: 'member_003',
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
        duration: const Duration(minutes: 60),
        type: SupervisionType.individual,
        status: SupervisionStatus.scheduled,
        agenda: 'Trauma vakası değerlendirmesi',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    for (final session in demoSessions) {
      _sessions.add(session);
    }

    await _saveSessions();

    // Add demo team meetings
    final demoMeetings = [
      TeamMeeting(
        id: 'meeting_001',
        title: 'Haftalık Ekip Toplantısı',
        description: 'Haftalık vaka değerlendirmesi ve ekip koordinasyonu',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        duration: const Duration(minutes: 90),
        location: 'Toplantı Odası A',
        attendees: ['member_001', 'member_002', 'member_003'],
        organizedBy: 'member_001',
        type: MeetingType.team,
        agenda: '1. Vaka değerlendirmeleri\n2. Ekip koordinasyonu\n3. Eğitim planlaması',
      ),
    ];

    for (final meeting in demoMeetings) {
      _meetings.add(meeting);
    }

    await _saveMeetings();

    print('✅ Demo team members created: ${demoTeamMembers.length}');
    print('✅ Demo supervision sessions created: ${demoSessions.length}');
    print('✅ Demo team meetings created: ${demoMeetings.length}');
  }
}