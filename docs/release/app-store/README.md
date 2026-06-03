# App Store + Google Play submission package — PsyClinicAI

Sprint 26 W2. Operator-ready bundle for App Store Connect and Google
Play Console. Hand the per-file artefacts in this directory to the
release manager — no further editing required except substituting
the build number and screenshot uploads.

## Manifest

| File | Destination |
|---|---|
| `app-store-listing.md` | App Store Connect → App Information |
| `privacy-nutrition-label.md` | App Store Connect → App Privacy |
| `play-data-safety.md` | Google Play Console → Data safety |
| `app-store-review-notes.md` | App Store Connect → Notes for App Review |
| `keywords.md` | App Store Connect → Localization → Keywords (per locale) |
| `screenshots.md` | Required screenshot inventory + sizes |

## Pre-flight checks (operator)

1. Bundle id `ai.psyclinic.app` matches the signed IPA / AAB.
2. App version + build number incremented from the previous TestFlight
   / Internal track build.
3. The `?deep=true` healthcheck endpoint passes with `status: ok`
   from EU and US edge probes.
4. SOC 2 evidence binder cross-references the build SHA.
5. Sub-processor list at https://psyclinic.ai/sub-processors reflects
   the new build's data flows (e.g. ActivityKit lock-screen does not
   require a new sub-processor — confirm).
