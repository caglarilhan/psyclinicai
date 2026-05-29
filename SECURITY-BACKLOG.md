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

---

## Round 2 — billing rails + UI audit (added with the revenue-rails work)

### Backend `functions/` — pre-deploy hardening (founder, before any real data)
The Cloud Functions are a **skeleton**; a TypeScript review flagged these to fix
before a production deploy that carries real data (tsc passes clean today):
- **CRITICAL — auth on `anthropicRelay`:** verify the Firebase ID token before
  relaying (PHI path). Marked TODO in `src/index.ts`.
- **HIGH — webhook `customer_email` bug:** `Stripe.Subscription` has no
  `customer_email`, so the webhook write is currently a no-op. Handle
  `checkout.session.completed` (which *does* carry `customer_email` + metadata),
  and key the Firestore doc by clinician UID, not email.
- **HIGH — fail-fast on missing secrets** (STRIPE_SECRET_KEY / WEBHOOK_SECRET /
  ANTHROPIC_API_KEY): throw at module load instead of `?? ""`.
- **HIGH — webhook idempotency:** dedupe by `event.id` (Stripe is at-least-once).
- **HIGH — relay input validation:** cap body size + allowlist fields / max_tokens.
- **MEDIUM:** classify Stripe errors (400 vs 502); add ESLint; add
  `noUncheckedIndexedAccess`; structured audit logging on the relay.

### UI / accessibility — fixed this round ✅
- `PsyButton`: enforced 44px min tap target (WCAG 2.5.8) + single
  `Semantics(button:…)` node — fixes role/target across every screen at once.
- Login: password-visibility toggle now has a tooltip; auth/validation errors
  wrapped in a `liveRegion` so screen readers announce them.
- Session: the primary notes `TextField` now has a `Semantics(label:'Session
  notes')`.

### UI / accessibility — remaining (tracked)
- **HIGH — `session_screen` design-system bypass:** bare `Scaffold` + hard-coded
  `Colors.*` + color-only timer state. Rebuild on `AppShell` + tokens, add a
  text/icon label to the timer (not color alone). Biggest single UI/demo gap.
- **HIGH — session 3-column layout** has no responsive reflow (<900px / 200%
  zoom). Add a `LayoutBuilder` stacked fallback.
- **MEDIUM:** dashboard quick-action tiles need `Semantics(button:…)`; pricing
  "MOST POPULAR" badge (white@28% on teal) + comparison-table status icons fail
  contrast / are icon-only; landing scroll/animations should honor
  `MediaQuery.disableAnimations`; `app_shell` search is a fake input (give it a
  button role); superbill prefilled sample data should be marked as demo.

---

*Generated from automated multi-agent reviews. Verify each item against current
code before acting — the codebase moves.*
