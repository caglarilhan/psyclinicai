# Security & Reliability Backlog

Findings from a multi-skill audit (security · silent-failure · Flutter · test
coverage) of the shipped surface. Code-fixable items were **fixed in-tree**
(see below). The remaining items need **credentials, a backend, or infra
config** and are owner/founder actions — they cannot be safely closed in code
alone.

> Framing: PsyClinicAI handles PHI (clinical notes, risk flags). Treat every
> item here as a launch gate for handling real patient data.

---

## ✅ Fixed in-tree (this audit)

- **Tenant isolation verified** — `firestore.rules` is deny-by-default with
  per-clinic ownership (`request.auth.uid == clinicId`); no cross-tenant access.
- **Secrets hygiene** — `.gitignore` now blocks `.env*`, keystores, service
  accounts, and Firebase client configs; stray `GoogleService-Info` plist
  untracked.
- **PHI at rest** — session notes + crisis safety plans moved from plaintext
  SharedPreferences to `flutter_secure_storage`.
- **Silent failures** — clinical persistence (safety plan, notes, medication,
  homework), Firebase bootstrap, auth profile load, and the Tier-2 risk layer
  now report failures to `TelemetryService` and survive one corrupt record
  instead of wiping the store. A failed crisis-plan save no longer reports a
  false success.
- **Account enumeration** — auth returns one generic message for
  user-not-found / wrong-password.
- **Removed** a dead stub `AuthService` with a hardcoded `admin/admin` backdoor.

---

## 🔴 HIGH — gate before handling real PHI

### 1. Anthropic API key + PHI exposed in the browser
**Where:** all `lib/services/copilot/*` services send `x-api-key` +
`anthropic-dangerous-direct-browser-access: true` directly from the web client.
**Risk:** on the web build, any XSS/extension on-origin can read the clinician's
key; session transcripts (PHI) leave the browser with no server-side audit.
**Fix (needs backend):** proxy Anthropic calls through a Firebase Cloud Function
/ minimal relay that holds the key server-side; drop the dangerous header.

### 2. Demo-mode auth bypass has no release guard
**Where:** `firebase_bootstrap.dart` / `login_screen.dart` fall through to
unauthenticated demo mode on a runtime placeholder check.
**Risk:** a misconfigured release build could ship into demo mode → dashboard
without auth.
**Fix (needs build config):** add `--dart-define=IS_DEMO=...`; in release,
assert not-demo at startup and never route to dashboard when auth failed.

### 3. PHI sent to the model without delimiting / size cap
**Where:** transcript + patient name interpolated into prompts
(`clinical_memory_service` puts `patientName` inline; `soap`, `supervision`,
`risk_signal` pass raw transcript).
**Risk:** prompt injection via free-text fields; unbounded payloads.
**Fix (code, larger):** wrap dynamic content in a delimited `<data>…</data>`
block instructed as data-only; cap bytes (~20 KB); strip control chars from
interpolated names.

---

## 🟠 MEDIUM

4. **Telemetry is a no-op stub** (`telemetry_service.dart`) — all the
   `captureError` calls added in this audit are inert until a Sentry/PostHog
   DSN is wired via `--dart-define`. **This is the multiplier**: wire it so the
   new observability actually reports. *(founder / Sprint E)*
5. **Firebase password policy** — client enforces 8 chars; set the server-side
   8+ policy in Firebase Console (Authentication → Password policy).
6. **`identify()` uses raw email** (`login_screen.dart`) — switch to Firebase
   UID before activating PostHog (GDPR data-minimisation / HIPAA minimum-
   necessary); configure an EU endpoint + DPA.
7. **Copilot parse-helper observability** — 6 `_parse()`/`parse()` helpers
   (compliance, treatment_plan_ai, clinical_memory, supervision, clinical_lens,
   session_insights) still swallow JSON errors silently; add a `captureError`
   so prompt/format drift is detectable. *(quick, code)*

---

## 🟢 LOW

8. **Firebase plist in git history** — the untracked iOS config still exists in
   history. The client API key is restricted by our Firestore rules (low risk);
   rotate + scrub history if desired.
9. **Waitlist write hardening** — tighten the `landing_waitlist` email regex /
   add a minimum length; add App Check / reCAPTCHA on that write path.
10. **Repository test gap** — `session_note_repository` / `safety_plan_repository`
    now use secure storage (platform channel), so their filter/sort logic isn't
    unit-tested here; the shared logic is covered via
    `homework_repository_test.dart`. Add a secure-storage mock if deeper repo
    tests are wanted.

---

*Generated from an automated multi-agent review. Verify each item against
current code before acting — the codebase moves.*
