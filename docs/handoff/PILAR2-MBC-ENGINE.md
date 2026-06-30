# PILAR 2 — Measurement-Based Care Engine

**Pitch**: "PHQ-9, GAD-7, PCL-5 — sent, scored, flagged. Patient fills in their browser. No account."

The payer-leverage pillar. Ships in 4 PRs (#192-195).

## Why this sells

- US payers (CMS MIPS #134, CalAIM, Cigna VBC) consistently reimburse
  measurement-based-care-certified practices **5-15% more per session**.
- Patient-facing token-signed URL: no account, no download, no friction.
- Sticky: clinicians who collect outcomes between sessions don't go back.
- Enterprise unlock — multi-clinician group practices buy on this.

## Architecture (4-PR slice)

```
PR-1 (#192) — Pinned MBC dispatch catalog (Dart + TS mirror + drift)
PR-2 (#193) — CF mbcDispatchLink + mbcSubmitAssessment + server-side scoring
PR-3 (#194) — Patient form (public, no-login) + MBC public client
PR-4 (#195) — Clinician MBC dashboard + routes + Quick Actions tile
```

## Regulatory posture

- **HIPAA §164.312(d)** — entity authentication: short-lived token URL,
  256-bit CSPRNG, sha256-stored, single-use (consumed on submit).
- **HIPAA §164.502(b)** — minimum-necessary: submit reply carries only
  the patient's own score / severity / clinicianAction. No PHI from the
  chart leaks back.
- **HIPAA §164.514(b)** — safe-harbor de-id: PHI scrubber sits in front
  of the dispatch link path.
- **CMS MIPS #134** — depression screening + follow-up plan.
- **NICE QS8 / CG90 / CG113 / CG115 / NG116** — per-scale cadence
  pinned in `MBC_DISPATCH_RULES`.
- **Joint Commission NPSG 15.01.01** — PHQ-9 item 9 alarm threshold
  fires immediately on submission.

## Server-side scoring spec

`functions/src/lib/mbc_scoring.ts` mirrors the validated algorithms in
`lib/services/assessments/clinical_scales.dart`:

| Scale | Items | Range/item | Max | Alarm at | Direction |
|---|---|---|---|---|---|
| PHQ-9 | 9 | 0..3 | 27 | ≥ 10 | high |
| GAD-7 | 7 | 0..3 | 21 | ≥ 10 | high |
| WHO-5 | 5 | 0..5 (×4 multiplier) | 100 | ≤ 52 | LOW (wellbeing) |
| AUDIT | 10 | 0..4 | 40 | ≥ 16 | high |
| PCL-5 | 20 | 0..4 | 80 | ≥ 33 | high |

## Token lifecycle

1. **Mint**: `mbcDispatchLink` clinician-only POST → 32-byte CSPRNG,
   sha256 stored, expiry from catalog `linkLifetimeHours`.
2. **Use**: PUBLIC `mbcSubmitAssessment` POST → transactional consume
   (no race), score server-side, write submission, return score.
3. **Reuse**: 409 conflict on second submit.
4. **Expire**: 410 gone past `expires_at` (catalog: 72h for PHQ-9/GAD-7,
   96h for WHO-5/AUDIT/PCL-5).

## Firestore collections + posture

- `mbc_dispatch` — admin-SDK-only writes, clinic-owner-read via
  `mbc_dispatch.clinic_id == request.auth.uid`.
- `mbc_submissions` — admin-SDK-only writes (PUBLIC endpoint uses
  admin SDK), clinic-owner-read via `mbc_submissions.tenant_id`.

Rules in `firestore.rules` enforce both.

## Audit fields (no PHI beyond patient_id pointer in dispatch)

`mbc_dispatch/{auto}`:
```
{
  tenant_id, clinic_id, patient_id, scale_id,
  token_hash (sha256 hex), channel,
  dispatched_at, expires_at, submitted_at?, reminded_at?,
  created_at (serverTimestamp)
}
```

`mbc_submissions/{auto}`:
```
{
  tenant_id, patient_id, scale_id, dispatch_id,
  score, max_score, severity, alarm_triggered,
  item_count, answers (int[]),  # clinical record, gated by rules
  submitted_at (serverTimestamp)
}
```

## Out of scope for PILAR 2

- SMS gateway adapter (Twilio relay) — Sprint 33.
- MBC payer report PDF — Sprint 32 phase 2.
- Adolescent variants (PHQ-A, GAD-7-A) — separate PR with their own
  validated thresholds.
- Cadence cron (auto-dispatch) — Sprint 33; clinician manually
  triggers via the dashboard today.
