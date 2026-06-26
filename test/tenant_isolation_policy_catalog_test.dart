import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/tenant_isolation_policy_catalog.dart';

void main() {
  group('TenantIsolationPolicyCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(TenantIsolationPolicyCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = TenantIsolationPolicyCatalog.records
          .map((r) => r.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in TenantIsolationPolicyCatalog.records) {
        expect(TenantIsolationPolicyCatalog.byId(r.id), same(r));
      }
      expect(TenantIsolationPolicyCatalog.byId('does-not-exist'), isNull);
    });

    test('every TenantDataDomain has exactly one pinned record', () {
      for (final d in TenantDataDomain.values) {
        final matches = TenantIsolationPolicyCatalog.records
            .where((r) => r.domain == d)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${d.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in TenantIsolationPolicyCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test('cross-tenant query allowed ONLY for platform-admin-readonly', () {
      for (final r in TenantIsolationPolicyCatalog.records) {
        if (r.domain == TenantDataDomain.platformAdminReadonly) {
          expect(r.allowCrossTenantQuery, isTrue);
        } else {
          expect(
            r.allowCrossTenantQuery,
            isFalse,
            reason:
                '${r.id}: cross-tenant query is the #1 SaaS breach class (OWASP API BOLA) — only platform-admin-readonly may enable',
          );
        }
      }
    });

    test('platform-admin-readonly MUST NOT scope reads/writes by tenant', () {
      final r = TenantIsolationPolicyCatalog.byDomain(
        TenantDataDomain.platformAdminReadonly,
      )!;
      expect(
        r.scopeReadsByTenant,
        isFalse,
        reason:
            'platform-admin-readonly is the cross-tenant surface; scoping reads defeats its purpose',
      );
      expect(
        r.scopeWritesByTenant,
        isFalse,
        reason:
            'platform-admin-readonly is read-only by name — writes must be impossible',
      );
    });

    test('every non-admin domain MUST scope reads AND writes by tenant', () {
      for (final r in TenantIsolationPolicyCatalog.records) {
        if (r.domain == TenantDataDomain.platformAdminReadonly) continue;
        expect(
          r.scopeReadsByTenant,
          isTrue,
          reason:
              '${r.id}: reading without tenant predicate is a cross-tenant leak waiting to happen',
        );
        expect(
          r.scopeWritesByTenant,
          isTrue,
          reason:
              '${r.id}: writing without tenant tag corrupts isolation for all subsequent reads',
        );
      }
    });

    test('clinical-records + audit-log MUST use per-tenant key derivation', () {
      for (final d in [
        TenantDataDomain.clinicalRecords,
        TenantDataDomain.auditLog,
      ]) {
        final r = TenantIsolationPolicyCatalog.byDomain(d)!;
        expect(
          r.perTenantKeyDerivation,
          isTrue,
          reason:
              '${d.name}: PHI / audit chain compromise must not cross tenants on envelope-key leak',
        );
      }
    });

    test(
      'clinical-records MUST be included in tenant-deletion cascade (GDPR Art. 17)',
      () {
        final r = TenantIsolationPolicyCatalog.byDomain(
          TenantDataDomain.clinicalRecords,
        )!;
        expect(
          r.includedInDeletionCascade,
          isTrue,
          reason:
              'GDPR Art. 17 right-to-erasure on tenant offboarding cannot leave clinical PHI behind',
        );
      },
    );

    test(
      'audit-log MUST NOT be in deletion cascade (HIPAA §164.316 retention)',
      () {
        final r = TenantIsolationPolicyCatalog.byDomain(
          TenantDataDomain.auditLog,
        )!;
        expect(
          r.includedInDeletionCascade,
          isFalse,
          reason:
              'audit log retention (HIPAA §164.316 6-year) overrides tenant erasure; logs are retained pseudonymised',
        );
      },
    );

    test(
      'every record MUST cite a tenant-isolation anchor (HIPAA / SOC 2 / GDPR / OWASP / PCI)',
      () {
        for (final r in TenantIsolationPolicyCatalog.records) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('HIPAA') ||
                blob.contains('SOC 2') ||
                blob.contains('GDPR') ||
                blob.contains('OWASP') ||
                blob.contains('PCI'),
            isTrue,
            reason: '${r.id}: needs an isolation-anchor regulatory citation',
          );
        }
      },
    );

    test('PHI-touching domains MUST cite HIPAA §164.502 or §164.312', () {
      for (final d in [
        TenantDataDomain.clinicalRecords,
        TenantDataDomain.auditLog,
        TenantDataDomain.errorTelemetry,
      ]) {
        final r = TenantIsolationPolicyCatalog.byDomain(d)!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('HIPAA §164.502') ||
              blob.contains('HIPAA §164.312') ||
              blob.contains('HIPAA §164.316'),
          isTrue,
          reason:
              '${d.name}: PHI-touching domain needs a HIPAA §164.502 / 312 / 316 anchor',
        );
      }
    });
  });

  group('mustScopeReads / mustScopeWrites helpers', () {
    test('mustScopeReads false ONLY for platform-admin-readonly', () {
      for (final d in TenantDataDomain.values) {
        final expected = d != TenantDataDomain.platformAdminReadonly;
        expect(mustScopeReads(d), expected, reason: d.name);
      }
    });

    test('mustScopeWrites false ONLY for platform-admin-readonly', () {
      for (final d in TenantDataDomain.values) {
        final expected = d != TenantDataDomain.platformAdminReadonly;
        expect(mustScopeWrites(d), expected, reason: d.name);
      }
    });
  });
}
