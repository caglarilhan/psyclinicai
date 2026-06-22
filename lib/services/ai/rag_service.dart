import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../config/build_config.dart';
import 'rag_client.dart';

/// High-level Clinical RAG facade used by UI.
///
/// Wraps the thin [RagClient] with:
///  - feature-flag (returns disabled result when [BuildConfig.ragEnabled] is
///    false — no exception, UI hides the surface),
///  - one-shot constructor from [BuildConfig],
///  - typed [RagResult] so the screen can render disabled / ok / error
///    without try/catch noise.
class RagService {
  RagService({RagClient? client}) : _client = client;

  /// Build from compile-time config. Returns a disabled instance when no
  /// backend is wired — every call short-circuits to [RagResult.disabled].
  /// Sprint 27 (F-003): `BACKEND_URL` points at the psyrag hub itself
  /// (e.g. `https://rag.psyclinicai.com`); the hub verifies the Firebase
  /// ID token in `Authorization: Bearer` and maps the `tenant_id` custom
  /// claim to its `clients` row. The per-tenant hub API key NEVER ships in
  /// the web bundle.
  factory RagService.fromConfig({
    http.Client? httpClient,
    IdTokenProvider? idTokenProvider,
  }) {
    if (!BuildConfig.ragEnabled) return RagService();
    return RagService(
      client: RagClient(
        baseUrl: '${BuildConfig.backendUrl}/api/rag',
        idTokenProvider: idTokenProvider ?? _defaultIdTokenProvider,
        httpClient: httpClient,
      ),
    );
  }

  static Future<String?> _defaultIdTokenProvider() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  final RagClient? _client;

  bool get isEnabled => _client != null;

  Future<RagResult> query({
    required String question,
    String region = 'EU',
    String? docType,
    int topK = 8,
  }) async {
    final client = _client;
    if (client == null) return const RagResult.disabled();
    try {
      final ans = await client.query(
        question: question,
        region: region,
        docType: docType,
        topK: topK,
      );
      return RagResult.ok(ans);
    } on RagException catch (e) {
      return RagResult.error('${e.statusCode}: ${_truncate(e.body)}');
    } catch (_) {
      return const RagResult.error('Network error reaching the RAG hub.');
    }
  }

  Future<RagResult> analyze({
    required Map<String, dynamic> patientContext,
    required String question,
    String region = 'EU',
    String? docType,
    String? clientUserRef,
    int topK = 8,
  }) async {
    final client = _client;
    if (client == null) return const RagResult.disabled();
    try {
      final ans = await client.analyze(
        patientContext: patientContext,
        question: question,
        region: region,
        docType: docType,
        clientUserRef: clientUserRef,
        topK: topK,
      );
      return RagResult.ok(ans);
    } on RagException catch (e) {
      return RagResult.error('${e.statusCode}: ${_truncate(e.body)}');
    } catch (_) {
      return const RagResult.error('Network error reaching the RAG hub.');
    }
  }

  /// Cheap, inference-free reachability check (Sprint 28 audit F8): the
  /// Trust Center health card used to call [query] with a probe string,
  /// which burned rate-limit tokens AND inference cost on every page
  /// view. The hub exposes `/api/rag/health` for exactly this case.
  Future<bool> healthOk() async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.health();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Submit clinician feedback on a prior answer. Returns null when disabled
  /// or on error — the UI treats it as best-effort.
  Future<String?> feedback({
    required String auditId,
    required String score,
    String? note,
  }) async {
    final client = _client;
    if (client == null) return null;
    try {
      return await client.feedback(auditId: auditId, score: score, note: note);
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client?.close();

  static String _truncate(String s) =>
      s.length <= 240 ? s : '${s.substring(0, 240)}…';
}

/// Three-state result the UI can pattern-match on without try/catch.
class RagResult {
  const RagResult._({this.answer, this.errorMessage, required this.state});
  const RagResult.disabled() : this._(state: RagState.disabled);
  const RagResult.ok(RagAnswer ans) : this._(answer: ans, state: RagState.ok);
  const RagResult.error(String message)
    : this._(errorMessage: message, state: RagState.error);

  final RagAnswer? answer;
  final String? errorMessage;
  final RagState state;

  bool get isDisabled => state == RagState.disabled;
  bool get isOk => state == RagState.ok;
  bool get isError => state == RagState.error;
}

enum RagState { disabled, ok, error }
