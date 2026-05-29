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
  static Map<String, String> headers(String apiKey) => useRelay
      ? const {'Content-Type': 'application/json'}
      : {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': _anthropicVersion,
          'anthropic-dangerous-direct-browser-access': 'true',
        };
}
