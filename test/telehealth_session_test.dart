import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/telehealth_session.dart';

TelehealthSession _row({
  RecordingConsent consent = RecordingConsent.notAsked,
  DateTime? joinedAt,
  DateTime? endedAt,
}) =>
    TelehealthSession(
      id: 'tx-1',
      clinicId: 'c1',
      sessionId: 's-1',
      patientId: 'p-1',
      clinicianId: 'doc-1',
      roomName: 'psy-c1-s-1',
      scheduledFor: DateTime.utc(2026, 6, 2, 9),
      joinedAt: joinedAt,
      endedAt: endedAt,
      recordingConsent: consent,
    );

void main() {
  group('TelehealthSession', () {
    test('JSON round-trip preserves recording consent + timestamps', () {
      final row = TelehealthSession(
        id: 'tx-2',
        clinicId: 'c1',
        sessionId: 's-2',
        patientId: 'p-2',
        clinicianId: 'doc-1',
        roomName: 'psy-c1-s-2',
        scheduledFor: DateTime.utc(2026, 6, 10, 14),
        joinedAt: DateTime.utc(2026, 6, 10, 14, 5),
        endedAt: DateTime.utc(2026, 6, 10, 14, 55),
        recordingConsent: RecordingConsent.granted,
        consentAt: DateTime.utc(2026, 6, 10, 14, 4),
      );
      final round = TelehealthSession.fromJson(row.toJson());
      expect(round.id, row.id);
      expect(round.recordingConsent, RecordingConsent.granted);
      expect(round.consentAt, row.consentAt);
      expect(round.joinedAt, row.joinedAt);
      expect(round.endedAt, row.endedAt);
    });

    test('isLive flips to true once joined and back to false when ended',
        () {
      expect(_row().isLive, isFalse);
      expect(_row(joinedAt: DateTime.utc(2026, 6, 2, 9)).isLive, isTrue);
      expect(
        _row(
          joinedAt: DateTime.utc(2026, 6, 2, 9),
          endedAt: DateTime.utc(2026, 6, 2, 10),
        ).isLive,
        isFalse,
      );
    });

    test('canRecord is true ONLY when consent is explicitly granted', () {
      expect(_row().canRecord, isFalse);
      expect(
          _row(consent: RecordingConsent.declined).canRecord, isFalse);
      expect(_row(consent: RecordingConsent.granted).canRecord, isTrue);
    });

    test('RecordingConsent.fromId tolerates unknown / null values', () {
      expect(RecordingConsent.fromId(null), RecordingConsent.notAsked);
      expect(RecordingConsent.fromId('garbage'),
          RecordingConsent.notAsked);
      expect(RecordingConsent.fromId('granted'),
          RecordingConsent.granted);
    });

    test('VisitConsent is separate from RecordingConsent', () {
      // A patient may agree to a video visit but decline recording.
      final row = _row(consent: RecordingConsent.declined).copyWith(
        visitConsent: VisitConsent.granted,
      );
      expect(row.visitConsent, VisitConsent.granted);
      expect(row.recordingConsent, RecordingConsent.declined);
      expect(row.canRecord, isFalse);
    });

    test('durationMinutes is null until the session has ended', () {
      expect(_row().durationMinutes, isNull);
      expect(
        _row(joinedAt: DateTime.utc(2026, 6, 2, 9)).durationMinutes,
        isNull,
      );
      expect(
        _row(
          joinedAt: DateTime.utc(2026, 6, 2, 9),
          endedAt: DateTime.utc(2026, 6, 2, 9, 45),
        ).durationMinutes,
        45,
      );
    });

    test('isBillable is true only when the call met the CMS minimum',
        () {
      final tooShort = _row(
        joinedAt: DateTime.utc(2026, 6, 2, 9),
        endedAt: DateTime.utc(2026, 6, 2, 9, 5),
      );
      expect(tooShort.isBillable, isFalse);
      final billable = _row(
        joinedAt: DateTime.utc(2026, 6, 2, 9),
        endedAt: DateTime.utc(2026, 6, 2, 9, 20),
      );
      expect(billable.isBillable, isTrue);
    });
  });
}
