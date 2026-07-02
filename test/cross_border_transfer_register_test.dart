import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/cross_border_transfer_register.dart';

void main() {
  group('CrossBorderTransferRegister — pinned invariants', () {
    test('register is non-empty', () {
      expect(CrossBorderTransferRegister.transfers, isNotEmpty);
    });

    test('every transfer id is unique', () {
      final ids = CrossBorderTransferRegister.transfers
          .map((t) => t.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every entry', () {
      for (final t in CrossBorderTransferRegister.transfers) {
        expect(CrossBorderTransferRegister.byId(t.id), same(t));
      }
      expect(CrossBorderTransferRegister.byId('does-not-exist'), isNull);
    });

    test('every transfer has populated fields', () {
      for (final t in CrossBorderTransferRegister.transfers) {
        expect(t.subprocessorId, isNotEmpty, reason: t.id);
        expect(t.sourceJurisdiction, isNotEmpty, reason: t.id);
        expect(t.destinationJurisdiction, isNotEmpty, reason: t.id);
        expect(t.regulatoryRefs, isNotEmpty, reason: t.id);
      }
    });

    test('every subprocessorId is in the known SubprocessorRegistry set', () {
      const known = {
        'hetzner',
        'aws-ses',
        'cloudflare',
        'firebase-auth',
        'anthropic',
        'openai',
        'groq',
        'google-gemini',
        'stripe',
        'sentry',
        'posthog',
        'daily-co',
        'twilio',
      };
      for (final t in CrossBorderTransferRegister.transfers) {
        expect(
          known,
          contains(t.subprocessorId),
          reason:
              '${t.id}: subprocessorId `${t.subprocessorId}` is not in the '
              'known SubprocessorRegistry id set',
        );
      }
    });

    test(
      'cross-border transfers (non-intraEea) cite GDPR Art. 46 OR 45 OR 49',
      () {
        for (final t in CrossBorderTransferRegister.outsideEea()) {
          final blob = t.regulatoryRefs.join(' | ');
          expect(
            blob.contains('Art. 46') ||
                blob.contains('Art. 45') ||
                blob.contains('Art. 49'),
            isTrue,
            reason:
                '${t.id}: cross-border transfer MUST cite the Art. 44+ '
                'mechanism (46 SCC / 45 adequacy / 49 derogation)',
          );
        }
      },
    );

    test('every SCC transfer declares at least one supplementary measure', () {
      for (final t in CrossBorderTransferRegister.transfers) {
        if (t.mechanism != TransferMechanism.standardContractualClauses) {
          continue;
        }
        expect(
          t.supplementaryMeasures,
          isNotEmpty,
          reason:
              '${t.id}: SCC transfers MUST list Schrems II supplementary '
              'measures (e.g. encryption, pseudonymisation, BYOK)',
        );
      }
    });

    test(
      'PHI transfers outside EEA must use SCCs (no derogation shortcut)',
      () {
        for (final t in CrossBorderTransferRegister.outsideEea()) {
          if (t.dataClass != TransferDataClass.phi) continue;
          expect(
            t.mechanism,
            TransferMechanism.standardContractualClauses,
            reason:
                '${t.id}: PHI cross-border transfers MUST use SCC; DPF + '
                'derogation are not used for PHI in this platform',
          );
        }
      },
    );

    test('Anthropic PHI transfer includes pseudonymisation supplementary', () {
      final t = CrossBorderTransferRegister.byId('anthropic-phi-us')!;
      final blob = t.supplementaryMeasures.join(' | ');
      expect(
        blob.toLowerCase(),
        contains('pseudonymis'),
        reason:
            'Anthropic PHI relay MUST pseudonymise before sending — '
            'L9 PHI scrub catalog is the enforcement layer',
      );
    });

    test('Anthropic + Stripe + Sentry transfers reference their TIA doc', () {
      const must = [
        'anthropic-phi-us',
        'stripe-billing-us',
        'sentry-business-us',
      ];
      for (final id in must) {
        final t = CrossBorderTransferRegister.byId(id)!;
        expect(
          t.tiaDocPath,
          startsWith('docs/compliance/TIA_'),
          reason: '$id MUST reference its TIA narrative',
        );
        expect(t.tiaDocPath, endsWith('.md'));
      }
    });

    test('intra-EEA transfers carry no TIA + no supplementary measures', () {
      for (final t in CrossBorderTransferRegister.transfers) {
        if (t.mechanism != TransferMechanism.intraEea) continue;
        expect(t.tiaDocPath, isEmpty, reason: t.id);
        expect(t.supplementaryMeasures, isEmpty, reason: t.id);
      }
    });

    test('bySubprocessor slices correctly', () {
      for (final t in CrossBorderTransferRegister.transfers) {
        final slice = CrossBorderTransferRegister.bySubprocessor(
          t.subprocessorId,
        );
        expect(slice, contains(t));
        for (final s in slice) {
          expect(s.subprocessorId, t.subprocessorId);
        }
      }
    });

    test('outsideEea returns only non-intraEea transfers', () {
      for (final t in CrossBorderTransferRegister.outsideEea()) {
        expect(t.mechanism, isNot(TransferMechanism.intraEea));
      }
    });
  });

  group('requiresTia + isCrossBorder helpers', () {
    test('requiresTia: false for intra-EEA + adequacy', () {
      final eea = CrossBorderTransferRegister.byId('hetzner-phi-eu')!;
      expect(requiresTia(eea), isFalse);
    });

    test('requiresTia: true for SCC transfers', () {
      final scc = CrossBorderTransferRegister.byId('anthropic-phi-us')!;
      expect(requiresTia(scc), isTrue);
    });

    test('isCrossBorder: false for intra-EEA', () {
      final eea = CrossBorderTransferRegister.byId('hetzner-phi-eu')!;
      expect(isCrossBorder(eea), isFalse);
    });

    test('isCrossBorder: true for SCC transfers', () {
      final scc = CrossBorderTransferRegister.byId('anthropic-phi-us')!;
      expect(isCrossBorder(scc), isTrue);
    });
  });
}
