import { test, expect, Page } from '@playwright/test';

/**
 * Flutter SPA boot tests — JS enabled, exercise the live renderer.
 *
 * We can't easily click inside Flutter canvaskit (no DOM nodes), but we
 * can verify the mount happens, the document title flips per route, and
 * no fatal console errors are thrown during boot.
 */

const FATAL_PATTERNS = [
  /is not a subtype of type/i,
  /uncaught (in promise )?error/i,
  /failed to fetch.*main\.dart\.js/i,
  /assetmanifest.*404/i,
];

async function gotoAndSettle(page: Page, path: string): Promise<string[]> {
  const errors: string[] = [];
  page.on('console', (msg) => {
    if (msg.type() === 'error') errors.push(msg.text());
  });
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto(path);
  await page.waitForSelector('flutter-view, flt-glass-pane', {
    timeout: 30_000,
  });
  // Give the first frame ~1.5s to render before reading title.
  await page.waitForTimeout(1500);
  return errors;
}

test.describe('Flutter SPA boot', () => {
  test('/ boots without fatal console errors', async ({ page }) => {
    const errors = await gotoAndSettle(page, '/');
    const fatal = errors.filter((e) =>
      FATAL_PATTERNS.some((p) => p.test(e)),
    );
    expect(fatal, fatal.join('\n')).toEqual([]);
  });

  const routes: Array<[string, RegExp]> = [
    ['/', /PsyClinicAI/i],
    ['/#/security', /Security/i],
    ['/#/about', /About|PsyClinicAI/i],
    ['/#/privacy', /Privacy/i],
    ['/#/tos', /Terms/i],
    ['/#/contact', /Contact/i],
    ['/#/changelog', /Changelog/i],
    ['/#/status', /Status/i],
  ];

  for (const [path, titleRe] of routes) {
    test(`document.title updates for ${path}`, async ({ page }) => {
      await gotoAndSettle(page, path);
      const title = await page.title();
      expect(title, `title for ${path}`).toMatch(titleRe);
    });
  }

  test('unknown route still returns 200 (SPA fallback)', async ({
    page,
  }) => {
    const res = await page.goto('/#/this-route-does-not-exist');
    expect(res?.status()).toBe(200);
    await page.waitForSelector('flutter-view, flt-glass-pane');
  });
});
