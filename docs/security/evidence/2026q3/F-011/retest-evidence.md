# Retest evidence — F-011 (healthcheck deep mode unauthenticated)

**Finding ID:** PSY-2026Q3-F-011
**Original severity:** Medium (CVSS 5.3, CWE-639)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** platform-wg (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** senior-security + platform-wg + observability-designer

---

## 1. Original vulnerability

> The `healthcheck` Cloud Function exposed a `?deep=true` mode that listed IAM users for liveness purposes. An unauthenticated caller could enumerate clinician emails via timing differences. CWE-639 + API5:2023.

## 2. Fix shipped

- **Commit:** Sprint 28 P2 close (`8fb50c2`).
- **Code references:**
  - `functions/src/healthcheck.ts` — `?deep=true` requires `X-Healthcheck-Token` header that matches `process.env.HEALTHCHECK_TOKEN`; absent token returns 401 immediately, no IAM call

## 3. Retest steps

```bash
# 3.1 — Plain (shallow) healthcheck MUST succeed unauthenticated.
curl -s https://europe-west1-psyclinicai.cloudfunctions.net/healthcheck > f011-shallow.txt
grep -q '"status":"ok"' f011-shallow.txt && echo OK || echo FAIL

# 3.2 — Deep healthcheck WITHOUT the token MUST 401.
curl -s -o f011-deep-no-token.txt -w '%{http_code}' \
    'https://europe-west1-psyclinicai.cloudfunctions.net/healthcheck?deep=true' \
    | grep -q '401' && echo OK || echo 'FAIL — deep mode reachable unauthenticated'

# 3.3 — Deep healthcheck WITH the right token MUST 200.
curl -s -H "X-Healthcheck-Token: ${HEALTHCHECK_TOKEN}" \
    'https://europe-west1-psyclinicai.cloudfunctions.net/healthcheck?deep=true' \
    > f011-deep-authed.txt
grep -q '"iam_users":' f011-deep-authed.txt && echo OK || echo FAIL

# 3.4 — Timing-based enumeration probe: 50 unauthenticated requests must
# return the same 401 + roughly the same latency (< 50ms variance).
for i in {1..50}; do
    /usr/bin/time -p curl -s -o /dev/null -w '%{http_code} %{time_total}\n' \
        'https://europe-west1-psyclinicai.cloudfunctions.net/healthcheck?deep=true' \
        2>>f011-timing.txt
done
```

## 4. Evidence artefacts

- `f011-shallow.txt`
- `f011-deep-no-token.txt`
- `f011-deep-authed.txt`
- `f011-timing.txt`

## 5. Sign-off

- [ ] **senior-security:** Deep healthcheck refuses unauthenticated calls; no IAM listing leaks.
- [ ] **platform-wg:** Token rotation runbook documented.
- [ ] **observability-designer:** Shallow path remains scrape-friendly for StatusPage / blackbox.
- [ ] **ciso-advisor:** `findings.csv` row F-011 flipped to `fixed_verified`.

## 6. Audit trail row

```
F-011,YYYY-MM-DD,platform-wg-003,fixed_pending_retest,fixed_verified
```
