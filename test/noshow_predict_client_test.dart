import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/services/noshow/noshow_feature_catalog.dart';
import 'package:psyclinicai/services/noshow/noshow_predict_client.dart';

void main() {
  group('NoShowPredictClient', () {
    test('posts features + parses 2xx prediction', () async {
      http.Request? captured;
      final mock = MockClient((req) async {
        captured = req;
        return http.Response(
          jsonEncode({
            'probability': 0.55,
            'tier': 'high',
            'modelVersion': 'v1-baseline-2026-06',
            'playbook': {
              'confirmCadenceHours': [72, 48, 24, 4, 1],
              'smsConfirmHours': 24,
              'callConfirmHours': 4,
              'depositRequired': true,
              'waitlistOfferOnCancel': true,
              'estUsdSavedPerSlot': 120,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = NoShowPredictClient(
        predictUrl: 'https://example.test/noshowPredict',
        idTokenProvider: () async => 'tok',
        httpClient: mock,
      );
      final p = await client.predict(
        tenantId: 't',
        appointmentId: 'appt-1',
        patientId: 'pt-1',
        features: const {
          'is_first_session': true,
          'history_noshow_count_90d': 3,
        },
      );
      expect(p.tier, NoShowRiskTier.high);
      expect(p.probability, closeTo(0.55, 1e-9));
      expect(p.playbook.depositRequired, isTrue);
      expect(p.playbook.estUsdSavedPerSlot, 120);
      expect(captured?.headers['authorization'], 'Bearer tok');
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['features'] is Map, isTrue);
    });

    test('throws on non-2xx', () async {
      final mock = MockClient(
        (_) async => http.Response('{"error":"unknown_feature"}', 400),
      );
      final c = NoShowPredictClient(
        predictUrl: 'https://example.test/noshowPredict',
        idTokenProvider: () async => 'tok',
        httpClient: mock,
      );
      expect(
        () => c.predict(
          tenantId: 't',
          appointmentId: 'a',
          patientId: 'p',
          features: const {'bogus': 1},
        ),
        throwsA(isA<NoShowPredictException>()),
      );
    });
  });
}
