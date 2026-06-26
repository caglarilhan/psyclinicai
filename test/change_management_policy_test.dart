import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/change_management_policy.dart';

void main() {
  group('ChangeManagementPolicy — class parity + invariants', () {
    test('every ChangeClass has exactly one pinned record', () {
      final pinned = ChangeManagementPolicy.classes
          .map((p) => p.changeClass)
          .toSet();
      expect(pinned, equals(ChangeClass.values.toSet()));
      expect(
        ChangeManagementPolicy.classes.length,
        ChangeClass.values.length,
        reason: 'duplicate record for a class',
      );
    });

    test('forClass resolves every enum value', () {
      for (final c in ChangeClass.values) {
        expect(ChangeManagementPolicy.forClass(c).changeClass, c);
      }
    });

    test('every record has populated fields + anchors', () {
      for (final p in ChangeManagementPolicy.classes) {
        expect(p.label, isNotEmpty, reason: p.changeClass.name);
        expect(p.exampleChanges, isNotEmpty, reason: p.changeClass.name);
        expect(p.minReviewers, greaterThan(0), reason: p.changeClass.name);
        expect(p.maxLeadTimeHours, greaterThan(0), reason: p.changeClass.name);
        expect(p.evidencePath, isNotEmpty, reason: p.changeClass.name);
        expect(p.regulatoryRefs, isNotEmpty, reason: p.changeClass.name);
      }
    });

    test(
      'locked surface REQUIRES two reviewers + codeowner + CISO co-sign',
      () {
        final locked = ChangeManagementPolicy.forClass(ChangeClass.locked);
        expect(locked.minReviewers, greaterThanOrEqualTo(2));
        expect(locked.requiresCodeowner, isTrue);
        expect(locked.requiresCisoCosign, isTrue);
        expect(
          locked.evidencePath,
          startsWith('docs/security/evidence/'),
          reason: 'locked changes must land in the security evidence ledger',
        );
      },
    );

    test('emergency change is the only one with maxLeadTimeHours ≤ 1', () {
      for (final p in ChangeManagementPolicy.classes) {
        if (p.changeClass == ChangeClass.emergency) {
          expect(
            p.maxLeadTimeHours,
            lessThanOrEqualTo(1),
            reason: 'emergency must ship within an hour',
          );
        } else {
          expect(
            p.maxLeadTimeHours,
            greaterThan(1),
            reason:
                '${p.changeClass.name}: non-emergency must give reviewers '
                'more than an hour',
          );
        }
      }
    });

    test('standard change needs no codeowner / CISO co-sign', () {
      final s = ChangeManagementPolicy.forClass(ChangeClass.standard);
      expect(s.requiresCodeowner, isFalse);
      expect(s.requiresCisoCosign, isFalse);
    });

    test('normal change needs codeowner but no CISO co-sign', () {
      final n = ChangeManagementPolicy.forClass(ChangeClass.normal);
      expect(n.requiresCodeowner, isTrue);
      expect(n.requiresCisoCosign, isFalse);
    });

    test('emergency + locked cite their evidence path + SOC 2 anchor', () {
      for (final cls in [ChangeClass.emergency, ChangeClass.locked]) {
        final p = ChangeManagementPolicy.forClass(cls);
        final blob = p.regulatoryRefs.join(' | ');
        expect(blob, contains('SOC 2 CC8.1'));
        expect(p.evidencePath, startsWith('docs/security/evidence/'));
      }
    });
  });

  group('ChangeManagementPolicy — freezes', () {
    test('every freeze id is unique', () {
      final ids = ChangeManagementPolicy.freezes.map((f) => f.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('freezeById resolves every entry', () {
      for (final f in ChangeManagementPolicy.freezes) {
        expect(ChangeManagementPolicy.freezeById(f.id), same(f));
      }
      expect(ChangeManagementPolicy.freezeById('does-not-exist'), isNull);
    });

    test('every freeze parses both ISO timestamps + end > start', () {
      for (final f in ChangeManagementPolicy.freezes) {
        final s = DateTime.parse(f.startIso);
        final e = DateTime.parse(f.endIso);
        expect(e.isAfter(s), isTrue, reason: f.id);
      }
    });

    test('every freeze permits emergency changes (safety floor)', () {
      for (final f in ChangeManagementPolicy.freezes) {
        expect(
          f.permittedClasses,
          contains(ChangeClass.emergency),
          reason:
              '${f.id}: emergency must always be permitted, even during '
              'a freeze — safety floor',
        );
      }
    });
  });

  group('isChangePermittedAt', () {
    test('outside any freeze: all classes permitted', () {
      final clear = DateTime.parse('2026-07-15T12:00:00Z');
      for (final c in ChangeClass.values) {
        expect(isChangePermittedAt(c, clear), isTrue, reason: c.name);
      }
    });

    test('during mobile-release-cut freeze: standard + normal blocked', () {
      final freeze = DateTime.parse('2026-09-04T12:00:00Z');
      expect(isChangePermittedAt(ChangeClass.standard, freeze), isFalse);
      expect(isChangePermittedAt(ChangeClass.normal, freeze), isFalse);
      expect(isChangePermittedAt(ChangeClass.emergency, freeze), isTrue);
      expect(isChangePermittedAt(ChangeClass.locked, freeze), isTrue);
    });

    test('during year-end financial close: only emergency permitted', () {
      final freeze = DateTime.parse('2026-12-31T12:00:00Z');
      expect(isChangePermittedAt(ChangeClass.standard, freeze), isFalse);
      expect(isChangePermittedAt(ChangeClass.normal, freeze), isFalse);
      expect(isChangePermittedAt(ChangeClass.locked, freeze), isFalse);
      expect(isChangePermittedAt(ChangeClass.emergency, freeze), isTrue);
    });

    test('boundary: end-of-freeze still blocks non-permitted', () {
      final endMoment = DateTime.parse('2026-09-08T23:59:59Z');
      expect(isChangePermittedAt(ChangeClass.standard, endMoment), isFalse);
    });

    test('one second after freeze end: clear again', () {
      final afterEnd = DateTime.parse('2026-09-09T00:00:00Z');
      expect(isChangePermittedAt(ChangeClass.standard, afterEnd), isTrue);
    });
  });
}
