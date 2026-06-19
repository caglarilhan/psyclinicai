# Incident-response runbook

**Owner:** sec-team@psyclinicai.com (rotating on-call)
**Last reviewed:** 2026-06-19 (Sprint 29 S-04)
**Next review:** every sprint close-out + post any SEV1/SEV2

This runbook satisfies HIPAA §164.308(a)(6) (security-incident procedures) and GDPR Art. 32(1)(c) + Art. 33 (notification to supervisory authority within 72 h, Art. 34 notification to data subjects without undue delay). The skill panel below is a permanent part of the runbook; every SEV1/SEV2 post-mortem must check it off.

---

## 0. Severity matrix

| Severity | Examples | Time-to-acknowledge | Time-to-containment | Notification |
|---|---|---|---|---|
| **SEV1** | Active PHI exfiltration, ransomware, cross-tenant data leak in production, payment fraud in flight | 15 min | 1 h | GDPR Art. 33 ≤ 72 h, HHS HIPAA ≤ 60 d, affected pilots ≤ 24 h |
| **SEV2** | Auth bypass demonstrated, account takeover, S3-equivalent public exposure | 30 min | 4 h | Same |
| **SEV3** | Single-user account compromise (passkey lost, phishing), suspicious activity, partial outage | 4 h business hours | 1 business day | Customer-direct, no regulator |
| **SEV4** | Vulnerability disclosure, low-impact bug, false alarm | 1 business day | Next sprint | Reporter only |

A tie or doubt always rounds **up** in severity.

---

## 1. Detection sources (anything here triggers triage)

- Sentry alert rules (released after D-07): `error_rate > 5 %` 5-min window, `unhandled_exception` on auth or billing files, `cross-tenant` keyword in any log line.
- StatusPage incident posted by an external monitor (released after D-08).
- `audit_logs` hash-chain break detected by `accessReviewCron` (F-008 already fixed).
- Cloud Logging metric: `rate_limit.blocked` (S-01) above 100/h on a single bucket = active enumeration attempt.
- Cloud Logging metric: `daily_cost_cap_exceeded` (B-01) above 10 events/h = LLM abuse or runaway.
- Cloud Logging metric: `default_tenant_fallback` (B-07) in production = misconfiguration, treat as SEV2.
- Inbound report via `security@psyclinicai.com` (PGP key fingerprint published in `SECURITY.md`).
- Inbound report via Trust Center "report a vulnerability" form.

---

## 2. Phases

### Phase 1 — Triage (T+0 to T+30 min)

1. On-call acknowledges in `#incidents` (Slack) within the severity SLA.
2. On-call opens incident doc `docs/security/incidents/INC-YYYYMMDD-HHMM.md` from the template at `docs/security/_incident-template.md` (created on first incident — file will be born then).
3. Fill: severity, summary (1 sentence), suspected scope (which tenants? which surface?), confidence (low/med/high).
4. Page incident commander if SEV1/SEV2 (commander != on-call). Commander runs the call; on-call drives technical work.
5. Decide: is this a confirmed breach of PHI confidentiality/integrity? If yes, the **GDPR Art. 33 72-h clock starts now** — note the wall-clock timestamp in the incident doc.

### Phase 2 — Containment (T+30 min to T+4 h)

- **Cross-tenant leak:** flip the Firebase rules to `match /{document=**} { allow read, write: if false; }` via `firebase deploy --only firestore:rules` (D-03 makes this fast). Accept the outage; ship a clean rules patch over the next hour.
- **Auth bypass:** revoke all sessions via `admin.auth().revokeRefreshTokens(uid)` for the impacted tenant; force passkey re-enrolment.
- **LLM abuse / cost runaway:** flip `GROQ_PAID_TIER_ENABLED=false` (D-09) — the router falls back to Gemini free tier then Ollama (PHI-safe). Update tenant's `daily_cost_cap_usd = 0` to hard-block (B-01).
- **Active exfiltration:** rotate every secret: `FIREBASE_TOKEN`, `RAG_API_KEY`, `STRIPE_LIVE_KEY`, `GROQ_API_KEY`, `RATE_LIMIT_IP_SALT`. Restart all Cloud Functions revisions; restart `rag-service` container with new `.env`.
- **Patient PWA compromise:** flip `firebase.json` Cache-Control on `/portal/**` to `no-store` (already shipped after F-009); push a service-worker `version` bump to force unregister on every browser.
- **Backup integrity doubt:** stop restic pruning (`systemctl stop ragsvc-backup.timer`); take a forensic copy of `/opt/rag-backups`.

### Phase 3 — Eradication (T+4 h to T+24 h)

- Patch the root cause; ship a regression test that fails without the patch.
- Bump the `CHANGELOG.md` under `[Unreleased]` with a `### Security` entry referencing the incident id.
- For any pentest-style finding, append a row to `docs/security/findings.csv` with `severity`, `owasp`, `cwe`, `cvss_score`, `status=fixed_pending_retest`, owner, retest date.

### Phase 4 — Recovery (T+24 h to T+72 h)

- Restore service. Reverse any emergency rules / kill-switch flips one by one with monitoring.
- Run the DR drill checklist (`docs/STATUS.md` §DR) at half scope to confirm restore paths still work after the patch.
- Customer SLA: send a *factual* update every 4 h until close (template lives in `docs/security/_incident-customer-update.md`, born on first use).

### Phase 5 — Lessons (T+72 h to T+5 working days)

- Post-mortem doc: `docs/security/post-mortems/PM-YYYYMMDD-summary.md`. Blameless. Sections: timeline, root cause, contributing factors, what worked, what didn't, action items with owner+date, lessons.
- Each action item → Linear / GitHub Issue, linked from the PM doc.
- Skill-panel review (see § 4) — every persona must sign off the PM.

---

## 3. Notifications & contacts

| Audience | Channel | SLA |
|---|---|---|
| Internal SEV1/SEV2 | Slack `#incidents` + PagerDuty | 15 min |
| Pilot clinicians (SEV1) | Sendgrid blast (P-08) + per-tenant in-app banner | ≤ 24 h |
| GDPR supervisory authority (BfDI / Datatilsynet / CNIL etc.) | `notification@<authority>` per data subject's country | ≤ 72 h from awareness |
| HHS OCR (US PHI breach) | https://ocrportal.hhs.gov/ocr/breach | ≤ 60 days |
| Cyber-insurance carrier | per policy contact card in 1Password vault `legal/insurance` | per policy SLA |
| Outside counsel | per retainer card in 1Password vault `legal/counsel` | immediate for SEV1 |

**Templates:**
- Customer email: `docs/security/_incident-customer-update.md` (born on first incident).
- GDPR Art. 33 notification: `docs/security/_gdpr-art33-template.md`.
- HHS HIPAA notification: `docs/security/_hipaa-breach-template.md`.

---

## 4. Skill-panel sign-off (must be ticked before PM close)

- [ ] **release-manager** — was the kill-switch flipped? Is the rollback path clean?
- [ ] **ciso-advisor** — is the regulatory clock served? Are insurance + counsel in the loop?
- [ ] **cto-advisor** — is the regression test in CI? Does the patch line up with the threat model in `docs/security/threat-model.md`?
- [ ] **senior-architect** — does the patch violate any invariant in `ARCHITECTURE.md` (no PHI in logs, tenant claim is auth root, audit chain append-only, kill-switch for every external)?
- [ ] **silent-failure-hunter** — did anything fail silently before alerting picked it up? File a sub-issue if yes.
- [ ] **cmo-advisor** — is the customer comms timeline + tone aligned with brand voice?
- [ ] **founder-coach** — what changes about how we sequence work in the next sprint to prevent recurrence?
- [ ] **change-management** — is the public status page + roadmap update queued?

---

## 5. Drills

- **Tabletop SEV1**, quarterly, 60 min. Scenario picked from the threat model. Out come: timing data + skill-panel notes.
- **Restore drill**, monthly, ≤ 6 h. Full DR per `docs/STATUS.md` §DR. Outcome: GREEN/AMBER/RED row in `docs/sprints/sprint-N-closeout.md`.
- **Phishing drill on staff**, half-yearly. Outcome: click-rate metric + training queue.

---

## 6. Closing the loop

An incident is closed when:
1. The action items in the PM have target dates.
2. The skill-panel checklist (§ 4) is signed.
3. The customer / regulator / insurer notifications are sent and acknowledged.
4. The pentest ledger (`docs/security/findings.csv`) and CHANGELOG carry the entry.
5. The next sprint plan picks up the action items.

Anything else gets a follow-up incident, not a close.
