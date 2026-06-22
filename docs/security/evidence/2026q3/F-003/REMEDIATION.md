# PSY-2026Q3-F-003 — Remediation evidence

**Finding:** RAG client API key (`RAG_API_KEY`) embedded in web build bundle.
**Severity:** High · CVSS 7.5 (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N)
**CWE:** 798 (Use of Hard-coded Credentials)
**OWASP API:** API2 — Broken Authentication
**Opened:** 2026-06-10 · **Remediated:** 2026-06-16 · **Retest due:** 2026-06-25
**Owner:** ai-wg

---

## Root cause

The Clinical RAG hub (`psyrag`) required a per-tenant API key. Until Sprint 26
the build pipeline shipped that key into the Flutter web bundle via
`flutter build web --dart-define=RAG_API_KEY=pck_...`. Dart's
`String.fromEnvironment` resolves at compile time, so the key string was
inlined as a literal inside `main.dart.js`. Any visitor could open Chrome
DevTools → Sources → search the bundle and recover the tenant key.

---

## Fix (Sprint 27 W1)

Replaced the direct hub call with a Cloud Functions reverse proxy. The
client never sees the hub key; the browser only carries a short-lived
Firebase ID token.

### 1. Cloud Function — `functions/src/rag_proxy.ts`

- HTTPS handler `ragProxy` exposes a path-routed allow-list of four ops:
  `analyze`, `query`, `feedback`, `health`. Anything else → `404`.
- Caller verification:
  - Requires `Authorization: Bearer <Firebase ID token>`.
  - Decodes via `admin.auth().verifyIdToken()`.
  - Requires a `tenantId` (or `tenant_id`) custom claim — body-supplied
    tenant ids are NEVER trusted (would be forgeable).
- Upstream call to `${RAG_HUB_URL}/api/rag/<op>` injects:
  - `x-api-key: ${RAG_HUB_KEY}` — read from Cloud Functions env (Vault).
  - `x-tenant-id: <verified claim>`.
- Per-request audit doc in `rag_proxy_calls/{auto}`:
  `{tenant_id, uid, op, status, latency_ms, created_at}` — **no PHI body**.
- CORS preflight via the existing `applyCors()` helper from `./lib/auth`.

### 2. Flutter client — `lib/services/ai/rag_client.dart`

- Constructor signature changed: `apiKey: String` → `idTokenProvider:
  Future<String?> Function()`.
- Header set to `Authorization: Bearer <token>` — `X-Api-Key` is gone.
- Endpoint paths changed to `/<op>`; the caller supplies
  `baseUrl: '${BACKEND_URL}/v1/rag'`.
- Missing/empty token → `RagException(401)` raised **before** the HTTP
  call (verified by test `missing ID token throws RagException(401)
  without hitting the network`).

### 3. Build config — `lib/config/build_config.dart`

- `BuildConfig.ragBaseUrl` and `BuildConfig.ragApiKey` marked
  `@Deprecated('Sprint 27 F-003: RAG key moved to Cloud Functions.
  Removed Sprint 28.')`. Kept as `// removed`-style placeholders for one
  sprint so external `--dart-define` CI scripts do not break the build.
- `BuildConfig.ragEnabled` now derives from `backendConfigured` (the
  Cloud Functions proxy URL), not from a per-tenant secret.

### 4. Service facade — `lib/services/ai/rag_service.dart`

- `RagService.fromConfig()` now wires
  `idTokenProvider: () => FirebaseAuth.instance.currentUser?.getIdToken()`
  by default; tests can inject a stub provider.

---

## Test coverage

| Layer | File | Cases |
|---|---|---|
| Flutter | `test/rag_client_test.dart` | 6 — incl. **negative assertion** that `X-Api-Key` is never present on outgoing requests; **negative network assertion** that missing token aborts before the HTTP call |
| Flutter | `test/rag_service_test.dart` | 4 — facade disabled/ok/error/feedback paths under new constructor |
| Cloud Functions | `functions/src/__tests__/rag_proxy.test.ts` | 4 — `extractOp` allow-list, prefix-strip from Hosting rewrites, unknown-op rejection, case sensitivity |

Run:

```bash
# Cloud Functions
cd functions && npx jest --testPathPattern rag_proxy
# → 4 passed (Sprint 27 F-003 allow-list)
cd functions && npx jest
# → 9 suites, 55 tests passed (full suite still green)

# Flutter
cd .. && flutter analyze lib/services/ai lib/config lib/screens/ai test/rag_client_test.dart test/rag_service_test.dart
# → No issues found
cd .. && flutter test test/rag_client_test.dart test/rag_service_test.dart
# → 10 tests passed
```

---

## Bundle verification (manual retest steps for vendor)

1. Build the web bundle with `--dart-define=BACKEND_URL=https://api.psyclinic.ai`
   (no `RAG_API_KEY` flag this time):

   ```bash
   flutter build web --release --dart-define=IS_DEMO=false \
     --dart-define=BACKEND_URL=https://api.psyclinic.ai
   ```

2. Grep the built bundle for the legacy key prefix:

   ```bash
   grep -RHn "pck_" build/web/ || echo "no key string present in bundle"
   ```

   Expected: `no key string present in bundle`.

3. Open the deployed app, sign in, and open DevTools → Network →
   filter `v1/rag`. Confirm:
   - Request URL points to `${BACKEND_URL}/v1/rag/<op>`, not to a `psyrag`
     hostname.
   - `Authorization` header carries a Firebase ID token (`eyJ...`),
     never an `X-Api-Key` header.

4. Inspect Firestore: a fresh `rag_proxy_calls` doc is written per call
   with `tenant_id`, `uid`, `op`, `status`, `latency_ms`, `created_at`,
   and **no PHI fields**.

5. Forged-tenant test: craft a request with `Authorization: Bearer
   <valid token for tenant A>` plus a body claiming `tenant_id: B`.
   Expected: proxy ignores the body-supplied id; upstream call carries
   the verified-claim tenant only; audit log records tenant A.

---

## Residual risk

- Hub URL/key rotation is now a Cloud Functions env redeploy — no client
  push needed. Operator runbook: `docs/deployment/README.md` (Sprint 27).
- Rate-limit cap on `ragProxy` is **not** part of F-003 close — that is
  Sprint 27 P0 task #1 (F-001, LLM proxy per-tenant quota). The pattern
  will be lifted into `ragProxy` in the same change.
- `BuildConfig.ragBaseUrl` / `ragApiKey` remain present as deprecated
  fields for one sprint; Sprint 28 W1 removes them outright.
