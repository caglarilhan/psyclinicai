import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/services/compliance/consent_withdrawal_cascade.dart';

void main() {
  group('ConsentWithdrawalCascade — enum parity + invariants', () {
    test('every ConsentKind has exactly one pinned cascade', () {
      final pinned = ConsentWithdrawalCascade.cascades
          .map((c) => c.kind)
          .toSet();
      expect(
        pinned,
        equals(ConsentKind.values.toSet()),
        reason:
            'enum/cascade parity broken — adding a ConsentKind requires '
            'adding its CascadeRecord here',
      );
      expect(
        ConsentWithdrawalCascade.cascades.length,
        ConsentKind.values.length,
      );
    });

    test('forKind resolves every enum value', () {
      for (final k in ConsentKind.values) {
        expect(ConsentWithdrawalCascade.forKind(k).kind, k);
      }
    });

    test('every cascade has at least one action', () {
      for (final c in ConsentWithdrawalCascade.cascades) {
        expect(c.actions, isNotEmpty, reason: c.kind.id);
      }
    });

    test('every cascade has positive SLA + anchors populated', () {
      for (final c in ConsentWithdrawalCascade.cascades) {
        expect(c.slaMinutes, greaterThan(0), reason: c.kind.id);
        expect(c.regulatoryRefs, isNotEmpty, reason: c.kind.id);
      }
    });

    test('reversibleWithinMinutes ≤ slaMinutes', () {
      for (final c in ConsentWithdrawalCascade.cascades) {
        expect(
          c.reversibleWithinMinutes,
          lessThanOrEqualTo(c.slaMinutes),
          reason: '${c.kind.id}: reversible window must fit inside the SLA',
        );
      }
    });

    test('AI consent revoke has 1h SLA (active-session safety floor)', () {
      final ai = ConsentWithdrawalCascade.forKind(ConsentKind.aiProcessing);
      expect(
        ai.slaMinutes,
        lessThanOrEqualTo(60),
        reason: 'AI revoke must stop new calls within an hour',
      );
    });

    test('audio recording revoke has 1h SLA', () {
      final audio = ConsentWithdrawalCascade.forKind(
        ConsentKind.audioRecording,
      );
      expect(audio.slaMinutes, lessThanOrEqualTo(60));
    });

    test('audio revoke order: STOP active recording BEFORE purge', () {
      final audio = ConsentWithdrawalCascade.forKind(
        ConsentKind.audioRecording,
      );
      final stopIdx = audio.actions.indexOf(
        CascadeAction.stopActiveAudioRecording,
      );
      final purgeIdx = audio.actions.indexOf(
        CascadeAction.purgeAudioAndTranscripts,
      );
      expect(stopIdx, isNonNegative);
      expect(purgeIdx, isNonNegative);
      expect(
        stopIdx,
        lessThan(purgeIdx),
        reason:
            'audio cascade must STOP recording first, then purge — '
            'otherwise the active capture keeps writing while purge runs',
      );
    });

    test('chart-close consents (gdpr/kvkk/hipaa) require clinician ack', () {
      for (final kind in [
        ConsentKind.hipaaNopp,
        ConsentKind.gdprProcessing,
        ConsentKind.kvkkSpecialCategoryHealth,
      ]) {
        final c = ConsentWithdrawalCascade.forKind(kind);
        expect(
          c.requiresClinicianAck,
          isTrue,
          reason:
              '${kind.id}: closing the chart MUST surface to the clinician '
              '(silent close = clinical-safety violation)',
        );
        expect(c.actions, contains(CascadeAction.closeChartPendingDpoReview));
      }
    });

    test('GDPR processing revoke triggers Art. 17 erasure', () {
      final c = ConsentWithdrawalCascade.forKind(ConsentKind.gdprProcessing);
      expect(c.actions, contains(CascadeAction.triggerGdprErasure));
    });

    test('KVKK special-category revoke triggers md. 7 erasure', () {
      final c = ConsentWithdrawalCascade.forKind(
        ConsentKind.kvkkSpecialCategoryHealth,
      );
      expect(c.actions, contains(CascadeAction.triggerKvkkErasure));
    });

    test('HIPAA NOPP withdrawal does NOT auto-purge (retention rule)', () {
      final c = ConsentWithdrawalCascade.forKind(ConsentKind.hipaaNopp);
      expect(
        c.actions,
        isNot(contains(CascadeAction.triggerGdprErasure)),
        reason:
            'HIPAA §164.316(b)(2)(i) requires 6-year retention; NOPP '
            'withdrawal closes chart but does not auto-erase',
      );
    });

    test('audio cascade is irreversible (purge does not roll back)', () {
      final audio = ConsentWithdrawalCascade.forKind(
        ConsentKind.audioRecording,
      );
      expect(audio.reversibleWithinMinutes, 0);
      expect(hasIrreversibleAction(audio), isTrue);
    });

    test('marketing + telehealth revokes are reversible within the SLA', () {
      for (final kind in [ConsentKind.marketing, ConsentKind.telehealth]) {
        final c = ConsentWithdrawalCascade.forKind(kind);
        expect(
          c.reversibleWithinMinutes,
          greaterThan(0),
          reason:
              '${kind.id}: this revoke is intentionally undoable — patient '
              'may re-opt-in within the window',
        );
        expect(hasIrreversibleAction(c), isFalse);
      }
    });
  });

  group('isCascadeReversible', () {
    test('false when reversibleWithinMinutes == 0 (audio)', () {
      final audio = ConsentWithdrawalCascade.forKind(
        ConsentKind.audioRecording,
      );
      expect(isCascadeReversible(cascade: audio, elapsedMinutes: 0), isFalse);
      expect(isCascadeReversible(cascade: audio, elapsedMinutes: 30), isFalse);
    });

    test('true within the reversible window for telehealth', () {
      final c = ConsentWithdrawalCascade.forKind(ConsentKind.telehealth);
      // reversible 24h.
      expect(isCascadeReversible(cascade: c, elapsedMinutes: 60), isTrue);
      expect(isCascadeReversible(cascade: c, elapsedMinutes: 24 * 60), isTrue);
    });

    test('false past the reversible window for telehealth', () {
      final c = ConsentWithdrawalCascade.forKind(ConsentKind.telehealth);
      expect(
        isCascadeReversible(cascade: c, elapsedMinutes: 24 * 60 + 1),
        isFalse,
      );
    });
  });

  group('hasIrreversibleAction', () {
    test('true for cascades with purge / erasure', () {
      for (final kind in [
        ConsentKind.audioRecording,
        ConsentKind.gdprProcessing,
        ConsentKind.kvkkSpecialCategoryHealth,
      ]) {
        final c = ConsentWithdrawalCascade.forKind(kind);
        expect(hasIrreversibleAction(c), isTrue, reason: kind.id);
      }
    });

    test('false for reversible-only cascades', () {
      for (final kind in [
        ConsentKind.marketing,
        ConsentKind.telehealth,
        ConsentKind.aiProcessing,
        ConsentKind.hipaaNopp,
      ]) {
        final c = ConsentWithdrawalCascade.forKind(kind);
        expect(hasIrreversibleAction(c), isFalse, reason: kind.id);
      }
    });
  });
}
