/// Coverage for HeuristicSoapDrafter — sub-extractor rules
/// (subjective, objective, assessment themes, plan), risk flag
/// trip, empty transcript shell, SOAP / DAP render paths.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/heuristic_soap_drafter.dart';
import 'package:psyclinicai/services/copilot/soap_generator_service.dart';

void main() {
  const drafter = HeuristicSoapDrafter();

  group('sub-extractors', () {
    test('subjective picks patient-voice sentences', () {
      const transcript =
          'I feel hopeless about work. '
          'Patient appeared tearful. '
          'My sleep has been bad. '
          'Scheduled the next session for Tuesday.';
      final s = drafter.extractSubjective(transcript);
      expect(s, contains('I feel hopeless about work.'));
      expect(s, contains('My sleep has been bad.'));
      expect(s, isNot(contains('Patient appeared tearful.')));
    });

    test('objective picks clinician-voice + time mentions', () {
      const transcript =
          'I feel anxious. '
          'Patient appeared tearful with restricted affect. '
          'Session start 10:00, end 10:53. '
          'Lately I have been ruminating.';
      final o = drafter.extractObjective(transcript);
      expect(o, contains('Patient appeared tearful with restricted affect.'));
      expect(o, contains('Session start 10:00, end 10:53.'));
    });

    test('assessment themes detect depression / anxiety / risk', () {
      const transcript =
          'I feel hopeless and anxious lately. '
          'Some days I have suicidal thoughts.';
      final a = drafter.extractAssessmentThemes(transcript);
      expect(a, contains('depression'));
      expect(a, contains('anxiety'));
      expect(a, contains('suicide-risk'));
    });

    test('plan picks action-verb sentences', () {
      const transcript =
          'I feel okay. '
          'Scheduled next session for Tuesday. '
          'Will call patient on Friday. '
          'Homework: track sleep nightly.';
      final p = drafter.extractPlan(transcript);
      expect(p, hasLength(3));
    });
  });

  group('draft', () {
    test('empty transcript returns a clean shell', () {
      final note = drafter.draft(transcript: '');
      expect(note.rawMarkdown, contains('No transcript content provided'));
      expect(note.flaggedRisk, isFalse);
    });

    test('SOAP format renders the four headings', () {
      final note = drafter.draft(
        transcript:
            'I feel anxious about work. '
            'Patient affect was tense. '
            'Homework: 10-min breathing nightly.',
      );
      expect(note.rawMarkdown, contains('S — Subjective'));
      expect(note.rawMarkdown, contains('O — Objective'));
      expect(note.rawMarkdown, contains('A — Assessment'));
      expect(note.rawMarkdown, contains('P — Plan'));
    });

    test('DAP format collapses S+O into Data', () {
      final note = drafter.draft(
        transcript: 'I feel anxious. Patient was tense.',
        format: SoapFormat.dap,
      );
      expect(note.rawMarkdown, contains('D — Data'));
      expect(note.rawMarkdown, isNot(contains('S — Subjective')));
    });

    test('risk theme trips flaggedRisk on the SoapNote', () {
      final note = drafter.draft(
        transcript: 'Patient says "I want to end my life some days".',
      );
      expect(note.flaggedRisk, isTrue);
    });

    test('mild transcript without risk language does not flag', () {
      final note = drafter.draft(
        transcript:
            'I feel okay this week. '
            'Patient mood is improved. '
            'Next session in two weeks.',
      );
      expect(note.flaggedRisk, isFalse);
    });
  });
}
