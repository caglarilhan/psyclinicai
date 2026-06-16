# PSY-2026Q3-F-008 — Remediation evidence

**Finding:** Audit-log hash-chain integrity verification only triggered
on Trust Center page load; `accessReviewCron` does not assert the
chain before the access review snapshot is written.
**Severity:** Medium · CVSS 4.4
(CVSS:3.1/AV:L/AC:L/PR:H/UI:N/S:U/C:N/I:H/A:N)
**CWE:** 353 (Missing Support for Integrity Check)
**OWASP API:** API8
**Opened:** 2026-06-03 · **Remediated:** 2026-06-16 · **Retest due:** 2026-06-25
**Owner:** sec-team

---

## Root cause

The `audit_logs` collection ships a `hash` field on every row
(SHA-256 over the canonical row JSON concatenated with the previous
row's hash). Until Sprint 26 the only consumer was the Trust Center
page, which calls `verifyAuditChain()` on demand. The quarterly
SOC 2 access review cron did NOT verify the chain before taking a
snapshot — so a tamper that landed between two reviews could end
up signed over by the compliance officer at sign-off time.

## Fix (Sprint 27 W2)

### 1. Pure verifier — `functions/src/lib/audit_chain.ts`

- `canonicalise(row)` — deterministic, key-sorted, null-omitting
  JSON serialisation of the row sans `hash`.
- `computeChainHash(row, prev)` — `SHA-256(prev + "|" + canonical)`.
- `verifyChainSlice(rows, initialPrev = "GENESIS")` — walks the
  slice and returns the first mismatch index + reason. Skips legacy
  rows that have no stored `hash` (so partial migrations don't
  trigger a false alarm).

### 2. Cron-time gate — `functions/src/access_review_cron.ts`

- `verifyAuditChainOrAbort(db, pageSize = 500)` reads the oldest
  500 rows of `audit_logs` ordered by `timestamp_utc` and runs
  `verifyChainSlice`.
- On chain break, the cron:
  1. Logs `access_review.chain_break` at `error` level with the
     first-bad-index, reason, and rows-checked.
  2. Writes an incident doc to a new collection
     `audit_chain_incidents/{auto}` (severity `P0`, contains
     `detected_at`, `first_bad_index`, `reason`, `rows_checked`,
     `page_size`).
  3. Returns early — the access review snapshot is **not** taken,
     so the compliance officer cannot accidentally sign over a
     tampered chain at quarter-end.

The leading 500-row window is the highest-risk class: tampering
inside it would invalidate every later derivation, so even a cheap
weekly run gives outsized coverage. A future iteration can paginate
end-to-end for full attestation.

---

## Test coverage

| Layer | File | Cases |
|---|---|---|
| Verifier | `functions/src/__tests__/audit_chain.test.ts` | 6 — **canonicalise determinism + null-omit invariant**, valid chain accepted, **single-row mutation flagged**, legacy gaps tolerated, **chaos: adjacent reorder breaks the chain** |

Run: `cd functions && npx jest --testPathPattern audit_chain` → 6 passed.
Full suite remains green (verified in the Sprint 27 W2 final gate run).

---

## Vendor retest steps

1. **Happy path.** Trigger the cron manually in staging
   (`firebase functions:shell` → `accessReviewCron()`). Confirm a
   fresh `access_reviews` doc lands AND no `audit_chain_incidents`
   doc is created.

2. **Chain-break probe.** In a staging emulator, write a tampered
   row directly: take an existing `audit_logs` doc and rewrite
   `action` (or any non-hash field) without recomputing `hash`.
   Re-run the cron. Expected: NO `access_reviews` doc is created;
   a new `audit_chain_incidents/{auto}` doc appears with
   `severity: "P0"` and a `reason` quoting the bad row id.

3. **Legacy-gap tolerance.** Insert a row with no `hash` between
   two correctly hashed rows. Cron must still succeed
   (`rows_checked` reduced by one).

4. **Stackdriver alert wiring.** Subscribe `severity ≥ ERROR` on
   the `access_review.chain_break` log channel to PagerDuty
   (operator runbook). Trigger probe #2 → page fires within a
   minute.

---

## Residual risk

- Only the oldest 500 rows are checked per fire. Tampering far
  beyond that window would not be caught on a single run; the
  ongoing weekly cadence (and the Trust Center on-demand verifier)
  cover the rest.
- The PagerDuty wiring lives in infra, not code. Operator runbook
  documents the alert query; an alert subscription drift would
  silently break the page-out without breaking the audit. Mitigated
  by a Sprint 28 "alert-test" cron that injects a synthetic
  incident doc weekly and confirms the page fires.
