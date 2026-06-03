import type * as functions from "firebase-functions";
import { rpIdFor, originFor } from "../lib/webauthn_env";

function req(origin: string | undefined): functions.https.Request {
  return {
    headers: origin === undefined ? {} : { origin },
  } as unknown as functions.https.Request;
}

describe("webauthn_env.rpIdFor", () => {
  it("returns 'localhost' for dev origins", () => {
    expect(rpIdFor(req("http://localhost:8000"))).toBe("localhost");
    expect(rpIdFor(req("http://localhost:5000"))).toBe("localhost");
  });

  it("returns 'psyclinic.ai' for prod / subdomains", () => {
    expect(rpIdFor(req("https://psyclinic.ai"))).toBe("psyclinic.ai");
    expect(rpIdFor(req("https://app.psyclinic.ai"))).toBe("psyclinic.ai");
    expect(rpIdFor(req("https://eu.psyclinic.ai"))).toBe("psyclinic.ai");
  });

  it("falls back to prod when origin is missing or malformed", () => {
    expect(rpIdFor(req(undefined))).toBe("psyclinic.ai");
    expect(rpIdFor(req("not-a-url"))).toBe("psyclinic.ai");
  });
});

describe("webauthn_env.originFor", () => {
  it("echoes only allow-listed origins", () => {
    expect(originFor(req("https://app.psyclinic.ai"))).toBe(
      "https://app.psyclinic.ai"
    );
    expect(originFor(req("http://localhost:8000"))).toBe(
      "http://localhost:8000"
    );
  });

  it("collapses unknown origins to the prod canonical URL", () => {
    expect(originFor(req("https://attacker.example.com"))).toBe(
      "https://psyclinic.ai"
    );
    expect(originFor(req(undefined))).toBe("https://psyclinic.ai");
  });
});
