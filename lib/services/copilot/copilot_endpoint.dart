import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../config/build_config.dart';

/// Single source of truth for where copilot LLM calls go and which headers to
/// send. Two modes:
///
///  - **Relay (preferred, once `BACKEND_URL` is set):** POST to our Cloud
///    Function, which holds the Anthropic key server-side. The browser never
///    sees the key and no `anthropic-dangerous-direct-browser-access` is used —
///    this closes SECURITY-BACKLOG #1.
///  - **Direct / BYOK (default today):** the clinician's own key is sent
///    straight to Anthropic from the device (pilot model).
typedef IdTokenProvider = Future<String?> Function();

class CopilotEndpoint {
  const CopilotEndpoint._();

  static const String _anthropicUrl = 'https://api.anthropic.com/v1/messages';
  static const String _anthropicVersion = '2023-06-01';

  /// True when calls should be relayed through our backend.
  static bool get useRelay => BuildConfig.backendConfigured;

  /// The endpoint to POST the Anthropic-shaped body to.
  static Uri get uri => Uri.parse(
    useRelay ? '${BuildConfig.backendUrl}/anthropicRelay' : _anthropicUrl,
  );

  /// Headers for the request. In relay mode the key stays server-side, so it is
  /// NOT attached here (the relay injects it); in direct mode we send the
  /// clinician's [apiKey] with the browser-access opt-in.
  ///
  /// Note: in relay mode this returns headers WITHOUT the `Authorization`
  /// bearer. Callers that want the relay's consent gate to evaluate against
  /// the live signed-in user must use [headersAsync] instead. Kept for
  /// back-compat with the BYOK-direct call sites.
  static Map<String, String> headers(String apiKey) => useRelay
      ? const {'Content-Type': 'application/json'}
      : {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': _anthropicVersion,
          'anthropic-dangerous-direct-browser-access': 'true',
        };

  /// Same as [headers] but, when in relay mode, fetches the current Firebase
  /// ID token and attaches it as `Authorization: Bearer …` so the Cloud
  /// Function's `authorizeUid` + `checkAiConsent` gates can run.
  ///
  /// In direct/BYOK mode the [idTokenProvider] is not invoked — the user's
  /// `apiKey` already authorises the call to Anthropic directly.
  ///
  /// If relay mode is enabled but the token provider returns null (signed-out
  /// user, expired token), an empty Authorization header is sent and the
  /// relay will reject with 401 — that is the correct fail-closed behaviour.
  static Future<Map<String, String>> headersAsync(
    String apiKey, {
    IdTokenProvider? idTokenProvider,
  }) async {
    if (!useRelay) return headers(apiKey);
    final provider = idTokenProvider ?? defaultFirebaseIdToken;
    final token = await provider();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Default ID-token provider — reads the current Firebase user's token.
  /// Returns null when nobody is signed in; the relay will then 401 and
  /// the calling service will surface an "unauthorized" error to the UI.
  /// Exposed so callers (services + tests) can compose / override it.
  static Future<String?> defaultFirebaseIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }
}
