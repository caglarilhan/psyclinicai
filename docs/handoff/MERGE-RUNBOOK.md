# Catalog merge runbook — 79 open PRs

Snapshot date: 2026-06-28. All 79 PRs are bağımsız pinned-helper
catalogs that add new const tables under `lib/services/**/`. Each
ships with its own invariant-test file under `test/`. None
modifies existing main-branch files, so cross-PR merge conflicts
are mathematically impossible.

## Pre-flight check (30 seconds)

```bash
cd /Users/caglarilhan/psyclinicai
git checkout main
git pull --ff-only origin main

# Confirm every open PR is still CLEAN before you start.
gh pr list --state open --limit 200 --json number,mergeStateStatus \
  --jq 'group_by(.mergeStateStatus)
        | map({state: .[0].mergeStateStatus, count: length})'
```

Expected output: `[{"count": 79, "state": "CLEAN"}]` (or 78 CLEAN + 1
UNSTABLE if a CI run hasn't quite finished — wait 2 minutes then
re-check).

## Merge the queue (~3-5 minutes)

```bash
gh pr list --state open --limit 200 --json number,mergeStateStatus \
  --jq '.[] | select(.mergeStateStatus=="CLEAN") | .number' \
  | sort -n \
  | while read n; do
      echo "=== PR #$n ==="
      gh pr merge "$n" --squash --delete-branch || { echo "STOPPED at #$n"; break; }
    done

git checkout main && git pull --ff-only origin main
```

- Oldest PR first (chronological → auditor friendly).
- `|| break` stops at the first failure for inspection.
- Each PR is squash-merged + remote branch deleted.

## Post-merge verification (~2 minutes)

```bash
# Full analyze on main.
flutter analyze 2>&1 | tail -20

# Full test suite.
flutter test 2>&1 | tail -10

# Confirm no open PR queue left.
gh pr list --state open --limit 5
```

Expected:
- `flutter analyze` → `No issues found!`
- `flutter test` → all green; aggregate test count jumps by roughly
  **+870 invariant tests** (sum across all 79 PRs).
- `gh pr list` → empty (or only PRs you opened *after* the merge).

## If something fails

**Single PR rejected** (e.g. CI flaked since the snapshot): re-trigger
the failing job in GitHub Actions, wait, then rerun the loop — it
will resume at the failed number because earlier PRs are already
merged.

**`flutter analyze` red after merge**: highly unlikely (zero
cross-catalog enum/class collisions verified in pre-flight audit
2026-06-28). If it happens:
```bash
flutter analyze 2>&1 | grep error
```
The error will name the file. Most likely cause is a stale local
branch; `git reset --hard origin/main` and re-run.

**`flutter test` regression**: every catalog ships with its own
invariant-test file. A regression would name the specific catalog;
revert just that single squash commit (`git revert <sha>`) and
re-investigate.

## What you get out of it

77 new pinned policy catalogs covering:
- **AI governance** (L1-L12): output guard, jailbreak patterns,
  PHI scrub, hallucination warning, clinician override audit, model
  card, training-data taxonomy, usage budget.
- **Compliance** (K7, K8, K9, K10, K11, K12, K13, K14, K15, K16,
  K17): data classification, subject rights, cookies, responsible
  disclosure, consent withdrawal cascade, cross-border transfer,
  identity verification, DPIA trigger, retention class, lawful
  basis, DSAR deadline.
- **Security** (N1-N27): SLO, training, alerting, change mgmt,
  pen-test findings, secret rotation, session timeout, DR drill,
  supply chain, vendor risk, key rotation, pen-test scope,
  DR RPO/RTO, AAL, security headers, API rate limit, SRI,
  CORS allowlist.
- **Data + ops** (O1, O3, O4, O5, O6, O7, O8, O9, O10): activation
  funnel, outcome measures, pricing tiers, analytics events,
  feature flags, deployment environments, tenant isolation,
  required env vars, scheduled jobs.
- **Marketing + ops** (M2, M3, M4, M5, M6): incident comms,
  support escalation, status-page components, launch comms,
  audience tier.
- **Clinical** (J3, J5): audit-log Firestore mirror, crisis
  trigger thresholds.

Every catalog enforces invariants in tests (regulatory anchor,
monotonic ladders, enum-coverage gaps) — adding a new enum value
without a corresponding catalog entry fails the build.

## After merge — recommended next steps

1. **Trust center wiring**: the trust-center page can now consume
   each catalog directly (e.g. `lastReviewed` fields drive the
   "needs review" badge).
2. **Middleware wire-up**: catalogs are policy tables; the actual
   middleware that reads them (rate-limit interceptor, CORS gate,
   security-header emitter, scheduled-job runner) ships in
   follow-up PRs that import these catalogs.
3. **Auditor brief**: `docs/handoff/CATALOG-INDEX.md` summarises
   every catalog + its regulatory anchors in one page for SOC 2 /
   ISO 27001 / HIPAA evidence packs.
