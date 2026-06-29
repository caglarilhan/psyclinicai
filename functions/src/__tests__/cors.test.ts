import {
  cors,
  currentSlot,
  isOriginAllowed,
  CORS_ALLOWED_ORIGINS,
} from '../middleware/cors';

type Headers = Record<string, string>;

function mockRes(): {
  headers: Headers;
  setHeader: jest.Mock;
  status: jest.Mock;
  end: jest.Mock;
  statusCode?: number;
} {
  const headers: Headers = {};
  const res: {
    headers: Headers;
    setHeader: jest.Mock;
    status: jest.Mock;
    end: jest.Mock;
    statusCode?: number;
  } = {
    headers,
    statusCode: undefined,
    setHeader: jest.fn((name: string, value: string) => {
      headers[name] = value;
    }),
    status: jest.fn((code: number) => {
      res.statusCode = code;
      return res;
    }),
    end: jest.fn(),
  };
  return res;
}

function mockReq(opts: {
  origin?: string;
  method?: string;
  reqMethod?: string;
  reqHeaders?: string;
}): {
  headers: Record<string, string | undefined>;
  method: string;
} {
  return {
    headers: {
      origin: opts.origin,
      'access-control-request-method': opts.reqMethod,
      'access-control-request-headers': opts.reqHeaders,
    },
    method: opts.method ?? 'GET',
  };
}

describe('cors middleware', () => {
  const ORIGINAL_ENV = process.env.DEPLOYMENT_SLOT;

  beforeEach(() => {
    process.env.DEPLOYMENT_SLOT = 'production';
  });

  afterEach(() => {
    process.env.DEPLOYMENT_SLOT = ORIGINAL_ENV;
  });

  test('catalog contains exactly 5 origins (scope guard)', () => {
    expect(CORS_ALLOWED_ORIGINS).toHaveLength(5);
  });

  test('no wildcard "*" origin', () => {
    for (const entry of CORS_ALLOWED_ORIGINS) {
      expect(entry.origin).not.toBe('*');
    }
  });

  test('every production-slot origin is HTTPS', () => {
    for (const entry of CORS_ALLOWED_ORIGINS) {
      if (entry.slots.has('production')) {
        expect(entry.origin.startsWith('https://')).toBe(true);
      }
    }
  });

  test('currentSlot defaults to "local" when env is unset', () => {
    delete process.env.DEPLOYMENT_SLOT;
    expect(currentSlot()).toBe('local');
  });

  test('currentSlot rejects unknown values + falls back to local', () => {
    process.env.DEPLOYMENT_SLOT = 'banana';
    expect(currentSlot()).toBe('local');
  });

  test('isOriginAllowed true for catalog entry in its slot', () => {
    expect(
      isOriginAllowed('https://app.psyclinicai.com', 'production'),
    ).toBe(true);
  });

  test('isOriginAllowed false for catalog entry in different slot', () => {
    expect(isOriginAllowed('https://app.psyclinicai.com', 'local')).toBe(
      false,
    );
  });

  test('isOriginAllowed false for unknown origin', () => {
    expect(
      isOriginAllowed('https://evil.example.com', 'production'),
    ).toBe(false);
  });

  test('same-origin (no Origin header) skips CORS headers + next()', () => {
    const res = mockRes();
    const next = jest.fn();
    cors(mockReq({}) as never, res as never, next);
    expect(res.headers['Access-Control-Allow-Origin']).toBeUndefined();
    expect(next).toHaveBeenCalledTimes(1);
  });

  test('disallowed origin on GET → next() without CORS headers (silent fail)', () => {
    const res = mockRes();
    const next = jest.fn();
    cors(
      mockReq({ origin: 'https://evil.example.com' }) as never,
      res as never,
      next,
    );
    expect(res.headers['Access-Control-Allow-Origin']).toBeUndefined();
    expect(next).toHaveBeenCalledTimes(1);
  });

  test('disallowed origin on preflight (OPTIONS) → 403 + no Allow-Origin', () => {
    const res = mockRes();
    const next = jest.fn();
    cors(
      mockReq({
        origin: 'https://evil.example.com',
        method: 'OPTIONS',
      }) as never,
      res as never,
      next,
    );
    expect(res.statusCode).toBe(403);
    expect(next).not.toHaveBeenCalled();
  });

  test('allowed origin (production app) echoes Origin + credentials + Vary', () => {
    const res = mockRes();
    const next = jest.fn();
    cors(
      mockReq({ origin: 'https://app.psyclinicai.com' }) as never,
      res as never,
      next,
    );
    expect(res.headers['Access-Control-Allow-Origin']).toBe(
      'https://app.psyclinicai.com',
    );
    expect(res.headers['Access-Control-Allow-Credentials']).toBe('true');
    expect(res.headers['Vary']).toBe('Origin');
    expect(next).toHaveBeenCalledTimes(1);
  });

  test('allowed origin without credentials (marketing) does NOT set Allow-Credentials', () => {
    const res = mockRes();
    const next = jest.fn();
    cors(
      mockReq({ origin: 'https://www.psyclinicai.com' }) as never,
      res as never,
      next,
    );
    expect(res.headers['Access-Control-Allow-Origin']).toBe(
      'https://www.psyclinicai.com',
    );
    expect(
      res.headers['Access-Control-Allow-Credentials'],
    ).toBeUndefined();
  });

  test('preflight from allowed origin → 204 + reflects requested method + headers', () => {
    const res = mockRes();
    const next = jest.fn();
    cors(
      mockReq({
        origin: 'https://app.psyclinicai.com',
        method: 'OPTIONS',
        reqMethod: 'PUT',
        reqHeaders: 'Authorization, Content-Type',
      }) as never,
      res as never,
      next,
    );
    expect(res.statusCode).toBe(204);
    expect(res.headers['Access-Control-Allow-Methods']).toBe('PUT');
    expect(res.headers['Access-Control-Allow-Headers']).toBe(
      'Authorization, Content-Type',
    );
    expect(res.headers['Access-Control-Max-Age']).toBe('600');
    expect(next).not.toHaveBeenCalled();
  });

  test('production-slot does NOT allow staging or preview origins', () => {
    expect(
      isOriginAllowed('https://staging.psyclinicai.com', 'production'),
    ).toBe(false);
    expect(
      isOriginAllowed('https://preview.psyclinicai.com', 'production'),
    ).toBe(false);
  });

  test('every catalog origin is canonical (scheme + host[:port], no path / no trailing slash)', () => {
    for (const entry of CORS_ALLOWED_ORIGINS) {
      const m = /^https?:\/\/[^/]+(\/.*)?$/.exec(entry.origin);
      expect(m).not.toBeNull();
      expect(m![1] ?? '').toBe('');
      expect(entry.origin.endsWith('/')).toBe(false);
    }
  });
});
