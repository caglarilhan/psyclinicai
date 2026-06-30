# PILAR 1 — Ambient Clinical Scribe

**Pitch**: "Press record. Get a signed SOAP note in 60 seconds."

The headline feature of the 2026-H2 launch sequence. Ships in 4 PRs.

## Why this sells

- Therapists spend **8–15 hrs/week** on documentation. Ambient scribe
  collapses that to **review-only** (~30s per note).
- Mental-health is under-served by horizontal scribes (Suki, Abridge,
  DeepScribe) because they don't carry psychiatric MSE structure,
  DSM-5-TR alignment, safety-plan integration, or modality awareness.
- Direct ROI sell: "Save 10 hours a week or it's free for 30 days."
- Sticky: once a clinician trusts the scribe, switching cost is
  emotional + workflow-deep — drops churn ~30%.

## Architecture (4-PR slice)

```
PR-1 (this one) — Pinned SOAP catalog (Dart + TS mirror + drift test)
PR-2            — CF aiScribeDraftSoap handler (N24+N25 wired, PHI scrub,
                  LLM provider strategy, audit trail, idempotent)
PR-3            — Flutter ai_scribe_screen + service + provider + tests
PR-4            — Route /clinician/scribe + Trust Center entry +
                  clinician-dashboard nav card + final regression
```

After this slice ships, a **Sprint 2** delivers:

- Live audio capture (Flutter `record` package + chunked upload)
- Whisper transcript proxy CF handler
- Real-time transcript display while recording
- Time-coded "tap to hear" affordance in the review screen

And **Sprint 3** delivers:

- Modality template catalog (CBT/DBT/EMDR/ACT) — `AS2` catalog
- Supervisor co-sign workflow
- PDF export with cited spans for audit

## Regulatory posture

- **HIPAA §164.526** — accuracy of PHI: every claim cites the
  transcript span it was drawn from.
- **HIPAA §164.514(b)** — safe-harbor de-id: `phi_scrub.ts` strips
  PHI before egress; per-tenant LLM keying.
- **HIPAA §164.502(b)** — minimum-necessary: section temperature
  capped, max output tokens capped per section.
- **21 CFR §11** — electronic records integrity: every draft +
  signed note has an audit_chain entry with `before/after/signer`.
- **FDA CDS non-device** — §520(o)(1)(E): scribe never auto-files;
  clinician edits + signs every note before persistence.
- **EU AI Act** — high-risk system disclosure: scribe is disclosed
  as AI-assisted in the signed note's footer.
- **DSM-5-TR** — Assessment section pins working_diagnoses to a
  DSM-5-TR-coded list.

## Catalog (PR-1) source of truth

- Dart: `lib/services/ai_scribe/soap_section_catalog.dart`
- TS mirror: `functions/src/lib/soap_section_catalog.ts`
- Drift test: `test/soap_section_parity_test.dart`
- Invariant tests:
  - `test/soap_section_catalog_test.dart` (Dart side)
  - `functions/src/__tests__/soap_section_catalog.test.ts` (TS side)

## Out of scope for PILAR 1

- Insurance prior-auth letter generator (separate pilar)
- Treatment plan drafter (PILAR 4)
- Outcome-measurement engine (PILAR 2)
- No-show predictor (PILAR 3)
- Stripe billing (no company entity yet — deferred)
