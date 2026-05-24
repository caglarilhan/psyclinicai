import { test, expect } from '@playwright/test';

/**
 * SSR fallback tests — what Google, LinkedIn, Twitter and other bots
 * (or any JS-disabled client) see when they fetch the landing page.
 * We force JS off so the <noscript> SSR block becomes the live DOM.
 */
test.use({ javaScriptEnabled: false });

test.describe('Landing SSR fallback', () => {
  test('hero copy is present in the noscript block', async ({ page }) => {
    await page.goto('/');
    const html = await page.content();
    expect(html).toContain(
      'Your AI co-pilot for therapy sessions. Notes drafted in 30 seconds.',
    );
    expect(html).toContain('HIPAA-aligned');
    expect(html).toContain('GDPR Article 28 DPA');
    expect(html).toContain('EU data residency');
    expect(html).toContain('AES-256 + TLS 1.3');
    expect(html).toContain('On-device transcription');
    expect(html).toContain('BYOK Anthropic Claude');
  });

  test('JSON-LD SoftwareApplication schema is present', async ({ page }) => {
    await page.goto('/');
    const html = await page.content();
    expect(html).toContain('"@type": "SoftwareApplication"');
    expect(html).toContain('"name": "PsyClinicAI"');
    expect(html).toContain('"applicationCategory": "MedicalApplication"');
    expect(html).toContain('"priceCurrency": "USD"');
  });

  test('OG + Twitter meta tags are set for social shares', async ({
    page,
  }) => {
    await page.goto('/');
    const html = await page.content();
    expect(html).toMatch(/<meta property="og:title"/);
    expect(html).toMatch(/<meta property="og:description"/);
    expect(html).toMatch(/<meta property="og:image"/);
    expect(html).toMatch(/<meta name="twitter:card"/);
    expect(html).toContain('summary_large_image');
  });

  test('canonical link points at psyclinicai.com', async ({ page }) => {
    await page.goto('/');
    const href = await page
      .locator('link[rel="canonical"]')
      .getAttribute('href');
    expect(href).toBe('https://psyclinicai.com/');
  });

  test('CTA links to /login', async ({ page }) => {
    await page.goto('/');
    const cta = page.locator('a.cta').first();
    await expect(cta).toBeVisible();
    expect(await cta.getAttribute('href')).toBe('/login');
  });

  test('SSR block contains the differentiators + built-for sections',
      async ({ page }) => {
    await page.goto('/');
    const html = await page.content();
    expect(html).toContain('Built for');
    expect(html).toContain('What makes PsyClinicAI different');
    expect(html).toContain('Audio never leaves the device.');
    expect(html).toContain('Superbill PDF in one click.');
  });
});
