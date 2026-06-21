import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment_model.dart';
import '../utils/appointment_conflict.dart';
import 'data/telemetry_service.dart';
import 'notification_service.dart';

class AppointmentService {
  factory AppointmentService() => _instance;
  AppointmentService._internal();
  static final AppointmentService _instance = AppointmentService._internal();

  static const String _appointmentsKey = 'appointments';
  List<Appointment> _appointments = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadAppointments();
  }

  // Load appointments from storage
  Future<void> _loadAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];
      
      _appointments = appointmentsJson
          .map((json) =>
              Appointment.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      // HIGH-11 fix (audit 2026-06-21): debugPrint is a no-op in
      // release, so sync failures here used to disappear silently and
      // the UI silently presented an empty appointment list. Telemetry
      // surfaces the exception so a real user-facing problem can be
      // diagnosed without reproducing locally.
      await TelemetryService.instance.captureError(
        e,
        stack,
        hint: 'appointments_load',
      );
      _appointments = [];
    }
  }

  // Save appointments to storage
  Future<void> _saveAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = _appointments
          .map((appointment) => jsonEncode(appointment.toJson()))
          .toList();
      
      await prefs.setStringList(_appointmentsKey, appointmentsJson);
    } catch (e, stack) {
      await TelemetryService.instance.captureError(
        e,
        stack,
        hint: 'appointments_save',
      );
    }
  }

  // Get all appointments
  List<Appointment> getAllAppointments() {
    return List.unmodifiable(_appointments);
  }

  // Get appointments for a specific date
  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments.where((appointment) {
      return appointment.startTime.year == date.year &&
             appointment.startTime.month == date.month &&
             appointment.startTime.day == date.day;
    }).toList();
  }

  // Get upcoming appointments
  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((appointment) => appointment.startTime.isAfter(now))
        .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get today's appointments
  List<Appointment> getTodaysAppointments() {
    return _appointments.where((appointment) => appointment.isToday).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get appointments by status
  List<Appointment> getAppointmentsByStatus(String status) {
    return _appointments
        .where((appointment) => appointment.status == status)
        .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get appointment by ID
  Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((appointment) => appointment.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new appointment
  Future<bool> addAppointment(Appointment appointment) async {
    try {
      // Check for time conflicts
      if (_hasTimeConflict(appointment)) {
        throw Exception('Bu saatte başka bir randevu var');
    }
    
    _appointments.add(appointment);
      await _saveAppointments();
      // Bildirim planla
      await NotificationService().scheduleAppointmentReminders(
        appointmentId: appointment.id,
        title: 'Yaklaşan Randevu',
        body: '${appointment.clientName} - ${appointment.type}',
        startTime: appointment.startTime,
      );
      return true;
    } catch (e, stack) {
      await TelemetryService.instance.captureError(
        e,
        stack,
        hint: 'appointments_add',
      );
      return false;
    }
  }

  // Update appointment
  Future<bool> updateAppointment(Appointment updatedAppointment) async {
    try {
      final index = _appointments.indexWhere((appointment) => appointment.id == updatedAppointment.id);
    if (index == -1) {
      throw Exception('Randevu bulunamadı');
    }
    
      // Check for time conflicts (excluding the current appointment)
      if (_hasTimeConflict(updatedAppointment, excludeId: updatedAppointment.id)) {
        throw Exception('Bu saatte başka bir randevu var');
    }
    
    // Eski hatırlatmaları iptal et
    await NotificationService().cancelAppointmentReminders(_appointments[index].id);
    _appointments[index] = updatedAppointment;
      await _saveAppointments();
      // Yeni hatırlatmaları planla
      await NotificationService().scheduleAppointmentReminders(
        appointmentId: updatedAppointment.id,
        title: 'Güncellenen Randevu',
        body: '${updatedAppointment.clientName} - ${updatedAppointment.type}',
        startTime: updatedAppointment.startTime,
      );
      return true;
    } catch (e, stack) {
      await TelemetryService.instance.captureError(
        e,
        stack,
        hint: 'appointments_update',
      );
      return false;
    }
  }

  // Delete appointment
  Future<bool> deleteAppointment(String id) async {
    try {
      final index = _appointments.indexWhere((appointment) => appointment.id == id);
    if (index == -1) {
      throw Exception('Randevu bulunamadı');
    }
    
      await NotificationService().cancelAppointmentReminders(_appointments[index].id);
      _appointments.removeAt(index);
      await _saveAppointments();
      return true;
    } catch (e, stack) {
      await TelemetryService.instance.captureError(
        e,
        stack,
        hint: 'appointments_delete',
      );
      return false;
    }
  }

  // Check for time conflicts using the pure utility — keeps the rule
  // (half-open intervals, back-to-back OK) testable without bootstrapping
  // SharedPreferences.
  bool _hasTimeConflict(Appointment newAppointment, {String? excludeId}) =>
      hasAppointmentConflict(newAppointment, _appointments,
          excludeId: excludeId);

  // Get appointment statistics
  Map<String, int> getAppointmentStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month);

    final todaysAppointments = _appointments.where((a) => a.isToday).length;
    final thisWeekAppointments = _appointments.where((a) => 
        a.startTime.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        a.startTime.isBefore(weekStart.add(const Duration(days: 7)))
    ).length;
    final thisMonthAppointments = _appointments.where((a) => 
        a.startTime.isAfter(monthStart.subtract(const Duration(days: 1))) &&
        a.startTime.isBefore(DateTime(now.year, now.month + 1))
    ).length;
    final upcomingAppointments = _appointments.where((a) => a.isUpcoming).length;

    return {
      'today': todaysAppointments,
      'thisWeek': thisWeekAppointments,
      'thisMonth': thisMonthAppointments,
      'upcoming': upcomingAppointments,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_appointments.isNotEmpty) return; // Don't generate if data already exists
    
    final now = DateTime.now();
    final demoAppointments = [
      Appointment(
        id: '1',
        clientId: '1',
        clientName: 'Ahmet Yılmaz',
        startTime: DateTime(now.year, now.month, now.day, 10),
        endTime: DateTime(now.year, now.month, now.day, 11),
        type: 'Bireysel Terapi',
        status: 'Scheduled',
        notes: 'İlk seans - Anksiyete değerlendirmesi',
        location: 'Ofis 1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: '2',
        clientId: '2',
        clientName: 'Fatma Kaya',
        startTime: DateTime(now.year, now.month, now.day, 14),
        endTime: DateTime(now.year, now.month, now.day, 15),
        type: 'Bireysel Terapi',
        status: 'Scheduled',
        notes: 'Depresyon tedavisi - 3. seans',
        location: 'Ofis 1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Appointment(
        id: '3',
        clientId: '3',
        clientName: 'Mehmet Demir',
        startTime: DateTime(now.year, now.month, now.day + 1, 9),
        endTime: DateTime(now.year, now.month, now.day + 1, 10),
        type: 'Bireysel Terapi',
        status: 'Scheduled',
        notes: 'PTSD tedavisi - 2. seans',
        location: 'Ofis 2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _appointments.addAll(demoAppointments);
    await _saveAppointments();
  }
}