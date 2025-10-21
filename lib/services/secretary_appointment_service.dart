import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/secretary_appointment_models.dart';

class SecretaryAppointmentService {
  static final SecretaryAppointmentService _instance = SecretaryAppointmentService._internal();
  factory SecretaryAppointmentService() => _instance;
  SecretaryAppointmentService._internal();

  final List<Appointment> _appointments = [];
  final List<WaitingList> _waitingList = [];
  final List<DoctorSchedule> _doctorSchedules = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadAppointments();
    await _loadWaitingList();
    await _loadDoctorSchedules();
  }

  // Load appointments from storage
  Future<void> _loadAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList('secretary_appointments') ?? [];
      _appointments.clear();
      
      for (final appointmentJson in appointmentsJson) {
        final appointment = Appointment.fromJson(jsonDecode(appointmentJson));
        _appointments.add(appointment);
      }
    } catch (e) {
      print('Error loading appointments: $e');
      _appointments.clear();
    }
  }

  // Save appointments to storage
  Future<void> _saveAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = _appointments
          .map((appointment) => jsonEncode(appointment.toJson()))
          .toList();
      await prefs.setStringList('secretary_appointments', appointmentsJson);
    } catch (e) {
      print('Error saving appointments: $e');
    }
  }

  // Load waiting list from storage
  Future<void> _loadWaitingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final waitingListJson = prefs.getStringList('secretary_waiting_list') ?? [];
      _waitingList.clear();
      
      for (final waitingJson in waitingListJson) {
        final waiting = WaitingList.fromJson(jsonDecode(waitingJson));
        _waitingList.add(waiting);
      }
    } catch (e) {
      print('Error loading waiting list: $e');
      _waitingList.clear();
    }
  }

  // Save waiting list to storage
  Future<void> _saveWaitingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final waitingListJson = _waitingList
          .map((waiting) => jsonEncode(waiting.toJson()))
          .toList();
      await prefs.setStringList('secretary_waiting_list', waitingListJson);
    } catch (e) {
      print('Error saving waiting list: $e');
    }
  }

  // Load doctor schedules from storage
  Future<void> _loadDoctorSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getStringList('secretary_doctor_schedules') ?? [];
      _doctorSchedules.clear();
      
      for (final scheduleJson in schedulesJson) {
        final schedule = DoctorSchedule.fromJson(jsonDecode(scheduleJson));
        _doctorSchedules.add(schedule);
      }
    } catch (e) {
      print('Error loading doctor schedules: $e');
      _doctorSchedules.clear();
    }
  }

  // Save doctor schedules to storage
  Future<void> _saveDoctorSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = _doctorSchedules
          .map((schedule) => jsonEncode(schedule.toJson()))
          .toList();
      await prefs.setStringList('secretary_doctor_schedules', schedulesJson);
    } catch (e) {
      print('Error saving doctor schedules: $e');
    }
  }

  // Create appointment
  Future<Appointment> createAppointment({
    required String patientId,
    required String doctorId,
    required String secretaryId,
    required DateTime scheduledTime,
    required Duration duration,
    required AppointmentType type,
    PriorityLevel priority = PriorityLevel.normal,
    String? notes,
    String? reason,
    String? location,
    bool isTelemedicine = false,
    String? telemedicineLink,
  }) async {
    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      doctorId: doctorId,
      secretaryId: secretaryId,
      scheduledTime: scheduledTime,
      duration: duration,
      type: type,
      priority: priority,
      notes: notes,
      reason: reason,
      location: location,
      isTelemedicine: isTelemedicine,
      telemedicineLink: telemedicineLink,
      createdAt: DateTime.now(),
    );

    _appointments.add(appointment);
    await _saveAppointments();

    // Add to history
    await _addAppointmentHistory(
      appointment.id,
      'created',
      'Randevu oluşturuldu',
      secretaryId,
    );

    // Generate reminders
    await _generateReminders(appointment);

    return appointment;
  }

  // Update appointment
  Future<bool> updateAppointment(Appointment updatedAppointment, String updatedBy) async {
    try {
      final index = _appointments.indexWhere((apt) => apt.id == updatedAppointment.id);
      if (index == -1) return false;

      final oldAppointment = _appointments[index];
      _appointments[index] = updatedAppointment.copyWith(updatedAt: DateTime.now());
      
      await _saveAppointments();

      // Add to history
      await _addAppointmentHistory(
        updatedAppointment.id,
        'updated',
        'Randevu güncellendi',
        updatedBy,
      );

      return true;
    } catch (e) {
      print('Error updating appointment: $e');
      return false;
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId, String reason, String cancelledBy) async {
    try {
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index == -1) return false;

      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      await _saveAppointments();

      // Add to history
      await _addAppointmentHistory(
        appointmentId,
        'cancelled',
        'Randevu iptal edildi: $reason',
        cancelledBy,
      );

      return true;
    } catch (e) {
      print('Error cancelling appointment: $e');
      return false;
    }
  }

  // Reschedule appointment
  Future<bool> rescheduleAppointment(String appointmentId, DateTime newTime, String rescheduledBy) async {
    try {
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index == -1) return false;

      final oldTime = _appointments[index].scheduledTime;
      _appointments[index] = _appointments[index].copyWith(
        scheduledTime: newTime,
        status: AppointmentStatus.rescheduled,
        updatedAt: DateTime.now(),
      );

      await _saveAppointments();

      // Add to history
      await _addAppointmentHistory(
        appointmentId,
        'rescheduled',
        'Randevu yeniden planlandı: ${oldTime.toString()} -> ${newTime.toString()}',
        rescheduledBy,
      );

      return true;
    } catch (e) {
      print('Error rescheduling appointment: $e');
      return false;
    }
  }

  // Add to waiting list
  Future<WaitingList> addToWaitingList({
    required String patientId,
    required String doctorId,
    required String secretaryId,
    required AppointmentType preferredType,
    required DateTime requestedDate,
    PriorityLevel priority = PriorityLevel.normal,
    String? preferredTime,
    String? notes,
    String? reason,
  }) async {
    final waiting = WaitingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      doctorId: doctorId,
      secretaryId: secretaryId,
      preferredType: preferredType,
      priority: priority,
      requestedDate: requestedDate,
      preferredTime: preferredTime,
      notes: notes,
      reason: reason,
      createdAt: DateTime.now(),
    );

    _waitingList.add(waiting);
    await _saveWaitingList();

    return waiting;
  }

  // Assign waiting list to appointment
  Future<bool> assignWaitingListToAppointment(String waitingId, String appointmentId) async {
    try {
      final waitingIndex = _waitingList.indexWhere((w) => w.id == waitingId);
      if (waitingIndex == -1) return false;

      _waitingList[waitingIndex] = _waitingList[waitingIndex].copyWith(
        isActive: false,
        assignedAt: DateTime.now(),
        assignedAppointmentId: appointmentId,
      );

      await _saveWaitingList();
      return true;
    } catch (e) {
      print('Error assigning waiting list: $e');
      return false;
    }
  }

  // Add doctor schedule
  Future<DoctorSchedule> addDoctorSchedule({
    required String doctorId,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? notes,
    List<String>? availableTypes,
    Duration? defaultDuration,
  }) async {
    final schedule = DoctorSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorId: doctorId,
      startTime: startTime,
      endTime: endTime,
      location: location,
      notes: notes,
      availableTypes: availableTypes ?? [],
      defaultDuration: defaultDuration ?? const Duration(minutes: 30),
    );

    _doctorSchedules.add(schedule);
    await _saveDoctorSchedules();

    return schedule;
  }

  // Generate reminders for appointment
  Future<void> _generateReminders(Appointment appointment) async {
    final reminders = <AppointmentReminder>[];
    
    // 24 hours before
    final reminder24h = AppointmentReminder(
      id: '${appointment.id}_24h',
      appointmentId: appointment.id,
      reminderTime: appointment.scheduledTime.subtract(const Duration(hours: 24)),
      type: NotificationType.email,
      message: 'Yarın ${appointment.scheduledTime.hour}:${appointment.scheduledTime.minute.toString().padLeft(2, '0')} randevunuz var.',
    );
    reminders.add(reminder24h);

    // 2 hours before
    final reminder2h = AppointmentReminder(
      id: '${appointment.id}_2h',
      appointmentId: appointment.id,
      reminderTime: appointment.scheduledTime.subtract(const Duration(hours: 2)),
      type: NotificationType.sms,
      message: '2 saat sonra ${appointment.scheduledTime.hour}:${appointment.scheduledTime.minute.toString().padLeft(2, '0')} randevunuz var.',
    );
    reminders.add(reminder2h);

    // Update appointment with reminders
    final index = _appointments.indexWhere((apt) => apt.id == appointment.id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(reminders: reminders);
      await _saveAppointments();
    }
  }

  // Add appointment history
  Future<void> _addAppointmentHistory(String appointmentId, String action, String description, String performedBy) async {
    final history = AppointmentHistory(
      id: '${appointmentId}_${DateTime.now().millisecondsSinceEpoch}',
      appointmentId: appointmentId,
      action: action,
      description: description,
      performedBy: performedBy,
      timestamp: DateTime.now(),
    );

    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      final updatedHistory = List<AppointmentHistory>.from(_appointments[index].history)..add(history);
      _appointments[index] = _appointments[index].copyWith(history: updatedHistory);
      await _saveAppointments();
    }
  }

  // Get appointments for doctor
  List<Appointment> getAppointmentsForDoctor(String doctorId) {
    return _appointments
        .where((apt) => apt.doctorId == doctorId)
        .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get appointments for patient
  List<Appointment> getAppointmentsForPatient(String patientId) {
    return _appointments
        .where((apt) => apt.patientId == patientId)
        .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get appointments for secretary
  List<Appointment> getAppointmentsForSecretary(String secretaryId) {
    return _appointments
        .where((apt) => apt.secretaryId == secretaryId)
        .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get appointments by date range
  List<Appointment> getAppointmentsByDateRange(DateTime startDate, DateTime endDate) {
    return _appointments
        .where((apt) => 
            apt.scheduledTime.isAfter(startDate) && 
            apt.scheduledTime.isBefore(endDate))
        .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get appointments by status
  List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    return _appointments
        .where((apt) => apt.status == status)
        .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get urgent appointments
  List<Appointment> getUrgentAppointments() {
    return _appointments
        .where((apt) => apt.priority == PriorityLevel.urgent)
        .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get waiting list for doctor
  List<WaitingList> getWaitingListForDoctor(String doctorId) {
    return _waitingList
        .where((w) => w.doctorId == doctorId && w.isActive)
        .toList()
        ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  // Get active waiting list
  List<WaitingList> getActiveWaitingList() {
    return _waitingList
        .where((w) => w.isActive)
        .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Get doctor schedules
  List<DoctorSchedule> getDoctorSchedules(String doctorId) {
    return _doctorSchedules
        .where((s) => s.doctorId == doctorId)
        .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get available time slots for doctor
  List<DateTime> getAvailableTimeSlots(String doctorId, DateTime date, Duration duration) {
    final schedules = getDoctorSchedules(doctorId);
    final appointments = getAppointmentsForDoctor(doctorId)
        .where((apt) => 
            apt.scheduledTime.day == date.day &&
            apt.scheduledTime.month == date.month &&
            apt.scheduledTime.year == date.year &&
            apt.status != AppointmentStatus.cancelled)
        .toList();

    final availableSlots = <DateTime>[];
    
    for (final schedule in schedules) {
      if (schedule.isAvailable && 
          schedule.startTime.day == date.day &&
          schedule.startTime.month == date.month &&
          schedule.startTime.year == date.year) {
        
        var currentTime = schedule.startTime;
        while (currentTime.add(duration).isBefore(schedule.endTime) || 
               currentTime.add(duration).isAtSameMomentAs(schedule.endTime)) {
          
          // Check if this slot conflicts with existing appointments
          final hasConflict = appointments.any((apt) {
            final aptEnd = apt.scheduledTime.add(apt.duration);
            final slotEnd = currentTime.add(duration);
            
            return (currentTime.isBefore(aptEnd) && slotEnd.isAfter(apt.scheduledTime));
          });
          
          if (!hasConflict) {
            availableSlots.add(currentTime);
          }
          
          currentTime = currentTime.add(const Duration(minutes: 30));
        }
      }
    }
    
    return availableSlots;
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalAppointments = _appointments.length;
    final scheduledAppointments = _appointments
        .where((apt) => apt.status == AppointmentStatus.scheduled)
        .length;
    final completedAppointments = _appointments
        .where((apt) => apt.status == AppointmentStatus.completed)
        .length;
    final cancelledAppointments = _appointments
        .where((apt) => apt.status == AppointmentStatus.cancelled)
        .length;
    final noShowAppointments = _appointments
        .where((apt) => apt.status == AppointmentStatus.noShow)
        .length;
    final urgentAppointments = _appointments
        .where((apt) => apt.priority == PriorityLevel.urgent)
        .length;
    final telemedicineAppointments = _appointments
        .where((apt) => apt.isTelemedicine)
        .length;

    final totalWaitingList = _waitingList.length;
    final activeWaitingList = _waitingList
        .where((w) => w.isActive)
        .length;
    final urgentWaitingList = _waitingList
        .where((w) => w.priority == PriorityLevel.urgent && w.isActive)
        .length;

    final totalSchedules = _doctorSchedules.length;
    final availableSchedules = _doctorSchedules
        .where((s) => s.isAvailable)
        .length;

    return {
      'totalAppointments': totalAppointments,
      'scheduledAppointments': scheduledAppointments,
      'completedAppointments': completedAppointments,
      'cancelledAppointments': cancelledAppointments,
      'noShowAppointments': noShowAppointments,
      'urgentAppointments': urgentAppointments,
      'telemedicineAppointments': telemedicineAppointments,
      'totalWaitingList': totalWaitingList,
      'activeWaitingList': activeWaitingList,
      'urgentWaitingList': urgentWaitingList,
      'totalSchedules': totalSchedules,
      'availableSchedules': availableSchedules,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_appointments.isNotEmpty) return;

    // Add demo appointments
    final demoAppointments = [
      Appointment(
        id: 'apt_001',
        patientId: '1',
        doctorId: 'doctor_001',
        secretaryId: 'secretary_001',
        scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        duration: const Duration(minutes: 30),
        type: AppointmentType.consultation,
        status: AppointmentStatus.scheduled,
        priority: PriorityLevel.normal,
        notes: 'İlk konsültasyon',
        reason: 'Depresyon şikayeti',
        location: 'Oda 1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: 'apt_002',
        patientId: '2',
        doctorId: 'doctor_001',
        secretaryId: 'secretary_001',
        scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
        duration: const Duration(minutes: 45),
        type: AppointmentType.followUp,
        status: AppointmentStatus.scheduled,
        priority: PriorityLevel.high,
        notes: 'Takip randevusu',
        reason: 'Anksiyete tedavisi takibi',
        location: 'Oda 1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: 'apt_003',
        patientId: '3',
        doctorId: 'doctor_002',
        secretaryId: 'secretary_001',
        scheduledTime: DateTime.now().add(const Duration(days: 2, hours: 14)),
        duration: const Duration(minutes: 60),
        type: AppointmentType.therapy,
        status: AppointmentStatus.scheduled,
        priority: PriorityLevel.normal,
        notes: 'Terapi seansı',
        reason: 'Bilişsel davranışçı terapi',
        location: 'Oda 2',
        isTelemedicine: true,
        telemedicineLink: 'https://zoom.us/j/123456789',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    for (final appointment in demoAppointments) {
      _appointments.add(appointment);
    }

    await _saveAppointments();

    // Add demo waiting list
    final demoWaitingList = [
      WaitingList(
        id: 'wait_001',
        patientId: '4',
        doctorId: 'doctor_001',
        secretaryId: 'secretary_001',
        preferredType: AppointmentType.consultation,
        priority: PriorityLevel.high,
        requestedDate: DateTime.now().add(const Duration(days: 3)),
        preferredTime: 'Sabah',
        notes: 'Acil randevu gerekli',
        reason: 'Panik atak şikayeti',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    for (final waiting in demoWaitingList) {
      _waitingList.add(waiting);
    }

    await _saveWaitingList();

    // Add demo doctor schedules
    final demoSchedules = [
      DoctorSchedule(
        id: 'schedule_001',
        doctorId: 'doctor_001',
        startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 17)),
        location: 'Oda 1',
        notes: 'Normal çalışma saatleri',
        availableTypes: ['consultation', 'followUp', 'assessment'],
        defaultDuration: const Duration(minutes: 30),
      ),
      DoctorSchedule(
        id: 'schedule_002',
        doctorId: 'doctor_002',
        startTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
        endTime: DateTime.now().add(const Duration(days: 2, hours: 18)),
        location: 'Oda 2',
        notes: 'Terapi odası',
        availableTypes: ['therapy', 'group', 'consultation'],
        defaultDuration: const Duration(minutes: 60),
      ),
    ];

    for (final schedule in demoSchedules) {
      _doctorSchedules.add(schedule);
    }

    await _saveDoctorSchedules();

    print('✅ Demo secretary appointment data created:');
    print('   - Appointments: ${demoAppointments.length}');
    print('   - Waiting list: ${demoWaitingList.length}');
    print('   - Doctor schedules: ${demoSchedules.length}');
  }
}
