# Revenue Rails — from demo to "a clinician can pay and use it"

**Goal:** sign up → pay → use with a persistent, authenticated account.

## Current state (audited)
- **Pricing UI exists** — `pricing_section.dart`: Solo **$99/mo**, Practice
  **$299/mo**, Group **$599/mo** (founding rates pre-pilot). `onPickTier` is
  wired to a callback but there's **no checkout** behind it.
- **No Stripe integration** in code (only landing copy references it).
- **Firebase is in demo mode** — `firebase_options.dart` has 6 placeholder
  TODOs; `firebase_bootstrap` degrades to offline. No real accounts/persistence.
- **Telemetry** is a no-op stub (no Sentry/PostHog DSN).

## Split: founder (credentials) vs code (I can build)

### 🔑 Founder — needs accounts/credentials (I cannot do)
1. Create the **Firebase prod project**; run `flutterfire configure` (fills
   `firebase_options.dart`, replaces the 6 TODOs).
2. **Stripe account** → create 3 Products/Prices ($99/$299/$599 + annual).
3. **Anthropic BAA** signed (gates real PHI — see `01-market-entry-decision.md`).
4. **Domain + DNS + SSL** for the prod web host.
5. **Sentry + PostHog** projects → DSN/keys (EU data region).

### ⌨️ Code — I can build once the above exist
1. **Stripe Checkout (web)** behind `onPickTier` → redirect to Checkout; on
   success, set the clinician's subscription tier in Firestore.
2. **Subscription gating** — a `SubscriptionService` reading tier/status; gate
   premium features (AI calls) for active subscribers; trial logic.
3. **Backend relay (Cloud Function)** for Anthropic so the key + PHI never sit
   in the browser (SECURITY-BACKLOG #1) — flips the BYOK model to managed.
4. **Telemetry DSN wiring** via `--dart-define` (activates the observability we
   already instrumented).
5. **Demo-mode release guard** (`--dart-define=IS_DEMO`; assert in release).
6. **Stripe webhook handler** (Cloud Function) → keep subscription status in
   sync (created / canceled / payment_failed).

## Sequence & acceptance
1. Founder: Firebase prod + Stripe products + Anthropic BAA. *(unblocks all)*
2. Code: relay + demo-guard + telemetry DSN. → **Accept:** real auth works, AI
   runs through the relay, errors reach Sentry.
3. Code: Checkout + gating + webhook. → **Accept:** a test card buys Solo, the
   account unlocks AI features, cancel revokes them.
4. → First chargeable account exists. Hand to `04-pilot-gtm.md`.

## Decision needed from founder
- **BYOK vs managed key?** A relay means *we* pay inference (~<$0.01/session) →
  simpler UX, supports a real BAA, but adds COGS. Recommended for paid tiers;
  keep BYOK as a free/trial option. (Affects margin in `VISION.md` §6.)
