import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consultation_models.dart';

class ConsultationService {
  static final ConsultationService _instance = ConsultationService._internal();
  factory ConsultationService() => _instance;
  ConsultationService._internal();

  final List<ConsultationRequest> _requests = [];
  final List<ConsultationResponse> _responses = [];
  final List<ConsultationTemplate> _templates = [];
  final List<ConsultationSchedule> _schedules = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadRequests();
    await _loadResponses();
    await _loadTemplates();
    await _loadSchedules();
  }

  // Load requests from storage
  Future<void> _loadRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getStringList('consultation_requests') ?? [];
      _requests.clear();
      
      for (final requestJson in requestsJson) {
        final request = ConsultationRequest.fromJson(jsonDecode(requestJson));
        _requests.add(request);
      }
    } catch (e) {
      print('Error loading consultation requests: $e');
      _requests.clear();
    }
  }

  // Save requests to storage
  Future<void> _saveRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = _requests
          .map((request) => jsonEncode(request.toJson()))
          .toList();
      await prefs.setStringList('consultation_requests', requestsJson);
    } catch (e) {
      print('Error saving consultation requests: $e');
    }
  }

  // Load responses from storage
  Future<void> _loadResponses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final responsesJson = prefs.getStringList('consultation_responses') ?? [];
      _responses.clear();
      
      for (final responseJson in responsesJson) {
        final response = ConsultationResponse.fromJson(jsonDecode(responseJson));
        _responses.add(response);
      }
    } catch (e) {
      print('Error loading consultation responses: $e');
      _responses.clear();
    }
  }

  // Save responses to storage
  Future<void> _saveResponses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final responsesJson = _responses
          .map((response) => jsonEncode(response.toJson()))
          .toList();
      await prefs.setStringList('consultation_responses', responsesJson);
    } catch (e) {
      print('Error saving consultation responses: $e');
    }
  }

  // Load templates from storage
  Future<void> _loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList('consultation_templates') ?? [];
      _templates.clear();
      
      for (final templateJson in templatesJson) {
        final template = ConsultationTemplate.fromJson(jsonDecode(templateJson));
        _templates.add(template);
      }
    } catch (e) {
      print('Error loading consultation templates: $e');
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
      await prefs.setStringList('consultation_templates', templatesJson);
    } catch (e) {
      print('Error saving consultation templates: $e');
    }
  }

  // Load schedules from storage
  Future<void> _loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getStringList('consultation_schedules') ?? [];
      _schedules.clear();
      
      for (final scheduleJson in schedulesJson) {
        final schedule = ConsultationSchedule.fromJson(jsonDecode(scheduleJson));
        _schedules.add(schedule);
      }
    } catch (e) {
      print('Error loading consultation schedules: $e');
      _schedules.clear();
    }
  }

  // Save schedules to storage
  Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = _schedules
          .map((schedule) => jsonEncode(schedule.toJson()))
          .toList();
      await prefs.setStringList('consultation_schedules', schedulesJson);
    } catch (e) {
      print('Error saving consultation schedules: $e');
    }
  }

  // Request consultation
  Future<ConsultationRequest> requestConsultation({
    required String patientId,
    required String requestingPhysicianId,
    required String consultingPsychiatristId,
    required ConsultationType type,
    required String reason,
    required String question,
    required ConsultationUrgency urgency,
    String? notes,
  }) async {
    final request = ConsultationRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      requestingPhysicianId: requestingPhysicianId,
      consultingPsychiatristId: consultingPsychiatristId,
      type: type,
      reason: reason,
      question: question,
      urgency: urgency,
      requestedAt: DateTime.now(),
      notes: notes,
    );

    _requests.add(request);
    await _saveRequests();

    return request;
  }

  // Schedule consultation
  Future<bool> scheduleConsultation({
    required String requestId,
    required DateTime scheduledAt,
    required Duration duration,
  }) async {
    try {
      final requestIndex = _requests.indexWhere((r) => r.id == requestId);
      if (requestIndex == -1) return false;

      final request = _requests[requestIndex];
      final updatedRequest = ConsultationRequest(
        id: request.id,
        patientId: request.patientId,
        requestingPhysicianId: request.requestingPhysicianId,
        consultingPsychiatristId: request.consultingPsychiatristId,
        type: request.type,
        reason: request.reason,
        question: request.question,
        urgency: request.urgency,
        requestedAt: request.requestedAt,
        scheduledAt: scheduledAt,
        status: ConsultationStatus.scheduled,
        notes: request.notes,
        metadata: request.metadata,
      );

      _requests[requestIndex] = updatedRequest;

      // Create schedule entry
      final schedule = ConsultationSchedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        psychiatristId: request.consultingPsychiatristId,
        startTime: scheduledAt,
        endTime: scheduledAt.add(duration),
        patientId: request.patientId,
        consultationRequestId: requestId,
        status: ScheduleStatus.booked,
      );

      _schedules.add(schedule);

      await _saveRequests();
      await _saveSchedules();
      return true;
    } catch (e) {
      print('Error scheduling consultation: $e');
      return false;
    }
  }

  // Respond to consultation
  Future<ConsultationResponse> respondToConsultation({
    required String requestId,
    required String psychiatristId,
    required String assessment,
    required String recommendations,
    String? followUp,
    String? notes,
  }) async {
    final response = ConsultationResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      consultationRequestId: requestId,
      psychiatristId: psychiatristId,
      respondedAt: DateTime.now(),
      assessment: assessment,
      recommendations: recommendations,
      followUp: followUp,
      notes: notes,
    );

    _responses.add(response);

    // Update request status
    final requestIndex = _requests.indexWhere((r) => r.id == requestId);
    if (requestIndex != -1) {
      final request = _requests[requestIndex];
      final updatedRequest = ConsultationRequest(
        id: request.id,
        patientId: request.patientId,
        requestingPhysicianId: request.requestingPhysicianId,
        consultingPsychiatristId: request.consultingPsychiatristId,
        type: request.type,
        reason: request.reason,
        question: request.question,
        urgency: request.urgency,
        requestedAt: request.requestedAt,
        scheduledAt: request.scheduledAt,
        status: ConsultationStatus.completed,
        notes: request.notes,
        metadata: request.metadata,
      );

      _requests[requestIndex] = updatedRequest;
    }

    await _saveResponses();
    await _saveRequests();

    return response;
  }

  // Create consultation template
  Future<ConsultationTemplate> createTemplate({
    required String name,
    required String description,
    required ConsultationType type,
    required String template,
    required String createdBy,
    bool isPublic = false,
    List<String>? sharedWith,
  }) async {
    final consultationTemplate = ConsultationTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      type: type,
      template: template,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      isPublic: isPublic,
      sharedWith: sharedWith ?? [],
    );

    _templates.add(consultationTemplate);
    await _saveTemplates();

    return consultationTemplate;
  }

  // Add consultation schedule
  Future<ConsultationSchedule> addSchedule({
    required String psychiatristId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    final schedule = ConsultationSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      psychiatristId: psychiatristId,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
    );

    _schedules.add(schedule);
    await _saveSchedules();

    return schedule;
  }

  // Get requests for psychiatrist
  List<ConsultationRequest> getRequestsForPsychiatrist(String psychiatristId) {
    return _requests
        .where((request) => request.consultingPsychiatristId == psychiatristId)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Get requests for physician
  List<ConsultationRequest> getRequestsForPhysician(String physicianId) {
    return _requests
        .where((request) => request.requestingPhysicianId == physicianId)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Get requests for patient
  List<ConsultationRequest> getRequestsForPatient(String patientId) {
    return _requests
        .where((request) => request.patientId == patientId)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Get pending requests
  List<ConsultationRequest> getPendingRequests() {
    return _requests
        .where((request) => request.status == ConsultationStatus.pending)
        .toList()
        ..sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
  }

  // Get urgent requests
  List<ConsultationRequest> getUrgentRequests() {
    return _requests
        .where((request) => request.isUrgent)
        .toList()
        ..sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
  }

  // Get overdue requests
  List<ConsultationRequest> getOverdueRequests() {
    return _requests
        .where((request) => request.isOverdue)
        .toList()
        ..sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
  }

  // Get responses for psychiatrist
  List<ConsultationResponse> getResponsesForPsychiatrist(String psychiatristId) {
    return _responses
        .where((response) => response.psychiatristId == psychiatristId)
        .toList()
        ..sort((a, b) => b.respondedAt.compareTo(a.respondedAt));
  }

  // Get templates for user
  List<ConsultationTemplate> getTemplatesForUser(String userId) {
    return _templates
        .where((template) => template.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get templates by type
  List<ConsultationTemplate> getTemplatesByType(ConsultationType type, String userId) {
    return _templates
        .where((template) => 
            template.type == type && 
            template.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get schedules for psychiatrist
  List<ConsultationSchedule> getSchedulesForPsychiatrist(String psychiatristId) {
    return _schedules
        .where((schedule) => schedule.psychiatristId == psychiatristId)
        .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get available schedules for psychiatrist
  List<ConsultationSchedule> getAvailableSchedulesForPsychiatrist(String psychiatristId) {
    return _schedules
        .where((schedule) => 
            schedule.psychiatristId == psychiatristId && 
            schedule.isAvailable)
        .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get booked schedules for psychiatrist
  List<ConsultationSchedule> getBookedSchedulesForPsychiatrist(String psychiatristId) {
    return _schedules
        .where((schedule) => 
            schedule.psychiatristId == psychiatristId && 
            schedule.isBooked)
        .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalRequests = _requests.length;
    final pendingRequests = _requests
        .where((request) => request.status == ConsultationStatus.pending)
        .length;
    final completedRequests = _requests
        .where((request) => request.status == ConsultationStatus.completed)
        .length;
    final urgentRequests = _requests
        .where((request) => request.isUrgent)
        .length;
    final overdueRequests = _requests
        .where((request) => request.isOverdue)
        .length;

    final totalResponses = _responses.length;
    final totalTemplates = _templates.length;
    final totalSchedules = _schedules.length;
    final availableSchedules = _schedules
        .where((schedule) => schedule.isAvailable)
        .length;
    final bookedSchedules = _schedules
        .where((schedule) => schedule.isBooked)
        .length;

    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'completedRequests': completedRequests,
      'urgentRequests': urgentRequests,
      'overdueRequests': overdueRequests,
      'totalResponses': totalResponses,
      'totalTemplates': totalTemplates,
      'totalSchedules': totalSchedules,
      'availableSchedules': availableSchedules,
      'bookedSchedules': bookedSchedules,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_requests.isNotEmpty) return;

    // Add demo requests
    final demoRequests = [
      ConsultationRequest(
        id: 'request_001',
        patientId: '1',
        requestingPhysicianId: 'physician_001',
        consultingPsychiatristId: 'psychiatrist_001',
        type: ConsultationType.assessment,
        reason: 'Depression evaluation',
        question: 'Does this patient need psychiatric evaluation?',
        urgency: ConsultationUrgency.routine,
        requestedAt: DateTime.now().subtract(const Duration(days: 2)),
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        status: ConsultationStatus.scheduled,
        notes: 'Patient cooperative',
      ),
      ConsultationRequest(
        id: 'request_002',
        patientId: '2',
        requestingPhysicianId: 'physician_002',
        consultingPsychiatristId: 'psychiatrist_001',
        type: ConsultationType.medication,
        reason: 'Medication adjustment',
        question: 'Should we adjust the current medication?',
        urgency: ConsultationUrgency.urgent,
        requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: ConsultationStatus.pending,
        notes: 'Patient not responding to current treatment',
      ),
    ];

    for (final request in demoRequests) {
      _requests.add(request);
    }

    await _saveRequests();

    // Add demo responses
    final demoResponses = [
      ConsultationResponse(
        id: 'response_001',
        consultationRequestId: 'request_001',
        psychiatristId: 'psychiatrist_001',
        respondedAt: DateTime.now().subtract(const Duration(days: 1)),
        assessment: 'Patient shows signs of depression',
        recommendations: 'Refer to psychiatrist for evaluation',
        followUp: 'Schedule psychiatric appointment',
        notes: 'Patient cooperative',
      ),
    ];

    for (final response in demoResponses) {
      _responses.add(response);
    }

    await _saveResponses();

    // Add demo templates
    final demoTemplates = [
      ConsultationTemplate(
        id: 'template_001',
        name: 'Depression Assessment Template',
        description: 'Template for depression assessment consultations',
        type: ConsultationType.assessment,
        template: '''
Assessment:
- Mood: {mood}
- Sleep: {sleep}
- Appetite: {appetite}
- Energy: {energy}
- Concentration: {concentration}
- Suicidal ideation: {suicidal_ideation}

Recommendations:
- {recommendations}

Follow-up:
- {follow_up}
        ''',
        createdBy: 'psychiatrist_001',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isPublic: true,
      ),
    ];

    for (final template in demoTemplates) {
      _templates.add(template);
    }

    await _saveTemplates();

    // Add demo schedules
    final demoSchedules = [
      ConsultationSchedule(
        id: 'schedule_001',
        psychiatristId: 'psychiatrist_001',
        startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        patientId: '1',
        consultationRequestId: 'request_001',
        status: ScheduleStatus.booked,
      ),
      ConsultationSchedule(
        id: 'schedule_002',
        psychiatristId: 'psychiatrist_001',
        startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
        status: ScheduleStatus.available,
      ),
    ];

    for (final schedule in demoSchedules) {
      _schedules.add(schedule);
    }

    await _saveSchedules();

    print('✅ Demo consultation requests created: ${demoRequests.length}');
    print('✅ Demo consultation responses created: ${demoResponses.length}');
    print('✅ Demo consultation templates created: ${demoTemplates.length}');
    print('✅ Demo consultation schedules created: ${demoSchedules.length}');
  }
}
