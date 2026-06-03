# Screenshot inventory — App Store Connect + Google Play

## Required asset checklist

### App Store Connect (iOS)

| Device class | Resolution | Required | Source |
|---|---|---|---|
| iPhone 6.7" (Pro Max) | 1290 × 2796 | 3-10 | `assets/release/ios/6_7/` |
| iPhone 6.5" (XS Max) | 1242 × 2688 | 3-10 | `assets/release/ios/6_5/` |
| iPhone 5.5" (8 Plus) | 1242 × 2208 | 3-10 (back-compat) | `assets/release/ios/5_5/` |
| iPad Pro 12.9" (6th gen) | 2048 × 2732 | 3-10 | `assets/release/ios/ipad_12_9/` |
| iPad Pro 11" / 12.9" (3rd-5th gen) | 2048 × 2732 | 3-10 | `assets/release/ios/ipad_11/` |
| Apple Watch | 410 × 502 | n/a (not shipping a watch app this release) | — |

### Google Play (Android)

| Asset | Size | Required |
|---|---|---|
| Phone screenshot | 1080 × 1920 minimum | 2-8 |
| Tablet 7" | 1200 × 1920 | 1-8 |
| Tablet 10" | 1600 × 2560 | 1-8 |
| Feature graphic | 1024 × 500 | 1 |
| App icon | 512 × 512 | 1 |

## Recommended shot list (in display order)

1. **Caseload dashboard** — "Your week, at a glance."
2. **Structured session note (SOAP)** — "Notes that scaffold themselves."
3. **PHQ-9 in progress with auto-scoring** — "Validated scales, scored on the spot."
4. **Telehealth video session (blurred patient)** — "Secure video, built for clinical work."
5. **Patient self-service portal** — "Patients book, complete PROMs, and message securely."
6. **Trust Center / Sub-processor list** — "Every dependency disclosed. Every region pinned."

## Capture pipeline

The web-build screenshot script lives at
`scripts/capture_app_store_screenshots.mjs` (Sprint 17 baseline +
Sprint 26 W2 retake — script lands in the follow-up commit). Run on a
freshly-built web bundle:

```bash
flutter build web --release
(cd build/web && python3 -m http.server 8000 &) && sleep 5
node scripts/capture_app_store_screenshots.mjs
```

Outputs land in `assets/release/screens/`. Hand-edit only for the
PHI-blur layer on the telehealth shot.

## Localisation

Screenshots are en-US only at launch. We translate the on-screen
text overlays per locale once the locale lands in-app:

- de-DE, fr-FR, nl-NL, es-ES, it-IT, pl-PL — Sprint 27.
