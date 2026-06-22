jest.mock("firebase-admin", () => ({
  firestore: {
    FieldValue: { serverTimestamp: () => "__SERVER_TS__" },
    Timestamp: { fromDate: (d: Date) => ({ __ts: d.toISOString() }) },
  },
}));

import { hashCredentialId, isCloningEvidence } from "../passkey_authenticate";

describe("hashCredentialId", () => {
  it("returns a stable 16-char hex prefix", () => {
    const a = hashCredentialId("cred-1");
    const b = hashCredentialId("cred-1");
    expect(a).toEqual(b);
    expect(a).toMatch(/^[0-9a-f]{16}$/);
  });

  it("distinguishes different credentials", () => {
    expect(hashCredentialId("cred-1")).not.toEqual(hashCredentialId("cred-2"));
  });
});

describe("isCloningEvidence — FIDO2 §6.1 step 17", () => {
  it("regression (received < stored) is cloning evidence", () => {
    expect(isCloningEvidence(7, 6)).toBe(true);
    expect(isCloningEvidence(1, 0)).toBe(true);
  });

  it("equality at non-zero is replay (cloning evidence)", () => {
    expect(isCloningEvidence(7, 7)).toBe(true);
    expect(isCloningEvidence(1, 1)).toBe(true);
  });

  it("equality at zero is the legitimate signCount-pinned authenticator", () => {
    expect(isCloningEvidence(0, 0)).toBe(false);
  });

  it("monotonic advance is fine", () => {
    expect(isCloningEvidence(7, 8)).toBe(false);
    expect(isCloningEvidence(0, 1)).toBe(false);
  });
});
