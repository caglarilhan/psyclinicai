// Web-safe post-logout cache purge — conditional import keeps the
// mobile build clean (no-op) while the web build asks the patient-
// portal service worker to drop every Cache + clears localStorage
// keys prefixed with "portal:". Sprint 27 / F-009.

import 'portal_cache_purge_stub.dart'
    if (dart.library.html) 'portal_cache_purge_web.dart'
    as impl;

/// Purge web caches + ask the service worker to logout-broadcast.
/// No-op on mobile / desktop; clinician sign-out on those platforms
/// is already a hard process kill from the patient's perspective.
Future<void> purgePortalCaches() => impl.purgePortalCaches();
