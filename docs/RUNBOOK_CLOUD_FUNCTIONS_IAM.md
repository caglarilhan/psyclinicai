# Cloud Functions — Service Account IAM (Least-Privilege Runbook)

**Status:** draft (Sprint 9 close-out)
**Owner:** PsyClinicAI SRE
**Last reviewed:** 2026-06-02

---

## 1. Why this exists

Every Firebase Cloud Function ships, by default, with the **App Engine
default service account** (`PROJECT_ID@appspot.gserviceaccount.com`),
which holds the **Editor** role on the entire project. That role can
read and write every Firestore collection, every Storage object, and
every IAM binding — the opposite of HIPAA §164.312(a)(1) "minimum
necessary access".

This runbook lists the smallest IAM bindings each Cloud Function
needs and the `gcloud` commands to apply them. Apply them in `dev`
first, smoke-test the function end-to-end, then promote to `prod`.

---

## 2. Per-function privilege map

| Function                | Reads                          | Writes                                      | Network              |
|-------------------------|--------------------------------|---------------------------------------------|----------------------|
| `anthropicRelay`        | none                           | none                                        | `api.anthropic.com`  |
| `createCheckoutSession` | none                           | none                                        | `api.stripe.com`     |
| `stripeWebhook`         | none                           | `subscriptions/*`                           | none                 |
| `auditRetentionPurge`   | `audit_logs/*` (read+update)   | `audit_logs/*` (update, append self-entry)  | none                 |
| `accountDeletionPurge`  | `account_deletions/*`, `intakes/*`, `safety_plans/*`, `session_notes/*` | same collections (merge), `account_deletions/{userId}.completed_at`, `audit_logs/*` (append) | none |

---

## 3. Service-account-per-function

Pin one identity per function so a compromise of one cannot reach
the others. Substitute `PROJECT_ID` with the Firebase project id.

```bash
# 3.1 — create the identities (run once)
for fn in anthropic-relay create-checkout-session stripe-webhook \
          audit-retention-purge account-deletion-purge; do
  gcloud iam service-accounts create "fn-$fn" \
    --display-name "Cloud Function: $fn" \
    --project PROJECT_ID
done
```

After deployment, attach the identity to each function (in
`firebase.json` `runtime` settings or via `gcloud functions deploy
--service-account`):

```jsonc
// firebase.json (excerpt)
{
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "runtime": "nodejs20",
      "serviceAccount":
        "fn-anthropic-relay@PROJECT_ID.iam.gserviceaccount.com"
    }
  ]
}
```

The Firebase CLI accepts `serviceAccount` per codebase from
`firebase-tools >= 13.7`. For mixed runtimes, deploy each function
individually with `gcloud functions deploy --service-account ...`.

---

## 4. Minimum role bindings

`roles/datastore.user` is overkill — it grants read on every
collection. Use **conditional bindings** (IAM v3 Conditions) or
**custom roles** to limit access to the collections the function
actually touches. Below is the custom-role approach; the trade-off
is one more YAML file to keep in sync.

### 4.1 `anthropicRelay` & `createCheckoutSession`

Neither function reads or writes Firestore. They only need:

```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member "serviceAccount:fn-anthropic-relay@PROJECT_ID.iam.gserviceaccount.com" \
  --role "roles/cloudfunctions.invoker"
```

The Anthropic and Stripe API keys live in **Secret Manager** (rotated
quarterly) — bind `roles/secretmanager.secretAccessor` only on the
specific secret resources:

```bash
gcloud secrets add-iam-policy-binding ANTHROPIC_API_KEY \
  --member "serviceAccount:fn-anthropic-relay@PROJECT_ID.iam.gserviceaccount.com" \
  --role "roles/secretmanager.secretAccessor"
```

### 4.2 `stripeWebhook`

```bash
# Read + write on subscriptions/* only.
gcloud iam roles create psyclinicaiStripeWebhook --project PROJECT_ID \
  --title "PsyClinicAI Stripe webhook" \
  --permissions datastore.entities.create,datastore.entities.update,\
datastore.entities.get,datastore.queries.list

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member "serviceAccount:fn-stripe-webhook@PROJECT_ID.iam.gserviceaccount.com" \
  --role "projects/PROJECT_ID/roles/psyclinicaiStripeWebhook" \
  --condition='expression=resource.name.startsWith("projects/_/databases/(default)/documents/subscriptions/"),title=subscriptions_only'
```

### 4.3 `auditRetentionPurge`

```bash
gcloud iam roles create psyclinicaiAuditRetention --project PROJECT_ID \
  --title "PsyClinicAI audit retention purge" \
  --permissions datastore.entities.get,datastore.entities.update,\
datastore.entities.create,datastore.queries.list

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member "serviceAccount:fn-audit-retention-purge@PROJECT_ID.iam.gserviceaccount.com" \
  --role "projects/PROJECT_ID/roles/psyclinicaiAuditRetention" \
  --condition='expression=resource.name.startsWith("projects/_/databases/(default)/documents/audit_logs/"),title=audit_logs_only'
```

### 4.4 `accountDeletionPurge`

```bash
gcloud iam roles create psyclinicaiAccountDeletion --project PROJECT_ID \
  --title "PsyClinicAI account deletion purge" \
  --permissions datastore.entities.get,datastore.entities.update,\
datastore.entities.create,datastore.queries.list

# Five paths: account_deletions, intakes, safety_plans, session_notes,
# audit_logs. Apply one binding per path with a starting-with condition
# so the role cannot read other collections (e.g. clinicians, billing).
for col in account_deletions intakes safety_plans session_notes audit_logs; do
  gcloud projects add-iam-policy-binding PROJECT_ID \
    --member "serviceAccount:fn-account-deletion-purge@PROJECT_ID.iam.gserviceaccount.com" \
    --role "projects/PROJECT_ID/roles/psyclinicaiAccountDeletion" \
    --condition="expression=resource.name.startsWith(\"projects/_/databases/(default)/documents/$col/\"),title=${col}_only"
done
```

---

## 5. Verification

After applying the bindings, smoke-test from `dev`:

```bash
# 1. Confirm each function only touches the expected collections
firebase emulators:start --only firestore,functions
# Trigger anthropicRelay with a bogus payload; confirm Firestore audit log
# in another terminal is empty (relay must not write).

# 2. Force-fail a forbidden read — auditRetentionPurge tries
# db.collection('clinicians').get() (should throw PERMISSION_DENIED).

# 3. Verify the IAM Recommender shows no Editor / Owner-equivalent
# bindings on any fn-* service account.
gcloud asset analyze-iam-policy \
  --project=PROJECT_ID \
  --identity="serviceAccount:fn-account-deletion-purge@PROJECT_ID.iam.gserviceaccount.com" \
  --output-resource-edges
```

---

## 6. Rotation checklist

- **Secret Manager keys** — Anthropic + Stripe rotate every 90 days.
  Set a Calendar reminder (`compliance/secret-rotation@psyclinicai.com`).
- **Service account keys** — disabled by default (gcloud SA keys are
  not created). If a key ever gets minted, rotate within 30 days.
- **Custom role audit** — every six months, review the `permissions:`
  list on each `roles/psyclinicai*` role and drop anything unused.

---

## 7. References

- HIPAA §164.312(a)(1) — Access control standard
- ISO 27001:2022 A.5.15 — Access control
- Google Cloud IAM Conditions documentation
- `firebase.json` `serviceAccount` field (firebase-tools ≥ 13.7)
