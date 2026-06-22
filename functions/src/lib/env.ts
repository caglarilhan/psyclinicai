/**
 * Fail-fast environment loader.
 *
 * Cloud Functions used to default missing env vars to "" — which let
 * the runtime call upstream APIs with an empty bearer token. We now
 * crash on cold-start instead, so deploy mistakes never reach prod.
 */

function read(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(
      `Required environment variable ${name} is missing — refusing to start.`,
    );
  }
  return value;
}

/**
 * Lazy proxy: env vars are read on first access so unit tests (where
 * we never touch the property) can import the module without the
 * vars being set.
 */
export const env = new Proxy(
  {} as Record<string, string>,
  {
    get(_target, key: string): string {
      return read(key);
    },
  },
);

/**
 * CORS allow-list — comma-separated list in ALLOWED_ORIGINS, falls
 * back to APP_URL for backward compatibility. Returns `null` when
 * the request origin is not in the list (handler should refuse).
 * Pure for unit testing.
 */
export function resolveCorsOrigin(
  requestOrigin: string | undefined,
): string | null {
  const raw =
    process.env.ALLOWED_ORIGINS ?? process.env.APP_URL ?? "";
  const list = raw
    .split(",")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
  if (list.length === 0) return null;
  if (!requestOrigin) return list[0];
  return list.includes(requestOrigin) ? requestOrigin : null;
}
