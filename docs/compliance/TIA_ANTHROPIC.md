# TIA — Anthropic, PBC

**Subject:** Transfer Impact Assessment for the EU → US transfer of
clinical free-text to Anthropic's hosted Claude models.
**RoPA activity:** `ai-assistance`
**Transfer instrument:** SCC 2021/914 Module 2 (controller → processor)
**Owner:** PsyClinicAI DPO — dpo@psyclinicai.com
**First drafted:** 2026-06-02
**Next review:** 2027-06-02 or upon any material legal change in
the destination jurisdiction.

---

## 1. Why a TIA is required

EDPB Recommendations 01/2020 (post Schrems II) require an in-writing
assessment whenever an EU controller relies on SCCs to transfer
personal data — and especially special-category data — to a third
country. The US is not subject to an EU adequacy decision in the
general case; the Data Privacy Framework (DPF) covers participating
companies but **Anthropic is not currently DPF-certified**. We
therefore rely on SCCs + supplementary measures.

---

## 2. Step 1 — Map the transfer

| Attribute             | Value                                                |
|-----------------------|------------------------------------------------------|
| Exporter              | PsyClinicAI B.V. (Netherlands, EU)                   |
| Importer              | Anthropic, PBC (Delaware, US)                        |
| Purpose               | LLM inference for clinical decision-support drafts   |
| Data category         | Clinical free-text (Art. 9 — health)                 |
| Volume                | ~5–20 short prompts per clinician per day            |
| Onward transfer       | None — Anthropic does not sub-process to third parties for this scope |
| Storage at importer   | Zero-retention API tier — prompts not stored beyond inference |

---

## 3. Step 2 — Transfer tool

Module 2 SCCs (controller → processor), signed via Anthropic's
Commercial Terms + DPA Addendum.

Key clauses:
- **Clause 8.1** — instructions limited to the documented purpose.
- **Clause 8.6 (security)** — Anthropic operates SOC 2 Type II + ISO
  27001:2022; encryption in transit (TLS 1.3) and at rest (AES-256).
- **Clause 14 (local laws)** — both parties commit to the EDPB
  problematic-laws analysis below.

---

## 4. Step 3 — Local laws in the importer's jurisdiction

### 4.1 Foreign Intelligence Surveillance Act (FISA) §702

- **In scope?** Anthropic is a US-based electronic communications
  service provider. It can be compelled to produce data covered by
  §702 if a non-US person is targeted for foreign intelligence.
- **Mitigation impact:** Our supplementary measures (§6) materially
  reduce the value of any compelled data — PII is stripped at the
  boundary; the BYOK custody model means Anthropic does not hold
  long-lived plaintext linking content to identity.

### 4.2 Executive Order 12333

- Allows bulk collection in transit. The TLS 1.3 channel between
  exporter and Anthropic mitigates passive collection.

### 4.3 Executive Order 14086 (2022) — redress mechanism

- Establishes the Data Protection Review Court. EU residents can
  pursue redress for unlawful US signals-intelligence access. This
  is a partial mitigation against §702 risk for EU patients.

### 4.4 Cloud Act (2018)

- Reach extends to data held by US providers outside the US. Since
  Anthropic does not store prompts (zero-retention tier), Cloud Act
  warrants would target data Anthropic does not have.

---

## 5. Step 4 — Assess effectiveness of the transfer tool

The SCCs alone are **not sufficient** for special-category data into
the US absent DPF coverage. We must add supplementary measures.

---

## 6. Step 5 — Supplementary measures (technical + contractual)

### Technical

- **T1 — Pseudonymisation at the boundary** (`PromptSafety.fence`):
  name, DoB, MRN, email, phone, address stripped before relay.
- **T2 — BYOK key custody:** the API key is per-clinic, stored in
  Google Secret Manager (EU region); Anthropic sees the key only on
  the auth header of the request.
- **T3 — Zero-retention API tier:** Anthropic does not persist
  prompts or completions beyond inference.
- **T4 — TLS 1.3 transport, perfect forward secrecy.**
- **T5 — No tool use, no agentic loop.** Claude has no outbound
  network or filesystem access from this relay.

### Contractual

- **C1 — DPA Schedule 2:** describes Anthropic's technical and
  organisational measures (SOC 2 Type II + ISO 27001:2022).
- **C2 — Audit clause:** annual right of audit (delegable to a
  qualified auditor) per SCC Clause 8.9.
- **C3 — Government-access notification:** Anthropic commits to
  challenge requests that conflict with EU law and to notify the
  controller "to the extent legally permitted".

### Organisational

- **O1 — Internal training:** clinicians complete an annual privacy
  module that explains what AI assistance does and does not see.
- **O2 — Annual TIA refresh:** this document re-reviewed each year
  or whenever §702, EO 14086, or the Anthropic DPA materially
  changes.

---

## 7. Step 6 — Re-evaluate

With the supplementary measures in §6, the residual risk for EU
patients is reduced from **HIGH (15/25)** to **MEDIUM-LOW (5/25)**.
The remaining residual risk is accepted by the controller because:

1. The clinical benefit (documented in `DPIA_AI_ASSISTANCE.md`,
   Section 3) is material and proportional.
2. The data subject's explicit consent is required per Art. 9(2)(a)
   and may be withdrawn at any time (Art. 7(3)).
3. Patient may always opt to receive treatment without AI
   assistance — the platform supports a `workspace_ai_mode = disabled`
   state per clinician choice.

---

## 8. Step 7 — Document & monitor

- This document lives at `docs/compliance/TIA_ANTHROPIC.md` and is
  surfaced in the Trust Center via `RopaRegistry.crossBorder`.
- Quarterly DPO check: scan EDPB / EDPS announcements for new
  problematic-laws guidance.
- On any change to Anthropic's DPA, processor sub-list, or the US
  legal landscape, the next clinic operations meeting includes a
  TIA-review agenda item.

---

## 9. Sign-off

| Role               | Name        | Date       | Signature            |
|--------------------|-------------|------------|----------------------|
| DPO                | _pending_   | 2026-06-02 | dpo@psyclinicai.com  |
| Legal counsel      | _pending_   | 2026-06-02 |                      |
| CTO                | _pending_   | 2026-06-02 |                      |
