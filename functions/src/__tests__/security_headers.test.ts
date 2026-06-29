import { securityHeaders, SECURITY_HEADERS } from '../middleware/security_headers';

type Headers = Record<string, string>;

function mockRes(): { headers: Headers; setHeader: jest.Mock } {
  const headers: Headers = {};
  const setHeader = jest.fn((name: string, value: string) => {
    headers[name] = value;
  });
  return { headers, setHeader };
}

describe('securityHeaders middleware', () => {
  test('emits every catalog header on every response', () => {
    const res = mockRes();
    const next = jest.fn();

    securityHeaders({} as never, res as never, next);

    for (const [name, value] of Object.entries(SECURITY_HEADERS)) {
      expect(res.headers[name]).toBe(value);
    }
    expect(next).toHaveBeenCalledTimes(1);
  });

  test('HSTS includes max-age >= 1 year + includeSubDomains + preload', () => {
    const hsts = SECURITY_HEADERS['Strict-Transport-Security'];
    expect(hsts).toContain('includeSubDomains');
    expect(hsts).toContain('preload');
    const m = /max-age=(\d+)/.exec(hsts);
    expect(m).not.toBeNull();
    expect(Number(m![1])).toBeGreaterThanOrEqual(31536000);
  });

  test('CSP forbids object-src + base-uri + frame-ancestors + requires upgrade-insecure-requests', () => {
    const csp = SECURITY_HEADERS['Content-Security-Policy'];
    expect(csp).toContain("object-src 'none'");
    expect(csp).toContain("base-uri 'none'");
    expect(csp).toContain("frame-ancestors 'none'");
    expect(csp).toContain('upgrade-insecure-requests');
  });

  test('X-Content-Type-Options is exactly nosniff', () => {
    expect(SECURITY_HEADERS['X-Content-Type-Options']).toBe('nosniff');
  });

  test('X-Frame-Options is DENY', () => {
    expect(SECURITY_HEADERS['X-Frame-Options']).toBe('DENY');
  });

  test('Referrer-Policy does not leak full URL cross-origin', () => {
    const acceptable = new Set([
      'strict-origin-when-cross-origin',
      'strict-origin',
      'no-referrer',
      'same-origin',
    ]);
    expect(acceptable.has(SECURITY_HEADERS['Referrer-Policy'])).toBe(true);
  });

  test('Permissions-Policy disables camera + geolocation + payment + usb', () => {
    const pp = SECURITY_HEADERS['Permissions-Policy'];
    for (const feature of [
      'camera=()',
      'geolocation=()',
      'payment=()',
      'usb=()',
    ]) {
      expect(pp).toContain(feature);
    }
  });

  test('COOP + COEP set for cross-origin isolation', () => {
    expect(SECURITY_HEADERS['Cross-Origin-Opener-Policy']).toBe('same-origin');
    expect(SECURITY_HEADERS['Cross-Origin-Embedder-Policy']).toBe(
      'require-corp',
    );
  });

  test('catalog has exactly the 8 pinned headers (catalog scope guard)', () => {
    expect(Object.keys(SECURITY_HEADERS).sort()).toEqual(
      [
        'Strict-Transport-Security',
        'Content-Security-Policy',
        'X-Content-Type-Options',
        'X-Frame-Options',
        'Referrer-Policy',
        'Permissions-Policy',
        'Cross-Origin-Opener-Policy',
        'Cross-Origin-Embedder-Policy',
      ].sort(),
    );
  });
});
