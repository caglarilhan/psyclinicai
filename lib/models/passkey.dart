/// WebAuthn / FIDO2 passkey credential record. Sprint 26 W1.
///
/// Stored under `users/{uid}/passkeys/{credentialId}`:
///   - `credentialId` is the base64url COSE credential ID (unique).
///   - `publicKey` is the COSE-encoded public key, base64url encoded.
///   - `signCount` MUST monotonically increase to defeat cloning.
///   - `revokedAt` set when the user explicitly removes the credential
///     (audit trail preserved; document never hard-deleted).
///
/// PHI never lands here — `deviceLabel` is a free-form user nickname.
class PasskeyCredential {
  PasskeyCredential({
    required this.credentialId,
    required this.publicKey,
    required this.signCount,
    required this.deviceLabel,
    this.transports = const <String>[],
    this.aaguid,
    DateTime? createdAt,
    this.lastUsedAt,
    this.revokedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc() {
    if (credentialId.trim().isEmpty) {
      throw ArgumentError.value(
          credentialId, 'credentialId', 'must not be empty');
    }
    if (publicKey.trim().isEmpty) {
      throw ArgumentError.value(publicKey, 'publicKey', 'must not be empty');
    }
    if (signCount < 0) {
      throw ArgumentError.value(
          signCount, 'signCount', 'must be non-negative');
    }
    if (deviceLabel.trim().isEmpty || deviceLabel.length > 80) {
      throw ArgumentError.value(
          deviceLabel, 'deviceLabel', 'must be 1..80 chars');
    }
  }

  final String credentialId;
  final String publicKey;
  final int signCount;
  final String deviceLabel;
  final List<String> transports;
  final String? aaguid;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;

  bool get isActive => revokedAt == null;

  PasskeyCredential copyWith({
    int? signCount,
    String? deviceLabel,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
  }) =>
      PasskeyCredential(
        credentialId: credentialId,
        publicKey: publicKey,
        signCount: signCount ?? this.signCount,
        deviceLabel: deviceLabel ?? this.deviceLabel,
        transports: transports,
        aaguid: aaguid,
        createdAt: createdAt,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        revokedAt: revokedAt ?? this.revokedAt,
      );

  Map<String, dynamic> toJson() => {
        'credential_id': credentialId,
        'public_key': publicKey,
        'sign_count': signCount,
        'device_label': deviceLabel,
        'transports': transports,
        if (aaguid != null) 'aaguid': aaguid,
        'created_at': createdAt.toIso8601String(),
        if (lastUsedAt != null) 'last_used_at': lastUsedAt!.toIso8601String(),
        if (revokedAt != null) 'revoked_at': revokedAt!.toIso8601String(),
      };

  factory PasskeyCredential.fromJson(Map<String, dynamic> json) =>
      PasskeyCredential(
        credentialId: json['credential_id'] as String,
        publicKey: json['public_key'] as String,
        signCount: json['sign_count'] as int,
        deviceLabel: json['device_label'] as String,
        transports: (json['transports'] as List? ?? const [])
            .map((e) => e as String)
            .toList(growable: false),
        aaguid: json['aaguid'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        lastUsedAt: json['last_used_at'] == null
            ? null
            : DateTime.parse(json['last_used_at'] as String),
        revokedAt: json['revoked_at'] == null
            ? null
            : DateTime.parse(json['revoked_at'] as String),
      );
}

abstract class PasskeyRepository {
  Future<List<PasskeyCredential>> listForUser(String uid);
  Future<void> add(String uid, PasskeyCredential credential);
  Future<void> recordAuthentication(
      String uid, String credentialId, int newSignCount);
  Future<void> revoke(String uid, String credentialId);
}

class InMemoryPasskeyRepository implements PasskeyRepository {
  final Map<String, Map<String, PasskeyCredential>> _store = {};

  @override
  Future<List<PasskeyCredential>> listForUser(String uid) async {
    final byId = _store[uid] ?? const <String, PasskeyCredential>{};
    return List.unmodifiable(byId.values);
  }

  @override
  Future<void> add(String uid, PasskeyCredential credential) async {
    final byId = _store.putIfAbsent(uid, () => <String, PasskeyCredential>{});
    if (byId.containsKey(credential.credentialId)) {
      throw StateError('passkey ${credential.credentialId} already enrolled');
    }
    byId[credential.credentialId] = credential;
  }

  @override
  Future<void> recordAuthentication(
      String uid, String credentialId, int newSignCount) async {
    final existing = _store[uid]?[credentialId];
    if (existing == null) {
      throw StateError('passkey $credentialId not found for $uid');
    }
    if (newSignCount < existing.signCount) {
      throw StateError('sign-count regression on $credentialId — '
          'possible cloned authenticator');
    }
    _store[uid]![credentialId] = existing.copyWith(
      signCount: newSignCount,
      lastUsedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> revoke(String uid, String credentialId) async {
    final existing = _store[uid]?[credentialId];
    if (existing == null) return;
    _store[uid]![credentialId] =
        existing.copyWith(revokedAt: DateTime.now().toUtc());
  }
}
