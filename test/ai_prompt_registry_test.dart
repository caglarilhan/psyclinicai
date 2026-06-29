/// L3 — pins the prompt registry + model-card invariants.
///
/// These are the contracts an AI Act / MDR auditor will spot-check
/// first. Drift here breaks the evidence pack.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/ai_model_card.dart';
import 'package:psyclinicai/services/ai/prompt_registry.dart';

void main() {
  group('PromptRegistry — seed coverage', () {
    test('every AI surface has at least one active system prompt', () {
      const surfaces = [
        'safety_plan',
        'treatment_plan_goals',
        'treatment_plan_homework',
        'diagnosis',
        'chatbot',
      ];
      for (final s in surfaces) {
        final p = PromptRegistry.active(s, PromptRole.system);
        expect(
          p,
          isNotNull,
          reason:
              'AI surface "$s" has no active system prompt in the '
              'registry. Add a PromptVersion in PromptRegistry._seed().',
        );
        expect(p!.text, isNotEmpty);
      }
    });

    test('id convention is <surface>.<role>.v<version>', () {
      for (final p in PromptRegistry.all()) {
        final expected = '${p.surface}.${p.role.name}.v${p.version}';
        expect(
          p.id,
          expected,
          reason:
              'Prompt id "${p.id}" does not match convention '
              '<surface>.<role>.v<version>',
        );
      }
    });
  });

  group('PromptRegistry — version invariants', () {
    test('version is a positive int', () {
      for (final p in PromptRegistry.all()) {
        expect(
          p.version,
          greaterThanOrEqualTo(1),
          reason: '${p.id} carries version ${p.version}; must be ≥ 1',
        );
      }
    });

    test('deprecatedAtUtc != null implies replacedBy != null', () {
      for (final p in PromptRegistry.all()) {
        if (p.deprecatedAtUtc != null) {
          expect(
            p.replacedBy,
            isNotNull,
            reason:
                '${p.id} is deprecated but has no replacedBy '
                'pointer — orphan deprecation is invalid.',
          );
        }
      }
    });

    test('replacedBy resolves to a registered id', () {
      for (final p in PromptRegistry.all()) {
        final rb = p.replacedBy;
        if (rb == null) continue;
        expect(
          PromptRegistry.get(rb),
          isNotNull,
          reason:
              '${p.id}.replacedBy points at "$rb" which is not '
              'in the registry.',
        );
      }
    });

    test('isActive matches deprecatedAtUtc == null', () {
      for (final p in PromptRegistry.all()) {
        expect(p.isActive, p.deprecatedAtUtc == null);
      }
    });
  });

  group('PromptRegistry.text', () {
    test('returns the seed body for a known id', () {
      final body = PromptRegistry.text('safety_plan.system.v1');
      expect(body, contains('Stanley-Brown'));
    });

    test('throws PromptNotFoundException for an unknown id', () {
      expect(
        () => PromptRegistry.text('does_not_exist.system.v1'),
        throwsA(isA<PromptNotFoundException>()),
      );
    });
  });

  group('AiModelCardRegistry', () {
    test('lists at least one model card', () {
      expect(AiModelCardRegistry.cards, isNotEmpty);
    });

    test('every card declares the five required safeguards', () {
      const required = [
        'ConsentGuard.requireAi',
        'PromptSafety.fence',
        'requireSafeOutput',
        'recordAiDecision',
        'AiDisclaimer',
      ];
      for (final card in AiModelCardRegistry.cards) {
        for (final s in required) {
          expect(
            card.safeguards.any((entry) => entry.contains(s)),
            isTrue,
            reason:
                'Model card "${card.modelId}" is missing the '
                '"$s" safeguard — every model the app calls into MUST '
                'flow through all five gates.',
          );
        }
      }
    });

    test('forModelId returns the seed card for a known id', () {
      final c = AiModelCardRegistry.forModelId('claude-haiku-4-5-20251001');
      expect(c, isNotNull);
      expect(c!.vendor, 'Anthropic PBC');
    });

    test('forModelId returns null for an unknown id', () {
      expect(AiModelCardRegistry.forModelId('unknown-model'), isNull);
    });

    test('every card cites its risk class + training attestation', () {
      for (final card in AiModelCardRegistry.cards) {
        expect(card.riskClass, isNotEmpty);
        expect(card.trainingDataAttestation, startsWith('http'));
        expect(card.intendedUse, isNotEmpty);
      }
    });
  });
}
