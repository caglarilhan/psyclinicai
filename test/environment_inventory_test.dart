import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/environment_inventory.dart';

void main() {
  group('EnvironmentInventory — pinned invariants', () {
    test('every DeploymentEnv has exactly one pinned record', () {
      final pinned = EnvironmentInventory.environments
          .map((r) => r.env)
          .toSet();
      expect(pinned, equals(DeploymentEnv.values.toSet()));
      expect(
        EnvironmentInventory.environments.length,
        DeploymentEnv.values.length,
      );
    });

    test('forEnv resolves every enum value', () {
      for (final e in DeploymentEnv.values) {
        expect(EnvironmentInventory.forEnv(e).env, e);
      }
    });

    test('every firebaseProjectId is unique', () {
      final ids = EnvironmentInventory.environments
          .map((r) => r.firebaseProjectId)
          .toList();
      expect(
        ids.toSet().length,
        ids.length,
        reason: 'duplicate firebaseProjectId',
      );
    });

    test('every functionsSecretNamespace is unique', () {
      final ids = EnvironmentInventory.environments
          .map((r) => r.functionsSecretNamespace)
          .toList();
      expect(
        ids.toSet().length,
        ids.length,
        reason: 'duplicate secret namespace',
      );
    });

    test('byFirebaseProjectId resolves every entry', () {
      for (final r in EnvironmentInventory.environments) {
        expect(
          EnvironmentInventory.byFirebaseProjectId(r.firebaseProjectId),
          same(r),
        );
      }
      expect(
        EnvironmentInventory.byFirebaseProjectId('does-not-exist'),
        isNull,
      );
    });

    test('every record has populated fields', () {
      for (final r in EnvironmentInventory.environments) {
        expect(r.firebaseProjectId, isNotEmpty, reason: r.env.name);
        expect(r.functionsSecretNamespace, isNotEmpty, reason: r.env.name);
        expect(r.publicHealthcheckUrl, isNotEmpty, reason: r.env.name);
        expect(r.cspReportUrl, isNotEmpty, reason: r.env.name);
      }
    });

    test('only production allows real customer traffic + real PHI', () {
      for (final r in EnvironmentInventory.environments) {
        if (r.env == DeploymentEnv.production) {
          expect(
            r.allowsRealCustomerTraffic,
            isTrue,
            reason: 'production MUST allow real customer traffic',
          );
          expect(
            r.allowsRealPhi,
            isTrue,
            reason: 'production MUST allow real PHI',
          );
        } else {
          expect(
            r.allowsRealCustomerTraffic,
            isFalse,
            reason:
                '${r.env.name}: only production allows real customer '
                'traffic — anything else risks leaking PHI to staging logs',
          );
          expect(
            r.allowsRealPhi,
            isFalse,
            reason: '${r.env.name}: only production allows real PHI',
          );
        }
      }
    });

    test('non-local envs use https healthcheck URLs', () {
      for (final r in EnvironmentInventory.environments) {
        if (r.env == DeploymentEnv.local) continue;
        expect(
          r.publicHealthcheckUrl,
          startsWith('https://'),
          reason: '${r.env.name}: non-local envs MUST use https healthcheck',
        );
      }
    });

    test('local env uses http (localhost)', () {
      final l = EnvironmentInventory.forEnv(DeploymentEnv.local);
      expect(l.publicHealthcheckUrl, contains('localhost'));
    });

    test('production firebase project id is the bare "psyclinicai" name', () {
      final prod = EnvironmentInventory.forEnv(DeploymentEnv.production);
      expect(prod.firebaseProjectId, 'psyclinicai');
      expect(prod.functionsSecretNamespace, 'prod');
    });

    test('every non-prod env uses a stage-suffix project + namespace', () {
      for (final r in EnvironmentInventory.environments) {
        if (r.env == DeploymentEnv.production) continue;
        if (r.env == DeploymentEnv.local) continue;
        expect(
          r.firebaseProjectId,
          startsWith('psyclinicai-'),
          reason: '${r.env.name}: project id needs stage suffix',
        );
        expect(
          r.functionsSecretNamespace,
          isNot('prod'),
          reason:
              '${r.env.name}: secret namespace MUST NOT be "prod" — that '
              'would let staging read prod secrets',
        );
      }
    });
  });

  group('envAllowsRealPhi', () {
    test('production: true', () {
      expect(envAllowsRealPhi(DeploymentEnv.production), isTrue);
    });

    test('local / preview / staging: false', () {
      expect(envAllowsRealPhi(DeploymentEnv.local), isFalse);
      expect(envAllowsRealPhi(DeploymentEnv.preview), isFalse);
      expect(envAllowsRealPhi(DeploymentEnv.staging), isFalse);
    });
  });
}
