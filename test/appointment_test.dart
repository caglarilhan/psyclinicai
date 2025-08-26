import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/appointment_service.dart';
import 'package:psyclinicai/models/appointment_models.dart';

void main() {
  group('AppointmentService Tests', () {
    late AppointmentService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = AppointmentService();
    });

    group('Initialization', () {
      test('should create instance and initialize', () async {
        expect(service, isNotNull);
        await service.initialize();
        expect(true, isTrue);
      });
    });

    group('Create Appointment', () {
      test('should create in-person initial session with default reminders', () async {
        await service.initialize();
        final start = DateTime.now().add(const Duration(days: 1));
        final appt = await service.createAppointment(
          clientId: 'client_1',
          therapistId: 'ther_1',
          startTime: start,
          durationMinutes: 50,
          title: 'Initial Assessment',
          isFirstSession: true,
          requiresPreAssessment: true,
        );

        expect(appt.id, isNotEmpty);
        expect(appt.clientId, 'client_1');
        expect(appt.therapistId, 'ther_1');
        expect(appt.location, 'Office');
        expect(appt.modality, 'in-person');
        expect(appt.status, AppointmentStatus.scheduled);
        expect(appt.reminders, isNotEmpty);
        expect(appt.endTime.difference(appt.startTime).inMinutes, 50);
      });

      test('should create video follow-up with custom reminders and recurrence', () async {
        await service.initialize();
        final start = DateTime.now().add(const Duration(days: 7));
        final appt = await service.createAppointment(
          clientId: 'client_2',
          therapistId: 'ther_1',
          startTime: start,
          durationMinutes: 45,
          location: 'Video',
          modality: 'video',
          title: 'Follow-up Session',
          reminders: [
            AppointmentReminder(
              id: 'rem1',
              appointmentId: 'temp',
              channel: ReminderChannel.email,
              offset: const Duration(hours: 24),
              isEnabled: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              metadata: {},
            ),
          ],
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly, interval: 1, count: 6),
        );

        expect(appt.modality, 'video');
        expect(appt.location, 'Video');
        expect(appt.recurrence, isNotNull);
        expect(appt.reminders.length, 1);
        expect(appt.title, 'Follow-up Session');
      });
    });

    group('List Appointments', () {
      test('should list therapist appointments in date range sorted', () async {
        await service.initialize();
        final now = DateTime.now();
        await service.createAppointment(
          clientId: 'c1',
          therapistId: 'ther_list',
          startTime: now.add(const Duration(days: 2)),
          durationMinutes: 50,
        );
        await service.createAppointment(
          clientId: 'c2',
          therapistId: 'ther_list',
          startTime: now.add(const Duration(days: 1)),
          durationMinutes: 50,
        );
        await service.createAppointment(
          clientId: 'c3',
          therapistId: 'ther_list',
          startTime: now.add(const Duration(days: 3)),
          durationMinutes: 50,
        );

        final list = await service.listTherapistAppointments(
          'ther_list',
          from: now.add(const Duration(hours: 12)),
          to: now.add(const Duration(days: 4)),
        );

        expect(list, isNotEmpty);
        expect(list.length, 3);
        expect(list[0].startTime.isBefore(list[1].startTime), isTrue);
        expect(list[1].startTime.isBefore(list[2].startTime), isTrue);
      });
    });

    group('No-show Prediction', () {
      test('should predict no-show risk', () async {
        await service.initialize();
        final appt = await service.createAppointment(
          clientId: 'risk_client',
          therapistId: 'ther_risk',
          startTime: DateTime.now().add(const Duration(days: 2)),
          durationMinutes: 50,
          isFirstSession: true,
        );

        final pred = await service.predictNoShow(appt.id);
        expect(pred.appointmentId, appt.id);
        expect(pred.riskScore, inInclusiveRange(0, 1));
        expect(pred.riskFactors, isNotEmpty);
        expect(pred.modelVersion, isNotEmpty);
      });
    });

    group('Reminders', () {
      test('should schedule reminders and emit stream', () async {
        await service.initialize();
        final appt = await service.createAppointment(
          clientId: 'c_rem',
          therapistId: 't_rem',
          startTime: DateTime.now().add(const Duration(days: 1)),
          durationMinutes: 50,
        );

        final reminders = [
          AppointmentReminder(
            id: 'r1',
            appointmentId: appt.id,
            channel: ReminderChannel.sms,
            offset: const Duration(hours: 24),
            isEnabled: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            metadata: {},
          ),
          AppointmentReminder(
            id: 'r2',
            appointmentId: appt.id,
            channel: ReminderChannel.push,
            offset: const Duration(hours: 2),
            isEnabled: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            metadata: {},
          ),
        ];

        final stream = service.reminderStream;
        final received = <AppointmentReminder>[];
        final sub = stream.listen(received.add);

        final saved = await service.scheduleReminders(appt.id, reminders);
        await Future.delayed(const Duration(milliseconds: 50));
        await sub.cancel();

        expect(saved.length, 2);
        expect(received.length, greaterThanOrEqualTo(2));
      });
    });

    group('Calendar Settings', () {
      test('should get and set calendar settings', () async {
        await service.initialize();
        final initial = await service.getCalendarSettings('ther_cal');
        expect(initial.therapistId, 'ther_cal');
        expect(initial.googleCalendarEnabled, isTrue);

        final updated = await service.setCalendarSettings(CalendarIntegrationSetting(
          therapistId: 'ther_cal',
          googleCalendarEnabled: false,
          appleCalendarEnabled: true,
          outlookCalendarEnabled: false,
          timezone: 'America/New_York',
          defaultSessionMinutes: 60,
          autoConfirm: false,
          metadata: {'note': 'updated'},
          updatedAt: DateTime.now(),
        ));

        expect(updated.googleCalendarEnabled, isFalse);
        expect(updated.appleCalendarEnabled, isTrue);
        expect(updated.defaultSessionMinutes, 60);
        expect(updated.autoConfirm, isFalse);
      });
    });

    group('Streams', () {
      test('should provide streams', () async {
        expect(service.appointmentStream, isNotNull);
        expect(service.reminderStream, isNotNull);
        expect(service.noShowStream, isNotNull);
      });
    });
  });
}
