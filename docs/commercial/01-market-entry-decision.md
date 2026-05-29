# Market-Entry Decision: US-first

**Decision:** Enter the **US**, targeting **insurance-billing solo & small
(1–5 clinician) behavioral-health practices**. Treat the EU as Phase 2.

*(Companion to `docs/international_compliance_analysis.md` and `HIPAA-BAA.md` —
this is the go/no-go call, not the full compliance analysis.)*

## Why US-first, even though EU is the easier legal path

The honest tension: the EU/GDPR path is *legally* faster, but our
**differentiator (Denial Shield) is a US private-insurance problem**. Most EU
systems are public / single-payer, so in the EU we'd be leading with the
commodity half (the scribe) and competing on price with Upheal/Mentalyc. In the
US, the dual-engine (scribe **+** claim defense) is unique and the pain is acute.

Selling **into** the US while remaining an **EU-domiciled company** is standard
and not in conflict with our brand positioning — domicile ≠ go-to-market geo.

## The legal/infra gates (must clear before real PHI)

| Gate | What | Owner |
|---|---|---|
| **HIPAA BAA — Anthropic** | Sign Anthropic's BAA for the API (covers the inference layer) | Founder |
| **HIPAA BAA — us → clinician** | We act as Business Associate; clinician is the Covered Entity. Template exists: `HIPAA-BAA.md` | Founder + legal review |
| **Backend relay** | Anthropic calls must not run browser-direct with PHI (SECURITY-BACKLOG #1) | Code (planned) |
| **Demo-mode release guard** | Release builds must never silently run unauthenticated (SECURITY-BACKLOG #2) | Code |
| **Persistent prod backend** | Firebase out of demo mode (`flutterfire configure`) | Founder + code |

## Sequencing (no PHI until gates clear)

1. **Weeks 0–2:** Anthropic BAA + Firebase prod project + backend relay scaffold.
2. **Weeks 2–4:** Stripe + demo-guard + our BAA template legal-reviewed.
3. **Weeks 4–8:** 10 paid pilots (see `04-pilot-gtm.md`) under signed BAAs.
4. **Phase 2 (post-traction):** EU launch leading with the **scribe + outcome
   tracking** (denial prevention de-emphasized), under `GDPR-DPA.md`.

## What we explicitly do NOT do yet
- No real US patient PHI until BAA + relay are live.
- No "guaranteed reimbursement" claims until Denial Shield is validated
  (`03-denial-shield-validation.md`).
- No EU denial-prevention marketing (the feature doesn't fit EU reimbursement).

**Bottom line:** the money engine is US insurance-billing practices. Clear the
BAA + relay gates, then sell the differentiated product where it actually hurts.
