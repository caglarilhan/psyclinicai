# TIA — Stripe, Inc.

**Subject:** Transfer Impact Assessment for the EU → US transfer of
billing data to Stripe (subscription + superbill payment flow).
**RoPA activity:** `billing-and-superbill`
**Transfer instrument:** SCC 2021/914 Module 2 + Stripe DPA
**Owner:** PsyClinicAI DPO — dpo@psyclinicai.com
**First drafted:** 2026-06-02
**Next review:** 2027-06-02 or upon any material legal change.

---

## 1. Why a TIA is required

Stripe is a US-based payment processor. The EU → US transfer
involves billing contact data and (indirectly) a diagnosis code
that lives on the superbill. While the diagnosis code alone is not
"health data" in the Art. 9 sense once severed from clinical
context, EDPB has cautioned that any combination that allows
re-identification of a patient with a clinical record warrants the
same level of care. We therefore complete a TIA.

---

## 2. Step 1 — Map the transfer

| Attribute             | Value                                                |
|-----------------------|------------------------------------------------------|
| Exporter              | PsyClinicAI B.V. (Netherlands, EU)                   |
| Importer              | Stripe Payments Europe, Ltd. (Ireland, EU) + Stripe, Inc. (US) |
| Purpose               | Subscription billing, superbill payment, invoice records |
| Data category         | Identity, billing contact, diagnosis code (ICD-10), service code (CPT) |
| Volume                | One row per clinician per month + ad-hoc invoices    |
| Onward transfer       | Card networks (Visa, Mastercard) under PCI DSS       |
| Storage at importer   | Stripe US sub-processes for fraud analysis           |

---

## 3. Step 2 — Transfer tool

Module 2 SCCs (controller → processor) embedded in Stripe's DPA.
Stripe is also DPF-certified — both grounds run in parallel and we
treat SCC + supplementary measures as the load-bearing layer.

---

## 4. Step 3 — Local laws in the importer's jurisdiction

Same §702 / EO 14086 / Cloud Act analysis as the Anthropic TIA
applies, with two differences:

- **PCI DSS overlay.** Cardholder data never enters PsyClinicAI; it
  is collected by Stripe Elements and tokenised at the edge. The
  data we transfer is **billing metadata + tokenised payment
  reference** — not card numbers.
- **Stripe DPF certification.** Even after Schrems II, Stripe's
  current DPF participation reduces the need to rely solely on
  SCCs. We track Stripe's DPF status quarterly (a delisting would
  trigger a TIA refresh inside one week).

---

## 5. Step 4 — Assess effectiveness of the transfer tool

Stripe DPA + Stripe DPF + Module 2 SCCs cover the data categories
above. Combined with the §6 supplementary measures the residual
risk is low.

---

## 6. Step 5 — Supplementary measures

### Technical

- **T1 — No card data in our database.** Stripe Elements tokenises
  in the browser. We persist `customer_id`, `payment_method_id`,
  and `subscription_status` only.
- **T2 — Server-side webhook signing.** `stripeWebhook` validates
  every event via `stripe.webhooks.constructEvent(rawBody, sig,
  STRIPE_WEBHOOK_SECRET)`; replay or spoofed events are rejected.
- **T3 — Diagnosis code minimisation.** Superbills include a single
  ICD-10 code chosen by the clinician for that visit, never the
  full diagnostic history.

### Contractual

- **C1 — Stripe DPA Schedule 3 (sub-processors).** Lists every
  downstream sub-processor with category, location, and transfer
  mechanism.
- **C2 — Stripe DPF certification.** Verified at
  `https://www.dataprivacyframework.gov/list` — re-checked
  quarterly.
- **C3 — Government access disclosure clause** in Stripe's DPA
  obliges Stripe to challenge unlawful requests and notify the
  controller where legally permitted.

### Organisational

- **O1 — Quarterly DPF status check** (calendar-driven).
- **O2 — Annual TIA refresh.**
- **O3 — Stripe Radar (fraud) opt-out review** — the platform
  currently does not opt into Radar for risk scoring; if that
  changes the TIA is re-evaluated because Radar may aggregate
  cross-controller data.

---

## 7. Step 6 — Re-evaluate

Residual risk after §6 supplementary measures: **LOW (3/25)**.
Accepted by the controller because tax obligations (Art. 6(1)(c))
make some processor relationship unavoidable, and Stripe's
combination of DPA + DPF + tokenisation is the lowest-risk path
available in this market segment.

---

## 8. Step 7 — Document & monitor

- This document lives at `docs/compliance/TIA_STRIPE.md`.
- Quarterly DPO check: DPF status, Stripe DPA version.
- On any breach notification from Stripe, an immediate TIA refresh
  is triggered alongside the incident-response runbook.

---

## 9. Sign-off

| Role               | Name        | Date       | Signature            |
|--------------------|-------------|------------|----------------------|
| DPO                | _pending_   | 2026-06-02 | dpo@psyclinicai.com  |
| Finance lead       | _pending_   | 2026-06-02 |                      |
| CTO                | _pending_   | 2026-06-02 |                      |
