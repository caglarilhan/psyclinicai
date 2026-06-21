jest.mock("firebase-admin", () => ({
  firestore: {
    Timestamp: {
      fromDate: (d: Date) => ({__ts: d.toISOString()}),
    },
  },
}));

import {
  buildWithdrawalAuditRow,
  detectsWithdrawal,
} from "../consent_withdrawal_audit";

describe("detectsWithdrawal", () => {
  it("fires when withdrawnAt goes null → timestamp", () => {
    expect(
      detectsWithdrawal(
        {withdrawnAt: null},
        {withdrawnAt: "2026-06-21T10:00:00Z"}
      )
    ).toBe(true);
  });

  it("fires when withdrawnAt was absent → set", () => {
    expect(
      detectsWithdrawal(
        {} as Record<string, unknown>,
        {withdrawnAt: "2026-06-21T10:00:00Z"}
      )
    ).toBe(true);
  });

  it("does NOT fire on unrelated field edits (e.g. policyVersion bump)", () => {
    expect(
      detectsWithdrawal(
        {withdrawnAt: null, policyVersion: "2026-05"},
        {withdrawnAt: null, policyVersion: "2026-06"}
      )
    ).toBe(false);
  });

  it("does NOT fire when withdrawnAt was already set on both sides", () => {
    expect(
      detectsWithdrawal(
        {withdrawnAt: "2026-06-01T00:00:00Z"},
        {withdrawnAt: "2026-06-21T10:00:00Z"}
      )
    ).toBe(false);
  });

  it("does NOT fire on the inverse (withdrawal undone)", () => {
    expect(
      detectsWithdrawal(
        {withdrawnAt: "2026-06-01T00:00:00Z"},
        {withdrawnAt: null}
      )
    ).toBe(false);
  });

  it("treats deleted documents as no-op", () => {
    expect(detectsWithdrawal({withdrawnAt: null}, null)).toBe(false);
    expect(detectsWithdrawal(null, null)).toBe(false);
  });
});

describe("buildWithdrawalAuditRow", () => {
  const NOW = new Date("2026-06-21T14:30:00.000Z");

  it("emits a typed audit row keyed by clinic_id with no PHI body", () => {
    const row = buildWithdrawalAuditRow({
      recordId: "rec-1",
      after: {
        patientId: "p-1",
        clinic_id: "u-1",
        policyVersion: "2026-06",
        withdrawnAt: NOW.toISOString(),
      },
      now: NOW,
    });
    expect(row.kind).toBe("consent");
    expect(row.event_type).toBe("consent.withdrawn");
    expect(row.action).toBe("consent.withdrawn");
    expect(row.actor).toBe("client.user");
    expect(row.clinic_id).toBe("u-1");
    expect(row.result).toBe("success");
    expect(row.entity as string).toContain("consent_record:rec-1");
    expect(row.entity as string).toContain("patient:p-1");
    expect(row.entity as string).toContain("policy:2026-06");
    // No raw PHI fields surface in the audit row.
    expect(JSON.stringify(row)).not.toContain("aiAssistanceConsent");
    expect(JSON.stringify(row)).not.toContain("dataProcessingConsent");
  });

  it("tolerates missing optional fields with empty strings", () => {
    const row = buildWithdrawalAuditRow({
      recordId: "rec-2",
      after: {withdrawnAt: NOW.toISOString()},
      now: NOW,
    });
    expect(row.clinic_id).toBe("");
    expect(row.entity as string).toContain("patient:");
    expect(row.entity as string).toContain("policy:");
  });

  it("uses an audit-friendly deterministic id", () => {
    const row1 = buildWithdrawalAuditRow({
      recordId: "rec-1",
      after: {clinic_id: "u-1", withdrawnAt: NOW.toISOString()},
      now: NOW,
    });
    expect(row1.id).toBe(`consent-withdrawn-rec-1-${NOW.toISOString()}`);
  });
});
