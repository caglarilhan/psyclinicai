import {
  applySecurityHeaders,
  applyRateLimit,
} from '../lib/security_chain';
import {
  resetStoreForTest,
  setNowForTest,
  resetNow,
} from '../middleware/rate_limit';
import { SECURITY_HEADERS } from '../middleware/security_headers';

type Headers = Record<string, string>;

function mockRes(): {
  headers: Headers;
  setHeader: jest.Mock;
  status: jest.Mock;
  json: jest.Mock;
  statusCode?: number;
} {
  const headers: Headers = {};
  const res: {
    headers: Headers;
    setHeader: jest.Mock;
    status: jest.Mock;
    json: jest.Mock;
    statusCode?: number;
  } = {
    headers,
    setHeader: jest.fn((name: string, value: string) => {
      headers[name] = value;
    }),
    status: jest.fn((code: number) => {
      res.statusCode = code;
      return res;
    }),
    json: jest.fn(() => res),
  };
  return res;
}

function mockReq(opts: { tenantId?: string; ip?: string } = {}): {
  headers: Record<string, string | undefined>;
  ip?: string;
  tenantId?: string;
} {
  return {
    headers: {},
    ip: opts.ip ?? '127.0.0.1',
    tenantId: opts.tenantId,
  };
}

describe('security_chain helpers', () => {
  let t = 1_700_000_000_000;

  beforeEach(() => {
    resetStoreForTest();
    t = 1_700_000_000_000;
    setNowForTest(() => t);
  });

  afterEach(() => {
    resetNow();
  });

  test('applySecurityHeaders emits every catalog header', () => {
    const res = mockRes();
    applySecurityHeaders(res as never);
    for (const [name, value] of Object.entries(SECURITY_HEADERS)) {
      expect(res.headers[name]).toBe(value);
    }
  });

  test('applyRateLimit returns false on the first allowed request', () => {
    const req = mockReq({ tenantId: 'tenant-chain-A' });
    const res = mockRes();
    const throttled = applyRateLimit(
      req as never,
      res as never,
      'ai-copilot-inference',
    );
    expect(throttled).toBe(false);
    expect(res.statusCode).toBeUndefined();
  });

  test('applyRateLimit returns true + emits 429 after the cap is drained', () => {
    const req = mockReq({ tenantId: 'tenant-chain-B' });
    for (let i = 0; i < 40; i++) {
      applyRateLimit(
        req as never,
        mockRes() as never,
        'ai-copilot-inference',
      );
    }
    const res = mockRes();
    const throttled = applyRateLimit(
      req as never,
      res as never,
      'ai-copilot-inference',
    );
    expect(throttled).toBe(true);
    expect(res.statusCode).toBe(429);
    expect(res.headers['Retry-After']).toBe('60');
  });

  test('applySecurityHeaders + applyRateLimit compose without interfering', () => {
    const req = mockReq({ tenantId: 'tenant-chain-C' });
    const res = mockRes();
    applySecurityHeaders(res as never);
    const throttled = applyRateLimit(
      req as never,
      res as never,
      'ai-copilot-inference',
    );
    expect(throttled).toBe(false);
    expect(res.headers['Strict-Transport-Security']).toBeDefined();
    expect(res.headers['Content-Security-Policy']).toBeDefined();
  });

  test(
    'security headers ALSO present on a 429 response (defense-in-depth)',
    () => {
      const req = mockReq({ tenantId: 'tenant-chain-D' });
      for (let i = 0; i < 40; i++) {
        applyRateLimit(
          req as never,
          mockRes() as never,
          'ai-copilot-inference',
        );
      }
      const res = mockRes();
      applySecurityHeaders(res as never);
      const throttled = applyRateLimit(
        req as never,
        res as never,
        'ai-copilot-inference',
      );
      expect(throttled).toBe(true);
      expect(res.headers['Strict-Transport-Security']).toBeDefined();
      expect(res.headers['X-Frame-Options']).toBe('DENY');
    },
  );
});
