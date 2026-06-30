import {Timestamp} from "firebase-admin/firestore";

import {findOverdueRotations} from "../scheduled/mbc_cadence_cron";

function tsFromDaysAgo(days: number): Timestamp {
  const d = new Date();
  d.setDate(d.getDate() - days);
  return Timestamp.fromMillis(d.getTime());
}

describe("findOverdueRotations", () => {
  test("empty input → empty result", () => {
    expect(findOverdueRotations([], new Date())).toEqual([]);
  });

  test("ignores rows missing tenant/patient/scale", () => {
    const rows = [
      {
        tenant_id: "t1",
        patient_id: "p1",
        scale_id: "phq9",
        submitted_at: tsFromDaysAgo(20),
        dispatched_at: tsFromDaysAgo(20),
      },
      {
        patient_id: "p2",
        scale_id: "phq9",
        submitted_at: tsFromDaysAgo(20),
        dispatched_at: tsFromDaysAgo(20),
      },
    ];
    const out = findOverdueRotations(rows, new Date());
    expect(out.length).toBe(1);
    expect(out[0].patientId).toBe("p1");
  });

  test("ignores never-submitted (patient never filled the form)", () => {
    const rows = [
      {
        tenant_id: "t1",
        patient_id: "p1",
        scale_id: "phq9",
        submitted_at: null,
        dispatched_at: tsFromDaysAgo(60),
      },
    ];
    expect(findOverdueRotations(rows, new Date())).toEqual([]);
  });

  test("returns overdue rotation (PHQ-9 last submitted 20 days ago)", () => {
    const rows = [
      {
        tenant_id: "t1",
        clinic_id: "c1",
        patient_id: "p1",
        scale_id: "phq9",
        submitted_at: tsFromDaysAgo(15),
        dispatched_at: tsFromDaysAgo(20),
      },
    ];
    const out = findOverdueRotations(rows, new Date());
    expect(out.length).toBe(1);
    expect(out[0].tenantId).toBe("t1");
    expect(out[0].scaleId).toBe("phq9");
  });

  test("does NOT return rotation still inside interval", () => {
    const rows = [
      {
        tenant_id: "t1",
        patient_id: "p1",
        scale_id: "phq9",
        submitted_at: tsFromDaysAgo(3),
        dispatched_at: tsFromDaysAgo(5),
      },
    ];
    expect(findOverdueRotations(rows, new Date())).toEqual([]);
  });

  test("dedupes per (tenant, patient, scale) keeping latest dispatch", () => {
    const rows = [
      {
        tenant_id: "t1",
        patient_id: "p1",
        scale_id: "phq9",
        submitted_at: tsFromDaysAgo(60),
        dispatched_at: tsFromDaysAgo(60),
      },
      {
        tenant_id: "t1",
        patient_id: "p1",
        scale_id: "phq9",
        submitted_at: tsFromDaysAgo(3),
        dispatched_at: tsFromDaysAgo(5),
      },
    ];
    expect(findOverdueRotations(rows, new Date())).toEqual([]);
  });

  test("ignores unknown scale ids", () => {
    const rows = [
      {
        tenant_id: "t1",
        patient_id: "p1",
        scale_id: "legacy_scale_x",
        submitted_at: tsFromDaysAgo(60),
        dispatched_at: tsFromDaysAgo(60),
      },
    ];
    expect(findOverdueRotations(rows, new Date())).toEqual([]);
  });
});
