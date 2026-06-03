import { test, expect } from '@playwright/test';

/**
 * Journey 03 — Session core (caseload → session note → safety plan
 * → superbill). Skeleton verifies each route serves the SPA shell;
 * deep interaction lives in widget tests where DOM hooks aren't
 * required.
 */
const SESSION_ROUTES = [
  '/#/caseload',
  '/#/session',
  '/#/safety-plan',
  '/#/superbill',
];

test.describe('Journey · session flow', () => {
  for (const route of SESSION_ROUTES) {
    test(`${route} renders without fatal errors`, async ({ page }) => {
      const errors: string[] = [];
      page.on('pageerror', (e) => errors.push(e.message));
      await page.goto(route);
      await page.waitForSelector('flutter-view, flt-glass-pane', {
        timeout: 30_000,
      });
      await page.waitForTimeout(1500);
      expect(errors, errors.join('\n')).toEqual([]);
    });
  }
});
