# Retest evidence — F-009 (Patient PWA service worker caches authenticated routes)

**Finding ID:** PSY-2026Q3-F-009
**Original severity:** High (CVSS 7.4, CWE-525)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** patient-portal-wg (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** senior-security + healthcare-phi-compliance + senior-frontend

---

## 1. Original vulnerability

> The Patient PWA service worker cached `/portal/inbox` responses regardless of auth status. On a shared kiosk, logging out and signing back in as a different patient could reveal the previous patient's inbox from the cache.

## 2. Fix shipped

- **Commits:** Sprint 27 F-009 close (`f3216b6`), Sprint 29 D-03 rules auto-deploy gate.
- **Code references:**
  - `firebase.json` hosting headers — `/portal/**` + `/api/portal/**` → `Cache-Control: no-store, private, must-revalidate` + `Pragma: no-cache`
  - `web/sw.js` — service-worker logic gates `/portal/**` to `network-only` strategy
  - Kiosk auto-logout (`lib/services/data/auto_logout_controller.dart`) flushes the cache on sign-out

## 3. Retest steps

```bash
# 3.1 — HEAD /portal/inbox and capture Cache-Control.
curl -I https://psyclinicai.web.app/portal/inbox > f009-headers.txt
grep -i 'cache-control:' f009-headers.txt | grep -qi 'no-store' \
    && echo OK || echo 'FAIL'

# 3.2 — End-to-end kiosk regression:
#     a. Sign in as Patient A → open /portal/inbox.
#     b. Force log-out via kiosk timeout (auto_logout_controller).
#     c. Sign in as Patient B with same browser session.
#     d. Open /portal/inbox → assert no Patient-A row appears.
playwright test test/e2e/portal-cache.spec.ts --reporter=line > f009-playwright.txt

# 3.3 — Service-worker cache-storage inspection (Chrome DevTools).
# Save the screenshot showing the `/portal/**` URLs are NOT in any cache.
# File: f009-cachestorage-empty.png.
```

## 4. Evidence artefacts

- `f009-headers.txt`
- `f009-playwright.txt`
- `f009-cachestorage-empty.png`

## 5. Sign-off

- [ ] **senior-security:** Cache-Control header present + Playwright regression passes.
- [ ] **healthcare-phi-compliance:** No PHI surface persists across user sessions on a shared device.
- [ ] **senior-frontend:** Service-worker scope confined; no opportunistic cache.
- [ ] **ciso-advisor:** `findings.csv` row F-009 flipped to `fixed_verified`.

## 6. Audit trail row

```
F-009,YYYY-MM-DD,patient-portal-wg-001,fixed_pending_retest,fixed_verified
```
