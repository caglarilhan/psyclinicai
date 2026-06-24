/// Coverage for FamilySessionNote — approach/subsystem enums,
/// JSON round-trip, isComplete gate, and the envelope integration
/// with `ModalitySessionRepository` (ModalityKind.family).
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/modalities/family_session_note.dart';
import 'package:psyclinicai/services/data/modality_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fssChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

FamilySessionNote _note({
  String id = 'fs1',
  FamilyTherapyApproach approach = FamilyTherapyApproach.bowen,
  FamilySubsystem subsystem = FamilySubsystem.couple,
  String genogramId = '',
  List<String> attendees = const [],
  String presentingDynamic = 'Triangulation between partner A, B, child',
  String interventions = 'Differentiation prompts',
  String homework = '',
  int relationalShift = 6,
}) => FamilySessionNote(
  id: id,
  patientId: 'p1',
  clinicianId: 'c1',
  sessionDate: DateTime.utc(2026, 6, 23, 10),
  approach: approach,
  subsystem: subsystem,
  attendees: attendees,
  genogramId: genogramId,
  presentingDynamic: presentingDynamic,
  interventions: interventions,
  homework: homework,
  relationalShift: relationalShift,
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

  group('FamilySessionNote model', () {
    test('isComplete fires when dynamic or interventions has content', () {
      expect(
        _note(presentingDynamic: '', interventions: '').isComplete,
        isFalse,
      );
      expect(
        _note(presentingDynamic: 'enmeshment', interventions: '').isComplete,
        isTrue,
      );
      expect(
        _note(presentingDynamic: '', interventions: 'unbalancing').isComplete,
        isTrue,
      );
    });

    test('hasShiftRecorded gates outcomes filter', () {
      expect(_note(relationalShift: 0).hasShiftRecorded, isFalse);
      expect(_note(relationalShift: 1).hasShiftRecorded, isTrue);
    });

    test('relationalShift clamps 0-10 on fromJson', () {
      final back = FamilySessionNote.fromJson({
        'id': 'clamp',
        'patientId': 'p1',
        'clinicianId': 'c1',
        'sessionDate': '2026-06-23T10:00:00Z',
        'relationalShift': 42,
      });
      expect(back.relationalShift, 10);
    });

    test('round-trips approach / subsystem / attendees / genogramId', () {
      final n = _note(
        approach: FamilyTherapyApproach.structural,
        subsystem: FamilySubsystem.parentChild,
        attendees: const ['self', 'mother', 'father'],
        genogramId: 'g42',
        homework: 'Boundary plan',
      );
      final back = FamilySessionNote.fromJson(n.toJson());
      expect(back.approach, FamilyTherapyApproach.structural);
      expect(back.subsystem, FamilySubsystem.parentChild);
      expect(back.attendees, ['self', 'mother', 'father']);
      expect(back.genogramId, 'g42');
      expect(back.homework, 'Boundary plan');
    });

    test('FamilyTherapyApproach.fromId falls back to integrative', () {
      expect(
        FamilyTherapyApproach.fromId('bogus'),
        FamilyTherapyApproach.integrative,
      );
      expect(
        FamilyTherapyApproach.fromId('eft'),
        FamilyTherapyApproach.emotionallyFocused,
      );
    });
  });

  group('ModalitySessionRepository envelope (family kind)', () {
    test('round-trips a family note through the tagged envelope', () {
      final n = _note(genogramId: 'g7');
      final envelope = ModalityRecord(kind: ModalityKind.family, payload: n);
      final json = envelope.toJson();
      expect(json['type'], 'family');
      final back = ModalityRecord.fromJson(json);
      expect(back.kind, ModalityKind.family);
      expect(back.familySessionNote, isNotNull);
      expect(back.familySessionNote!.genogramId, 'g7');
      expect(back.patientId, 'p1');
      expect(back.id, 'fs1');
      expect(back.sortDate, DateTime.utc(2026, 6, 23, 10));
    });

    test(
      'repo upsert + cross-modality fetch returns the family note',
      () async {
        final repo = ModalitySessionRepository(storageKey: 'modality_fam_rt');
        await repo.initialize();
        await repo.upsert(
          ModalityRecord(kind: ModalityKind.family, payload: _note()),
        );
        final fresh = ModalitySessionRepository(storageKey: 'modality_fam_rt');
        await fresh.initialize();
        final list = fresh.forPatient('p1');
        expect(list, hasLength(1));
        expect(list.first.kind, ModalityKind.family);
      },
    );
  });
}
