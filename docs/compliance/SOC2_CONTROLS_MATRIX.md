# SOC 2 — Trust Services Criteria Controls Matrix

**Status:** Draft for Type I observation window (opens 2026-09-01)
**Owner:** PsyClinicAI CISO
**Source of truth:** `lib/services/compliance/soc2_evidence_registry.dart`
**Last reviewed:** 2026-06

This matrix is the human-readable mirror of the in-code registry.
Auditors and prospective customers should read this file; the
registry generates the same content programmatically so the two
never drift.

---

## Category legend

| Category              | AICPA reference |
|-----------------------|-----------------|
| Common Criteria (CC*) | Security        |
| A*                    | Availability    |
| C*                    | Confidentiality |
| P*                    | Privacy         |

## Status legend

- **implemented** — control in place AND evidence reviewed within 12 months
- **partial** — control exists but evidence is incomplete or stale
- **planned** — committed roadmap item, not yet started

---

## Controls

### CC6.1 — Logical access (authentication)

- **Status:** implemented
- **Evidence:** `lib/screens/auth/mfa_setup_screen.dart` + Firebase MFA
- **Last reviewed:** 2026-06
- **Notes:** TOTP enrolment lands at first login; SMS fallback only with
  explicit clinician opt-in (NIST SP 800-63B AAL2 boundary).

### CC6.6 — Boundary protection (encrypted transit)

- **Status:** implemented
- **Evidence:** TLS 1.3 enforced by Firebase Hosting; Anthropic + Stripe
  relays use TLS 1.3 inside the data centre too.
- **Last reviewed:** 2026-06

### CC7.2 — System monitoring (security events)

- **Status:** partial
- **Evidence:** `audit_logs` collection + `auditRetentionPurge` cron
  (Sprint 9). Missing SIEM forwarder (Sprint 15 backlog).

### CC7.4 — Incident response

- **Status:** implemented
- **Evidence:** `lib/screens/trust/incident_response_screen.dart`,
  runbook in `docs/RUNBOOK_CLOUD_FUNCTIONS_IAM.md`.

### CC8.1 — Change management

- **Status:** partial
- **Evidence:** `docs/RUNBOOK_CLOUD_FUNCTIONS_IAM.md`, git history.
  Pending: formal change advisory board minutes
  (`docs/compliance/SOC2_CHANGE_MGMT.md` Sprint 15).

### A1.2 — Backup + recovery

- **Status:** partial
- **Evidence:** Firestore daily exports — schedule live, restore drill
  scheduled Sprint 15.

### C1.1 — Data classification + handling

- **Status:** implemented
- **Evidence:** `lib/utils/pii_redaction.dart`, `ConsentGuard`
  fail-closed (`lib/services/compliance/consent_guard.dart`).

### P3.1 — Notice + choice (consent capture)

- **Status:** implemented
- **Evidence:** `lib/models/consent_record.dart`,
  `consent_records` Firestore rules with immutable `withdrawn_at`.

### P5.1 — Access to personal data

- **Status:** implemented
- **Evidence:** `lib/utils/dsar_export_zip.dart`, DPIA
  `docs/compliance/DPIA_AI_ASSISTANCE.md`.

### P6.1 — Disposal of personal data

- **Status:** implemented
- **Evidence:** `functions/src/account_deletion_purge.ts` (Sprint 9)
  hourly cron pseudonymises PHI rows after 30-day grace window.

---

## Gap summary

| Criterion | Gap                                                                |
|-----------|--------------------------------------------------------------------|
| CC7.2     | SIEM forwarder — Sprint 15 backlog                                 |
| CC8.1     | Formal change advisory board minutes — `SOC2_CHANGE_MGMT.md`       |
| A1.2      | Restore drill not yet executed — Sprint 15                         |

## Observation window

- Opens: **2026-09-01** (per `Soc2EvidenceRegistry.observationOpensAt`)
- Type I report target: **2026-12-15**
- Type II observation kickoff: **2027-Q2**
