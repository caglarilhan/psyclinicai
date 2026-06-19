# SOC 2 evidence registry — Trust Service Criteria mapping

**Last reviewed:** 2026-06-19 (Sprint 31 W2)
**Owner:** ciso-advisor@psyclinicai.com
**Audit period start:** 2026-10-01 (Q4 2026)
**Auditor:** TBD (Cure53 engagement letter Sprint 32)

Each row maps one SOC 2 control to (a) the live system surface that
implements it, (b) the evidence artefact we hand the auditor, and (c)
how often the artefact must be refreshed. The quarterly cron
(`scripts/collect-soc2-evidence.sh`) snapshots most rows automatically.

---

## CC1 — Control environment

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC1.1 Code of conduct | `docs/security/workforce-training.md` §1–8 | training-completion CSV per quarter | Quarterly |
| CC1.4 Workforce competence | Workforce training programme | training-completion CSV | Quarterly |
| CC1.5 Org structure | `docs/security/threat-model.md` § ownership | static doc + Slack `#team` membership snapshot | Per change |

## CC2 — Communication and information

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC2.1 Internal communication | Slack `#incidents`, `#launches`, `#security` | weekly Slack export (admin) | Weekly |
| CC2.2 External communication | StatusPage.io, `docs/marketing/launch-kit.md`, `/roadmap` | screenshots + change log | Per incident |
| CC2.3 Customer-facing | BAA, DPA, ToS, Privacy, Pilot Agreement | signed PDFs in vault | Per contract |

## CC3 — Risk assessment

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC3.1 Risk identification | `docs/security/threat-model.md`, `docs/security/qdrant-spof.md` | static doc + sprint close-out review | Quarterly |
| CC3.2 Fraud risk | Stripe webhook idempotency (B-09), audit chain (F-008) | `processed_webhooks` row count + chain verify report | Quarterly |
| CC3.4 Vendor risk | `docs/legal/SUBPROCESSORS.md` § Annex II | static doc + signed DPAs | Per onboard |

## CC4 — Monitoring activities

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC4.1 Monitoring | Sentry, PostHog, Grafana dashboards, `/metrics` endpoint | dashboard URL + alert log | Continuous |
| CC4.2 Independent review | Quarterly access-review (`accessReviewCron`) | `access_review_snapshots/{quarter}` JSON | Quarterly |

## CC5 — Control activities

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC5.1 Selection of controls | `docs/security/threat-model.md` STRIDE per boundary | static doc | Per change |
| CC5.2 Tech infrastructure controls | `firestore.rules`, `rate_limit.ts`, `cost_ledger.py`, `llm_safety.ts` | source diff under git | Per release |
| CC5.3 Policies + procedures | `docs/security/incident-response.md`, `docs/security/workforce-training.md` | static docs | Quarterly |

## CC6 — Logical and physical access controls (the big one)

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC6.1 Logical access | Firestore rules, `setTenantClaim` CF (Sprint 29 S-03), WebAuthn passkeys | rules unit-test pass + claim coverage report | Per release |
| CC6.2 New / modified access | onboard / offboard runbooks (`docs/runbooks/`) | ticket history | Per event |
| CC6.3 Access removal | `account_deletion_purge` CF, JIRA SOX ticket | purge-log CSV | Per event |
| CC6.6 Boundary protection | Caddy + Cloud Functions CORS + Firestore rules | config snapshot | Per release |
| CC6.7 Transmission protection | TLS 1.3, HSTS, CSP (S-07) | `ssl-labs.html` A+ rating screenshot | Quarterly |
| CC6.8 Software intrusion prevention | `lib/llm_safety.ts` jailbreak regex, F-013 SQLCipher | red-team eval + tests | Per release |

## CC7 — System operations

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC7.1 Detection | Sentry alert rules, `rate_limit.blocked`, `daily_cost_cap_exceeded` | alert history | Continuous |
| CC7.2 Anomaly response | `docs/security/incident-response.md` SEV1–4 matrix | post-mortem docs | Per incident |
| CC7.3 Mitigation | kill-switches (D-09 GROQ, Stripe webhook idempotency) | runbook + recent invocations | Per use |
| CC7.4 Evaluation | `docs/security/threat-model.md` quarterly review | review log entries | Quarterly |
| CC7.5 Recovery | restore drill (B-08) | `last-restore-drill.log` GREEN | Monthly |

## CC8 — Change management

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC8.1 Change management | GitHub PR workflow, CI gate (`ci.yml`), CHANGELOG | PR history + green CI runs | Per release |

## CC9 — Risk mitigation

| Control | Implementation | Evidence | Cadence |
|---|---|---|---|
| CC9.1 Business continuity | DR drill (D-05 RTO/RPO), restic backups | DR drill log | Quarterly |
| CC9.2 Vendor management | `docs/legal/SUBPROCESSORS.md` + DPA copies | static doc | Per onboard |

---

## Evidence storage layout

```
docs/security/evidence/
  2026q3/
    F-001/  …F-013/                     # pentest retest evidence
    soc2/
      CC1.1-training-completion.csv
      CC1.5-team-roster.png
      CC4.1-grafana-dashboard.png
      CC4.2-access-review-2026Q3.json
      CC6.7-ssl-labs-rating.html
      CC7.5-last-restore-drill.log
      CC8.1-pr-history.json
```

The quarterly cron snapshots **CC1.1**, **CC4.2**, **CC6.7**, **CC7.5**,
**CC8.1** automatically. Manual sections (CC1.5 team roster, CC2.3
signed contracts) are owned by the ciso-advisor as a checklist on the
sprint close-out.

## Manual review checklist (per quarter)

- [ ] CC1.5 team roster screenshot (Slack `#team` member list).
- [ ] CC2.3 contracts vault (every customer DPA/BAA up to date).
- [ ] CC3.4 vendor risk — every subprocessor in `SUBPROCESSORS.md`
  matched to a signed DPA copy.
- [ ] CC5.3 review IR + workforce-training docs for currentness.
- [ ] CC7.4 threat-model walkthrough with sec-team.
- [ ] CC9.2 every new subprocessor logged in DPA review minute.

When all rows pass, append a row to `docs/security/evidence/soc2/
audit-trail.csv`:
`quarter, ciso_reviewer_id, completed_at_iso, notes_md_path`.
