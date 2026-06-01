import { chromium, devices, Page } from "@playwright/test";
import { mkdirSync } from "fs";
import { resolve } from "path";
import { homedir } from "os";

// Captures one PNG per main route to ~/Downloads/psyclinicai-screens-web.
// Single browser tab: open root → wait for splash to finish → dismiss cookie
// modal → for each route, set window.location.hash and screenshot. (Avoids the
// splash screen's pushReplacement('/landing') from swallowing direct hash URLs.)

const BASE = "https://caglarilhan.github.io/psyclinicai/";
const OUT = resolve(homedir(), "Downloads/psyclinicai-screens");

const ROUTES: Array<[string, string]> = [
  ["/landing", "02-landing"],
  ["/login", "03-login"],
  ["/onboarding", "04-onboarding"],
  ["/dashboard", "05-dashboard"],
  ["/caseload", "06-caseload"],
  ["/session", "07-session"],
  ["/superbill", "08-superbill"],
  ["/safety_plan", "09-safety-plan"],
  ["/treatment_plan", "10-treatment-plan"],
  ["/assessments/phq9", "11-phq9"],
  ["/scales/cssrs", "12-cssrs"],
  ["/scales/pcl5", "13-pcl5"],
  ["/scales/audit", "14-audit"],
  ["/settings", "15-settings"],
  ["/settings/api_keys", "16-api-keys"],
  ["/ai_diagnosis", "17-ai-diagnosis"],
  ["/mood_tracking", "18-mood"],
  ["/e_prescription", "19-e-prescription"],
  ["/feature_system", "20-feature-system"],
];

async function dismissCookie(page: Page) {
  try {
    // Cookie strip button labels evolved: "Got it" (old) → "Accept" (new).
    const got = page.getByRole("button", { name: /accept|got it/i });
    if (await got.isVisible({ timeout: 1500 })) await got.click();
  } catch {
    // no modal — fine
  }
}

(async () => {
  mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch();
  const context = await browser.newContext({
    ...devices["iPhone 13 Pro"], // 390×844, close to iPhone 16 Pro framing
    deviceScaleFactor: 3,
  });
  const page = await context.newPage();

  // Capture the splash first.
  process.stdout.write(`→ 01-splash             ${BASE}\n`);
  await page.goto(BASE, { waitUntil: "domcontentloaded", timeout: 30_000 });
  await page.waitForTimeout(700); // mid-splash
  await page.screenshot({ path: resolve(OUT, "01-splash.png") });

  // Let splash finish, then dismiss the cookie modal once.
  await page.waitForTimeout(2000);
  await dismissCookie(page);

  for (const [hash, slug] of ROUTES) {
    process.stdout.write(`→ ${slug.padEnd(22)} #${hash}\n`);
    // Navigate within the SPA via the hash — Flutter's router picks it up.
    await page.evaluate((h) => {
      window.location.hash = h;
    }, hash);
    await page.waitForTimeout(2200); // route + render settle
    await dismissCookie(page); // in case a different modal pops
    await page.screenshot({ path: resolve(OUT, `${slug}.png`) });
  }

  await browser.close();
  console.log(`\n✓ ${ROUTES.length + 1} screenshots saved to ${OUT}`);
})();
