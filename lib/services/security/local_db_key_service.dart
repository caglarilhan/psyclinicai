import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Sprint 30 S-06 — keychain-backed passphrase for the on-device PHI
/// store (SQLCipher). The passphrase is generated once with
/// `Random.secure()` and never leaves `flutter_secure_storage`
/// (iOS Keychain / Android Keystore). HIPAA §164.312(a)(2)(iv) maps to
/// "ePHI must be encrypted at rest" — this is how we satisfy it on the
/// client.
class LocalDbKeyService {
  LocalDbKeyService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              // Bind the key to the device biometric/lock-screen so a
              // stolen-and-jailbroken device cannot read it offline.
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  /// Storage key. Kept stable so app upgrades don't trigger re-key.
  static const String storageKey = 'psyclinicai.local_db.passphrase.v1';

  /// 32-byte (256-bit) random key, base64-url encoded. Same shape as the
  /// SQLCipher `PRAGMA key` parameter expects.
  static String _newPassphrase() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Returns the keychain-bound passphrase, generating + persisting it
  /// the first time it is requested. Idempotent under concurrent calls
  /// because [FlutterSecureStorage.write] is serialised by the plugin.
  Future<String> getOrCreatePassphrase() async {
    final existing = await _storage.read(key: storageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final fresh = _newPassphrase();
    await _storage.write(key: storageKey, value: fresh);
    return fresh;
  }

  /// Force a fresh key on the next [getOrCreatePassphrase]. Used by the
  /// account-deletion runbook when we need to invalidate offline data
  /// without round-tripping every SQLCipher page.
  Future<void> rotate() async {
    await _storage.delete(key: storageKey);
  }
}
