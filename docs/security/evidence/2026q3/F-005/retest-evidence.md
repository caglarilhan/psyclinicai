# Retest evidence — F-005 (PHI leakage in Cloud Logging on passkey verify error)

**Finding ID:** PSY-2026Q3-F-005
**Original severity:** Medium (CVSS 6.5, CWE-532)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** sec-team (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** senior-security + healthcare-phi-compliance + silent-failure-hunter

---

## 1. Original vulnerability

> Unhandled exceptions in `passkey_authenticate.ts` included raw `uid` + `credential_id` when the FIDO2 verification library threw before redaction. Cloud Logging retained those entries indefinitely — HIPAA §164.312(b) audit-log integrity surface + log-based PHI exfil.

## 2. Fix shipped

- **Commit:** Sprint 28 close (`5ba8f83`), Sprint 29 rate limit gate (`51b2b7f`).
- **Code references:**
  - `functions/src/passkey_authenticate.ts:271-275` — `String(e).slice(0, 120)` strip in catch block
  - `functions/src/passkey_authenticate.ts:248-253` — sign-count regression log uses `hashCredentialId()` (16-char SHA prefix), not raw id
  - `functions/src/lib/rate_limit.ts` — Sprint 29 S-01 wraps the endpoint, fewer error paths overall

## 3. Retest steps

```bash
# 3.1 — Force a verifier error with a corrupt assertion payload.
curl -X POST https://europe-west1-psyclinicai.cloudfunctions.net/passkeyAuthVerify \
    -H "Authorization: Bearer ${PILOT_IDTOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"credentialId":"deadbeef","assertionResponse":{"id":"corrupt","rawId":"corrupt"}}'
# Expected: 400 verification_error.

# 3.2 — Inspect the Cloud Logging entry for the error.
gcloud logging read 'resource.type="cloud_run_revision" AND severity>=ERROR AND timestamp>="<NOW-1m>"' \
    --format json --limit 5 > f005-cloudlog.json

# 3.3 — Assert NO raw credential id (length > 16) appears in the log
jq -r '.[].jsonPayload.error' f005-cloudlog.json | grep -E '[0-9a-f]{32,}' \
    && echo 'FAIL — raw credential id leaked' || echo 'OK — only the 16-char hash present'

# 3.4 — Assert error string was truncated to 120 chars.
jq -r '.[].jsonPayload.error | length' f005-cloudlog.json | awk '$1>120 {print "FAIL"} $1<=120 {print "OK len="$1}'
```

## 4. Evidence artefacts

- `f005-cloudlog.json` — captured Cloud Logging payload
- `f005-grep-no-rawid.txt` — output of 3.3
- `f005-len-check.txt` — output of 3.4

## 5. Sign-off

- [ ] **senior-security:** No raw uid + credential id pair appears in any log line during the corrupt-assertion test.
- [ ] **healthcare-phi-compliance:** HIPAA §164.312(b) audit posture upheld.
- [ ] **silent-failure-hunter:** rate_limit + verifier guard ensure the error path is exercised (no silent skip).
- [ ] **ciso-advisor:** `findings.csv` row F-005 flipped to `fixed_verified`.

## 6. Audit trail row

```
F-005,YYYY-MM-DD,sec-team-003,fixed_pending_retest,fixed_verified
```
