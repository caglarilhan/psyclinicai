# Startup credit application kit

Founder runbook: four programs to apply to in Week 5 of the bootstrap
roadmap (`BOOTSTRAP-ROADMAP.md`). Total time to fill all four: ~1 hour.
Expected credit return: \$2.5k Anthropic + \$150k Azure + \$1k-100k AWS
+ \$200k Google for Startups Cloud. Even **one** approval unlocks
6-12 months of full paid-tier runway.

Apply in this order — the first three accept "early traction" without
revenue; Google for Startups requires a paying customer or a strong
demo signal so save it for last.

---

## 1) Anthropic Startup Program

**URL**: https://www.anthropic.com/startups
**Credit**: ~\$2,500 in Anthropic API credits
**Decision time**: 14-30 days
**Eligibility**: pre-seed / seed startups, AI-focused product, < 5 employees, < \$10M raised

### What to paste in the application form

**Company**: psyclinicai
**One-line description**: EU-based clinical AI for mental-health practices — ambient SOAP scribe, measurement-based care, no-show recovery, evidence-based treatment plan drafter.

**Product stage**: Live demo (Sprint 30 launch). 4 sellable AI features in production; bootstrap launch on free LLM tiers (Groq + Gemini) until first 10 paying customers fund a switch to a BAA-bearing chain.

**Why Anthropic specifically**: Claude Haiku 4.5 + Sonnet 4.6 are the only frontier models with a published HIPAA BAA path that match our clinician-in-the-loop safety posture (cited spans, DSM-5-TR alignment, FDA CDS non-device framing). The fallback chain in `functions/src/lib/llm_provider.ts` puts AnthropicProvider after Groq/Gemini so PHI tier flips on the moment we have BAA-bearing inference.

**Monthly burn projection** (post-launch):
- 10 paying clinicians × ~5k tokens/day each × 22 working days ≈ 1.1M tokens/month
- Mix of Haiku (Scribe) + Sonnet (Drafter complex cases) → ~\$300/month
- \$2.5k credit = 8 months of runway

**Founder LinkedIn**: (paste your LinkedIn)
**GitHub**: https://github.com/caglarilhan/psyclinicai (public; 4 PILAR PRs live)
**Demo URL**: (paste once deployed)

---

## 2) Microsoft for Startups (Azure for Startups)

**URL**: https://www.microsoft.com/en-us/startups
**Credit**: \$150,000 Azure (includes Azure OpenAI Service WITH BAA standard)
**Decision time**: 1-2 weeks
**Eligibility**: pre-seed / seed / Series A; B2B; < 7 years old

### What to paste

**Company**: psyclinicai
**One-line description**: Same as above (EU-based clinical AI for mental-health practices).

**Stage**: Early commercial — demo mode launched, first 10 paying customer target Week 12.

**Why Azure specifically**: Azure OpenAI signs a HIPAA BAA on the standard subscription. Our LLM provider chain already has `AzureOpenAIProvider` plumbed in `functions/src/lib/llm_provider.ts:164` — only env vars are needed (`AZURE_OPENAI_ENDPOINT` / `AZURE_OPENAI_API_KEY` / `AZURE_OPENAI_DEPLOYMENT`). Day-one credit lights up the BAA tier without code changes.

**Workload**: GPT-4o-mini for Scribe transcript → SOAP + GPT-4o for Drafter SMART-goal generation. Estimated \$150-400/month at 25 paying clinicians; \$150k credit covers ~3 years.

**Existing Microsoft footprint**: Visual Studio Code, GitHub (Microsoft-owned). Open to BizSpark-style co-marketing.

---

## 3) AWS Activate

**URL**: https://aws.amazon.com/activate/
**Credit**: \$1k (self-serve) → \$25k–100k (accelerator/VC referral track)
**Decision time**: 1-2 weeks (self-serve), 4 weeks (accelerator)
**Eligibility**: pre-seed / seed; accelerator partnership preferred for higher tier

### What to paste (self-serve track)

**Company**: psyclinicai
**Product**: Clinical AI for mental-health practices.
**Infrastructure today**: Hetzner CX22 (€4/mo) + Firebase Spark. Plan to graduate critical services (CF cold-start sensitivity for Scribe + Drafter) to AWS Lambda + Bedrock once credits land.

**Why AWS specifically**: AWS Bedrock hosts Anthropic Claude with **BAA included** at no extra cost. Bedrock could replace AnthropicProvider via a thin adapter once we have the credit pool. Also: AWS Activate Pioneer tier (\$1k) is no-commitment + fastest decision.

**Higher tier plan**: when (not if) we apply to Y Combinator / Antler / Techstars in Spring 2027, we'll qualify for the \$100k tier via the accelerator partnership.

---

## 4) Google for Startups Cloud Program

**URL**: https://cloud.google.com/startup
**Credit**: \$2k (self-serve) → \$200k (with verified accelerator/VC partner)
**Decision time**: 30 days
**Eligibility**: must have a paying customer OR be in a verified accelerator program

### What to paste (apply once first paying customer signed)

**Company**: psyclinicai
**Product**: Same.
**Why Google specifically**: Gemini 1.5/2.5 is already in our free-tier fallback (`GeminiProvider`). The \$2k self-serve tier funds Gemini 1.5 Pro / Gemini 2.5 Pro for the Scribe / Drafter use cases at a fraction of Anthropic cost (~\$50-100/mo at 25 clinicians). \$200k tier (via accelerator) covers Vertex AI + GCS + Cloud Run for the next 3+ years.

**Existing customer**: (name your first paying customer + email; ask for permission first).

---

## Operational notes

1. **Apply in parallel**, not sequentially. None of these block each other.
2. **Same demo URL / pitch deck across all four** — write once, reuse.
3. **GitHub repo public** for all four — the 4 PILAR PRs + this credits-kit doc themselves act as the "early traction" signal.
4. **Founder identity stays plural** per CLAUDE.md brand voice — "our team", "the platform" — but the application form requires a single founder name; use that field only.
5. **Update `BOOTSTRAP-ROADMAP.md` Week 5 checklist** the moment you apply (timestamp each submission).
6. **Track decisions in `docs/launch/CREDITS-LEDGER.md`** (create when first decision lands).

## Backup plans if all four reject

- **Cloudflare Workers AI** — Llama 3.1 + Mistral on Cloudflare's free tier (10k requests/day).
- **Together AI** — open-weight models with \$25 free credit on signup.
- **Lepton AI** — free credits + low-cost open models.
- **Self-host Ollama on the Hetzner CX22** — Llama 3.1 8B runs okay for low traffic.

None of these have BAA. But until the first paying PHI customer lands, BAA isn't on the critical path — Groq + Gemini cover demo mode.
