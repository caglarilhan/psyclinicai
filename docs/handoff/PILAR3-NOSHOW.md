# PILAR 3 — Smart No-Show Predictor & Auto-Recovery

**Pitch**: "We saved this practice ~\$2,000 a month."

The ROI pillar — direct receipt math, sells to practice managers
not clinicians. Ships in 4 PRs (#196-199).

## Why this sells

- Average mental-health practice no-show rate: **15-25%**.
- At ~1.5 sessions/week per slot × \$120/session × 4 weeks ≈ \$2,160/month
  walking out the door per clinician.
- Recover the slot ROI math fits in a cold-email subject line.
- Practice managers are the buyer; they decide.

## Architecture (4-PR slice)

```
PR-1 (#196) — Pinned no-show feature + recovery playbook catalog
PR-2 (#197) — noshowPredict CF + pinned logistic baseline (v1-baseline-2026-06)
PR-3 (#198) — Risk-tiered appointment queue UI + predict client
PR-4 (#199) — Route /clinician/noshow + dashboard nav card
```

## Regulatory posture

- **HIPAA §164.502(b)** — minimum-necessary: catalog whitelist gates
  what features the predictor model reads. NO feature in the catalog
  carries `high` PHI sensitivity. Audit row stores feature **keys
  only** — values never persist outside the chart.
- **Joint Commission scheduling efficiency** — playbook cadence cited.
- **NIH PMC4574795** — SMS reminders evidence base.

## Feature catalog (whitelist)

11 features pinned in `NOSHOW_FEATURES`:

- `history_attended_count_90d` (count, PHI=none)
- `history_noshow_count_90d` (count, PHI=none)
- `history_late_cancel_count_90d` (count, PHI=none)
- `days_since_last_session` (count, PHI=none)
- `is_first_session` (boolean, PHI=none)
- `lead_time_days_band` (band, PHI=none)
- `slot_hour_band` (band, PHI=none)
- `weekday` (band, PHI=none)
- `modality` (boolean, PHI=none) — telehealth vs in-person
- `distance_band` (band, PHI=low) — coarse mileage band only
- `has_active_safety_plan` (boolean, PHI=low)

A future model retrain that wants to consume any other feature MUST
bump `NOSHOW_SCHEMA_VERSION` + add the field to the catalog +
re-deploy. Privacy review reads the catalog as the source of truth.

## Risk tiers + playbooks

| Tier | Boundary | Confirm cadence (hrs before) | Deposit | Waitlist on cancel | ROI/slot |
|---|---|---|---|---|---|
| Low | p < 0.15 | [24] | — | — | \$0 |
| Medium | 0.15 ≤ p < 0.40 | [48, 24, 4] | — | yes | \$60 |
| High | p ≥ 0.40 | [72, 48, 24, 4, 1] | required | yes | \$120 |

`tierForProbability(p)` is pure for unit testing; boundaries pinned
in both Dart + TS (drift detector enforces).

## Logistic model v1

`functions/src/lib/noshow_model.ts` — hand-tuned baseline:

```
z = -2.1
  + (-0.18) * history_attended_count_90d
  + (+0.55) * history_noshow_count_90d
  + (+0.28) * history_late_cancel_count_90d
  + (+0.012) * days_since_last_session
  + (+0.65) * is_first_session
  + (+0.20) * lead_time_days_band     (ordinal band)
  + (+0.10) * slot_hour_band          (ordinal band)
  + (+0.04) * weekday                 (ordinal band)
  + (-0.30) * modality (1 = telehealth)
  + (+0.18) * distance_band           (ordinal band)
  + (-0.40) * has_active_safety_plan
probability = sigmoid(z)
```

`MODEL_VERSION = "v1-baseline-2026-06"`. A retrain bumps it + ships
holdout AUC + Brier scores in the release notes. Re-train target:
4 weeks after the cron starts emitting outcome rows.

## Firestore collection + audit posture

`noshow_predictions/{auto}` — admin-SDK-only writes; clinic-owner-read
via `noshow_predictions.clinic_id == request.auth.uid`. Audit fields:

```
{
  tenant_id, clinic_id, appointment_id, patient_id,
  probability, tier, model_version,
  features_used (string[] — KEYS only),
  created_at (serverTimestamp)
}
```

Feature VALUES are NOT stored — HIPAA §164.502(b) minimum-necessary.
The chart bytes never leave the patient row.

## Out of scope for PILAR 3

- Firestore stream over upcoming appointments + batched scoring on
  dashboard mount — Sprint 32.
- Drag-and-drop "apply playbook" → cron-armed reminders — Sprint 32.
- SMS reminder dispatch (Twilio) — Sprint 33 (PILAR 2 shares this).
- Deposit hold integration with `deposit_handler.ts` — Sprint 34.
- Retrain pipeline + holdout monitoring — Sprint 34.
