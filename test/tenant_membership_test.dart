import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/tenant_membership.dart';
import 'package:psyclinicai/services/data/tenant_membership_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    TenantMembershipService.setTestInstance(
      prefs: SharedPreferences.getInstance,
    );
  });
  tearDown(TenantMembershipService.resetTestInstance);

  group('TenantRole', () {
    test('owner + admin can manage billing; trainee cannot sign notes', () {
      expect(TenantRole.owner.canManageBilling, isTrue);
      expect(TenantRole.admin.canManageBilling, isTrue);
      expect(TenantRole.clinician.canManageBilling, isFalse);
      expect(TenantRole.trainee.canSignNotes, isFalse);
      expect(TenantRole.clinician.canSignNotes, isTrue);
    });

    test('fromId falls back to clinician for unknown ids', () {
      expect(TenantRole.fromId('xyz'), TenantRole.clinician);
      expect(TenantRole.fromId('trainee'), TenantRole.trainee);
    });
  });

  group('TenantMembership JSON', () {
    test('round-trip preserves fields', () {
      final m = TenantMembership(
        tenantId: 't-1',
        tenantName: 'Demo',
        uid: 'u-1',
        role: TenantRole.admin,
        joinedAt: DateTime.utc(2026, 6, 1),
        isDefault: true,
      );
      final restored = TenantMembership.fromJson(m.toJson());
      expect(restored.tenantId, 't-1');
      expect(restored.role, TenantRole.admin);
      expect(restored.isDefault, isTrue);
    });
  });

  group('TenantMembershipService', () {
    test('demo seed produces two memberships with first default', () async {
      await TenantMembershipService.instance.load();
      final svc = TenantMembershipService.instance;
      expect(svc.memberships.length, 2);
      expect(svc.hasMultipleTenants, isTrue);
      expect(svc.currentMembership?.tenantId, 'demo-tenant-xyz');
    });

    test('switchTo persists the choice + notifies', () async {
      await TenantMembershipService.instance.load();
      var notified = 0;
      TenantMembershipService.instance.addListener(() => notified++);
      await TenantMembershipService.instance.switchTo('locum-frankfurt-01');
      expect(notified, 1);
      expect(
        TenantMembershipService.instance.currentTenantId,
        'locum-frankfurt-01',
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('tenant.current_id'), 'locum-frankfurt-01');
    });

    test('switchTo refuses unknown tenant', () async {
      await TenantMembershipService.instance.load();
      expect(
        () => TenantMembershipService.instance.switchTo('nope'),
        throwsArgumentError,
      );
    });

    test('load re-uses persisted tenant on subsequent boots', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'tenant.current_id': 'locum-frankfurt-01',
      });
      TenantMembershipService.setTestInstance(
        prefs: SharedPreferences.getInstance,
      );
      await TenantMembershipService.instance.load();
      expect(
        TenantMembershipService.instance.currentTenantId,
        'locum-frankfurt-01',
      );
    });
  });
}
