import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/services/ai_scribe/ai_scribe_client.dart';
import 'package:psyclinicai/services/ai_scribe/soap_section_catalog.dart';

void main() {
  AiScribeClient withMock(MockClient mock) => AiScribeClient(
        baseUrl: 'https://example.test/aiScribeDraftSoap',
        idTokenProvider: () async => 'tok-xyz',
        httpClient: mock,
      );

  group('AiScribeClient', () {
    test('posts payload + Bearer token + parses 200 draft', () async {
      http.Request? captured;
      final mock = MockClient((req) async {
        captured = req;
        return http.Response(
          jsonEncode({
            'sessionId': 'sess-1',
            'schemaVersion': 1,
            'generatedAt': 1717000000000,
            'provider': 'anthropic',
            'model': 'claude-haiku-4-5',
            'sections': {
              'subjective': {
                'chief_complaint': {
                  'value': 'Worsening sleep',
                  'transcript_spans': [
                    {'start_ms': 10, 'end_ms': 240},
                  ],
                },
              },
            },
            'phiRedactions': 0,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = withMock(mock);
      final draft = await client.draftSoap(
        tenantId: 'tenant-a',
        sessionId: 'sess-1',
        transcript: 'Patient reports sleep loss.',
        patientId: 'pt-9',
        sections: const [SoapSection.subjective],
      );

      expect(draft.sessionId, 'sess-1');
      expect(draft.schemaVersion, 1);
      expect(draft.provider, 'anthropic');
      expect(
        draft.stringField(SoapSection.subjective, 'chief_complaint'),
        'Worsening sleep',
      );

      expect(captured?.headers['authorization'], 'Bearer tok-xyz');
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['tenantId'], 'tenant-a');
      expect(body['patientId'], 'pt-9');
      expect(body['sections'], ['subjective']);
    });

    test('throws AiScribeException on non-2xx', () async {
      final mock = MockClient(
        (req) async => http.Response('{"error":"consent_required"}', 403),
      );
      final client = withMock(mock);
      expect(
        () => client.draftSoap(
          tenantId: 't',
          sessionId: 's',
          transcript: 'x',
        ),
        throwsA(isA<AiScribeException>()),
      );
    });

    test('throws when id token is missing', () async {
      final client = AiScribeClient(
        baseUrl: 'https://example.test/aiScribeDraftSoap',
        idTokenProvider: () async => null,
        httpClient: MockClient((_) async => http.Response('', 200)),
      );
      expect(
        () => client.draftSoap(
          tenantId: 't',
          sessionId: 's',
          transcript: 'x',
        ),
        throwsA(isA<AiScribeException>()),
      );
    });
  });

  group('AiScribeDraft.stringField', () {
    test('returns empty string when section absent', () {
      const d = AiScribeDraft(
        sessionId: 's',
        schemaVersion: 1,
        generatedAtMillis: 0,
        provider: 'anthropic',
        model: 'm',
        sections: {},
        phiRedactions: 0,
      );
      expect(d.stringField(SoapSection.plan, 'next_session'), '');
    });

    test('joins list values with newlines', () {
      const d = AiScribeDraft(
        sessionId: 's',
        schemaVersion: 1,
        generatedAtMillis: 0,
        provider: 'anthropic',
        model: 'm',
        sections: {
          'subjective': {
            'patient_reported_symptoms': {
              'value': ['Sleep loss', 'Low appetite'],
            },
          },
        },
        phiRedactions: 0,
      );
      expect(
        d.stringField(SoapSection.subjective, 'patient_reported_symptoms'),
        'Sleep loss\nLow appetite',
      );
    });
  });
}
