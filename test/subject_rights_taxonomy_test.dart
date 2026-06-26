import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/subject_rights_taxonomy.dart';

void main() {
  group('SubjectRightsTaxonomy — coverage + invariants', () {
    test('every SubjectRightKind has exactly one pinned record', () {
      final pinned = SubjectRightsTaxonomy.rights.map((r) => r.kind).toSet();
      expect(
        pinned,
        equals(SubjectRightKind.values.toSet()),
        reason:
            'enum/taxonomy drift — adding a SubjectRightKind requires '
            'adding its pinned record here',
      );
      expect(
        SubjectRightsTaxonomy.rights.length,
        SubjectRightKind.values.length,
        reason: 'duplicate record for a right',
      );
    });

    test('forKind resolves every enum value', () {
      for (final k in SubjectRightKind.values) {
        expect(SubjectRightsTaxonomy.forKind(k)?.kind, k);
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in SubjectRightsTaxonomy.rights) {
        expect(r.label, isNotEmpty, reason: r.kind.name);
        expect(r.responseOwner, isNotEmpty, reason: r.kind.name);
        expect(
          r.responseTemplateId,
          startsWith('rights_response_'),
          reason: r.kind.name,
        );
        expect(
          r.auditEntryKind,
          startsWith('subject_rights.'),
          reason: r.kind.name,
        );
        expect(r.auditEntryKind, endsWith('.completed'), reason: r.kind.name);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.kind.name);
      }
    });

    test(
      'every right honours the GDPR Art. 12(3) one-month statutory floor',
      () {
        for (final r in SubjectRightsTaxonomy.rights) {
          expect(
            r.statutoryDeadlineDays,
            lessThanOrEqualTo(30),
            reason:
                '${r.kind.name}: statutoryDeadlineDays > 30 violates the '
                'GDPR Art. 12(3) one-month floor.',
          );
        }
      },
    );

    test('internalTargetDays < statutoryDeadlineDays for every right', () {
      for (final r in SubjectRightsTaxonomy.rights) {
        expect(
          r.internalTargetDays,
          lessThan(r.statutoryDeadlineDays),
          reason:
              '${r.kind.name}: internal target must be tighter than the '
              'statutory deadline so legal has buffer.',
        );
      }
    });

    test(
      'every right requires identity verification (Recital 64 / md. 13)',
      () {
        for (final r in SubjectRightsTaxonomy.rights) {
          expect(
            r.requiresIdentityVerification,
            isTrue,
            reason:
                '${r.kind.name}: every right MUST gate on identity '
                'verification to prevent unauthorised disclosure.',
          );
        }
      },
    );

    test('automated-decision right has the tightest internal target (Art. 22 '
        'urgency)', () {
      final auto = SubjectRightsTaxonomy.forKind(
        SubjectRightKind.automatedDecision,
      )!;
      for (final r in SubjectRightsTaxonomy.rights) {
        if (r.kind == SubjectRightKind.automatedDecision) continue;
        expect(
          auto.internalTargetDays,
          lessThanOrEqualTo(r.internalTargetDays),
          reason:
              'automatedDecision must clear faster than ${r.kind.name} '
              '— human review of automated decisions is time-sensitive',
        );
      }
    });

    test('erasure right cites both GDPR Art. 17 and KVKK md. 7', () {
      final erasure = SubjectRightsTaxonomy.forKind(SubjectRightKind.erasure)!;
      final blob = erasure.regulatoryRefs.join(' | ');
      expect(blob, contains('GDPR Art. 17'));
      expect(blob, contains('KVKK md. 7'));
    });

    test('every audit entry kind is unique', () {
      final kinds = SubjectRightsTaxonomy.rights
          .map((r) => r.auditEntryKind)
          .toList();
      expect(
        kinds.toSet().length,
        kinds.length,
        reason: 'duplicate audit entry kind would alias trail entries',
      );
    });
  });

  group('daysUntilStatutoryDeadline', () {
    test('positive when deadline is in the future', () {
      final r = SubjectRightsTaxonomy.forKind(SubjectRightKind.access)!;
      expect(
        daysUntilStatutoryDeadline(
          record: r,
          filedIso: '2026-06-01',
          today: DateTime.parse('2026-06-15'),
        ),
        16, // 30 - 14
      );
    });

    test('zero on the deadline day', () {
      final r = SubjectRightsTaxonomy.forKind(SubjectRightKind.access)!;
      expect(
        daysUntilStatutoryDeadline(
          record: r,
          filedIso: '2026-06-01',
          today: DateTime.parse('2026-07-01'),
        ),
        0,
      );
    });

    test('negative when overdue', () {
      final r = SubjectRightsTaxonomy.forKind(SubjectRightKind.access)!;
      expect(
        daysUntilStatutoryDeadline(
          record: r,
          filedIso: '2026-06-01',
          today: DateTime.parse('2026-07-10'),
        ),
        -9,
      );
    });
  });

  group('isWithinInternalTarget', () {
    test('true on the target day itself', () {
      final r = SubjectRightsTaxonomy.forKind(SubjectRightKind.access)!;
      expect(
        isWithinInternalTarget(
          record: r,
          filedIso: '2026-06-01',
          today: DateTime.parse('2026-06-15'), // 14 days in
        ),
        isTrue,
      );
    });

    test('false the day after the target elapses', () {
      final r = SubjectRightsTaxonomy.forKind(SubjectRightKind.access)!;
      expect(
        isWithinInternalTarget(
          record: r,
          filedIso: '2026-06-01',
          today: DateTime.parse('2026-06-16'), // 15 days in
        ),
        isFalse,
      );
    });
  });
}
