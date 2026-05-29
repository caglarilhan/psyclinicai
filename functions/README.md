# PsyClinicAI Backend (Cloud Functions)

Server-side rails so secrets + PHI never live in the browser. **Deploy-time —
the founder runs this once accounts exist.** The Flutter app talks to it via
`--dart-define=BACKEND_URL=...`.

## Functions
| Endpoint | Purpose |
|---|---|
| `POST /anthropicRelay` | Proxies LLM calls; the Anthropic key stays here (closes SECURITY-BACKLOG #1). |
| `POST /createCheckoutSession` | Creates a Stripe Checkout session; returns `{ url }`. Called by `CheckoutService`. |
| `POST /stripeWebhook` | Verifies Stripe signatures, syncs subscription status to Firestore `subscriptions/{email}`. |

## Setup (founder)
1. `cd functions && npm install`
2. `cp .env.example .env` and fill in (Anthropic key, Stripe secret + webhook
   secret + 3 price IDs, APP_URL). Never commit `.env`.
3. `npm run build` to type-check.
4. `npm run deploy` (`firebase deploy --only functions`).
5. In Stripe, add a webhook → `…/stripeWebhook`; copy its signing secret to
   `STRIPE_WEBHOOK_SECRET`.
6. Build the web app with `--dart-define=BACKEND_URL=<functions base URL>`
   (+ `STRIPE_PUBLISHABLE_KEY`, `IS_DEMO=false`, telemetry DSNs).

## Still TODO before real PHI (tracked in /SECURITY-BACKLOG.md)
- **Auth on `anthropicRelay`:** verify the Firebase ID token before relaying
  (placeholder noted in `src/index.ts`).
- **Wire the copilot services** to call `BACKEND_URL/anthropicRelay` instead of
  Anthropic directly when `BACKEND_URL` is set (drops the
  `anthropic-dangerous-direct-browser-access` path).
- **Resolve clinician UID** from the Stripe customer in the webhook (today keyed
  by email).
