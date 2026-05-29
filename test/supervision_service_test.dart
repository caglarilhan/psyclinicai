import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/soap_generator_service.dart'
    show Modality;
import 'package:psyclinicai/services/copilot/supervision_service.dart';

void main() {
  final svc = SupervisionService();

  test('parses a valid report and clamps the score', () {
    const json = '{"fidelityScore":140,"fidelityNotes":"Strong CBT structure.",'
        '"strengths":["Clear agenda"],"growthAreas":["More Socratic questioning"],'
        '"reflectiveQuestions":["What kept the client stuck?"],'
        '"summary":"The therapist used CBT well."}';
    final r = svc.parse(json, Modality.cbt)!;
    expect(r.modalityLabel, 'CBT');
    expect(r.fidelityScore, 100); // clamped from 140
    expect(r.strengths, contains('Clear agenda'));
    expect(r.growthAreas, hasLength(1));
    expect(r.reflectiveQuestions, hasLength(1));
  });

  test('returns null on garbage / empty content', () {
    expect(svc.parse('not json', Modality.cbt), isNull);
    expect(
        svc.parse(
            '{"fidelityScore":0,"strengths":[],"growthAreas":[],'
            '"reflectiveQuestions":[],"summary":"","fidelityNotes":""}',
            Modality.cbt),
        isNull);
  });

  test('anonymizedText is de-identified and structured', () {
    const json = '{"fidelityScore":82,"fidelityNotes":"Good adherence.",'
        '"strengths":["Validation"],"growthAreas":["Pacing"],'
        '"reflectiveQuestions":["Where was the client ambivalent?"],'
        '"summary":"The therapist held the frame."}';
    final r = svc.parse(json, Modality.schema)!;
    final text = r.anonymizedText();
    expect(text, contains('SUPERVISION REPORT (de-identified)'));
    expect(text, contains('Schema'));
    expect(text, contains('82/100'));
    expect(text, contains('Strengths'));
    expect(text, contains('Verify anonymization before sharing'));
  });
}
