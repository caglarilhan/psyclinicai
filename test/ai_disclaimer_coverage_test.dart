/// L5 — every AI-touched screen MUST surface a disclaimer.
///
/// The clinician-owns-the-decision message is a Software-as-Medical-
/// Device evidence requirement (FDA Clinical Decision Support
/// Guidance Sep 2022). It's also brand voice — "decision support,
/// not diagnosis" — that a new contributor easily forgets when
/// adding a fresh AI surface.
///
/// This test is a static contract: every screen file in the
/// hard-coded AI-screen list must either:
///   1. Import + use the shared [AiDisclaimer] widget, OR
///   2. Carry an inline disclaimer string that includes
///      "clinician owns" (the agreed-on copy anchor).
///
/// When a new AI surface ships, add its path here AND make sure
/// it carries a disclaimer — otherwise CI fails loudly.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The screens we KNOW surface AI output today. Append-only —
/// removing a screen from this list silences the test, which is
/// the wrong direction.
const _aiScreens = <String>[
  'lib/screens/safety_plan/safety_plan_screen.dart',
  'lib/screens/treatment_plan/treatment_plan_screen.dart',
  'lib/screens/ai/ai_diagnosis_screen.dart',
  'lib/screens/ai/rag_console_screen.dart',
  'lib/screens/ai_chatbot/ai_chatbot_screen.dart',
];

bool _hasDisclaimer(String src) {
  if (src.contains('AiDisclaimer.')) return true;
  // Inline-copy anchor: `ai_diagnosis_screen` keeps its own
  // PsyCard-based disclaimer with this exact phrase. As long as
  // one of the agreed-on phrases is present, count it.
  final inlineAnchors = <String>[
    'clinician owns',
    'Decision-support only',
    'Decision support — clinician',
    'decision-support scaffold',
  ];
  return inlineAnchors.any(src.contains);
}

void main() {
  group('AI disclaimer coverage', () {
    test('every AI screen surfaces a disclaimer', () {
      final missing = <String>[];
      for (final path in _aiScreens) {
        final file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'AI-screen list is stale — $path no longer exists',
        );
        final src = file.readAsStringSync();
        if (!_hasDisclaimer(src)) missing.add(path);
      }
      expect(
        missing,
        isEmpty,
        reason:
            'These AI screens render LLM output but carry no '
            'AiDisclaimer + no agreed-on inline anchor:\n  - '
            '${missing.join('\n  - ')}\n'
            "Add `AiDisclaimer.compact(surface: '<screen>')` near "
            'the AI surface, or include the phrase "clinician owns" '
            'in an existing notice.',
      );
    });

    test('the list itself has no dupes (insertion accident catch)', () {
      expect(_aiScreens.toSet().length, _aiScreens.length);
    });
  });
}
