import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/ai_diagnosis_service.dart';
import 'package:psyclinicai/services/ai/llm_proxy_client.dart';

void main() {
  group('AiDiagnosisService.toolSchema', () {
    test('declares the submit_differential tool with required fields', () {
      expect(AiDiagnosisService.toolSchema['name'], 'submit_differential');
      final schema =
          AiDiagnosisService.toolSchema['input_schema'] as Map<String, dynamic>;
      expect(schema['required'], contains('candidates'));
      final items =
          (schema['properties'] as Map<String, dynamic>)['candidates']['items']
              as Map<String, dynamic>;
      expect(items['required'], containsAll(['code', 'name', 'confidence']));
    });
  });

  group('suggestDifferential', () {
    test('parses a tool-use payload into DifferentialCandidate list', () async {
      final client = LlmProxyClientStub(
        responder: (req) {
          expect(req.prompt, contains('[NAME]'));
          expect(req.prompt, isNot(contains('John Demo')));
          return LlmCompletion(
            text: '',
            model: req.model,
            inputTokens: 100,
            outputTokens: 200,
            tenantUsdCost: req.model.usdPer5Min,
            toolUse: const {
              'name': 'submit_differential',
              'candidates': [
                {
                  'code': 'F32.1',
                  'name': 'MDD, single episode, moderate',
                  'confidence': 0.78,
                  'criteriaMet': ['A.1 depressed mood', 'A.2 anhedonia'],
                  'criteriaMissing': ['A.5 psychomotor agitation'],
                  'differentialFrom': ['F33.1 recurrent MDD'],
                },
                {
                  'code': 'F41.1',
                  'name': 'Generalised anxiety disorder',
                  'confidence': 0.32,
                  'criteriaMet': ['B excessive worry'],
                  'criteriaMissing': ['C duration ≥ 6 months'],
                  'differentialFrom': <String>[],
                },
              ],
            },
          );
        },
      );
      final svc = AiDiagnosisService(client);
      final candidates = await svc.suggestDifferential(
        tenantId: 't-1',
        vignette: 'John Demo reports 3 weeks of low mood …',
        symptoms: const ['Depressed mood', 'Diminished interest'],
        patientNames: const ['John Demo'],
      );
      expect(candidates.length, 2);
      expect(candidates.first.code, 'F32.1');
      expect(candidates.first.confidence, closeTo(0.78, 0.01));
    });

    test('throws FormatException when tool payload is missing', () async {
      final client = LlmProxyClientStub(
        responder: (req) => LlmCompletion(
          text: 'free text only',
          model: req.model,
          inputTokens: 10,
          outputTokens: 5,
          tenantUsdCost: req.model.usdPer5Min,
        ),
      );
      final svc = AiDiagnosisService(client);
      expect(
        () => svc.suggestDifferential(
          tenantId: 't-1',
          vignette: 'x',
          symptoms: const [],
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
