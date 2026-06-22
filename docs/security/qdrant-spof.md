# Qdrant SPOF — migration plan

**Status:** open, tracked from `docs/security/threat-model.md` § 5
**Owner:** rag-architect + senior-devops
**Target:** Sprint 31

The vector store currently runs as a single Qdrant container on the
Hetzner CX22 host. Disk failure or container corruption costs the full
vector index until the next weekly snapshot restores it (RPO ≤ 7 d,
RTO ≤ 6 h per `docs/STATUS.md` §DR). For Wave A pilots this is
acceptable; before public launch it is not.

---

## 1. Failure modes

| Mode | Likelihood (CX22, EU) | Blast radius |
|---|---|---|
| Disk failure on host | Low (1 / yr / fleet) | Full vector loss until restore |
| Container OOM during ingest | Medium | Service degraded, no loss |
| Qdrant binary corruption on upgrade | Low | Service degraded, snapshot restore |
| Misclick during operator session | Medium | Full vector loss until restore |

## 2. Decision criteria

We will migrate when **any one** of:

- A second pilot region requires < 6 h RTO (today's plan can't promise it).
- Pentest finds a vector-store specific vulnerability (e.g., CVE on the
  Qdrant version pinned in `docker-compose.yml`).
- Storage exceeds 4 GB (CX22 cannot host that comfortably alongside
  Postgres + Ollama-class memory).
- A customer contract requires a vendor SOC 2 letter for the vector
  store.

## 3. Options (compared)

| Option | Cost / mo | RTO | Pros | Cons |
|---|---|---|---|---|
| **Status quo** — single CX22 Qdrant + weekly restic | €0 add | 6 h | Free, simple | RPO ≤ 7 d |
| **Daily snapshot to Storage Box** | €0 add | 4 h | Same model, tighter RPO | Still SPOF compute |
| **CX42 with replicated Qdrant cluster (3 nodes)** | ~€36 | 1 h | Self-hosted, EU residency | Operator burden up |
| **Qdrant Cloud (EU)** | ~$25 starter | 30 m | Managed, vendor SOC 2 | One more subprocessor |
| **Migrate vectors into Postgres pgvector** | €0 add | <30 m | One fewer system | bge-m3 retrieval slower |

## 4. Recommendation

**Sprint 31 — daily snapshot to Storage Box** (Option 2) — ✅ **shipped**.
`ragsvc-backup.timer` now fires `OnCalendar=*-*-* 03:00:00 UTC`
(was Sunday weekly). Zero new subprocessors, RPO tightens 7 d → 1 d.

**Sprint 33 — Qdrant Cloud EU** (Option 4) once a paying customer
requires < 1 h RTO. Updates `docs/legal/SUBPROCESSORS.md` § 2.

Option 5 (pgvector) is on the radar only if Qdrant licensing or
governance becomes a blocker — bge-m3 in pgvector is workable but
needs new ANN index tuning.

## 5. Migration playbook (Option 4, Sprint 33)

1. Provision Qdrant Cloud EU cluster, copy API key into
   `/opt/rag-service/.env`.
2. Update `psyrag/backend/rag.py` `QDRANT_URL` to the cloud endpoint.
3. Run `scripts/migrate_vectors.py --source local --dest cloud` (script
   not yet written; baseline TODO ticket created in Linear).
4. Smoke 10 eval vignettes against the cloud cluster.
5. Cut DNS / env in a single commit; revert path is `QDRANT_URL=http://qdrant:6333`.
6. Decommission local Qdrant container after 14 d soak.
7. Update `docs/legal/SUBPROCESSORS.md` + customer DPA notice
   30 days ahead per the Annex II contract.

## 6. Watch list

- Qdrant CVE feed: https://github.com/qdrant/qdrant/security/advisories
- Storage usage alarm: `qdrant_data_size_bytes > 3.5 GB` for the CX22 case.
- Daily snapshot success metric in Grafana (`ragsvc_qdrant_snapshot_age_seconds`).
