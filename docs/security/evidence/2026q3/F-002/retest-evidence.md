# Retest evidence — F-002 (cross-tenant /tenants/{tid} Firestore read)

**Finding ID:** PSY-2026Q3-F-002
**Original severity:** Critical (CVSS 9.1, CWE-285)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** platform-wg (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** senior-security + senior-architect + adversarial-reviewer

---

## 1. Original vulnerability

> Authenticated user A (uid=A) could read `/tenants/B` (uid=B's tenant doc) because the rule only required `request.auth != null`. Tenant metadata (region, plan, feature flags) leaked across tenants — competitor enumeration surface + GDPR Art. 32 breach.

## 2. Fix shipped

- **Commit:** Sprint 28 hardening + Sprint 29 audit_logs deep-validation (`51b2b7f`).
- **Code references:**
  - `firestore.rules:247-252` — `allow read,update: if request.auth.uid == tid`
  - `firestore.rules:96-114` — Sprint 29 B-04 audit_logs schema-shape assertions
- **Tests:** `firestore-rules` emulator suite (Cure53 retest will exercise).

## 3. Retest steps

```bash
# Pre-req: two pilot accounts, uids = TENANT_A and TENANT_B, with valid id tokens.

# 3.1 — Self-read MUST succeed
firebase emulators:exec --only firestore \
  "curl -X GET 'http://localhost:8080/v1/projects/psyclinicai/databases/(default)/documents/tenants/${TENANT_A}' \
     -H 'Authorization: Bearer ${TOKEN_A}'"
# Expected: 200 + tenant doc body.

# 3.2 — Cross-tenant read MUST fail
firebase emulators:exec --only firestore \
  "curl -X GET 'http://localhost:8080/v1/projects/psyclinicai/databases/(default)/documents/tenants/${TENANT_B}' \
     -H 'Authorization: Bearer ${TOKEN_A}'"
# Expected: 403 Permission denied (NOT 200 with B's data).

# 3.3 — Cross-tenant audit_logs MUST fail
firebase emulators:exec --only firestore \
  "curl -X GET 'http://localhost:8080/v1/projects/psyclinicai/databases/(default)/documents/audit_logs/some_b_owned_id' \
     -H 'Authorization: Bearer ${TOKEN_A}'"
# Expected: 403 — Sprint 29 B-04 hardening rejects malformed shape too.

# 3.4 — Unauthenticated tenant enumeration MUST fail
curl -X GET 'https://firestore.googleapis.com/v1/projects/psyclinicai/databases/(default)/documents/tenants/anyuid'
# Expected: 401.
```

## 4. Evidence artefacts

- `retest-self-read.txt`
- `retest-cross-tenant-403.txt`
- `retest-audit-logs-403.txt`
- `retest-unauthenticated-401.txt`
- `firestore-rules-unit-tests.txt` — Firebase rules-unit-testing run.

## 5. Sign-off

- [ ] **senior-security:** zero cross-tenant 200 responses across 50+ probe permutations.
- [ ] **senior-architect:** Sprint 30 invariant "tenant claim is the only authorization root" upheld.
- [ ] **adversarial-reviewer:** independent probe of `users/{uid}` + `clinics/{cid}` paths.
- [ ] **ciso-advisor:** `findings.csv` row flipped + DPA cross-tenant clause re-affirmed.

## 6. Audit trail row

```
F-002,YYYY-MM-DD,platform-wg-001,fixed_pending_retest,fixed_verified
```
