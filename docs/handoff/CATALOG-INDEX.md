# Pinned policy catalog index

Single-page reference of every pinned-helper policy catalog shipped
to date. Each row maps a catalog → its purpose → its regulatory
anchors → the file that pins it. Auditor-defensible: show this index
+ the underlying file + its test file to evidence pack any SOC 2 /
ISO 27001 / HIPAA / GDPR / EU AI Act control.

Snapshot date: 2026-06-28.

## How to read this index

Every catalog has the same shape:
- A `const` table of records under
  `lib/services/<domain>/<id>_catalog.dart` (or `_schedule.dart` /
  `_policy.dart` / `_registry.dart`).
- An invariant-test file under `test/<id>_catalog_test.dart` that
  enforces structural + safety-critical rules (regulatory anchor
  required, monotonic ladders, enum coverage).
- A `lastReviewed` YYYY-MM stamp that drives the trust-center
  "needs review" badge.

Catalog ids follow a stable taxonomy:
- **L** = AI governance (LLM safety, training data, oversight).
- **K** = Compliance (GDPR, HIPAA, consent, retention).
- **N** = Security (auth, key mgmt, vulnerability, response).
- **O** = Operations + data (env, tenants, jobs, analytics).
- **M** = Marketing + comms (status page, incident comms, launch).
- **J** = Clinical (assessments, crisis, escalation).

## AI governance (L)

| id  | catalog | PR  | regulatory anchors |
|-----|---------|-----|--------------------|
| L1  | AI output guard pattern | (already merged) | OWASP LLM Top-10 LLM01 + LLM06 + HIPAA §164.502(b) |
| L2  | CSSRS clinical escalation runbook | #116 | Joint Commission NPSG 15.01.01 + FDA CDS Sep 2022 |
| L3  | Prompt registry + model card | #117 | EU AI Act Art. 13 + Art. 14 + FDA CDS |
| L6  | On-device jailbreak pattern | #130 | OWASP LLM Top-10 LLM01 |
| L7  | Model card annual review | #135 | EU AI Act Art. 13 + FDA CDS Sep 2022 |
| L8  | AI training-data eligibility | #139 | GDPR Art. 9 + EU AI Act Art. 10 + HIPAA §164.514 |
| L9  | PHI scrub pattern | #142 | HIPAA Safe Harbor §164.514(b)(2)(i) |
| L10 | AI usage budget | #152 | EU AI Act Art. 14 + cost containment |
| L11 | AI hallucination warning | #157 | FDA CDS + Joint Commission NPSG + EU AI Act Annex III §5(b) |
| L12 | AI clinician override audit | #158 | EU AI Act Art. 14 + HIPAA §164.312(b) + §164.316(b)(2)(i) |

## Compliance (K)

| id  | catalog | PR  | regulatory anchors |
|-----|---------|-----|--------------------|
| K6  | Consent kind catalog | #124 | GDPR Art. 7 + Art. 9 + KVKK md. 6 |
| K7  | Data classification policy | #133 | GDPR Art. 9 + HIPAA §164.514 + ISO 27001 A.8.2.1 |
| K8  | Subject rights taxonomy | #137 | GDPR Art. 15-22 + HIPAA §164.524-528 |
| K9  | Cookie + tracker taxonomy | #140 | ePrivacy Directive Art. 5(3) + TTDSG §25 |
| K10 | Responsible disclosure policy | #143 | RFC 9116 security.txt |
| K11 | Consent withdrawal cascade | #153 | GDPR Art. 7(3) + Art. 17 |
| K12 | Cross-border transfer register | #155 | GDPR Art. 44-49 + Schrems II + SCC 2021/914 Module 2 |
| K13 | DSAR identity verification | #156 | GDPR Recital 64 + HIPAA §164.514(b)(2) |
| K14 | DPIA trigger | #161 | GDPR Art. 35 + EDPB WP248 rev.01 |
| K15 | Data retention class | #164 | GDPR Art. 5(1)(e) + HIPAA §164.316(b)(2)(i) + NHS England RMC 2023 |
| K16 | GDPR lawful basis | #166 | GDPR Art. 6(1) + Art. 7(3) + Art. 9(2) |
| K17 | DSAR deadline | #170 | GDPR Art. 12(3) + HIPAA §164.524 + §164.526 |

## Security (N)

| id  | catalog | PR  | regulatory anchors |
|-----|---------|-----|--------------------|
| N1  | SLO + error budget | #119 | SOC 2 A1.1 availability commitments |
| N2  | Workforce training programme | #123 | ISO 27001 A.7.2.2 + SOC 2 CC2.3 |
| N3  | On-call incident runbook | #118 | SOC 2 CC7.4 + ISO 27001 A.16.1.5 |
| N4  | Backup catalog + DR runbook | #121 | HIPAA §164.308(a)(7) + ISO 27001 A.17.1 |
| N6  | Vendor SLA + outage credit | #128 | SOC 2 CC9.2 + GDPR Art. 28 |
| N7  | Quarterly access-review | #126 | SOC 2 CC6.3 + HIPAA §164.308(a)(4) |
| N8  | DPIA register | #127 | GDPR Art. 35 + EDPB WP248 |
| N9  | Session timeout policy | #131 | HIPAA §164.312(a)(2)(iii) auto-logoff |
| N10 | Secret rotation calendar | #132 | PCI DSS v4.0 §3.7 + NIST SP 800-57 + SOC 2 CC6.1 |
| N11 | DR drill schedule | #134 | HIPAA §164.308(a)(7)(ii)(D) contingency-plan testing |
| N12 | Alerting policy | #138 | SOC 2 CC7.1 + ISO 27001 A.16 |
| N13 | Change mgmt + freeze windows | #141 | SOC 2 CC8.1 + ISO 27001 A.12.1.2 |
| N14 | Supply chain SBOM + license | #146 | SOC 2 CC9.2 + NIST SP 800-161 |
| N15 | Pentest findings register | #148 | SOC 2 CC4.1 + PCI DSS v4.0 §11.4 |
| N18 | CI/CD workflow inventory | #154 | SOC 2 CC8.1 + ISO 27001 A.12.1.2 |
| N19 | Vendor risk tier | #159 | SOC 2 CC9.2 + ISO 27001 A.15.1 + HIPAA §164.308(b)(1) |
| N20 | Encryption key rotation | #160 | NIST SP 800-57 + HIPAA §164.312(a)(2)(iv) + PCI DSS §3.7 |
| N21 | Pen test scope | #163 | SOC 2 CC4.1 + ISO 27001 A.12.6.1 + PCI DSS §11.4 |
| N22 | DR RPO/RTO | #168 | HIPAA §164.308(a)(7)(ii)(B) + ISO 27001 A.17.1 + SOC 2 A1.2 |
| N23 | Authenticator Assurance Level | #169 | NIST SP 800-63B + HIPAA §164.312(d) + FIDO2 |
| N24 | Security HTTP headers | #172 | OWASP ASVS V14.4 + RFC 6797 + W3C CSP Level 3 |
| N25 | API rate limit | #173 | OWASP API Top-10 API4:2023 + NIST SP 800-63B §5.2.2 |
| N26 | Sub-Resource Integrity | #174 | OWASP ASVS V14.4.4 + W3C SRI + RFC 6234 |
| N27 | CORS allowed-origin | #175 | OWASP API Top-10 API8:2023 + W3C Fetch CORS |

## Operations + data (O)

| id  | catalog | PR  | regulatory anchors |
|-----|---------|-----|--------------------|
| O1  | Activation funnel + cohort | #120 | product analytics |
| O3  | Outcome measure catalog | #144 | published validation refs |
| O4  | Pricing tier catalog | #147 | per-tier feature gate |
| O5  | Analytics event taxonomy | #149 | GDPR Art. 5(1)(c) data minimisation |
| O6  | Feature flag registry | #150 | SOC 2 CC8.1 change management |
| O7  | Deployment environment inventory | #151 | SOC 2 CC8.1 + ISO 27001 A.12.1.4 |
| O8  | Tenant isolation policy | #162 | HIPAA §164.502(b) + OWASP API BOLA + SOC 2 CC6.1 |
| O9  | Required env var | #165 | SOC 2 CC8.1 + ISO 27001 A.12.1.2 |
| O10 | Scheduled job | #171 | SOC 2 CC7.1 + ISO 27001 A.12.1.3 |

## Marketing + comms (M)

| id  | catalog | PR  | regulatory anchors |
|-----|---------|-----|--------------------|
| M2  | Incident comms templates | #125 | HIPAA §164.404 breach notification |
| M3  | Customer support escalation | #129 | SOC 2 CC2.2 internal comms |
| M4  | Public status-page components | #136 | SOC 2 CC2.3 |
| M5  | Launch comms / press kit | #145 | brand voice + brand-guidelines |
| M6  | Status-page audience tier | #167 | HIPAA §164.404 + GDPR Art. 33 + ISO 27001 A.16.1.5 |

## Clinical (J)

| id  | catalog | PR  | regulatory anchors |
|-----|---------|-----|--------------------|
| J3  | Audit-log Firestore mirror | #106 | HIPAA §164.312(b) audit controls |
| J5  | Crisis trigger threshold | #176 | Joint Commission NPSG 15.01.01 + FDA CDS + Kroenke/Spitzer/Posner |

## Cross-cutting invariants

Every catalog test file enforces (at minimum):
- **Records non-empty + unique ids** — catalog cannot ship empty
  and cannot ship with duplicate primary keys.
- **byId resolves every record + null for unknown** — lookup helper
  contract is honored.
- **Enum coverage gap detector** — adding an enum value (e.g. new
  `KeyClass`, new `UserRole`) without a corresponding record fails
  the build. This is the "future-proof" invariant.
- **Populated fields + regulatory anchors** — no catalog entry
  ships without its `description` + `regulatoryRefs`.
- **Monotonic ladders** — where the catalog encodes a severity /
  retention / RPO / AAL hierarchy, the ladder is verified in test.

Catalog-specific safety invariants are listed in each catalog
file's `///` header (search for "**safety-critical invariants**").

## Why this index exists

A regulator (HIPAA OCR, EDPB / national DPA, SOC 2 auditor, FDA
field inspector, ISO 27001 lead auditor) asks ONE question:

> "Show me your policy for X."

Without this index they get sent to 79 PRs to grep through. With
this index they get one filtered row + the file path + the line of
test that proves the policy is enforced at build time.

That is the value-add: **machine-readable policy + test-enforced
invariants + human-readable evidence map**.

## Maintenance

- New catalog: append the row to the matching domain table above.
- Catalog removal: mark deprecated, do not delete the row for one
  audit cycle (drift detection).
- Annual review: bump every `lastReviewed` YYYY-MM stamp.
- New regulation: add the anchor to relevant rows + bump
  `lastReviewed`.
