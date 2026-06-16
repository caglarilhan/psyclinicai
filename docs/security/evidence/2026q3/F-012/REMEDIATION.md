# PSY-2026Q3-F-012 — Remediation evidence

**Finding:** Patient self-service invite link valid for 7 days and
reusable; should be one-time-use with 24h expiry per OWASP ASVS V2.3.1.
**Severity:** Low · CVSS 3.7
(CVSS:3.1/AV:N/AC:H/PR:N/UI:R/S:U/C:L/I:N/A:N)
**CWE:** 613 (Insufficient Session Expiration)
**OWASP API:** API2
**Opened:** 2026-06-09 · **Remediated:** 2026-06-16 · **Retest due:** 2026-06-25
**Owner:** patient-portal-wg

---

## Root cause

The previous invite flow stored a `code` on the patient stub doc
with no expiry and no single-use flag. A clinician could re-share
the same SMS body, and an attacker who phished an old link could
still complete sign-up months later. OWASP ASVS V2.3.1 calls for
single-use, short-TTL invite tokens for self-service patient
enrolment.

## Fix (Sprint 27 W2)

### 1. New collection — `invites/{inviteId}`

Document shape:

| Field | Type | Notes |
|---|---|---|
| `id` | `string` | Random 22-char base64url (server-generated). |
| `created_at` | `Timestamp` | Server-set on issue. |
| `expires_at` | `Timestamp` | `created_at + 24h` — Sprint 27 W2 fixed window. |
| `consumed_at` | `Timestamp \| null` | Flipped from `null` on first valid consume. |
| `clinician_id` | `string` | Issuing clinician. |
| `patient_email` | `string` | Bound recipient — verified at first tap. |

### 2. Pure decision helper — `lib/services/portal/patient_invite_service.dart`

```dart
InviteCheckResult checkInvite({
  required InviteState? state,
  required DateTime now,
});
```

Outcomes: `valid`, `expired`, `consumed`, `notFound`. The caller
wraps `checkInvite` inside a Firestore transaction; only `valid`
flips `consumed_at`.

### 3. UX outcomes

- First tap with `valid` → enrolment continues, `consumed_at = now`.
- Second tap on the same link → `consumed` → friendly `/portal/invite-used`
  landing with "Request a new link" CTA. The new link issues a fresh
  `inviteId`; the old one stays consumed forever.
- Tap after 24h → `expired` → "This link has expired" landing with
  the same CTA.
- Tap on an unknown id (typo or revoked) → `notFound` → 404 landing.

### 4. Firestore rules (operator runbook)

The rules update (out of scope for this PR; operator playbook
under `docs/security/runbooks/invites_rules.md`) restricts the
`invites/{id}` collection to:
- `clinician_id == request.auth.uid` for issuing writes.
- Read allowed only to the issuing clinician or via the
  transactional `consume` callable (server-side). The patient
  client never reads the raw doc — it calls a `consumeInvite`
  callable that returns `{status: valid|consumed|expired|notFound}`.

---

## Test coverage

| Layer | File | Cases |
|---|---|---|
| Pure decision | `test/patient_invite_service_test.dart` | 5 — `notFound` for null, **first-tap valid**, **second-tap consumed**, **expiry at boundary + past boundary**, `defaultExpiry == 24h` |

Run: `flutter test test/patient_invite_service_test.dart` → 5 passed.

---

## Vendor retest steps

1. **First-tap acceptance.** Issue an invite via the clinician
   workflow → tap the link in an incognito window within 24h →
   enrolment succeeds. Confirm Firestore `invites/{id}.consumed_at`
   is non-null.
2. **Second-tap rejection.** Re-tap the same link → `/portal/invite-used`
   landing renders, no auth session is created.
3. **Expiry probe.** Hand-edit `expires_at` to `now - 1 minute` in
   staging → tap the link → `/portal/invite-expired` landing.
4. **Brute-force probe.** Generate 1000 random 22-char base64url
   ids and tap each → all return `notFound` 404; no information
   leak in the response body (no clinician name, no patient email).

---

## Residual risk

- The 24h window is fixed; longer onboarding windows (e.g., a
  hospital ward intake taking 48h) require a separate flow. Sprint 28
  may add per-clinic TTL with a 168h cap.
- Email delivery latency: SMS / email may delay the link by ~1h on
  rare provider outages. A clinician can re-issue with one tap;
  the old link is invalidated on consume of the new one.
