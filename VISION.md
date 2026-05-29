# PsyClinicAI — Vision & Defensibility

> **Thesis.** Behavioral health runs on two broken workflows: clinicians spend
> ~2 unpaid hours/day on documentation, and ~1 in 7 claims is denied. We
> collapse both into one AI copilot that writes the note *and* defends the
> claim — then turn the resulting data into the **approval-intelligence layer
> for behavioral-health billing**. The notes are the wedge; the payer-outcome
> dataset is the moat.

This document frames why the product we have already shipped is a category
platform, not a feature — and what compounds it into a generational outcome.

---

## 1. The problem (why now)

- **Documentation burden.** US therapists/psychiatrists average 1.5–2 hrs/day on
  notes; burnout is the #1 reason clinicians leave. Ambient AI scribes (Upheal,
  Mentalyc) attack this but stop at the note.
- **The denial crisis.** ~$300B/yr in US claim denials across healthcare; ~60%
  are never resubmitted. In behavioral health, denials hit small practices
  hardest — a denied 90837 is real lost rent. **No scribe defends the claim.**
- **Why now.** (1) LLMs got good *and* cheap enough to run per-session for
  <$0.01. (2) Payers tightened medical-necessity scrutiny post-2023. (3)
  Telehealth normalized digital-first clinical workflows. The window to own the
  AI layer between clinician and payer is open and closing.

## 2. The wedge — a dual-engine copilot (shipped)

| Engine | What it does | Why it's hard to copy |
|---|---|---|
| **Clinical Scribe** | Transcribes the live session, writes the note in the clinician's modality, surfaces real-time risk language (decision-support) | Multi-modality **Clinical Lens** (CBT, DBT, EMDR, IFS, ACT, OCD/ERP, Schema, Psychodynamic) — structured extraction per ekol, not generic summarization |
| **Insurance Auditor (Denial Shield)** | At save-time, scores the note against payer + CPT criteria, quantifies $ at risk, and one-click-fixes the gaps before submission | Payer-specific criteria + CPT time-band logic + the **outcome dataset** below |

Adjacent shipped surface that deepens the wedge: pre-session **Clinical Memory**
brief, **caseload attention** triage, outcome scales (C-SSRS / PCL-5 / AUDIT),
crisis **safety planning**, note→**superbill** autofill, and a de-identified
**supervision** report (the B2B training wedge).

## 3. The moat — a data flywheel competitors can't buy

```
clinician writes note → Denial Shield scores it → claim submitted →
payer approves/denies → outcome captured → approval model sharpens →
better predictions → more clinicians → more outcomes → ...
```

Every assessed claim + realized payer outcome is a proprietary label. After
volume, we predict *this payer will deny this note* better than anyone —
including the payers' own opaque rules. **That dataset is the asset that
justifies a platform multiple**, not the UI. Scribe-only competitors have no
path to it because they never touch the claim.

Secondary moats: switching cost (the chart + memory live here), modality depth
(clinical credibility), and the supervision/benchmark network effect.

## 4. Expansion — solo tool to billing-intelligence layer

1. **Solo clinician (now).** BYOK, sub-$0.01/session, high gross margin. Wedge.
2. **Group practice.** Seats + admin dashboard + caseload-level denial analytics.
3. **RCM / billing-service partners.** API to score claims in their pipeline.
4. **Payer-facing intelligence.** Sell aggregated, de-identified denial-pattern
   insight — the "**Stripe/Plaid for behavioral-health claims**."
5. **Value-based care.** Outcome scales + fidelity benchmarks support
   outcomes-based contracting — where the next decade of spend is moving.

## 5. Defensibility vs incumbents

- **EHRs (SimplePractice, TherapyNotes, ICANotes):** systems of record, not AI;
  slow to ship modality-aware AI + denial prevention. We integrate, then
  out-intelligence.
- **Scribes (Upheal, Mentalyc, Eleos):** note-only; no claim defense, no payer
  data loop. We are a superset and own the higher-value half of the workflow.
- **Horizontal AI:** no clinical modality depth, no payer criteria, no
  compliance posture. Regulatory + clinical trust is the barrier.

## 6. Unit economics

- **BYOK inference** keeps per-token cost on the clinician → we are off the
  variable-cost path; gross margin looks like classic SaaS (80%+).
- Value metric is **$ saved on denials + hours returned**, not seats — pricing
  can capture a slice of recovered revenue (ROI-priced, not cost-priced).

## 7. Metrics that compound (the board view)

- Denials prevented ($ recovered / clinician / month) — the ROI headline.
- Notes/clinician/week (engagement → switching cost).
- Payer-outcome labels captured (moat accumulation rate).
- Net revenue retention (group-practice expansion).
- Modality coverage & fidelity benchmark size (clinical credibility).

## 8. Engineering posture (diligence-ready)

Built to a standard that survives technical + clinical + security diligence:
deny-by-default per-tenant Firestore rules, PHI in secure storage, BYOK keys in
Keychain/encrypted prefs, observability on every clinical-data path,
responsible-AI input fencing (`PromptSafety`), decision-support framing
everywhere (never diagnosis), and a green CI (analyze 0 errors/warnings, unit +
E2E suites). Open security gates are tracked honestly in `SECURITY-BACKLOG.md`.

## 9. Honest risks / gates

- **Regulatory:** HIPAA BAA + SOC 2 path required before scaled PHI; EU MDR
  posture for any diagnostic-leaning claim. (Decision-support framing keeps us
  out of "medical device" today.)
- **Browser key exposure / backend:** Anthropic calls must move behind a relay
  before real PHI at scale (see backlog).
- **Payer-data cold start:** the flywheel needs initial volume; the scribe wedge
  is the volume engine.
- **Trust:** one bad clinical hallucination erodes credibility — hence
  decision-support-only, clinician-in-the-loop, and de-identification by
  construction.

---

*Positioning: we are an EU-based company building the clinical-AI + billing
intelligence layer for behavioral health. This is an internal strategy artifact,
not external marketing copy.*
