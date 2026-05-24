# ADR-0002: Firestore as the multi-tenant persistence layer

- **Date:** 2026-05-20
- **Status:** Accepted
- **Deciders:** Çağlar Ilhan
- **Supersedes:** —

## Context

PsyClinicAI needs a persistence layer that:

1. is **EU-resident** by default (GDPR Article 44),
2. supports **per-tenant isolation** at the document level,
3. has a **real-time push model** so the Live AI panel reflects new notes
   the moment they are saved,
4. has a **mobile + web** SDK from a vendor that already has a BAA path,
5. minimises the amount of backend code a solo founder needs to maintain.

Candidates: Firestore, Supabase, AWS DynamoDB, self-hosted PostgreSQL.

## Decision

Cloud **Firestore in the `eur3` multi-region (Frankfurt / Belgium)**.
Schema and security rules use one root collection per tenant:

```
/clinics/{clinicId}/...
```

In the pilot solo-practice model, `clinicId == auth.uid`. The Firestore
security rule is a single root-level guard:

```js
match /clinics/{clinicId}/{document=**} {
  allow read, write: if request.auth.uid == clinicId;
}
```

A future enterprise tier (multi-clinician clinic) will switch to
`request.auth.uid in clinic.members[]` lookup; the data model already
supports it via the `/clinicians` sub-collection.

## Consequences

**Pros**

- Real-time push out of the box (snapshot listeners power the dashboard).
- EU residency on a managed service, BAA available from Google Cloud.
- Schemaless writes keep iteration fast in Sprint 4-6.
- Single source of truth for paths: `lib/services/data/firestore_schema.dart`.

**Cons**

- Vendor lock-in to Firebase. Mitigation: repositories isolate Firestore
  semantics; a `PostgresRepository` swap is feasible.
- Aggregation queries are weak. We will use Cloud Functions or BigQuery
  exports for analytics (Sprint 5+).
- Composite indexes must be declared up-front; build will fail at runtime
  if missing — covered by emulator integration tests.

## Alternatives considered

- **Supabase Postgres.** Strong relational story but requires running our
  own auth or coupling to Supabase Auth; row-level security less battle-
  tested than Firestore rules at solo-founder scale.
- **DynamoDB.** Excellent at scale, weak at developer ergonomics for a
  Flutter solo pilot; no first-class Flutter SDK.
- **Self-hosted Postgres on Hetzner.** Lower vendor lock-in but doubles
  operational surface (we already run Nginx + fail2ban on Hetzner).

## Links

- `lib/services/data/firestore_schema.dart`
- `firestore.rules` (Sprint 3)
- `ARCHITECTURE.md` section 3
