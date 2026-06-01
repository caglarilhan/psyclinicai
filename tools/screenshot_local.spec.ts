import { chromium, devices, Page } from "@playwright/test";
import { mkdirSync } from "fs";
import { resolve } from "path";
import { homedir } from "os";

// Captures one PNG per main route to ~/Downloads/psyclinicai-screens-local.
// Drives the LOCAL `flutter build web` served at http://localhost:8765.
//
// Single browser tab: open root → wait for splash → dismiss cookie modal
// → for each route, set window.location.hash and screenshot.

const BASE = process.env.PSY_BASE_URL ?? "http://localhost:8765/";
const OUT = resolve(
  homedir(),
  "Downloads/psyclinicai-screens-local"
);

// Route → output slug. Mirrors the production capture list (slots 01–27)
// and appends the Sprint 1–4 surfaces (slots 28–33).
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
  ["/settings/audit_log", "21-audit-log"],
  ["/dpa", "22-dpa"],
  ["/baa", "23-baa"],
  ["/trust", "24-trust-center"],
  ["/trust/subprocessors", "25-subprocessors"],
  ["/trust/security_controls", "26-security-controls"],
  ["/trust/incident_response", "27-incident-response"],
  // ────────── Sprint 1–4 new surfaces ──────────
  ["/auth/password_reset", "28-password-reset"],
  ["/settings/mfa", "29-mfa-setup"],
  ["/settings/profile", "30-clinician-profile"],
  ["/patients/intake", "31-patient-intake"],
  ["/patients", "32-patients"],
  ["/appointments", "33-appointments"],
  ["/settings/data_export", "34-data-export"],
];

async function dismissCookie(page: Page) {
  try {
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

  process.stdout.write(`→ 01-splash             ${BASE}\n`);
  await page.goto(BASE, { waitUntil: "domcontentloaded", timeout: 60_000 });
  await page.waitForTimeout(900);
  await page.screenshot({ path: resolve(OUT, "01-splash.png") });

  await page.waitForTimeout(2200);
  await dismissCookie(page);

  for (const [hash, slug] of ROUTES) {
    process.stdout.write(`→ ${slug.padEnd(24)} #${hash}\n`);
    await page.evaluate((h) => {
      window.location.hash = h;
    }, hash);
    await page.waitForTimeout(2400);
    await dismissCookie(page);
    await page.screenshot({ path: resolve(OUT, `${slug}.png`) });
  }

  await browser.close();
  console.log(`\n✓ ${ROUTES.length + 1} screenshots saved to ${OUT}`);
})();
