/// Mint output of the Daily.co room minting Cloud Function
/// (`functions/src/telehealth_room.ts`). The token is short-lived and
/// is **never** persisted client-side — we hold it in memory just
/// long enough to hand it to the WebRTC SDK.
class TelehealthRoomToken {
  const TelehealthRoomToken({
    required this.roomName,
    required this.token,
    required this.expiresAt,
    required this.recordingEnabled,
    required this.euRegion,
    required this.createdAt,
  });

  final String roomName;
  final String token;
  final DateTime expiresAt;
  final bool recordingEnabled;
  final bool euRegion;
  final DateTime createdAt;

  bool isValid({DateTime? now}) {
    final ts = now ?? DateTime.now().toUtc();
    return ts.isBefore(expiresAt.subtract(const Duration(minutes: 1)));
  }

  Duration remaining({DateTime? now}) {
    final ts = now ?? DateTime.now().toUtc();
    final diff = expiresAt.difference(ts);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// JSON shape for **persistence and audit logging only** — the raw
  /// [token] is deliberately omitted. The credential lives in memory
  /// for the duration of the call; persisting it (Firestore, telemetry,
  /// crash reports) would violate HIPAA §164.312(c)(2) integrity +
  /// GDPR Art. 5(1)(e) storage limitation. Use [toWireJson] only at
  /// the WebRTC handoff boundary.
  Map<String, dynamic> toJson() => {
        'room_name': roomName,
        'expires_at': expiresAt.toUtc().toIso8601String(),
        'recording_enabled': recordingEnabled,
        'eu_region': euRegion,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  /// In-process JSON used to hand the live token to the WebRTC SDK.
  /// Caller is responsible for dropping the reference immediately
  /// after `join()` — never persist this map.
  Map<String, dynamic> toWireJson() => {
        ...toJson(),
        'token': token,
      };

  factory TelehealthRoomToken.fromJson(Map<String, dynamic> json) {
    return TelehealthRoomToken(
      roomName: json['room_name'] as String,
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      recordingEnabled: json['recording_enabled'] as bool? ?? false,
      euRegion: json['eu_region'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

abstract class TelehealthRoomMinter {
  Future<TelehealthRoomToken> mint({
    required String tenantId,
    required String sessionId,
    required bool recordingConsentGranted,
    required bool euRegion,
  });
}

class TelehealthRoomMinterStub implements TelehealthRoomMinter {
  TelehealthRoomMinterStub({this.clock});
  final DateTime Function()? clock;
  DateTime _now() => clock?.call() ?? DateTime.now().toUtc();

  @override
  Future<TelehealthRoomToken> mint({
    required String tenantId,
    required String sessionId,
    required bool recordingConsentGranted,
    required bool euRegion,
  }) async {
    if (tenantId.isEmpty) throw ArgumentError('tenantId required');
    if (sessionId.isEmpty) throw ArgumentError('sessionId required');
    final ts = _now();
    return TelehealthRoomToken(
      roomName: 'psy-$tenantId-$sessionId',
      token: 'stub-${ts.millisecondsSinceEpoch.toRadixString(36)}',
      expiresAt: ts.add(const Duration(minutes: 60)),
      recordingEnabled: recordingConsentGranted,
      euRegion: euRegion,
      createdAt: ts,
    );
  }
}
