/// Sprint 32 P2 — BYOK key rotation flow.
///
/// Each BYOK provider (Anthropic, OpenAI, Cohere…) can rotate via:
///   1. Operator pastes a new key in Settings → API Keys → "Rotate now".
///   2. The new key is stored under the canonical secure-storage slot.
///   3. The old key moves to a `*_previous` slot for a configurable
///      grace window (default 24 h) so any in-flight request that
///      still holds a reference can finish without an auth failure.
///   4. After the grace window, the `*_previous` slot is wiped.
///
/// Telemetry events live in [TelemetryEvents]:
///   - byok.rotation_requested
///   - byok.rotation_completed
///   - byok.rotation_failed
///
/// Skill-panel coverage: env-secrets-manager (rotation policy),
/// senior-security (key-lifecycle correctness), senior-frontend (UX
/// scaffolding for the settings rotate button).
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The BYOK providers we currently store keys for. Extending this enum
/// is sufficient — slot names derive from `.name`.
enum ByokProvider { anthropic, openai, cohere }

/// Outcome of a single rotation attempt.
enum ByokRotationStatus { completed, rejected, failed }

class ByokRotationResult {
  const ByokRotationResult({
    required this.status,
    required this.provider,
    this.reason,
  });

  final ByokRotationStatus status;
  final ByokProvider provider;
  final String? reason;
}

class ByokRotationService {
  ByokRotationService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  /// Grace window during which the previous key remains valid.
  /// Defaults to 24 hours; the consumer may tighten this for high-
  /// security tenants.
  static const Duration defaultGraceWindow = Duration(hours: 24);

  String _currentSlot(ByokProvider p) => 'byok.${p.name}.current';
  String _previousSlot(ByokProvider p) => 'byok.${p.name}.previous';
  String _expirySlot(ByokProvider p) => 'byok.${p.name}.previous_expires_at';

  /// Persist [newKey] as the current key for [provider]. If a current
  /// key already exists, move it to the previous slot with an expiry
  /// timestamp = now + [graceWindow]. Returns the result for the
  /// caller to emit telemetry.
  Future<ByokRotationResult> rotate(
    ByokProvider provider,
    String newKey, {
    Duration graceWindow = defaultGraceWindow,
  }) async {
    if (newKey.trim().isEmpty) {
      return ByokRotationResult(
        status: ByokRotationStatus.rejected,
        provider: provider,
        reason: 'empty_key',
      );
    }
    if (newKey.length < 16) {
      return ByokRotationResult(
        status: ByokRotationStatus.rejected,
        provider: provider,
        reason: 'key_too_short',
      );
    }
    try {
      final existing = await _storage.read(key: _currentSlot(provider));
      if (existing != null && existing.isNotEmpty) {
        await _storage.write(
            key: _previousSlot(provider), value: existing);
        final expiresAt =
            DateTime.now().toUtc().add(graceWindow).toIso8601String();
        await _storage.write(
            key: _expirySlot(provider), value: expiresAt);
      }
      await _storage.write(key: _currentSlot(provider), value: newKey);
      return ByokRotationResult(
        status: ByokRotationStatus.completed,
        provider: provider,
      );
    } catch (e) {
      return ByokRotationResult(
        status: ByokRotationStatus.failed,
        provider: provider,
        reason: e.toString(),
      );
    }
  }

  /// Returns the current key for [provider] or `null` when none is set.
  Future<String?> currentKey(ByokProvider provider) async {
    return _storage.read(key: _currentSlot(provider));
  }

  /// Returns the previous key when it is still inside the grace window,
  /// otherwise wipes the slots and returns `null`. Callers fall back to
  /// the previous key when the current key throws an auth error and
  /// retry-once succeeds.
  Future<String?> previousKeyIfValid(ByokProvider provider,
      {DateTime? now}) async {
    final expiry = await _storage.read(key: _expirySlot(provider));
    if (expiry == null) return null;
    final ts = DateTime.tryParse(expiry);
    if (ts == null) return null;
    final reference = (now ?? DateTime.now().toUtc());
    if (reference.isAfter(ts)) {
      // Grace window over — wipe previous slot so we never silently
      // accept a stale credential.
      await wipePrevious(provider);
      return null;
    }
    return _storage.read(key: _previousSlot(provider));
  }

  /// Manually clear the previous slot — used by the IR runbook when
  /// the operator believes the previous key is compromised.
  Future<void> wipePrevious(ByokProvider provider) async {
    await _storage.delete(key: _previousSlot(provider));
    await _storage.delete(key: _expirySlot(provider));
  }
}
