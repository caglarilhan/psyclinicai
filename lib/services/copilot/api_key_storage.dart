import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores BYOK (Bring Your Own Key) API credentials.
///
/// PsyClinicAI follows a BYOK model in the pilot stage: each clinician supplies
/// their own Anthropic API key, which never leaves the device's secure storage.
/// This keeps inference cost on the clinician (sub-$0.01/session) and removes
/// PsyClinicAI from the per-token billing path.
///
/// **H-9 fix (audit 2026-06-21):** on the web build,
/// `flutter_secure_storage` maps to `window.localStorage` in plain
/// text — any XSS reaches the key. Web clinicians MUST use the
/// server-side relay path (`anthropicRelay`) which keeps the proxy
/// key off the client entirely. Calls to [setAnthropicKey] /
/// [setOpenAIKey] from a web build throw [WebKeyStorageRefused]; the
/// UI's API-keys screen catches this and renders a "use the iOS /
/// Android app for BYOK" notice instead of the input field.
class ApiKeyStorage {
  ApiKeyStorage._();
  static final ApiKeyStorage instance = ApiKeyStorage._();

  static const _anthropicKey = 'copilot.anthropic_api_key';
  static const _openaiKey = 'copilot.openai_api_key';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// True when this platform is allowed to persist a BYOK key. False
  /// on web — callers should hide BYOK UI and prompt the user to use
  /// the mobile app or the managed-key relay tier.
  bool get supportsLocalKey => !kIsWeb;

  Future<String?> getAnthropicKey() async {
    if (kIsWeb) return null;
    return _storage.read(key: _anthropicKey);
  }

  Future<String?> getOpenAIKey() async {
    if (kIsWeb) return null;
    return _storage.read(key: _openaiKey);
  }

  Future<void> setAnthropicKey(String value) async {
    if (kIsWeb) throw const WebKeyStorageRefused();
    await _storage.write(key: _anthropicKey, value: value.trim());
  }

  Future<void> setOpenAIKey(String value) async {
    if (kIsWeb) throw const WebKeyStorageRefused();
    await _storage.write(key: _openaiKey, value: value.trim());
  }

  Future<void> clearAnthropic() async {
    if (kIsWeb) return;
    await _storage.delete(key: _anthropicKey);
  }

  Future<void> clearOpenAI() async {
    if (kIsWeb) return;
    await _storage.delete(key: _openaiKey);
  }

  Future<bool> hasAnthropicKey() async =>
      (await getAnthropicKey())?.isNotEmpty ?? false;
}

/// Thrown when the caller asks ApiKeyStorage to persist a key on a
/// platform that is not safe for it (currently: web). UI catches this
/// and surfaces the managed-key relay tier as the alternative.
class WebKeyStorageRefused implements Exception {
  const WebKeyStorageRefused();
  @override
  String toString() =>
      'WebKeyStorageRefused: BYOK keys are not persisted on the web '
      'build. Use the iOS / Android app for BYOK, or sign up for the '
      'managed-key tier so the proxy holds the key server-side.';
}
