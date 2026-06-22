# Public launch kit — ProductHunt + Hacker News + Indie Hackers + X

**Status:** drafted, **not posted**. Gate per the skill-panel sequence
(`docs/launch/LAUNCH-READINESS-PUNCHLIST.md` §0.5): hold the public launch
until Wave A closed-beta funnel proves ≥ 40 % activation.

This doc holds the copy + assets we'll fire in a single day. Treat each
section as a fill-in template; the bracketed `[FILL]` slots are the only
edits needed at launch time.

---

## 1. ProductHunt

**Title (60 chars max):** PsyClinicAI — AI co-pilot for therapists & psychiatrists

**Tagline (60 chars max):** Notes in 30 s. Superbill in 1 click. Audio stays on-device.

**Description (260 chars max):**
> Cut session notes from 90 minutes to 5. On-device transcription, BYOK
> Claude, auto-generated SOAP/DAP/BIRP, CMS-1500 superbill, PHQ-9 / GAD-7
> dashboards. HIPAA-aligned, GDPR Article 28 DPA, EU data residency by default.

**First-comment template:**
> Hey Product Hunt! We built PsyClinicAI because therapists were spending
> Sunday on notes instead of with their families. Three things we did
> differently:
>
> 1. **Audio never leaves the device.** STT is native; only redacted
>    transcript reaches our hub.
> 2. **BYOK by default.** Clinicians bring their Claude key — we don't
>    rent your tokens to you with a 5× margin.
> 3. **EU-first.** Firebase EU + Hetzner EU + on-device PHI store.
>
> We're in private beta with [FILL — N] founding clinicians and opening
> 25 seats for PH today at 50 % off for 6 months, locked for life.
>
> AMA — what would make this easier for your practice?

**Topics:** AI, Health & Fitness, Productivity, Healthcare, SaaS

**Hunter strategy:** find a hunter who has shipped a healthtech /
clinician tool already; do not self-hunt.

**Launch day rules (from `launch-strategy` skill):**
- Post at 12:01 AM Pacific.
- Reply to every comment within 5 min for the first 4 h.
- 3 demo GIFs (session → SOAP, superbill, PHQ-9 trend) in the gallery —
  no raw screenshots; loops should be ≤ 4 s.

---

## 2. Hacker News — Show HN

**Title (80 chars):** Show HN: PsyClinicAI — on-device transcription + BYOK Claude for therapists

**First-comment template:**
> Hi HN — solo-founder, EU-based. PsyClinicAI is a clinical co-pilot
> for therapists and psychiatrists. The deltas vs. what's already out
> there:
>
> 1. STT runs on-device (native iOS/Android/web speech API). Raw audio
>    never reaches our servers.
> 2. BYOK — you bring your own Anthropic key. No platform-rented LLM
>    margin.
> 3. Per-tenant daily LLM cost cap in code, not just billing —
>    `cost_log` table + 429 on overrun. Open-source the snippet on
>    request.
> 4. EU residency by default. Hetzner CX22 + Firebase europe-west1.
>    HIPAA-aligned (BAA on request), GDPR Article 28 DPA.
>
> Open to feedback on: (a) is on-device STT acceptable to your clinic's
> IT? (b) what's the hardest part of the superbill workflow we got
> wrong?
>
> Free 6-month founding pilot for the first 20 HN clinicians. No card
> at signup.

**Rules:**
- Post Tue/Wed 8:30 AM PT.
- No follow-up "any update?" comments — the front page is binary.
- Be technical: show real metrics (request latency, cost cap, RTO/RPO)
  in replies, not marketing copy.

---

## 3. Indie Hackers

**Title:** Notes from launching PsyClinicAI — a privacy-first AI co-pilot for therapists

**Body skeleton:** 800–1 200 words. Sections: (1) problem statement —
the 90-minute Sunday note ritual; (2) the BYOK / on-device wedge;
(3) what shipped Sprint 1–29 (link to CHANGELOG); (4) what didn't —
honest miss list; (5) pricing logic (founding rate locked for life);
(6) what we want feedback on.

**Disclosure:** include the IndieHackers founder badge; no affiliate
links until we have 100 paying clinicians.

---

## 4. X / Twitter — 5-tweet launch thread

**Tweet 1 (hook):**
> Therapists spend 90 minutes a session on notes.
>
> Our pilot clinicians are down to 5.
>
> Built it because [FILL — pilot quote 1].
>
> Today we're launching the founding-member program. 🧵👇

**Tweet 2 (proof / how):**
> The trick isn't a better LLM. It's the rails around it:
>
> – STT runs on-device. Audio never leaves the room.
> – BYOK Claude. No token-rental margin.
> – Per-tenant daily cost cap in the database, not just the bill.
> – EU residency by default.

**Tweet 3 (offer):**
> Founding-member pilot:
> – 6 months at $49/mo (list $99)
> – Rate locked for life
> – No card at signup
> – Cancel anytime
>
> 30 seats. [FILL — N] left.

**Tweet 4 (compliance):**
> HIPAA-aligned. BAA on request.
> GDPR Article 28 DPA. EU multi-region.
> SOC 2 Type II evidence collection runs Q4 2026.
> Trust center: psyclinicai.com/trust

**Tweet 5 (CTA):**
> If you're a therapist or psychiatrist tired of Sunday notes, the
> waiting list is open here: psyclinicai.com/beta
>
> Reply with your clinic name + jurisdiction and I'll prioritise your
> demo slot this week.

---

## 5. LinkedIn — long-form post (clinician audience)

**Headline:** "We built an AI co-pilot that doesn't record your sessions"

**First paragraph (the hook):**
> A clinician friend told me she dreaded Sundays. Not because of the
> work — because of the notes. PsyClinicAI started that night.

**Closing CTA:**
> If you're a therapist or psychiatrist running a solo practice or a
> small clinic, I'd love 20 minutes of your time this week. DM me;
> demo slots fill quickly.

---

## 6. Press / podcast outreach list (top 12)

> Order by warmth, not reach. The first reply rate matters more than
> the audience size; a small podcast that says yes ships before a big
> one that ghosts.

| Outlet | Angle | Owner intro path |
|---|---|---|
| Therapy Tech Talk | on-device STT, BYOK | LinkedIn intro via [FILL] |
| Healthcare AI Today | EU residency, GDPR Art. 28 | [FILL] |
| Indie Hackers podcast | solo founder bootstrapping | apply via form |
| HealthIT Answers | HIPAA-aligned BAA model | warm intro [FILL] |
| The Psychiatry Podcast | DSM-5 co-pilot UX | guest pitch |
| Healthcare Data Bytes | cost cap + observability | LinkedIn |
| TechCrunch (EU desk) | Hetzner-only €4/mo stack | press@ |
| Sifted | EU AI healthtech | press@ |
| ProductHunt Show | post-launch retro | apply |
| TWiML — psychology + AI ethics | on-device PHI design | guest |
| Lenny's Newsletter | activation north-star (`first_soap_generated`) | personal newsletter pitch |
| Healthcare Unbound | clinician-as-customer GTM | conference pitch |

## 7. Assets checklist (pre-launch D-1)

- [ ] 1200 × 630 OG / social-share image
- [ ] 3 × ProductHunt gallery GIFs (≤ 4 s, ≤ 3 MB each)
- [ ] 1 × hero Loom 90 s walkthrough (vendor-unlocks.md #7)
- [ ] 1 × 30 s pilot testimonial clip (after first 3 pilots reach `first_soap_generated`)
- [ ] Press kit PDF: 2-page summary + logo + founder headshot
- [ ] StatusPage.io running so the launch surge has a public uptime page
- [ ] Slack #launches channel armed (`SLACK_SIGNUP_WEBHOOK` from §6 of vendor-unlocks)

## 8. Day-of war-room (skill panel)

- **release-manager:** snapshot Firestore counts pre-launch + 4 h after.
- **cmo-advisor:** monitor PostHog funnel; flag any 30 %+ drop-off.
- **ciso-advisor:** SEV1 channel open; cap LLM spend at 2 × normal day.
- **founder-coach:** answer every PH/HN comment within 5 min for the
  first 4 h; everything else can wait.
- **change-management:** prep the inevitable "we are surprised by
  demand" follow-up post for D+1.
