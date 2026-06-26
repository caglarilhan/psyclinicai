import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/identity_verification_policy.dart';

void main() {
  group('IdentityVerificationPolicy — pinned invariants', () {
    test('every RequestChannel has exactly one pinned policy', () {
      final pinned = IdentityVerificationPolicy.policies
          .map((p) => p.channel)
          .toSet();
      expect(pinned, equals(RequestChannel.values.toSet()));
      expect(
        IdentityVerificationPolicy.policies.length,
        RequestChannel.values.length,
      );
    });

    test('forChannel resolves every enum value', () {
      for (final c in RequestChannel.values) {
        expect(IdentityVerificationPolicy.forChannel(c).channel, c);
      }
    });

    test('every policy has ≥1 required proof + anchors', () {
      for (final p in IdentityVerificationPolicy.policies) {
        expect(p.requiredProofs, isNotEmpty, reason: p.channel.name);
        expect(p.regulatoryRefs, isNotEmpty, reason: p.channel.name);
      }
    });

    test('authenticated portal needs only the live session', () {
      final p = IdentityVerificationPolicy.forChannel(
        RequestChannel.authenticatedPortal,
      );
      expect(p.requiredProofs, [VerificationProof.liveSession]);
      expect(p.maxTurnaroundHours, 0);
    });

    test(
      'postal + authorised representative require multiple proofs (high-risk)',
      () {
        for (final c in [
          RequestChannel.postalLetter,
          RequestChannel.authorisedRepresentative,
        ]) {
          final p = IdentityVerificationPolicy.forChannel(c);
          expect(
            requiresMultipleProofs(p),
            isTrue,
            reason:
                '${c.name}: low-signal channels MUST require multi-proof '
                'before any PHI release',
          );
        }
      },
    );

    test('authorised representative MUST require power-of-attorney doc', () {
      final p = IdentityVerificationPolicy.forChannel(
        RequestChannel.authorisedRepresentative,
      );
      expect(
        p.requiredProofs,
        contains(VerificationProof.powerOfAttorneyDoc),
        reason:
            'representative path MUST present PoA — otherwise anyone '
            'claiming representation could exfiltrate the chart',
      );
    });

    test('postal channel MUST require gov ID match', () {
      final p = IdentityVerificationPolicy.forChannel(
        RequestChannel.postalLetter,
      );
      expect(
        p.requiredProofs,
        contains(VerificationProof.governmentIdMatch),
        reason:
            'postal letters carry the lowest baseline signal — gov ID match '
            'is mandatory',
      );
    });

    test('every policy cites GDPR Recital 64 or KVKK md. 13', () {
      for (final p in IdentityVerificationPolicy.policies) {
        final blob = p.regulatoryRefs.join(' | ');
        expect(
          blob.contains('Recital 64') || blob.contains('md. 13'),
          isTrue,
          reason:
              '${p.channel.name}: must cite the canonical identity-'
              'verification anchor',
        );
      }
    });

    test('maxTurnaroundHours falls within GDPR Art. 12(3) 30d ceiling', () {
      const ceiling = 30 * 24;
      for (final p in IdentityVerificationPolicy.policies) {
        expect(
          p.maxTurnaroundHours,
          lessThanOrEqualTo(ceiling),
          reason:
              '${p.channel.name}: verification turnaround must fit inside '
              'the GDPR Art. 12(3) one-month window',
        );
      }
    });

    test('turnaround monotonic: portal < email < phone < postal', () {
      final portal = IdentityVerificationPolicy.forChannel(
        RequestChannel.authenticatedPortal,
      );
      final email = IdentityVerificationPolicy.forChannel(
        RequestChannel.registeredEmail,
      );
      final phone = IdentityVerificationPolicy.forChannel(
        RequestChannel.phoneCall,
      );
      final post = IdentityVerificationPolicy.forChannel(
        RequestChannel.postalLetter,
      );
      expect(portal.maxTurnaroundHours, lessThan(email.maxTurnaroundHours));
      expect(email.maxTurnaroundHours, lessThan(phone.maxTurnaroundHours));
      expect(phone.maxTurnaroundHours, lessThan(post.maxTurnaroundHours));
    });

    test('fallbackOnFail points to a documented channel or null', () {
      const knownChannels = <RequestChannel?>{
        null,
        RequestChannel.authenticatedPortal,
        RequestChannel.registeredEmail,
        RequestChannel.phoneCall,
        RequestChannel.postalLetter,
        RequestChannel.authorisedRepresentative,
      };
      for (final p in IdentityVerificationPolicy.policies) {
        expect(
          knownChannels,
          contains(p.fallbackOnFail),
          reason: p.channel.name,
        );
      }
    });
  });

  group('helpers', () {
    test('requiresMultipleProofs: false for portal (single proof)', () {
      final p = IdentityVerificationPolicy.forChannel(
        RequestChannel.authenticatedPortal,
      );
      expect(requiresMultipleProofs(p), isFalse);
    });

    test('requiresMultipleProofs: true for postal (2 proofs)', () {
      final p = IdentityVerificationPolicy.forChannel(
        RequestChannel.postalLetter,
      );
      expect(requiresMultipleProofs(p), isTrue);
    });

    test('satisfiesProof: true when proof is in the required list', () {
      final p = IdentityVerificationPolicy.forChannel(
        RequestChannel.registeredEmail,
      );
      expect(
        satisfiesProof(policy: p, proof: VerificationProof.magicLink),
        isTrue,
      );
    });

    test('satisfiesProof: false when proof is not in the required list', () {
      final p = IdentityVerificationPolicy.forChannel(
        RequestChannel.registeredEmail,
      );
      expect(
        satisfiesProof(policy: p, proof: VerificationProof.voiceRecall),
        isFalse,
      );
    });
  });
}
