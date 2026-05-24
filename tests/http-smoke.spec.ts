import { test, expect, request } from '@playwright/test';

/**
 * HTTP smoke — every public asset the Flutter renderer needs at boot
 * must return 200. We also verify robots.txt / sitemap.xml /
 * security.txt are well-formed.
 */

const assets = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter_bootstrap.js',
  '/flutter.js',
  '/canvaskit/canvaskit.js',
  '/canvaskit/canvaskit.wasm',
  '/assets/AssetManifest.bin.json',
  '/assets/FontManifest.json',
  '/assets/assets/landing/session.png',
  '/assets/assets/landing/dashboard.png',
  '/assets/assets/landing/superbill.png',
  '/assets/assets/landing/phq9.png',
  '/manifest.json',
  '/favicon.png',
  '/robots.txt',
  '/sitemap.xml',
  '/.well-known/security.txt',
];

test.describe('HTTP smoke', () => {
  for (const path of assets) {
    test(`200 OK: ${path}`, async ({ baseURL }) => {
      const ctx = await request.newContext({ baseURL });
      const res = await ctx.get(path);
      expect(res.status(), `${path} should be 200`).toBe(200);
    });
  }

  test('robots.txt references the sitemap', async ({ baseURL }) => {
    const ctx = await request.newContext({ baseURL });
    const res = await ctx.get('/robots.txt');
    const body = await res.text();
    expect(body).toMatch(/Sitemap:.*sitemap\.xml/i);
    expect(body).toMatch(/User-agent:\s*\*/);
  });

  test('security.txt has the canonical RFC 9116 fields', async ({
    baseURL,
  }) => {
    const ctx = await request.newContext({ baseURL });
    const res = await ctx.get('/.well-known/security.txt');
    const body = await res.text();
    expect(body).toMatch(/Contact:\s*mailto:security@psyclinicai\.com/);
    expect(body).toMatch(/Expires:\s*\d{4}-\d{2}-\d{2}T/);
  });

  test('sitemap lists every static page', async ({ baseURL }) => {
    const ctx = await request.newContext({ baseURL });
    const res = await ctx.get('/sitemap.xml');
    const body = await res.text();
    for (const p of [
      'landing',
      'security',
      'about',
      'changelog',
      'status',
      'privacy',
      'tos',
      'contact',
      'press',
      'login',
    ]) {
      expect(body, `sitemap should list /${p}`).toContain(`#/${p}`);
    }
  });
});
