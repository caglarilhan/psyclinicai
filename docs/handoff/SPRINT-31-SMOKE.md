# Sprint 31 — Post-Deploy Smoke Runbook

Layered on top of `PILARS-DEPLOY-RUNBOOK.md`. Covers everything Sprint
31 shipped: Groq/Gemini free-tier demo chain, BYOK BAA gate, dashboard
Firestore streams, /help + /compare rewrites, Sentry health probe,
legal disclosures.

**Estimated time: 30 minutes** (chase edge cases at the end).

Owners: single clinician on-call. Run in one sitting, browser + phone
side-by-side.

---

## Pre-flight (2 min)

```bash
cd ~/psyclinicai
git checkout main && git pull --ff-only origin main

# Confirm Sprint 31 landed
git log --oneline main -20 | grep -E "PR #(215|216|217|218|219)" || echo "STOP: Sprint 31 not on main"
```

**Pass:** all 5 PR numbers appear in the log.

---

## Section A — Cloud Functions health (5 min)

### A1. Deploy + version tag

```bash
cd functions && npm run build
firebase deploy --only functions --project psyclinicai-prod
```

**Pass:** deploy summary shows `aiScribeDraftSoap`, `tpDraftPlan`,
`mbcDispatchLink`, `mbcSubmitAssessment`, `noshowPredict`,
`mbcCadenceCron` **all listed with the fresh SHA**. If `mbcCadenceCron`
does NOT appear → Blaze plan not enabled; skip cron only.

### A2. Sentry DSN check via /status

Open `https://psyclinicai.com/status` — scroll to the "Observability"
section.

**Pass:** the Sentry row says **`wired`** with `env=production` and
`dsn=configured`. **Fail modes:**
- `misconfigured` = DSN set but init failed → check env in `firebase
  functions:config:get` and re-deploy.
- `off` = DSN never bound → set `SENTRY_DSN` build define and re-deploy
  hosting.

### A3. Free-tier chain smoke

Open a **Demo-tier** workspace (no BYOK key). Draft a SOAP note with
one of the shipped synthetic vignettes.

**Pass:** the draft renders with a **provider tag** on the badge. In
Cloud Logging, filter by `resource.labels.function_name="aiScribeDraftSoap"`
and confirm the log line `llm_provider.fellover` shows `to=groq` OR
`to=gemini` for at least one request in the last 10 minutes.

---

## Section B — Firestore rules + streams (7 min)

### B1. Rules deploy

```bash
firebase deploy --only firestore:rules --project psyclinicai-prod
```

**Pass:** deploy summary shows 5 new collection rules for
`ai_scribe_drafts`, `mbc_dispatch`, `mbc_submissions`,
`noshow_predictions`, `tp_drafted_plans`.

### B2. MBC dashboard live stream

- Login as a demo clinician
- `/clinician/mbc` → set patient id `pilot-smoke-01`, scale PHQ-9, tap
  "Generate link"
- Copy the URL, open in an incognito tab, submit the assessment

**Pass:** the "Recent dispatches" panel row **flips from
`outstanding` → `submitted`** within 3 seconds, **no page reload**.

### B3. No-show dashboard live stream

- `/clinician/noshow` → score an appointment with high-risk features
  (5 no-shows in 90d, first session, no safety plan)

**Pass:** the "Recent predictions" panel gets a **new row with a
HIGH badge** within 3 seconds. The probability percentage matches the
`_ScorePanel` value above.

### B4. Clinic isolation

Log out, sign in as a **different clinician (clinic id B)**. Open both
dashboards.

**Pass:** the rows from Section B2/B3 (clinic id A) do **NOT** appear.
Fail = Firestore rule regression, halt release, roll back.

---

## Section C — BYOK BAA gate (5 min)

### C1. Settings entry

`/settings` → confirm both "API keys (device)" and **"BYOK LLM keys
(cloud)"** are listed under Workspace.

### C2. BAA checkbox enforcement

`/settings/byok-llm` → paste a dummy Anthropic key `sk-ant-test-...` →
attempt Save **without** the "I have signed the HIPAA BAA" checkbox.

**Pass:** save is refused with the error `You must confirm you signed
the Anthropic BAA…`. Tick the box → save succeeds. Cloud Logging shows
the write hit `clinicians/{uid}/api_keys/llm`.

### C3. Chain reprioritisation

Draft another SOAP note as this clinician.

**Pass:** Cloud Logging shows `llm_provider.invoked` with
`provider=anthropic` on the FIRST attempt, not Groq. If Groq still
comes first → `resolveProviderChainForUser` regression.

---

## Section D — Legal + trust surfaces (5 min)

Open each page and confirm the new copy is live:

- `/tos` §3 "Service tiers + the LLM you get" ✅
- `/tos` §4 "BAA delegation (US clinicians)" ✅
- `/privacy` §4 names Groq + Gemini ✅
- `/dpa` sub-processors row mentions Groq + Gemini ✅
- `/baa` Subcontractors row explains BYOK delegation ✅
- `/trust/subprocessors` shows `Groq, Inc.` and `Google Ireland Ltd.
  (Gemini API)` **flagged as high-risk** ✅
- `/pricing` shows Demo / **BYOK (Recommended)** / Pro tiers ✅
- `/compare` vendor grid renders Mentalyc / Upheal / Eleos /
  SimplePractice / TherapyNotes columns
- `/compare` on a **375px viewport** falls back to stacked cards ✅
- `/help` FAQ renders with Setup + BYOK / Clinical / Data + Privacy /
  When to email whom sections ✅

**Fail:** any missing section = deploy artefact stale, re-run web
build.

---

## Section E — Landing + dashboard entry (3 min)

- Landing hero has the **secondary CTA "Try demo now — no card,
  synthetic data"** below the primary CTA
- Dashboard `/dashboard` → the 4 pillar tiles (AI Scribe / MBC /
  No-show / TP Drafter) render **at the top**, before "Start a
  session"
- Footer "Contact" link routes to `/contact`; footer "Help" routes to
  `/help` (not `/contact`)

---

## Section F — Ambient scribe UX polish (2 min)

- `/clinician/scribe` — the demo banner is **amber** (not red).
  Colour: bg `#FFF4CC`, fg `#8B5A00`, border `#F5C542`.
- Vignette picker menu shows each item with a **2-line preview**
  (label on line 1, `contextNote` snippet on line 2, ~100 chars).
- Same amber banner on `/clinician/tp-drafter`.

---

## Post-smoke — critical follow-ups (do the day of deploy)

1. **Rotate the leaked API keys**
   Chat leaked `GROQ_API_KEY=gsk_...` and
   `GEMINI_API_KEY=AQ.Ab8RN6...`. Both are still active on prod. Rotate
   in the provider console + update `firebase functions:config:set`.
   ```bash
   firebase functions:config:set groq.api_key="NEW_GROQ_KEY" gemini.api_key="NEW_GEMINI_KEY" --project psyclinicai-prod
   firebase deploy --only functions --project psyclinicai-prod
   ```

2. **Verify Groq/Gemini blocked from PHI**
   `functions/src/lib/llm_provider.ts` exposes `phiSafe: false` on both.
   Manual grep on prod deploy: `firebase functions:log --only aiScribeDraftSoap | grep phi_gate_filtered` — should log
   `filtered=["groq","gemini"]` for any BYOK-tier request.

3. **First 3 clinician invites**
   Send the founder-outreach email from `docs/launch/COLD-EMAIL-KIT.md`
   to the top 3 candidates. Track responses in a spreadsheet — the
   goal is 10 paying pilots.

4. **Sentry breadcrumb spot-check**
   Open Sentry, filter by `environment=production, release=<sha>`.
   Confirm **at least one `funnel` breadcrumb per session** — that
   proves `TelemetryService.capture` is landing.

5. **Cost meter**
   Groq free tier caps at 14.4k tokens/day, Gemini at 1k RPD. Set a
   Cloud Logging alert on `llm_provider.failed reason=rate_limited`;
   more than 3/hour means we need to nudge users toward BYOK sooner.

---

## Rollback triggers

Halt release + roll back the tagged deploy if ANY of:
- Section B4 fails (cross-clinic data leak)
- Section C2 fails (BAA gate bypass)
- Sentry health `misconfigured` and errors are not visible
- More than 2% of `llm_provider.failed` events in the first hour
- Any clinician reports drafting UI silently discarding edits (the
  `_SectionEditor` regression from before Sprint 31 review sweep)

Rollback:
```bash
firebase hosting:clone psyclinicai-prod:live psyclinicai-prod:<previous-version>
firebase functions:rollback --project psyclinicai-prod
```
