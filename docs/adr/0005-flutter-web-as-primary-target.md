# ADR-0005: Flutter web as the primary launch target

- **Date:** 2026-05-18
- **Status:** Accepted

## Context

Flutter compiles to web, iOS, Android, macOS, Windows, and Linux from one
codebase. We have to pick which target gets first-class pilot support; we
cannot polish six platforms before the first paying clinician.

## Decision

**Flutter web is the primary target through Sprint 6.** Pilots run on the
clinician's desktop browser (Chrome / Edge / Safari).

Native iOS and Android builds are kept compilable but not yet shipped to the
App / Play stores. They become the focus from Sprint 7+ once the web flow is
revenue-validated.

## Consequences

**Pros**

- **Zero-install demo.** A cold-email link opens the live product in one
  click. Critical for solo-founder sales velocity.
- One CI build (web) is enough for the pilot; we are not paying for two
  app-store review cycles.
- Hetzner can host the static bundle for ~€8 / month. No app-store fees.

**Cons**

- Microphone permission and STT quality vary across browsers (covered in
  ADR-0004).
- Flutter web bundle size: `main.dart.js` is 3.8 MB compressed. We monitor
  with a build budget (Sprint 4 CI check) and lean on CanvasKit's CDN.
- iOS / Android push notifications, biometric unlock, and offline mode all
  require native shells. Out of scope until Sprint 7.

## Links

- `web/index.html`
- `pubspec.yaml`
- `deploy/deploy-hetzner.sh`
