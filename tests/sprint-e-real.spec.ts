import { test, expect, Page } from '@playwright/test';

/**
 * Sprint E-real verification — the 4 legacy screens that were rewired
 * to real Claude / Firestore / honest roadmap. Canvaskit text is in a
 * canvas, so we verify boot-level signals only:
 *   1. The Flutter shell mounts (<flt-glass-pane> appears).
 *   2. No fatal console errors during 2.5s of settle.
 */

const FATAL = [
  /is not a subtype of type/i,
  /uncaught (in promise )?error/i,
  /Lf.*is not.*subtype.*h/i,
  /RangeError/i,
  /TypeError.*null/i,
];

async function bootRoute(page: Page, path: string): Promise<string[]> {
  const errors: string[] = [];
  page.on('console', (m) => {
    if (m.type() === 'error') errors.push(m.text());
  });
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto(path);
  await page.waitForSelector('flutter-view, flt-glass-pane', {
    timeout: 30_000,
  });
  await page.waitForTimeout(2500);
  return errors;
}

test.describe('Sprint E-real — 4 legacy screens boot cleanly', () => {
  const routes: Array<[string, string]> = [
    ['/#/ai_chatbot', 'AI Chatbot'],
    ['/#/ai_diagnosis', 'AI Diagnosis'],
    ['/#/mood_tracking', 'Mood Tracking'],
    ['/#/e_prescription', 'e-Prescription'],
  ];

  for (const [path, label] of routes) {
    test(`${label} (${path}) boots without fatal errors`, async ({
      page,
    }) => {
      const errors = await bootRoute(page, path);
      const fatal = errors.filter((e) => FATAL.some((p) => p.test(e)));
      expect(fatal, fatal.join('\n')).toEqual([]);
    });

    test(`${label} (${path}) renders a flutter-view`, async ({
      page,
    }) => {
      await bootRoute(page, path);
      const present = await page
        .locator('flutter-view, flt-glass-pane')
        .count();
      expect(present).toBeGreaterThan(0);
    });
  }
});
