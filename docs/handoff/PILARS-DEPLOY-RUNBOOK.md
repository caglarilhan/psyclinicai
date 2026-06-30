# PILAR 1-4 Deploy + Smoke-Test Runbook

End-to-end checklist from "PRs merged" to "production verified live".
Every step has the exact command + the pass criterion.

Estimated time: **45-60 minutes** including LLM key configuration.

---

## Step 0 — Pre-flight (5 min)

```bash
cd ~/psyclinicai
git checkout main
git pull --ff-only origin main
```

**Pass criterion**: `main` has 16 + 1 = 17 merged PRs reflected in
the log. `git log --oneline -20` shows the PILAR 1..4 commits.

---

## Step 1 — Merge the 17+2 PRs (10 min)

```bash
gh pr merge 188 --squash --delete-branch && \
gh pr merge 189 --squash --delete-branch && \
gh pr merge 190 --squash --delete-branch && \
gh pr merge 191 --squash --delete-branch && \
gh pr merge 192 --squash --delete-branch && \
gh pr merge 193 --squash --delete-branch && \
gh pr merge 194 --squash --delete-branch && \
gh pr merge 195 --squash --delete-branch && \
gh pr merge 196 --squash --delete-branch && \
gh pr merge 197 --squash --delete-branch && \
gh pr merge 198 --squash --delete-branch && \
gh pr merge 199 --squash --delete-branch && \
gh pr merge 200 --squash --delete-branch && \
gh pr merge 201 --squash --delete-branch && \
gh pr merge 202 --squash --delete-branch && \
gh pr merge 203 --squash --delete-branch && \
gh pr merge 204 --squash --delete-branch && \
gh pr merge <FIRESTORE_RULES_PR> --squash --delete-branch
```

I'll give you the `FIRESTORE_RULES_PR` number once it lands.

If a merge fails because the previous merge's CI is still running on
the next PR, wait 2-3 minutes and re-run from the failed one onwards.

**Pass criterion**: `gh pr list --state open` returns no PILAR PRs.

---

## Step 2 — Configure LLM secrets in Cloud Functions (10 min)

PILAR 1 (Scribe) and PILAR 4 (Plan Drafter) both call Anthropic via
the `ANTHROPIC_PROXY_API_KEY` env var. Without it, those handlers
return 500 on every call.

### 2a. Anthropic key (required)

```bash
firebase functions:secrets:set ANTHROPIC_PROXY_API_KEY
# Paste the Anthropic key when prompted (sk-ant-api03-...)
```

### 2b. Azure OpenAI BAA fallback (optional but recommended)

```bash
firebase functions:secrets:set AZURE_OPENAI_ENDPOINT
# Paste: https://YOUR-RESOURCE.openai.azure.com
firebase functions:secrets:set AZURE_OPENAI_API_KEY
# Paste the Azure key
firebase functions:secrets:set AZURE_OPENAI_DEPLOYMENT
# Paste the deployment name (e.g. gpt-4o-mini-baa)
```

If you skip 2b, the system runs Anthropic-only.

### 2c. Verify the secrets landed

```bash
firebase functions:secrets:access ANTHROPIC_PROXY_API_KEY --quiet | head -c 12
# Should print the first 12 chars of your key.
```

**Pass criterion**: the command prints your key prefix (e.g.
`sk-ant-api03`). No "secret not found" error.

---

## Step 3 — Deploy Cloud Functions (10 min)

```bash
cd ~/psyclinicai/functions
npm ci
npx tsc --noEmit          # one last sanity check; should be silent
firebase deploy --only functions
```

Deploy takes 3-5 minutes. Watch for the 5 new function URLs:
- `aiScribeDraftSoap`
- `mbcDispatchLink`
- `mbcSubmitAssessment`
- `noshowPredict`
- `tpDraftPlan`

**Pass criterion**: Deploy completes with no `Error:` lines + all 5
URLs listed.

---

## Step 4 — Deploy Firestore rules (2 min)

```bash
cd ~/psyclinicai
firebase deploy --only firestore:rules
```

**Pass criterion**: "Deploy complete!" with no errors. The 5 new
collection rules go live.

---

## Step 5 — Deploy the web app (5 min)

```bash
gh workflow run deploy_web.yml
gh run watch              # press Enter on the most recent run
```

**Pass criterion**: workflow finishes `completed success`.

---

## Step 6 — Smoke-test on production (10 min, together)

After deploy, open the live URL (`https://psyclinicai.com` or your
Hetzner host) and walk through each pillar.

### 6a. PILAR 1 — Scribe
1. Sign in as a clinician.
2. Dashboard → "Ambient scribe" tile.
3. Fill: session id = `smoketest-1`, transcript = "Patient reports
   2 weeks of low mood and sleep loss. Denies SI."
4. Tap "Draft SOAP".
5. **Expect**: 4 tabs render with content; PHI badge shows redaction
   count (probably 0 for this synthetic transcript).

### 6b. PILAR 2 — MBC
1. Dashboard → "Send MBC check-in".
2. Fill: patient id = `smoke-patient`, scale = PHQ-9.
3. Tap "Generate link". Copy the URL.
4. Open that URL in an incognito tab. Fill 9 answers, submit.
5. **Expect**: thank-you panel with score + severity.

### 6c. PILAR 3 — No-show
1. Dashboard → "No-show risk queue".
2. Fill the form (any synthetic ids). Tap "Score risk".
3. **Expect**: tier badge + recovery playbook with cadence list.

### 6d. PILAR 4 — Treatment plan drafter
1. Dashboard → "Treatment plan drafter".
2. Pick disorder = "Major Depressive Disorder", modality = "CBT".
3. Enter "low mood\nsleep loss" in presenting problems.
4. Tap "Draft plan".
5. **Expect**: 4 sections render (Problems, SMART goals, Sessions,
   Risk review); each SMART goal carries a "cite: NICE CG90..." badge.

If any step fails, grab the CF log:

```bash
firebase functions:log --only <handler_name> --lines 50
```

Paste it back to me and I'll triage in real time.

---

## Step 7 — Rollback (only if Step 6 reveals a regression)

```bash
# Cloud Functions: deploy the previous git tag
git checkout <previous_release_tag>
firebase deploy --only functions

# Web: trigger the previous successful workflow run
gh run rerun <previous_workflow_run_id>
```

---

## What I expect to break (and how)

| Surface | Most likely failure | Fix |
|---|---|---|
| Scribe + Drafter | `ANTHROPIC_PROXY_API_KEY` missing | Step 2a |
| MBC submit (public) | CORS preflight rejects production origin | Add to `ALLOWED_ORIGINS` env |
| Firestore reads (any handler) | Rules deploy didn't propagate | Re-run Step 4 |
| Web build | Pinned Firebase config missing | Re-check `firebase.json` |

If we hit any of these I'll write the fix PR in real time.
