/// Sprint 31 P0 / Sprint 32 — PostHog HTTP client (no SDK dependency).
///
/// The PostHog Flutter SDK pulls in a heavy native dependency we don't
/// want in the web bundle. The HTTP capture endpoint is documented +
/// stable, so we POST events directly. The client is intentionally
/// minimal:
///
///   - no batching delay (clinic users generate at most a few events
///     per minute; the cost of a single POST per event is fine);
///   - no PHI is ever included — the call site is responsible for
///     stripping identifiers before invoking;
///   - no retry loop — a missed event is acceptable, a delayed crash
///     is not.
///
/// Skill-panel coverage: observability-designer (event shape), senior-
/// devops (low-blast-radius client), product-analytics (funnel).
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// `PostHogClient` keeps zero state by default. Pass a custom
/// [http.Client] in tests so requests don't leave the process.
class PostHogClient {
  PostHogClient({
    required this.apiKey,
    this.host = 'https://eu.i.posthog.com',
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client(),
       _enabled = apiKey.isNotEmpty;

  final String apiKey;
  final String host;
  final http.Client _http;
  final bool _enabled;

  bool get enabled => _enabled;

  /// Fire a single funnel event. Returns `true` when the request was
  /// accepted (2xx), `false` otherwise — callers ignore the result
  /// because analytics is never load-bearing.
  Future<bool> capture({
    required String event,
    required String distinctId,
    Map<String, Object?> properties = const {},
    DateTime? timestamp,
  }) async {
    if (!_enabled) return false;
    final payload = <String, Object?>{
      'api_key': apiKey,
      'event': event,
      'distinct_id': distinctId,
      'timestamp': (timestamp ?? DateTime.now().toUtc()).toIso8601String(),
      'properties': {
        ...properties,
        // Always tag the source so dashboards can split by build.
        '\$lib': 'psyclinicai-flutter',
      },
    };
    try {
      final r = await _http
          .post(
            Uri.parse('$host/i/v0/e/'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));
      if (r.statusCode >= 200 && r.statusCode < 300) return true;
      if (kDebugMode) {
        debugPrint('[posthog] non-2xx ${r.statusCode}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('[posthog] capture failed: $e');
      return false;
    }
  }

  /// Associate an anonymous device with an authenticated user.
  Future<bool> identify({
    required String distinctId,
    required String anonymousId,
    Map<String, Object?> traits = const {},
  }) async {
    if (!_enabled) return false;
    return capture(
      event: '\$identify',
      distinctId: distinctId,
      properties: {'\$anon_distinct_id': anonymousId, '\$set': traits},
    );
  }

  void close() {
    _http.close();
  }
}
