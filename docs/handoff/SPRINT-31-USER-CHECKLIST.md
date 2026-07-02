# Sprint 31 — Your Turn: Merge → Deploy → Smoke → Outreach

Every step below is **something you (the human) run** because the
Claude Code auto-mode classifier blocks `gh pr merge`, prod deploys,
and force pushes to shared branches.

Total time end-to-end: **~2 hours** — one focused sitting.

---

## Step 1 — Merge chain (Layer 0 → 4, ~10 min)

You paste each block, wait for it to return, then paste the next. Each
`gh pr merge` triggers a Vercel/Firebase preview CI so give it a few
seconds between layers.

**Layer 0 — foundation (blocks everything downstream):**
```bash
gh pr merge 207 --squash --delete-branch
```
Watch that the response is `✓ Squashed and merged`. If GitHub rejects
with "not mergeable" → re-run after 30s (CI just needs to settle).

Expected side effect: **PRs #208, #209, #210, #211, #212, #214, #216
auto-retarget their base to `main`** (GitHub does this because their
old base branch was deleted).

**Layer 1 — Sprint 31 first wave (7 PRs, run in one block):**
```bash
for pr in 208 209 210 211 212 214 216; do
  gh pr merge $pr --squash --delete-branch || echo "FAILED: #$pr — re-run this one"
done
```

**Layer 2 — depends on Layer 1:**
```bash
for pr in 213 215 217; do
  gh pr merge $pr --squash --delete-branch || echo "FAILED: #$pr — re-run this one"
done
```

**Layer 3:**
```bash
gh pr merge 218 --squash --delete-branch
```

**Layer 4 (final, brings this whole review-sweep chain into main):**
```bash
gh pr merge 219 --squash --delete-branch
```

**Cleanup — Sprint 30 leftovers (superseded by #207):**
```bash
for pr in 195 202 203 204 205; do
  gh pr close $pr --comment "Superseded by #207 consolidation"
done
```

**Verify:**
```bash
git checkout main && git pull --ff-only origin main
git log --oneline main -20 | grep -E "PR #(215|216|217|218|219)"
```
Pass = all 5 PR numbers appear. Fail = one didn't merge; re-run.

---

## Step 2 — Deploy prod (~15 min)

**2a. Firestore rules first** (dashboards break without these):
```bash
firebase deploy --only firestore:rules --project psyclinicai-prod
```
Expected output: 5 new rule blocks listed (`ai_scribe_drafts`,
`mbc_dispatch`, `mbc_submissions`, `noshow_predictions`,
`tp_drafted_plans`).

**2b. Cloud Functions:**
```bash
cd functions && npm ci && npm run build
firebase deploy --only functions --project psyclinicai-prod
cd ..
```
Expected: 6 functions listed with fresh SHA (`aiScribeDraftSoap`,
`tpDraftPlan`, `mbcDispatchLink`, `mbcSubmitAssessment`,
`noshowPredict`, `mbcCadenceCron`). If `mbcCadenceCron` is missing →
Blaze plan not enabled; that's ok, cron optional.

**2c. Set the free-tier LLM keys in prod config:**
```bash
firebase functions:config:set \
  groq.api_key="YOUR_NEW_GROQ_KEY" \
  gemini.api_key="YOUR_NEW_GEMINI_KEY" \
  --project psyclinicai-prod
firebase deploy --only functions --project psyclinicai-prod
```

**IMPORTANT: rotate the leaked keys first.** Earlier chat turns
contained a live `GROQ_API_KEY` (prefix `gsk_lhIBF…`) and
`GEMINI_API_KEY` (prefix `AQ.Ab8RN6…`). Both may still be active in
Groq + Google AI Studio consoles. Steps:
1. Rotate: generate new keys in each provider console
2. Revoke: delete the leaked ones
3. Paste the new keys into the command above (never commit them)

**2d. Web hosting:**
```bash
flutter clean && flutter pub get
flutter build web --release \
  --dart-define=BUILD_ENV=production \
  --dart-define=SENTRY_DSN="$SENTRY_DSN" \
  --dart-define=BACKEND_URL="https://us-central1-psyclinicai-prod.cloudfunctions.net"
firebase deploy --only hosting --project psyclinicai-prod
```

Expected: `https://psyclinicai.com` returns HTTP 200 with the new
`main` bundle SHA in the response headers.

---

## Step 3 — Prod smoke (~30 min)

Run `docs/handoff/SPRINT-31-SMOKE.md` end-to-end. Every section has
pass/fail criteria + fail-mode remediation. If ANY of the rollback
triggers fire, halt + roll back:

```bash
firebase hosting:clone psyclinicai-prod:live psyclinicai-prod:<prev-version>
```

---

## Step 4 — Post-deploy (~15 min the day of, ~2 h across the week)

**Same day:**
- Set a Cloud Logging alert on `llm_provider.failed reason=rate_limited`
  — more than 3 events/hour means Groq quota is exhausting and demo
  users are hitting failures. Log into GCP → Logging → Alerts →
  create alert on `resource.type=cloud_run_revision AND
  jsonPayload.message="llm_provider.failed" AND
  jsonPayload.reason="rate_limited"` — threshold 3/hour, notify
  founders@psyclinicai.com.
- Verify Sentry is receiving events: open Sentry → Issues → filter
  `environment:production`. You should see at least one funnel
  breadcrumb per real session within 10 min of any user activity.

**Days 1-3:**
- Send the founder-outreach template (`docs/launch/cold-email-templates.md`
  → PILAR 1 body) to your top 5 candidates. Personalise
  `{{first_name}}` and `{{calendar_link}}` per recipient. Do NOT
  batch-send — Gmail flags 5+ identical emails/hour as spam.
- Track responses in a fresh Google Sheet (columns: name, email, sent,
  replied, demo booked, converted).

**Days 4-14:**
- Each conversion → walk them through `/settings/byok-llm` in a
  screen-share. The BAA delegation checkbox is the friction point;
  script: "Anthropic signs a HIPAA BAA with you individually, we
  record your acknowledgement — that's the compliance chain. Takes 2
  minutes."
- Watch Cloud Logging for `llm_provider.usage provider=anthropic` —
  that's a paying user. Groq/Gemini events are demo/trial.

**Week 3-4:**
- 3+ paying users → apply to Anthropic Startups
  (`docs/launch/STARTUP-CREDITS-KIT.md`). $5k credits covers your Pro
  tier LLM cost for 6 months.
- 10 paying users → decision point: raise Series-Seed or continue
  bootstrap. The bootstrap roadmap in `docs/launch/BOOTSTRAP-ROADMAP.md`
  breaks this down.

---

## Step 5 — Ongoing monitoring (30 min/week)

**Weekly review — every Monday:**
1. `firebase functions:log --only aiScribeDraftSoap --limit 200 | grep llm_provider.usage`
   — count tokens per provider. If Groq TPD > 10k/day, users are
   burning free tier — nudge them to BYOK.
2. Sentry → Issues → filter by `hint:mbc.*` OR `hint:noshow.*` — any
   new dashboard stream failures? If so, check
   `firestore.rules` deploy state.
3. `gh pr list --state open` — anything stale > 7 days? Close or
   revive.

---

## When things break

- **`gh pr merge` says "not mergeable"**: the base branch's CI is
  still running. Wait 60s and retry.
- **Firebase deploy fails on "not in Blaze"**: switch project to
  Blaze in Firebase console (small monthly bill starts). Or skip
  `mbcCadenceCron` — the rest works on Spark.
- **`llm_provider.usage` logs never appear**: the `phiSafe` gate
  filtered every provider (no BAA-bearing key configured). Check
  `firebase functions:config:get` shows `anthropic.proxy_api_key`.
- **Smoke Section B4 (clinic isolation) fails**: STOP. Revert the
  Firestore rules deploy. Rules regression is a data-leak class
  incident.

---

## Quick reference — the files that matter

| Path | Purpose |
|------|---------|
| `docs/handoff/SPRINT-31-SMOKE.md` | 30-min post-deploy smoke |
| `docs/handoff/PILARS-DEPLOY-RUNBOOK.md` | Baseline PILAR deploy |
| `docs/launch/cold-email-templates.md` | Outreach copy |
| `docs/launch/BOOTSTRAP-ROADMAP.md` | Week-by-week bootstrap arc |
| `docs/launch/STARTUP-CREDITS-KIT.md` | Anthropic + AWS + Google |
| `functions/src/lib/llm_provider.ts` | LLM chain + phiSafe gate |
| `firestore.rules` | Data access rules |

---

## What Claude (me) will do while you execute

Layer 0 fires → I watch CI on the auto-retargeted Layer 1 PRs and
tell you the go/no-go per PR before you paste the next layer. If any
PR has a failing check, I inspect + tell you the fix before you
retry. If everything is green, I confirm and you paste the next
layer.

Ping me with `L0 tamam` / `L1 tamam` etc after each block; that's
your only interaction between blocks.
