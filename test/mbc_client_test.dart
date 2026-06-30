import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/services/mbc/mbc_client.dart';

void main() {
  group('MbcPublicClient', () {
    test('posts token + answers, parses 2xx result', () async {
      http.Request? captured;
      final mock = MockClient((req) async {
        captured = req;
        return http.Response(
          jsonEncode({
            'scaleId': 'phq9',
            'score': 10,
            'maxScore': 27,
            'severity': 'moderate',
            'alarmTriggered': true,
            'clinicianAction': 'Treatment plan.',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = MbcPublicClient(
        submitUrl: 'https://example.test/mbcSubmitAssessment',
        httpClient: mock,
      );
      final res = await client.submit(
        token: 'tok-x',
        answers: const [2, 2, 2, 2, 2, 0, 0, 0, 0],
      );
      expect(res.scaleId, 'phq9');
      expect(res.score, 10);
      expect(res.severity, 'moderate');
      expect(res.alarmTriggered, isTrue);
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['token'], 'tok-x');
      expect((body['answers'] as List).length, 9);
    });

    test('throws on non-2xx', () async {
      final mock = MockClient(
        (req) async => http.Response('{"error":"token_expired"}', 410),
      );
      final client = MbcPublicClient(
        submitUrl: 'https://example.test/mbcSubmitAssessment',
        httpClient: mock,
      );
      expect(
        () => client.submit(token: 't', answers: const [0]),
        throwsA(isA<MbcSubmitException>()),
      );
    });
  });

  group('MbcSubmitResult', () {
    test('fromJson maps all fields', () {
      final r = MbcSubmitResult.fromJson(const {
        'scaleId': 'gad7',
        'score': 15,
        'maxScore': 21,
        'severity': 'severe',
        'alarmTriggered': true,
        'clinicianAction': 'Active treatment.',
      });
      expect(r.scaleId, 'gad7');
      expect(r.maxScore, 21);
      expect(r.clinicianAction, 'Active treatment.');
    });
  });
}
