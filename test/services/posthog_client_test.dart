import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/services/data/posthog_client.dart';

void main() {
  group('PostHogClient (Sprint 31 P0)', () {
    test('disabled when apiKey is empty — capture returns false', () async {
      final mock = MockClient((req) async => http.Response('ok', 200));
      final c = PostHogClient(apiKey: '', httpClient: mock);
      expect(c.enabled, false);
      final ok = await c.capture(
        event: 'landing.visit',
        distinctId: 'anon-123',
      );
      expect(ok, false);
    });

    test('enabled when apiKey present and posts a well-formed payload',
        () async {
      late Map<String, Object?> body;
      late Uri url;
      final mock = MockClient((req) async {
        url = req.url;
        body = jsonDecode(req.body) as Map<String, Object?>;
        return http.Response('{"status":"ok"}', 200);
      });
      final c = PostHogClient(
        apiKey: 'phc_test',
        httpClient: mock,
      );
      final ok = await c.capture(
        event: 'session.first_soap_generated',
        distinctId: 'user_42',
        properties: {'time_to_first_soap_sec': 178},
        timestamp: DateTime.utc(2026, 6, 20, 12, 0, 0),
      );
      expect(ok, true);
      expect(url.host, 'eu.i.posthog.com');
      expect(url.path, '/i/v0/e/');
      expect(body['api_key'], 'phc_test');
      expect(body['event'], 'session.first_soap_generated');
      expect(body['distinct_id'], 'user_42');
      expect(body['timestamp'], '2026-06-20T12:00:00.000Z');
      final props = body['properties'] as Map<String, Object?>;
      expect(props['time_to_first_soap_sec'], 178);
      expect(props[r'$lib'], 'psyclinicai-flutter');
    });

    test('returns false on non-2xx', () async {
      final mock = MockClient((req) async => http.Response('nope', 500));
      final c = PostHogClient(apiKey: 'phc_test', httpClient: mock);
      final ok = await c.capture(
        event: 'landing.visit',
        distinctId: 'anon-1',
      );
      expect(ok, false);
    });

    test('returns false on network error', () async {
      final mock = MockClient((req) async {
        throw Exception('network down');
      });
      final c = PostHogClient(apiKey: 'phc_test', httpClient: mock);
      final ok = await c.capture(
        event: 'landing.visit',
        distinctId: 'anon-1',
      );
      expect(ok, false);
    });

    test('identify emits the \$identify event with anon_distinct_id',
        () async {
      late Map<String, Object?> body;
      final mock = MockClient((req) async {
        body = jsonDecode(req.body) as Map<String, Object?>;
        return http.Response('{}', 200);
      });
      final c = PostHogClient(apiKey: 'phc_test', httpClient: mock);
      final ok = await c.identify(
        distinctId: 'user_42',
        anonymousId: 'anon-99',
        traits: {'region': 'EU'},
      );
      expect(ok, true);
      expect(body['event'], r'$identify');
      final props = body['properties'] as Map<String, Object?>;
      expect(props[r'$anon_distinct_id'], 'anon-99');
      expect(props[r'$set'], {'region': 'EU'});
    });

    test('custom host is honoured (US instance support)', () async {
      late Uri url;
      final mock = MockClient((req) async {
        url = req.url;
        return http.Response('{}', 200);
      });
      final c = PostHogClient(
        apiKey: 'phc_test',
        host: 'https://us.i.posthog.com',
        httpClient: mock,
      );
      await c.capture(event: 'landing.visit', distinctId: 'a');
      expect(url.host, 'us.i.posthog.com');
    });
  });
}
