import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/telehealth_room_token.dart';

void main() {
  group('TelehealthRoomToken', () {
    final now = DateTime.utc(2026, 6, 2, 12, 0, 0);
    final tok = TelehealthRoomToken(
      roomName: 'psy-t-1-s-1',
      token: 'jwt-X',
      expiresAt: now.add(const Duration(minutes: 60)),
      recordingEnabled: true,
      euRegion: true,
      createdAt: now,
    );

    test('isValid true within window, false near expiry (1-min margin)', () {
      expect(tok.isValid(now: now), isTrue);
      expect(
        tok.isValid(now: now.add(const Duration(minutes: 59, seconds: 30))),
        isFalse,
      );
      expect(tok.isValid(now: now.add(const Duration(hours: 2))), isFalse);
    });

    test('remaining duration is zero when expired', () {
      expect(tok.remaining(now: now).inMinutes, 60);
      expect(tok.remaining(now: now.add(const Duration(hours: 2))),
          Duration.zero);
    });

    test('toJson omits the raw token (audit safety)', () {
      final j = tok.toJson();
      expect(j.containsKey('token'), isFalse,
          reason: 'Persisting the live token would leak a credential');
      expect(j['room_name'], 'psy-t-1-s-1');
      expect(j['recording_enabled'], isTrue);
      expect(j['eu_region'], isTrue);
    });

    test('toWireJson includes the token for SDK handoff', () {
      final w = tok.toWireJson();
      expect(w['token'], 'jwt-X');
      expect(w['room_name'], 'psy-t-1-s-1');
    });

    test('fromJson stays compatible with toWireJson at the SDK boundary',
        () {
      final restored = TelehealthRoomToken.fromJson(tok.toWireJson());
      expect(restored.token, tok.token);
      expect(restored.expiresAt, tok.expiresAt);
      expect(restored.recordingEnabled, tok.recordingEnabled);
    });
  });

  group('TelehealthRoomMinterStub', () {
    final fixedTime = DateTime.utc(2026, 6, 2, 12, 0, 0);
    final minter = TelehealthRoomMinterStub(clock: () => fixedTime);

    test('mints a room name scoped to tenant + session', () async {
      final t = await minter.mint(
        tenantId: 't-1',
        sessionId: 's-99',
        recordingConsentGranted: false,
        euRegion: true,
      );
      expect(t.roomName, 'psy-t-1-s-99');
      expect(t.recordingEnabled, isFalse);
      expect(t.euRegion, isTrue);
      expect(t.expiresAt.difference(t.createdAt).inMinutes, 60);
    });

    test('rejects empty tenant or session', () async {
      expect(
        () => minter.mint(
          tenantId: '',
          sessionId: 's-1',
          recordingConsentGranted: false,
          euRegion: true,
        ),
        throwsArgumentError,
      );
      expect(
        () => minter.mint(
          tenantId: 't-1',
          sessionId: '',
          recordingConsentGranted: false,
          euRegion: true,
        ),
        throwsArgumentError,
      );
    });

    test('recordingEnabled mirrors consent flag', () async {
      final granted = await minter.mint(
          tenantId: 't',
          sessionId: 's',
          recordingConsentGranted: true,
          euRegion: false);
      expect(granted.recordingEnabled, isTrue);
      expect(granted.euRegion, isFalse);
    });
  });
}
