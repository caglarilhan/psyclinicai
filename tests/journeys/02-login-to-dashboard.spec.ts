import { test, expect } from '@playwright/test';

/**
 * Journey 02 — Clinician opens /#/login, the Flutter SPA mounts, and
 * the dashboard route serves a Flutter view without fatal console
 * errors.
 *
 * Real form submission depends on Firebase Auth emulator wiring, which
 * lives outside this skeleton. We assert the route loads + the SPA
 * paints first frame.
 */
test.describe('Journey · login → dashboard', () => {
  test('/#/login mounts the Flutter SPA', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', (e) => errors.push(e.message));
    await page.goto('/#/login');
    await page.waitForSelector('flutter-view, flt-glass-pane', {
      timeout: 30_000,
    });
    await page.waitForTimeout(1500);
    expect(errors, errors.join('\n')).toEqual([]);
  });

  test('/#/dashboard route resolves (200, SPA paints)', async ({ page }) => {
    const res = await page.goto('/#/dashboard');
    expect(res?.status()).toBe(200);
    await page.waitForSelector('flutter-view, flt-glass-pane', {
      timeout: 30_000,
    });
  });
});
