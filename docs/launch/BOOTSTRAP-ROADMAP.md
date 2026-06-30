# Bootstrap roadmap — \$0 to first 10 paying therapists

**Constraint**: zero spend on paid LLM APIs until 10 therapists are
paying subscriptions (~\$990/month MRR). Until then we run on Groq +
Gemini free tiers, Firebase Spark, and the existing €4/month Hetzner VPS.

## Three-tier launch plan

### Tier 1 — DEMO (Groq backend, \$0 from us, \$0 from clinician)

**What ships**: PILAR 1 (Ambient Scribe) + PILAR 4 (Plan Drafter) +
PILAR 3 (No-show predictor, no LLM) + PILAR 2 (MBC, no LLM) — all
gated behind a **"⚠️ Synthetic data only — do NOT enter real PHI"**
banner.

**Backend**: `defaultProviderChain()` = `[Groq, Gemini, Anthropic, Azure]`.
Empty Anthropic / Azure keys auto-skip; chain falls through to Groq.

**Cost**:
- Hetzner CX22: €4/month (already paid)
- Firebase Spark: \$0 (Functions 125k invocations/month free)
- Groq free tier: \$0 (14.4M tokens/day cap)
- Gemini free tier: \$0 (60 RPM, 1k RPD)
- **Total: €4/month**

**Marketing goal**: 200 waitlist signups, 50 active free-demo users
by Week 4.

### Tier 2 — BYOK (Bring Your Own Key, \$0 from us)

**What ships**: Settings → API keys → "Paste your Anthropic API key
to use real PHI". Clinician's key encrypted in Firestore (per-user
scope). Per-request resolver: user's BYOK first, then chain.

**Why it works**:
- Anthropic gives \$5 free credit on every new account → 1 week of
  light use is free for the clinician.
- HIPAA BAA between Anthropic and the clinician (not us) → we're not
  a covered entity yet.
- Clinician self-funds inference → \$0 from us.

**Cost**: still €4/month.

**Marketing goal**: 5-10 BYOK trial users actively running real PHI
through the system by Week 6.

### Tier 3 — PRO (\$99/month, we cover everything)

**What ships**: full HIPAA tier. Manual invoicing via Wise or Stripe
Atlas (no payment infra needed for the first 10).

**Unit economics** at 10 paying:
- Revenue: 10 × \$99 = \$990/month
- Anthropic (Haiku/Sonnet mix, ~5k tokens/clinician/day): ~\$300/month
- Firebase Blaze (over Spark quota): ~\$50/month
- Hetzner: €4
- **Net: ~\$636/month positive cash flow**

**Trigger**: first 10 paying customers OR an Anthropic Startup credit
approval (which can come earlier).

## Week-by-week milestones

| Week | Milestone | Spend | Customers |
|---|---|---|---|
| 0 (now) | 4 pillars code complete (PRs open) | €4 | 0 |
| 1 | Demo launch (Groq primary), waitlist live | €4 | 0 / waitlist 20 |
| 2 | Cold-email Wave A (PILAR 1 hero) | €4 | waitlist 60 |
| 3 | Linkedin / Twitter PILAR 3 ROI calculator post | €4 | waitlist 120 |
| 4 | BYOK launch (Sprint 31) | €4 | waitlist 150, BYOK 5 |
| 5 | Apply Anthropic Startup + Microsoft for Startups | €4 | BYOK 10 |
| 6 | First case study (synthetic) | €4 | BYOK 15 |
| 8 | First paid customer | €4 | 1 paid \$99 |
| 12 | 10 paid customers — flip to Blaze | \$50 | 10 paid \$990 |
| 14 | Anthropic Startup credits land | \$50 | 12 paid \$1.2k |
| 20 | BAA tier shipped (Pro plan with our key) | \$200 | 25 paid \$2.5k |

## Startup credit programs (apply Week 5)

These are FREE applications. Solo founder + AI/clinical product
+ paying customers = strong eligibility on every one.

| Program | Credit | Decision time | URL |
|---|---|---|---|
| Anthropic Startup Program | ~\$2.5k Anthropic credits | 30 days | anthropic.com/startups |
| Microsoft for Startups | \$150k Azure (incl. OpenAI BAA) | 2 weeks | startups.microsoft.com |
| AWS Activate | \$1k-100k AWS | 2 weeks | aws.amazon.com/activate |
| Google for Startups Cloud | \$200k Vertex AI | 30 days | startup.google.com |

Even one approval unlocks 6-12 months of full paid-tier runway with
BAA. Worst case (none approved) → revenue covers the \$354/month
at-cap cost by Week 12.

## What the founder does each week

### Week 1
- [ ] Merge the 18 PRs (one-liner already in `PILARS-DEPLOY-RUNBOOK.md`)
- [ ] Add `GROQ_API_KEY` + `GEMINI_API_KEY` to `functions/.env`
- [ ] `firebase deploy --only functions`
- [ ] `firebase deploy --only firestore:rules`
- [ ] `gh workflow run deploy_web.yml`
- [ ] Walk through Step 6 smoke test in `PILARS-DEPLOY-RUNBOOK.md`

### Week 2
- [ ] Send cold-email Wave A using `docs/launch/cold-email-templates.md`
- [ ] Linkedin post (PILAR 1 hero)
- [ ] Add waitlist conversion tracking

### Week 3-4
- [ ] Linkedin post (PILAR 3 ROI calculator hero)
- [ ] Twitter thread (4 pillars in 8 tweets)
- [ ] Land 5 BYOK trial users

### Week 5
- [ ] Apply to all 4 startup credit programs (1 hour total)
- [ ] First demo call recordings

### Week 6-8
- [ ] First paying customer (manual Wise invoice)
- [ ] Case study draft (synthetic patient, clinician quote)
- [ ] Cold-email Wave B (PILAR 2 enterprise)

### Week 9-12
- [ ] Land #5, #8, #10 paying customers
- [ ] Flip to Firebase Blaze
- [ ] Activate Anthropic Startup credits if approved

## When the constraint loosens

**Triggers to start paid spend**:
1. **10 paying customers** (\$990/mo) → upgrade Anthropic + Azure
2. **Any startup credit approval** → upgrade earlier
3. **First clinician request for real PHI on our infra** → BYOK tier
4. **First enterprise pilot prospect** → Pro tier conversation

Until one of those, every dollar stays in the bank.
