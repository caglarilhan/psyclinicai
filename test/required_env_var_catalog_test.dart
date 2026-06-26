import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/required_env_var_catalog.dart';

void main() {
  group('RequiredEnvVarCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(RequiredEnvVarCatalog.records, isNotEmpty);
    });

    test('every record name is unique', () {
      final names = RequiredEnvVarCatalog.records.map((r) => r.name).toList();
      expect(names.toSet().length, names.length);
    });

    test('byName resolves every record', () {
      for (final r in RequiredEnvVarCatalog.records) {
        expect(RequiredEnvVarCatalog.byName(r.name), same(r));
      }
      expect(RequiredEnvVarCatalog.byName('NO_SUCH_VAR'), isNull);
    });

    test('every record has populated fields + anchors', () {
      for (final r in RequiredEnvVarCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.name);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.name);
        expect(
          r.requiredIn,
          isNotEmpty,
          reason: '${r.name}: needs at least one required slot',
        );
      }
    });

    test('every record name is uppercase + underscore (SCREAMING_SNAKE)', () {
      final pattern = RegExp(r'^[A-Z][A-Z0-9_]*$');
      for (final r in RequiredEnvVarCatalog.records) {
        expect(
          pattern.hasMatch(r.name),
          isTrue,
          reason:
              '${r.name}: env var convention is SCREAMING_SNAKE_CASE — drives shell-script readability + grep',
        );
      }
    });
  });

  group('safety-critical invariants', () {
    test('every secret-class var MUST be required in production', () {
      for (final r in RequiredEnvVarCatalog.records) {
        if (r.sensitivity != EnvVarSensitivity.secret) continue;
        expect(
          r.requiredIn,
          contains(DeploymentSlot.production),
          reason:
              '${r.name}: secret without prod requirement is dead config + leaked-vendor-cost surface',
        );
      }
    });

    test(
      'JWT + audit-log key handles MUST be required in preview + staging + production',
      () {
        for (final name in [
          'JWT_SIGNING_KEY_HANDLE',
          'AUDIT_LOG_HMAC_KEY_HANDLE',
        ]) {
          final r = RequiredEnvVarCatalog.byName(name)!;
          for (final slot in [
            DeploymentSlot.preview,
            DeploymentSlot.staging,
            DeploymentSlot.production,
          ]) {
            expect(
              r.requiredIn,
              contains(slot),
              reason:
                  '${r.name}: missing ${slot.name} would silently disable signing/verification',
            );
          }
        }
      },
    );

    test(
      'backup-encryption + payment + AI secrets MUST be required in staging + production',
      () {
        for (final name in [
          'BACKUP_ENCRYPTION_KEY_HANDLE',
          'STRIPE_SECRET_KEY',
          'STRIPE_WEBHOOK_SECRET',
          'OPENAI_API_KEY',
        ]) {
          final r = RequiredEnvVarCatalog.byName(name)!;
          for (final slot in [
            DeploymentSlot.staging,
            DeploymentSlot.production,
          ]) {
            expect(
              r.requiredIn,
              contains(slot),
              reason: '${r.name}: missing ${slot.name} breaks core flow',
            );
          }
        }
      },
    );

    test(
      'Firebase public-config vars MUST be required in ALL slots (client bundle needs them)',
      () {
        for (final name in ['FIREBASE_PROJECT_ID', 'FIREBASE_API_KEY']) {
          final r = RequiredEnvVarCatalog.byName(name)!;
          for (final slot in DeploymentSlot.values) {
            expect(
              r.requiredIn,
              contains(slot),
              reason:
                  '${r.name}: client bundle cannot boot in ${slot.name} without it',
            );
          }
        }
      },
    );

    test(
      'every record MUST cite a control anchor (SOC 2 / ISO 27001 / NIST / HIPAA / PCI / OWASP)',
      () {
        for (final r in RequiredEnvVarCatalog.records) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('SOC 2') ||
                blob.contains('ISO 27001') ||
                blob.contains('NIST') ||
                blob.contains('HIPAA') ||
                blob.contains('PCI') ||
                blob.contains('OWASP') ||
                blob.contains('EU AI Act'),
            isTrue,
            reason: '${r.name}: needs a regulatory/control anchor',
          );
        }
      },
    );

    test(
      'every secret MUST cite SOC 2 CC6.1 OR PCI / HIPAA / NIST anchor (secrets are access-control surfaces)',
      () {
        for (final r in RequiredEnvVarCatalog.records) {
          if (r.sensitivity != EnvVarSensitivity.secret) continue;
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('SOC 2 CC6.1') ||
                blob.contains('PCI DSS') ||
                blob.contains('HIPAA') ||
                blob.contains('NIST SP 800-57') ||
                blob.contains('OWASP ASVS V3.5') ||
                blob.contains('EU AI Act'),
            isTrue,
            reason:
                '${r.name}: secret needs an access-control anchor (SOC 2 CC6.1 / PCI / HIPAA / NIST 800-57)',
          );
        }
      },
    );
  });

  group('requiredInSlot + isRequiredIn helpers', () {
    test('production slot has the most required vars (most demanding slot)', () {
      final prod = RequiredEnvVarCatalog.requiredInSlot(
        DeploymentSlot.production,
      ).length;
      final local = RequiredEnvVarCatalog.requiredInSlot(
        DeploymentSlot.local,
      ).length;
      expect(
        prod,
        greaterThanOrEqualTo(local),
        reason:
            'production must require AT LEAST as many vars as local — anything less means a prod-only var is undocumented',
      );
    });

    test('isRequiredIn returns true for known var + slot combinations', () {
      expect(
        isRequiredIn('STRIPE_SECRET_KEY', DeploymentSlot.production),
        isTrue,
      );
      expect(isRequiredIn('STRIPE_SECRET_KEY', DeploymentSlot.local), isFalse);
      expect(isRequiredIn('NO_SUCH_VAR', DeploymentSlot.production), isFalse);
    });
  });
}
