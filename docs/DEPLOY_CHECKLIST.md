# PsyClinicAI — Deploy Checklist

**Owner:** PsyClinicAI SRE
**Last reviewed:** 2026-06-02

Run top-to-bottom for **every** environment (staging first, then
production). Anything left unchecked is a guaranteed P1 incident
within 72h.

---

## 0. Pre-flight (do once per environment)

- [ ] Firebase project exists in the correct EU region
      (`eu-central-1` for production; staging shares the location).
- [ ] App Check (Recaptcha v3) enabled on Hosting + Firestore +
      Cloud Functions.
- [ ] Custom domain (`app.psyclinicai.com`) verified, SSL active,
      HSTS preload submitted.
- [ ] Per-function service accounts created (see
      `docs/RUNBOOK_CLOUD_FUNCTIONS_IAM.md`).
- [ ] Sentry project + DSN provisioned, source-map upload token
      stored in CI.

---

## 1. Secrets (Secret Manager)

Run each `firebase functions:secrets:set` command **once** per
environment; the value never appears in git history.

- [ ] `ANTHROPIC_API_KEY` — clinic-scoped BYOK relay key
- [ ] `STRIPE_SECRET_KEY` — live or test mode, matches the project
- [ ] `STRIPE_WEBHOOK_SECRET` — fetched from Stripe Dashboard
- [ ] `STRIPE_PRICE_SOLO`, `STRIPE_PRICE_PRACTICE`, `STRIPE_PRICE_GROUP`
- [ ] `DAILY_API_KEY` — Daily.co dashboard, room.create scope
- [ ] `ALLOWED_ORIGINS` — comma-separated allow-list
      (`https://app.psyclinicai.com,https://staging.psyclinicai.com`)
- [ ] `APP_URL` — production app URL (CORS fallback)

Verify after set:

```bash
firebase functions:secrets:access ANTHROPIC_API_KEY
# expected: redacted printable preview, not "Secret not found"
```

---

## 2. Functions build + deploy

```bash
cd functions
npm ci                      # lockfile-pinned install
npm run lint                # tsc --noEmit
npm test                    # 39+ Jest tests must pass
npm run build               # emit lib/
cd ..

# Optional: verify what will deploy.
firebase deploy --dry-run --only functions

# Real deploy.
firebase deploy --only functions
```

- [ ] All scheduled + HTTP functions show `Successful` in the CLI
      output (`anthropicRelay`, `createCheckoutSession`,
      `stripeWebhook`, `telehealthRoom`, `depositIntent`,
      `depositCapture`, `auditRetentionPurge`,
      `accountDeletionPurge`, `escalationSoftLockCleanup`,
      `accessReviewCron`).
- [ ] Cold-start smoke test:
      `curl -X POST https://REGION-PROJECT.cloudfunctions.net/anthropicRelay`
      returns `401 unauthorized` (no token), NOT `500` (env missing).

---

## 3. Firestore rules + indexes

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

- [ ] Rules show `Successful`.
- [ ] Indexes compile-time green.
- [ ] Emulator smoke test (one row read per collection from each
      role) before promoting to prod.

---

## 4. Hosting (web build)

```bash
flutter pub get
flutter test --reporter compact     # 606+ tests
flutter build web --release
firebase deploy --only hosting
```

- [ ] Web build size < 8 MB main.dart.js.
- [ ] Cache-control headers set in `firebase.json`
      (immutable on hashed assets, no-cache on index.html).
- [ ] Lighthouse score > 90 for PWA basics on `/landing`.

---

## 5. Post-deploy verification

- [ ] Open `/landing` in incognito — splash renders < 2 s.
- [ ] Sign-in → MFA TOTP → dashboard happy path.
- [ ] New session → save → sign — audit log row appears.
- [ ] PHQ-9 self-administer → score 12 (moderate) → result screen
      renders the band + recommendation.
- [ ] Trigger PHQ-9 item 9 ≥ 1 — Phq9TriggerSheet opens.
- [ ] Open `/portal` in a private window without a clinician
      session — patient transparency cards render.
- [ ] Visit `/trust/subprocessors` — Daily.co row present, status
      shows "active".
- [ ] Sentry receives a synthetic error from
      `flutter run --release` smoke session.

---

## 6. Scheduled cron sanity (give it 2h after first deploy)

- [ ] `auditRetentionPurge` log line "audit_retention.purge_idle"
      visible in Cloud Logging.
- [ ] `escalationSoftLockCleanup` same idle log.
- [ ] `accessReviewCron` — fired only on quarter starts; expected
      to be quiet on a mid-quarter deploy.

---

## 7. Rollback runbook (keep next to the terminal)

If anything red:

```bash
# Roll back functions one revision.
firebase deploy --only functions --force \
  --revision <previous-revision-id>

# Roll back hosting.
firebase hosting:rollback
```

- [ ] Status page (`https://status.psyclinicai.com`) updated.
- [ ] Post-mortem opened within 24h of any rollback.
