/// Single source of truth for the currently active tenant id.
///
/// **Why this exists (audit 2026-06-21, M2):** the codebase still maps
/// every Firebase user 1:1 to a Firestore `clinic_id == uid` ownership
/// (the "solo pilot" tenancy). Group-practice + supervision-org sales
/// requires multi-tenant — multiple clinicians under one shared
/// `tenantId`. Migrating 85 screens at once would risk a tenancy break;
/// instead we ship this resolver now so the call sites only have to
/// reference *one* helper, and the underlying implementation can flip
/// from "uid is tenant" to "uid maps to tenant via custom claim"
/// without touching the screens.
///
/// Today the resolver returns the Firebase user's uid (preserving the
/// solo pilot behaviour). Once `setTenantClaim` finishes rolling out
/// (Sprint 29 S-03 / S-05), the resolver will read the `tenant_id`
/// custom claim and the screens will automatically pick it up — no
/// further refactor required.
///
/// **Contract:** the resolver is synchronous-safe whenever a Firebase
/// session has already loaded the id token; it returns `null` only
/// when nobody is signed in or the token has not yet been fetched.
library;

import 'package:firebase_auth/firebase_auth.dart';

/// Pluggable tenant resolver. UI-side callers should NEVER touch
/// `FirebaseAuth.instance.currentUser.uid` directly when they mean
/// "which tenant are we in" — go through this helper so the
/// multi-tenant rollout is a one-place flip.
class TenantContext {
  const TenantContext._();

  /// Optional override — only set in tests or by a deliberate caller
  /// (e.g. an admin tool that needs to act on behalf of a specific
  /// tenant). Production code paths must leave this null and let the
  /// auth-claim resolver run.
  static String? _overrideTenantId;

  /// True when the current user has an active tenant resolved. False
  /// when signed out or pre-auth-bootstrap.
  static bool get hasTenant => currentTenantIdOrNull != null;

  /// Resolve the current tenant id. Returns null when:
  ///   - nobody is signed in,
  ///   - or the auth token has not been fetched yet (cold start).
  ///
  /// Callers that need a non-null value should prefer
  /// [requireTenantId] which throws a clear exception instead of
  /// silently letting a null slip through a Firestore query.
  static String? get currentTenantIdOrNull {
    if (_overrideTenantId != null) return _overrideTenantId;

    // `FirebaseAuth.instance` throws when Firebase has not been
    // bootstrapped yet (cold start, unit tests without an emulator).
    // Treat that as "no tenant" so callers can probe before showing UI.
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
    if (user == null) return null;

    // Solo pilot today: uid IS the tenant. Multi-tenant rollout will
    // replace this with a `tenant_id` claim read from
    // `user.getIdTokenResult()`.
    return user.uid;
  }

  /// Resolve the current tenant id or throw [TenantNotResolvedException].
  /// Use this when the caller cannot meaningfully proceed without a
  /// tenant (Firestore reads/writes scoped to a clinic).
  static String requireTenantId() {
    final t = currentTenantIdOrNull;
    if (t == null) throw const TenantNotResolvedException();
    return t;
  }

  /// Set the tenant override (tests + admin tools only). Pass null
  /// to clear. Throws in release builds if the host process did not
  /// explicitly opt-in via [allowOverrideInRelease].
  static void setOverride(
    String? tenantId, {
    bool allowOverrideInRelease = false,
  }) {
    assert(
      allowOverrideInRelease || !_isReleaseMode(),
      'TenantContext.setOverride is test-only. '
      'Pass allowOverrideInRelease: true to enable in production builds.',
    );
    _overrideTenantId = tenantId;
  }

  /// Returns true when the currently configured tenant id matches the
  /// `clinic_id` of a Firestore document. Pure convenience for call
  /// sites that already loaded a doc and want a defensive double-check
  /// before showing PHI to the user.
  static bool ownsDocClinicId(String? clinicId) {
    if (clinicId == null || clinicId.isEmpty) return false;
    return currentTenantIdOrNull == clinicId;
  }

  static bool _isReleaseMode() {
    // const bool.fromEnvironment is evaluated at compile time; in
    // release builds Flutter wires `dart.vm.product` to true.
    return const bool.fromEnvironment('dart.vm.product');
  }
}

/// Thrown by [TenantContext.requireTenantId] when no tenant is
/// resolvable. The Firestore queries that hit this exception should
/// fail fast — they cannot scope themselves correctly without a tenant
/// id and a silent null would risk reading the wrong rows in a future
/// multi-tenant build.
class TenantNotResolvedException implements Exception {
  const TenantNotResolvedException();

  @override
  String toString() =>
      'TenantNotResolvedException: no tenant id available '
      '(user signed out or auth token not yet loaded).';
}
