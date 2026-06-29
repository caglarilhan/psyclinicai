# PsyClinicAI — Business Associate Agreement (HIPAA) — Template

> ⚠️ **Template for legal review — not legal advice.** A HIPAA BAA has
> mandatory elements (45 CFR §164.504(e)). Have U.S. healthcare counsel
> review before signing or processing any PHI. Fill all `[BRACKETS]`.
>
> **Sequencing note:** per the launch risk table, onboard **EU pilots under
> the [GDPR DPA](GDPR-DPA.md) first**; do not collect U.S. PHI until this BAA
> is counsel-approved and signed.
>
> **Counsel red-line checklist** lives at the bottom of this file — keep it
> internal; do not include it in the customer-signing PDF.

**Covered Entity:** [CUSTOMER_NAME] (clinician/practice/healthcare facility).
**Business Associate:** [LEGAL_ENTITY_NAME] ("PsyClinicAI", "we", "our").
**Effective date:** [DATE]
**Underlying Service Agreement:** [PILOT_AGREEMENT_TITLE], dated [DATE]

This Business Associate Agreement ("BAA") supplements the Service Agreement.
To the extent of any conflict between this BAA and the Service Agreement, this
BAA controls with respect to Protected Health Information ("PHI").

---

## 1. Definitions
Capitalised terms have the meaning in the HIPAA Privacy, Security, and Breach
Notification Rules at 45 CFR Parts 160 and 164 ("HIPAA Rules"), as amended by
HITECH. Without limiting that incorporation:

- **"Breach"** has the meaning at 45 CFR §164.402.
- **"PHI"** means Protected Health Information that PsyClinicAI creates,
  receives, maintains, or transmits on behalf of the Covered Entity.
- **"Required by Law"** has the meaning at 45 CFR §164.103.
- **"Security Incident"** has the meaning at 45 CFR §164.304.
- **"Unsecured PHI"** means PHI not rendered unusable, unreadable, or
  indecipherable to unauthorised persons through a technology or methodology
  specified in 45 CFR §164.402 and HHS guidance (currently AES-128 or higher
  at rest, TLS 1.2+ in transit).

## 2. Permitted uses & disclosures of PHI

### 2.1 Service performance
PsyClinicAI may use and disclose PHI only as necessary to perform the services
described in the Service Agreement (AI-assisted clinical documentation,
scheduling, billing support, telehealth orchestration, RAG-augmented decision
support, and the patient portal).

### 2.2 Permitted internal uses
PsyClinicAI may use PHI for its proper management and administration, or to
carry out its legal responsibilities, **provided that** any disclosure to a
third party for such purposes is either Required by Law or accompanied by the
written assurances under 45 CFR §164.504(e)(4)(ii).

### 2.3 Data aggregation
PsyClinicAI may use PHI to provide data-aggregation services relating to the
health-care operations of the Covered Entity, as permitted by 45 CFR
§164.504(e)(2)(i)(B).

### 2.4 Minimum necessary
PsyClinicAI will limit its use, disclosure, and request of PHI to the
**minimum necessary** to accomplish the purpose, per 45 CFR §164.502(b).

### 2.5 Prohibited uses
PsyClinicAI will not:
- use or disclose PHI in a manner that would violate the HIPAA Rules if done
  by the Covered Entity;
- sell PHI in violation of 45 CFR §164.502(a)(5)(ii);
- use or disclose PHI for marketing in violation of 45 CFR §164.508(a)(3); or
- use PHI to train any AI model in a manner that retains identifiers, except
  as expressly authorised by the Covered Entity in writing.

## 3. Safeguards (Security Rule)
PsyClinicAI will implement administrative, physical, and technical safeguards
(45 CFR §§ 164.308, .310, .312) that reasonably and appropriately protect the
confidentiality, integrity, and availability of electronic PHI ("ePHI"). The
current control set includes:

| Safeguard | Implementation |
|---|---|
| Encryption in transit | TLS 1.3 enforced by Caddy + Firebase Hosting; HSTS preloaded |
| Encryption at rest | AES-256 (Firestore native + Postgres + restic-encrypted backups + SQLCipher on-device) |
| Access control | Firebase Auth + WebAuthn passkeys; per-tenant claims (`tenant_id`) on every token |
| Audit logging | Append-only hash-chained `audit_logs` collection with hourly integrity verification |
| Automatic logoff | Web auto-logout after 15 minutes idle; portal kiosk auto-flush on tab change |
| Integrity controls | Hash-chained audit log; Stripe webhook idempotency ledger (`processed_webhooks/{event.id}`) |
| Transmission security | TLS 1.3, `Referrer-Policy: no-referrer` on session routes, `Permissions-Policy` lock |
| Workstation security | Workforce-training module §2 — disk encryption + MFA mandatory for all team members |
| Incident response | Documented runbook in `docs/security/incident-response.md` with SEV1–4 matrix and 24-hour Covered-Entity notification posture |
| BYOK option | AI inference may use the Covered Entity's own LLM key; in that mode no LLM-routed PHI is retained outside the request lifecycle |

A current copy of the Trust Center disclosure is available at
https://psyclinicai.com/trust.

### 3.1 Programmatic operational commitments
The safeguards above are backed by **pinned in-repo catalogs**, so
any drift between the contractual promise and the running system is
caught by tests at build time. The catalogs and their downstream
consumers (trust-center page, DPA, customer DPA appendix):

| Program | Catalog source | Customer-visible posture |
|---|---|---|
| Backup + DR (RTO/RPO per data class) | `lib/services/ops/backup_recovery_plan.dart` | Firestore default daily / 24h RPO / 4h RTO; clinical audit chain weekly cold storage / 7-year retention; consent records daily / 7-year retention; KMS secret snapshots weekly / 1h RTO. |
| Service-level objectives | `lib/services/ops/slo_catalog.dart` | Audit-log mirror success ≥ 99.5% / 30d; chain-tamper events = 0 / 30d; DSAR export SLA ≥ 99% / 90d; breach 72h compliance = 100% / 90d. |
| On-call incident runbook | `lib/services/ops/on_call_runbook.dart` | 6-kind incident matrix (chain break, DSAR overdue, AI output block, breach, ransomware, supply-chain) with declared owners + step targets. |
| Breach notification deadlines | `lib/services/compliance/breach_notification.dart` | HIPAA §164.410(b) ≤ 60 days (policy ≤ 24h to Covered Entity); GDPR Art. 33 ≤ 72h to supervisory authority; KVKK 72h. |
| AI decision audit | `lib/services/ai/ai_decision_logger.dart` + `lib/services/ai/ai_output_guard.dart` | Every LLM-routed clinical suggestion is hash-chained with the prompt id, model card id, input hash, and the safety-guard verdict (FDA CDS-aligned). |

These catalogs are append-only; deprecated entries remain so
historic incident logs always resolve.

## 4. Subcontractors & sub-processors
PsyClinicAI will require any subcontractor that creates, receives, maintains,
or transmits PHI on PsyClinicAI's behalf to agree, in writing, to **the same
restrictions and conditions** that apply to PsyClinicAI under this BAA, per
45 CFR §164.502(e)(1)(ii).

The current sub-processor list with Business Associate posture is published
at https://psyclinicai.com/dpa and the underlying matrix lives in
`docs/legal/SUBPROCESSORS.md`. PsyClinicAI will give the Covered Entity
**30 days written notice** of any new sub-processor that will process PHI,
during which the Covered Entity may object in writing; either party may then
terminate the Service Agreement without penalty under §9 of this BAA.

## 5. Reporting

### 5.1 Security Incidents
PsyClinicAI will report any Security Incident (other than ping sweeps, port
scans, and other unsuccessful attempts that do not result in unauthorised
access to PHI) to the Covered Entity **without unreasonable delay and no later
than 5 business days** after discovery.

### 5.2 Unauthorised use or disclosure
PsyClinicAI will report any use or disclosure of PHI not permitted by this
BAA, including any Breach of Unsecured PHI, under §5.3.

### 5.3 Breach notification (HITECH §13402)
For any Breach of Unsecured PHI:

| Step | Deadline |
|---|---|
| Initial notification to the Covered Entity | Without unreasonable delay and in no case later than **60 calendar days** after discovery (45 CFR §164.410(b)) — we target ≤ **24 hours** as a matter of policy. |
| Initial notification content | 45 CFR §164.410(c): identification of each individual whose PHI was or is reasonably believed to have been accessed, acquired, used, or disclosed; description of what happened; types of PHI involved; steps individuals should take; mitigation steps taken. |
| Follow-up information | As soon as reasonably practicable as facts develop. |
| Cooperation | PsyClinicAI will cooperate with the Covered Entity on any required notifications to individuals (45 CFR §164.404), the media (§164.406), and HHS (§164.408). |

Notice is delivered to the security email the Covered Entity registers in the
operator console (default: account-owner email).

## 6. Individual rights support
PsyClinicAI will, within **15 business days** of a written request from the
Covered Entity, take such action as is necessary to make PHI in its custody
available to support:

- **Access** by the individual or designee (45 CFR §164.524) — DSAR export
  endpoint;
- **Amendment** of PHI (§164.526) — editable Firestore record paths;
- **Accounting of disclosures** (§164.528) — append-only audit chain; and
- **Restrictions and confidential communications** (§§ 164.522, 164.530) —
  configurable per patient record.

## 7. Availability to HHS
PsyClinicAI will make its internal practices, books, and records relating to
the use and disclosure of PHI available to the Secretary of HHS for purposes
of determining compliance with the HIPAA Rules.

### 7.1 Records retention
PsyClinicAI will retain records sufficient to demonstrate compliance with this
BAA for at least **six (6) years** from the date of creation or the date when
last in effect, whichever is later (45 CFR §164.316(b)). Hub backups follow
the restic 6-year retention policy.

## 8. Return or destruction of PHI on termination

### 8.1 Return / destruction
Upon termination of the Service Agreement, PsyClinicAI will, at the Covered
Entity's option, return or destroy all PHI received from, or created or
received on behalf of, the Covered Entity that PsyClinicAI maintains, and
will retain no copies.

### 8.2 Export window
The Covered Entity will have **30 days** post-termination to retrieve PHI
through the DSAR export endpoint. PsyClinicAI will then destroy PHI within an
additional **30 days**, except as provided in §8.3.

### 8.3 Infeasibility
If return or destruction is infeasible (for example, PHI contained in audit
chain rows whose deletion would void the integrity assurance), PsyClinicAI
will extend the protections of this BAA to such PHI and limit further uses
and disclosures to those purposes that make the return or destruction
infeasible. PsyClinicAI will document the basis for infeasibility in writing.

## 9. Term & termination

### 9.1 Term
This BAA is effective on the Effective Date and continues until the earlier
of (i) termination by either party under §9.2, or (ii) the date when all PHI
provided by the Covered Entity is returned or destroyed.

### 9.2 Termination for breach
The Covered Entity may terminate this BAA upon **30 days written notice** if
PsyClinicAI materially breaches a provision of this BAA and fails to cure the
breach within that period.

### 9.3 Continued protections
The obligations under §§ 5, 6, 7, 8, and 10 survive termination.

## 10. Indemnity & limitation of liability

### 10.1 Indemnity by PsyClinicAI
PsyClinicAI will indemnify and hold harmless the Covered Entity from
third-party claims, fines, and reasonable attorney fees arising directly from
PsyClinicAI's breach of this BAA, subject to §10.2.

### 10.2 Liability cap
EXCEPT FOR LIABILITY ARISING FROM (i) PSYCLINICAI'S GROSS NEGLIGENCE OR
WILFUL MISCONDUCT, OR (ii) PSYCLINICAI'S BREACH OF §§ 2 OR 3, EACH PARTY'S
TOTAL CUMULATIVE LIABILITY UNDER THIS BAA WILL NOT EXCEED THE GREATER OF
(A) THE TOTAL FEES PAID BY THE COVERED ENTITY UNDER THE SERVICE AGREEMENT
IN THE TWELVE MONTHS PRECEDING THE EVENT GIVING RISE TO THE CLAIM, OR
(B) USD 100,000.

> Counsel review note: insurance carrier requires cyber liability ≥ USD 1 M;
> align cap with carrier limits before signing.

## 11. Data residency

### 11.1 EU default
Default hosting is the EU ([HOSTING_REGION], currently `europe-west1` for
Firestore + `eu-central` for Postgres on Hetzner). For U.S. customers a
**U.S. data-region add-on** ([e.g. AWS `us-east-1` or GCP `us-central1`])
may be required — confirm in the order form before processing U.S. PHI.

### 11.2 No EU-to-US PHI transfer in default plan
For Covered Entities on the EU plan, PHI does not leave the EU region except
where the BYOK LLM provider sits in the US (then PHI never leaves the
request lifecycle — see §3 BYOK row).

## 12. Miscellaneous

### 12.1 Regulatory amendment
This BAA will be amended automatically to comply with future amendments of
the HIPAA Rules or HITECH that affect the obligations of business associates.

### 12.2 Independent contractor
Nothing in this BAA creates a partnership, joint venture, or agency
relationship.

### 12.3 Interpretation
Ambiguities will be resolved in favour of an interpretation that permits
compliance with the HIPAA Rules.

### 12.4 Survival
Sections that by their nature should survive termination do so, including
§§ 5, 6, 7, 8, 10, and 12.

### 12.5 Severability
If any provision is held invalid, the remainder remains in effect.

### 12.6 Governing law & forum
This BAA is governed by the laws of [STATE] without regard to conflicts of
law. Exclusive jurisdiction and venue lie with the state and federal courts
located in [COUNTY, STATE].

## 13. Notices

| Recipient | Email |
|---|---|
| PsyClinicAI — primary | legal@psyclinicai.com |
| PsyClinicAI — security incidents | security@psyclinicai.com |
| Covered Entity — primary | [CUSTOMER_LEGAL_EMAIL] |
| Covered Entity — security incidents | [CUSTOMER_SECURITY_EMAIL] |

---

### Signatures

**Covered Entity** — signature: ____________  date: ______
**PsyClinicAI** — signature: ____________  date: ______

---

## Counsel red-line checklist (internal — do not send to customer)

- [ ] Confirm `[LEGAL_ENTITY_NAME]` is the entity that actually holds the
      cyber-insurance policy.
- [ ] Insert insurance carrier name + policy number reference in §10 if
      customer requires it.
- [ ] Adjust §10.2 cap to align with insurance limits (USD 100,000 is a
      placeholder).
- [ ] Confirm 5-business-day Security Incident reporting in §5.1 is
      consistent with the customer's own incident policy; some health systems
      require 48-h or 72-h windows.
- [ ] Confirm §7.1 6-year records retention aligns with the customer's state
      law (CA + NY + TX have longer minor-record retention).
- [ ] §12.6 — replace `[STATE]` with the customer's jurisdiction; HIPAA does
      not pre-empt state law where state law is more protective.
- [ ] Verify the sub-processor list on https://psyclinicai.com/dpa is the
      live one before signature.
- [ ] If the customer is a US federal entity (VA, IHS, Tricare), insert
      FAR/DFARS flow-downs as Schedule A.
- [ ] If California consumer: align §7.1 records retention with CMIA (Civil
      Code §56.101) and §8.2 export window with CCPA §1798.130(a)(3).
