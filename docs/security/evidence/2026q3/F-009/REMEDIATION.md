# PSY-2026Q3-F-009 — Remediation evidence

**Finding:** Patient PWA service worker caches authenticated
`/portal/inbox` responses; a shared kiosk session reveals the prior
patient's inbox after logout.
**Severity:** High · CVSS 7.4
(CVSS:3.1/AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:N)
**CWE:** 525 (Use of Web Browser Cache Containing Sensitive Info)
**OWASP API:** API7 — Server-Side Request Forgery (close family — Broken Access via stale cache)
**Opened:** 2026-06-04 · **Remediated:** 2026-06-16 · **Retest due:** 2026-06-25
**Owner:** patient-portal-wg

---

## Root cause

The web build previously shipped Flutter's auto-generated
`flutter_service_worker.js`, which precaches HTML/JS shells and
opportunistically caches GETs. Authenticated `/portal/inbox`,
`/portal/appointments`, and `/portal/messages` responses landed in
that Cache. The boot script in `web/index.html` did blanket
`getRegistrations() → unregister()` on every load — a hack to defeat
stale main.dart.js — but the same blanket purge was not run on
logout, and the underlying Firebase Hosting headers did not set
`Cache-Control: no-store` for the portal routes either. Net effect on
a shared kiosk: the next user's first `/portal/inbox` paint could
hydrate from the prior user's cached response.

## Fix (Sprint 27 W1)

Defence in depth — four layers, smallest blast radius at the top:

### 1. Firebase Hosting headers — `firebase.json`

Added explicit `Cache-Control: no-store, private, must-revalidate`
(plus `Pragma: no-cache`) for `/portal/**` and `/api/portal/**`.
Browser HTTP cache will not retain these responses regardless of
service worker state.

### 2. Patient-portal service worker — `web/sw.js`

A new, intentional SW (replaces the unsupervised
`flutter_service_worker.js`):

- `install`: `self.skipWaiting()` — no precache.
- `activate`: wipe **every** Cache name and `clients.claim()` so the
  active SW immediately controls every open tab.
- `fetch`: intercepts same-origin requests whose path matches
  `/(portal|api\/portal)(\/|$|\?)/` — serves them `network-first`
  with `cache: 'no-store'` and `credentials: 'same-origin'`. On
  network failure it returns `503 {"error": "offline"}` (fail-closed
  — no cached fallback, no stale PHI).
- `message: {type: 'logout'}`: wipe every Cache, `clients.claim()`,
  then fan-out a `logout_ack` to every controlled tab.

### 3. Logout-time client purge — `lib/utils/portal_cache_purge*.dart`

Conditional-import facade (`portal_cache_purge.dart` →
`portal_cache_purge_web.dart` on web, `_stub.dart` everywhere else;
mirrors the existing `document_title*` pattern).

The web impl, called from `FirebaseAuthService.signOut()`:

- `navigator.serviceWorker.controller?.postMessage({type:'logout'})`
  → SW drops Caches.
- `localStorage.removeWhere(k → k.startsWith('portal:') || k.startsWith('auth:'))`.
- Same for `sessionStorage`.

The boot script in `web/index.html` was reworked to register *only*
`/sw.js` and unregister any SW whose `scriptURL` does not contain
`/sw.js` — so a stale Flutter SW cannot coexist with ours.

### 4. Shared-device idle auto-logout

- `SharedDeviceService` — `SharedPreferences`-backed `bool` toggle
  (`security.shared_device`). `ChangeNotifier` so the portal shell
  rebuilds when the user flips kiosk mode.
- `AutoLogoutController` — wraps a `Timer.periodic` ticker. Watches
  `SharedDeviceService.isShared`; when true, idles fire
  `onLogout()` after 5 minutes without `recordActivity()`. Constructor
  takes injected `now: DateTime Function()` for `fake_async`
  widget tests.

W2 wires the controller into `app_shell.dart` (a single root
`Listener` calls `recordActivity()` on pointer events) and adds the
kiosk-mode toggle to the security settings screen.

---

## Test coverage

| Layer | File | Cases |
|---|---|---|
| Kiosk toggle | `test/shared_device_service_test.dart` | 3 — default `false`, persistence across restart, notifier fires |
| Idle timer | `test/auto_logout_controller_test.dart` | 3 — **no fire on non-shared device**, **fires after 5 min idle on shared device**, **activity resets the window** |

`flutter test` run:

```
00:02 +6: All tests passed!
```

`flutter analyze` on touched files: **0 errors, 0 warnings**
(41 info-level — all pre-existing CI `--no-fatal-infos` items).

---

## Vendor retest steps

1. **Cache-Control header probe.** Sign in as patient A, open
   DevTools → Network → reload `/portal/inbox`. Confirm the response
   header set includes `cache-control: no-store, private,
   must-revalidate`.

2. **Service worker scope probe.** DevTools → Application → Service
   Workers. Confirm `sw.js` is `activated and running` and no
   `flutter_service_worker.js` registration is present.

3. **Stale-cache probe.** While signed in as patient A, browse
   `/portal/inbox`, `/portal/appointments`, `/portal/messages`. Sign
   out. Open a new tab, sign in as patient B, browse the same routes.
   Inspect Network → no response is served from `(disk cache)` or
   `(ServiceWorker)`; every response is `200` from the origin and
   contains B's data only.

4. **Logout broadcast probe.** Open the portal in two tabs. Sign in
   as A in both. Sign out in tab 1. Within ~1s tab 2 receives a
   `logout_ack` message (visible via `navigator.serviceWorker
   .addEventListener('message', …)`) and `localStorage` no longer
   contains any `portal:*` / `auth:*` keys in either tab.

5. **Kiosk auto-logout probe.** Enable the kiosk toggle. Sign in,
   leave the tab untouched for 5 minutes. Expected: tab is signed
   out automatically and re-renders the public login screen. Re-run
   with the kiosk toggle off — no auto-logout after 5 minutes.

6. **Offline fail-closed probe.** Block network in DevTools while
   signed in. Navigate to `/portal/inbox`. Expected: a `503` payload
   `{"error":"offline","route":"/portal/inbox"}`, NOT a stale cached
   inbox. The portal UI renders an offline banner.

---

## Residual risk

- IndexedDB is **not** wiped by the SW or the logout purge. The
  portal currently stores nothing PHI-bearing there; the runbook
  flags this for the next sprint.
- Browsers with no Service Worker support (rare, but possible on
  locked-down kiosk OSes) fall back to the `Cache-Control: no-store`
  headers only. This still satisfies F-009; the SW is the second
  line.
- Auto-logout uses wall-clock activity, not actual user focus. A
  background tab keeping a video player open will not be treated as
  active. Sprint 28 may wire `document.visibilityState` if real-world
  retest finds the 5-min window too aggressive.
