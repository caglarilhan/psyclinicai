/**
 * E2 — integration coverage for the audit_retention_purge cron's
 * inner loop (`runRetentionPurge`). Builds a tiny in-memory
 * Firestore stand-in so we can run the whole pseudonymise + chain-
 * verify + self-audit flow without booting the Cloud Functions
 * emulator.
 *
 * What's pinned:
 *   - HIPAA §164.316(b) 6-year window respected: fresh rows stay,
 *     rows older than 6y get pseudonymised.
 *   - Pseudonymise payload merges over original docs (id / kind /
 *     timestamp_utc / hash / user_id stay; actor / entity / ip /
 *     device get blanked, purged=true).
 *   - Tampered batches are skipped (NOT pseudonymised) so the
 *     evidence chain survives.
 *   - A `retention.purge_run` self-audit row is appended with the
 *     correct success / failure verdict + counts in `entity`.
 */
jest.mock("firebase-admin", () => {
  const FieldValue = {
    serverTimestamp: () => "__SERVER_TS__",
  };
  const Timestamp = {
    fromDate: (d: Date) => ({
      __ts: d.toISOString(),
      toDate: () => d,
      toMillis: () => d.getTime(),
    }),
  };
  return {
    firestore: Object.assign(() => ({}), {FieldValue, Timestamp}),
  };
});

import {
  computeChainHash,
  GENESIS_PREV_HASH,
} from "../lib/audit_chain";
import {
  RetentionPurgeResult,
  runRetentionPurge,
} from "../audit_retention_purge";

interface StubDoc {
  id: string;
  data: Record<string, unknown>;
}

interface StubResult {
  db: import("firebase-admin").firestore.Firestore;
  addedRows: Array<Record<string, unknown>>;
  remaining: StubDoc[];
}

function makeDb(rows: StubDoc[]): StubResult {
  const collectionRows = [...rows];
  const added: Array<Record<string, unknown>> = [];

  function fakeBatch() {
    const ops: Array<{ref: {id: string}; data: Record<string, unknown>}> = [];
    return {
      update: (ref: {id: string}, data: Record<string, unknown>) => {
        ops.push({ref, data});
      },
      commit: async () => {
        for (const op of ops) {
          const idx = collectionRows.findIndex((r) => r.id === op.ref.id);
          if (idx >= 0) {
            collectionRows[idx] = {
              ...collectionRows[idx],
              data: {...collectionRows[idx].data, ...op.data},
            };
          }
        }
      },
    };
  }

  function buildSnap(rs: StubDoc[], limit: number, cursor: StubDoc | null) {
    let start = 0;
    if (cursor) {
      start = rs.findIndex((r) => r.id === cursor.id) + 1;
    }
    const slice = rs.slice(start, start + limit);
    return {
      empty: slice.length === 0,
      size: slice.length,
      docs: slice.map((r) => ({
        id: r.id,
        ref: {id: r.id},
        data: () => r.data,
      })),
    };
  }

  const db = {
    collection: (_name: string) => ({
      add: async (data: Record<string, unknown>) => {
        added.push(data);
        return {id: `added-${added.length}`};
      },
      where: (_field: string, _op: string, cutoffTs: {toDate: () => Date}) => {
        let cursor: StubDoc | null = null;
        const cutoff = cutoffTs.toDate();
        const matching = collectionRows
          .filter((r) => {
            const ts = r.data.timestamp_utc as {toDate: () => Date};
            return ts.toDate().getTime() < cutoff.getTime();
          })
          .sort((a, b) => {
            const at = (a.data.timestamp_utc as {toDate: () => Date})
              .toDate()
              .getTime();
            const bt = (b.data.timestamp_utc as {toDate: () => Date})
              .toDate()
              .getTime();
            return at - bt;
          });
        const query = {
          orderBy: () => query,
          limit: (n: number) => ({
            startAfter: (c: StubDoc) => {
              cursor = c;
              return {
                get: async () => buildSnap(matching, n, cursor),
              };
            },
            get: async () => buildSnap(matching, n, cursor),
          }),
        };
        return query;
      },
    }),
    batch: fakeBatch,
  } as unknown as import("firebase-admin").firestore.Firestore;

  return {db, addedRows: added, remaining: collectionRows};
}

function row(
  id: string,
  ageDays: number,
  now: Date,
  overrides: Record<string, unknown> = {},
): StubDoc {
  const at = new Date(now.getTime() - ageDays * 24 * 60 * 60 * 1000);
  return {
    id,
    data: {
      kind: "phi_access",
      action: "patient.read",
      actor: "uid-1",
      entity: `patient:p${id}`,
      timestamp_utc: {
        toDate: () => at,
        toMillis: () => at.getTime(),
      },
      result: "success",
      // Legacy / pre-chain rows: hash absent → verifier skips them and
      // the cron pseudonymises normally. Lets the test focus on the
      // retention math without re-implementing the SHA-256 chain.
      hash: null,
      prev_hash: null,
      ip: "10.0.0.1",
      device: "macbook",
      ...overrides,
    },
  };
}

describe("runRetentionPurge", () => {
  const now = new Date(Date.UTC(2026, 5, 25)); // 2026-06-25
  const sixYearsDays = 6 * 365 + 2; // ~6 years + buffer

  it("no-op when audit_logs is empty (still writes self-audit)", async () => {
    const {db, addedRows} = makeDb([]);
    const result = await runRetentionPurge(db, now);
    expect(result.purged).toBe(0);
    expect(result.failed).toBe(0);
    expect(result.tampered_skipped).toBe(0);
    expect(addedRows).toHaveLength(1);
    expect(addedRows[0].action).toBe("retention.purge_run");
    expect(addedRows[0].result).toBe("success");
    expect(addedRows[0].entity).toContain("purged=0");
  });

  it("does not touch rows younger than 6 years", async () => {
    const fresh = [row("0", 30, now), row("1", 365, now), row("2", 1000, now)];
    const {db, addedRows, remaining} = makeDb(fresh);
    const result = await runRetentionPurge(db, now);
    expect(result.purged).toBe(0);
    for (const r of remaining.slice(0, 3)) {
      expect(r.data.purged).toBeUndefined();
      expect(r.data.entity).toContain("patient:p");
    }
    expect(addedRows[0].entity).toContain("purged=0");
  });

  it("pseudonymises rows older than 6 years + keeps the chain fields", async () => {
    const oldRow = row("0", sixYearsDays, now);
    const {db, addedRows, remaining} = makeDb([oldRow]);
    const result = await runRetentionPurge(db, now);
    expect(result.purged).toBe(1);
    expect(addedRows[0].result).toBe("success");

    const after = remaining[0].data;
    expect(after.actor).toBeNull();
    expect(after.entity).toBe("__purged__");
    expect(after.ip).toBeNull();
    expect(after.device).toBeNull();
    expect(after.purged).toBe(true);
    expect(after.kind).toBe("phi_access");
    // Legacy fixture uses hash=null; the pseudonymise merge must
    // leave the field exactly as it was (don't overwrite the chain
    // anchor for rows that have one in production).
    expect(after.hash).toBeNull();
    expect(after.timestamp_utc).toBeDefined();
  });

  it("mix: old + fresh — only the old rows pseudonymise", async () => {
    const mix = [
      row("0", sixYearsDays + 5, now),
      row("1", sixYearsDays + 2, now),
      row("2", 30, now),
      row("3", 60, now),
    ];
    const {db, addedRows, remaining} = makeDb(mix);
    const result = await runRetentionPurge(db, now);
    expect(result.purged).toBe(2);
    const byId = Object.fromEntries(remaining.map((r) => [r.id, r.data]));
    expect(byId["0"].entity).toBe("__purged__");
    expect(byId["1"].entity).toBe("__purged__");
    expect(byId["2"].entity).toContain("patient:p2");
    expect(byId["3"].entity).toContain("patient:p3");
    expect(addedRows[0].entity).toContain("purged=2");
  });

  it("emits a failure self-audit when the chain is tampered", async () => {
    // Build a real chain: row0.hash = H(GENESIS | row0); row1.hash =
    // H(row0.hash | row1). Then tamper row1's stored hash so the
    // verifier rejects the batch and the cron skips the pseudonymise.
    const r0 = row("0", sixYearsDays + 1, now, {hash: null, prev_hash: null});
    const r1 = row("1", sixYearsDays, now, {hash: null, prev_hash: null});
    const r0Chain = {
      id: r0.id,
      kind: r0.data.kind as string,
      action: r0.data.action as string,
      actor: r0.data.actor as string,
      entity: r0.data.entity as string,
      timestamp_utc: (
        r0.data.timestamp_utc as {toDate: () => Date}
      ).toDate().toISOString(),
      result: r0.data.result as string,
      ip: r0.data.ip as string,
      device: r0.data.device as string,
    };
    const r0Hash = computeChainHash(r0Chain, GENESIS_PREV_HASH);
    r0.data.hash = r0Hash;
    r0.data.prev_hash = GENESIS_PREV_HASH;
    // r1 stored hash is intentionally wrong → tamper detected.
    r1.data.hash = "TAMPERED-HASH-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    r1.data.prev_hash = r0Hash;

    const {db, addedRows, remaining} = makeDb([r0, r1]);
    const result = await runRetentionPurge(db, now);
    expect(result.tampered_skipped).toBeGreaterThan(0);
    expect(result.purged).toBe(0);
    // Rows survive untouched so the operator can rebuild from cold
    // storage / Sentinel snapshots.
    expect(remaining[0].data.entity).toContain("patient:p0");
    expect(remaining[1].data.entity).toContain("patient:p1");
    expect(addedRows[0].result).toBe("failure");
    expect(addedRows[0].entity).toContain("tampered_skipped=");
  });
});

// Keep the imported type referenced so a future refactor that drops
// the export trips a compile error in this file.
const _typeWitness: RetentionPurgeResult | undefined = undefined;
void _typeWitness;
