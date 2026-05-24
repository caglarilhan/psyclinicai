# Security policy

PsyClinicAI processes protected health information (PHI). We take security
seriously and welcome responsible disclosure.

---

## 1. Reporting a vulnerability

**Do not open a public issue.**

Email `security@psyclinicai.com` (or `caglarilhann@gmail.com` until that
address is provisioned) with:

- a description of the vulnerability,
- reproduction steps (target URL, payload, screenshots, logs),
- the impact you believe it has,
- your suggested fix, if any.

We commit to:

- acknowledge within **24 hours**,
- triage and reply with a severity assessment within **5 business days**,
- ship a fix within **30 days** for `P0-critical`, **90 days** for others,
- credit you in the release notes unless you prefer to remain anonymous.

We do not currently run a paid bug-bounty program; we will offer a public
acknowledgement and (where legally possible) a small token of appreciation.

---

## 2. Scope

In scope:
- `https://psyclinicai.com` (production web)
- `https://*.psyclinicai.com` (subdomains we own)
- the `psyclinicai` GitHub repository
- the Hetzner production host
- Firestore security rules

Out of scope:
- third-party services we depend on (Firebase, Anthropic, Hetzner — report to the vendor),
- physical security of clinician devices,
- social engineering of clinicians or PsyClinicAI staff.

---

## 3. Threat model

| # | Threat | Likelihood | Impact | Mitigation |
|:-:|--------|:--:|:--:|------------|
| T1 | Cross-tenant Firestore read | M | High | Per-tenant rule `request.auth.uid == clinicId` enforced at the document root. CI runs emulator tests. |
| T2 | Stolen BYOK API key | M | Medium | Key never leaves OS keychain. Clinician can rotate at any time. Anthropic supports key revocation. |
| T3 | Compromised clinician device | M | High | Firebase tokens are short-lived. Re-auth required for sensitive operations (Sprint 5). |
| T4 | Audio recording leak | L | High | Audio is processed by native STT on-device. Server / network never sees PCM samples. |
| T5 | Transcript leak via Anthropic | M | Medium | Disclosed in onboarding + BAA. Clinician opt-in. Anthropic Bedrock EU residency on roadmap. |
| T6 | XSS / arbitrary script execution | L | High | Flutter web renders via framework primitives, not raw HTML. CSP report-only header in place; will move to enforce post-pilot. |
| T7 | Insecure deserialization | L | High | All Firestore reads go through typed repositories. `Map<String, dynamic>` is never persisted to disk. |
| T8 | Supply-chain attack on dependencies | L | High | `flutter pub deps` audited weekly. `osv-scanner` runs in CI (Sprint 5). |
| T9 | Brute-force on SSH | M | Medium | fail2ban (5 fail / 1 h ban). Hetzner Cloud Firewall allow-list only 22 / 80 / 443 / 3000. SSH password disabled. |
| T10 | DDoS on `psyclinicai.com` | L | Medium | Nginx rate limit + Hetzner network protections. Cloudflare upgrade option held in reserve. |

---

## 4. Disclosed vulnerabilities

None to date.

---

## 5. Compliance certifications & alignment

- HIPAA — aligned, BAA available (signed before any live PHI workflow).
- GDPR — Article 28 DPA available; EU data residency by default.
- KVKK — Turkish DPA available; VERBİS registration in progress.
- SOC 2 Type II — preparation tracked in `docs/legal/SOC2-readiness.md` (target Q4 2026).
- ISO 27001 — backlog (post-SOC 2).

---

## 6. Cryptographic posture

| Layer | Algorithm |
|-------|-----------|
| In transit | TLS 1.2 + 1.3 (Let's Encrypt; HSTS 1 year + preload) |
| Web token | Firebase ID token (RS256, 1-hour TTL) |
| Local cache | `sqflite_sqlcipher` (AES-256) |
| Firestore | Native at-rest encryption (AES-256, Google-managed) |
| Storage / PDFs | Native at-rest encryption + signed URLs (24-hour TTL, Sprint 5) |
| Secrets | OS keychain (`flutter_secure_storage`) |

---

## 7. Operational security

- SSH: key-only authentication, password disabled, `MaxAuthTries 3`.
- fail2ban: 5 failed attempts per 10 minutes triggers a 1-hour ban.
- Unattended upgrades: weekly automatic security patches.
- Cloud firewall: only TCP 22 / 80 / 443 / 3000 + ICMP allowed.
- Backups: weekly Hetzner snapshot. Firestore export to Cloud Storage with 30-day retention (Sprint 5).
- Audit log: append-only, immutable, exported on demand (Sprint 5).

---

## 8. Coordinated disclosure principles

We follow the [ISO/IEC 29147](https://www.iso.org/standard/72311.html) and
[ISO/IEC 30111](https://www.iso.org/standard/69725.html) vulnerability
handling standards. We will never threaten legal action against a researcher
who acts in good faith, follows this policy, and gives us a reasonable
window to remediate before public disclosure.
