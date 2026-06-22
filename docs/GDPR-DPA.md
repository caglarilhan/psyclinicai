# PsyClinicAI — Data Processing Agreement (GDPR Art. 28) — Template

> ⚠️ **Template for legal review — not legal advice.** Adapt with counsel
> before signing. Fill all `[BRACKETS]`. This DPA forms part of the
> [Pilot Agreement](PILOT-AGREEMENT.md) / main service agreement.
>
> **Counsel red-line checklist** is at the bottom — keep it internal; do
> not include it in the customer-signing PDF.

**Controller:** [CUSTOMER_NAME] (the clinician/practice).
**Processor:** [LEGAL_ENTITY_NAME], established in [EU_COUNTRY] ("PsyClinicAI",
"we", "our").
**Effective date:** [DATE]
**Underlying service agreement:** [PILOT_AGREEMENT_TITLE], dated [DATE]

Capitalised terms not defined here have the meaning in Regulation (EU)
2016/679 ("GDPR"). To the extent of any conflict, this DPA controls with
respect to the processing of Personal Data.

---

## 1. Subject matter & roles
PsyClinicAI processes Personal Data **on behalf of and on the documented
instructions of** the Controller, solely to provide the service. The
Controller determines the purposes and means; PsyClinicAI acts as Processor
within the meaning of Art. 4(8) GDPR.

## 2. Nature & purpose of processing
Hosting and processing of clinical records to deliver: AI-assisted session
documentation, decision-support, outcome tracking, scheduling, billing
artifacts, telehealth orchestration, and the patient portal — all on the
documented instructions of the Controller, in accordance with the Service
Agreement and the operator-console configuration.

## 3. Categories of data subjects & data

| Category | Examples |
|---|---|
| Data subjects | Controller's patients / clients; Controller's staff (doctors, therapists, admin) |
| Identifiers | Names, email, phone, date of birth, national ID where the Controller chooses to store it |
| Contact data | Addresses, emergency contact |
| **Special-category health data (Art. 9)** | Mental-health assessments (PHQ-9, GAD-7, C-SSRS, custom), session notes, outcome scores, treatment plans, prescriptions where stored |
| Financial data | Stripe customer IDs, last-4 of card (no PAN ever held), invoice line items |
| Telemetry | Login times, IP for security telemetry, audit-log breadcrumbs |

The legal basis for processing Art. 9 special-category data is Art. 9(2)(h)
GDPR (provision of healthcare), exercised by the Controller as the
healthcare professional bound by professional secrecy.

## 4. Duration
For the term of the Service Agreement; then deletion or return per §10.

## 5. Processor obligations (Art. 28(3))
PsyClinicAI shall:

| Art. 28(3) | Commitment |
|---|---|
| (a) Documented instructions | Process Personal Data only on the documented instructions of the Controller (Service Agreement + operator-console configuration + this DPA), including with regard to transfers to a third country or an international organisation, unless required to do so by Union or Member-State law to which PsyClinicAI is subject; in that case, PsyClinicAI will notify the Controller before processing unless prohibited by that law. |
| (b) Confidentiality | Ensure that persons authorised to process Personal Data have committed themselves to confidentiality or are under an appropriate statutory obligation of confidentiality. Each PsyClinicAI team member signs an NDA + confidentiality clause and completes the workforce-training module before access. |
| (c) Security | Implement the technical and organisational measures (TOMs) in Annex II, addressing Art. 32 (encryption, ongoing CIA, restoration after incident, regular testing). |
| (d) Sub-processors | Engage sub-processors only under §7 and Art. 28(2) / (4). |
| (e) Data-subject requests | Assist the Controller, taking into account the nature of the processing, by appropriate technical and organisational measures, in fulfilling the Controller's obligation to respond to data-subject requests under Chapter III (Arts. 12–22) — supported via the DSAR endpoint, audit-log accounting, and the configurable consent / restriction flags. |
| (f) Assistance with security, breach, DPIA | Assist the Controller in ensuring compliance with Arts. 32–36, taking into account the nature of processing and information available — security TOMs in Annex II, breach notification under §9, DPIA support package linked at https://psyclinicai.com/dpa. |
| (g) Return / deletion | At the choice of the Controller, delete or return all Personal Data after the end of the provision of services, and delete existing copies unless Union or Member-State law requires storage. |
| (h) Compliance audit | Make available to the Controller all information necessary to demonstrate compliance with the obligations laid down in Art. 28 and allow for and contribute to audits, including inspections, conducted by the Controller or another auditor mandated by the Controller — see §11. |

If, in PsyClinicAI's opinion, an instruction from the Controller infringes
the GDPR or other Union or Member-State data-protection provisions,
PsyClinicAI will inform the Controller without undue delay.

## 6. Security (Art. 32) — summary; full TOM list in Annex II
- Encryption in transit (TLS 1.3) and at rest (AES-256 — Firestore native,
  Postgres, restic backups, SQLCipher on-device);
- BYOK option: AI calls may use the Controller's own LLM key; in BYOK mode
  no Controller patient data is retained on PsyClinicAI servers beyond what
  the request lifecycle requires;
- Tenant isolation: per-tenant `tenant_id` claim on every Firebase token,
  enforced by Firestore rules + functions guard;
- Access control with WebAuthn / passkey + per-clinician roles + automatic
  logoff;
- Append-only hash-chained `audit_logs` with hourly integrity verification;
- Backup + restore testing per the `docs/security/backup-restore.md` runbook;
- Vulnerability management: monthly Snyk + quarterly Cure53 / NCC retest
  cadence; findings tracked in `docs/security/findings.csv`;
- Incident response: SEV1–4 runbook in `docs/security/incident-response.md`,
  with the 72-h breach notification budget allocated as ≤ 24 h Controller
  notice → Controller has ≥ 48 h to file with the SA.

## 7. Sub-processors

### 7.1 General authorisation
The Controller gives PsyClinicAI a general written authorisation to engage
sub-processors, subject to §§ 7.2–7.4.

### 7.2 Current list (Annex III)
The current list of sub-processors is published at
https://psyclinicai.com/dpa and maintained in `docs/legal/SUBPROCESSORS.md`.

### 7.3 Change notice
PsyClinicAI will inform the Controller of any intended changes concerning
the addition or replacement of sub-processors at least **30 days in
advance**, giving the Controller the opportunity to object on reasonable
data-protection grounds. If the Controller objects and the parties cannot
resolve the objection within 14 days, the Controller may terminate the
Service Agreement without penalty as to the affected service.

### 7.4 Flow-down
Where PsyClinicAI engages a sub-processor for carrying out specific
processing activities on behalf of the Controller, PsyClinicAI imposes by
contract the same data-protection obligations as set out in this DPA, in
particular providing sufficient guarantees to implement appropriate TOMs.
PsyClinicAI remains fully liable to the Controller for the performance of
the sub-processor's obligations (Art. 28(4) GDPR).

## 8. International transfers
Personal Data is hosted in the **EU/EEA ([HOSTING_REGION], default
`europe-west1` Firestore + `eu-central` Postgres on Hetzner)** by default.

Where a sub-processor processes Personal Data outside the EEA, transfers
rely on:
- the **Standard Contractual Clauses (Commission Implementing Decision
  (EU) 2021/914) — Module 2 (Controller-to-Processor)**, incorporated by
  reference, including Annex I/II/III; and
- supplementary measures (encryption in transit and at rest, key-management
  isolation, no clear-text PHI in transit logs).

For BYOK LLM use, the Controller is the data exporter for the request
lifecycle; PsyClinicAI provides the SCC framework but does not retain the
prompt/response.

## 9. Personal data breach
PsyClinicAI will notify the Controller **without undue delay** and in any
event **within 48 hours** of becoming aware of a Personal Data Breach
affecting the Controller's Personal Data — we target ≤ 24 h as a matter of
policy so the Controller still has ≥ 48 h to file under Art. 33.

The notification will include, to the extent known at the time and
supplemented as facts develop, the information described in Art. 33(3)
GDPR:
- nature of the breach, including categories and approximate number of data
  subjects and records concerned;
- name and contact details of the data-protection contact;
- likely consequences;
- measures taken or proposed to mitigate the breach.

## 10. Return & deletion
On termination of the Service Agreement, at the choice of the Controller,
PsyClinicAI will return or delete all Personal Data within **60 days**.
- **Export window**: 30 days after termination, the Controller may export
  data via the DSAR endpoint and the operator-console "Bulk export" tool.
- **Deletion**: in the subsequent 30 days, PsyClinicAI deletes Personal
  Data and all existing copies (including backups, on the restic 30-day
  rolling cycle, naturally rolling off within 30 days), unless retention is
  required by Union or Member-State law.

## 11. Audit (Art. 28(3)(h))
The Controller (or a mutually-agreed third-party auditor bound by
confidentiality) may audit PsyClinicAI's compliance with this DPA on
reasonable written notice (≥ 30 days), no more than **once per calendar
year** absent a material incident or supervisory-authority request.

Audits will be conducted during business hours, will not disrupt the
service, and will respect PsyClinicAI's confidentiality obligations to
other customers. PsyClinicAI may satisfy this obligation by providing the
Controller with a current SOC 2 Type II or ISO 27001 report (when
available), the published Trust Center disclosure, and the Cure53 / NCC
pentest summary with remediation evidence.

## 12. Liability
The liability of each party under this DPA is subject to the limits and
exclusions of liability set out in the Service Agreement. Nothing in this
DPA limits or excludes either party's liability where such limitation or
exclusion is not permitted by applicable law (including Art. 82 GDPR).

## 13. Term, governing law & general

### 13.1 Term
This DPA is effective on the Effective Date and runs for the duration of
the processing of Personal Data under the Service Agreement; §§ 9, 10, 11,
and 12 survive termination.

### 13.2 Order of precedence
In case of conflict among (i) the SCCs (where applicable), (ii) this DPA,
and (iii) the Service Agreement, the order of precedence is (i) → (ii) →
(iii) with respect to data-protection matters.

### 13.3 Governing law & forum
This DPA is governed by the law of [EU_MEMBER_STATE]; courts of
[EU_MEMBER_STATE_CITY] have exclusive jurisdiction, without prejudice to
the data subject's right to bring a claim under Art. 79 GDPR.

---

### Annex I — Processing details
See §§ 2–4.

#### Annex I.A — List of parties
| | Name | Address | Contact (DPO / lead) | Role |
|---|---|---|---|---|
| Data exporter | [CUSTOMER_NAME] | [CUSTOMER_ADDRESS] | [CUSTOMER_DPO_EMAIL] | Controller |
| Data importer | [LEGAL_ENTITY_NAME] | [PSYCLINICAI_ADDRESS] | dpo@psyclinicai.com | Processor |

#### Annex I.B — Description of transfer
- **Categories of data subjects**: see §3.
- **Categories of personal data**: see §3.
- **Sensitive data (Art. 9)**: mental-health assessment scores, free-text
  clinical notes, treatment plans, risk-screening outcomes.
- **Frequency**: continuous, on Controller-initiated usage.
- **Nature of the processing**: see §2.
- **Purposes**: see §2.
- **Retention**: for the term of the Service Agreement + the 60-day return /
  deletion window in §10.
- **Sub-processors**: see Annex III.

#### Annex I.C — Competent supervisory authority
The supervisory authority of [EU_MEMBER_STATE] is the competent authority
in accordance with Clause 13 of the SCCs.

### Annex II — Technical & organisational measures (Art. 32)

| Domain | Measure |
|---|---|
| Pseudonymisation & encryption | TLS 1.3 in transit; AES-256 at rest; SQLCipher on-device; per-tenant key namespace |
| Ongoing CIA | Append-only hash-chained audit log; hourly integrity verifier; uptime monitoring; chaos-drill quarterly |
| Restoration after incident | Restic backups (30-day rolling + 6-y archive); restore-rehearsal quarterly; documented runbook |
| Regular testing | Snyk + npm audit weekly; Cure53 / NCC pentest annually + on major release; internal ASVS Level 2 baseline |
| Access control | WebAuthn / passkey + role-based access + automatic logoff (15 min web); per-tenant `tenant_id` claim |
| Data minimisation | DSAR export is per-tenant; production access by named on-call only; admin actions logged + reviewed |
| Workforce training | Mandatory training (GDPR + clinical-data handling + secure-coding) on hire + annual refresh; tracked in HR ledger |
| Sub-processor management | Annex III + 30-day change notice + SCC flow-down + annual security review |
| Incident response | SEV1–4 matrix; 24-h Controller notification posture; root-cause review within 14 days |
| Secure SDLC | Pull-request review, automated unit + integration test suite, secret scanning, dependency-pin policy |
| Physical security | Hetzner ISO 27001 + SOC 2 attested DCs; Firebase / GCP physical controls inherited |
| BYOK option for LLM | Per §6; Controller-held LLM key; no prompt/response retention server-side |

### Annex III — Approved sub-processors

The authoritative live list is the in-app trust-center page (`/trust/subprocessors`), backed by `lib/services/compliance/subprocessor_registry.dart`. The matrix below mirrors that registry at the Effective Date; any divergence is resolved in favour of the registry.

| Sub-processor | Purpose | Location | Transfer mechanism |
|---|---|---|---|
| Hetzner Online GmbH | Primary application + database hosting (Postgres + Qdrant + Ollama) | Frankfurt (EU) | EEA — no transfer |
| AWS EMEA SES | Transactional email (password reset, receipts) | eu-west-1 / Ireland | EEA — no transfer |
| Cloudflare, Inc. | WAF + edge CDN in front of the web app (request metadata, no clinical content) | Global edge, EU routing preferred | SCC 2021/914 Module 2 + Cloudflare EU enterprise data-localisation |
| Google Firebase (Auth) | Sign-in + password-reset email delivery | EU multi-region | SCC 2021/914 Module 2 |
| Anthropic, PBC | LLM inference for SOAP drafts + risk co-pilot — BYOK opt-in only | US | SCC 2021/914 Module 2 + 0-day retention |
| OpenAI Ireland Ltd. | Alternate LLM provider — same BYOK gate as Anthropic | EU + US fallback | SCC 2021/914 Module 2 + zero-retention API mode |
| Stripe Payments Europe Ltd. | Billing + invoicing + card processing | Ireland (EEA) | EEA — no transfer |
| Sentry (Functional Software, Inc.) | Crash + error reporting (`sendDefaultPii=false`) | US (EU residency on enterprise) | SCC 2021/914 Module 2 |
| PostHog, Inc. | Product analytics — funnel events only, no PHI | EU (eu.posthog.com) | EEA — no transfer |
| Daily.co (Pluot Communications, Inc.) | Telehealth video — clinician ↔ patient sessions (planned Q3 2026) | EU region, no cross-region fallback | SCC 2021/914 Module 2 + EU-only routing flag |
| Twilio Ireland Ltd. | Appointment-reminder SMS (planned Q3 2026) | Ireland (EEA) | EEA — no transfer |

---

**Controller** — signature: ____________  date: ______
**PsyClinicAI** — signature: ____________  date: ______

---

## Counsel red-line checklist (internal — do not send to customer)

- [ ] Confirm `[LEGAL_ENTITY_NAME]` + `[EU_COUNTRY]` match the entity that
      will sign the EU GmbH / SAS / B.V.; align with the cyber-insurance
      policyholder.
- [ ] §9 — confirm 48 h Controller notification is consistent with the
      Controller's own 72 h Art. 33 budget; some German Länder DPAs prefer
      24 h contractual.
- [ ] §10 deletion timeline — verify backup cycle is actually 30 days rolling
      (restic config) so the "naturally rolls off within 30 days" statement
      is accurate at the time of signature.
- [ ] §11 audit — confirm SOC 2 Type II / ISO 27001 will be available before
      the customer's first annual audit window; otherwise budget for a
      direct customer audit visit.
- [ ] §13.3 — replace `[EU_MEMBER_STATE]` and `[EU_MEMBER_STATE_CITY]` with
      the actual jurisdiction (likely Germany or Ireland depending on the
      legal entity).
- [ ] Annex III — verify each row's transfer mechanism is current; update
      any that flipped (e.g., a sub-processor moving from EU to global
      hosting).
- [ ] If the Controller is in DE / AT / IT: attach the relevant national
      addendum (DE: BDSG §22 health data; AT: DSG §13 special categories;
      IT: Codice Privacy Art. 2-septies special categories).
- [ ] If the Controller is a public hospital / EU-funded institution:
      include the EU Cloud Code of Conduct flow-down.
- [ ] Confirm the SCC Annex (I.A, I.B, I.C, II, III) wording matches the
      Commission Implementing Decision (EU) 2021/914 verbatim; counsel
      typically attaches the SCCs as a separate schedule.
