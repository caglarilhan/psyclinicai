#!/usr/bin/env bash
#
# PsyClinicAI — Stripe Live setup helper.
#
# Creates the three Wave A founding-member products, six prices (USD + EUR),
# and a subscription webhook endpoint. Writes the resulting IDs to
# `stripe-secrets.env` so the operator can paste them into
# `firebase functions:secrets:set` interactively.
#
# Pre-requisites:
#   - Stripe CLI installed:        brew install stripe/stripe-cli/stripe
#   - `stripe login` already done. `stripe config --list` should show
#     `workspace.mode = live` before running this script — guard below
#     refuses to proceed if it isn't.
#
# Idempotency:
#   - Product names use a stable `psyclinicai-{tier}-founding` lookup-key
#     so re-runs UPSERT instead of duplicating.
#   - Prices are flagged with a `tier=<tier>,currency=<usd|eur>` metadata
#     pair; if a price with the same metadata already exists we re-use it.
#
# Outputs:
#   - stripe-secrets.env (gitignored — see .gitignore additions)
#   - stdout summary table

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: scripts/stripe-live-setup.sh [--webhook-url URL] [--dry-run]

Options:
  --webhook-url URL   Cloud Function URL to subscribe (default:
                      https://europe-west1-psyclinicai.cloudfunctions.net/stripeSubscriptionWebhook)
  --dry-run           Print actions without calling Stripe
  -h, --help          Show this help
USAGE
}

WEBHOOK_URL="https://europe-west1-psyclinicai.cloudfunctions.net/stripeSubscriptionWebhook"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --webhook-url) WEBHOOK_URL="$2"; shift 2 ;;
        --dry-run)     DRY_RUN=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        *) echo "unknown arg: $1" >&2; usage; exit 2 ;;
    esac
done

command -v stripe >/dev/null 2>&1 || {
    echo "[fatal] Stripe CLI not installed. Run: brew install stripe/stripe-cli/stripe" >&2
    exit 1
}

# Guard: refuse to operate against test mode unless --dry-run.
MODE=$(stripe config --list 2>/dev/null | awk -F= '/^workspace.mode/ {gsub(/ /,"",$2); print $2}')
if [[ "$MODE" != "live" && "$DRY_RUN" -eq 0 ]]; then
    cat <<EOF >&2
[fatal] Stripe CLI workspace.mode is "$MODE", not "live".
        Run:  stripe config --set workspace.mode live
        Or pass --dry-run to preview against test mode.
EOF
    exit 1
fi

OUT_ENV="$(cd "$(dirname "$0")/.." && pwd)/stripe-secrets.env"

# --- helpers -----------------------------------------------------------------
run_stripe() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] stripe $*" >&2
        echo '{"id":"dryrun_id"}'
    else
        stripe "$@"
    fi
}

# upsert_product TIER NAME DESC -> echoes product_id
upsert_product() {
    local tier="$1" name="$2" desc="$3"
    local lookup="psyclinicai-${tier}-founding"

    local existing
    existing=$(run_stripe products list --limit 100 \
        | grep -Eo '"id":[[:space:]]*"prod_[A-Za-z0-9]+"[^}]*"metadata":[^}]*"lookup":[[:space:]]*"'"$lookup"'"' \
        | grep -Eo 'prod_[A-Za-z0-9]+' | head -1 || true)

    if [[ -n "$existing" ]]; then
        echo "[upsert] product $tier already exists: $existing" >&2
        echo "$existing"
        return
    fi

    local pid
    pid=$(run_stripe products create \
        --name "$name" \
        --description "$desc" \
        -d "statement_descriptor=PSYCLINICAI" \
        -d "metadata[lookup]=$lookup" \
        -d "metadata[tier]=$tier" \
        -d "metadata[cohort]=wave_a_founding" \
        | grep -Eo '"id":[[:space:]]*"prod_[A-Za-z0-9]+"' | head -1 \
        | grep -Eo 'prod_[A-Za-z0-9]+')
    echo "$pid"
}

# upsert_price PRODUCT_ID TIER CURRENCY AMOUNT_MINOR -> echoes price_id
upsert_price() {
    local product="$1" tier="$2" currency="$3" minor="$4"

    local marker="tier=$tier,currency=$currency"
    local existing
    existing=$(run_stripe prices list --product "$product" --limit 100 \
        | grep -Eo '"id":[[:space:]]*"price_[A-Za-z0-9]+"[^}]*"metadata":[^}]*"marker":[[:space:]]*"'"$marker"'"' \
        | grep -Eo 'price_[A-Za-z0-9]+' | head -1 || true)

    if [[ -n "$existing" ]]; then
        echo "[upsert] price $tier/$currency already exists: $existing" >&2
        echo "$existing"
        return
    fi

    local prid
    prid=$(run_stripe prices create \
        --product "$product" \
        --currency "$currency" \
        --unit-amount "$minor" \
        -d "recurring[interval]=month" \
        -d "recurring[trial_period_days]=14" \
        -d "metadata[marker]=$marker" \
        | grep -Eo '"id":[[:space:]]*"price_[A-Za-z0-9]+"' | head -1 \
        | grep -Eo 'price_[A-Za-z0-9]+')
    echo "$prid"
}

# --- products ----------------------------------------------------------------
echo "==> Upserting products"
SOLO_PROD=$(upsert_product "solo"     "Solo Founding Member"     "Founding-member pricing for solo practitioners — lifetime rate.")
PRAC_PROD=$(upsert_product "practice" "Practice Founding Member" "For practices with 2–5 clinicians.")
GROUP_PROD=$(upsert_product "group"    "Group Founding Member"    "For groups with 6+ clinicians. Includes Connect onboarding.")

echo "    solo:     $SOLO_PROD"
echo "    practice: $PRAC_PROD"
echo "    group:    $GROUP_PROD"

# --- prices (cents/minor units) ----------------------------------------------
echo "==> Upserting prices"
SOLO_USD=$(upsert_price  "$SOLO_PROD"  "solo"     "usd" 4900)
SOLO_EUR=$(upsert_price  "$SOLO_PROD"  "solo"     "eur" 4500)
PRAC_USD=$(upsert_price  "$PRAC_PROD"  "practice" "usd" 14900)
PRAC_EUR=$(upsert_price  "$PRAC_PROD"  "practice" "eur" 13900)
GROUP_USD=$(upsert_price "$GROUP_PROD" "group"    "usd" 29900)
GROUP_EUR=$(upsert_price "$GROUP_PROD" "group"    "eur" 27900)

# --- webhook -----------------------------------------------------------------
echo "==> Registering subscription webhook"
EXISTING_HOOK=$(run_stripe webhook_endpoints list --limit 100 \
    | grep -Eo '"id":[[:space:]]*"we_[A-Za-z0-9]+"[^}]*"url":[[:space:]]*"'"$WEBHOOK_URL"'"' \
    | grep -Eo 'we_[A-Za-z0-9]+' | head -1 || true)

if [[ -n "$EXISTING_HOOK" ]]; then
    echo "    webhook already exists: $EXISTING_HOOK"
    WH_SECRET="(rotate manually in dashboard if needed)"
else
    WH_RESPONSE=$(run_stripe webhook_endpoints create \
        --url "$WEBHOOK_URL" \
        --enabled-events "checkout.session.completed" \
        --enabled-events "customer.subscription.created" \
        --enabled-events "customer.subscription.updated" \
        --enabled-events "customer.subscription.deleted" \
        --enabled-events "invoice.payment_succeeded" \
        --enabled-events "invoice.payment_failed")
    WH_SECRET=$(echo "$WH_RESPONSE" | grep -Eo '"secret":[[:space:]]*"whsec_[^"]+"' | grep -Eo 'whsec_[A-Za-z0-9]+')
fi

# --- write env file ----------------------------------------------------------
TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
cat > "$OUT_ENV" <<ENV
# stripe-secrets.env — generated $TS by scripts/stripe-live-setup.sh
# DO NOT COMMIT (already in .gitignore). Paste these into
#   firebase functions:secrets:set <NAME>
# one by one when prompted.

STRIPE_PRICE_SOLO=$SOLO_USD
STRIPE_PRICE_SOLO_EUR=$SOLO_EUR
STRIPE_PRICE_PRACTICE=$PRAC_USD
STRIPE_PRICE_PRACTICE_EUR=$PRAC_EUR
STRIPE_PRICE_GROUP=$GROUP_USD
STRIPE_PRICE_GROUP_EUR=$GROUP_EUR

STRIPE_SUBSCRIPTION_WEBHOOK_SECRET=$WH_SECRET
STRIPE_WEBHOOK_SECRET=$WH_SECRET
# STRIPE_LIVE_SK — fetch from Dashboard → API keys → Reveal live key
ENV

echo
echo "==> Done. Summary:"
column -t -s= <"$OUT_ENV" | grep -v '^#'

cat <<NEXT

Next steps (manual, ~5 min):
  1. firebase functions:secrets:set STRIPE_LIVE_SK
       (paste sk_live_... from Dashboard → API keys → Reveal live key)
  2. for var in STRIPE_PRICE_SOLO STRIPE_PRICE_PRACTICE STRIPE_PRICE_GROUP \\
                STRIPE_WEBHOOK_SECRET STRIPE_SUBSCRIPTION_WEBHOOK_SECRET; do
         val=\$(grep "^\$var=" $OUT_ENV | cut -d= -f2)
         echo "Setting \$var ..."
         echo "\$val" | firebase functions:secrets:set \$var --data-file=-
     done
  3. firebase deploy --only \\
         functions:createCheckoutSession,functions:stripeWebhook,\\
         functions:stripeSubscriptionWebhook,functions:stripeCustomerPortalSession
  4. Smoke test (see ~/Downloads/Stripe-Live-Rehber.md §D5).

NEXT
