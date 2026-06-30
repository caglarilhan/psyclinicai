import {formUrlFor, hashToken, mintRawToken} from "../mbc_dispatch_link";

describe("mintRawToken", () => {
  test("returns URL-safe base64 of length >= 40", () => {
    const t = mintRawToken();
    expect(t.length).toBeGreaterThanOrEqual(40);
    expect(t).toMatch(/^[A-Za-z0-9_-]+$/);
  });

  test("two consecutive mints are different (entropy sanity)", () => {
    const a = mintRawToken();
    const b = mintRawToken();
    expect(a).not.toBe(b);
  });
});

describe("hashToken", () => {
  test("sha256 64-char hex", () => {
    const h = hashToken("hello");
    expect(h).toMatch(/^[0-9a-f]{64}$/);
  });

  test("deterministic", () => {
    expect(hashToken("same")).toBe(hashToken("same"));
  });

  test("different inputs differ", () => {
    expect(hashToken("a")).not.toBe(hashToken("b"));
  });
});

describe("formUrlFor", () => {
  test("appends the raw token to the base", () => {
    const url = formUrlFor("abc123");
    expect(url.endsWith("/abc123")).toBe(true);
  });
});
