# PsyClinicAI — Market Research & Feature Roadmap (US + EU)

**Date:** 2026-05-26
**Method:** Live web research across therapist communities/blogs, AI-scribe review/comparison sites, EU practice-software vendors, and billing/admin analyses (r/therapists discussions, SimplePractice/Jane reviews, Upheal/Mentalyc/Blueprint/Twofold/DeepCura comparisons, Heard "Financial State of Private Practice 2026", EU vendors: Konfidens, PracFlow, Therasee, Rhadar, ZEIPSY, Eholo, PraxiPro, Zanda).

> Goal: what US + EU psychologists/psychiatrists *actually pay for*, and the ordered plan to win it. Cited signals, not opinion.

---

## 1. The universal pain (ranked by $ and frequency)

Admin = **~40% of a clinician's time / 10–20 hrs per week** — the #1 burnout driver, US and EU alike. At a $150–200 session rate that's **$1,800–2,700/week of opportunity cost**. Two-thirds of therapists already use AI (mostly for notes).

| Rank | Pain | Cost signal | Our status |
|---|---|---|---|
| 1 | **Documentation** (notes, treatment plans) — 5–8 hrs/wk, the single biggest | AI-scribe market on fire (Upheal ~25k sessions/mo) | ✅ have SOAP/DAP/BIRP (real Claude) |
| 2 | **Billing / insurance / claims** — most *dreaded*; 18–22% first-pass denial, **65% of denials never appealed → $20–40k/yr abandoned**; credentialing 90–120d = ~$48k delayed | "the admin task therapists dread most" | ⚠️ only superbill PDF |
| 3 | **No-shows / scheduling** — no-shows cost **$30–50k/yr**; reminders cut them **29%** | "ROI in the first week" | ✅ just shipped (Appointments + reminders) |
| 4 | **Intake / onboarding** — redundant data entry, eligibility checks | 1.5–2.5 hrs/wk | ❌ not built |
| 5 | **Audit/compliance anxiety** — "will my notes survive an audit?" | drives tool choice | ⚠️ partial (risk flag) |

---

## 2. What they pay (pricing intelligence)

- **AI scribe**: $19–129/mo. Three live models: **per-session** ($0.49–1.49 — Blueprint/Upheal), **flat unlimited** ($49 — Twofold), **note caps** ($20–80 — Mentalyc).
- **Full EHR**: $39–99/mo (SimplePractice, Jane, TherapyNotes). Psychiatry: Berries $79.
- **Winning trend**: bundle **EHR + AI** (Upheal $1/session cap $69; **Blueprint = free EHR + per-session AI**). Standalone scribes are converging toward full EHR.
- **Our $49/€45 founding (→ $99) is competitive.** Add a **per-session / pay-as-you-go** option to match Blueprint/Upheal for light caseloads — BYOK already makes our marginal AI cost ~$0.

---

## 3. Competitor weakness = our wedge

**SimplePractice (250k users) is bleeding trust** — our single biggest opening:
- **63% price hike in 2025** ($29→$49+, many $49→$99), opaque forced T&C, **per-claim charges**.
- **"You're selling my data to AI?"** — the T&C AI clause triggered mass distrust. Therapists actively want an ethical, privacy-first alternative.
- **Telehealth drops mid-session** ("horrible grinding noise", clients kicked) — a *clinical* disruption.
- No group-therapy notes, no UB-04 (IOP/PHP), weak out-of-network billing, bot-only support, no autosave, hard data export.
- Therapists feel **stuck** — "no viable alternative" + switching cost.

**Jane wins by being the anti-SimplePractice**: transparent pricing, no contracts, human support, easy migration, online booking, email open/click tracking, multi-location, supervision + part-time licensing.

### 🎯 Our killer positioning (no competitor has this)
**BYOK + on-device transcription + zero audio retention = "your data is never ours to sell."** This is the *direct* answer to SimplePractice's #1 trust wound. Lead every US message with it. Pair with **transparent flat pricing + no contracts + 1-click export** (Jane's playbook) to convert the disaffected SimplePractice base.

---

## 4. Assets we already have that match proven demand
AI SOAP/DAP/BIRP ✅ · Superbill CPT+ICD-10 ✅ · PHQ-9/GAD-7 measurement-based care ✅ · Real-time risk co-pilot ✅ (unique) · Appointments + reminders ✅ · Multi-jurisdiction/GDPR positioning ✅ · BYOK privacy moat ✅.

We are ~70% of the way to a credible SimplePractice/Upheal competitor. The roadmap closes the *paid* gaps.

---

## 5. ROADMAP — prioritized by (proven willingness to pay × our effort)

### P0 — Close the table-stakes gaps that lose deals (next)
1. **Golden Thread** — treatment plan ↔ session notes ↔ progress, carried forward & audit-ready. *Every* AI competitor (Upheal/Mentalyc/Twofold/Blueprint) sells this; we lack it (treatment-plan code is orphan). **Highest-frequency "why I chose them".**
2. **Compliance/Audit checker** — flag notes that won't survive a payer audit (missing medical necessity, time, risk). Directly targets pain #5. Cheap with Claude; high trust payoff.
3. **Card-on-file + auto-charge + no-show fee + payment reminders** — proven "ROI in week 1"; reduces no-shows 29% and protects revenue. Reuses Stripe.
4. **Speaker diarization in transcription** — "who is client vs clinician" is Upheal's #1 praised edge; bad diarization is the #1 scribe complaint. Improves our existing co-pilot's note accuracy.

### P1 — Differentiators that justify the price
5. **Session analytics / "AI supervisor"** — post-session feedback on rapport, agenda-setting, interventions (Mentalyc's most-loved feature: "like having a clinical supervisor"). We have transcripts already.
6. **Note-format breadth + modality templates** — GIRP + EMDR/IFS/CBT/DBT/OCD-ERP aware. Therapists explicitly ask for modality-specific notes.
7. **Client portal + online self-booking** — Jane's conversion win ("clients book while motivated"); table-stakes for groups.
8. **Insurance eligibility check + auto-claim submission + denial tracking** — attacks pain #2 (the dreaded one) and the $20–40k/yr abandoned-revenue. Needs a clearinghouse integration (Availity/Office Ally) — bigger effort, biggest revenue story. Consider partner vs build.
9. **Group-therapy notes** (one note, individual progress entries) — SimplePractice can't; wins IOP/PHP/DBT-group practices.

### P2 — Expansion / moats
10. **Pay-as-you-go pricing tier** (per-session) to match Blueprint/Upheal for light caseloads — trivial given BYOK.
11. **"Float the reimbursement" / out-of-network-feels-in-network** (Heard/Deputy model) — estimate post-deductible patient responsibility, pay therapist full fee, chase the payer. Advanced, but a category-defining retention/acquisition moat.
12. **Psychiatry track** — e-prescribing (already honest "Q4 2026"), med management, prior-auth assist (Berries/mdhub space).

---

## 6. EU roadmap (country-specific — this is where EU vendors win locally)

EU practice software competes on **GDPR-first + EU/UK data residency + country billing**, not AI. Our AI + BYOK is *ahead* of them; our gap is **local billing/compliance plumbing**.

| Need | Where | Signal / vendor | Action |
|---|---|---|---|
| **GDPR + EU data residency + ISO 27001** front-and-center | All EU | Konfidens, PracFlow, Therasee, Rhadar, Zanda all lead with "Built in EU 🇪🇺" | Make EU hosting + DPA + "Built in Europe" a homepage badge |
| **DE: GOÄ/GOP private invoices + e-Rechnung + KV** | Germany | PraxiPro | Private-pay invoice generator per GOÄ/GOP + e-Rechnung format |
| **AT: Kostenzuschuss (insurance reimbursement) AI form-fill** | Austria | ZEIPSY ("fill the Krankenkasse claim with AI in <5 min") | **AI-assisted reimbursement-application filler** — concrete, lovable EU win, reuses our Claude |
| **ES: quarterly + mandatory e-invoicing** | Spain | Eholo ("quarterly billing in one click") | Quarterly invoice batch + Spanish e-invoicing law |
| **UK: ICO registration, DBS/insurance expiry reminders, GP consent fields** | UK | Rhadar, Therasee | Credential/DBS expiry tracker + GP-consent intake fields |
| **SMS reminders, secure EU video, encrypted messaging** | All EU | Konfidens/Therasee | We have reminders; add EU-hosted video later (telehealth = backend) |
| **Transparent per-user, no-contract pricing** | All EU | universal | Match (we already do founding) |

**EU positioning:** "The AI co-pilot SimplePractice/Jane don't have — built in Europe, GDPR-native, your data never trains anyone's model." AI is our edge over the local EU incumbents; local billing is our gap to close per-country.

---

## 7. Sequenced plan (what to build, in order)

- **Now → 2 wks:** P0.1 Golden Thread, P0.2 Compliance checker (both Claude-cheap, reuse session+notes).
- **2–4 wks:** P0.3 payments/no-show automation (Stripe), P0.4 diarization.
- **Month 2:** P1.5 session analytics, P1.6 note-format breadth, P1.7 client portal+booking.
- **Month 2–3 (EU):** AT Kostenzuschuss AI-filler + DE GOÄ/GOP invoice + "Built in Europe" trust layer (fastest EU love).
- **Month 3+:** P1.8 claims/eligibility (partner or build), group notes, pay-as-you-go tier; then P2 reimbursement-float + psychiatry track.

**One line:** lead with the BYOK/privacy + AI-scribe wedge against a distrusted SimplePractice; close Golden Thread + payments to stop losing deals; win EU with GDPR-native + per-country billing (AT/DE/ES/UK) that the US AI scribes don't touch.
