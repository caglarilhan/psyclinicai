/**
 * J2 — unit tests for the client-chain verifier.
 *
 * The Cloud Function in production walks `clinic_audit_logs` and
 * pages on chain corruption. These tests pin the pure verifier
 * helpers (clientCanonicalise / computeClientChainHash /
 * verifyClientChainSlice) PLUS the runChainVerify orchestrator
 * with a stub `fetchRows` so we don't need to boot admin SDK.
 */
import {createHash} from "crypto";

import {runChainVerify, ChainVerifyRun} from "../audit_chain_verify";
import {
  AuditChainRow,
  CLIENT_GENESIS_PREV_HASH,
  clientCanonicalise,
  computeClientChainHash,
  verifyClientChainSlice,
} from "../lib/audit_chain";

function rowOf(
  id: string,
  ts: string,
  extra: Partial<AuditChainRow> = {},
): AuditChainRow {
  return {
    id,
    kind: "consent",
    action: "kvkk.consent_granted",
    actor: "pat-1",
    entity: `patient:pat-1 entry:ce-${id} policy:2026-06`,
    timestamp_utc: ts,
    result: "success",
    ...extra,
  };
}

function sealChain(rows: AuditChainRow[]): AuditChainRow[] {
  let prev = CLIENT_GENESIS_PREV_HASH;
  const sealed: AuditChainRow[] = [];
  for (const r of rows) {
    const h = computeClientChainHash(r, prev);
    sealed.push({...r, hash: h});
    prev = h;
  }
  return sealed;
}

describe("clientCanonicalise", () => {
  it("emits keys in Dart toJson insertion order", () => {
    const row = rowOf("e1", "2026-06-25T12:00:00.000Z");
    const canon = clientCanonicalise(row);
    // The exact JSON string is the contract — drift breaks every
    // mirrored chain.
    expect(canon).toEqual(
      `{"id":"e1","kind":"consent","action":"kvkk.consent_granted",` +
        `"actor":"pat-1","entity":"patient:pat-1 entry:ce-e1 policy:2026-06",` +
        `"timestamp_utc":"2026-06-25T12:00:00.000Z","result":"success"}`,
    );
  });

  it("omits null/undefined optional fields", () => {
    const row = rowOf("e1", "2026-06-25T12:00:00.000Z", {
      user_id: null,
      ip: undefined,
      device: null,
    });
    const canon = clientCanonicalise(row);
    expect(canon).not.toContain("user_id");
    expect(canon).not.toContain("ip");
    expect(canon).not.toContain("device");
  });

  it("appends optional fields in insertion order when present", () => {
    const row = rowOf("e1", "2026-06-25T12:00:00.000Z", {
      user_id: "uid-1",
      ip: "203.0.113.5",
      device: "iphone-15-pro",
    });
    const canon = clientCanonicalise(row);
    const userIdx = canon.indexOf("user_id");
    const ipIdx = canon.indexOf('"ip"');
    const deviceIdx = canon.indexOf("device");
    expect(userIdx).toBeGreaterThan(0);
    expect(ipIdx).toBeGreaterThan(userIdx);
    expect(deviceIdx).toBeGreaterThan(ipIdx);
  });
});

describe("computeClientChainHash", () => {
  it("matches sha256(prev + clientCanonicalise(row))", () => {
    const row = rowOf("e1", "2026-06-25T12:00:00.000Z");
    const expected = createHash("sha256")
      .update("prev123" + clientCanonicalise(row))
      .digest("hex");
    expect(computeClientChainHash(row, "prev123")).toEqual(expected);
  });

  it("genesis hash uses empty prev — matches Dart writer", () => {
    const row = rowOf("e1", "2026-06-25T12:00:00.000Z");
    const expected = createHash("sha256")
      .update("" + clientCanonicalise(row))
      .digest("hex");
    expect(computeClientChainHash(row, CLIENT_GENESIS_PREV_HASH)).toEqual(
      expected,
    );
  });
});

describe("verifyClientChainSlice", () => {
  it("returns ok for a properly sealed chain", () => {
    const sealed = sealChain([
      rowOf("e1", "2026-06-25T12:00:00.000Z"),
      rowOf("e2", "2026-06-25T12:01:00.000Z"),
      rowOf("e3", "2026-06-25T12:02:00.000Z"),
    ]);
    const v = verifyClientChainSlice(sealed);
    expect(v.ok).toBe(true);
    expect(v.rowsChecked).toBe(3);
    expect(v.firstBadIndex).toBe(-1);
  });

  it("detects a tampered hash at the first broken row", () => {
    const sealed = sealChain([
      rowOf("e1", "2026-06-25T12:00:00.000Z"),
      rowOf("e2", "2026-06-25T12:01:00.000Z"),
      rowOf("e3", "2026-06-25T12:02:00.000Z"),
    ]);
    // Tamper row 1's hash to a plausible but wrong sha256.
    sealed[1] = {...sealed[1], hash: "f".repeat(64)};
    const v = verifyClientChainSlice(sealed);
    expect(v.ok).toBe(false);
    expect(v.firstBadIndex).toBe(1);
    expect(v.reason).toContain("e2");
  });

  it("treats a missing hash on the mirror as corruption", () => {
    const sealed = sealChain([
      rowOf("e1", "2026-06-25T12:00:00.000Z"),
      rowOf("e2", "2026-06-25T12:01:00.000Z"),
    ]);
    sealed[1] = {...sealed[1], hash: undefined};
    const v = verifyClientChainSlice(sealed);
    expect(v.ok).toBe(false);
    expect(v.firstBadIndex).toBe(1);
    expect(v.reason).toContain("missing hash");
  });

  it("detects a row reordering attack (row 1 and 2 swapped)", () => {
    const sealed = sealChain([
      rowOf("e1", "2026-06-25T12:00:00.000Z"),
      rowOf("e2", "2026-06-25T12:01:00.000Z"),
      rowOf("e3", "2026-06-25T12:02:00.000Z"),
    ]);
    const reordered = [sealed[0], sealed[2], sealed[1]];
    const v = verifyClientChainSlice(reordered);
    expect(v.ok).toBe(false);
  });
});

describe("runChainVerify", () => {
  const stubDb = {} as never;

  it("clean chain across multiple clinics → all clean", async () => {
    const fetchRows = async (
      _db: unknown,
      clinicId: string,
    ): Promise<AuditChainRow[]> => {
      if (clinicId === "clinic-a") {
        return sealChain([
          rowOf("e1", "2026-06-25T12:00:00.000Z"),
          rowOf("e2", "2026-06-25T12:01:00.000Z"),
        ]);
      }
      return sealChain([rowOf("e1", "2026-06-25T13:00:00.000Z")]);
    };
    const run: ChainVerifyRun = await runChainVerify(
      stubDb,
      ["clinic-a", "clinic-b"],
      fetchRows as never,
    );
    expect(run.clinicsChecked).toBe(2);
    expect(run.clinicsClean).toBe(2);
    expect(run.clinicsCorrupt).toBe(0);
    expect(run.clinicsEmpty).toBe(0);
  });

  it("empty clinic → ok with reason 'empty_chain'", async () => {
    const fetchRows = async (): Promise<AuditChainRow[]> => [];
    const run = await runChainVerify(stubDb, ["clinic-x"], fetchRows as never);
    expect(run.clinicsEmpty).toBe(1);
    expect(run.results["clinic-x"].ok).toBe(true);
    expect(run.results["clinic-x"].reason).toBe("empty_chain");
  });

  it("one corrupt clinic does NOT stop verification of the others", async () => {
    const fetchRows = async (
      _db: unknown,
      clinicId: string,
    ): Promise<AuditChainRow[]> => {
      if (clinicId === "clinic-bad") {
        const sealed = sealChain([
          rowOf("e1", "2026-06-25T12:00:00.000Z"),
          rowOf("e2", "2026-06-25T12:01:00.000Z"),
        ]);
        sealed[0] = {...sealed[0], hash: "0".repeat(64)};
        return sealed;
      }
      return sealChain([rowOf("e1", "2026-06-25T13:00:00.000Z")]);
    };
    const run = await runChainVerify(
      stubDb,
      ["clinic-bad", "clinic-good"],
      fetchRows as never,
    );
    expect(run.clinicsChecked).toBe(2);
    expect(run.clinicsCorrupt).toBe(1);
    expect(run.clinicsClean).toBe(1);
    expect(run.results["clinic-bad"].ok).toBe(false);
    expect(run.results["clinic-good"].ok).toBe(true);
  });

  it("fetch failure for a clinic is reported, others continue", async () => {
    const fetchRows = async (
      _db: unknown,
      clinicId: string,
    ): Promise<AuditChainRow[]> => {
      if (clinicId === "clinic-net-fail") {
        throw new Error("network_down");
      }
      return sealChain([rowOf("e1", "2026-06-25T13:00:00.000Z")]);
    };
    const run = await runChainVerify(
      stubDb,
      ["clinic-net-fail", "clinic-ok"],
      fetchRows as never,
    );
    expect(run.results["clinic-net-fail"].ok).toBe(false);
    expect(run.results["clinic-net-fail"].reason).toContain("fetch_failed");
    expect(run.results["clinic-ok"].ok).toBe(true);
  });
});
