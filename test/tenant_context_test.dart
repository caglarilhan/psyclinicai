/// Note: these tests do NOT boot Firebase — they exclusively exercise
/// the override + ownership-check code paths so the helper's contract
/// is locked down without needing a Firebase emulator. The Firebase
/// branch is tested by the integration suite.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/tenant_context.dart';

void main() {
  group('TenantContext', () {
    tearDown(() => TenantContext.setOverride(null));

    test('setOverride lets tests run scoped to a synthetic tenant', () {
      TenantContext.setOverride('tenant-abc');
      expect(TenantContext.hasTenant, isTrue);
      expect(TenantContext.currentTenantIdOrNull, 'tenant-abc');
      expect(TenantContext.requireTenantId(), 'tenant-abc');
    });

    test('setOverride(null) clears the override', () {
      TenantContext.setOverride('tenant-abc');
      TenantContext.setOverride(null);
      // No Firebase user in the test runner, so without an override
      // we expect null again.
      expect(TenantContext.currentTenantIdOrNull, isNull);
    });

    test('ownsDocClinicId returns false for null / empty clinic id', () {
      TenantContext.setOverride('tenant-abc');
      expect(TenantContext.ownsDocClinicId(null), isFalse);
      expect(TenantContext.ownsDocClinicId(''), isFalse);
    });

    test('ownsDocClinicId true only when ids match exactly', () {
      TenantContext.setOverride('tenant-abc');
      expect(TenantContext.ownsDocClinicId('tenant-abc'), isTrue);
      expect(TenantContext.ownsDocClinicId('tenant-xyz'), isFalse);
      expect(TenantContext.ownsDocClinicId('Tenant-Abc'), isFalse);
    });

    test('TenantNotResolvedException carries a human-readable toString', () {
      const ex = TenantNotResolvedException();
      expect(ex.toString(), contains('TenantNotResolvedException'));
      expect(ex.toString(), contains('no tenant id available'));
    });
  });
}
