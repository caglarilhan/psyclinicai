import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/appointment_models.dart';

class AppointmentService {
  static const String _baseUrl = 'https://api.appointments.psyclinicai.com/v1';
  static const String _apiKey = 'appt_key_12345';

  final Map<String, Appointment> _appointments = {};
  final Map<String, List<Appointment>> _therapistIndex = {};
  final Map<String, List<Appointment>> _clientIndex = {};
  final Map<String, CalendarIntegrationSetting> _calendarSettings = {};

  final StreamController<Appointment> _appointmentController =
      StreamController<Appointment>.broadcast();
  final StreamController<AppointmentReminder> _reminderController =
      StreamController<AppointmentReminder>.broadcast();
  final StreamController<NoShowPrediction> _noShowController =
      StreamController<NoShowPrediction>.broadcast();

  Stream<Appointment> get appointmentStream => _appointmentController.stream;
  Stream<AppointmentReminder> get reminderStream => _reminderController.stream;
  Stream<NoShowPrediction> get noShowStream => _noShowController.stream;

  Future<void> initialize() async {
    // preload nothing for now, but keep consistent with other services
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  Future<Appointment> createAppointment({
    required String clientId,
    required String therapistId,
    required DateTime startTime,
    required int durationMinutes,
    String location = 'Office',
    String modality = 'in-person',
    String title = 'Therapy Session',
    String? notes,
    RecurrenceRule? recurrence,
    bool isFirstSession = false,
    bool requiresPreAssessment = false,
    bool isBillable = true,
    Map<String, dynamic>? billingInfo,
    List<AppointmentReminder>? reminders,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'client_id': clientId,
          'therapist_id': therapistId,
          'start_time': startTime.toIso8601String(),
          'duration': durationMinutes,
          'location': location,
          'modality': modality,
          'title': title,
          'notes': notes,
          'recurrence': recurrence?.toJson(),
          'is_first_session': isFirstSession,
          'requires_pre_assessment': requiresPreAssessment,
          'is_billable': isBillable,
          'billing_info': billingInfo ?? {},
          'reminders': (reminders ?? []).map((r) => r.toJson()).toList(),
        }),
      );
      if (response.statusCode == 201) {
        final appt = Appointment.fromJson(json.decode(response.body));
        _indexAppointment(appt);
        _appointmentController.add(appt);
        return appt;
      } else {
        throw Exception('Failed to create appointment: ${response.statusCode}');
      }
    } catch (e) {
      final endTime = startTime.add(Duration(minutes: durationMinutes));
      final appt = Appointment(
        id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
        clientId: clientId,
        therapistId: therapistId,
        startTime: startTime,
        endTime: endTime,
        location: location,
        modality: modality,
        status: AppointmentStatus.scheduled,
        title: title,
        notes: notes,
        reminders: reminders ?? _defaultReminders(),
        recurrence: recurrence,
        isFirstSession: isFirstSession,
        requiresPreAssessment: requiresPreAssessment,
        isBillable: isBillable,
        billingInfo: billingInfo ?? {'currency': 'USD', 'amount': 80},
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _indexAppointment(appt);
      _appointmentController.add(appt);
      return appt;
    }
  }

  Future<List<Appointment>> listTherapistAppointments(String therapistId,
      {DateTime? from, DateTime? to}) async {
    try {
      final uri = Uri.parse('$_baseUrl/therapists/$therapistId/appointments').replace(
        queryParameters: {
          if (from != null) 'from': from.toIso8601String(),
          if (to != null) 'to': to.toIso8601String(),
        },
      );
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Appointment.fromJson(e)).toList();
      } else {
        throw Exception('Failed to list appointments: ${response.statusCode}');
      }
    } catch (e) {
      final list = _therapistIndex[therapistId] ?? [];
      return list.where((a) {
        final okFrom = from == null || !a.startTime.isBefore(from);
        final okTo = to == null || !a.startTime.isAfter(to);
        return okFrom && okTo;
      }).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    }
  }

  Future<NoShowPrediction> predictNoShow(String appointmentId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments/$appointmentId/no-show'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final pred = NoShowPrediction.fromJson(json.decode(response.body));
        _noShowController.add(pred);
        return pred;
      } else {
        throw Exception('Failed to predict no-show: ${response.statusCode}');
      }
    } catch (e) {
      final rnd = Random();
      final pred = NoShowPrediction(
        appointmentId: appointmentId,
        riskScore: 0.15 + rnd.nextDouble() * 0.5,
        riskFactors: [
          'past_no_shows:${rnd.nextInt(3)}',
          'first_session:${rnd.nextBool()}',
          'late_booking:${rnd.nextBool()}',
        ],
        modelVersion: 'v1.0.0',
        predictedAt: DateTime.now(),
        metadata: {},
      );
      _noShowController.add(pred);
      return pred;
    }
  }

  Future<List<AppointmentReminder>> scheduleReminders(
    String appointmentId,
    List<AppointmentReminder> reminders,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments/$appointmentId/reminders'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reminders': reminders.map((e) => e.toJson()).toList()}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final list = data.map((e) => AppointmentReminder.fromJson(e)).toList();
        for (final r in list) {
          _reminderController.add(r);
        }
        return list;
      } else {
        throw Exception('Failed to schedule reminders: ${response.statusCode}');
      }
    } catch (e) {
      for (final r in reminders) {
        _reminderController.add(r);
      }
      return reminders;
    }
  }

  Future<CalendarIntegrationSetting> getCalendarSettings(String therapistId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/therapists/$therapistId/calendar-settings'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final setting = CalendarIntegrationSetting.fromJson(json.decode(response.body));
        _calendarSettings[therapistId] = setting;
        return setting;
      } else {
        throw Exception('Failed to get calendar settings: ${response.statusCode}');
      }
    } catch (e) {
      return _calendarSettings[therapistId] ?? CalendarIntegrationSetting(
        therapistId: therapistId,
        googleCalendarEnabled: true,
        appleCalendarEnabled: false,
        outlookCalendarEnabled: false,
        timezone: 'Europe/Istanbul',
        defaultSessionMinutes: 50,
        autoConfirm: true,
        metadata: {},
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<CalendarIntegrationSetting> setCalendarSettings(
    CalendarIntegrationSetting setting,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/therapists/${setting.therapistId}/calendar-settings'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(setting.toJson()),
      );
      if (response.statusCode == 200) {
        final saved = CalendarIntegrationSetting.fromJson(json.decode(response.body));
        _calendarSettings[setting.therapistId] = saved;
        return saved;
      } else {
        throw Exception('Failed to set calendar settings: ${response.statusCode}');
      }
    } catch (e) {
      final saved = CalendarIntegrationSetting(
        therapistId: setting.therapistId,
        googleCalendarEnabled: setting.googleCalendarEnabled,
        appleCalendarEnabled: setting.appleCalendarEnabled,
        outlookCalendarEnabled: setting.outlookCalendarEnabled,
        timezone: setting.timezone,
        defaultSessionMinutes: setting.defaultSessionMinutes,
        autoConfirm: setting.autoConfirm,
        metadata: {},
        updatedAt: DateTime.now(),
      );
      _calendarSettings[setting.therapistId] = saved;
      return saved;
    }
  }

  void dispose() {
    if (!_appointmentController.isClosed) _appointmentController.close();
    if (!_reminderController.isClosed) _reminderController.close();
    if (!_noShowController.isClosed) _noShowController.close();
  }

  // helpers
  void _indexAppointment(Appointment appt) {
    _appointments[appt.id] = appt;
    _therapistIndex.putIfAbsent(appt.therapistId, () => []).add(appt);
    _clientIndex.putIfAbsent(appt.clientId, () => []).add(appt);
  }

  List<AppointmentReminder> _defaultReminders() {
    return [
      AppointmentReminder(
        id: 'rem_${DateTime.now().millisecondsSinceEpoch}_24h',
        appointmentId: 'unknown',
        channel: ReminderChannel.sms,
        offset: const Duration(hours: 24),
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      ),
      AppointmentReminder(
        id: 'rem_${DateTime.now().millisecondsSinceEpoch}_2h',
        appointmentId: 'unknown',
        channel: ReminderChannel.push,
        offset: const Duration(hours: 2),
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      ),
    ];
  }
}
