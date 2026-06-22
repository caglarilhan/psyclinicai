import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/tenant_membership.dart';

/// In-memory + SharedPreferences-backed tenant switcher. Production
/// swap pulls memberships from a Firestore collection-group query on
/// `tenants/{tid}/members/{uid}`.
class TenantMembershipService extends ChangeNotifier {
  TenantMembershipService._({Future<SharedPreferences> Function()? prefs})
    : _prefsFactory = prefs;

  static TenantMembershipService instance = TenantMembershipService._();

  @visibleForTesting
  static void setTestInstance({
    required Future<SharedPreferences> Function() prefs,
  }) {
    instance = TenantMembershipService._(prefs: prefs);
  }

  @visibleForTesting
  static void resetTestInstance() {
    instance = TenantMembershipService._();
  }

  static const _currentKey = 'tenant.current_id';

  final Future<SharedPreferences> Function()? _prefsFactory;

  List<TenantMembership> _memberships = const [];
  String? _currentTenantId;
  bool _loaded = false;

  List<TenantMembership> get memberships => List.unmodifiable(_memberships);
  String? get currentTenantId => _currentTenantId;

  TenantMembership? get currentMembership {
    if (_currentTenantId == null) return null;
    for (final m in _memberships) {
      if (m.tenantId == _currentTenantId) return m;
    }
    return null;
  }

  bool get hasMultipleTenants => _memberships.length > 1;

  Future<SharedPreferences> _prefs() =>
      _prefsFactory?.call() ?? SharedPreferences.getInstance();

  Future<void> load({List<TenantMembership>? memberships}) async {
    if (_loaded) return;
    final p = await _prefs();
    _memberships = memberships ?? _demoSeed();
    final saved = p.getString(_currentKey);
    if (saved != null && _memberships.any((m) => m.tenantId == saved)) {
      _currentTenantId = saved;
    } else if (_memberships.isNotEmpty) {
      final def = _memberships.firstWhere(
        (m) => m.isDefault,
        orElse: () => _memberships.first,
      );
      _currentTenantId = def.tenantId;
    } else {
      _currentTenantId = null;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> switchTo(String tenantId) async {
    if (!_memberships.any((m) => m.tenantId == tenantId)) {
      throw ArgumentError('Unknown tenant id: $tenantId');
    }
    if (_currentTenantId == tenantId) return;
    _currentTenantId = tenantId;
    final p = await _prefs();
    await p.setString(_currentKey, tenantId);
    notifyListeners();
  }

  List<TenantMembership> _demoSeed() => [
    TenantMembership(
      tenantId: 'demo-tenant-xyz',
      tenantName: 'Demo Practice',
      uid: 'demo',
      role: TenantRole.owner,
      joinedAt: DateTime.utc(2026, 1, 14),
      isDefault: true,
    ),
    TenantMembership(
      tenantId: 'locum-frankfurt-01',
      tenantName: 'Frankfurt Locum Clinic',
      uid: 'demo',
      role: TenantRole.clinician,
      joinedAt: DateTime.utc(2026, 4),
    ),
  ];
}
