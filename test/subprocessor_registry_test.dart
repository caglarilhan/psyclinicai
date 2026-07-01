import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/subprocessor.dart';
import 'package:psyclinicai/services/compliance/subprocessor_registry.dart';

void main() {
  group('SubprocessorRegistry', () {
    test('exposes a non-empty curated list', () {
      expect(SubprocessorRegistry.entries, isNotEmpty);
      expect(
        SubprocessorRegistry.entries.length,
        greaterThanOrEqualTo(10),
        reason: 'the plan calls out at least 10 vendors',
      );
    });

    test('every id is unique and lowercase kebab', () {
      final ids = SubprocessorRegistry.entries.map((s) => s.id).toSet();
      expect(ids.length, SubprocessorRegistry.entries.length);
      for (final id in ids) {
        expect(
          id,
          matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')),
          reason: 'id "$id" should be lowercase kebab',
        );
      }
    });

    test('lastReviewed is a YYYY-MM stamp', () {
      expect(
        SubprocessorRegistry.lastReviewed,
        matches(RegExp(r'^\d{4}-\d{2}$')),
      );
    });

    test('every entry has a non-empty transfer mechanism', () {
      for (final s in SubprocessorRegistry.entries) {
        expect(
          s.transferMechanism,
          isNotEmpty,
          reason: '${s.id} must document its transfer mechanism',
        );
      }
    });

    test('byId resolves known vendors and returns null otherwise', () {
      expect(SubprocessorRegistry.byId('stripe')?.name, contains('Stripe'));
      expect(SubprocessorRegistry.byId('anthropic')?.id, 'anthropic');
      expect(SubprocessorRegistry.byId('unknown-vendor'), isNull);
    });

    test('withCrossBorderTransfer returns vendors that rely on SCC/IDTA', () {
      final crossBorder = SubprocessorRegistry.withCrossBorderTransfer.toList();
      // Anthropic and Sentry both rely on EU SCCs.
      expect(crossBorder.any((s) => s.id == 'anthropic'), isTrue);
      expect(crossBorder.any((s) => s.id == 'sentry'), isTrue);
      // Hetzner is EU-resident → must NOT appear.
      expect(crossBorder.any((s) => s.id == 'hetzner'), isFalse);
    });

    test('every AI vendor is gated on BYOK in its purpose copy', () {
      for (final s in SubprocessorRegistry.entries) {
        if (s.id == 'anthropic' || s.id == 'openai') {
          expect(
            s.purpose.toLowerCase().contains('byok') ||
                s.purpose.toLowerCase().contains('opt-in'),
            isTrue,
            reason: '${s.id} purpose should make BYOK / opt-in nature explicit',
          );
        }
      }
    });

    test('Demo-tier LLMs (Groq + Gemini) are pinned as high-risk, no PHI', () {
      for (final id in ['groq', 'google-gemini']) {
        final s = SubprocessorRegistry.byId(id);
        expect(s, isNotNull, reason: '$id must be in the registry');
        expect(
          s!.risk,
          SubprocessorRisk.high,
          reason:
              '$id ships without a BAA and must be marked high-risk so '
              'the trust center flags it clearly',
        );
        expect(
          s.purpose.toLowerCase(),
          contains('demo'),
          reason:
              '$id purpose must call out that only Demo-tier synthetic '
              'vignettes are sent — never PHI',
        );
        expect(
          s.transferMechanism.toLowerCase().contains('no baa') ||
              s.transferMechanism.toLowerCase().contains('does not process'),
          isTrue,
          reason:
              '$id transfer mechanism must document that no BAA applies '
              'because Demo tier does not process PHI',
        );
      }
    });

    test('SubprocessorRisk covers low / medium / high', () {
      expect(SubprocessorRisk.values, hasLength(3));
      expect(SubprocessorRisk.values.map((r) => r.name).toSet(), {
        'low',
        'medium',
        'high',
      });
    });
  });
}
