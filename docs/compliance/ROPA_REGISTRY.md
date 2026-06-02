# GDPR Art. 30 — Record of Processing Activities

**Status:** Active — five processing activities registered
**Source of truth:** `lib/services/compliance/ropa_registry.dart`
**Owner:** PsyClinicAI Data Protection Officer (DPO)
**DPO contact:** dpo@psyclinicai.com
**Last reviewed:** 2026-06-02

This document is the human-readable mirror of `RopaRegistry`. Both
update together; the `test/compliance_docs_parity_test.dart` test
asserts every DPIA / TIA reference below resolves to a real file.

---

## Activities

### 1. `clinical-record-keeping`

| Field                  | Value                                                  |
|------------------------|--------------------------------------------------------|
| Purpose                | Maintain longitudinal patient clinical records         |
| Data subjects          | Patients                                               |
| Data categories        | Identity, contact, Art. 9 health, clinical free-text   |
| Lawful basis           | Art. 9(2)(h) — health care; Art. 6(1)(b) contract      |
| Retention              | 6 years after end of treatment (HIPAA §164.316 align.) |
| Recipients             | Clinician, Firebase (EU), Hetzner (EU)                 |
| Cross-border           | None — EEA only                                        |
| Security measures      | Audit log, deny-by-default rules, at-rest encryption   |

### 2. `ai-assistance`

| Field                  | Value                                                  |
|------------------------|--------------------------------------------------------|
| Purpose                | Decision-support drafts at clinician request           |
| Data subjects          | Patients                                               |
| Data categories        | Clinical free-text segments, pseudo-identifier         |
| Lawful basis           | Art. 9(2)(a) — explicit consent                        |
| Retention              | Prompt + response 30 days; then purged                 |
| Recipients             | Anthropic (US, BYOK relay)                             |
| Cross-border           | EU → US                                                |
| Transfer mechanism     | SCC 2021/914 Module 2 + supplementary measures         |
| TIA                    | `docs/compliance/TIA_ANTHROPIC.md`                     |
| DPIA                   | `docs/compliance/DPIA_AI_ASSISTANCE.md`                |
| Security measures      | ConsentGuard fail-closed, PromptSafety, per-call audit |

### 3. `billing-and-superbill`

| Field                  | Value                                                  |
|------------------------|--------------------------------------------------------|
| Purpose                | Subscription billing + superbill payment               |
| Data subjects          | Patients, billing contacts                             |
| Data categories        | Identity, billing contact, ICD-10, CPT, payment meta   |
| Lawful basis           | Art. 6(1)(b) + Art. 6(1)(c) tax obligation             |
| Retention              | 7 years (statutory)                                    |
| Recipients             | Stripe (US, BAA + SCC), Clinician                      |
| Cross-border           | EU → US                                                |
| Transfer mechanism     | SCC 2021/914 Module 2 + Stripe DPA + DPF tracking      |
| TIA                    | `docs/compliance/TIA_STRIPE.md`                        |
| Security measures      | Webhook signing, tokenised cards                       |

### 4. `audit-logging`

| Field                  | Value                                                  |
|------------------------|--------------------------------------------------------|
| Purpose                | Tamper-evident audit trail                             |
| Data subjects          | Clinicians (directly), patients (indirectly)           |
| Data categories        | Actor uid, entity reference, redacted IP               |
| Lawful basis           | Art. 6(1)(c) HIPAA §164.312(b); Art. 6(1)(f) security  |
| Retention              | 6 years (HIPAA §164.316(b)(2)(i)); then pseudonymised  |
| Recipients             | Firebase (EU)                                          |
| Cross-border           | None                                                   |
| Security measures      | Append-only rule, SHA-256 chain, retention cron        |

### 5. `incident-response`

| Field                  | Value                                                  |
|------------------------|--------------------------------------------------------|
| Purpose                | Investigate + contain + notify on incidents            |
| Data subjects          | Affected clinicians and patients                       |
| Data categories        | Identity, communication logs, incident artefacts       |
| Lawful basis           | Art. 6(1)(c) — HIPAA §164.404; Art. 33 / 34            |
| Retention              | 6 years after closure                                  |
| Recipients             | Internal incident commander, affected subjects, regulators |
| Cross-border           | None                                                   |
| Security measures      | Severity playbook, on-call rotation, 24h SLA           |

---

## Cross-border recipients

| Sub-processor    | Country | Instrument                        | TIA                                    |
|------------------|---------|-----------------------------------|----------------------------------------|
| Anthropic, PBC   | US      | SCC 2021/914 Module 2             | `docs/compliance/TIA_ANTHROPIC.md`     |
| Stripe, Inc.     | US      | SCC 2021/914 Module 2 + DPF       | `docs/compliance/TIA_STRIPE.md`        |

---

## Review cadence

- **Annual full review** by the DPO, every June.
- **Trigger-based review** within seven days of any of:
  - New sub-processor onboarded
  - Material change to the Anthropic / Stripe DPA
  - EU adequacy decision changes (DPF status, new SCC version)
  - Breach or near-miss requiring RoPA recalibration
