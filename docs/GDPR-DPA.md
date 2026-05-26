# PsyClinicAI — Data Processing Agreement (GDPR Art. 28) — Template

> ⚠️ **Template for legal review — not legal advice.** Adapt with counsel
> before signing. Fill all `[BRACKETS]`. This DPA forms part of the
> [Pilot Agreement](PILOT-AGREEMENT.md) / main service agreement.

**Controller:** [CUSTOMER_NAME] (the clinician/practice).
**Processor:** [LEGAL_ENTITY_NAME], established in [EU_COUNTRY] ("PsyClinicAI").
**Effective date:** [DATE]

---

## 1. Subject matter & roles
PsyClinicAI processes personal data **on behalf of and on the documented
instructions of** the Controller, solely to provide the service. The Controller
determines the purposes and means.

## 2. Nature & purpose of processing
Hosting and processing of clinical records to deliver: session notes, AI
decision-support, outcome tracking, scheduling, and billing artifacts.

## 3. Categories of data subjects & data
- **Data subjects:** the Controller's patients/clients and authorised staff.
- **Personal data:** identifiers, contact details, and **special-category
  health data** (Art. 9) — assessments, session notes, mood/outcome scores.

## 4. Duration
For the term of the service agreement; then deletion/return per Section 10.

## 5. Processor obligations (Art. 28(3))
PsyClinicAI shall:
1. Process only on documented Controller instructions, incl. for transfers.
2. Ensure personnel are bound by confidentiality.
3. Implement the technical & organisational measures in **Annex II**.
4. Engage sub-processors only under Section 7.
5. Assist the Controller with data-subject requests (Ch. III) where feasible.
6. Assist with security, breach notification, and DPIAs (Arts. 32–36).
7. Delete or return personal data at the end of provision (Section 10).
8. Make available information needed to demonstrate compliance and allow audits.

## 6. Security (Art. 32) — summary; full list in Annex II
- Encryption in transit (TLS) and at rest (local store via SQLCipher; managed
  encryption in [HOSTING_REGION]).
- BYOK: AI calls use the Controller's own Anthropic key; no Controller patient
  data is retained on PsyClinicAI servers beyond what the service requires.
- Tenant isolation: per-clinic access control (`clinicId == authenticated user`).
- Access controls, audit logging, least privilege, backups.

## 7. Sub-processors (Annex III)
Current sub-processors: **[HOSTING_PROVIDER e.g. Hetzner, EU region]**,
**[FIREBASE/GCP region]**, **[STRIPE]** (billing), **Anthropic** (only for
Controller-initiated AI calls under BYOK). PsyClinicAI gives prior notice of
changes and the Controller may object on reasonable data-protection grounds.

## 8. International transfers
Data is hosted in the **EU/EEA ([HOSTING_REGION])** by default. Where a
sub-processor processes data outside the EEA, transfers rely on **Standard
Contractual Clauses** and supplementary measures.

## 9. Personal data breach
PsyClinicAI notifies the Controller **without undue delay and within
[24–72] hours** of becoming aware, with the information needed for the
Controller's Art. 33/34 obligations.

## 10. Return & deletion
On termination, the Controller may export data for **30 days**; thereafter
PsyClinicAI deletes it (including backups, on the backup cycle) unless
retention is required by law.

## 11. Audit
The Controller may audit (incl. via a third party) on reasonable notice, no
more than [once per year] absent an incident, subject to confidentiality.

---

### Annex I — Processing details
See Sections 2–4.

### Annex II — Technical & organisational measures
Encryption (transit + rest), access control & MFA on admin, tenant isolation,
audit logs, backup + restore testing, vulnerability management, secure SDLC,
incident response, data-minimisation, BYOK for AI.

### Annex III — Approved sub-processors
| Sub-processor | Purpose | Location |
|---|---|---|
| [HOSTING_PROVIDER] | Hosting/compute | [EU region] |
| [FIREBASE/GCP] | Auth + datastore | [region] |
| [STRIPE] | Billing | [region] |
| Anthropic | AI inference (BYOK, Controller-initiated) | [region] |

---

**Controller** — signature: ____________  date: ______
**PsyClinicAI** — signature: ____________  date: ______
