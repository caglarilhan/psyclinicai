/**
 * Pure-helper tests for `buildDsarBundle`. Firestore is mocked so we
 * exercise the assembly logic without booting the real client.
 */
jest.mock("firebase-admin", () => ({
  firestore: {
    Timestamp: {
      now: () => ({__ts: "now"}),
      fromDate: (d: Date) => ({__ts: d.toISOString()}),
    },
  },
}));

import {buildDsarBundle} from "../dsar_export";

interface MockDoc {
  id: string;
  data: Record<string, unknown>;
}

interface MockEntry {
  rows: MockDoc[];
}

// Tiny Firestore stand-in. Routes `collection(path)` lookups through a
// path→entry map; `.where()` / `.startAfter()` / `.limit()` are no-ops
// (the test fixtures are small enough to fit in one page).
function makeDb(paths: Record<string, MockEntry>) {
  const calls: string[] = [];
  function makeQuery(path: string) {
    const entry = paths[path] ?? {rows: []};
    const query: {
      where: () => typeof query;
      startAfter: () => typeof query;
      limit: () => typeof query;
      get: () => Promise<{
        empty: boolean;
        size: number;
        docs: Array<{
          id: string;
          ref: {path: string};
          data: () => Record<string, unknown>;
        }>;
      }>;
    } = {
      where: () => query,
      startAfter: () => query,
      limit: () => query,
      get: async () => {
        calls.push(path);
        return {
          empty: entry.rows.length === 0,
          size: entry.rows.length,
          docs: entry.rows.map((r) => ({
            id: r.id,
            ref: {path: `${path}/${r.id}`},
            data: () => r.data,
          })),
        };
      },
    };
    return query;
  }
  return {
    db: {
      collection: (p: string) => makeQuery(p),
    } as unknown as import("firebase-admin").firestore.Firestore,
    calls,
  };
}

describe("buildDsarBundle", () => {
  it("returns an empty manifest + records for a patient with no data", async () => {
    const {db} = makeDb({});
    const bundle = await buildDsarBundle(db, "u1", "p1");
    expect(bundle.clinicId).toBe("u1");
    expect(bundle.patientId).toBe("p1");
    expect(bundle.policyVersion).toContain("GDPR Art. 15");
    expect(bundle.records).toEqual({});
    // Manifest always lists every configured collection (with count: 0)
    // so an auditor sees the function ran end-to-end.
    expect(bundle.manifest.length).toBeGreaterThan(5);
    for (const m of bundle.manifest) {
      expect(m.count).toBe(0);
    }
  });

  it("aggregates rows from flat top-level collections", async () => {
    const {db} = makeDb({
      intakes: {
        rows: [
          {id: "i1", data: {patient_id: "p1", presenting_concern: "anxiety"}},
        ],
      },
      session_notes: {
        rows: [
          {id: "n1", data: {patient_id: "p1", markdown: "S/O/A/P"}},
        ],
      },
    });
    const bundle = await buildDsarBundle(db, "u1", "p1");
    expect(bundle.records.intakes).toHaveLength(1);
    expect((bundle.records.intakes![0] as {id: string}).id).toBe("i1");
    expect(bundle.records.session_notes).toHaveLength(1);
    const manifestNames = bundle.manifest.map((m) => m.collection);
    expect(manifestNames).toContain("intakes");
    expect(manifestNames).toContain("session_notes");
  });

  it("excludes pseudonymised (purged) rows", async () => {
    const {db} = makeDb({
      intakes: {
        rows: [
          {id: "i1", data: {patient_id: "p1", purged: true}},
          {id: "i2", data: {patient_id: "p1", presenting_concern: "live"}},
        ],
      },
    });
    const bundle = await buildDsarBundle(db, "u1", "p1");
    expect(bundle.records.intakes).toHaveLength(1);
    expect((bundle.records.intakes![0] as {id: string}).id).toBe("i2");
  });

  it("walks nested patient sub-collections", async () => {
    const {db} = makeDb({
      "clinics/u1/patients/p1/superbills": {
        rows: [
          {id: "s1", data: {invoiceNumber: "INV-1", totalCharges: 200}},
        ],
      },
    });
    const bundle = await buildDsarBundle(db, "u1", "p1");
    expect(bundle.records.superbills).toHaveLength(1);
    expect((bundle.records.superbills![0] as {id: string}).id).toBe("s1");
    const sb = bundle.manifest.find((m) => m.collection === "superbills");
    expect(sb?.count).toBe(1);
    expect(sb?.path).toBe("nested");
  });

  it("recurses into sessions/{id}/notes nested-nested rows", async () => {
    const {db} = makeDb({
      "clinics/u1/patients/p1/sessions": {
        rows: [
          {id: "sess1", data: {startedAt: "2026-06-21T10:00:00Z"}},
        ],
      },
      "clinics/u1/patients/p1/sessions/sess1/notes": {
        rows: [
          {id: "note1", data: {markdown: "## S — Subjective"}},
        ],
      },
    });
    const bundle = await buildDsarBundle(db, "u1", "p1");
    expect(bundle.records.sessions).toHaveLength(1);
    const row = bundle.records.sessions![0] as Record<string, unknown>;
    const nested = row._nested as Record<string, unknown[]>;
    expect(nested.notes).toHaveLength(1);
    const sessionNotesManifest = bundle.manifest.find(
      (m) => m.collection === "sessions/notes"
    );
    expect(sessionNotesManifest?.path).toBe("nested-nested");
    expect(sessionNotesManifest?.count).toBe(1);
  });

  it("scopes consent_records by clinic_id tenancy filter", async () => {
    const {db, calls} = makeDb({
      consent_records: {
        rows: [
          {id: "c1", data: {patientId: "p1", clinic_id: "u1"}},
        ],
      },
    });
    const bundle = await buildDsarBundle(db, "u1", "p1");
    expect(calls).toContain("consent_records");
    expect(
      bundle.manifest.some((m) => m.collection === "consent_records")
    ).toBe(true);
  });

  // K1 — per-kind consent_entries are surfaced under the same
  // clinic-tenancy gate. Without this the export would miss every
  // grant + revoke the patient performed in the Consent Center.
  it("includes consent_entries for the patient", async () => {
    const {db, calls} = makeDb({
      consent_entries: {
        rows: [
          {
            id: "ce-1",
            data: {
              patientId: "p1",
              clinic_id: "u1",
              kind: "aiProcessing",
              policyVersion: "2026-06",
              signature: "typed:Demo",
              signedAt: "2026-06-25T12:00:00.000Z",
            },
          },
          {
            id: "ce-2",
            data: {
              patientId: "p1",
              clinic_id: "u1",
              kind: "telehealth",
              policyVersion: "2026-06",
              signature: "typed:Demo",
              signedAt: "2026-06-25T12:01:00.000Z",
              revokedAt: "2026-06-25T13:00:00.000Z",
            },
          },
        ],
      },
    });
    const bundle = await buildDsarBundle(db, "u1", "p1");
    expect(calls).toContain("consent_entries");
    expect(bundle.records.consent_entries).toHaveLength(2);
    const entries = bundle.records.consent_entries as Array<{
      kind: string;
      revokedAt?: string;
    }>;
    expect(entries.map((e) => e.kind).sort()).toEqual([
      "aiProcessing",
      "telehealth",
    ]);
    // Revoke history is preserved — KVKK md. 11(d) compliance.
    const revoked = entries.find((e) => e.kind === "telehealth");
    expect(revoked?.revokedAt).toBe("2026-06-25T13:00:00.000Z");
  });

  // K1 — clinic_audit_logs/{clinicId}/entries mirror rows scoped to
  // patient via actor field. Closes the KVKK md. 11(d) "veri
  // faaliyetlerinin niteliğini öğrenme" right.
  it("includes clinic_audit_logs filtered by actor==patientId", async () => {
    const {db, calls} = makeDb({
      "clinic_audit_logs/u1/entries": {
        rows: [
          {
            id: "audit-1",
            data: {
              clinic_id: "u1",
              kind: "consent",
              action: "kvkk.consent_granted",
              actor: "p1",
              entity: "patient:p1 entry:ce-1 policy:2026-06",
              timestamp_utc: "2026-06-25T12:00:00.000Z",
              result: "success",
              hash: "a".repeat(64),
              prev_hash: "",
            },
          },
          {
            id: "audit-2",
            data: {
              clinic_id: "u1",
              kind: "consent",
              action: "consent.granted.ai_processing",
              actor: "p1",
              entity: "patient:p1 entry:ce-2 policy:2026-06",
              timestamp_utc: "2026-06-25T11:00:00.000Z",
              result: "success",
              hash: "b".repeat(64),
              prev_hash: "a".repeat(64),
            },
          },
        ],
      },
    });
    const bundle = await buildDsarBundle(db, "u1", "p1");
    expect(calls).toContain("clinic_audit_logs/u1/entries");
    expect(bundle.records.audit_log).toHaveLength(2);
    // Sorted ASC by timestamp_utc — chain-replayable.
    const audit = bundle.records.audit_log as Array<{
      id: string;
      timestamp_utc: string;
    }>;
    expect(audit[0].id).toBe("audit-2"); // 11:00 < 12:00
    expect(audit[1].id).toBe("audit-1");
    expect(
      bundle.manifest.some((m) => m.collection === "audit_log")
    ).toBe(true);
  });

  it("audit_log manifest stays at 0 when no patient rows exist", async () => {
    const {db} = makeDb({});
    const bundle = await buildDsarBundle(db, "u1", "p1");
    const auditManifest = bundle.manifest.find(
      (m) => m.collection === "audit_log"
    );
    expect(auditManifest?.count).toBe(0);
    expect(bundle.records.audit_log).toBeUndefined();
  });
});
