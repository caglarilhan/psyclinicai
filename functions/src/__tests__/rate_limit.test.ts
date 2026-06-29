import {
  rateLimitFor,
  recordAuthFailure,
  resetStoreForTest,
  setNowForTest,
  resetNow,
  scopeKeyFor,
  RATE_LIMITS,
} from '../middleware/rate_limit';

type Headers = Record<string, string>;

function mockRes(): {
  headers: Headers;
  setHeader: jest.Mock;
  status: jest.Mock;
  json: jest.Mock;
  statusCode?: number;
  body?: unknown;
} {
  const headers: Headers = {};
  const res: {
    headers: Headers;
    setHeader: jest.Mock;
    status: jest.Mock;
    json: jest.Mock;
    statusCode?: number;
    body?: unknown;
  } = {
    headers,
    setHeader: jest.fn((name: string, value: string) => {
      headers[name] = value;
    }),
    status: jest.fn((code: number) => {
      res.statusCode = code;
      return res;
    }),
    json: jest.fn((body: unknown) => {
      res.body = body;
      return res;
    }),
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

describe('rate_limit middleware', () => {
  let t = 1_000_000_000_000;

  beforeEach(() => {
    resetStoreForTest();
    t = 1_000_000_000_000;
    setNowForTest(() => t);
  });

  afterEach(() => {
    resetNow();
  });

  test('catalog has exactly 7 endpoint classes (scope guard)', () => {
    expect(Object.keys(RATE_LIMITS).sort()).toEqual(
      [
        'auth-login',
        'public-unauthenticated',
        'clinician-dashboard-read',
        'ai-copilot-inference',
        'portal-dsar',
        'internal-admin',
        'webhook-ingestion',
      ].sort(),
    );
  });

  test('auth-login is brute-force-sensitive + perMinute=10 + burst=0', () => {
    expect(RATE_LIMITS['auth-login'].bruteForceSensitive).toBe(true);
    expect(RATE_LIMITS['auth-login'].perMinute).toBe(10);
    expect(RATE_LIMITS['auth-login'].burst).toBe(0);
  });

  test('non-auth endpoints are NOT brute-force-sensitive', () => {
    for (const [name, rec] of Object.entries(RATE_LIMITS)) {
      if (name === 'auth-login') continue;
      expect(rec.bruteForceSensitive).toBe(false);
    }
  });

  test('auth-login: 10 reqs/min/tenant pass, 11th is 429', () => {
    const mw = rateLimitFor('auth-login');
    const req = mockReq({ tenantId: 'tenant-A' });

    for (let i = 0; i < 10; i++) {
      const res = mockRes();
      const next = jest.fn();
      mw(req as never, res as never, next);
      expect(next).toHaveBeenCalledTimes(1);
      expect(res.statusCode).toBeUndefined();
    }

    const res11 = mockRes();
    const next11 = jest.fn();
    mw(req as never, res11 as never, next11);
    expect(res11.statusCode).toBe(429);
    expect(next11).not.toHaveBeenCalled();
    expect(res11.headers['Retry-After']).toBe('60');
  });

  test('auth-login: lockout-after-5 failures triggers 429 + Retry-After 900', () => {
    const req = mockReq({ tenantId: 'tenant-B' });
    const key = scopeKeyFor(req as never, 'auth-login');

    for (let i = 0; i < 5; i++) {
      recordAuthFailure(key);
    }

    const mw = rateLimitFor('auth-login');
    const res = mockRes();
    const next = jest.fn();
    mw(req as never, res as never, next);

    expect(res.statusCode).toBe(429);
    expect(res.body).toEqual({
      error: 'locked_out',
      retryAfterSeconds: 900,
    });
    expect(res.headers['Retry-After']).toBe('900');
    expect(next).not.toHaveBeenCalled();
  });

  test('lockout expires after 15 min', () => {
    const req = mockReq({ tenantId: 'tenant-C' });
    const key = scopeKeyFor(req as never, 'auth-login');

    for (let i = 0; i < 5; i++) recordAuthFailure(key);

    const mw = rateLimitFor('auth-login');
    const res1 = mockRes();
    mw(req as never, res1 as never, jest.fn());
    expect(res1.statusCode).toBe(429);

    t += 16 * 60 * 1000;

    const res2 = mockRes();
    const next = jest.fn();
    mw(req as never, res2 as never, next);
    expect(res2.statusCode).toBeUndefined();
    expect(next).toHaveBeenCalledTimes(1);
  });

  test('failures outside 60s window reset the counter', () => {
    const req = mockReq({ tenantId: 'tenant-D' });
    const key = scopeKeyFor(req as never, 'auth-login');

    for (let i = 0; i < 4; i++) recordAuthFailure(key);

    t += 61 * 1000;
    recordAuthFailure(key);

    const mw = rateLimitFor('auth-login');
    const res = mockRes();
    const next = jest.fn();
    mw(req as never, res as never, next);
    expect(res.statusCode).toBeUndefined();
    expect(next).toHaveBeenCalledTimes(1);
  });

  test('different tenants get independent buckets', () => {
    const mw = rateLimitFor('auth-login');

    for (let i = 0; i < 10; i++) {
      mw(
        mockReq({ tenantId: 'tA' }) as never,
        mockRes() as never,
        jest.fn(),
      );
    }
    const res = mockRes();
    const next = jest.fn();
    mw(mockReq({ tenantId: 'tB' }) as never, res as never, next);
    expect(next).toHaveBeenCalledTimes(1);
    expect(res.statusCode).toBeUndefined();
  });

  test('unauthenticated falls back to IP-scoped bucket', () => {
    const mw = rateLimitFor('public-unauthenticated');

    for (let i = 0; i < 90; i++) {
      mw(
        mockReq({ ip: '1.1.1.1' }) as never,
        mockRes() as never,
        jest.fn(),
      );
    }
    const overIp1 = mockRes();
    mw(
      mockReq({ ip: '1.1.1.1' }) as never,
      overIp1 as never,
      jest.fn(),
    );
    expect(overIp1.statusCode).toBe(429);

    const ip2 = mockRes();
    const next = jest.fn();
    mw(mockReq({ ip: '2.2.2.2' }) as never, ip2 as never, next);
    expect(next).toHaveBeenCalledTimes(1);
  });

  test('bucket refills over time (drain then 30s wait → ~half capacity refilled)', () => {
    const mw = rateLimitFor('webhook-ingestion');
    const req = mockReq({ tenantId: 'webhook-tenant' });

    for (let i = 0; i < 1200; i++) {
      mw(req as never, mockRes() as never, jest.fn());
    }
    const drained = mockRes();
    mw(req as never, drained as never, jest.fn());
    expect(drained.statusCode).toBe(429);

    t += 30 * 1000;
    let allowedAfterRefill = 0;
    for (let i = 0; i < 350; i++) {
      const r = mockRes();
      mw(req as never, r as never, jest.fn());
      if (r.statusCode === undefined) allowedAfterRefill += 1;
    }
    expect(allowedAfterRefill).toBeGreaterThanOrEqual(250);
    expect(allowedAfterRefill).toBeLessThanOrEqual(310);
  });
});
