/**
 * Tamper-evident audit log — chain verifier.
 *
 * Sprint 27 / F-008 close. The `audit_logs` collection is append-only
 * and each row carries a SHA-256 `hash` derived from the canonical
 * JSON of the row (without the `hash` field itself) concatenated
 * with the previous row's hash. The Trust Center page already runs
 * this check on demand; from Sprint 27 the quarterly access-review
 * cron also runs it at the start of each schedule fire, so a silent
 * mid-quarter chain corruption surfaces within at most three months.
 *
 * Pure helpers — easy to unit-test, no Firebase imports.
 */
import {createHash} from "crypto";

export interface AuditChainRow {
  id: string;
  kind: string;
  action: string;
  actor: string;
  entity: string;
  /** ISO-8601 UTC string in the on-disk schema. */
  timestamp_utc: string;
  result: string;
  user_id?: string | null;
  ip?: string | null;
  device?: string | null;
  /** Stored chain hash (hex). `null`/`undefined` for legacy rows. */
  hash?: string | null;
}

export const GENESIS_PREV_HASH = "GENESIS";

/**
 * Stable canonical serialisation of a row, excluding the `hash`
 * field itself. Keys are sorted lexicographically; `null`/`undefined`
 * optional fields are omitted so they cannot drift between writer
 * and verifier (a stray `null` vs absent field would otherwise
 * yield two different canonical strings).
 */
export function canonicalise(row: AuditChainRow): string {
  const ordered: Array<[string, unknown]> = [];
  const push = (k: string, v: unknown) => {
    if (v === null || v === undefined) return;
    ordered.push([k, v]);
  };
  push("action", row.action);
  push("actor", row.actor);
  push("device", row.device);
  push("entity", row.entity);
  push("id", row.id);
  push("ip", row.ip);
  push("kind", row.kind);
  push("result", row.result);
  push("timestamp_utc", row.timestamp_utc);
  push("user_id", row.user_id);
  const obj: Record<string, unknown> = {};
  for (const [k, v] of ordered) obj[k] = v;
  return JSON.stringify(obj);
}

/** SHA-256(prev || canonical(row)), lowercase hex. */
export function computeChainHash(row: AuditChainRow, prevHash: string): string {
  const payload = `${prevHash}|${canonicalise(row)}`;
  return createHash("sha256").update(payload).digest("hex");
}

export interface VerifyResult {
  ok: boolean;
  rowsChecked: number;
  /** Index of the first row where the chain breaks, or -1. */
  firstBadIndex: number;
  /** Reason string — empty when `ok`. */
  reason: string;
}

/**
 * Walk an ordered slice of audit rows and confirm each row's stored
 * `hash` matches `computeChainHash(row, prev)`. Rows with no stored
 * hash are skipped (legacy data); the chain link picks up from the
 * last verified hash, so a single gap does not break the rest.
 *
 * Returns `ok: false` on the first mismatch — the cron should abort
 * and the operator must rebuild the chain from cold storage.
 */
export function verifyChainSlice(
  rows: ReadonlyArray<AuditChainRow>,
  initialPrev: string = GENESIS_PREV_HASH,
): VerifyResult {
  let prev = initialPrev;
  let rowsChecked = 0;
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const stored = row.hash;
    if (!stored) {
      continue;
    }
    const expected = computeChainHash(row, prev);
    if (expected !== stored) {
      return {
        ok: false,
        rowsChecked,
        firstBadIndex: i,
        reason: `row id=${row.id}: stored=${stored.slice(0, 12)}… expected=${expected.slice(0, 12)}…`,
      };
    }
    rowsChecked++;
    prev = stored;
  }
  return {ok: true, rowsChecked, firstBadIndex: -1, reason: ""};
}
