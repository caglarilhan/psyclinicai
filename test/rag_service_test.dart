import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/services/ai/rag_client.dart';
import 'package:psyclinicai/services/ai/rag_service.dart';

void main() {
  group('RagService', () {
    test('disabled service short-circuits to RagResult.disabled', () async {
      final svc = RagService();
      expect(svc.isEnabled, isFalse);

      final qr = await svc.query(question: 'x');
      expect(qr.isDisabled, isTrue);
      expect(qr.answer, isNull);

      final ar = await svc.analyze(
        patientContext: const {'age': 30},
        question: 'x',
      );
      expect(ar.isDisabled, isTrue);

      final fb = await svc.feedback(auditId: 'a', score: 'up');
      expect(fb, isNull);
    });

    test('enabled service maps a 200 into RagResult.ok', () async {
      final mock = MockClient((req) async {
        return http.Response(
            jsonEncode({
              'answer': 'CBT first-line for moderate MDD.',
              'citations': const <Map<String, dynamic>>[],
              'model_used': 'haiku-4.5',
              'phi_detected': false,
              'audit_id': 'aud_1',
              'request_ms': 120,
            }),
            200);
      });
      final svc = RagService(
        client: RagClient(
          baseUrl: 'https://hub.test',
          apiKey: 'pck_test',
          httpClient: mock,
        ),
      );
      expect(svc.isEnabled, isTrue);
      final r = await svc.query(question: 'first-line for MDD?');
      expect(r.isOk, isTrue);
      expect(r.answer!.auditId, 'aud_1');
    });

    test('enabled service converts non-2xx into RagResult.error (no throw)',
        () async {
      final mock = MockClient(
          (req) async => http.Response('{"error":"hub_down"}', 503));
      final svc = RagService(
        client: RagClient(
          baseUrl: 'https://hub.test',
          apiKey: 'pck_test',
          httpClient: mock,
        ),
      );
      final r = await svc.query(question: 'x');
      expect(r.isError, isTrue);
      expect(r.errorMessage, contains('503'));
      expect(r.errorMessage, contains('hub_down'));
    });

    test('feedback is best-effort: returns null on HTTP error', () async {
      final mock = MockClient(
          (req) async => http.Response('{"error":"forbidden"}', 403));
      final svc = RagService(
        client: RagClient(
          baseUrl: 'https://hub.test',
          apiKey: 'pck_test',
          httpClient: mock,
        ),
      );
      final id = await svc.feedback(auditId: 'aud_x', score: 'down');
      expect(id, isNull);
    });
  });
}
