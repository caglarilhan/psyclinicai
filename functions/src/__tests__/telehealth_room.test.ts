jest.mock("firebase-admin", () => ({
  firestore: {
    Timestamp: { fromDate: (d: Date) => ({ __ts: d.toISOString() }) },
    FieldValue: { serverTimestamp: () => "__SERVER_TS__" },
  },
}));

import { deriveRoomName, computeTokenExpiry } from "../telehealth_room";

describe("deriveRoomName", () => {
  it("is deterministic — same inputs yield the same slug", () => {
    expect(deriveRoomName("clinic-1", "session-42")).toBe(
      deriveRoomName("clinic-1", "session-42")
    );
  });

  it("normalises mixed-case and special characters", () => {
    const slug = deriveRoomName("Clinic 1!", "Session/42");
    expect(slug).toMatch(/^[a-z0-9-]+$/);
    expect(slug.startsWith("psy-")).toBe(true);
  });

  it("clamps at 41 characters (Daily.co limit)", () => {
    const slug = deriveRoomName(
      "an-extremely-long-clinic-identifier-x",
      "and-an-equally-long-session-id-y"
    );
    expect(slug.length).toBeLessThanOrEqual(41);
  });
});

describe("computeTokenExpiry", () => {
  it("starts 15 minutes before the scheduled time", () => {
    const start = new Date(Date.UTC(2026, 5, 2, 14));
    const { notBefore } = computeTokenExpiry(start);
    expect(start.getTime() - notBefore.getTime()).toBe(15 * 60 * 1000);
  });

  it("expires 90 minutes after the scheduled start", () => {
    const start = new Date(Date.UTC(2026, 5, 2, 14));
    const { expiresAt } = computeTokenExpiry(start);
    expect(expiresAt.getTime() - start.getTime()).toBe(90 * 60 * 1000);
  });
});
