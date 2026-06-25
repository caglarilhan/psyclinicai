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

// ---------------------------------------------------------------
// J2 — client-side chain helpers
//
// The on-device `AuditLogRepository` (Dart) computes each row's
// hash as `sha256(prevHash + jsonEncode(entry.toJson()))` where
// `toJson()` emits keys in INSERTION order (id, kind, action,
// actor, entity, timestamp_utc, result, [user_id], [ip], [device]).
// That is NOT the same as [canonicalise]'s lexicographic order, so
// re-using `verifyChainSlice` against client-mirrored rows would
// always fail.
//
// The helpers below mirror the Dart serialiser EXACTLY so a Cloud
// Function chain-verifier can replay rows mirrored into
// `clinic_audit_logs/{clinicId}/entries` without false alarms.
// Concatenation is plain `prev + canonical` (no separator) to
// match `String + String` in Dart.
// ---------------------------------------------------------------

/** Empty-string chain head (Dart uses `''`, not `'GENESIS'`). */
export const CLIENT_GENESIS_PREV_HASH = "";

/**
 * Stable JSON serialisation that mirrors Dart's `AuditLogEntry.toJson`
 * insertion order. Hash field is NEVER included (the chain hash is
 * computed over everything *but* the hash field).
 */
export function clientCanonicalise(row: AuditChainRow): string {
  const obj: Record<string, unknown> = {
    id: row.id,
    kind: row.kind,
    action: row.action,
    actor: row.actor,
    entity: row.entity,
    timestamp_utc: row.timestamp_utc,
    result: row.result,
  };
  if (row.user_id !== null && row.user_id !== undefined) {
    obj.user_id = row.user_id;
  }
  if (row.ip !== null && row.ip !== undefined) obj.ip = row.ip;
  if (row.device !== null && row.device !== undefined) {
    obj.device = row.device;
  }
  return JSON.stringify(obj);
}

/**
 * SHA-256 over `prev + clientCanonicalise(row)`. Lowercase hex.
 * NB: concatenation is unseparated to match the Dart writer.
 */
export function computeClientChainHash(
  row: AuditChainRow,
  prevHash: string,
): string {
  const payload = `${prevHash}${clientCanonicalise(row)}`;
  return createHash("sha256").update(payload).digest("hex");
}

/**
 * Walk an ordered slice of CLIENT-WRITTEN audit rows and confirm
 * each row's stored `hash` matches `computeClientChainHash`.
 * Unlike [verifyChainSlice], rows MUST carry a hash — a missing
 * hash on the mirrored side is itself a corruption signal.
 */
export function verifyClientChainSlice(
  rows: ReadonlyArray<AuditChainRow>,
  initialPrev: string = CLIENT_GENESIS_PREV_HASH,
): VerifyResult {
  let prev = initialPrev;
  let rowsChecked = 0;
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const stored = row.hash;
    if (!stored) {
      return {
        ok: false,
        rowsChecked,
        firstBadIndex: i,
        reason: `row id=${row.id}: missing hash on mirrored row`,
      };
    }
    const expected = computeClientChainHash(row, prev);
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
