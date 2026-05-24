import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores BYOK (Bring Your Own Key) API credentials.
///
/// PsyClinicAI follows a BYOK model in the pilot stage: each clinician supplies
/// their own Anthropic API key, which never leaves the device's secure storage.
/// This keeps inference cost on the clinician (sub-$0.01/session) and removes
/// PsyClinicAI from the per-token billing path.
class ApiKeyStorage {
  ApiKeyStorage._();
  static final ApiKeyStorage instance = ApiKeyStorage._();

  static const _anthropicKey = 'copilot.anthropic_api_key';
  static const _openaiKey = 'copilot.openai_api_key';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String?> getAnthropicKey() => _storage.read(key: _anthropicKey);
  Future<String?> getOpenAIKey() => _storage.read(key: _openaiKey);

  Future<void> setAnthropicKey(String value) =>
      _storage.write(key: _anthropicKey, value: value.trim());

  Future<void> setOpenAIKey(String value) =>
      _storage.write(key: _openaiKey, value: value.trim());

  Future<void> clearAnthropic() => _storage.delete(key: _anthropicKey);
  Future<void> clearOpenAI() => _storage.delete(key: _openaiKey);

  Future<bool> hasAnthropicKey() async =>
      (await getAnthropicKey())?.isNotEmpty ?? false;
}
