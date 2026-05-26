# PsyClinicAI — Business Associate Agreement (HIPAA) — Template

> ⚠️ **Template for legal review — not legal advice.** A HIPAA BAA has
> mandatory elements (45 CFR §164.504(e)). Have U.S. healthcare counsel
> review before signing or processing any PHI. Fill all `[BRACKETS]`.
>
> **Sequencing note:** per the launch risk table, onboard **EU pilots under
> the [GDPR DPA](GDPR-DPA.md) first**; do not collect U.S. PHI until this BAA
> is counsel-approved and signed.

**Covered Entity:** [CUSTOMER_NAME] (clinician/practice).
**Business Associate:** [LEGAL_ENTITY_NAME] ("PsyClinicAI").
**Effective date:** [DATE]

---

## 1. Definitions
Terms used here have the meaning in the HIPAA Privacy, Security, and Breach
Notification Rules (45 CFR Parts 160 and 164). "PHI" means Protected Health
Information created/received by PsyClinicAI for the Covered Entity.

## 2. Permitted uses & disclosures
PsyClinicAI may use/disclose PHI only:
- to perform the services in the service agreement;
- for its proper management and administration, or to carry out its legal
  responsibilities, with required assurances; and
- as Required by Law.

PsyClinicAI will **not** use or disclose PHI other than as permitted here or
required by law, and will apply **minimum necessary**.

## 3. Safeguards (Security Rule)
PsyClinicAI will implement administrative, physical, and technical safeguards
(45 CFR §164.308, .310, .312) that reasonably protect PHI, including:
- Encryption in transit (TLS) and at rest ([SQLCipher local; managed encryption in hosting region]).
- Access control with unique user IDs and tenant isolation (`clinicId == authenticated user`).
- Audit logging, automatic logoff, and integrity controls.
- BYOK: AI inference uses the Covered Entity's own API key; PHI is not retained
  on PsyClinicAI infrastructure beyond what the service requires.

## 4. Subcontractors
PsyClinicAI will ensure any subcontractor that creates/receives PHI agrees to
**the same restrictions and conditions** (45 CFR §164.502(e)(1)(ii)) via a
written BAA. *(Note: confirm each AI/cloud sub-processor will sign a BAA or is
configured so no PHI is disclosed to it.)*

## 5. Reporting & breach notification
PsyClinicAI will report to the Covered Entity any use/disclosure not permitted
here, any Security Incident, and any Breach of Unsecured PHI **without
unreasonable delay and no later than [X] days** after discovery, with the
content required by §164.410.

## 6. Access, amendment, accounting
PsyClinicAI will, within the timeframes the Covered Entity reasonably requires:
- make PHI available for **access** (§164.524);
- make PHI available for **amendment** (§164.526); and
- maintain and provide an **accounting of disclosures** (§164.528).

## 7. Availability to HHS
PsyClinicAI will make its internal practices, books, and records relating to
PHI available to the Secretary of HHS for determining compliance.

## 8. Return or destruction on termination
On termination, PsyClinicAI will return or destroy all PHI if feasible; where
infeasible, it will extend protections and limit further use. Export window:
**30 days**.

## 9. Term & termination
Effective on the Effective date and terminating when all PHI is returned or
destroyed. The Covered Entity may terminate if PsyClinicAI materially breaches
and fails to cure within [30] days.

## 10. Data residency note
Default hosting is EU ([HOSTING_REGION]). For U.S. customers a **U.S. data
region add-on** ([e.g. AWS us-east / GCP us]) may be required — confirm before
processing U.S. PHI.

---

**Covered Entity** — signature: ____________  date: ______
**PsyClinicAI** — signature: ____________  date: ______
