#!/usr/bin/env bash
# Sprint 31 — quarterly SOC 2 evidence snapshot.
#
# Drops into `docs/security/evidence/${QUARTER}/soc2/` the auto-
# refreshable artefacts the auditor expects. Manual rows (CC1.5 team
# roster, CC2.3 contracts) are flagged in MANUAL_TODO.md for the
# ciso-advisor to fill in by hand.
#
# Cron-friendly: idempotent, never modifies prior quarter dirs.
#
# Usage:
#   bash scripts/collect-soc2-evidence.sh             # auto-detect quarter
#   QUARTER=2026q3 bash scripts/collect-soc2-evidence.sh   # explicit

set -euo pipefail

cd "$(dirname "$0")/.."

QUARTER="${QUARTER:-$(date -u +%Y)q$(((`date -u +%-m`-1)/3+1))}"
OUT_DIR="docs/security/evidence/${QUARTER}/soc2"
mkdir -p "$OUT_DIR"

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "[soc2 $NOW] starting evidence collection for quarter=${QUARTER}"

# ───────────────────────────────────────────────────────────────────
# CC8.1 — change management: list PRs merged this quarter.
# ───────────────────────────────────────────────────────────────────
if command -v gh >/dev/null; then
    gh pr list --state merged --limit 200 --json number,title,mergedAt,author \
        > "${OUT_DIR}/CC8.1-pr-history.json" 2>/dev/null \
        || echo '[]' > "${OUT_DIR}/CC8.1-pr-history.json"
else
    git log --since="3 months ago" --pretty=format:'%h|%ad|%an|%s' \
        --date=iso > "${OUT_DIR}/CC8.1-commit-history.txt"
fi

# ───────────────────────────────────────────────────────────────────
# CC7.5 — recovery: copy the most recent restore-drill log if
# available locally (operator typically copies this from the hub
# `/opt/rag-backups/last-restore-drill.log`).
# ───────────────────────────────────────────────────────────────────
if [ -f "/opt/rag-backups/last-restore-drill.log" ]; then
    cp "/opt/rag-backups/last-restore-drill.log" \
        "${OUT_DIR}/CC7.5-last-restore-drill.log"
else
    cat > "${OUT_DIR}/CC7.5-last-restore-drill.MANUAL.md" <<EOM
# CC7.5 — restore drill log not present on this host.
# Fetch via: scp ragsvc@46.225.181.130:/opt/rag-backups/last-restore-drill.log .
EOM
fi

# ───────────────────────────────────────────────────────────────────
# CC6.7 — TLS rating placeholder.
# ───────────────────────────────────────────────────────────────────
cat > "${OUT_DIR}/CC6.7-ssl-labs-rating.MANUAL.md" <<'EOF'
# CC6.7 — TLS rating

Run from any browser and save the SSL Labs report HTML:
  https://www.ssllabs.com/ssltest/analyze.html?d=psyclinicai.com
  https://www.ssllabs.com/ssltest/analyze.html?d=rag.psyclinicai.com

Both should be A+ before audit period close.
EOF

# ───────────────────────────────────────────────────────────────────
# CC4.2 — access-review cron output. accessReviewCron writes a
# Firestore doc under access_review_snapshots/{YYYY-Qn} that we
# export here via the Firebase CLI.
# ───────────────────────────────────────────────────────────────────
if command -v firebase >/dev/null; then
    firebase firestore:export \
        "gs://psyclinicai-soc2-exports/${QUARTER}" \
        --collection-ids access_review_snapshots \
        > "${OUT_DIR}/CC4.2-export.log" 2>&1 || true
else
    cat > "${OUT_DIR}/CC4.2-access-review.MANUAL.md" <<'EOF'
# CC4.2 — access review snapshot

firebase CLI not available on this host. From a workstation with
`firebase login` complete, run:

  firebase firestore:export gs://psyclinicai-soc2-exports/${QUARTER} \
      --collection-ids access_review_snapshots --project psyclinicai
EOF
fi

# ───────────────────────────────────────────────────────────────────
# CC1.1 — training-completion placeholder (manual).
# ───────────────────────────────────────────────────────────────────
cat > "${OUT_DIR}/CC1.1-training-completion.MANUAL.md" <<'EOF'
# CC1.1 — workforce training completion

Maintain `docs/security/evidence/workforce-training/${QUARTER}.csv`
with columns:

  trainee_id, role, module_id, completion_date, evidence_url, reviewer_id

Auditor receives a redacted copy with trainee_id SHA-256 prefixed.
EOF

# ───────────────────────────────────────────────────────────────────
# Manual TODO file — appears at top of the dir so the ciso-advisor
# never misses it.
# ───────────────────────────────────────────────────────────────────
cat > "${OUT_DIR}/MANUAL_TODO.md" <<EOF
# Manual evidence — quarter ${QUARTER}

Owner: ciso-advisor@psyclinicai.com

The auto-collect script seeded this dir on ${NOW}. The rows below
still need the operator's hand-off:

- [ ] CC1.5 team roster screenshot (Slack \`#team\`).
- [ ] CC2.3 customer contract vault — every BAA/DPA up to date.
- [ ] CC3.4 vendor risk audit — \`docs/legal/SUBPROCESSORS.md\` vs DPAs.
- [ ] CC4.1 Grafana dashboard screenshot.
- [ ] CC6.7 SSL Labs rating (see \`CC6.7-ssl-labs-rating.MANUAL.md\`).
- [ ] CC7.4 threat-model walkthrough minute with sec-team.
- [ ] CC1.1 training-completion CSV (see \`CC1.1-training-completion.MANUAL.md\`).

When complete, append a row to
\`docs/security/evidence/soc2/audit-trail.csv\`:
\`quarter, ciso_reviewer_id, completed_at_iso, notes_md_path\`.
EOF

echo "[soc2 $NOW] OK — quarter=${QUARTER} dir=${OUT_DIR}"
