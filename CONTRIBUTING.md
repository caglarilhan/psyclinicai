# Contributing to PsyClinicAI

Thank you for considering contributing. PsyClinicAI handles **protected health
information** (PHI); the bar is therefore higher than a typical Flutter app.
Read this whole document before opening a PR.

---

## 1. Code of conduct

We follow the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
Treat clinicians, patients, and contributors with the same respect you would
expect from a hospital colleague.

---

## 2. Getting started

```bash
git clone https://github.com/caglarilhan/psyclinicai.git
cd psyclinicai
flutter pub get
flutter analyze        # must be clean before touching code
flutter test
flutter run -d chrome
```

Need a Firebase project? See [docs/runbooks/firebase-setup.md](docs/runbooks/firebase-setup.md).

---

## 3. Branching & PR workflow

- `main` is always deployable. Never push directly.
- Feature branches: `feat/<short-name>`, `fix/<short-name>`, `chore/<short-name>`.
- Pull request must:
  - reference an issue (or attach a one-paragraph rationale),
  - keep CI green (`analyze`, `test`, `build`),
  - include or update tests for the change,
  - include or update docs / ADR when it changes behavior contracts,
  - get a green review from at least one maintainer.

Squash-merge by default. PR title follows
[Conventional Commits](https://www.conventionalcommits.org/):

```
feat(billing): add insurance eligibility verification
fix(copilot): handle empty transcript before generation
docs(adr): record decision on Firestore tenant model
```

Valid types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `build`, `ci`, `style`, `revert`.

---

## 4. Code standards

### Formatting
- `dart format .` on every save. `dart format --set-exit-if-changed .` is part of CI.

### Analysis
- `flutter analyze` must return **0 errors / 0 warnings on owned code**.
  Legacy orphan code is excluded in `analysis_options.yaml` and tracked
  separately (Sprint 7 cleanup).
- The analyzer runs with `strict-casts`, `strict-inference`, `strict-raw-types`.

### Style
- Prefer single quotes (`'`) for strings.
- Prefer `const` constructors where possible.
- Public API requires Dartdoc (`/// ...`) explaining *intent*, not implementation.
- No `print()` in non-test code. Use the structured logger
  (`lib/services/observability/logger.dart`, Sprint 5).
- No emojis in source code unless explicitly requested for UX copy.

### Architecture
- Repository pattern under `lib/services/data/` is the only place that talks
  to Firestore directly.
- Services in `lib/services/<feature>/` expose typed APIs; UI must not
  consume `Map<String, dynamic>` from raw Firestore.
- Each new feature lives in its own folder: `services/<feature>/`,
  `widgets/<feature>/`, `screens/<feature>/`.

### Testing
- Every new public method requires a unit test under `test/services/<feature>/`.
- Every new screen requires a widget test under `test/screens/<feature>/`.
- Critical happy paths require an integration test under `integration_test/`.
- Coverage target: at least 60% by end of Sprint 4, 80% by end of Sprint 6.

---

## 5. Architecture decisions

Anything more durable than a bug-fix needs an ADR.

```bash
cp docs/adr/0001-byok-anthropic.md docs/adr/00NN-<short-name>.md
```

Format (Michael Nygard style): **Context, Decision, Consequences**.
Number sequentially. Never edit a merged ADR; write a new one that supersedes it.

---

## 6. Compliance gotchas

- **Never commit real PHI.** Sample data must be synthetic (`John Demo`, `BCBS-INS-001`).
- **Never commit API keys** or BAA-protected credentials.
- **Never log full transcripts** — log the sha256 fingerprint instead.
- All new screens that handle PHI must:
  - require an authenticated session,
  - render only data scoped to the current `clinicId`,
  - call the audit log on read (Sprint 5 wiring).
- If a feature touches AI vendor APIs (Anthropic / OpenAI), update
  [`docs/legal/HIPAA-BAA.md`](docs/legal/HIPAA-BAA.md) so the clinician knows.

---

## 7. Issue triage

| Priority | When |
|----------|------|
| `P0-critical` | PHI leak, auth bypass, prod down |
| `P1-high` | Demo / pilot blocker |
| `P2-medium` | Feature gap, UX papercut |
| `P3-low` | Nice-to-have |

| Area | |
|------|-|
| `area/copilot` | AI ambient session |
| `area/billing` | Superbill / CPT / ICD-10 |
| `area/assessments` | PHQ-9 / GAD-7 |
| `area/data` | Firestore / repositories |
| `area/ui` | Widgets / theme |
| `area/compliance` | HIPAA / GDPR / KVKK |
| `area/devx` | CI, lint, docs |

---

## 8. Releasing

Tags follow `vMAJOR.MINOR.PATCH` semver (from Sprint 6 onwards). The CI
release pipeline builds web + iOS + Android and publishes release notes
generated from Conventional Commits.

---

## 9. Reporting security issues

**Do not open a public issue.** See [SECURITY.md](SECURITY.md).
