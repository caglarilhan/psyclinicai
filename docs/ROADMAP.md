# PsyClinicAI Roadmap

**Last reviewed:** 2026-06-02

Every closed sprint has a one-line summary and a link to its full
plan. New plans land in `docs/sprints/sprint-NN.md`.

---

## Shipped sprints

| Sprint | Theme                                            | Plan |
|--------|--------------------------------------------------|------|
| 1–5    | Foundational clinical safety + intake + consent  | see legacy commit history |
| 6 + 7  | ConsentGuard + 24-finding skill-review pass      | [sprint-06-07.md](sprints/sprint-06-07.md) |
| 8      | DSAR encrypted export, web PHI gate, i18n        | [sprint-08.md](sprints/sprint-08.md) |
| 9      | Backend skeleton — audit retention + erasure + cross-clinic supervision | [sprint-09.md](sprints/sprint-09.md) |
| 10     | DPIA + TIA + cross-device soft-lock + ARB bind   | [sprint-10.md](sprints/sprint-10.md) |
| 11     | Telehealth (Daily.co) + Stripe deposit handlers  | [sprint-11.md](sprints/sprint-11.md) |
| 12     | e-Rx market-agnostic + EHDSI / MEDULA + DDI gate | [sprint-12.md](sprints/sprint-12.md) |
| 13     | Patient portal DSAR + PROM wiring                | [sprint-13.md](sprints/sprint-13.md) |
| 14     | SOC 2 Type I evidence registry + mobile prep + skill-polish pass | (see compliance docs) |

---

## In flight

- Sprint 14 polish (post-multi-skill review) — see top-level
  `TaskList` for the active items.

---

## Backlog (Sprint 15+)

- SOC 2 SIEM forwarder (CC7.2) + change-management evidence (CC8.1)
- Firestore daily-export restore drill (A1.2)
- Lexicomp / IBM Micromedex DDI integration (`ddi_checker.dart`)
- Patient-side auth scope (separate Firebase project / custom claim)
- US e-Rx (SureScripts EPCS) adapter
- Telehealth widget wiring (real Daily.co JS / Flutter WebRTC)
- App Store + Play Console submission

---

## Cross-cutting reference docs

- Architecture: `ARCHITECTURE.md`
- Design system: `DESIGN.md`
- Deployment: `docs/DEPLOYMENT_GUIDE.md`
- IAM runbook: `docs/RUNBOOK_CLOUD_FUNCTIONS_IAM.md`
- Mobile release checklist: `docs/MOBILE_RELEASE_CHECKLIST.md`
- Compliance bundle: `docs/compliance/`
  - `DPIA_AI_ASSISTANCE.md`
  - `TIA_ANTHROPIC.md`
  - `TIA_STRIPE.md`
  - `SOC2_CONTROLS_MATRIX.md`
  - `SOC2_ACCESS_REVIEW.md`
  - `ROPA_REGISTRY.md`
