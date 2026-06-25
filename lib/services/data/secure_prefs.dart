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
///   - Web: `flutter_secure_storage` uses JS Web Crypto + IndexedDB.
///     We pass explicit [WebOptions] (`dbName` + `publicKey` both
///     pinned to `psyclinicai_secure_v1`) so the IndexedDB namespace
///     is PsyClinicAI-specific instead of the plugin's vague default
///     (`FlutterEncryptedStorage`). The AES-GCM key is non-extractable
///     but the ciphertext + IV still sit in the browser's storage;
///     **treat the web build as best-effort** — do not rely on it
///     for long-term ePHI persistence; prefer server round-trips for
///     the canonical record.
///
/// **Not an audit log**: callers that need a tamper-evident chain
/// must still go through [AuditLogService]. This wrapper is only the
/// at-rest encryption layer.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// PsyClinicAI-specific IndexedDB namespace for the web build. Pinned
/// here so an auditor can grep one symbol and so a plugin upgrade
/// that changes the default `FlutterEncryptedStorage` name can never
/// move our existing entries silently.
const String securePrefsWebNamespace = 'psyclinicai_secure_v1';

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
      // Explicit web namespace — see [securePrefsWebNamespace] for
      // why we pin both fields instead of accepting the plugin's
      // generic "FlutterEncryptedStorage" default.
      webOptions: WebOptions(
        dbName: securePrefsWebNamespace,
        publicKey: securePrefsWebNamespace,
      ),
    );
  }

  /// @visibleForTesting — read-only view of the FSS instance the
  /// production constructor wires, so the web-fallback test can
  /// inspect the pinned [WebOptions].
  @visibleForTesting
  static FlutterSecureStorage defaultStorageForTesting() => _defaultStorage();

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
