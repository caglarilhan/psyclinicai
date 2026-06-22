# Retest evidence — F-012 (Patient invite link reusable + 7-day TTL)

**Finding ID:** PSY-2026Q3-F-012
**Original severity:** Low (CVSS 3.7, CWE-613)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** patient-portal-wg (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** senior-security + patient-portal-wg + healthcare-phi-compliance

---

## 1. Original vulnerability

> The patient self-service invite link was valid for 7 days and could be redeemed an unlimited number of times. OWASP ASVS V2.3.1 calls for single-use credentials with a tight TTL.

## 2. Fix shipped

- **Commits:** Sprint 27 P2 close (`627f6e9`).
- **Code references:**
  - `functions/src/patient_invite.ts` — token TTL 24 h + single-use redeem (`invite_used_at` server-side flip inside a Firestore transaction)
  - `firestore.rules` — `patient_invites/{token}` allow read + update only when `request.resource.data.used_at == request.time`

## 3. Retest steps

```bash
# 3.1 — Create an invite, redeem it, attempt to redeem the same token.
INVITE_TOKEN=$(firebase functions:shell <<EOF
const r = await mintPatientInvite({patientId:'patient_42'});
console.log(r.token);
EOF
| tail -1)

curl -X POST https://europe-west1-psyclinicai.cloudfunctions.net/redeemPatientInvite \
    -H 'Content-Type: application/json' \
    -d "{\"token\":\"${INVITE_TOKEN}\"}" > f012-first-redeem.txt
grep -q '"status":"redeemed"' f012-first-redeem.txt && echo OK || echo FAIL

# 3.2 — Second redeem MUST 410 Gone.
curl -X POST https://europe-west1-psyclinicai.cloudfunctions.net/redeemPatientInvite \
    -H 'Content-Type: application/json' \
    -w '%{http_code}\n' \
    -d "{\"token\":\"${INVITE_TOKEN}\"}" > f012-second-redeem.txt
grep -q '410' f012-second-redeem.txt && echo OK || echo 'FAIL — token reusable'

# 3.3 — Mint a fresh invite, fast-forward Firestore createdAt by 25 h, redeem.
TOKEN_EXPIRED=$(node -e "console.log(require('uuid').v4())")
# (replace with the real mint output + a backdated createdAt)
curl -X POST https://europe-west1-psyclinicai.cloudfunctions.net/redeemPatientInvite \
    -H 'Content-Type: application/json' \
    -w '%{http_code}\n' \
    -d "{\"token\":\"${TOKEN_EXPIRED}\"}" > f012-expired-redeem.txt
grep -q '410' f012-expired-redeem.txt && echo OK || echo 'FAIL — TTL not enforced'
```

## 4. Evidence artefacts

- `f012-first-redeem.txt`
- `f012-second-redeem.txt`
- `f012-expired-redeem.txt`

## 5. Sign-off

- [ ] **senior-security:** Single-use + 24 h TTL both enforced.
- [ ] **patient-portal-wg:** Replay against redeem returns 410.
- [ ] **healthcare-phi-compliance:** Closed invite never reactivated, even with clock skew.
- [ ] **ciso-advisor:** `findings.csv` row F-012 flipped to `fixed_verified`.

## 6. Audit trail row

```
F-012,YYYY-MM-DD,patient-portal-wg-002,fixed_pending_retest,fixed_verified
```
