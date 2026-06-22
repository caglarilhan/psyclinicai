# Workforce security training programme

**Last reviewed:** 2026-06-19 (Sprint 30)
**Owner:** sec-team@psyclinicai.com
**Authority:** HIPAA §164.308(a)(5) (security-awareness and training); GDPR Art. 32(4); SOC 2 CC1.4 + CC2.2.

Every individual who handles customer data — full-time, contractor, or
auditor — completes this curriculum before access is granted and refreshes
it annually. Completion is logged in the SOC 2 evidence registry.

---

## 1. Roles + cadence

| Role | First-day | Quarterly | Annual | Trigger-based |
|---|---|---|---|---|
| Engineer with prod access | Modules 1–8 | Phishing drill | Full refresh | After any SEV1/SEV2 incident they were on-call for |
| Engineer without prod access | Modules 1–5 | Phishing drill | Full refresh | Same |
| Founder / business ops | Modules 1, 2, 4, 6, 7 | Phishing drill | Full refresh | Before any board / customer demo |
| Contractor with PHI exposure | Modules 1–5, 8 | — | Full refresh | Before contract renewal |
| Customer success | Modules 1, 2, 4, 7 | Phishing drill | Full refresh | After any new clinic onboard |

A row in `docs/security/evidence/workforce-training/2026-Qn.csv` records:
`name, role, modules_completed, completion_date, evidence_url`.

## 2. Modules

### Module 1 — What PHI / personal data we touch
- Definition of ePHI under HIPAA §164.103.
- Categories of personal data under GDPR Art. 4(1) + special-category Art. 9(1).
- Walk through `firestore.rules` so the trainee can name each collection
  and its access posture.
- Outcome: the trainee can answer "is this PHI?" for 10 sample fields.

### Module 2 — Acceptable use + workstation security
- Disk encryption on every laptop touching `git` (FileVault / BitLocker).
- Password manager (1Password) mandatory; recovery key escrowed.
- Hardware-bound MFA (passkey or YubiKey) on every GitHub + Firebase
  console account.
- No PHI in screenshots, chat messages, or `// TODO` comments.
- Outcome: trainee signs the acceptable-use addendum.

### Module 3 — Secrets handling
- No production secret ever in a chat, email, or unencrypted disk.
- Vendor keys flow through `firebase functions:secrets:set` or the
  Hetzner `/opt/rag-service/.env` file, never via `git`.
- Rotation cadence: secrets rotate every 90 d; emergency rotation per
  the incident-response runbook §2.
- Outcome: trainee performs one rotation in the staging tenant under
  supervision.

### Module 4 — Phishing + social engineering
- Spot a phishing email: from-domain mismatch, reply-to drift,
  urgency tells, unexpected file attachments.
- Voice / SMS pretexting awareness: customer success will never ask
  for a clinician's MFA code; founder will never DM you on Signal to
  request prod access.
- Outcome: trainee passes the quarterly phishing-drill click rate
  threshold (< 5 %).

### Module 5 — Reporting an incident
- How to fill `docs/security/incident-response.md` § Phase 1 template
  inside 30 minutes of suspecting an incident.
- Slack `#incidents` is the primary channel; if Slack is the affected
  surface, fall back to the founder phone tree in 1Password
  `ops/phone-tree`.
- "When in doubt, raise it." No retaliation for false alarms.

### Module 6 — Clinical safety + AI guardrails
- Trainee reads `SYSTEM_PROMPT_BASE` in `psyrag/backend/main.py` and
  the jailbreak patterns in `functions/src/lib/llm_safety.ts`.
- Recognises hallucination patterns (made-up DSM codes, drug
  recommendations without citation).
- Knows when to escalate to a clinician advisor (any output flagged
  as `phi_detected=true` requires sign-off before customer reply).

### Module 7 — Customer comms posture
- The `brand-voice` rule: plural "we / our team / the platform";
  never first-person or country-specific founder identity.
- Status page is the only public channel during an incident; nobody
  speaks for the company in DMs.
- Pricing + roadmap commitments only via `/pricing`, `/roadmap`, or a
  signed pilot agreement — never improvised on a sales call.

### Module 8 — Production access discipline (engineers only)
- Production access is least-privilege; default deny.
- Every prod operation runs through a documented runbook
  (`docs/runbooks/*.md`) or a signed-off ad-hoc change ticket.
- `ssh ragsvc@…` is logged via `auth.log`; weekly review by another
  engineer.
- `firebase deploy` only from CI; manual deploys require ticket + buddy.

## 3. Evidence ledger

Per-quarter CSV at `docs/security/evidence/workforce-training/`. Columns:

```
trainee_id, role, module_id, completion_date, evidence_url, reviewer_id
```

The SOC 2 audit period collector reads the CSV directly; auditors get
a redacted version with the `trainee_id` replaced by a SHA-256 prefix.

## 4. Sanctions

A documented violation of any module triggers the sanctions process:

| Violation tier | Example | Action |
|---|---|---|
| 1 (negligent) | one missed quarterly module, no PHI impact | Coaching + 7-day re-training window |
| 2 (reckless) | sharing a secret on chat, no exploit observed | Written warning + secret rotation + role temporarily downgraded |
| 3 (knowing) | exporting PHI to personal device, bypassing audit chain | Suspension + counsel review + breach assessment |
| 4 (malicious) | exfil for sale / unauthorised account creation | Termination + civil + criminal referral |

All sanctions are logged in `docs/security/sanctions/SANC-YYYYMMDD.md`
(template borns on first use). Whistleblower protection is in the
HR-policy companion doc.
