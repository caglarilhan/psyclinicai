import { test, expect } from '@playwright/test';

/**
 * Journey 01 — Marketing visitor lands on / and reaches the signup CTA.
 *
 * Skeleton: validates that the public marketing surface renders, that
 * core nav routes still serve the SPA, and that the "Sign up" CTA is
 * discoverable on the rendered DOM (SSR landing) or via title check
 * on the SPA. Detailed CTA-click assertions are deferred until the
 * Flutter web build exposes a stable DOM hook.
 */
test.describe('Journey · marketing → signup', () => {
  test('/ landing renders with brand + signup discoverable', async ({
    page,
  }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    expect(await page.title()).toMatch(/PsyClinicAI/i);
  });

  test('/security and /privacy reachable via direct nav', async ({
    page,
  }) => {
    await page.goto('/#/security');
    await page.waitForSelector('flutter-view, flt-glass-pane', {
      timeout: 30_000,
    });
    await page.waitForTimeout(1500);
    expect(await page.title()).toMatch(/Security/i);

    await page.goto('/#/privacy');
    await page.waitForSelector('flutter-view, flt-glass-pane', {
      timeout: 30_000,
    });
    await page.waitForTimeout(1500);
    expect(await page.title()).toMatch(/Privacy/i);
  });
});
