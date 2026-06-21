/**
 * Pure-function tests for the server-side PHI scrubber.
 * Mirror of the Dart `phi_redaction.dart` contract.
 */
import {scrubPhiInPayload, scrubPhiInString} from "../lib/phi_scrub";

describe("scrubPhiInString", () => {
  it("redacts email, phone, SSN, MRN, NPI, IP in a single pass", () => {
    const input =
      "Email john.doe@example.com phone 415-555-9876 SSN 123-45-6789 " +
      "MRN: AB12345 NPI 1234567890 server 10.0.0.5 fine.";
    const r = scrubPhiInString(input);
    expect(r.text).not.toMatch(/john\.doe/);
    expect(r.text).not.toMatch(/415-555-9876/);
    expect(r.text).not.toMatch(/123-45-6789/);
    expect(r.text).not.toMatch(/AB12345/);
    expect(r.text).not.toMatch(/1234567890/);
    expect(r.text).toContain("[EMAIL]");
    expect(r.text).toContain("[PHONE]");
    expect(r.text).toContain("[SSN]");
    expect(r.text).toContain("[MRN]");
    expect(r.text).toContain("[NPI]");
    expect(r.text).toContain("[IP]");
    expect(r.totalRemoved).toBeGreaterThanOrEqual(6);
  });

  it("passes clinical text without identifiers through unchanged", () => {
    const benign =
      "Patient describes ongoing depressed mood for 3 weeks; sleep " +
      "improved last fortnight; reports no SI.";
    const r = scrubPhiInString(benign);
    expect(r.text).toBe(benign);
    expect(r.totalRemoved).toBe(0);
  });

  it("counts every removal it makes per label", () => {
    const r = scrubPhiInString("a@b.com c@d.com e@f.com");
    expect(r.totalRemoved).toBe(3);
    expect(r.removed.email).toBe(3);
  });
});

describe("scrubPhiInPayload", () => {
  it("walks nested arrays + objects + Anthropic message shape", () => {
    const body = {
      model: "claude-haiku-4-5",
      max_tokens: 400,
      system: "You are a clinical safety assistant.",
      messages: [
        {
          role: "user",
          content: "Client john@example.com called 415-555-9876 today.",
        },
        {
          role: "assistant",
          content: [{type: "text", text: "Noted."}],
        },
      ],
    };
    const r = scrubPhiInPayload(body);
    const out = r.payload as typeof body;
    expect(out.model).toBe("claude-haiku-4-5");
    expect(out.max_tokens).toBe(400);
    expect(out.system).toBe("You are a clinical safety assistant.");
    const userContent = (out.messages[0] as {content: string}).content;
    expect(userContent).not.toMatch(/john@example/);
    expect(userContent).not.toMatch(/415-555-9876/);
    expect(userContent).toContain("[EMAIL]");
    expect(userContent).toContain("[PHONE]");
    expect(r.totalRemoved).toBe(2);
    expect(r.removed.email).toBe(1);
    expect(r.removed.phone_us).toBe(1);
  });

  it("leaves non-string leaves (numbers, booleans, null) untouched", () => {
    const r = scrubPhiInPayload({
      max_tokens: 1024,
      temperature: 0.2,
      stream: false,
      tools: null,
    });
    expect(r.payload).toEqual({
      max_tokens: 1024,
      temperature: 0.2,
      stream: false,
      tools: null,
    });
    expect(r.totalRemoved).toBe(0);
  });

  it("does not mutate the input object", () => {
    const original = {
      messages: [{role: "user", content: "a@b.com"}],
    };
    const snapshot = JSON.stringify(original);
    scrubPhiInPayload(original);
    expect(JSON.stringify(original)).toBe(snapshot);
  });
});
