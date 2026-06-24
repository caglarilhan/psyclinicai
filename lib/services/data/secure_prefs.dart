/// Thin facade over [FlutterSecureStorage] with the platform-correct
/// defaults the codebase has been repeating in every PHI-bearing
/// repository (intake, session-notes, safety-plan today; risk-signals,
/// homework, modality-sessions, Vanderbilt assessments after the
/// migration sweep).
///
/// **Why this exists** — three PHI repositories each instantiated
/// `FlutterSecureStorage(...)` with the same Android/iOS options
/// inline. A typo or drift in any one of them would silently
/// degrade encryption posture for a single repo without anyone
/// noticing. Centralising the construction here makes the guarantee
/// auditable: one constructor, one set of options, one place to
/// extend (e.g. add a tenant prefix or audit hooks).
///
/// **Platform behaviour**:
///   - Android: encryptedSharedPreferences → AES-GCM via the AndroidX
///     Security library; keys live in Android KeyStore.
///   - iOS: Keychain `first_unlock`, scoped to the app, requires the
///     device to have been unlocked at least once after boot.
///   - macOS: Keychain (default plugin behaviour).
///   - Web: `flutter_secure_storage` falls back to JS Web Crypto +
///     localStorage. The blob is encrypted with a non-extractable
///     AES-GCM key, but the ciphertext + IV still sit in localStorage.
///     **Treat the web build as best-effort** — do not use this for
///     long-term ePHI persistence in browsers; prefer server round-
///     trips for the canonical record.
///
/// **Not an audit log**: callers that need a tamper-evident chain
/// must still go through [AuditLogService]. This wrapper is only the
/// at-rest encryption layer.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePrefs {
  SecurePrefs({FlutterSecureStorage? storage})
    : _storage = storage ?? _defaultStorage();

  /// Process-wide default; tests should construct their own with an
  /// in-memory backing `FlutterSecureStorage.setMockInitialValues`.
  static SecurePrefs get instance => _instance ??= SecurePrefs();
  static SecurePrefs? _instance;

  /// Overrides the singleton — test-only seam.
  static void setInstanceForTest(SecurePrefs? value) {
    _instance = value;
  }

  static FlutterSecureStorage _defaultStorage() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  final FlutterSecureStorage _storage;

  Future<String?> getString(String key) => _storage.read(key: key);

  Future<void> setString(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> remove(String key) => _storage.delete(key: key);

  Future<bool> containsKey(String key) => _storage.containsKey(key: key);

  /// Drops every entry written through this facade — wired only for
  /// account-deletion flows + tests. Production code paths should
  /// remove a single key at a time via [remove] so neighbouring repos
  /// stay intact.
  Future<void> clearAll() => _storage.deleteAll();
}
