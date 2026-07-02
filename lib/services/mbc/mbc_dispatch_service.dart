// ignore_for_file: avoid_catching_errors
// Schema-drift protection: we deliberately catch `TypeError` /
// `NoSuchMethodError` inside `MbcDispatch.fromJson` so a server
// response that grows a new required field surfaces as
// `MbcSubmitException(422, …)` instead of an unhandled crash.
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'mbc_client.dart' show MbcSubmitException;

/// Clinician-authenticated client for `mbcDispatchLink`. Bound to a
/// Firebase ID token; on success it returns the patient-facing form
/// URL the clinician can copy into an SMS / email.
typedef IdTokenProvider = Future<String?> Function();

class MbcDispatchService {
  MbcDispatchService({
    required this.dispatchUrl,
    required this.idTokenProvider,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  /// Expected to be `${BuildConfig.backendUrl}/mbcDispatchLink`.
  final String dispatchUrl;
  final IdTokenProvider idTokenProvider;
  final http.Client _http;

  Future<MbcDispatch> dispatch({
    required String tenantId,
    required String patientId,
    required String scaleId,
    String? channel,
  }) async {
    final token = await idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const MbcSubmitException(401, 'No Firebase ID token.');
    }
    // Dispatch is a token mint — fast on the server side. Bound the
    // client at 30s so a stalled socket doesn't leave the "Sending…"
    // button spinning indefinitely.
    final res = await _http
        .post(
          Uri.parse(dispatchUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'tenantId': tenantId,
            'patientId': patientId,
            'scaleId': scaleId,
            if (channel != null) 'channel': channel,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw const MbcSubmitException(
            408,
            'Request timed out — please retry.',
          ),
        );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MbcSubmitException(res.statusCode, res.body);
    }
    return MbcDispatch.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void close() => _http.close();
}

class MbcDispatch {
  const MbcDispatch({
    required this.dispatchId,
    required this.token,
    required this.formUrl,
    required this.expiresAtMillis,
    required this.scaleId,
    required this.channel,
  });

  /// Defensive constructor — schema drift throws
  /// `MbcSubmitException(422, …)` the UI can surface, instead of an
  /// unhandled `TypeError`.
  factory MbcDispatch.fromJson(Map<String, dynamic> j) {
    try {
      return MbcDispatch(
        dispatchId: j['dispatchId'] as String,
        token: j['token'] as String,
        formUrl: j['formUrl'] as String,
        expiresAtMillis: j['expiresAt'] as int,
        scaleId: j['scaleId'] as String,
        channel: j['channel'] as String,
      );
    } on TypeError catch (e) {
      throw MbcSubmitException(
        422,
        'Malformed mbcDispatchLink response — schema drift: $e',
      );
    } on NoSuchMethodError catch (e) {
      throw MbcSubmitException(
        422,
        'Missing mbcDispatchLink response field: $e',
      );
    }
  }

  final String dispatchId;
  final String token;
  final String formUrl;
  final int expiresAtMillis;
  final String scaleId;
  final String channel;
}
