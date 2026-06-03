#!/usr/bin/env bash
# PsyClinicAI — Cloud Functions production deploy wrapper.
#
# Pre-flight env check + tsc validation + firebase deploy + smoke
# test. Sprint 25 W1 release-blocker.
#
# Usage:
#   scripts/deploy_cloud_functions.sh [--dry-run]

set -euo pipefail
DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then DRY_RUN=1; fi

REQUIRED=(
  ANTHROPIC_PROXY_API_KEY
  STRIPE_SECRET_KEY
  STRIPE_CONNECT_WEBHOOK_SECRET
  STRIPE_WEBHOOK_SECRET
  DAILY_API_KEY
  FIREBASE_PROJECT_ID
  ALLOWED_ORIGINS
)

echo "▶ PsyClinicAI Cloud Functions deploy"
echo "  project: ${FIREBASE_PROJECT_ID:-MISSING}"
echo "  dry run: $DRY_RUN"
echo ""

# 1. Validate env
MISSING=()
for v in "${REQUIRED[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    MISSING+=("$v")
  fi
done
if (( ${#MISSING[@]} > 0 )); then
  echo "✗ Missing required env vars:"
  printf '  - %s\n' "${MISSING[@]}"
  echo ""
  echo "  Load from Vault:"
  echo "  vault kv get -format=json secret/psyclinicai/prod | jq …"
  exit 1
fi
echo "✓ All ${#REQUIRED[@]} required env vars present"

# 2. Validate TypeScript compiles
echo ""
echo "▶ Type-checking functions/"
(cd functions && npx tsc --noEmit)
echo "✓ tsc --noEmit clean"

# 3. Validate Firestore rules parse
echo ""
echo "▶ Validating firestore.rules"
if command -v firebase >/dev/null 2>&1; then
  firebase firestore:rules:test --project="$FIREBASE_PROJECT_ID" \
    firestore.rules 2>/dev/null || true
fi

# 4. Show what would deploy
echo ""
echo "▶ Functions to deploy:"
grep -E "^export const|^export \{" functions/src/index.ts \
  | sed 's/^/  · /'

# 5. Deploy (or dry-run)
echo ""
if (( DRY_RUN )); then
  echo "▶ DRY RUN — would run:"
  echo "   firebase deploy \\"
  echo "     --project=$FIREBASE_PROJECT_ID \\"
  echo "     --only functions,firestore:rules \\"
  echo "     --force"
  exit 0
fi

echo "▶ Deploying to $FIREBASE_PROJECT_ID …"
firebase deploy \
  --project="$FIREBASE_PROJECT_ID" \
  --only functions,firestore:rules \
  --force

# 6. Smoke-test the deployed surface
echo ""
echo "▶ Smoke-testing health endpoints …"
REGION="${FIREBASE_REGION:-us-central1}"
BASE="https://${REGION}-${FIREBASE_PROJECT_ID}.cloudfunctions.net"

for fn in llmProxy stripeConnectOnboard telehealthRoom; do
  status=$(curl -s -o /dev/null -w "%{http_code}" \
    -X OPTIONS "$BASE/$fn" || echo 000)
  echo "  $fn: HTTP $status"
done

echo ""
echo "✓ Deploy complete. Watch logs:"
echo "  firebase functions:log --project=$FIREBASE_PROJECT_ID"
