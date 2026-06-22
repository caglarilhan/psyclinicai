# Google Play — Data safety form (PsyClinicAI)

## Data collection & sharing

| Type | Collected | Shared with third parties | Optional | Purpose |
|---|---|---|---|---|
| Personal info — Name | Yes | No | No | Account management, App functionality |
| Personal info — Email | Yes | No | No | Account management, App functionality |
| Personal info — Phone number | Yes | No | Yes | Account recovery |
| Health & fitness — Health info | Yes | No | No | App functionality (clinician records patient data) |
| Financial info — Other financial info (Stripe id) | Yes | Yes (Stripe / Mollie payment sub-processors — see DPA) | No | App functionality |
| App activity — App interactions | Yes | No | Yes | Analytics, App functionality |
| App info & performance — Crash logs | Yes | No | Yes | Diagnostics |
| App info & performance — Diagnostics | Yes | No | Yes | Diagnostics |
| Device or other IDs | Yes | No | No | App functionality, Authentication |

## Encryption in transit

**Yes** — TLS 1.3 minimum on every endpoint; HSTS preloaded.

## Encryption at rest

**Yes** — every patient-bearing field encrypted at the application layer
with AES-256-GCM. Firestore + Cloud SQL provide additional disk-level
encryption.

## Data deletion

**Yes** — users (clinicians) can request deletion in-app
(`Settings → Account → Delete account`). Patient self-service portal
exposes a Right of Access entry point at `/portal` with a 30-day SLA.
Audit log retention is preserved for 6 years per HIPAA §164.316
regardless of account deletion (de-identified after deletion).

## Independent security review

**Yes** — Drata + annual external pentest. Reports in the Trust Center.

## Committed to Play Families policy / Designed for Families

**No.** Restricted to 17+ clinical use.
