# Retest evidence — F-008 (audit hash-chain integrity not verified pre-access-review)

**Finding ID:** PSY-2026Q3-F-008
**Original severity:** Medium (CVSS 4.4, CWE-353)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** sec-team (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** senior-security + silent-failure-hunter + ciso-advisor

---

## 1. Original vulnerability

> Audit-log hash-chain integrity was only verified on Trust Center page load. The quarterly access-review (`accessReviewCron`) ran straight against the chain without asserting integrity first — a chain break would have silently propagated into the SOC 2 access-review snapshot.

## 2. Fix shipped

- **Commits:** Sprint 27 (`17ccf1b`) + Sprint 29 B-04 (`51b2b7f`).
- **Code references:**
  - `functions/src/access_review_cron.ts` — Sprint 27 pre-flight hash-chain verify call
  - `functions/src/lib/audit_chain.ts` — `verifyChainIntegrity()` (covered by `__tests__/audit_chain.test.ts`)
  - `firestore.rules:96-114` — Sprint 29 B-04 audit_logs schema-shape assertions (defence in depth)

## 3. Retest steps

```bash
# 3.1 — Healthy chain: cron must succeed.
firebase functions:shell <<EOF
accessReviewCron()
EOF
# Expected: log line `access_review.snapshot_ok` with row count.

# 3.2 — Tamper one row, re-run: cron MUST refuse to write snapshot.
firebase firestore:set audit_logs/SOME_KNOWN_ID \
    --data '{"clinic_id":"TENANT_A","ts":"<existing>","event_type":"override"}' \
    --merge
firebase functions:shell <<EOF
accessReviewCron()
EOF
# Expected: log line `access_review.integrity_break` + Slack alert fired.

# 3.3 — Trust Center read returns 503 while integrity is broken.
curl -X GET https://europe-west1-psyclinicai.cloudfunctions.net/trustCenterIntegrity
# Expected: 503 + `{"integrity":"broken","since":"<ts>"}` (Trust Center widget consumes this).

# 3.4 — Restore the row, re-run, verify chain healthy.
firebase firestore:delete audit_logs/SOME_KNOWN_ID
# (replay from a backup)
firebase functions:shell <<EOF
accessReviewCron()
EOF
# Expected: `access_review.snapshot_ok` again.
```

## 4. Evidence artefacts

- `retest-cron-healthy.log`
- `retest-cron-integrity-break.log`
- `retest-slack-alert.png`
- `retest-trust-center-503.txt`
- `retest-cron-recovered.log`

## 5. Sign-off

- [ ] **senior-security:** integrity break detected by `accessReviewCron` before any snapshot is written.
- [ ] **silent-failure-hunter:** alert fires within 2 min of detection; no silent fallback to "continue with broken chain".
- [ ] **ciso-advisor:** SOC 2 CC4.2 evidence row references this retest.
- [ ] **release-manager:** restore drill documented in `docs/STATUS.md` §DR.

## 6. Audit trail row

```
F-008,YYYY-MM-DD,sec-team-002,fixed_pending_retest,fixed_verified
```
