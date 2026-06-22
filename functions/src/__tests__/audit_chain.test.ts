import {
  AuditChainRow,
  GENESIS_PREV_HASH,
  canonicalise,
  computeChainHash,
  verifyChainSlice,
} from "../lib/audit_chain";

function row(
  patch: Partial<AuditChainRow> & {id: string; timestamp_utc: string},
): AuditChainRow {
  return {
    kind: "read",
    action: "patient.view",
    actor: "clinician_a@psy.test",
    entity: "patient/synthetic_1",
    result: "success",
    ...patch,
  };
}

describe("canonicalise (deterministic + sorted)", () => {
  it("emits keys in lexicographic order regardless of input order", () => {
    const a = canonicalise(row({id: "1", timestamp_utc: "2026-06-16T12:00:00Z"}));
    const b = canonicalise({
      result: "success",
      kind: "read",
      action: "patient.view",
      entity: "patient/synthetic_1",
      id: "1",
      timestamp_utc: "2026-06-16T12:00:00Z",
      actor: "clinician_a@psy.test",
    });
    expect(a).toBe(b);
  });

  it("omits null / undefined optional fields (no drift)", () => {
    const a = canonicalise(row({id: "1", timestamp_utc: "t", ip: null}));
    const b = canonicalise(row({id: "1", timestamp_utc: "t"}));
    expect(a).toBe(b);
    expect(a.includes("ip")).toBe(false);
  });
});

describe("verifyChainSlice (Sprint 27 F-008)", () => {
  it("accepts a chain built with computeChainHash", () => {
    const r1 = row({id: "1", timestamp_utc: "2026-06-16T12:00:00Z"});
    const h1 = computeChainHash(r1, GENESIS_PREV_HASH);
    const r2 = row({id: "2", timestamp_utc: "2026-06-16T12:05:00Z"});
    const h2 = computeChainHash(r2, h1);
    const rows = [
      {...r1, hash: h1},
      {...r2, hash: h2},
    ];
    const res = verifyChainSlice(rows);
    expect(res.ok).toBe(true);
    expect(res.rowsChecked).toBe(2);
    expect(res.firstBadIndex).toBe(-1);
  });

  it("flags a single-row mutation and stops at first bad index", () => {
    const r1 = row({id: "1", timestamp_utc: "2026-06-16T12:00:00Z"});
    const h1 = computeChainHash(r1, GENESIS_PREV_HASH);
    const r2 = row({id: "2", timestamp_utc: "2026-06-16T12:05:00Z"});
    const h2 = computeChainHash(r2, h1);
    const rows = [
      {...r1, hash: h1},
      {...r2, action: "patient.export.full_chart", hash: h2},
    ];
    const res = verifyChainSlice(rows);
    expect(res.ok).toBe(false);
    expect(res.firstBadIndex).toBe(1);
    expect(res.reason).toMatch(/^row id=2/);
  });

  it("skips legacy rows without a hash but still validates later rows", () => {
    const r1 = row({id: "1", timestamp_utc: "t1"});
    const r2 = row({id: "2", timestamp_utc: "t2"});
    const h2 = computeChainHash(r2, GENESIS_PREV_HASH);
    const res = verifyChainSlice([
      {...r1},
      {...r2, hash: h2},
    ]);
    expect(res.ok).toBe(true);
    expect(res.rowsChecked).toBe(1);
  });

  it("chaos: reordering two adjacent rows breaks the chain", () => {
    const r1 = row({id: "1", timestamp_utc: "2026-06-16T12:00:00Z"});
    const h1 = computeChainHash(r1, GENESIS_PREV_HASH);
    const r2 = row({id: "2", timestamp_utc: "2026-06-16T12:05:00Z"});
    const h2 = computeChainHash(r2, h1);
    const res = verifyChainSlice([
      {...r2, hash: h2},
      {...r1, hash: h1},
    ]);
    expect(res.ok).toBe(false);
    expect(res.firstBadIndex).toBe(0);
  });
});
