import { defineConfig, devices } from '@playwright/test';

/**
 * PsyClinicAI Flutter web E2E config.
 *
 * The Flutter renderer takes a few seconds to mount (4.3 MB main.dart.js +
 * 6.9 MB canvaskit.wasm) on cold load, so the per-test action timeout is
 * generous. baseURL targets the local Python server the dev runs via
 *   cd build/web && python3 -m http.server 8000
 */
export default defineConfig({
  testDir: './tests',
  timeout: 60_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  retries: process.env.CI ? 1 : 0,
  workers: 1,
  reporter: [
    ['list'],
    ['html', { open: 'never', outputFolder: 'playwright-report' }],
  ],
  use: {
    baseURL: process.env.PSY_BASE_URL ?? 'http://localhost:8000',
    headless: true,
    viewport: { width: 1440, height: 900 },
    actionTimeout: 15_000,
    navigationTimeout: 30_000,
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'desktop-chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'mobile-iphone',
      use: { ...devices['iPhone 14 Pro'] },
    },
  ],
});
