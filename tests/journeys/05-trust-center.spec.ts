import { test, expect } from '@playwright/test';

/**
 * Journey 05 — Buyer/security reviewer walks the Trust Center.
 * Skeleton verifies trust + sub-processors + status + DPA routes all
 * render the SPA, and the public /healthcheck Cloud Function emits a
 * JSON body when reachable (skipped if no functions emulator URL).
 */
test.describe('Journey · trust center', () => {
  const TRUST_ROUTES = [
    '/#/trust',
    '/#/sub-processors',
    '/#/status',
    '/#/dpa',
    '/#/baa',
  ];

  for (const route of TRUST_ROUTES) {
    test(`${route} mounts the SPA`, async ({ page }) => {
      await page.goto(route);
      await page.waitForSelector('flutter-view, flt-glass-pane', {
        timeout: 30_000,
      });
      await page.waitForTimeout(1500);
    });
  }

  test('healthcheck endpoint (best-effort) returns valid JSON', async ({
    request,
  }) => {
    const base = process.env.PSY_FUNCTIONS_BASE ?? '';
    test.skip(!base, 'PSY_FUNCTIONS_BASE not set — skipping live probe');
    const res = await request.get(`${base}/healthcheck`);
    expect(res.ok()).toBeTruthy();
    const body = await res.json();
    expect(body.status).toMatch(/ok|degraded|outage/);
    expect(typeof body.uptime_seconds).toBe('number');
  });
});
