# PILAR 4 — Evidence-Based Treatment Plan Drafter

**Pitch**: "Pick disorder + modality. Get a SMART-goal plan cited to NICE/APA."

The moat pillar — group-practice expansion + liability reduction.
Ships in 4 PRs (#200-203).

## Why this sells

- New-clinician onboarding: cuts plan-drafting time **~50%**.
- Liability reduction: cited evidence → defensible care.
- Supervisor co-sign workflow opens **group-practice expansion**
  sales motion.
- No other mental-health EHR ships AI-drafted, cited-to-guideline
  treatment plans.

## Architecture (4-PR slice)

```
PR-1 (#200) — Pinned (disorder, modality) protocol catalog + drift
PR-2 (#201) — tpDraftPlan CF handler (provider fallback + co-sign flag)
PR-3 (#202) — Flutter drafter screen + client
PR-4 (#203) — Route /clinician/tp-drafter + dashboard nav card
```

## Regulatory posture

- **FDA CDS non-device §520(o)(1)(E)** — drafter never auto-files;
  clinician edits + signs every plan before persistence.
- **EU AI Act high-risk disclosure** — signed plan footer carries
  "AI-assisted draft, clinician-reviewed".
- **HIPAA §164.526** — accuracy of PHI: every SMART goal cites a
  published guideline.
- **Joint Commission care-planning standards** — SMART goals +
  measurable outcome instrument + reassessment cadence.

## Pinned (disorder, modality) protocols — 12 tuples

| Disorder | Modality | Sessions | Outcome | Co-sign | Anchors |
|---|---|---|---|---|---|
| Major Depressive Disorder | CBT | 16 | PHQ-9 | — | NICE CG90 / APA 2019 |
| Major Depressive Disorder | IPT | 16 | PHQ-9 | — | NICE CG90 / Markowitz & Weissman 2012 |
| Generalised Anxiety | CBT | 14 | GAD-7 | — | NICE CG113 / APA 2024 |
| Panic Disorder | CBT | 12 | GAD-7 | — | NICE CG113 / APA 2024 |
| Social Anxiety | CBT | 14 | GAD-7 | — | NICE CG159 |
| PTSD | EMDR | 12 | PCL-5 | **REQ** | NICE NG116 / WHO mhGAP 2023 |
| PTSD | Trauma-Focused CBT | 14 | PCL-5 | **REQ** | NICE NG116 / APA 2017 |
| OCD | ERP-based CBT | 16 | GAD-7 | — | NICE CG31 / APA 2013 |
| Borderline PD | DBT | 48 | PHQ-9 | **REQ** | NICE CG78 / Linehan 2nd ed. |
| Binge-Eating Disorder | CBT | 16 | PHQ-9 | — | NICE NG69 |
| Alcohol Use Disorder | MI | 8 | AUDIT | **REQ** | NICE CG115 / SAMHSA TIP 35 |
| Insomnia Disorder | CBT-I | 6 | PHQ-9 | — | AASM 2021 |

**Co-sign rule**: trauma (PTSD) + personality (BPD) + substance (AUD)
protocols REQUIRE supervisor co-sign before persistence. Sprint 33
ships the assign-supervisor workflow; today the screen renders the
banner + blocks persistence until co-sign metadata lands.

## LLM output schema (server-pinned, client cannot inject)

`functions/src/lib/tp_drafter_catalog.ts:jsonSchemaForPlan()` emits a
strict JSON schema with these required sections:

1. `presenting_problems[]`
2. `smart_goals[]` — each goal MUST populate goal_text + specific +
   measurable + achievable + relevant + time_bound + cited_guideline
3. `session_plan[]` — recommendedSessions entries
4. `homework_templates[]`
5. `outcome_reassessment{instrument, cadence_label}`
6. `risk_review_cadence`

**Citation invariant**: `cited_guideline` MUST be a verbatim string
from the protocol's `guidelineAnchors` array — enforced in the system
prompt + reviewable at audit time.

## Firestore collection + audit posture

`tp_drafted_plans/{auto}` — admin-SDK-only writes; clinic-owner-read
via `tp_drafted_plans.clinic_id == request.auth.uid`. Audit fields:

```
{
  tenant_id, clinic_id, patient_id,
  disorder, modality, schema_version,
  provider, model, input_tokens, output_tokens,
  phi_redactions,
  requires_co_sign,
  presenting_problems_hash (sha256 hex),
  hour_bucket, created_at (serverTimestamp)
}
```

NO PHI bytes, NO draft bytes — only counts + hash. The signed plan
body lands in the encounter (Sprint 33).

## Safety chain (identical to PILAR 1 + 2)

- Clinician-only auth via `authorizeClinicianUid`.
- N24 security headers + N25 rate limit (`ai-copilot-inference`).
- Consent gate when `patientId` present.
- Jailbreak reject on the prompt text inputs.
- PHI scrub before egress.
- LLM provider fallback (Anthropic → Azure BAA).
- Strict JSON parse, 502 on failure (no silent retry).

## Out of scope for PILAR 4

- Assign-supervisor flow + co-sign UI — Sprint 33.
- Plan-to-encounter persistence path — Sprint 33.
- Cited-footer PDF export — Sprint 33.
- Group-practice supervisor routing — Sprint 33.
- Adolescent / paediatric protocols — separate PR with their own
  validated guidelines.
