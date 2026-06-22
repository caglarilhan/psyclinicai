/*
 * PsyClinicAI patient-portal service worker — Sprint 27 / F-009 close.
 *
 * Goal: stop the prior-patient inbox leak on a shared kiosk. We
 *   - never cache /portal/** or /api/portal/** responses (these are
 *     PHI-bearing and per-user),
 *   - serve them network-first with `cache: 'no-store'`,
 *   - on logout, the app posts {type: 'logout'} and we drop every
 *     Cache + claim all clients so the next tab sees no stale data.
 */

const SW_VERSION = "psy-portal-sw-v1";

self.addEventListener("install", (event) => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener("activate", (event) => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names.map((n) => caches.delete(n)));
    await self.clients.claim();
  })());
});

const AUTH_ROUTE_RE = /\/(portal|api\/portal)(\/|$|\?)/;

self.addEventListener("fetch", (event) => {
  const req = event.request;
  let url;
  try {
    url = new URL(req.url);
  } catch (_) {
    return;
  }
  if (url.origin !== self.location.origin) return;
  if (!AUTH_ROUTE_RE.test(url.pathname)) return;

  event.respondWith((async () => {
    try {
      return await fetch(req, {
        cache: "no-store",
        credentials: req.credentials || "same-origin",
      });
    } catch (e) {
      return new Response(
        JSON.stringify({error: "offline", route: url.pathname}),
        {
          status: 503,
          headers: {"content-type": "application/json"},
        },
      );
    }
  })());
});

self.addEventListener("message", (event) => {
  // Origin check: only accept messages from a client served by this
  // service worker's own scope. Browsers already restrict
  // Window→SW postMessage to same-origin, but an explicit check
  // closes CodeQL "Missing origin verification in postMessage
  // handler" and is defence in depth.
  const sourceUrl = event.source && event.source.url;
  if (!sourceUrl || new URL(sourceUrl).origin !== self.location.origin) {
    return;
  }
  const data = event.data || {};
  if (data.type === "logout") {
    event.waitUntil((async () => {
      const names = await caches.keys();
      await Promise.all(names.map((n) => caches.delete(n)));
      await self.clients.claim();
      const all = await self.clients.matchAll({includeUncontrolled: true});
      for (const c of all) {
        c.postMessage({type: "logout_ack", swVersion: SW_VERSION});
      }
    })());
  }
});
