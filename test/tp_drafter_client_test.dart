import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/services/treatment_plan_drafter/tp_drafter_catalog.dart';
import 'package:psyclinicai/services/treatment_plan_drafter/tp_drafter_client.dart';

void main() {
  TpDrafterClient withMock(MockClient mock) => TpDrafterClient(
    draftUrl: 'https://example.test/tpDraftPlan',
    idTokenProvider: () async => 'tok',
    httpClient: mock,
  );

  group('TpDrafterClient', () {
    test('posts (disorder, modality, problems) + parses 2xx draft', () async {
      http.Request? captured;
      final mock = MockClient((req) async {
        captured = req;
        return http.Response(
          jsonEncode({
            'schemaVersion': 1,
            'generatedAt': 1717000000000,
            'provider': 'anthropic',
            'model': 'claude-haiku-4-5',
            'protocolLabel': 'CBT for Major Depressive Disorder',
            'requiresSupervisorCoSign': false,
            'phiRedactions': 0,
            'plan': {
              'presenting_problems': ['Sleep loss'],
              'smart_goals': [
                {
                  'goal_text': 'Sleep 7 hours by week 4',
                  'specific': 'Sleep onset',
                  'measurable': 'PHQ-9 + sleep diary',
                  'achievable': 'yes',
                  'relevant': 'reduces depressive load',
                  'time_bound': 'week 4',
                  'cited_guideline': 'NICE CG90 depression in adults',
                },
              ],
              'session_plan': [
                {
                  'session_index': 1,
                  'focus': 'Psychoeducation',
                  'interventions': ['Sleep hygiene'],
                },
              ],
              'homework_templates': ['Sleep diary'],
              'outcome_reassessment': {
                'instrument': 'phq9',
                'cadence_label': 'every 2 weeks',
              },
              'risk_review_cadence': 'C-SSRS at every visit',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = withMock(mock);
      final draft = await client.draftPlan(
        tenantId: 't',
        patientId: 'pt-1',
        disorder: TpDisorderId.majorDepressiveDisorder,
        modality: TpModality.cbt,
        presentingProblems: const ['Sleep loss'],
      );
      expect(draft.protocolLabel, 'CBT for Major Depressive Disorder');
      expect(draft.requiresSupervisorCoSign, isFalse);
      expect(draft.smartGoals().length, 1);
      expect(draft.sessionPlan().length, 1);
      expect(draft.riskReviewCadence(), 'C-SSRS at every visit');

      expect(captured?.headers['authorization'], 'Bearer tok');
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['disorder'], 'majorDepressiveDisorder');
      expect(body['modality'], 'cbt');
    });

    test('throws TpDrafterException on non-2xx', () async {
      final mock = MockClient(
        (_) async => http.Response('{"error":"unsupported_protocol"}', 400),
      );
      final client = withMock(mock);
      expect(
        () => client.draftPlan(
          tenantId: 't',
          disorder: TpDisorderId.insomniaDisorder,
          modality: TpModality.emdr,
          presentingProblems: const ['x'],
        ),
        throwsA(isA<TpDrafterException>()),
      );
    });
  });

  group('TpDraftedPlan helpers', () {
    test('returns empty list when sections absent', () {
      const d = TpDraftedPlan(
        schemaVersion: 1,
        generatedAtMillis: 0,
        provider: 'anthropic',
        model: 'm',
        protocolLabel: 'x',
        requiresSupervisorCoSign: false,
        plan: {},
        phiRedactions: 0,
      );
      expect(d.smartGoals(), isEmpty);
      expect(d.sessionPlan(), isEmpty);
      expect(d.presentingProblems(), isEmpty);
      expect(d.riskReviewCadence(), '');
    });
  });
}
