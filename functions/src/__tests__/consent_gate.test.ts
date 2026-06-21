/**
 * Consent gate decision tests. firebase-admin is mocked so we exercise
 * the helper without booting Firestore.
 */
import {checkAiConsent, extractPatientId} from "../lib/consent_gate";

// Minimal firestore mock that supports the chained call:
//   db.collection(...).where(...).where(...).orderBy(...).limit(...).get()
function makeDb(snapshot: {empty: boolean; docs: Array<{data: () => unknown}>}) {
  const query = {
    where: () => query,
    orderBy: () => query,
    limit: () => query,
    get: jest.fn(async () => snapshot),
  };
  const db = {
    collection: jest.fn(() => query),
  };
  return {db: db as unknown as import("firebase-admin").firestore.Firestore,
    query};
}

describe("extractPatientId", () => {
  it("returns null for missing / empty inputs", () => {
    expect(extractPatientId(null)).toBeNull();
    expect(extractPatientId({})).toBeNull();
    expect(extractPatientId({patientId: ""})).toBeNull();
    expect(extractPatientId({patientId: "   "})).toBeNull();
  });

  it("accepts camelCase patientId", () => {
    expect(extractPatientId({patientId: "p-1"})).toBe("p-1");
  });

  it("accepts snake_case patient_id (legacy)", () => {
    expect(extractPatientId({patient_id: "p-2"})).toBe("p-2");
  });

  it("accepts nested patient.id", () => {
    expect(extractPatientId({patient: {id: "p-3"}})).toBe("p-3");
  });

  it("trims surrounding whitespace", () => {
    expect(extractPatientId({patientId: "  p-4  "})).toBe("p-4");
  });
});

describe("checkAiConsent", () => {
  it("allows when no patient is mentioned (non-PHI call)", async () => {
    const {db} = makeDb({empty: true, docs: []});
    const r = await checkAiConsent({db, clinicId: "u1", patientId: null});
    expect(r.ok).toBe(true);
    if (r.ok) expect(r.reason).toBe("no_patient_in_request");
  });

  it("allows when empty patientId is passed", async () => {
    const {db} = makeDb({empty: true, docs: []});
    const r = await checkAiConsent({db, clinicId: "u1", patientId: ""});
    expect(r.ok).toBe(true);
  });

  it("denies missing_consent when no record exists for the patient", async () => {
    const {db} = makeDb({empty: true, docs: []});
    const r = await checkAiConsent({db, clinicId: "u1", patientId: "p1"});
    expect(r.ok).toBe(false);
    if (!r.ok) expect(r.reason).toBe("missing_consent");
  });

  it("denies withdrawn when the latest record has withdrawnAt set", async () => {
    const {db} = makeDb({
      empty: false,
      docs: [{data: () => ({
        aiAssistanceConsent: true,
        withdrawnAt: "2026-06-01T00:00:00Z",
      })}],
    });
    const r = await checkAiConsent({db, clinicId: "u1", patientId: "p1"});
    expect(r.ok).toBe(false);
    if (!r.ok) expect(r.reason).toBe("withdrawn");
  });

  it("denies not_ai_authorized when aiAssistanceConsent is false", async () => {
    const {db} = makeDb({
      empty: false,
      docs: [{data: () => ({
        aiAssistanceConsent: false,
        withdrawnAt: null,
      })}],
    });
    const r = await checkAiConsent({db, clinicId: "u1", patientId: "p1"});
    expect(r.ok).toBe(false);
    if (!r.ok) expect(r.reason).toBe("not_ai_authorized");
  });

  it("consents when aiAssistanceConsent is true and not withdrawn", async () => {
    const {db} = makeDb({
      empty: false,
      docs: [{data: () => ({
        aiAssistanceConsent: true,
        withdrawnAt: null,
      })}],
    });
    const r = await checkAiConsent({db, clinicId: "u1", patientId: "p1"});
    expect(r.ok).toBe(true);
    if (r.ok) expect(r.reason).toBe("consented");
  });
});
