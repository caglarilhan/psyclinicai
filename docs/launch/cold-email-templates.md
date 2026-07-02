# Cold-email templates — PILAR 1-4

EU brand voice: plural ("we / our team"), professional, calm,
clinical-grade. No personal-founder framing. Never imply FDA
clearance. ROI numbers are conservative; payer claims sit on the
published vehicle (CMS MIPS #134), not on any specific contract.

Open rates target: warm 35%, lukewarm 18%, cold 6%. Reply target: 4%.

---

## PILAR 1 — Ambient Clinical Scribe

### Subject lines (A/B/C)
- A: "What would you do with an extra 10 hours a week?"
- B: "Press record. Sign the SOAP note 60 seconds later."
- C: "Your evenings called. They want their hours back."

### Body — cold list (clinician, US/EU)

> Hi {{first_name}},
>
> Most of the clinicians we work with were spending **8 to 15 hours a
> week** on documentation before they switched. After a month with our
> ambient scribe, that number is **under one**.
>
> We built it specifically for mental-health practice — the
> mental-status exam structure, DSM-5-TR-aligned assessment, and a
> safety-plan-aware Plan section come standard. Every claim the
> assistant emits cites the transcript span it came from, so you can
> verify a sentence in two seconds before you sign.
>
> Free 30 days. No card needed. If you don't get the hours back, the
> trial extends another 30 days on us.
>
> {{calendar_link}}
>
> — {{your_name}}, the psyclinicai team

### Body — warm list (existing waitlist)

> Hi {{first_name}},
>
> You signed up for our beta a few weeks back. Quick update:
>
> The ambient scribe just shipped. Press record at the start of a
> session, get a signed SOAP draft 60 seconds after you stop. The
> assistant cites every claim to the transcript so you can verify
> before you sign.
>
> Want first access? Reply "yes" and we'll set you up tomorrow.
>
> — {{your_name}}

---

## PILAR 2 — Measurement-Based Care Engine

### Subject lines
- A: "Your PHQ-9 follow-ups, in your patients' pockets"
- B: "MBC-certified practice = +5-15% payer reimbursement"
- C: "PHQ-9, GAD-7, PCL-5 — sent + scored + flagged automatically"

### Body — practice owner

> Hi {{first_name}},
>
> US payers (CMS MIPS #134, CalAIM, Cigna VBC) consistently pay
> measurement-based-care-certified practices **5-15% more per session**.
> Most clinics never collect because between-session dispatch is the
> painful part.
>
> We just shipped that. Your clinician picks a patient + scale (PHQ-9,
> GAD-7, WHO-5, PCL-5, AUDIT), one tap mints a private link, the patient
> fills it in their browser — no account, no login. Scores land in your
> dashboard with a risk flag the moment they cross the alarm threshold.
>
> Want to see the dispatch + scoring flow on a 15-min call this week?
>
> {{calendar_link}}

---

## PILAR 3 — No-Show Predictor + Auto-Recovery

### Subject lines
- A: "Your no-shows cost you \$X this month. Here's the receipt."
- B: "What if we caught your high-risk slots 72 hours out?"
- C: "ROI: \$2k/month per clinician. Or your money back."

### Body — practice manager

> Hi {{first_name}},
>
> Average mental-health practice no-show rate runs 15-25%. At 1.5
> sessions a week per slot, that's roughly **\$2,000 a month per
> clinician** walking out the door.
>
> We just shipped a predictor that tiers every upcoming appointment
> low / medium / high. High-tier slots get a deposit hold + a 72/48/24/
> 4/1-hour confirm cadence + an auto-waitlist offer the moment the
> patient cancels. Medium tier gets the cadence without the deposit.
> Low tier stays out of your way.
>
> First 30 days are free. If we don't recover the slot revenue, the
> trial extends another 30 days. ROI calculator on the landing page.
>
> {{calendar_link}}

---

## PILAR 4 — Evidence-Based Treatment Plan Drafter

### Subject lines
- A: "From intake to signed plan in 10 minutes"
- B: "SMART goals cited to NICE CG90. Every. Single. One."
- C: "Hiring a clinician? Your onboarding just dropped 4 weeks."

### Body — group practice / training program

> Hi {{first_name}},
>
> When a new clinician joins your practice, the slowest week is
> usually treatment-plan drafting. Static templates don't fit the
> patient; from-scratch drafting eats 2-3 hours per case.
>
> We just shipped a drafter that takes a disorder + modality + a few
> presenting problems and emits a complete plan with SMART goals
> **cited verbatim** to NICE / APA / SAMHSA / WHO mhGAP — defensible
> care on day one. PTSD / BPD / AUD protocols route to a supervisor
> for co-sign automatically.
>
> 12 protocols supported today: depression / GAD / panic / social
> anxiety / PTSD / OCD / BPD / binge-eating / AUD / insomnia.
>
> Want a 5-minute demo with a real case?
>
> {{calendar_link}}

---

## Multi-pillar (when 2+ pillars are live)

### Subject
- "We just shipped 4 features. Pick the one that solves your week."

### Body

> Hi {{first_name}},
>
> Last 60 days at psyclinicai:
>
> 1. **Ambient scribe** — record a session, get a signed SOAP. 60s.
> 2. **MBC engine** — patient-facing PHQ-9/GAD-7 link, scored + flagged.
> 3. **No-show predictor** — tier every appointment, auto-recover slots.
> 4. **Plan drafter** — SMART goals cited to NICE/APA.
>
> Each one comes with a 30-day free trial. Pick the one that hurts
> the most this week.
>
> {{calendar_link}}

---

## Operational notes

- **First touch**: send 9am local-time, Tuesday-Wednesday.
- **Follow-up cadence**: +3 days → +7 days → +14 days, max 3 touches.
- **Personalisation tokens**: `{{first_name}}`, `{{practice_name}}`, `{{calendar_link}}`, `{{your_name}}` — keep the rest static so the warmth scales.
- **Unsubscribe**: footer one-click, recorded in the suppression list.
- **A/B subject test**: ship 20% of the list to A + B + C each, then send the winner to the remaining 40% per pillar.
