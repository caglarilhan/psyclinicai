# GTM + Pricing + B2B Wedge Playbook (18-Month Horizon)

Companion to: `01-market-entry-decision.md`, `02-revenue-rails-plan.md`, `03-denial-shield-validation.md`, `04-pilot-gtm.md`.

This playbook upgrades the current $99/$299/$599 founding-member ladder into a defensible 3-tier architecture, defines 3 ranked ICPs, prioritizes 5 channels, designs 3 B2B beachheads, prepares competitive defenses, ships 3 free top-of-funnel tools, and forecasts revenue under two scenarios.

Core wedges (not commodity scribes): **Denial-Shield** (save-time billing auditor), **Multi-Modality Clinical Lens** (CBT / DBT / EMDR / IFS / ACT / OCD-ERP / Schema / Psychodynamic), **De-Identified Supervision Report**, **EU residency + BYOK + SQLCipher**.

---

## 1. Pricing Architecture (3 Tiers + 1 B2B Module)

Goal: out-position Blueprint's "free EHR + $0.99/session AI" loss-leader, beat Upheal's $1/session cap @ $69/mo, capture psychiatry premium that SimplePractice/Mentalyc cannot, and own a B2B/Supervision module that has no real US/EU competitor.

| Tier | EU € / mo | US $ / mo | Annual (-17 %) | Inference COGS | Gross Margin | Anchor Against |
|---|---|---|---|---|---|---|
| **Solo Clinician** | €49 | $59 | $588 / yr | ~$6 / mo (~200 sessions × $0.03) | ~90 % | Upheal $69 capped, Mentalyc $39–$79 |
| **Practice (1–10 clinicians)** | €129 / seat | $149 / seat | $1,490 / seat / yr | ~$9 / seat / mo | ~88 % | Blueprint EHR+AI bundle, SimplePractice Care Aide |
| **Enterprise / Group (10 +)** | €249 / seat (custom) | $279 / seat (custom) | Negotiated, multi-year | ~$12 / seat / mo | ~85 % | Lyssn (audit), Eleos (group), custom RFP |
| **Supervision Module (B2B add-on)** | €349 / supervisor / mo | $399 / supervisor / mo | $3,990 / yr | ~$15 / mo | ~92 % | No direct competitor |

### Tier 1 — Solo Clinician — €49 / $59 mo

- **Included:** unlimited AI session notes (SOAP / DAP / BIRP), modality-aware structuring for 8 modalities, **Denial-Shield Lite** (US only: code suggestions + top-10 denial-reason check on 90837 / 90834 / 90791 / 90792), basic outcome tracker (PHQ-9, GAD-7, PCL-5), **BYOK Anthropic option** (drops effective price ~$15 / mo), EU residency with SQLCipher at rest, single-clinician dashboard, mobile + web.
- **Excluded:** multi-clinician dashboards, supervision reports, telehealth video, EHR integrations beyond Calendly/Zoom, custom prompts, SLA.
- **Anchor:** Upheal $69 → we win on price and feature density (modality lens + denial logic). Mentalyc $39 → we beat on US billing intelligence; Mentalyc has none.
- **Margin assumption:** 90 % at managed key (paid by us); 96 % at BYOK.
- **Upgrade trigger to Practice:** clinician adds a 2nd seat, OR group practice owner buys for the team, OR uses **>40 sessions / week** consistently (= mid-sized practice, not solo).

### Tier 2 — Practice (1–10 clinicians) — €129 / $149 per seat / mo

- **Included:** everything in Solo, plus:
  - **Multi-clinician dashboard** (caseload load, denial rate by clinician, modality fidelity scores)
  - **Denial-Shield Full** (pre-submit audit on every claim, denial root-cause attribution, payer-specific rules for BCBS / Aetna / UHC-Optum / Medicaid by state)
  - **Modality Fidelity Reports** (per-session adherence scoring vs CBT / DBT / EMDR / IFS protocol — owner-only, not patient-facing)
  - **Shared template library** + custom prompt packs (intake, discharge summary, treatment plan)
  - 2 EHR integrations (SimplePractice + TherapyNotes via API), Calendly + Zoom + Doxy.me
  - HIPAA BAA (US) + GDPR DPA (EU) auto-generated
  - **De-identified case-share** between clinicians inside the practice (no PHI leaves the org)
- **Excluded:** external supervision (separate module), white-label, SSO/SAML, dedicated VPC, custom modality training.
- **Anchor:** Blueprint EHR ($59 EHR + $0.99/session AI = ~$120 at 60 sessions/mo) → we win on AI depth + denial defense + modality fidelity, accept losing the EHR storage. SimplePractice Care Aide ($39 add-on) → we win on every clinical AI dimension, accept they own scheduling/billing.
- **Margin assumption:** 88 % at managed key.
- **Upgrade trigger to Enterprise:** 10+ seats, OR procurement asks for SSO/SAML, OR a clinical director asks for outcome reporting across the org, OR they need BAA + custom DPA + insurance certificates.

### Tier 3 — Enterprise / Group (10 + clinicians) — €249 / $279 per seat / mo (negotiated)

- **Included:** everything in Practice, plus:
  - SSO/SAML (Okta, Azure AD, Google Workspace), SCIM provisioning, audit logs (immutable, exportable for SOC 2 / ISO 27001 evidence)
  - **Org-wide outcome analytics** (PHQ-9 trajectories, dropout prediction, denial $$ recovered per quarter)
  - Dedicated EU or US data residency, BYO-AWS option, customer-managed encryption keys (CMEK)
  - Custom prompt engineering + custom modality packs (e.g. EMDR Phase 3 protocol scoring for an EMDR-only group)
  - **Quarterly clinical-governance review** (we produce a board-ready report)
  - 99.9 % SLA, named CSM, priority Slack/email, 4-hour P1 response
  - White-label option for training institutes (own logo on supervision reports)
- **Anchor:** Lyssn ($custom, enterprise-only, audit-focused) → we cover their audit use case plus production scribe + denial. Eleos ($custom, group-only) → we beat on modality breadth and on solo-to-group pricing continuity. SimplePractice Enterprise + Care Aide bundle → we beat on clinical AI depth.
- **Margin assumption:** 85 % (more support cost, more custom prompts).
- **Upgrade trigger to Supervision Module:** clinical director / training-institute director wants formal supervision artifacts (not just internal review).

### B2B Add-On — Supervision Module — €349 / $399 per supervisor / mo

- **Included:** **De-Identified Supervision Report** (auto-generated weekly: anonymized case summaries, modality fidelity scores, risk flags, supervisor talking-point agenda), supervisee dashboard, signature workflow (supervisor + supervisee), exportable PDF for licensing boards (US state boards + EU equivalents), training-hour tracking, **CE marking case-study export** (EU institutes use this for accreditation evidence).
- **Excluded:** clinical record-of-truth (we are *not* the EHR for supervisees).
- **Anchor:** No real direct competitor. Closest is manual + Google Docs + Zoom recordings. Mentalyc has nothing here. SimplePractice has nothing here. **This is the moat.**
- **Margin assumption:** 92 % (mostly inference + lightweight workflow).
- **Sold to:** training-institute directors, supervision-program leads, group-practice clinical directors. **Sales-assisted only**, never self-serve at this price.

### Why this defeats the competitive traps

1. **Blueprint at $0.99 / session** = price war on commodity. We don't compete on the commodity scribe; we charge a flat seat fee and bundle **denial defense + modality fidelity + supervision** that they don't have. A clinician doing 80 sessions/mo on Blueprint pays $79 + EHR cost; on us they pay $59 and get denial recovery worth one prevented 90837 claim (~$175). Math wins.
2. **Upheal at $69 capped** = generic scribe with no US billing intel and shallow modality coverage. We undercut by $10 on Solo and out-feature on every dimension a real clinician cares about.
3. **Mentalyc / SimplePractice are generic** = they cover scribe + scheduling, not psychiatry-specific medication review, controlled-substance documentation, or denial defense. Practice tier at $149 captures psychiatry NPs/MDs who currently overpay SimplePractice + still get denied.
4. **Supervision module is uncontested** = no competitor sells a de-identified supervision artifact. This is the **B2B beachhead** that protects against a price war on the solo tier.

---

## 2. ICP — 3 Segments Ranked

### ICP #1 (highest priority): US Solo & Small-Practice Insurance-Billing Therapists (1–5 clinicians)

- **Demographic:** LCSW, LMFT, LPC, PsyD, PhD; US-licensed; sees 25–60 sessions / week; bills BCBS / Aetna / UHC-Optum / Medicaid for 60 %+ of caseload; practice owner or independent contractor in a 1–5 person group.
- **Trigger event:** got a batch of 90837 denials in the last 30 days, OR a 25 %+ down-coding from 90837 to 90834, OR a Medicaid audit letter, OR is choosing between hiring a biller (~$1.5k/mo) and a software solution.
- **Buying motion:** **self-serve** at Solo ($59), **sales-assisted** at Practice ($149+ × seats). 15-min Loom + 1-call close. No RFP.
- **LTV / CAC math:**
  - ARPU Solo $59 / mo × 24 months avg life (industry: 22–26 mo for clinical SaaS) = **LTV $1,416**
  - Expected expansion: 35 % upgrade to Practice within 12 mo → blended LTV ~**$1,900**
  - Target CAC ≤ $250 (7.6:1 blended). Achievable via SEO + community + LinkedIn.
- **Where they hang out:** r/therapists, r/psychotherapy, Private Practice Pro FB group, Modern Therapist's Survival Guide podcast, state psychological association newsletters, Mental Health Tech Slack, AAMFT/NASW listservs.
- **Why current competitors fail them:** Blueprint sells the EHR — they want the AI without re-platforming their EHR. SimplePractice has no real billing audit. Upheal has no US billing knowledge. Mentalyc has no denial intelligence. **Nobody combines scribe + denial defense + modality.**

### ICP #2: US/EU Psychiatry NPs and MDs (solo or in 2–10 person practices)

- **Demographic:** PMHNP, MD/DO psychiatrist; prescribes controlled substances; 15-min med-management + 45-min therapy hybrids; mixed insurance + cash-pay; needs strict documentation for DEA / EMA controlled-substance trail.
- **Trigger event:** DEA audit notice; failed insurance pre-auth on a complex med regimen; new PMHNP starting solo and overwhelmed by documentation; switched from a hospital system to private practice and lost the dictation service.
- **Buying motion:** sales-assisted (1-call after a free trial), often through a referral from another psychiatrist.
- **LTV / CAC math:**
  - ARPU Practice $149 / mo × 28 months (psychiatrists are stickier — switching cost on prescribing workflow) = **LTV $4,172**
  - Expansion 25 % → Enterprise → blended LTV ~**$5,200**
  - Target CAC ≤ $700 (7:1).
- **Where they hang out:** APA Annual Meeting, APNA, AAAP, PsychCongress, Reddit r/psychiatry, "Psychiatry Today" mailing lists, KevinMD, MGMA for practice ops.
- **Why current competitors fail them:** Generic scribes cannot handle med-management E/M coding (99214 / 99215 + add-on therapy). Mentalyc is therapy-first and ignores prescribing logic. SimplePractice has therapy-grade templates only. **Psychiatry is a $4k+ LTV segment that no AI player has won.**

### ICP #3: EU Training Institutes & Supervision Programs (EMDR-Europe consortium, ESMHO, IFS-Europe, BABCP CBT centers)

- **Demographic:** training-institute director, supervision-program lead; 10–80 trainees per cohort; multi-year curriculum; needs documentation evidence for accreditation bodies (EMDR-E, EABP, EAP) and EU CE marking where applicable.
- **Trigger event:** annual accreditation review approaching; trainee complaint about supervision quality; new EU AI Act compliance pressure (high-risk AI in clinical training); cohort growth without proportional admin staff.
- **Buying motion:** **sales-assisted, sometimes RFP-light**. 3-call process: discovery → pilot proposal (3 supervisors, 60 days) → contract. Cycle 60–120 days.
- **LTV / CAC math:**
  - ARPU: 8 supervisors × €349 = €2,792 / mo per institute = €33,504 / yr; 36-month avg contract = **LTV €100,000+**
  - Add Practice seats for trainees (avg 24 seats × €129) = +€37,000 / yr → blended **LTV €200k+**
  - Target CAC ≤ €15k (13:1). Conference sponsorship + 2 reference institutes get you there.
- **Where they hang out:** EMDR-Europe annual conference, EABCT (CBT Europe), IFS Institute Europe events, EFPA (European psych associations), national psychotherapy chamber meetings (DE Psychotherapeutenkammer, FR FF2P).
- **Why current competitors fail them:** Nobody else builds a **supervision-specific artifact**. SimplePractice / Blueprint are US-EHR-first. Upheal/Mentalyc have no supervision angle. EU data-residency requirement excludes most US-built tools by default. **This is the uncontested moat.**

---

## 3. Channel Playbook — Top 5

### Channel 1 — Programmatic SEO + AI-Search (ChatGPT / Perplexity / Claude citations) — ICP #1

- **Tactic:** ship a content cluster of 200 long-tail pages: `"{payer} denial reasons for {CPT code} {state}"` (BCBS / Aetna / UHC / Medicaid × 90837 / 90834 / 90791 / 90792 / 99214 × 15 high-population states). Each page = denial-rate stats, top-5 reasons, fix template, in-page "Run this through Denial Shield free" CTA. Optimize for AI-search by including a structured Q&A schema and a "TL;DR for AI assistants" block at the top of each page.
- **90-day pilot test:** ship 30 pages in 30 days, instrument Search Console + Plausible, measure organic clicks + waitlist signups + free-tool runs.
- **Success metric:** 1,500 monthly organic visits by day 90; 150 free-tool runs; 25 trial signups; 8 paid conversions; CAC ≤ $150.
- **Cost:** ~$3k content (programmatic + 1 freelance writer for QA) + $200 hosting.
- **Why this channel for this ICP:** US insurance-billing therapists Google denial codes at the moment of pain. This is the highest-intent traffic in the entire mental-health SaaS market and Blueprint/Upheal/Mentalyc are not ranking for it.

### Channel 2 — Modality-Training-Institute Partnerships (EMDR / IFS / CBT) — ICP #3 (also seeds ICP #1)

- **Tactic:** partner with 3 institutes (1 EMDR, 1 IFS, 1 CBT/BABCP) — offer free Supervision Module for the institute's faculty in exchange for a co-branded white paper + listing in their trainee toolkit. Quote: *"Used by [Institute X] to document trainee modality fidelity."* Then trainees graduate into our Solo/Practice funnel.
- **90-day pilot test:** sign 3 institutes by day 60; ship co-branded white paper by day 90.
- **Success metric:** 3 signed institutes; 1 published white paper; 40 trainee-funnel signups (free trial of Solo); €15k pipeline.
- **Cost:** founder time ~40 hours + ~$2k design / production of white paper + travel ~$2k.
- **Why this channel for this ICP:** Training institutes are kingmakers — their graduates trust the tools they trained on. This is the cheapest way to seed both ICP #3 (institutes themselves) and ICP #1 (their alumni).

### Channel 3 — Supervision-Led Growth (Founder-Led + Reddit / LinkedIn) — ICP #1 + ICP #3

- **Tactic:** post weekly de-identified case mini-tutorials on r/therapists, LinkedIn, and a YouTube channel ("Case Conceptualization in 5 Minutes — CBT vs IFS framing of the same case"). Each post ends with: *"Want the full supervision report? Run your case through psyclinicai (link)."* Founder voice is the company voice ("our team", "we built this") per brand guide.
- **90-day pilot test:** 12 posts over 12 weeks, 1 YouTube video per week, instrument all UTMs.
- **Success metric:** 5,000 cumulative impressions; 200 profile clicks; 40 trial signups; 12 paid conversions.
- **Cost:** founder time ~6 hrs/week, $0 paid, ~$300 video gear.
- **Why this channel for this ICP:** Therapists trust other therapists. Founder-as-clinical-thinker (not founder-as-founder) is the only org form that earns this audience's attention.

### Channel 4 — Conference Sponsorship (APA, EMDRIA, APNA) — ICP #2 + ICP #3

- **Tactic:** sponsor 2 conferences in year 1 (APA Annual in US for ICP #2, EMDR-Europe in Europe for ICP #3). Booth + 1 sponsored workshop ("Documenting Modality Fidelity for Accreditation"). Hand out free Denial-Shield Lite trials + Supervision Module demo.
- **90-day pilot test:** book 1 conference in Q1, prep workshop + demo flow + lead-capture stack (Tally / HubSpot).
- **Success metric:** 200 booth leads; 30 demos booked; 8 paid conversions; 1 enterprise pipeline opp ($50k+).
- **Cost:** ~$15k sponsorship + $3k booth/swag + $5k travel = **$23k per conference**.
- **Why this channel for this ICP:** Psychiatrists and institute directors don't read Reddit. They go to conferences. One enterprise contract pays the conference back 2×.

### Channel 5 — Integration Partnerships (SimplePractice / TherapyNotes / Doxy.me) — ICP #1

- **Tactic:** publish first-class integrations and submit to SimplePractice + TherapyNotes app marketplaces. Co-list as "AI scribe + denial guard for SimplePractice users." Don't compete with their EHR — explicitly position as "the AI layer your EHR doesn't have." Negotiate a revenue-share in year 2 once we have proof.
- **90-day pilot test:** ship SimplePractice OAuth + read/write of session notes by day 60; submit to marketplace by day 90.
- **Success metric:** marketplace listing live; 50 install events; 10 paid conversions; CAC ≤ $100 from marketplace traffic.
- **Cost:** ~80 eng hours + $0 marketplace fee.
- **Why this channel for this ICP:** ICP #1 already uses SimplePractice — distribution into their installed base is cheaper than competing for organic traffic and immediately defuses the "do I have to switch EHR?" objection.

---

## 4. B2B Beachhead Strategy — 3 Distinct Plays

### Play A — Training-Institute Director (EMDR-Europe, IFS-Europe, BABCP)

- **Target buyer:** institute director or director of training.
- **Problem we uniquely solve:** they must document trainee modality fidelity for accreditation but currently use manual rubric scoring across PDFs + Google Docs. We auto-generate fidelity scores per session and a portfolio-level evidence pack for the accreditation body.
- **Deal size:** €25k–€80k / yr (8–25 supervisor seats + 20–80 trainee seats).
- **Sales cycle:** 60–120 days.
- **Pitch (5 slides):**
  1. **The accreditation evidence problem** — manual rubrics, inconsistent supervisors, no auditable trail.
  2. **What our Supervision Module produces** — sample report (de-identified, modality-tagged, supervisor-signed).
  3. **EU residency + GDPR + AI-Act-ready** — data never leaves the EU; full DPIA pack included.
  4. **3-institute pilot results** (filled in after Play A pilots close).
  5. **Pricing + 90-day pilot offer** — 50 % off for first 3 institutes, includes white-paper co-branding.
- **3-pilot proof plan:** sign 1 EMDR institute, 1 IFS center, 1 CBT/BABCP center by month 6. Each runs 60-day pilot, ends with a signed case study + €25k annual contract.

### Play B — Group-Practice Clinical Director (10–50 clinicians, US insurance-billing)

- **Target buyer:** clinical director or COO at a 10–50 clinician group practice.
- **Problem we uniquely solve:** **denial-leak attribution at the clinician level**. They're losing $50k–$300k/yr to denials and have no way to tell which clinician is mis-coding which CPT for which payer. Our Practice tier surfaces this in 1 dashboard, plus pre-submit Denial-Shield catches issues before they're billed.
- **Deal size:** $25k–$100k / yr (15–50 seats at $149 each + Supervision Module for clinical director).
- **Sales cycle:** 30–75 days.
- **Pitch (5 slides):**
  1. **The denial-leak problem** — show industry stats: 7–12 % of behavioral-health claims denied, avg recovery rate 30 %.
  2. **Per-clinician denial dashboard** — live demo.
  3. **Pre-submit audit** — show a 90837 about to be denied; show our fix.
  4. **ROI math** — at 25 clinicians × $200 avg recovered denial × 2 prevented/clinician/mo = $120k / yr recovered for ~$45k / yr platform cost. **2.7× ROI minimum.**
  5. **30-day risk-free pilot** — money back if we don't catch ≥ 10 denials.
- **3-pilot proof plan:** target 3 US group practices in 3 different states (TX, CA, NY) by month 9. Each pilot signs a $35k+ annual contract on success.

### Play C — Supervision-Program Lead (state psychological association, post-grad fellowship)

- **Target buyer:** director of a state association's supervision program or a university post-doc fellowship director.
- **Problem we uniquely solve:** supervisors are unpaid volunteers with no scalable way to track 10–30 supervisees. We produce the supervision artifact for them in 5 minutes and they sign + send.
- **Deal size:** $15k–$40k / yr (5–15 supervisor seats).
- **Sales cycle:** 45–90 days.
- **Pitch (5 slides):**
  1. **The supervisor-burnout problem** — unpaid, untracked, leaving the system.
  2. **Auto-generated supervision packet** — sample.
  3. **Licensing-board export** — direct PDF for state board renewals.
  4. **EU/US compliance + de-identification** — never PHI in the report.
  5. **Pilot offer** — 1 free supervisor seat for 6 months; convert at month 6.
- **3-pilot proof plan:** sign 1 US state association (start with smaller state — VT, OR, NM), 1 university postdoc program, 1 EU national chamber's supervision program by month 12.

---

## 5. Pricing Defenses Against Competition

### Scenario A — SimplePractice drops Care Aide to $19 / mo

- **Don't drop Solo price.** Their $19 is a feature, not a product. Reframe: *"$19 gets you a transcript. We give you denial defense + modality fidelity + supervision. One prevented 90837 denial = 9 months of psyclinicai."*
- **Counter-bundle:** introduce a Solo Annual at €490 / $590 (effective $49/mo, -17 %), positioned as "less than SimplePractice + Care Aide combined and you don't have to switch EHR."
- **Ship integration:** if they integrate, we integrate. Be the AI layer on top of their EHR, not a competitor.

### Scenario B — Upheal launches an EU residency tier

- **Add 3 EU-only proof points** to Practice tier: **EU AI Act risk classification report**, **DPIA template generator**, **CE marking case study for medical-device-adjacent use**. Upheal will not match these in <12 months.
- **Lower EU Solo to €39** temporarily for new signups (60-day campaign), but only in EU, and recover via Practice expansion.
- **Lock training institutes faster** — Play A in section 4 becomes urgent. 5 signed institutes in EU = unmatchable distribution.

### Scenario C — Mentalyc adds modality fidelity

- **Out-publish them on clinical authority.** Ship the **Modality Lens Standards Paper** (a 30-page, peer-reviewed-style document on how we score CBT/DBT/EMDR/IFS/ACT/OCD-ERP/Schema/Psychodynamic adherence). Get 3 institute endorsements (from Play A). Submit to JMIR Mental Health.
- **Ship the Supervision Module deeper** — auto-generated supervisor talking points + risk flags. This is the layer above modality fidelity that Mentalyc cannot easily ship without our supervision DNA.
- **Lean into psychiatry** (ICP #2) — Mentalyc is therapy-first; we extend modality coverage to med-management documentation and DEA-grade controlled-substance documentation.

---

## 6. Free Tool Strategy (Top-of-Funnel Lead Gen)

### Tool 1 — Denial Code Lookup (US, ICP #1)

- **Spec:** searchable database of CARC + RARC denial codes mapped to behavioral-health CPT codes (90837, 90834, 90791, 90792, 99214) and top-5 payers (BCBS, Aetna, UHC, Cigna, Medicaid). Each result shows: reason, fix template, example clean claim language.
- **Lead capture:** free without signup for 3 lookups; signup (email + state + role) for unlimited + a weekly digest of "new denial trends by payer."
- **Conversion path:** weekly digest CTA → "Run your last 10 EOBs through Denial-Shield free for 14 days" → trial → Solo paid.

### Tool 2 — Modality Fidelity Sample Report Generator (US + EU, ICP #1 + #3)

- **Spec:** clinician pastes (or types) a 200-word session vignette → we return a 1-page fidelity report scoring it on the 8 modalities + top-2 suggestions. Branded "Powered by psyclinicai's Multi-Modality Lens."
- **Lead capture:** email-gated download of the PDF report.
- **Conversion path:** report PDF ends with: *"This took us 12 seconds. Want this for every session? Try Solo free for 14 days."* → trial → paid.

### Tool 3 — PHQ-9 / GAD-7 Severity Calculator (EU + US, all ICPs)

- **Spec:** in-browser PHQ-9 and GAD-7 calculator with EU/US clinical interpretation cards, treatment-recommendation snippets, plus auto-generated patient handout PDF. No data ever leaves the browser (local-only — that's the privacy hook).
- **Lead capture:** optional "save my clinic's results dashboard" → signup.
- **Conversion path:** dashboard upsell → Solo trial → paid. Doubles as SEO bait (high search volume on "PHQ-9 calculator").

---

## 7. Brand Positioning vs Competitors (1 paragraph per segment)

**vs Blueprint (ICP #1):** We are the **clinical AI you don't have to re-platform for**. Blueprint asks you to leave your EHR; we plug into the EHR you already use (SimplePractice / TherapyNotes) and add the two things they don't — denial defense and modality fidelity. You keep your charts. We protect your revenue.

**vs Upheal / Mentalyc (ICP #1 + #2):** We are the **modality-aware, billing-aware co-pilot**, not a generic transcript service. Upheal and Mentalyc write a note. We write a note, score it against the modality you actually practice, audit it for denial risk before submission, and (for the practice tier) tell the clinical director exactly where revenue is leaking.

**vs SimplePractice Care Aide (ICP #1):** We are the **specialist** to their generalist. Care Aide is a checkbox feature on a scheduling product. Clinical AI is our product. Every dollar of R&D goes here — every dollar of their R&D goes to scheduling, calendaring, and patient portals. You don't hire a GP to do brain surgery.

**vs Lyssn / Eleos (ICP #3 + Enterprise):** We are the **continuous co-pilot**, not the post-hoc auditor. Lyssn scores sessions after the fact for QA. Eleos optimizes group operations. We do both in real-time — and we make it work for solo clinicians, training institutes, and group practices on the same platform, with EU residency and BYOK baked in.

**vs DIY / Google Docs (ICP #3, supervision):** We are the **supervision artifact** the accreditation board will accept. Manual notes are unreviewable, inconsistent, and a liability. Our de-identified supervision report is auditable, signed, exportable, and built from the ground up for EMDR-Europe, IFS-Europe, BABCP, and US state-board evidence requirements.

---

## 8. 18-Month Revenue Forecast (Conservative + Bullish)

### Assumptions

| Variable | Conservative | Bullish |
|---|---|---|
| Paid signup rate (free trial → paid) | 18 % | 32 % |
| Monthly logo churn | 4.5 % | 2.5 % |
| Net revenue retention (12 mo) | 102 % | 118 % |
| Blended ARPU (Solo $59 + Practice $149 weighted) | $74 | $96 |
| Avg seats / logo | 1.3 | 1.8 |
| Avg revenue / logo / mo | ~$96 | ~$173 |
| Enterprise + Supervision deals (annual contract value) | 1 per Q from M9 @ $35k ACV | 2 per Q from M6 @ $55k ACV |

### Conservative Scenario (Month-by-Month)

| Month | New Logos | Churned | Net Logos | Subscription MRR | Enterprise / Sup. MRR | Total MRR | ARR Run-Rate |
|---|---|---|---|---|---|---|---|
| M1 | 6 | 0 | 6 | $576 | $0 | $576 | $6,912 |
| M2 | 9 | 0 | 15 | $1,440 | $0 | $1,440 | $17,280 |
| M3 | 12 | 1 | 26 | $2,496 | $0 | $2,496 | $29,952 |
| M4 | 16 | 1 | 41 | $3,936 | $0 | $3,936 | $47,232 |
| M5 | 22 | 2 | 61 | $5,856 | $0 | $5,856 | $70,272 |
| M6 | 28 | 3 | 86 | $8,256 | $0 | $8,256 | $99,072 |
| M7 | 32 | 4 | 114 | $10,944 | $0 | $10,944 | $131,328 |
| M8 | 36 | 5 | 145 | $13,920 | $0 | $13,920 | $167,040 |
| M9 | 40 | 7 | 178 | $17,088 | $2,917 | $20,005 | $240,060 |
| M10 | 42 | 8 | 212 | $20,352 | $2,917 | $23,269 | $279,228 |
| M11 | 44 | 10 | 246 | $23,616 | $2,917 | $26,533 | $318,396 |
| M12 | 46 | 11 | 281 | $26,976 | $5,834 | $32,810 | $393,720 |
| M13 | 48 | 13 | 316 | $30,336 | $5,834 | $36,170 | $434,040 |
| M14 | 50 | 14 | 352 | $33,792 | $5,834 | $39,626 | $475,512 |
| M15 | 52 | 16 | 388 | $37,248 | $8,751 | $45,999 | $551,988 |
| M16 | 54 | 17 | 425 | $40,800 | $8,751 | $49,551 | $594,612 |
| M17 | 56 | 19 | 462 | $44,352 | $8,751 | $53,103 | $637,236 |
| M18 | 58 | 21 | 499 | $47,904 | $11,668 | $59,572 | **$714,864** |

**Conservative M18: ~$60k MRR, ~$715k ARR, ~500 paid logos, 4 enterprise deals.**

### Bullish Scenario (Month-by-Month)

| Month | New Logos | Churned | Net Logos | Subscription MRR | Enterprise / Sup. MRR | Total MRR | ARR Run-Rate |
|---|---|---|---|---|---|---|---|
| M1 | 10 | 0 | 10 | $1,730 | $0 | $1,730 | $20,760 |
| M2 | 16 | 0 | 26 | $4,498 | $0 | $4,498 | $53,976 |
| M3 | 24 | 1 | 49 | $8,477 | $0 | $8,477 | $101,724 |
| M4 | 32 | 1 | 80 | $13,840 | $0 | $13,840 | $166,080 |
| M5 | 42 | 2 | 120 | $20,760 | $0 | $20,760 | $249,120 |
| M6 | 52 | 3 | 169 | $29,237 | $9,167 | $38,404 | $460,848 |
| M7 | 62 | 4 | 227 | $39,271 | $9,167 | $48,438 | $581,256 |
| M8 | 72 | 6 | 293 | $50,689 | $9,167 | $59,856 | $718,272 |
| M9 | 80 | 7 | 366 | $63,318 | $18,334 | $81,652 | $979,824 |
| M10 | 86 | 9 | 443 | $76,639 | $18,334 | $94,973 | $1,139,676 |
| M11 | 90 | 11 | 522 | $90,306 | $18,334 | $108,640 | $1,303,680 |
| M12 | 94 | 13 | 603 | $104,319 | $27,501 | $131,820 | **$1,581,840** |
| M13 | 96 | 15 | 684 | $118,332 | $27,501 | $145,833 | $1,749,996 |
| M14 | 98 | 17 | 765 | $132,345 | $27,501 | $159,846 | $1,918,152 |
| M15 | 100 | 19 | 846 | $146,358 | $36,668 | $183,026 | $2,196,312 |
| M16 | 102 | 21 | 927 | $160,371 | $36,668 | $197,039 | $2,364,468 |
| M17 | 104 | 23 | 1,008 | $174,384 | $36,668 | $211,052 | $2,532,624 |
| M18 | 106 | 25 | 1,089 | $188,397 | $45,835 | $234,232 | **$2,810,784** |

**Bullish M18: ~$234k MRR, ~$2.81M ARR, ~1,089 paid logos, 10 enterprise/supervision deals.**

### Reading the forecast

- **Conservative** is what happens if the launch is product-market-fit-good (3 channels working, no enterprise marketing) — already at **~$715k ARR by M18**, enough to support a 4-person team and Seed/Series-A optionality.
- **Bullish** is what happens if Play A (training institutes) hits in M6 + Channel 1 (programmatic SEO) compounds + 1 hero case study (a group practice publishing $200k recovered denials/year) — **~$2.81M ARR by M18**, well past the bar for a Series A on solid revenue ground.
- Both scenarios assume **no paid ad spend**. Adding $5k/mo of paid LinkedIn into ICP #2 (psychiatry) from M9 likely lifts both by ~15 %.

---

## Ne yapsam — Yönetici Özeti (TR)

Kısa cevap: **fiyatı düşürme, dikey derinleş**. Solo'yu **€49/$59**'a çek (Upheal'i 10 dolar altı; Mentalyc'i feature ile yen). Practice'i **€129/$149/koltuk** yap — burada para psikiyatristlerden ve 3–10 kişilik gruplardan gelir. Enterprise'ı **€249/$279/koltuk** olarak özel sat. **Asıl moat: Supervision Module €349/$399** — rakipte yok, EU eğitim enstitüleri için biçilmiş kaftan, **LTV €200k+** veriyor.

İlk 90 günde 3 paralel iş çevir:
1. **Programmatic SEO** (US denial kodları için 200 sayfa) — ICP #1 için en ucuz CAC.
2. **3 EU eğitim enstitüsü pilotu** (EMDR-E, IFS-E, BABCP) — Supervision Module'ün ilk referansları, white-paper çıkar.
3. **SimplePractice marketplace entegrasyonu** — kullanıcının zaten orada olduğu yere git, "AI layer on top" pozisyonu ile.

Conservative senaryoda **M18'de $715k ARR / 500 logo / 4 enterprise**. Bullish'te **$2.81M ARR / 1,089 logo / 10 enterprise**. Para kasası iki yerden: (a) US psikiyatri ICP #2'nin yüksek LTV'si, (b) EU supervision modülünün anti-rekabet konumu.

Rakip savaşına girme: Blueprint'in $0.99 fiyatına Solo'yu indirerek cevap verme — onun yerine "yıllık $590" ve "denial savunması bir reddi yakalarsa 9 ay bedavaya gelir" mesajı ile değer çerçevesini bozma. SimplePractice $19'a Care Aide indirirse entegrasyonu derinleştir ve modality fidelity + denial defense'i öne çıkar.

Sırada: bu playbook'tan **Stripe fiyatlarını yeniden konfigüre et** (`02-revenue-rails-plan.md` ile uyumlu), **3 free tool'u 60 günde shipla**, **EMDR-Europe'a outreach maili at**.
