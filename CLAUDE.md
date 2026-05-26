# PsyClinicAI — Project Instructions

## What this is
Clinical AI product for therapists/psychologists, targeting **EU/US markets**. Flutter app (mobile + web build).

## Stack
- **Flutter / Dart**, Material 3 (`useMaterial3: true`)
- **Firebase** (Auth, Firestore) — see `firebase.json`, `firestore.rules`
- E2E: Playwright against the Flutter web build (`package.json`)
- Theme tokens: `lib/utils/theme.dart` (`AppColors`, `AppTheme`), `lib/theme/`

## ⭐ UI work — non-negotiable
**Before building or editing ANY screen, read `DESIGN.md` and follow it.**
It fixes our 4 known UI problems: empty/flat pages, no cross-page continuity, invisible buttons, eye strain.
- Always wrap screens in the shared shell (`lib/widgets/app_shell.dart`) — never a bare `Scaffold`.
- Use only `AppColors`/`AppTheme` tokens and the DESIGN.md spacing scale.
- Every screen: dense meaningful content (stat rows, lists with icons, status chips), a clear `FilledButton` primary CTA, designed empty states.
- After UI changes run `flutter analyze` and verify it builds.

## Brand voice (EU/US facing)
- Plural, company voice: **"we" / "our team" / "the platform"** — never a single founder persona.
- Position as **EU-based**. Do not surface a personal/Turkish founder identity in product copy.
- Tone: professional, trustworthy, clinical-grade, calm.

## Commands
```bash
flutter pub get          # deps
flutter run -d chrome    # web dev
flutter analyze          # lint — run after changes
flutter test             # unit/widget tests
npm test                 # Playwright e2e (web build)
```

## Conventions
- Code in English, explanations to the user in Turkish.
- Reuse existing widgets in `lib/widgets/` before creating new ones.
- New feature → read related files first, then implement; update/add a minimal test.
- Don't refactor unrelated code during a bugfix.
- Auth / PII / clinical data touches → extra security pass.

## Key paths
- `lib/` — app source · `lib/utils/theme.dart` — design tokens · `lib/widgets/` — shared UI
- `DESIGN.md` — design system (read for all UI) · `docs/` — product docs
- `firestore.rules` — data access rules
