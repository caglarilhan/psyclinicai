/// PHI storage policy by platform.
///
/// `flutter_secure_storage` does not have a hardware keystore on the
/// web — its web implementation writes to `localStorage`, which is
/// readable by any script loaded on the same origin. That makes it
/// unfit for clinical PHI by default. This file holds the boolean we
/// use anywhere a repository decides whether to mirror a record to
/// local storage at all.
///
/// Pure — no Flutter imports — so the boolean is also callable from a
/// pure-Dart CI check.
library;

/// Reasons the local cache may be denied. Stored as a stable id so
/// banners + telemetry can stay consistent across surfaces.
enum WebPhiPolicy {
  /// Native (iOS / Android / macOS / Windows / Linux) — Keychain or
  /// encrypted preferences back the storage; local cache allowed.
  nativeAllowed,

  /// Web — `localStorage` is plain text; the repository must skip the
  /// local cache and rely on Firestore-only round-trips.
  webDenied,
}

/// `true` when the current platform may keep a local PHI cache.
/// Caller passes `kIsWeb` (or an injected flag in tests) so the
/// function stays a pure switch with no Flutter import.
bool isLocalCacheAllowed({required bool isWeb}) => !isWeb;

/// The matching policy enum value — useful when the call site wants
/// to log or render the reason, not just the boolean.
WebPhiPolicy resolveWebPhiPolicy({required bool isWeb}) =>
    isWeb ? WebPhiPolicy.webDenied : WebPhiPolicy.nativeAllowed;

/// One-line human-readable description for the banner on the
/// `data_export` and `intake_form` screens.
String webPhiPolicyMessage(WebPhiPolicy policy) {
  switch (policy) {
    case WebPhiPolicy.webDenied:
      return 'Web build does not cache PHI on this device. Records '
          'are read from and written to the server on every action.';
    case WebPhiPolicy.nativeAllowed:
      return 'Records cache locally inside the device keystore '
          'so the app keeps working without a network round-trip.';
  }
}
