# Retest evidence — F-007 (Telehealth room token leaked in Referer header)

**Finding ID:** PSY-2026Q3-F-007
**Original severity:** Medium (CVSS 5.4, CWE-200)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** platform-wg (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** senior-security + platform-wg + healthcare-phi-compliance

---

## 1. Original vulnerability

> A participant who clicked an external citation link from inside a session note caused the browser to send the telehealth room URL (with embedded token) as the `Referer` header. CWE-200; PHI surface because the token grants ongoing room read access.

## 2. Fix shipped

- **Commits:** Sprint 29 S-02 (`51b2b7f`).
- **Code references:**
  - `firebase.json` hosting headers — `/portal/session/**` → `Referrer-Policy: no-referrer` + `Permissions-Policy: camera=(self), microphone=(self), display-capture=(self)`

## 3. Retest steps

```bash
# 3.1 — HEAD the telehealth route and capture the response headers.
curl -I https://psyclinicai.web.app/portal/session/test > f007-headers.txt

# 3.2 — Assert Referrer-Policy is no-referrer.
grep -i 'referrer-policy:' f007-headers.txt | grep -qi 'no-referrer' \
    && echo OK || echo 'FAIL — Referrer-Policy missing or wrong value'

# 3.3 — Browser smoke: open Chrome DevTools → Network → click an external
# link from inside the telehealth page → assert outgoing request has no
# Referer (or Referer trimmed to origin only — both pass).
# Save the screenshot as f007-devtools-no-referer.png.

# 3.4 — Verify Permissions-Policy hardened.
grep -i 'permissions-policy:' f007-headers.txt | \
    grep -qi 'camera=(self).*microphone=(self)' \
    && echo OK || echo 'FAIL — permissions-policy missing'
```

## 4. Evidence artefacts

- `f007-headers.txt`
- `f007-grep-referrer.txt`
- `f007-devtools-no-referer.png`
- `f007-grep-permissions.txt`

## 5. Sign-off

- [ ] **senior-security:** Referer header not emitted for outbound clicks from `/portal/session/**`.
- [ ] **platform-wg:** Permissions-Policy enforces media-capture allow-list.
- [ ] **healthcare-phi-compliance:** No session-token format string appears in any outbound request.
- [ ] **ciso-advisor:** `findings.csv` row F-007 flipped to `fixed_verified`.

## 6. Audit trail row

```
F-007,YYYY-MM-DD,platform-wg-002,fixed_pending_retest,fixed_verified
```
