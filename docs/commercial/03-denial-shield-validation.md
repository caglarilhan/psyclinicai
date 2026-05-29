# Denial Shield — Validation Protocol

**Why this gates revenue:** Denial Shield's value is a *trust* claim ("this note
will be denied; fix X"). If a clinician follows it and still gets denied — or it
cries wolf — we lose them on day one. **Until validated, we frame it as a
compliance / documentation decision-support check, NOT a reimbursement
guarantee.** This doc defines what "validated" means.

## What we're measuring
Denial Shield today is rule-based (CPT time-bands + curated payer
medical-necessity criteria). We must show its pre-submission prediction
correlates with **real payer outcomes**.

## Data to collect (de-identified)
For 30–50 real claims from pilot clinicians:
- the note text (de-identified), CPT code, payer
- **Denial Shield output at save time:** risk level + flagged reasons + $ at risk
- **Realized payer outcome:** approved / denied (+ denial reason code)

> De-identification is non-negotiable (PHI). Reuse the supervision module's
> de-identify-first pattern; store only what the protocol needs.

## Metrics & acceptance bar
| Metric | Definition | Ship bar |
|---|---|---|
| **Recall on denials** | of claims that WERE denied, % we flagged HIGH/MED | ≥ 70% |
| **False-alarm rate** | of clean approved claims, % we wrongly flagged HIGH | ≤ 20% |
| **Reason precision** | flagged reason matches the real denial reason | ≥ 50% |
| **Per-payer accuracy** | break the above out by Medicaid / BCBS / Aetna / UHC | report |
| **$ recovered (proxy)** | flagged-then-fixed claims that got approved | report |

If we clear recall ≥ 70% + false-alarm ≤ 20%, we may publish the ROI claim
("prevents ~X% of denials"). Below that, keep the softer "documentation
completeness check" framing.

## How to capture outcomes (cheapest first)
1. **Pilot clinicians self-log** the outcome 2–4 weeks post-submission (a 30-sec
   form). Lowest cost; depends on follow-through.
2. **Partner with one small billing service / RCM** → batch outcomes. Higher
   quality, also a channel (see `04-pilot-gtm.md`).
3. **Retrospective:** ask a pilot to run 20 *past* claims (outcome already known)
   through Denial Shield — fastest signal, no waiting on the billing cycle.

→ Start with (3) for a quick read, then (1) running continuously.

## Output
- A validation memo with the table above, per-payer.
- This is the **first labeled slice of the data flywheel** (`VISION.md` §3) —
  keep it; it seeds the predictive model that becomes the moat.

## Honesty guardrail (until the bar is met)
Every Denial Shield surface keeps "decision-support, not a reimbursement
guarantee." No "$ recovered" marketing number ships before the bar is cleared.
