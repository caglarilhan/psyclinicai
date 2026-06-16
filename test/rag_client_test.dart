import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/services/ai/rag_client.dart';

void main() {
  group('RagClient (post-Sprint-27 / F-003 close)', () {
    Map<String, dynamic> sampleAnswer({bool phi = false}) => {
          'answer': 'Use C-SSRS for acute suicide risk screening.',
          'citations': [
            {
              'id': 'c1',
              'source': 'NICE',
              'country': 'EU',
              'doc_type': 'guideline',
              'url': 'https://nice.org.uk/g1',
              'score': 0.91,
              'snippet': 'C-SSRS validated for adolescents and adults.',
            }
          ],
          'model_used': 'haiku-4.5',
          'phi_detected': phi,
          'audit_id': 'aud_abc',
          'request_ms': 482,
        };

    Future<String?> tokenProvider() async => 'fake_id_token_xyz';

    test(
        'analyze posts to /v1/rag/analyze, sends Bearer token, NEVER sends X-Api-Key',
        () async {
      Map<String, dynamic>? sent;
      final mock = MockClient((req) async {
        expect(req.url.path, '/v1/rag/analyze');
        expect(req.headers['Authorization'], 'Bearer fake_id_token_xyz');
        expect(req.headers.containsKey('X-Api-Key'), isFalse,
            reason: 'F-003: hub key must not leave the Cloud Function.');
        sent = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode(sampleAnswer()), 200,
            headers: {'content-type': 'application/json'});
      });
      final c = RagClient(
        baseUrl: 'https://api.psyclinic.ai/v1/rag',
        idTokenProvider: tokenProvider,
        httpClient: mock,
      );
      final ans = await c.analyze(
        patientContext: const {'age': 34, 'dx': 'F32.1'},
        question: 'next step?',
        docType: 'guideline',
      );
      expect(sent!['patient_context'], {'age': 34, 'dx': 'F32.1'});
      expect(sent!['region'], 'EU');
      expect(sent!['doc_type'], 'guideline');
      expect(sent!['top_k'], 8);
      expect(ans.auditId, 'aud_abc');
      expect(ans.modelUsed, 'haiku-4.5');
      expect(ans.phiDetected, isFalse);
      expect(ans.citations.single.country, 'EU');
      expect(ans.citations.single.score, closeTo(0.91, 1e-6));
    });

    test('query hits /v1/rag/query and respects topK + omits null docType',
        () async {
      Map<String, dynamic>? sent;
      final mock = MockClient((req) async {
        expect(req.url.path, '/v1/rag/query');
        expect(req.headers['Authorization'], 'Bearer fake_id_token_xyz');
        sent = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode(sampleAnswer(phi: true)), 200);
      });
      final c = RagClient(
        baseUrl: 'https://api.psyclinic.ai/v1/rag',
        idTokenProvider: tokenProvider,
        httpClient: mock,
      );
      final ans = await c.query(question: 'PHQ-9 cutoff?', topK: 3);
      expect(sent!.containsKey('patient_context'), isFalse);
      expect(sent!.containsKey('doc_type'), isFalse);
      expect(sent!['top_k'], 3);
      expect(sent!['region'], 'EU');
      expect(ans.phiDetected, isTrue);
    });

    test('feedback hits /v1/rag/feedback and returns server feedback_id',
        () async {
      final mock = MockClient((req) async {
        expect(req.url.path, '/v1/rag/feedback');
        expect(req.headers['Authorization'], 'Bearer fake_id_token_xyz');
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['audit_id'], 'aud_abc');
        expect(body['score'], 'up');
        expect(body['note'], 'matches local protocol');
        return http.Response(jsonEncode({'feedback_id': 'fb_1'}), 200);
      });
      final c = RagClient(
        baseUrl: 'https://api.psyclinic.ai/v1/rag',
        idTokenProvider: tokenProvider,
        httpClient: mock,
      );
      final id = await c.feedback(
        auditId: 'aud_abc',
        score: 'up',
        note: 'matches local protocol',
      );
      expect(id, 'fb_1');
    });

    test('health hits /v1/rag/health (GET) with Bearer header', () async {
      final mock = MockClient((req) async {
        expect(req.url.path, '/v1/rag/health');
        expect(req.method, 'GET');
        expect(req.headers['Authorization'], 'Bearer fake_id_token_xyz');
        return http.Response(
            jsonEncode({'status': 'ok', 'version': '1.0.0'}), 200);
      });
      final c = RagClient(
        baseUrl: 'https://api.psyclinic.ai/v1/rag',
        idTokenProvider: tokenProvider,
        httpClient: mock,
      );
      final h = await c.health();
      expect(h['status'], 'ok');
      expect(h['version'], '1.0.0');
    });

    test('missing ID token throws RagException(401) without hitting the network',
        () async {
      var called = false;
      final mock = MockClient((req) async {
        called = true;
        return http.Response('{}', 200);
      });
      final c = RagClient(
        baseUrl: 'https://api.psyclinic.ai/v1/rag',
        idTokenProvider: () async => null,
        httpClient: mock,
      );
      await expectLater(
        c.query(question: 'x'),
        throwsA(isA<RagException>().having((e) => e.statusCode, '401', 401)),
      );
      expect(called, isFalse,
          reason: 'no upstream call should happen without an ID token');
    });

    test('non-2xx throws RagException with status + body', () async {
      final mock = MockClient((req) async =>
          http.Response('{"error":"rate_limited"}', 429));
      final c = RagClient(
        baseUrl: 'https://api.psyclinic.ai/v1/rag',
        idTokenProvider: tokenProvider,
        httpClient: mock,
      );
      await expectLater(
        c.query(question: 'x'),
        throwsA(isA<RagException>()
            .having((e) => e.statusCode, 'statusCode', 429)
            .having((e) => e.body, 'body', contains('rate_limited'))),
      );
    });
  });
}
