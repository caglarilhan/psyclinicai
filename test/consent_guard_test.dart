import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/models/consent_record.dart';
import 'package:psyclinicai/services/compliance/consent_guard.dart';

void main() {
  ConsentRecord build({
    bool aiAssistance = true,
    bool dataProcessing = true,
    bool sensitive = true,
    String signature = 'Jane Doe',
    String version = '2026-06',
  }) => ConsentRecord(
    patientId: 'p1',
    policyVersion: version,
    dataProcessingConsent: dataProcessing,
    aiAssistanceConsent: aiAssistance,
    sensitiveDataConsent: sensitive,
    signedFullName: signature,
  );

  group('ConsentGuard.aiAllowed', () {
    test('false when the patient has no consent record on file', () {
      final guard = ConsentGuard.fromMap(const {});
      expect(guard.aiAllowed('p1'), isFalse);
    });

    test('true when a valid record explicitly grants AI consent', () {
      final guard = ConsentGuard.fromMap({'p1': build()});
      expect(guard.aiAllowed('p1'), isTrue);
    });

    test('false when AI consent is explicitly withdrawn', () {
      final guard = ConsentGuard.fromMap({'p1': build(aiAssistance: false)});
      expect(guard.aiAllowed('p1'), isFalse);
    });

    test('false when the consent record itself is invalid (missing sig)', () {
      final guard = ConsentGuard.fromMap({'p1': build(signature: '   ')});
      expect(guard.aiAllowed('p1'), isFalse);
    });

    test('false when required data-processing consent is missing', () {
      final guard = ConsentGuard.fromMap({'p1': build(dataProcessing: false)});
      expect(
        guard.aiAllowed('p1'),
        isFalse,
        reason: 'AI is denied unless the base consent stack is valid',
      );
    });

    test('default lookup denies every patient (fail-closed)', () {
      final guard = ConsentGuard();
      expect(guard.aiAllowed('p1'), isFalse);
      expect(guard.aiAllowed('anyone'), isFalse);
    });

    test('a withdrawn consent denies AI even if AI flag was true', () {
      final withdrawn = build().copyWith(withdrawnAt: DateTime.utc(2026, 6, 5));
      final guard = ConsentGuard.fromMap({'p1': withdrawn});
      expect(
        guard.aiAllowed('p1'),
        isFalse,
        reason: 'GDPR Art. 7(3) — withdrawal must close the AI gate',
      );
    });
  });

  // I2 — B1 fix: union read against ConsentEntry stream.
  // Revoking a kind from the Consent Center MUST close the gate even
  // if the intake-time aggregate still says yes.
  group('ConsentGuard.aiAllowed — union read against ConsentEntry', () {
    ConsentEntry entry({required ConsentKind kind, DateTime? revokedAt}) {
      final base = ConsentEntry(
        id: 'ce-${kind.id}',
        patientId: 'p1',
        kind: kind,
        policyVersion: '2026-06',
        signature: 'demo',
      );
      return revokedAt == null ? base : base.revoke(at: revokedAt);
    }

    test('intake OK + entry active → allowed', () {
      final guard = ConsentGuard.fromMap(
        {'p1': build()},
        consentEntryLookup: (id, kind) => kind == ConsentKind.aiProcessing
            ? entry(kind: ConsentKind.aiProcessing)
            : null,
      );
      expect(guard.aiAllowed('p1'), isTrue);
    });

    test('intake OK + entry REVOKED → denied (B1 the bug we are fixing)', () {
      final guard = ConsentGuard.fromMap(
        {'p1': build()},
        consentEntryLookup: (id, kind) => kind == ConsentKind.aiProcessing
            ? entry(
                kind: ConsentKind.aiProcessing,
                revokedAt: DateTime.utc(2026, 6, 10),
              )
            : null,
      );
      expect(
        guard.aiAllowed('p1'),
        isFalse,
        reason:
            'Consent Center revoke MUST close the AI gate even though '
            'the intake aggregate still says yes — otherwise GDPR Art. '
            '7(3) "as easy to withdraw as to give" is violated.',
      );
    });

    test('intake OK + entry MISSING (lookup configured) → denied', () {
      final guard = ConsentGuard.fromMap({
        'p1': build(),
      }, consentEntryLookup: (id, kind) => null);
      expect(
        guard.aiAllowed('p1'),
        isFalse,
        reason:
            'With entry lookup configured, the per-kind entry must be '
            'explicitly active. Missing entry = no grant on the '
            'revoke-able stream = deny.',
      );
    });

    test('no entry lookup → back-compat with intake-only gate', () {
      final guard = ConsentGuard.fromMap({'p1': build()});
      expect(
        guard.aiAllowed('p1'),
        isTrue,
        reason:
            'Pre-router callers (no entry lookup) keep the previous '
            'intake-only behavior.',
      );
    });
  });

  group('ConsentGuard.audioAllowed', () {
    test('no lookup configured → permissive (matches pre-router behavior)', () {
      final guard = ConsentGuard();
      expect(guard.audioAllowed('p1'), isTrue);
    });

    test('lookup with active entry → allowed', () {
      final guard = ConsentGuard(
        consentEntryLookup: (id, kind) => kind == ConsentKind.audioRecording
            ? ConsentEntry(
                id: 'ce-audio',
                patientId: 'p1',
                kind: kind,
                policyVersion: 'v1',
                signature: 'demo',
              )
            : null,
      );
      expect(guard.audioAllowed('p1'), isTrue);
    });

    test('lookup with revoked entry → denied', () {
      final guard = ConsentGuard(
        consentEntryLookup: (id, kind) => kind == ConsentKind.audioRecording
            ? ConsentEntry(
                id: 'ce-audio',
                patientId: 'p1',
                kind: kind,
                policyVersion: 'v1',
                signature: 'demo',
              ).revoke(at: DateTime.utc(2026, 6, 10))
            : null,
      );
      expect(guard.audioAllowed('p1'), isFalse);
    });

    test('lookup with missing entry → denied (gate is configured)', () {
      final guard = ConsentGuard(consentEntryLookup: (id, kind) => null);
      expect(guard.audioAllowed('p1'), isFalse);
    });

    test('requireAudio throws with audio_recording_consent_revoked reason', () {
      final guard = ConsentGuard(consentEntryLookup: (id, kind) => null);
      try {
        guard.requireAudio('p1');
        fail('expected throw');
      } on ConsentDeniedException catch (e) {
        expect(e.patientId, 'p1');
        expect(e.reason, 'audio_recording_consent_revoked');
      }
    });
  });

  group('ConsentGuard.telehealthAllowed', () {
    test('no lookup → permissive', () {
      final guard = ConsentGuard();
      expect(guard.telehealthAllowed('p1'), isTrue);
    });

    test('lookup with revoked entry → denied', () {
      final guard = ConsentGuard(
        consentEntryLookup: (id, kind) => kind == ConsentKind.telehealth
            ? ConsentEntry(
                id: 'ce-tele',
                patientId: 'p1',
                kind: kind,
                policyVersion: 'v1',
                signature: 'demo',
              ).revoke(at: DateTime.utc(2026, 6, 10))
            : null,
      );
      expect(guard.telehealthAllowed('p1'), isFalse);
    });

    test('requireTelehealth throws with telehealth_consent_revoked reason', () {
      final guard = ConsentGuard(consentEntryLookup: (id, kind) => null);
      try {
        guard.requireTelehealth('p1');
        fail('expected throw');
      } on ConsentDeniedException catch (e) {
        expect(e.reason, 'telehealth_consent_revoked');
      }
    });
  });

  group('ConsentGuard.requireAi', () {
    test('throws ConsentDeniedException when AI is denied', () {
      final guard = ConsentGuard.fromMap({'p1': build(aiAssistance: false)});
      expect(
        () => guard.requireAi('p1'),
        throwsA(isA<ConsentDeniedException>()),
      );
    });

    test('returns silently when AI is allowed', () {
      final guard = ConsentGuard.fromMap({'p1': build()});
      expect(() => guard.requireAi('p1'), returnsNormally);
    });

    test('exception carries the patient id and a reason code', () {
      final guard = ConsentGuard.fromMap(const {});
      try {
        guard.requireAi('p-missing');
        fail('expected throw');
      } on ConsentDeniedException catch (e) {
        expect(e.patientId, 'p-missing');
        expect(e.reason, isNotEmpty);
      }
    });
  });
}
