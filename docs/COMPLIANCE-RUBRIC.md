# Progress-Note Audit Rubric (the "Golden Thread")

**Date:** 2026-05-26 · **Powers:** `ComplianceCheckService` (audit-readiness checker in the session co-pilot).

> Distilled from live research of US payer/auditor documentation standards: CMS
> (Article A57480), Optum/UHC behavioral-health audit checklist, Centene/Ambetter
> treatment-record policy (HIM.CP.BH.500), county BHRS/CBH documentation guides,
> ICANotes & Ensora audit guides (2025–2026). **Decision-support, not legal/billing advice.**

## Why it matters
A 2023 **HHS-OIG** audit found **~$580M of $1B** in psychotherapy payments were *improper for
documentation reasons* — missing time, missing signatures — **not fraud**. Behavioral-health
denial rates run **15–25%** (≈2× other specialties). Most recoupments come from notes that don't
*demonstrate* the care, not from bad care.

## The 8 elements auditors read every note for
1. **Diagnosis** — specific DSM-5/ICD-10, highest specificity, consistent across assessment → plan → note → claim.
2. **Functional impairment** — *most under-documented signal.* How symptoms impair work/relationships/self-care; quantify (PHQ-9/GAD-7 + change). A diagnosis without functional consequence is hard to defend.
3. **Named intervention** — specific technique (CBT, EMDR, MI, behavioral activation), and *why* appropriate — not "provided therapy".
4. **Client response** — how the client responded to the intervention.
5. **Goal linkage (golden thread)** — reference ≥1 *treatment-plan goal* and progress toward it, not just the diagnosis.
6. **Risk/safety** — addressed explicitly even when absent ("No SI/HI, no acute safety concerns").
7. **Time** — exact start/stop ("10:02–10:55"), matching the CPT code. Cloned/duration-only notes are the top recoupment trigger.
8. **Plan / next steps** — next session, frequency, homework, referrals.

Plus structural deny-on-sight items: **signature + credentials + date**, **CPT↔time alignment**,
**unsigned/stale treatment plan** (update ≤90 days), **telehealth** modifier (95/93/FQ) + POS
(10 home / 02 other) + consent, and **no cloned language** across sessions.

## CPT time thresholds (individual psychotherapy)
| Code | Face-to-face time | Note |
|---|---|---|
| 90832 | 16–37 min | |
| 90834 | 38–52 min | most-billed; the "50-min hour" is **90834**, not 90837 |
| 90837 | **53+ min** | **most-audited** — add a one-line medical-necessity reason for the extended session |
| 90791/90792 | eval, no set time | |
| 90839/+90840 | crisis, 60 min + add-on | |
| 90846/90847 | family (w/o · w patient) | |
| 90853 | group | |

## How `ComplianceCheckService` applies it
- **Tier 1 (offline, free, instant):** keyword/regex heuristics for all 8 elements + the 90837 time-justification hint; goal-linkage is a hard **fail** when no treatment plan exists. Recall-biased — flags for clinician review.
- **Tier 2 (BYOK Claude, on demand):** semantic review for the judgement calls (functional impairment, intervention↔goal narrative), returning per-element pass/warn/fail + a one-line fix.
- Output: a 0–100 **audit-readiness score** (fails weighted 2×) surfaced in the note panel with the specific fixes. Never a reimbursement guarantee.

## EU note
EU records hinge on **GDPR lawful basis + retention + clinician identification** rather than US
payer medical-necessity. The rubric's structural items (diagnosis, intervention, response, plan,
signature/credentials) still apply; CPT/time/telehealth-modifier items are US-specific.
