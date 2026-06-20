# Retest evidence — F-006 (Stripe webhook replay window > 5 min)

**Finding ID:** PSY-2026Q3-F-006
**Original severity:** Medium (CVSS 4.3, CWE-294)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** billing-wg (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** senior-security + finance-billing-ops + release-manager

---

## 1. Original vulnerability

> The Stripe webhook handler accepted a tolerance window of 15 minutes (Stripe SDK default with custom value), exceeding Stripe's recommended 5 minutes. Signed event replay possible during clock skew.

## 2. Fix shipped

- **Commit:** Sprint 28 fix + Sprint 29 B-09 idempotency (`8fb50c2`, `51b2b7f`).
- **Code references:**
  - `functions/src/lib/stripe.ts` — `tolerance: 300` (5 min) wired into `constructEvent`
  - `functions/src/stripe_connect.ts:108-120` — signature verify
  - `functions/src/stripe_connect.ts:154+` — `processed_webhooks/{event.id}` transactional ledger (Sprint 29 B-09)
  - `functions/src/stripe_subscription.ts` — Sprint 32 graduation handler reuses the same ledger.

## 3. Retest steps

```bash
# 3.1 — Replay a freshly signed event MUST succeed.
stripe trigger customer.subscription.updated \
    --webhook-endpoint https://europe-west1-psyclinicai.cloudfunctions.net/stripeSubscriptionWebhook
# Expected: 200 + {"result":"renewed"} (or appropriate transition).

# 3.2 — Replay the SAME event 6 minutes later MUST be rejected.
stripe events resend EVT_ID_FROM_3.1 \
    --webhook-endpoint https://europe-west1-psyclinicai.cloudfunctions.net/stripeSubscriptionWebhook
sleep 360
# Replay (Stripe CLI prints the signature header it uses; capture & re-post)
curl -X POST https://europe-west1-psyclinicai.cloudfunctions.net/stripeSubscriptionWebhook \
    -H "Stripe-Signature: ${OLD_SIG_FROM_31_MIN_AGO}" \
    -H "Content-Type: application/json" \
    -d @event-from-3.1.json
# Expected: 400 {"error":"invalid_signature"} — tolerance window exceeded.

# 3.3 — Same event_id replayed inside the window MUST be idempotent.
curl -X POST https://europe-west1-psyclinicai.cloudfunctions.net/stripeSubscriptionWebhook \
    -H "Stripe-Signature: ${FRESH_SIG}" \
    -H "Content-Type: application/json" \
    -d @event-from-3.1.json
# Expected: 200 {"result":"duplicate"} — `processed_webhooks` ledger hit.
```

## 4. Evidence artefacts

- `retest-stripe-cli-trigger.txt`
- `retest-stripe-cli-resend-rejected.txt`
- `retest-stripe-cli-idempotent.txt`
- `processed_webhooks-snapshot.json`

## 5. Sign-off

- [ ] **senior-security:** 5 min tolerance enforced; replay outside window rejected.
- [ ] **finance-billing-ops:** subscription state in Firestore matches Stripe dashboard after replay attempts.
- [ ] **release-manager:** rollback to 15 min tolerance can be done in 1 commit if needed.
- [ ] **ciso-advisor:** `findings.csv` row flipped.

## 6. Audit trail row

```
F-006,YYYY-MM-DD,billing-wg-001,fixed_pending_retest,fixed_verified
```
