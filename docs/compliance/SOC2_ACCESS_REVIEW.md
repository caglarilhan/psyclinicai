# SOC 2 — Quarterly Access Review (CC6.1)

**Status:** Process documented; first observation cycle 2026-Q3
**Owner:** PsyClinicAI Compliance Officer + CISO
**Implementation:** `functions/src/access_review_cron.ts`
**Last reviewed:** 2026-06

---

## 1. Why

AICPA CC6.1 expects evidence that the list of users with logical
access to the production system is reviewed at least quarterly. A
missing review is the #1 finding pattern auditors flag on first-time
Type I reports.

---

## 2. Cadence

- **Cron schedule:** `0 6 1 1,4,7,10 *` UTC — first day of each
  calendar quarter, 06:00 UTC.
- **Sign-off SLA:** 7 calendar days from the cron run. If the
  compliance officer has not stamped `reviewed_by` + `reviewed_at`
  by then, an alert fires (Sprint 15 PagerDuty wiring).

---

## 3. What the cron captures

For every document in `clinicians/*` the cron persists a snapshot
row in `access_reviews/{auto}`:

```jsonc
{
  "created_at":          Timestamp,        // server-stamped
  "created_for_quarter": "2026-09",         // YYYY-MM
  "roster_count":        14,
  "roster": [
    { "uid": "<auth-uid>", "roles": ["therapist"] },
    { "uid": "<auth-uid>", "roles": ["admin", "billing"] }
  ],
  "reviewed_by": null,
  "reviewed_at": null
}
```

**Note:** `email` is intentionally NOT persisted in the snapshot
(GDPR Art. 5(1)(e) + HIPAA minimum-necessary). The compliance
officer retrieves it from Firebase Auth at sign-off time and
records the verification result in the snapshot's `reviewed_by`
field.

---

## 4. Sign-off procedure

1. Open `access_reviews` collection (Firestore console) and locate
   the row for the current quarter.
2. For each `uid`, check the user's status in Firebase Auth:
   - Account disabled? Confirm with the role owner that disablement
     is intentional; otherwise re-enable.
   - Last sign-in > 90 days? Flag for "stale account" review.
3. Update the document with `reviewed_by`, `reviewed_at`, and a
   `notes` field summarising the changes applied.
4. The audit log row (`access_review.snapshot_captured`) already
   chains the entry.

---

## 5. Pagination

The cron paginates through `clinicians` 200 rows at a time
(`startAfter` cursor). Snapshot is complete even at very large
deployments — there is no silent 500-row truncation.

---

## 6. Failure handling

- If the audit log write fails, the cron logs
  `access_review.audit_write_failed` via `functions.logger.error`
  and exits cleanly — Cloud Functions v1 retry would re-snapshot
  needlessly otherwise.
- If the snapshot write fails, the cron rethrows; the scheduler
  retries with exponential backoff.

---

## 7. References

- AICPA TSC CC6.1
- HIPAA §164.312(a)(1)
- ISO 27001:2022 A.5.18
