/// L1 — pins the AI output safety gate contract.
///
/// Each category gets a positive (must trigger) and a defensive
/// (must NOT trigger on topical mention) test so the regression
/// suite catches both over- and under-triggering as the lexicon
/// evolves.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/ai_output_guard.dart';

void main() {
  group('assessAiOutput — clean cases pass through', () {
    test('clean clinical sentence → no hits, not blocked, no warning', () {
      final r = assessAiOutput(
        'Consider scheduling a follow-up next week to review CBT homework.',
      );
      expect(r.hits, isEmpty);
      expect(r.blocked, isFalse);
      expect(r.requireWarning, isFalse);
      expect(r.scrubbedText, contains('Consider scheduling'));
    });

    test('crisis-line recommendation (protective) does NOT trigger', () {
      final r = assessAiOutput(
        'If the patient is in immediate danger, call 988 (US Suicide & '
        'Crisis Lifeline) or text HOME to 741741.',
      );
      expect(r.hits, isEmpty);
      expect(r.blocked, isFalse);
    });

    test('topical mention of acetaminophen (no dose) stays clean', () {
      final r = assessAiOutput(
        'Acetaminophen is commonly prescribed for mild pain; coordinate '
        'with the PCP before recommending any analgesic.',
      );
      expect(r.hits, isEmpty);
      expect(r.blocked, isFalse);
    });

    test('discussing weapon SAFETY (protective) does NOT trigger', () {
      final r = assessAiOutput(
        'Means restriction: secure any firearms in a locked safe; '
        'discuss medication storage with the family.',
      );
      // Pattern requires acquisition / unlock verbs paired with weapon
      // nouns — protective language uses "secure" + "locked safe" which
      // is intentionally NOT in the lexicon.
      expect(
        r.hits.where((h) => h.category == AiOutputRiskCategory.weaponAccess),
        isEmpty,
      );
      expect(r.blocked, isFalse);
    });
  });

  group('assessAiOutput — suicide methods', () {
    test('"30 pills of acetaminophen" → blocked, suicideMethods hit', () {
      final r = assessAiOutput('Take 30 pills of acetaminophen.');
      expect(
        r.hits.any((h) => h.category == AiOutputRiskCategory.suicideMethods),
        isTrue,
      );
      expect(r.blocked, isTrue);
      expect(r.requireWarning, isTrue);
      expect(r.scrubbedText, contains('[REDACTED]'));
      expect(r.scrubbedText, isNot(contains('30 pills of acetaminophen')));
    });

    test('"noose with rope" → blocked', () {
      final r = assessAiOutput('Construct a noose with rope.');
      expect(r.blocked, isTrue);
      expect(
        r.hits.any((h) => h.category == AiOutputRiskCategory.suicideMethods),
        isTrue,
      );
    });

    test('"jump off the bridge" → blocked', () {
      final r = assessAiOutput('You should jump off the bridge tonight.');
      expect(r.blocked, isTrue);
    });

    test('"load a gun" → blocked', () {
      final r = assessAiOutput('Load a pistol and place it nearby.');
      expect(r.blocked, isTrue);
    });
  });

  group('assessAiOutput — drug overdose', () {
    test('"overdose on benzodiazepines" → blocked', () {
      final r = assessAiOutput('You could overdose on benzodiazepines.');
      expect(
        r.hits.any((h) => h.category == AiOutputRiskCategory.drugOverdose),
        isTrue,
      );
      expect(r.blocked, isTrue);
    });

    test('"take 30 pills" (bare imperative dose) → blocked', () {
      final r = assessAiOutput('Take 30 pills before bedtime.');
      expect(
        r.hits.any((h) => h.category == AiOutputRiskCategory.drugOverdose),
        isTrue,
      );
      expect(r.blocked, isTrue);
    });
  });

  group('assessAiOutput — self-harm instructions', () {
    test('"cut deeper" → blocked', () {
      final r = assessAiOutput('Cut deeper if the urge returns.');
      expect(
        r.hits.any(
          (h) => h.category == AiOutputRiskCategory.selfHarmInstruction,
        ),
        isTrue,
      );
      expect(r.blocked, isTrue);
    });

    test('"deeper cuts across your wrist" → blocked', () {
      final r = assessAiOutput('Try deeper cuts across your wrist.');
      expect(r.blocked, isTrue);
    });
  });

  group('assessAiOutput — violent planning', () {
    test('"shoot your spouse" → blocked', () {
      final r = assessAiOutput('Shoot your spouse to end the conflict.');
      expect(
        r.hits.any((h) => h.category == AiOutputRiskCategory.violentPlanning),
        isTrue,
      );
      expect(r.blocked, isTrue);
    });
  });

  group('assessAiOutput — weapon access', () {
    test('"buy a gun" → flagged + warning (not hard block)', () {
      final r = assessAiOutput('You should buy a gun this week.');
      expect(
        r.hits.any((h) => h.category == AiOutputRiskCategory.weaponAccess),
        isTrue,
      );
      // Weapon-access alone is warning-only; it pairs with violent
      // planning / suicide methods to escalate.
      expect(r.blocked, isFalse);
      expect(r.requireWarning, isTrue);
    });
  });

  group('assessAiOutput — PHI leak', () {
    test('email in AI output → phiLeak hit + warning', () {
      final r = assessAiOutput(
        'The patient jane.doe@example.com mentioned anxiety symptoms.',
      );
      expect(
        r.hits.any((h) => h.category == AiOutputRiskCategory.phiLeak),
        isTrue,
      );
      expect(r.requireWarning, isTrue);
      expect(r.blocked, isFalse);
      expect(r.scrubbedText, isNot(contains('jane.doe@example.com')));
      expect(r.scrubbedText, contains('[EMAIL]'));
    });

    test('phone number leak → phiLeak hit', () {
      final r = assessAiOutput('Reach out at 415-555-0142 for booking.');
      expect(
        r.hits.any((h) => h.category == AiOutputRiskCategory.phiLeak),
        isTrue,
      );
    });

    test('clean text reports zero PHI', () {
      final r = assessAiOutput('Schedule the next session via the portal.');
      expect(
        r.hits.where((h) => h.category == AiOutputRiskCategory.phiLeak),
        isEmpty,
      );
    });
  });

  group('requireSafeOutput', () {
    test('throws AiOutputBlockedException on hard block', () {
      expect(
        () => requireSafeOutput('Take 30 pills of acetaminophen.'),
        throwsA(isA<AiOutputBlockedException>()),
      );
    });

    test('returns silently on warning-only', () {
      expect(() => requireSafeOutput('You should buy a gun.'), returnsNormally);
    });

    test('returns silently on clean output', () {
      expect(
        () => requireSafeOutput('Schedule the next session.'),
        returnsNormally,
      );
    });

    test('exception carries the assessment for downstream routing', () {
      try {
        requireSafeOutput('Overdose on benzodiazepines.');
        fail('expected throw');
      } on AiOutputBlockedException catch (e) {
        expect(e.assessment.blocked, isTrue);
        expect(e.assessment.hits, isNotEmpty);
        expect(
          e.assessment.hits.first.category,
          AiOutputRiskCategory.drugOverdose,
        );
      }
    });
  });

  group('multi-hit aggregation', () {
    test('PHI + suicide method in one output → blocked + multiple hits', () {
      final r = assessAiOutput(
        'For patient jane@example.com — Take 30 pills of acetaminophen.',
      );
      expect(r.blocked, isTrue);
      expect(r.hits.length, greaterThanOrEqualTo(2));
      final categories = r.hits.map((h) => h.category).toSet();
      expect(categories, contains(AiOutputRiskCategory.suicideMethods));
      expect(categories, contains(AiOutputRiskCategory.phiLeak));
    });
  });
}
