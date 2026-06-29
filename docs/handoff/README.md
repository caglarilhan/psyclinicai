# Handoff — what to do

This folder is the delivery pack for the 79-PR pinned-catalog
sprint. Three files, in the order you'll use them.

## 1. `MERGE-RUNBOOK.md`

Step-by-step: pre-flight check, the merge loop, post-merge
verification, what to do if any step fails. Read this first.

## 2. `merge-all-clean.sh`

The runbook compressed into a single executable. From the repo root:

```bash
bash docs/handoff/merge-all-clean.sh
```

It will:
- pull main,
- merge every CLEAN open PR oldest-first (squash + delete branch),
- pull main again,
- run `flutter analyze` + `flutter test`,
- list any remaining open PRs.

Safe to rerun — already-merged PRs are skipped.

## 3. `CATALOG-INDEX.md`

Auditor brief. One row per catalog with id, PR number, and
regulatory anchors. Hand this to a SOC 2 / ISO 27001 / HIPAA / GDPR
auditor as the entry point to evidence pack.

## Why this layout

- The runbook explains the *why* and the safety rails.
- The script is the *how* for users who just want to run it.
- The index is the *what* for users who only need to know what
  shipped, not how.

Auditor sees only `CATALOG-INDEX.md`. Operator runs only
`merge-all-clean.sh`. Future engineer onboards by reading the
runbook.
