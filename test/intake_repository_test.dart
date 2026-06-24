/// Coverage for the SecurePrefs-backed IntakeRepository. The repo
/// holds PHI (demographics, allergies, meds, signed consent) so the
/// round-trip needs to pin both the JSON shape AND the secure-prefs
/// key id used to store it. A future migration that drops the
/// existing storage namespace would silently lose every recorded
/// intake — this test makes that loud.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/patient_intake.dart';
import 'package:psyclinicai/services/data/intake_repository.dart';
import 'package:psyclinicai/services/data/secure_prefs.dart';

const _channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late Map<String, String> backing;

  setUp(() {
    backing = <String, String>{};
    messenger.setMockMethodCallHandler(_channel, (call) async {
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
    messenger.setMockMethodCallHandler(_channel, null);
    SecurePrefs.setInstanceForTest(null);
  });

  PatientIntake sample({String id = 'demo-1'}) => PatientIntake(
    patientId: id,
    fullName: 'Demo Patient',
    presentingConcern: 'mild depressive episode',
    allergies: const <String>['none'],
    currentMedications: const <String>['sertraline 50mg'],
  );

  test('fresh device reports no intake for any patient', () async {
    final repo = IntakeRepository();
    await repo.initialize();
    expect(repo.forPatient('demo-1'), isNull);
    expect(repo.all, isEmpty);
  });

  test(
    'save then re-init round-trips a PatientIntake via SecurePrefs',
    () async {
      final first = IntakeRepository();
      await first.initialize();
      await first.save(sample());

      // New repo instance, same SecurePrefs backing → must observe the
      // round-trip from disk (not from the in-memory cache).
      SecurePrefs.setInstanceForTest(null);
      final fresh = IntakeRepository();
      await fresh.initialize();
      final loaded = fresh.forPatient('demo-1');
      expect(loaded, isNotNull);
      expect(loaded!.patientId, 'demo-1');
      expect(loaded.presentingConcern, 'mild depressive episode');
      expect(loaded.currentMedications, contains('sertraline 50mg'));
    },
  );

  test(
    'the SecurePrefs key id is "patient_intakes" (PHI namespace lock)',
    () async {
      final repo = IntakeRepository();
      await repo.initialize();
      await repo.save(sample());
      expect(
        backing.keys,
        contains('patient_intakes'),
        reason:
            'Migration must not drop the existing storage namespace — '
            'changing this key would orphan every previously-recorded '
            'intake on real devices.',
      );
    },
  );
}
