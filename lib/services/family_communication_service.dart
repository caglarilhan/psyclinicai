import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_communication_models.dart';

class FamilyCommunicationService {
  static final FamilyCommunicationService _instance = FamilyCommunicationService._internal();
  factory FamilyCommunicationService() => _instance;
  FamilyCommunicationService._internal();

  final List<FamilyMember> _familyMembers = [];
  final List<FamilyCommunication> _communications = [];
  final List<FamilyMeeting> _meetings = [];
  final List<FamilyConsent> _consents = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadFamilyMembers();
    await _loadCommunications();
    await _loadMeetings();
    await _loadConsents();
  }

  // Load family members from storage
  Future<void> _loadFamilyMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final membersJson = prefs.getStringList('family_members') ?? [];
      _familyMembers.clear();
      
      for (final memberJson in membersJson) {
        final member = FamilyMember.fromJson(jsonDecode(memberJson));
        _familyMembers.add(member);
      }
    } catch (e) {
      print('Error loading family members: $e');
      _familyMembers.clear();
    }
  }

  // Save family members to storage
  Future<void> _saveFamilyMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final membersJson = _familyMembers
          .map((member) => jsonEncode(member.toJson()))
          .toList();
      await prefs.setStringList('family_members', membersJson);
    } catch (e) {
      print('Error saving family members: $e');
    }
  }

  // Load communications from storage
  Future<void> _loadCommunications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final communicationsJson = prefs.getStringList('family_communications') ?? [];
      _communications.clear();
      
      for (final communicationJson in communicationsJson) {
        final communication = FamilyCommunication.fromJson(jsonDecode(communicationJson));
        _communications.add(communication);
      }
    } catch (e) {
      print('Error loading family communications: $e');
      _communications.clear();
    }
  }

  // Save communications to storage
  Future<void> _saveCommunications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final communicationsJson = _communications
          .map((communication) => jsonEncode(communication.toJson()))
          .toList();
      await prefs.setStringList('family_communications', communicationsJson);
    } catch (e) {
      print('Error saving family communications: $e');
    }
  }

  // Load meetings from storage
  Future<void> _loadMeetings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final meetingsJson = prefs.getStringList('family_meetings') ?? [];
      _meetings.clear();
      
      for (final meetingJson in meetingsJson) {
        final meeting = FamilyMeeting.fromJson(jsonDecode(meetingJson));
        _meetings.add(meeting);
      }
    } catch (e) {
      print('Error loading family meetings: $e');
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
      await prefs.setStringList('family_meetings', meetingsJson);
    } catch (e) {
      print('Error saving family meetings: $e');
    }
  }

  // Load consents from storage
  Future<void> _loadConsents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentsJson = prefs.getStringList('family_consents') ?? [];
      _consents.clear();
      
      for (final consentJson in consentsJson) {
        final consent = FamilyConsent.fromJson(jsonDecode(consentJson));
        _consents.add(consent);
      }
    } catch (e) {
      print('Error loading family consents: $e');
      _consents.clear();
    }
  }

  // Save consents to storage
  Future<void> _saveConsents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentsJson = _consents
          .map((consent) => jsonEncode(consent.toJson()))
          .toList();
      await prefs.setStringList('family_consents', consentsJson);
    } catch (e) {
      print('Error saving family consents: $e');
    }
  }

  // Add family member
  Future<FamilyMember> addFamilyMember({
    required String patientId,
    required String name,
    required String relationship,
    required String phoneNumber,
    String? email,
    String? address,
    bool isPrimaryContact = false,
    bool canReceiveUpdates = true,
    bool canMakeDecisions = false,
  }) async {
    final member = FamilyMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      name: name,
      relationship: relationship,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
      isPrimaryContact: isPrimaryContact,
      canReceiveUpdates: canReceiveUpdates,
      canMakeDecisions: canMakeDecisions,
      createdAt: DateTime.now(),
    );

    _familyMembers.add(member);
    await _saveFamilyMembers();

    return member;
  }

  // Get family members for patient
  List<FamilyMember> getFamilyMembersForPatient(String patientId) {
    return _familyMembers
        .where((member) => member.patientId == patientId && member.isActive)
        .toList()
        ..sort((a, b) => b.isPrimaryContact ? 1 : -1);
  }

  // Get primary contact for patient
  FamilyMember? getPrimaryContactForPatient(String patientId) {
    return _familyMembers
        .where((member) => 
            member.patientId == patientId && 
            member.isActive && 
            member.isPrimaryContact)
        .firstOrNull;
  }

  // Send communication to family member
  Future<FamilyCommunication> sendCommunication({
    required String patientId,
    required String familyMemberId,
    required CommunicationType type,
    required String subject,
    required String message,
    required String sentBy,
    List<String>? attachments,
  }) async {
    final communication = FamilyCommunication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      familyMemberId: familyMemberId,
      type: type,
      subject: subject,
      message: message,
      sentAt: DateTime.now(),
      sentBy: sentBy,
      attachments: attachments ?? [],
    );

    _communications.add(communication);
    await _saveCommunications();

    return communication;
  }

  // Get communications for patient
  List<FamilyCommunication> getCommunicationsForPatient(String patientId) {
    return _communications
        .where((communication) => communication.patientId == patientId)
        .toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  // Get communications for family member
  List<FamilyCommunication> getCommunicationsForFamilyMember(String familyMemberId) {
    return _communications
        .where((communication) => communication.familyMemberId == familyMemberId)
        .toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  // Mark communication as read
  Future<bool> markCommunicationAsRead(String communicationId) async {
    try {
      final index = _communications.indexWhere((comm) => comm.id == communicationId);
      if (index == -1) return false;

      final communication = _communications[index];
      final updatedCommunication = communication.copyWith(
        status: CommunicationStatus.read,
        readAt: DateTime.now(),
      );

      _communications[index] = updatedCommunication;
      await _saveCommunications();
      return true;
    } catch (e) {
      print('Error marking communication as read: $e');
      return false;
    }
  }

  // Add response to communication
  Future<bool> addResponseToCommunication({
    required String communicationId,
    required String response,
  }) async {
    try {
      final index = _communications.indexWhere((comm) => comm.id == communicationId);
      if (index == -1) return false;

      final communication = _communications[index];
      final updatedCommunication = communication.copyWith(
        response: response,
        responseAt: DateTime.now(),
        status: CommunicationStatus.responded,
      );

      _communications[index] = updatedCommunication;
      await _saveCommunications();
      return true;
    } catch (e) {
      print('Error adding response to communication: $e');
      return false;
    }
  }

  // Schedule family meeting
  Future<FamilyMeeting> scheduleFamilyMeeting({
    required String patientId,
    required List<String> familyMemberIds,
    required String title,
    required String description,
    required DateTime scheduledAt,
    required Duration duration,
    required String location,
    required MeetingType type,
    required String organizedBy,
    String? notes,
  }) async {
    final meeting = FamilyMeeting(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      familyMemberIds: familyMemberIds,
      title: title,
      description: description,
      scheduledAt: scheduledAt,
      duration: duration,
      location: location,
      type: type,
      organizedBy: organizedBy,
      notes: notes,
    );

    _meetings.add(meeting);
    await _saveMeetings();

    return meeting;
  }

  // Get meetings for patient
  List<FamilyMeeting> getMeetingsForPatient(String patientId) {
    return _meetings
        .where((meeting) => meeting.patientId == patientId)
        .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  // Get upcoming meetings for patient
  List<FamilyMeeting> getUpcomingMeetingsForPatient(String patientId, {int days = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    return _meetings
        .where((meeting) => 
            meeting.patientId == patientId &&
            meeting.status == MeetingStatus.scheduled &&
            meeting.scheduledAt.isAfter(DateTime.now()) &&
            meeting.scheduledAt.isBefore(cutoffDate))
        .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Start meeting
  Future<bool> startMeeting(String meetingId) async {
    try {
      final index = _meetings.indexWhere((meeting) => meeting.id == meetingId);
      if (index == -1) return false;

      final meeting = _meetings[index];
      final updatedMeeting = FamilyMeeting(
        id: meeting.id,
        patientId: meeting.patientId,
        familyMemberIds: meeting.familyMemberIds,
        title: meeting.title,
        description: meeting.description,
        scheduledAt: meeting.scheduledAt,
        duration: meeting.duration,
        location: meeting.location,
        type: meeting.type,
        organizedBy: meeting.organizedBy,
        status: MeetingStatus.inProgress,
        notes: meeting.notes,
        attendees: meeting.attendees,
        startedAt: DateTime.now(),
        endedAt: meeting.endedAt,
        outcomes: meeting.outcomes,
      );

      _meetings[index] = updatedMeeting;
      await _saveMeetings();
      return true;
    } catch (e) {
      print('Error starting meeting: $e');
      return false;
    }
  }

  // End meeting
  Future<bool> endMeeting({
    required String meetingId,
    required Map<String, dynamic> outcomes,
    String? notes,
  }) async {
    try {
      final index = _meetings.indexWhere((meeting) => meeting.id == meetingId);
      if (index == -1) return false;

      final meeting = _meetings[index];
      final updatedMeeting = FamilyMeeting(
        id: meeting.id,
        patientId: meeting.patientId,
        familyMemberIds: meeting.familyMemberIds,
        title: meeting.title,
        description: meeting.description,
        scheduledAt: meeting.scheduledAt,
        duration: meeting.duration,
        location: meeting.location,
        type: meeting.type,
        organizedBy: meeting.organizedBy,
        status: MeetingStatus.completed,
        notes: notes ?? meeting.notes,
        attendees: meeting.attendees,
        startedAt: meeting.startedAt,
        endedAt: DateTime.now(),
        outcomes: outcomes,
      );

      _meetings[index] = updatedMeeting;
      await _saveMeetings();
      return true;
    } catch (e) {
      print('Error ending meeting: $e');
      return false;
    }
  }

  // Request family consent
  Future<FamilyConsent> requestFamilyConsent({
    required String patientId,
    required String familyMemberId,
    required ConsentType type,
    required String description,
    required String requestedBy,
    Duration? validityPeriod,
  }) async {
    final consent = FamilyConsent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      familyMemberId: familyMemberId,
      type: type,
      description: description,
      requestedAt: DateTime.now(),
      requestedBy: requestedBy,
      expiresAt: validityPeriod != null 
          ? DateTime.now().add(validityPeriod) 
          : null,
    );

    _consents.add(consent);
    await _saveConsents();

    return consent;
  }

  // Grant consent
  Future<bool> grantConsent(String consentId, {String? notes}) async {
    try {
      final index = _consents.indexWhere((consent) => consent.id == consentId);
      if (index == -1) return false;

      final consent = _consents[index];
      final updatedConsent = FamilyConsent(
        id: consent.id,
        patientId: consent.patientId,
        familyMemberId: consent.familyMemberId,
        type: consent.type,
        description: consent.description,
        requestedAt: consent.requestedAt,
        requestedBy: consent.requestedBy,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now(),
        expiresAt: consent.expiresAt,
        notes: notes ?? consent.notes,
        permissions: consent.permissions,
      );

      _consents[index] = updatedConsent;
      await _saveConsents();
      return true;
    } catch (e) {
      print('Error granting consent: $e');
      return false;
    }
  }

  // Get consents for patient
  List<FamilyConsent> getConsentsForPatient(String patientId) {
    return _consents
        .where((consent) => consent.patientId == patientId)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Get pending consents for family member
  List<FamilyConsent> getPendingConsentsForFamilyMember(String familyMemberId) {
    return _consents
        .where((consent) => 
            consent.familyMemberId == familyMemberId &&
            consent.status == ConsentStatus.pending)
        .toList()
        ..sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
  }

  // Get family communication statistics
  Map<String, dynamic> getFamilyCommunicationStatistics(String patientId) {
    final communications = getCommunicationsForPatient(patientId);
    final meetings = getMeetingsForPatient(patientId);
    final consents = getConsentsForPatient(patientId);

    final totalCommunications = communications.length;
    final readCommunications = communications
        .where((comm) => comm.status == CommunicationStatus.read)
        .length;
    final respondedCommunications = communications
        .where((comm) => comm.status == CommunicationStatus.responded)
        .length;

    final totalMeetings = meetings.length;
    final completedMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.completed)
        .length;
    final upcomingMeetings = meetings
        .where((meeting) => 
            meeting.status == MeetingStatus.scheduled &&
            meeting.scheduledAt.isAfter(DateTime.now()))
        .length;

    final totalConsents = consents.length;
    final grantedConsents = consents
        .where((consent) => consent.status == ConsentStatus.granted)
        .length;
    final pendingConsents = consents
        .where((consent) => consent.status == ConsentStatus.pending)
        .length;

    return {
      'totalCommunications': totalCommunications,
      'readCommunications': readCommunications,
      'respondedCommunications': respondedCommunications,
      'totalMeetings': totalMeetings,
      'completedMeetings': completedMeetings,
      'upcomingMeetings': upcomingMeetings,
      'totalConsents': totalConsents,
      'grantedConsents': grantedConsents,
      'pendingConsents': pendingConsents,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_familyMembers.isNotEmpty) return;

    final demoFamilyMembers = [
      FamilyMember(
        id: 'family_001',
        patientId: '1',
        name: 'Ayşe Yılmaz',
        relationship: 'Eş',
        phoneNumber: '+90 532 123 4567',
        email: 'ayse.yilmaz@email.com',
        isPrimaryContact: true,
        canReceiveUpdates: true,
        canMakeDecisions: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      FamilyMember(
        id: 'family_002',
        patientId: '1',
        name: 'Mehmet Yılmaz',
        relationship: 'Oğul',
        phoneNumber: '+90 533 234 5678',
        email: 'mehmet.yilmaz@email.com',
        isPrimaryContact: false,
        canReceiveUpdates: true,
        canMakeDecisions: false,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      FamilyMember(
        id: 'family_003',
        patientId: '2',
        name: 'Fatma Demir',
        relationship: 'Kız Kardeş',
        phoneNumber: '+90 534 345 6789',
        isPrimaryContact: true,
        canReceiveUpdates: true,
        canMakeDecisions: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    for (final member in demoFamilyMembers) {
      _familyMembers.add(member);
    }

    await _saveFamilyMembers();

    // Add demo communications
    final demoCommunications = [
      FamilyCommunication(
        id: 'comm_001',
        patientId: '1',
        familyMemberId: 'family_001',
        type: CommunicationType.update,
        subject: 'Hasta Durumu Güncellemesi',
        message: 'Hastanızın durumu stabil. Kan şekeri seviyeleri normale döndü.',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        sentBy: 'nurse_001',
        status: CommunicationStatus.read,
        readAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      FamilyCommunication(
        id: 'comm_002',
        patientId: '1',
        familyMemberId: 'family_001',
        type: CommunicationType.appointment,
        subject: 'Randevu Hatırlatması',
        message: 'Yarın saat 14:00\'da kontrol randevunuz var.',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        sentBy: 'system',
        status: CommunicationStatus.responded,
        readAt: DateTime.now().subtract(const Duration(hours: 20)),
        response: 'Teşekkürler, randevuya geleceğiz.',
        responseAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ];

    for (final communication in demoCommunications) {
      _communications.add(communication);
    }

    await _saveCommunications();

    print('✅ Demo family members created: ${demoFamilyMembers.length}');
    print('✅ Demo communications created: ${demoCommunications.length}');
  }
}
