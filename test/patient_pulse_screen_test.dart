/// Widget coverage for PatientPulseScreen — renders the overall
/// chip + all four signal tiles, and the overall chip reflects
/// the worst-of-four signal.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/feedback_rating.dart';
import 'package:psyclinicai/models/medication_dose_log.dart';
import 'package:psyclinicai/screens/outcomes/patient_pulse_screen.dart';
import 'package:psyclinicai/services/data/feedback_rating_repository.dart';
import 'package:psyclinicai/services/data/medication_dose_repository.dart';
import 'package:psyclinicai/services/data/medication_side_effect_repository.dart';
import 'package:psyclinicai/services/data/vanderbilt_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fssChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

Future<void> _pump(WidgetTester tester, Widget screen) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1600));
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(home: screen),
    ),
  );
}

FeedbackRating _ors(int total, DateTime at, {String patientId = 'p1'}) {
  final share = total ~/ 4;
  final rem = total - share * 4;
  final v0 = (share + rem).clamp(0, 10);
  return FeedbackRating(
    id: 'ors-${at.millisecondsSinceEpoch}',
    sessionId: 's1',
    patientId: patientId,
    clinicianId: 'c1',
    capturedAt: at,
    kind: FitKind.ors,
    scores: {
      FitItem.orsIndividual: v0,
      FitItem.orsInterpersonal: share.clamp(0, 10),
      FitItem.orsSocial: share.clamp(0, 10),
      FitItem.orsOverall: share.clamp(0, 10),
    },
  );
}

MedicationDoseLog _dose(String id, DoseStatus s, DateTime when) =>
    MedicationDoseLog(
      id: id,
      patientId: 'p1',
      medicationId: 'm1',
      scheduledAt: when,
      status: s,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final backing = <String, String>{};
    messenger.setMockMethodCallHandler(_fssChannel, (call) async {
      switch (call.method) {
        case 'read':
          return backing[(call.arguments as Map)['key'] as String];
        case 'write':
          final a = call.arguments as Map;
          backing[a['key'] as String] = a['value'] as String;
          return null;
        case 'delete':
          backing.remove((call.arguments as Map)['key'] as String);
          return null;
        case 'containsKey':
          return backing.containsKey((call.arguments as Map)['key'] as String);
        case 'deleteAll':
          backing.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(backing);
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(_fssChannel, null);
  });

  testWidgets('renders overall chip + all four signal tiles', (tester) async {
    final fitRepo = FeedbackRatingRepository(storageKey: 'pps_fit');
    final doseRepo = MedicationDoseRepository(storageKey: 'pps_dose');
    final seRepo = MedicationSideEffectRepository(storageBucket: 'pps_se');
    final vbRepo = VanderbiltRepository(storageKey: 'pps_vb');
    await Future.wait([
      fitRepo.initialize(),
      doseRepo.initialize(),
      seRepo.initialize(),
      vbRepo.initialize(),
    ]);

    await _pump(
      tester,
      PatientPulseScreen(
        patientId: 'p1',
        patientName: 'Test Patient',
        fitRepo: fitRepo,
        doseRepo: doseRepo,
        seRepo: seRepo,
        vbRepo: vbRepo,
        now: DateTime.utc(2026, 6, 23, 12),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Test Patient'), findsOneWidget);
    expect(find.text('Alliance and outcome (FIT)'), findsOneWidget);
    expect(find.text('Medication adherence (MAR)'), findsOneWidget);
    expect(find.text('Tolerability (side effects)'), findsOneWidget);
    expect(find.text('ADHD subtype (Vanderbilt)'), findsOneWidget);
  });

  testWidgets('overall chip shows Needs attention when ORS below cutoff', (
    tester,
  ) async {
    final fitRepo = FeedbackRatingRepository(storageKey: 'pps_concern_fit');
    await fitRepo.initialize();
    await fitRepo.save(_ors(20, DateTime.utc(2026, 6, 22)));

    final doseRepo = MedicationDoseRepository(storageKey: 'pps_concern_dose');
    final seRepo = MedicationSideEffectRepository(
      storageBucket: 'pps_concern_se',
    );
    final vbRepo = VanderbiltRepository(storageKey: 'pps_concern_vb');
    await Future.wait([
      doseRepo.initialize(),
      seRepo.initialize(),
      vbRepo.initialize(),
    ]);

    await _pump(
      tester,
      PatientPulseScreen(
        patientId: 'p1',
        fitRepo: fitRepo,
        doseRepo: doseRepo,
        seRepo: seRepo,
        vbRepo: vbRepo,
        now: DateTime.utc(2026, 6, 23, 12),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Overall: Needs attention'), findsOneWidget);
  });

  testWidgets('overall chip shows Watch when only ADHD signal is missing', (
    tester,
  ) async {
    final fitRepo = FeedbackRatingRepository(storageKey: 'pps_watch_fit');
    await fitRepo.initialize();
    await fitRepo.save(_ors(36, DateTime.utc(2026, 6, 22)));

    final doseRepo = MedicationDoseRepository(storageKey: 'pps_watch_dose');
    await doseRepo.initialize();
    for (var i = 0; i < 10; i++) {
      await doseRepo.upsert(
        _dose(
          'd$i',
          DoseStatus.taken,
          DateTime.utc(2026, 6, 23, 12).subtract(Duration(days: i + 1)),
        ),
      );
    }

    final seRepo = MedicationSideEffectRepository(
      storageBucket: 'pps_watch_se',
    );
    await seRepo.initialize();

    final vbRepo = VanderbiltRepository(storageKey: 'pps_watch_vb');
    await vbRepo.initialize();

    await _pump(
      tester,
      PatientPulseScreen(
        patientId: 'p1',
        fitRepo: fitRepo,
        doseRepo: doseRepo,
        seRepo: seRepo,
        vbRepo: vbRepo,
        now: DateTime.utc(2026, 6, 23, 12),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Overall: Watch'), findsOneWidget);
  });
}
