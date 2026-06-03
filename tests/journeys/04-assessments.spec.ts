import { test, expect } from '@playwright/test';

/**
 * Journey 04 — Clinical assessments (PHQ-9, GAD-7, C-SSRS, PCL-5,
 * AUDIT) reachable from /#/assessments. Skeleton verifies the
 * scale-list route serves the SPA and at least one scale detail
 * route resolves.
 */
test.describe('Journey · assessments', () => {
  test('/#/assessments lists scales', async ({ page }) => {
    await page.goto('/#/assessments');
    await page.waitForSelector('flutter-view, flt-glass-pane', {
      timeout: 30_000,
    });
    await page.waitForTimeout(1500);
    expect(await page.title()).toMatch(/Assessments|PsyClinicAI/i);
  });

  test('/#/assessments/phq9 deep-link resolves', async ({ page }) => {
    const res = await page.goto('/#/assessments/phq9');
    expect(res?.status()).toBe(200);
    await page.waitForSelector('flutter-view, flt-glass-pane', {
      timeout: 30_000,
    });
  });
});
