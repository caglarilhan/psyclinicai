/// Unit-level coverage for the KRİTİK-3 envelope wrap. We mock the
/// HTTP client so we never reach Anthropic — the assertions focus on
/// the envelope contract (riskClass, disclaimer, model metadata,
/// serialisation round-trip) rather than the upstream call.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/models/clinical_decision_support.dart';
import 'package:psyclinicai/services/copilot/api_key_storage.dart';
import 'package:psyclinicai/services/copilot/diagnosis_service.dart';

class _FakeKeys implements ApiKeyStorage {
  _FakeKeys(this._key);
  final String? _key;

  @override
  bool get supportsLocalKey => true;

  @override
  Future<String?> getAnthropicKey() async => _key;

  @override
  Future<String?> getOpenAIKey() async => null;

  @override
  Future<void> setAnthropicKey(String value) async {}

  @override
  Future<void> setOpenAIKey(String value) async {}

  @override
  Future<void> clearAnthropic() async {}

  @override
  Future<void> clearOpenAI() async {}

  @override
  Future<bool> hasAnthropicKey() async => _key != null && _key.isNotEmpty;
}

http.Client _stubClient(Map<String, dynamic> upstreamBody) {
  return MockClient((req) async {
    return http.Response(jsonEncode(upstreamBody), 200);
  });
}

void main() {
  group('DiagnosisService.suggestWithEnvelope', () {
    test('wraps candidates in a ClinicalDecisionSupport envelope', () async {
      final upstream = {
        'content': [
          {
            'type': 'text',
            'text': jsonEncode({
              'candidates': [
                {
                  'name': 'Major Depressive Disorder, single episode, moderate',
                  'icd10': 'F32.1',
                  'dsm5': '296.22',
                  'confidence': 'high',
                  'matchingCriteria': ['Depressed mood (Criterion A.1)'],
                  'missingCriteria': ['Duration unclear'],
                  'nextSteps': ['Administer PHQ-9'],
                },
              ],
            }),
          },
        ],
      };

      final svc = DiagnosisService(
        keyStorage: _FakeKeys('sk-test-fake'),
        client: _stubClient(upstream),
      );

      final envelope = await svc.suggestWithEnvelope(
        vignette: 'Low mood for 3 weeks, anhedonia, sleep disruption.',
        selectedSymptoms: const ['depressed_mood', 'anhedonia'],
      );

      expect(envelope, isA<ClinicalDecisionSupport<List<DxCandidate>>>());
      expect(envelope.riskClass, ClinicalRiskClass.cdss);
      expect(envelope.requiresClinicianConfirmation, isTrue);
      expect(envelope.disclaimer.toLowerCase(), contains('not a diagnosis'));
      expect(envelope.modelId, startsWith('claude-haiku-4-5'));
      expect(envelope.modelVersion, startsWith('pyc-diagnosis-'));
      expect(envelope.suggestion, hasLength(1));
      expect(envelope.suggestion.first.icd10, 'F32.1');

      svc.dispose();
    });

    test('envelope toJson round-trips the DxCandidate list', () async {
      final upstream = {
        'content': [
          {
            'type': 'text',
            'text': jsonEncode({
              'candidates': [
                {
                  'name': 'Generalized Anxiety Disorder',
                  'icd10': 'F41.1',
                  'dsm5': '300.02',
                  'confidence': 'medium',
                  'matchingCriteria': const [],
                  'missingCriteria': const [],
                  'nextSteps': const [],
                },
              ],
            }),
          },
        ],
      };

      final svc = DiagnosisService(
        keyStorage: _FakeKeys('sk-test-fake'),
        client: _stubClient(upstream),
      );

      final envelope = await svc.suggestWithEnvelope(
        vignette: 'Anxiety for 6 months.',
        selectedSymptoms: const ['anxiety'],
      );
      final json = envelope.toJson();
      expect(json['kind'], 'clinical_decision_support');
      expect(json['riskClass'], 'cdss');
      expect(json['requiresClinicianConfirmation'], isTrue);
      final suggestion = json['suggestion'] as List<dynamic>;
      expect(suggestion, hasLength(1));
      expect((suggestion.first as Map)['icd10'], 'F41.1');
      expect((suggestion.first as Map)['confidence'], 'medium');

      svc.dispose();
    });
  });
}
