import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/group_session.dart';

void main() {
  group('GroupSession model', () {
    test('roster cap is enforced at construction', () {
      final tooMany = List.generate(
        9,
        (i) => GroupSessionAttendance(
          patientId: 'p$i',
          subNoteId: 'n$i',
        ),
      );

      expect(
        () => GroupSession(
          id: 'g1',
          clinicId: 'c1',
          modalityLabel: 'DBT skills group',
          scheduledAt: DateTime(2026, 6, 5),
          roster: tooMany,
        ),
        // ArgumentError — survives `flutter build --release` (asserts
        // are stripped). Patient safety: never a silent 30-pt roster.
        throwsA(isA<ArgumentError>()),
      );
    });

    test('isAtCapacity flips at the cap', () {
      final atCap = GroupSession(
        id: 'g2',
        clinicId: 'c1',
        modalityLabel: 'CBT relapse group',
        scheduledAt: DateTime(2026, 6, 5),
        roster: List.generate(
          GroupSession.maxRosterSize,
          (i) => GroupSessionAttendance(
            patientId: 'p$i',
            subNoteId: 'n$i',
          ),
        ),
      );
      expect(atCap.isAtCapacity, isTrue);
    });

    test('clinicianOnlyPatientIds is order-preserving and roster-only', () {
      final g = GroupSession(
        id: 'g3',
        clinicId: 'c1',
        modalityLabel: 'ACT',
        scheduledAt: DateTime(2026, 6, 5),
        roster: const [
          GroupSessionAttendance(patientId: 'p-alpha', subNoteId: 'n1'),
          GroupSessionAttendance(patientId: 'p-beta', subNoteId: 'n2'),
        ],
      );
      expect(g.clinicianOnlyPatientIds, ['p-alpha', 'p-beta']);
    });

    test('round-trips through JSON', () {
      final g = GroupSession(
        id: 'g4',
        clinicId: 'c1',
        modalityLabel: 'IPT',
        scheduledAt: DateTime.utc(2026, 6, 10, 14),
        roster: const [
          GroupSessionAttendance(
            patientId: 'p1',
            subNoteId: 'n1',
            attended: true,
            notes: 'arrived 10 min late',
          ),
        ],
        facilitatorNote: 'opened with grounding exercise',
        status: GroupSessionStatus.inProgress,
      );

      final round = GroupSession.fromJson(g.toJson());

      expect(round.id, g.id);
      expect(round.modalityLabel, g.modalityLabel);
      expect(round.roster.length, 1);
      expect(round.roster.first.attended, isTrue);
      expect(round.roster.first.notes, 'arrived 10 min late');
      expect(round.status, GroupSessionStatus.inProgress);
    });

    test('status fromId falls back to scheduled on unknown id', () {
      expect(
        GroupSessionStatus.fromId('garbage'),
        GroupSessionStatus.scheduled,
      );
      expect(
        GroupSessionStatus.fromId(null),
        GroupSessionStatus.scheduled,
      );
    });
  });
}
