// Screenshot every PsyClinicAI route after Sprint 17 polish.
//
// Usage:
//   1. `flutter build web --release`
//   2. `node scripts/screenshots/sprint17_screens.mjs`
// The script boots a static HTTP server on http://127.0.0.1:8765,
// drives a headless Chromium across every named route, and writes
// PNGs into `docs/screenshots/sprint-17/`.
import { chromium } from 'playwright';
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const ROOT = path.resolve(path.dirname(__filename), '..', '..');
const WEB_DIR = path.join(ROOT, 'build', 'web');
const OUT_DIR = path.join(ROOT, 'docs', 'screenshots', 'sprint-17');
const PORT = 8765;
const VIEWPORT = { width: 1440, height: 900 };

const ROUTES = [
  '/landing',
  '/login',
  '/onboarding',
  '/auth/password_reset',
  '/dashboard',
  '/patients',
  '/patient/detail',
  '/patients/intake',
  '/patients/chart',
  '/patients/consents',
  '/appointments',
  '/caseload',
  '/session',
  '/session_management',
  '/group_session',
  '/safety_plan',
  '/treatment_plan',
  '/mood_tracking',
  '/outcomes',
  '/ai_chatbot',
  '/ai_diagnosis',
  '/e_prescription',
  '/superbill',
  '/billing/preauth',
  '/assessments/result',
  '/scales/cssrs',
  '/scales/audit',
  '/feature_system',
  '/supervision/queue',
  '/portal',
  '/settings',
  '/settings/profile',
  '/settings/mfa',
  '/settings/api_keys',
  '/settings/audit_log',
  '/settings/account_deletion',
  '/settings/data_export',
  '/settings/payments',
  '/settings/telehealth',
  '/trust',
  '/trust/subprocessors',
  '/trust/security_controls',
  '/trust/incident_response',
  '/dpa',
  '/baa',
  '/privacy',
  '/security',
  '/tos',
  '/about',
  '/changelog',
  '/contact',
  '/press',
  '/status',
];

function safeMime(ext) {
  return (
    {
      '.html': 'text/html; charset=utf-8',
      '.js': 'application/javascript; charset=utf-8',
      '.css': 'text/css; charset=utf-8',
      '.json': 'application/json; charset=utf-8',
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.svg': 'image/svg+xml',
      '.wasm': 'application/wasm',
      '.woff': 'font/woff',
      '.woff2': 'font/woff2',
      '.ttf': 'font/ttf',
      '.ico': 'image/x-icon',
    }[ext] ?? 'application/octet-stream'
  );
}

function startServer(rootDir, port) {
  return new Promise((resolve) => {
    const server = http.createServer((req, res) => {
      const url = decodeURIComponent((req.url ?? '/').split('?')[0]);
      let target = path.join(rootDir, url);
      if (!fs.existsSync(target) || fs.statSync(target).isDirectory()) {
        target = path.join(rootDir, 'index.html');
      }
      try {
        const data = fs.readFileSync(target);
        res.writeHead(200, { 'Content-Type': safeMime(path.extname(target)) });
        res.end(data);
      } catch {
        res.writeHead(404).end('not found');
      }
    });
    server.listen(port, '127.0.0.1', () => resolve(server));
  });
}

function slug(route) {
  return route === '/' ? 'home' : route.replace(/^\//, '').replace(/\//g, '-');
}

async function waitForFlutter(page) {
  await page.waitForLoadState('networkidle', { timeout: 30_000 });
  await page.waitForFunction(() => Boolean(window._flutter), {
    timeout: 30_000,
  });
  await page.waitForTimeout(900);
}

async function main() {
  if (!fs.existsSync(path.join(WEB_DIR, 'index.html'))) {
    throw new Error(
      `Missing ${WEB_DIR}/index.html — run \`flutter build web --release\` first.`,
    );
  }
  fs.mkdirSync(OUT_DIR, { recursive: true });

  const server = await startServer(WEB_DIR, PORT);
  console.log(`Static server up on http://127.0.0.1:${PORT}`);

  const browser = await chromium.launch();
  const context = await browser.newContext({ viewport: VIEWPORT });
  const page = await context.newPage();

  await page.goto(`http://127.0.0.1:${PORT}/`);
  await waitForFlutter(page);
  await page.screenshot({
    path: path.join(OUT_DIR, '00-splash.png'),
    fullPage: true,
  });

  let ok = 0;
  const failures = [];
  for (let i = 0; i < ROUTES.length; i++) {
    const route = ROUTES[i];
    const file = `${String(i + 1).padStart(2, '0')}-${slug(route)}.png`;
    try {
      await page.goto(`http://127.0.0.1:${PORT}/#${route}`, {
        waitUntil: 'networkidle',
      });
      await page.waitForTimeout(800);
      await page.screenshot({
        path: path.join(OUT_DIR, file),
        fullPage: true,
      });
      ok++;
      console.log(`  ok ${route} -> ${file}`);
    } catch (e) {
      failures.push({ route, error: String(e) });
      console.warn(`  fail ${route}: ${e}`);
    }
  }

  await browser.close();
  server.close();

  console.log(`\nDone. ${ok}/${ROUTES.length} routes captured.`);
  if (failures.length) {
    console.log(`Failures:`);
    for (const f of failures) console.log(` - ${f.route}: ${f.error}`);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
