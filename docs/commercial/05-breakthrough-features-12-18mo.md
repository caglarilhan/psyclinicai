# PsyClinicAI — 30 Breakthrough Features to Leapfrog Competition (12–18 Month Horizon)

> **Scope**: AI-native, defensible, payer-grade. Table-stakes excluded.
> **Competitor frame**: SimplePractice, TherapyNotes, Blueprint, Upheal, Mentalyc, Eleos, Heidi, Psyprax, WriteUpp.
> **North star**: Build a *clinical operating system* that owns the outcome data, the compliance posture, and the supervision graph — not just the note.

---

## A. AI-Clinical Innovation (in-session + agentic)

### A1. **Live Co-Therapist Whisper**
**What it does**: A second, silent agent listens to the live session and surfaces *real-time micro-prompts* on the clinician's secondary screen — "client mentioned suicidal ideation 14s ago, not yet acknowledged", "you've used 6 closed questions in a row, consider Socratic", "modality drift: you opened CBT, now in psychodynamic territory". Not a transcript — a **clinical conscience**.
**Why competitors can't copy**: Requires (a) latency <800ms streaming ASR + LLM, (b) the 8-modality lens already built, (c) clinician trust earned by Denial Shield. Upheal/Mentalyc are *post-session* tools by architecture; flipping to live is a 12+ month rebuild.
**Effort**: L · **Impact**: 5 · **Reg**: EU AI Act Annex III (high-risk decision support) — needs Article 14 human-oversight UI · **TTFV**: 8 wk

### A2. **Agentic Between-Session Loop**
**What it does**: After each session, an agent autonomously: (1) drafts the SOAP, (2) schedules MBC re-administration at the optimal interval per condition, (3) drafts homework personalized to the modality + client cognitive style, (4) flags ruptures from session sentiment delta, (5) pre-books the next session topic agenda. Clinician approves with one tap.
**Why competitors can't copy**: Requires durable agent state per client across sessions — neither Upheal nor Mentalyc retain longitudinal agent memory; their AI resets per recording. SimplePractice has no agent layer at all.
**Effort**: L · **Impact**: 5 · **Reg**: AI Act limited-risk (transparency labels) · **TTFV**: 10 wk

### A3. **Multimodal Risk Engine (voice + face + text)**
**What it does**: Beyond text sentiment — vocal prosody (jitter, shimmer, pause ratio) and optional video micro-expression analysis to detect *prodromal* suicidality, mania switch, dissociation. Outputs a calibrated risk score with confidence interval, not a binary flag.
**Why competitors can't copy**: Voice biomarker training data is the moat. Partner with 2-3 EU university hospitals for labeled corpus → no competitor has this dataset. Mentalyc/Upheal are text-only.
**Effort**: XL · **Impact**: 5 · **Reg**: FDA SaMD Class II / EU MDR Class IIa — must pursue formal pathway (this is a *feature*, not a bug — it becomes the moat) · **TTFV**: 26 wk

### A4. **Modality-Specific Fidelity Scoring**
**What it does**: For each session, score adherence to the chosen modality (CBT, DBT, ACT, IFS, EMDR, psychodynamic, MI, schema therapy) on a 0–100 fidelity rubric. Used for self-improvement, supervision evidence, and *payer demonstration of evidence-based care*.
**Why competitors can't copy**: PsyClinicAI's 8-modality lens is already built — fidelity scoring is the next layer. No competitor has modality-aware NLP; they all do generic SOAP.
**Effort**: M · **Impact**: 4 · **Reg**: AI Act limited-risk · **TTFV**: 6 wk

### A5. **Counter-Transference Mirror (clinician-facing)**
**What it does**: Private dashboard for the *clinician's own* patterns across all clients: language entropy decline, empathy markers, talk-time ratio, modality drift, emotional reactivity to specific client archetypes. Surfaces burnout, attachment patterns, and supervision opportunities.
**Why competitors can't copy**: Requires cross-client clinician-level data model — competitors are client-centric. Also a wedge into the **supervision** market (see D2).
**Effort**: M · **Impact**: 4 · **Reg**: HR-sensitive — opt-in only, clinician-owned data · **TTFV**: 8 wk

---

## B. Outcomes & Value-Based Care

### B1. **Outcome-Linked Pricing Engine**
**What it does**: Offer agencies/payers a contract option: 30% of subscription fee returned if their cohort doesn't hit MEI (Minimal Effective Improvement) on PHQ-9/GAD-7 within 12 weeks. We can afford this because A2+A4 actually move outcomes.
**Why competitors can't copy**: Requires confidence in *our own* outcome data. SimplePractice/TherapyNotes have no outcomes layer. Blueprint has MBC but no agentic intervention loop, so they can't underwrite outcomes.
**Effort**: M (engineering) + L (actuarial) · **Impact**: 5 · **Reg**: not AI Act, but contract/insurance — needs legal · **TTFV**: 16 wk

### B2. **Payer-Ready Outcome Ledger**
**What it does**: A cryptographically signed, immutable ledger of every PROM (Patient-Reported Outcome Measure) administration, intervention, and outcome delta — exportable as a HL7 FHIR R4 bundle to BCBS / AOK / NHS commissioners. Becomes the *de facto* receipt for value-based BH contracts.
**Why competitors can't copy**: Requires (a) FHIR maturity, (b) audit-grade signing infra, (c) the trust to be the system of record. Eleos has agency-level reporting but not patient-portable, payer-grade ledger.
**Effort**: L · **Impact**: 5 · **Reg**: HIPAA + GDPR Art. 20 data portability — actually a compliance *advantage* · **TTFV**: 14 wk

### B3. **Population-Level Benchmark API**
**What it does**: Every practice gets a private benchmark: "Your GAD-7 reduction at 8 weeks is 3.1 points; the de-identified cohort median for similar caseload is 4.4." Drives behavioral change (gamification), and the aggregate becomes a sellable real-world evidence (RWE) dataset to pharma.
**Why competitors can't copy**: Two-sided data network — value scales with participants. First mover in EU BH wins. Mentalyc tried scribe-only; never built outcome aggregation.
**Effort**: M · **Impact**: 5 · **Reg**: GDPR — needs proper anonymization (k-anonymity ≥5) · **TTFV**: 12 wk

### B4. **Stepped-Care Auto-Triage**
**What it does**: When MBC scores plateau, agent auto-suggests stepping up (med referral, group, intensive outpatient) or stepping down (self-guided, biweekly). Includes referral letter generation and warm-handoff scheduling.
**Why competitors can't copy**: Requires (a) outcome trajectory model, (b) referral network (see D1), (c) modality-aware reasoning. Combines three of our moats.
**Effort**: L · **Impact**: 4 · **Reg**: AI Act high-risk (medical triage) — must include Art. 14 oversight · **TTFV**: 18 wk

### B5. **Pre-Authorization Auto-Pack**
**What it does**: For US payers requiring prior auth for >20 sessions, auto-generates a payer-tailored medical necessity packet using session evidence, MBC trajectory, and clinical narrative. Targets a 90% first-pass approval rate vs industry ~55%.
**Why competitors can't copy**: This is **Denial Shield extended upstream**. Eleos does denial appeals but not pre-auth. SimplePractice has no clinical reasoning layer.
**Effort**: M · **Impact**: 5 · **Reg**: limited-risk · **TTFV**: 8 wk

---

## C. Therapist Productivity 10x (Kill the EHR)

### C1. **Zero-Click Note (the "Tesla autopilot" of documentation)**
**What it does**: Session ends → 90 seconds later, fully coded note (DSM-5, ICD-10/11, CPT, modifiers) is in the chart, claim is scrubbed, superbill is queued, next appointment is suggested, homework is sent to client portal. Clinician's only action: thumbs-up.
**Why competitors can't copy**: Requires the **entire stack** (scribe + coder + claim engine + portal + scheduler) to be ours and agentic. SimplePractice has the modules but not the agent glue; Heidi has the scribe but no EHR.
**Effort**: L · **Impact**: 5 · **Reg**: limited-risk · **TTFV**: 12 wk

### C2. **Voice-First Chart Navigation**
**What it does**: "Show me everything about Mr. K's medication non-adherence over the last 6 months" → agent retrieves, summarizes, cites timestamps. Works in 24 languages, including clinical Turkish/German/French. No clicks, no menus.
**Why competitors can't copy**: Requires RAG over the longitudinal chart with clinical entity linking. Legacy EHRs are SQL forms; impossible without a ground-up rewrite.
**Effort**: M · **Impact**: 4 · **Reg**: limited-risk · **TTFV**: 6 wk

### C3. **Inbox Zero Agent**
**What it does**: Triages incoming portal messages, faxes (OCR), insurance EOBs, lab results. Auto-drafts replies, flags urgents (SI, med side effects), files routine items. Clinician inbox shrinks 80%.
**Why competitors can't copy**: Multi-channel ingestion + clinical judgment in one agent. SimplePractice messaging is a dumb inbox. Most competitors don't even ingest fax/EOB.
**Effort**: M · **Impact**: 4 · **Reg**: limited-risk · **TTFV**: 8 wk

### C4. **Smart Template Evolution**
**What it does**: Templates learn from each clinician's edits. After 20 sessions, the template *is* you. Crosses no PHI boundary because learning happens per-clinician on-device or in their tenant.
**Why competitors can't copy**: Requires per-tenant fine-tuning infra (we have BYOK + isolated inference). Competitors use shared models; can't personalize without leaking.
**Effort**: M · **Impact**: 3 · **Reg**: limited-risk · **TTFV**: 6 wk

### C5. **CPT/ICD Defensive Coder**
**What it does**: Suggests *the most defensible code, not the most lucrative*. Shows audit risk score per code and the evidence chain from the note. Clinicians stop fearing audits → adoption flywheel.
**Why competitors can't copy**: Requires (a) audit case-law corpus, (b) per-payer denial pattern data (Denial Shield byproduct). Generic coders maximize $; ours minimizes risk-adjusted-revenue variance.
**Effort**: M · **Impact**: 4 · **Reg**: limited-risk · **TTFV**: 8 wk

---

## D. Network / Community / Marketplace

### D1. **Verified Referral Graph**
**What it does**: A two-sided clinician marketplace where every referral is outcome-tracked. "Therapist A refers EMDR-needing trauma clients to Therapist B; B's outcomes for those cases are 0.4 SD better than baseline." Becomes the trusted referral network in EU BH.
**Why competitors can't copy**: Network effect — first 1000 nodes win. Outcome data is the unfair advantage; competitors without B1/B2 can't rank referrals on outcomes.
**Effort**: L · **Impact**: 5 · **Reg**: GDPR + national medical advertising laws · **TTFV**: 20 wk

### D2. **Supervision OS** (extends current supervision module)
**What it does**: Supervisors get a dashboard across all supervisees: modality fidelity, risk events, growth trajectories, parallel-process detection. Auto-generates supervision contracts, hour-logs for licensure boards (BPtK, HCPC, APA, BfArM). Pre-packed evidence for board audits.
**Why competitors can't copy**: We already ship a supervision module; no competitor has this. Becomes the **certification system of record** for trainees → 10-year stickiness from day one of residency.
**Effort**: M · **Impact**: 5 · **Reg**: per-country licensure body certification — *moat once obtained* · **TTFV**: 10 wk

### D3. **Group Practice Operating System**
**What it does**: For practices with 5–50 clinicians: revenue per clinician, outcome per clinician, audit risk per clinician, supervision coverage matrix, clinician burnout index (from A5). Practice owner sees what no other tool surfaces.
**Why competitors can't copy**: SimplePractice has dashboards; nobody has *outcome + risk + fidelity + burnout* in one. Becomes contract-renewal driver for practice owners.
**Effort**: M · **Impact**: 4 · **Reg**: HR-sensitive · **TTFV**: 10 wk

### D4. **Anonymous Peer Consultation Hub**
**What it does**: De-identified case posts to a verified-clinician-only forum, with AI-suggested similar cases from your own caseload. Triple-blind: client, poster, viewer.
**Why competitors can't copy**: Requires verified clinician identity layer + clinical de-id NLP. Reddit/Twitter can't be HIPAA-clean; competitors don't have the de-id pipeline.
**Effort**: M · **Impact**: 3 · **Reg**: HIPAA Safe Harbor de-id + GDPR Recital 26 · **TTFV**: 12 wk

### D5. **Modality Master-Class Marketplace**
**What it does**: Verified expert clinicians (EMDR Master, IFS Lead, DBT Linehan-trained) sell async case-consultation hours. We take 15%. CME/CE credits issued through accredited bodies.
**Why competitors can't copy**: Two-sided, supply-side trust is the bottleneck. Our supervision-OS users *are* the supply side.
**Effort**: M · **Impact**: 3 · **Reg**: CE/CME accreditation per region · **TTFV**: 16 wk

---

## E. Compliance & Trust Moats

### E1. **EU AI Act Class III Certification (preempt 2027 enforcement)**
**What it does**: Voluntarily pursue Annex III high-risk classification with full conformity assessment, registered in the EU AI database. Be one of the first 5 BH AI systems with the badge.
**Why competitors can't copy**: 18-month process; SimplePractice/Blueprint/Mentalyc are US-first and will be late. Becomes EU-tender prerequisite by 2027.
**Effort**: XL · **Impact**: 5 · **Reg**: *this is the regulatory feature* · **TTFV**: 52 wk (start now)

### E2. **MDR Class IIa Medical Device for Risk Engine**
**What it does**: Notify body certification (TÜV/BSI) for the suicide-risk prediction component (A3). Carries CE-MDR mark. Reimbursable as DiGA in Germany (€200+/patient/quarter).
**Why competitors can't copy**: 12–18 month cert; capital intensive. Once certified, statutory health insurance reimburses *us* — a revenue line competitors can't access.
**Effort**: XL · **Impact**: 5 · **Reg**: MDR Annex IX + ISO 14971 + IEC 62304 · **TTFV**: 60 wk

### E3. **Post-Market Surveillance & Algorithmic Audit Log**
**What it does**: Every AI decision logged with model version, input fingerprint, confidence, and override outcome. Annual algorithmic impact report published. Required by AI Act Art. 72 — we ship the dashboard *now* and turn it into a sales asset.
**Why competitors can't copy**: Architectural — must be designed in from start. Retrofitting onto SimplePractice's monolith is years away.
**Effort**: M · **Impact**: 4 · **Reg**: AI Act Art. 72 compliance · **TTFV**: 10 wk

### E4. **Sovereign Inference Tiers**
**What it does**: Three deployment modes: (1) EU-multi-tenant (Frankfurt), (2) Single-tenant in customer's region (FR, DE, IT, ES, UK, US), (3) On-prem for ministries of health. Same UI, same features, regulator-friendly data residency.
**Why competitors can't copy**: US SaaS competitors physically can't serve French Ordre des Médecins or German KBV without this — and engineering it is a 12-month rebuild for them.
**Effort**: L · **Impact**: 5 · **Reg**: GDPR Schrems II + national health-data laws · **TTFV**: 20 wk

### E5. **Explainability Receipts**
**What it does**: Every AI suggestion includes a "why" receipt — the evidence span from the chart, the modality rule fired, the model confidence, and a counterfactual ("if X were absent, suggestion would be Y"). Click-to-expand, exportable.
**Why competitors can't copy**: Requires structured reasoning pipeline, not just RAG. Most AI scribes are black-box — they will *fail* AI Act Art. 13 transparency.
**Effort**: M · **Impact**: 4 · **Reg**: AI Act Art. 13 + 14 · **TTFV**: 8 wk

---

## F. Patient-Side

### F1. **Between-Session AI Coach (clinician-supervised)**
**What it does**: Patients get a chat companion *trained on their own treatment plan and modality*. Skill practice between sessions (CBT thought records, DBT diary cards, IFS parts mapping). Clinician sees the log, escalates on risk markers. NOT a replacement therapist — an extension.
**Why competitors can't copy**: Requires clinician-in-the-loop guardrails + modality awareness. Generic mental-health chatbots (Wysa, Woebot) are unsupervised and have no clinical handoff. Competitors lack the chart context.
**Effort**: L · **Impact**: 5 · **Reg**: AI Act limited-risk (with clinician-in-loop) — sidesteps high-risk classification · **TTFV**: 14 wk

### F2. **Family/Caregiver Portal with Consent Granularity**
**What it does**: For minors and elderly clients, family members get scoped access: medication adherence, appointment attendance — *not* session content. AI summarizes the week for the caregiver without breaching client confidentiality.
**Why competitors can't copy**: Requires fine-grained ABAC (attribute-based access control) and clinical de-id at field level. Built once, locks in family-practice and child/adolescent markets.
**Effort**: M · **Impact**: 4 · **Reg**: minor consent laws per jurisdiction · **TTFV**: 10 wk

### F3. **Patient-Owned Health Record (Verifiable Credentials)**
**What it does**: Patient downloads a cryptographically signed, payer-verifiable summary of their care — outcomes, sessions completed, evidence of evidence-based care. Use case: switching insurers, applying for disability, second opinion. Built on W3C Verifiable Credentials + EU Digital Identity Wallet.
**Why competitors can't copy**: Forward-compatible with EUDI Wallet (mandated 2026). First mover wins patient loyalty + becomes the issuer of record.
**Effort**: L · **Impact**: 4 · **Reg**: GDPR Art. 20 + eIDAS 2.0 · **TTFV**: 18 wk

### F4. **Async Crisis Bridge**
**What it does**: Between sessions, if a patient texts the AI coach with crisis content, structured handoff: (1) safety plan retrieval, (2) clinician on-call routing, (3) regional crisis-line warm-transfer with consent. Clinician gets a packaged briefing before the call.
**Why competitors can't copy**: Requires integration with regional crisis infra (988 US, 116 117 EU, NHS 111) + clinician on-call rota. Mental health startups won't touch crisis liability; we lean in with proper protocols.
**Effort**: L · **Impact**: 5 · **Reg**: high-risk + state-by-state crisis intervention laws · **TTFV**: 20 wk

### F5. **Outcome-Aware Booking Funnel**
**What it does**: Patients searching for a therapist see *outcome-matched* recommendations: "Therapists treating your symptom cluster see 4.2-point GAD-7 reduction in 8 weeks." Powered by the Outcome Ledger (B2) + Referral Graph (D1).
**Why competitors can't copy**: Requires both data products to exist. Becomes the EU "Zocdoc for BH" with outcomes as the differentiator.
**Effort**: M · **Impact**: 4 · **Reg**: medical advertising compliance per country · **TTFV**: 12 wk

---

## G. Specialty Depth

### G1. **Psychiatry Co-Pilot (med-aware)**
**What it does**: For prescribers — integrated CYP450 interaction check, pharmacogenomic test interpretation (CPIC guidelines), serotonin syndrome risk, controlled-substance state-by-state e-Rx with PDMP check (US) / BtMVV (DE). Suggests titration based on response curve from MBC.
**Why competitors can't copy**: Pharmacology depth + clinical reasoning. SimplePractice has e-Rx; nobody has pharmacogenomic + response-curve titration. Unlocks the **psychiatrist** persona ($300/mo tier).
**Effort**: L · **Impact**: 5 · **Reg**: e-Rx licensure + controlled substance integration · **TTFV**: 20 wk

### G2. **Child & Adolescent Pack**
**What it does**: Age-banded MBC (PHQ-A, SCARED, CBCL, YSR), parent-child split portal, school-IEP letter generator, mandatory-reporting workflow with state-specific routing, developmental-milestone-aware language in notes.
**Why competitors can't copy**: Requires age-specific clinical models + multi-stakeholder portal (F2). C&A is 25% of BH market and underserved.
**Effort**: M · **Impact**: 4 · **Reg**: minor consent + mandatory reporting · **TTFV**: 12 wk

### G3. **Addiction & MAT Module**
**What it does**: SBIRT screening, ASAM-criteria level-of-care, MAT (buprenorphine) prescribing workflow with DATA-2000 waiver tracking (US) / equivalent EU, contingency-management gamification for clients, group-session multi-speaker transcription.
**Why competitors can't copy**: ASAM logic + multi-speaker group transcription is a hard NLP problem. SUD providers are an underserved $4B segment.
**Effort**: L · **Impact**: 4 · **Reg**: 42 CFR Part 2 (US SUD records) — strictest privacy in healthcare · **TTFV**: 16 wk

### G4. **EMDR / IFS / Somatic Modality Tools**
**What it does**: For EMDR — bilateral stimulation timer, SUDS tracking, target memory protocol auto-documentation. For IFS — parts map visualization, Self-energy tracking. For somatic — body-map annotations. Modality-native, not bolted-on.
**Why competitors can't copy**: Requires modality SMEs on the product team. We have the 8-modality lens already; these are specialized depth layers.
**Effort**: M · **Impact**: 3 · **Reg**: limited-risk · **TTFV**: 10 wk

### G5. **Neuropsych Battery Auto-Scorer**
**What it does**: Tablet-delivered WAIS-IV, RBANS, MoCA, etc. with AI-assisted scoring, normative comparison, narrative report drafting. Reduces neuropsych report turnaround from 8 hours to 90 minutes.
**Why competitors can't copy**: Test publisher partnerships (Pearson, PAR) + scoring algorithms. High barrier; once partnered, exclusive.
**Effort**: L · **Impact**: 4 · **Reg**: test publisher licensing + AI Act limited-risk · **TTFV**: 22 wk

---

# WINNER PORTFOLIO — The 7 That Compound

Out of 30, these 7 form an interlocking system. None work in isolation; together they are a moat.

| # | Feature | Why it's in the 7 |
|---|---|---|
| 1 | **A2. Agentic Between-Session Loop** | The product wedge — turns scribe into a clinical agent |
| 2 | **A4. Modality Fidelity Scoring** | Generates the evidence that B1/B2 monetize |
| 3 | **B2. Payer-Ready Outcome Ledger** | Makes value-based-care contracts possible; locks in payer relationships |
| 4 | **B1. Outcome-Linked Pricing** | Converts B2 into a commercial weapon competitors can't match |
| 5 | **D2. Supervision OS** | Owns the trainee → 10-year LTV + becomes licensure-board system of record |
| 6 | **E1. EU AI Act Class III Cert** | Regulatory moat; locks competitors out of EU public tenders post-2027 |
| 7 | **F1. Between-Session AI Coach** | Patient-side flywheel — generates the longitudinal data that powers B2/B3 |

## Connective Tissue — Why These 7 = A System

**The data flywheel:**
A2 generates structured between-session signal. F1 multiplies that signal 10x by capturing patient self-report and skill practice between sessions. Both feed A4's fidelity scoring. A4's outputs become the evidence layer in B2's Outcome Ledger. Once the ledger has 10,000+ patient-quarters of outcome data, B1 (outcome-linked pricing) becomes financially safe to underwrite — *competitors cannot offer this without our data*.

**The trust moat:**
E1 (AI Act Class III certification) is the regulatory wall. Once we have it and SimplePractice/Mentalyc don't, every EU public-sector tender, every German statutory insurer (GKV), every French ARS contract has us on the shortlist by default. The cert *requires* the post-market surveillance (E3 — table-stakes for the cert anyway), the explainability (E5), and the outcome tracking (B2) — so E1 is the **forcing function** that ensures we build the other moats correctly.

**The network lock-in:**
D2 (Supervision OS) is the trojan horse for the next generation of clinicians. A clinician onboarded as a supervisee at month 1 of their training stays 7–10 years. Their supervisor uses our outcome data (B2) to evaluate them. Their licensure board uses our hour-logs. Switching cost compounds annually. The supervisees graduate into private practice as natural buyers of A2+F1.

**The patient pull:**
F1 turns patients from passive recipients into active product users. When a patient changes therapist, they bring their AI coach + outcome history with them — putting pressure on the new therapist to also be on PsyClinicAI. This is the *only* feature in the portfolio with patient-side network effects, and it's the long-term wedge against entrenched US incumbents.

**Why competitors can't assemble this stack in 18 months:**
- SimplePractice/TherapyNotes: monolithic Rails apps from 2012; cannot retrofit agentic loops or outcome ledgers without a ground-up rewrite. Their installed base of 200k+ clinicians is also their anchor.
- Blueprint: outcome-tracking strong but no scribe agent, no supervision, no compliance posture for EU.
- Upheal/Mentalyc/Heidi: post-session scribes by architecture; no EHR, no claims, no patient portal, no supervision. Each would need 4 product lines they don't have.
- Eleos: enterprise agency play, B2B2C only — can't reach the long tail of private practice; can't pursue EU because of US-only compliance posture.
- Psyprax/WriteUpp: domestic billers without AI architecture; will be commoditized within 24 months.

**The 12-month execution sequence:**
- **M1–M3**: Ship A2 + A4 (compounds existing modality lens, fastest TTFV).
- **M3–M6**: Ship B2 + E5 (outcome ledger + explainability — both required for E1 anyway).
- **M4–M9**: Kick off E1 (52-week regulatory clock starts now).
- **M6–M10**: Ship D2 expansion (supervision OS becomes the trainee channel).
- **M8–M12**: Ship F1 (patient coach — once A2 produces the structured plans it needs).
- **M10–M14**: Pilot B1 (outcome-linked pricing) with 3 anchor agency customers using 6 months of B2 data.

By month 14, the loop is closed: agentic loop → fidelity evidence → outcome ledger → payer contracts → cert badge → supervisor pipeline → patient coach → more data into the loop.

---

# EXECUTIVE VERDICT (TR)

Rakipler üç farklı kutuya sıkışmış: **SimplePractice/TherapyNotes** eski mimari, **Upheal/Mentalyc/Heidi** sadece scribe, **Eleos** sadece kurumsal. Hiçbiri *klinik işletim sistemi* değil — biz olmalıyız.

**Tek doğru hamle**: scribe yarışına girmemek. Scribe artık emtia (commodity). Asıl moat üç katmanda:

1. **Sonuç verisi** (B2 + B1) — sadece bizde olacak, çünkü A2 + F1 onu üretiyor. Sigorta şirketine "ödediğiniz paranın karşılığını biz garanti ederiz" diyebilen tek oyuncu.
2. **Regülasyon kalkanı** (E1 + E4) — AI Act Class III sertifikası 2027'de zorunlu olmadan biz alacağız. AB'nin kamu ihalelerinden, Almanya DiGA ödemelerinden, Fransa ARS sözleşmelerinden ABD'li rakipler dışlanacak.
3. **Süpervizyon ağı** (D2) — yeni nesil terapistleri stajyerken yakalıyoruz. 7-10 yıl sticky.

**12 ay sonra**: Avrupa'nın klinik BH OS'i biziz, ABD'de niş ama yüksek ARPU bir oyuncuyuz. SimplePractice'in bizi satın almak isteyeceği seviyeye gelmek hedef değil — **biz ondan büyük olacağız çünkü o oyun oynayamıyor**.

**Eksik yapmamamız gereken üç şey**:
- E1 sertifikasyon saatini bugün başlatmak (52 hafta; 6 ay gecikme = pazar kaybı).
- B2 verisini ilk günden imzalı/audit-grade tasarlamak. Sonradan eklenmez.
- F1'i clinician-in-the-loop'la lansman yapmak; aksi takdirde "AI terapist" gibi görünür ve regülatör/medya tepkisi alırız.

Tek satırlık özet: **Notu yazan AI değil, bakımı işleten AI olacağız.**
