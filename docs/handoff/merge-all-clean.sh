#!/usr/bin/env bash
# Merge every CLEAN open PR in chronological order, squash, delete branch.
# Stops at the first failure. Safe to rerun — already-merged PRs are skipped.
#
# Usage:
#   cd /Users/caglarilhan/psyclinicai
#   bash docs/handoff/merge-all-clean.sh
#
# See docs/handoff/MERGE-RUNBOOK.md for pre/post checks.

set -euo pipefail

cd "$(dirname "$0")/../.."

echo "==> Pulling main..."
git checkout main
git pull --ff-only origin main

echo "==> Snapshotting open PR queue..."
total=$(gh pr list --state open --limit 200 --json number --jq 'length')
clean=$(gh pr list --state open --limit 200 --json mergeStateStatus \
  --jq '[.[] | select(.mergeStateStatus=="CLEAN")] | length')
echo "    open=$total  clean=$clean"

if [ "$clean" -eq 0 ]; then
  echo "    nothing to merge."
  exit 0
fi

echo "==> Merging CLEAN PRs oldest-first..."
gh pr list --state open --limit 200 --json number,mergeStateStatus \
  --jq '.[] | select(.mergeStateStatus=="CLEAN") | .number' \
  | sort -n \
  | while read -r n; do
      echo "--- PR #$n ---"
      if ! gh pr merge "$n" --squash --delete-branch; then
        echo "STOPPED at #$n. Resolve + re-run."
        exit 1
      fi
    done

echo "==> Pulling main again..."
git checkout main
git pull --ff-only origin main

echo "==> Post-merge: flutter analyze..."
flutter analyze 2>&1 | tail -10 || true

echo "==> Post-merge: flutter test..."
flutter test 2>&1 | tail -10 || true

echo "==> Remaining open PRs:"
gh pr list --state open --limit 10

echo
echo "Done. See docs/handoff/CATALOG-INDEX.md for the auditor brief."
