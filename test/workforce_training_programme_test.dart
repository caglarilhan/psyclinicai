import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/workforce_training_programme.dart';

void main() {
  group('WorkforceTrainingProgramme — modules', () {
    test('module list is non-empty', () {
      expect(WorkforceTrainingProgramme.modules, isNotEmpty);
    });

    test('every module has a unique id', () {
      final ids = WorkforceTrainingProgramme.modules.map((m) => m.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('moduleById resolves every entry', () {
      for (final m in WorkforceTrainingProgramme.modules) {
        expect(WorkforceTrainingProgramme.moduleById(m.id), same(m));
      }
      expect(WorkforceTrainingProgramme.moduleById('m999'), isNull);
    });

    test('every module has anchors + title + outcome populated', () {
      for (final m in WorkforceTrainingProgramme.modules) {
        expect(m.regulatoryRefs, isNotEmpty, reason: m.id);
        expect(m.title, isNotEmpty, reason: m.id);
        expect(m.outcome, isNotEmpty, reason: m.id);
      }
    });
  });

  group('WorkforceTrainingProgramme — roles', () {
    test('role list is non-empty + role keys unique', () {
      final keys = WorkforceTrainingProgramme.roles.map((r) => r.role).toList();
      expect(keys, isNotEmpty);
      expect(keys.toSet().length, keys.length, reason: 'duplicate role keys');
    });

    test('roleByKey resolves every entry', () {
      for (final r in WorkforceTrainingProgramme.roles) {
        expect(WorkforceTrainingProgramme.roleByKey(r.role), same(r));
      }
      expect(WorkforceTrainingProgramme.roleByKey('orphan'), isNull);
    });

    test('every role references only known module ids (no orphan refs)', () {
      final known = WorkforceTrainingProgramme.modules.map((m) => m.id).toSet();
      for (final r in WorkforceTrainingProgramme.roles) {
        for (final id in {
          ...r.onboardingModules,
          ...r.quarterlyModules,
          ...r.annualModules,
        }) {
          expect(
            known,
            contains(id),
            reason: '${r.role} references unknown module $id',
          );
        }
      }
    });

    test('every role declares a triggerCondition', () {
      for (final r in WorkforceTrainingProgramme.roles) {
        expect(r.triggerCondition, isNotEmpty, reason: r.role);
      }
    });

    test(
      'annual refresh covers every onboarding module — no module is taught at '
      'hire then never revisited',
      () {
        for (final r in WorkforceTrainingProgramme.roles) {
          for (final id in r.onboardingModules) {
            expect(
              r.annualModules,
              contains(id),
              reason:
                  '${r.role}: $id is in onboarding but missing from annual '
                  'refresh',
            );
          }
        }
      },
    );

    test('engineer_prod must take every module', () {
      final r = WorkforceTrainingProgramme.roleByKey('engineer_prod')!;
      final allModuleIds = WorkforceTrainingProgramme.modules
          .map((m) => m.id)
          .toSet();
      expect(r.onboardingModules.toSet(), equals(allModuleIds));
    });

    test('m8 (prod access discipline) is engineer-only', () {
      for (final r in WorkforceTrainingProgramme.roles) {
        final touchesM8 = {
          ...r.onboardingModules,
          ...r.annualModules,
        }.contains('m8');
        if (touchesM8) {
          expect(
            r.role,
            anyOf(equals('engineer_prod'), equals('contractor_phi')),
            reason:
                '${r.role}: m8 is engineer-only — non-engineer roles must '
                'not be gated on production access discipline.',
          );
        }
      }
    });
  });

  group('WorkforceTrainingProgramme — sanctions', () {
    test('sanction list is non-empty', () {
      expect(WorkforceTrainingProgramme.sanctions, isNotEmpty);
    });

    test('sanction tiers are strictly ascending (1 < 2 < 3 < 4)', () {
      final tiers = WorkforceTrainingProgramme.sanctions
          .map((s) => s.tier)
          .toList();
      for (var i = 1; i < tiers.length; i++) {
        expect(
          tiers[i],
          greaterThan(tiers[i - 1]),
          reason:
              'sanction tier ${tiers[i]} not strictly greater than '
              '${tiers[i - 1]} — severity ladder broken',
        );
      }
    });

    test('every sanction has name + example + action populated', () {
      for (final s in WorkforceTrainingProgramme.sanctions) {
        expect(s.name, isNotEmpty, reason: 'tier ${s.tier}');
        expect(s.example, isNotEmpty, reason: 'tier ${s.tier}');
        expect(s.action, isNotEmpty, reason: 'tier ${s.tier}');
      }
    });
  });

  group('requiredModuleIdsFor', () {
    test('returns the union of onboarding + quarterly + annual modules', () {
      for (final r in WorkforceTrainingProgramme.roles) {
        final union = requiredModuleIdsFor(r);
        expect(union, containsAll(r.onboardingModules));
        expect(union, containsAll(r.quarterlyModules));
        expect(union, containsAll(r.annualModules));
      }
    });

    test('engineer_prod requires all eight modules', () {
      final r = WorkforceTrainingProgramme.roleByKey('engineer_prod')!;
      expect(requiredModuleIdsFor(r).length, 8);
    });
  });

  test('authority list cites HIPAA + GDPR + SOC 2', () {
    final blob = WorkforceTrainingProgramme.authority.join(' | ');
    expect(blob, contains('HIPAA'));
    expect(blob, contains('GDPR'));
    expect(blob, contains('SOC 2'));
  });
}
