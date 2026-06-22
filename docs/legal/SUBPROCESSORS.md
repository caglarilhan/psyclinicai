# GDPR Art. 28(2) — Subprocessor list (Annex II of our DPA)

**Last reviewed:** 2026-06-19 (Sprint 30 S-05)
**Owner:** legal-ops@psyclinicai.com
**Customer notice window:** 30 days before a new subprocessor goes live. Customers
may object in writing; if we cannot accommodate, either side may terminate the
DPA per § 12 of the master agreement.

Each row covers:
- the legal entity actually receiving customer data,
- the categories of personal / clinical data they process,
- the role (processor / sub-processor),
- the location (data residency),
- the legal transfer mechanism for any data leaving the EU/EEA.

---

## 1. Cloud infrastructure

| Subprocessor | Service | Data categories | Region | Transfer mechanism |
|---|---|---|---|---|
| Google Ireland Ltd. (Firebase / Google Cloud) | Auth, Firestore, Cloud Functions, Hosting | account metadata, audit logs, encrypted PHI documents | EU multi-region (`europe-west1`) | EU intra-EEA + EU SCCs 2021/914 for fallback US operations + Google's [BAA](https://cloud.google.com/security/compliance/hipaa) for HIPAA-covered tenants |
| Hetzner Online GmbH | RAG hub VM (`rag.psyclinicai.com`) | non-PHI clinical guidelines, query hashes, audit rows, encrypted Postgres + Qdrant volumes | DE / FI (EU) | Intra-EEA only |
| Hetzner Online GmbH (Storage Box) | Encrypted restic backups of Postgres + Qdrant | encrypted backup blobs | DE / FI (EU) | Intra-EEA only |

## 2. AI / LLM providers

| Subprocessor | Service | Data categories | Region | Transfer mechanism |
|---|---|---|---|---|
| Anthropic PBC | Claude API (`anthropicRelay`) | session transcript chunks (no PHI by default — clinician opt-in only) | US | EU SCCs + Anthropic [zero-retention](https://www.anthropic.com/legal/commercial-terms) option for PHI tenants. **BYOK** by default — customer's own key, billed direct. |
| Groq Inc. | Llama 3.x inference for non-PHI RAG queries | tokenised non-PHI medical guideline queries | US | EU SCCs + Groq DPA addendum (signed by 2026-06-30 per `vendor-unlocks.md` #2). **Paid tier behind `GROQ_PAID_TIER_ENABLED` kill-switch.** |
| Google LLC (Gemini API fallback) | Gemini 2.0 inference for non-PHI RAG queries when Groq is degraded | tokenised non-PHI medical guideline queries | US | EU SCCs + same Google BAA / Google AI Studio DPA |
| Local Ollama (on the Hetzner VM) | PHI-bearing inference path | full session transcript including PHI | EU (DE / FI) | No transfer — runs in-process on the hub container. **Required for any `has_phi=True` route**, enforced by `psyrag.llm_router._route_by_phi`. |
| Cohere Inc. (planned, Sprint 31) | Re-ranker for RAG candidate set | tokenised non-PHI medical guideline candidate chunks | US | EU SCCs + Cohere [DPA](https://cohere.com/data-protection). Gated behind `COHERE_API_KEY` env — not active in Wave A. |

## 3. Payments

| Subprocessor | Service | Data categories | Region | Transfer mechanism |
|---|---|---|---|---|
| Stripe Payments Europe Ltd. | Customer billing (`Checkout`, `Customer Portal`, `Connect Standard`) | clinician contact info, billing address, last-4 card + brand (tokenised), subscription state | IE (EU) + US (PCI scope) | Stripe acts as PCI-DSS processor; EU SCCs cover any out-of-region flows. [Stripe BAA](https://stripe.com/legal/baa) for HIPAA-covered tenants. |

## 4. Observability

| Subprocessor | Service | Data categories | Region | Transfer mechanism |
|---|---|---|---|---|
| Functional Software Inc. d/b/a Sentry | Crash + error capture (Flutter / Node / Python) | request_id, release tag, stack trace (PII-scrubbing rule enforced via `beforeSend` filter — `email`, `uid`, `tenant_id` redacted before transmit) | US | EU SCCs + Sentry [DPA](https://sentry.io/legal/dpa/) + `send_default_pii=False` default |
| PostHog Inc. (EU instance, `eu.posthog.com`) | Product analytics, funnel events | event name, anonymised `distinct_id`, locale, viewport, no PHI | EU multi-region | Intra-EEA only |
| Twilio SendGrid Inc. | Transactional email for waitlist + IR comms | clinician email address only | US | EU SCCs + SendGrid [DPA](https://www.twilio.com/legal/data-protection-addendum) |
| Cloudflare Inc. | Turnstile bot-protection on `beta_signups` form | client IP (hashed by Cloudflare), browser fingerprint | EU (DE edge nodes) | EU SCCs + Cloudflare [DPA](https://www.cloudflare.com/cloudflare_customer_DPA/) |

## 5. Operations / on-call

| Subprocessor | Service | Data categories | Region | Transfer mechanism |
|---|---|---|---|---|
| PagerDuty Inc. (planned, Sprint 31) | SEV1/SEV2 paging for the on-call rotation | clinician-facing service name + severity. **No customer data transmitted** — the page body references the audit_log row id only. | US | EU SCCs + PagerDuty [DPA](https://www.pagerduty.com/privacy-policy/dpa/) |
| Atlassian Pty Ltd. (Statuspage.io) | Public uptime + incident comms | none — incident text is written by us, no automatic ingest of customer data | US | EU SCCs + Statuspage [DPA](https://www.atlassian.com/legal/data-processing-addendum) |

---

## 6. Removal log

When a subprocessor is replaced or removed, the row stays here with the
status flipped to `removed` and the removal date appended, so the
historic data flow remains auditable.

| Subprocessor | Removed | Reason |
|---|---|---|
| _none yet_ | — | — |

## 7. Customer notice template

> **Subject:** PsyClinicAI subprocessor update — [SUBPROCESSOR_NAME], effective [DATE]
>
> Per § 4 of our Data Processing Addendum we are giving you 30 days'
> notice that the subprocessor named above will begin processing the data
> categories listed in our published Annex II
> (`docs/legal/SUBPROCESSORS.md`) from [DATE].
>
> Updated Annex II is published at: https://psyclinicai.com/dpa
> If you wish to object, reply to this email by [DATE-3].
