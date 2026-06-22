/**
 * `setTenantClaim` — Sprint 29 S-03.
 *
 * Two surfaces:
 *   • `assignTenantOnCreate` (Auth onCreate trigger) — every new
 *     account is given a `tenant_id` custom claim equal to the user
 *     uid (solo-practice invariant, same as Firestore rules' clinicId).
 *     This is what unblocks `DEFAULT_TENANT_ID=""` in the psyrag hub —
 *     once this trigger ships, every authenticated request carries an
 *     explicit claim and the open-signup fallback is no longer needed.
 *   • `adminSetTenantClaim` (HTTPS callable, admin-only) — lets a
 *     platform admin re-bind a user to a different tenant during
 *     migrations or onboarding to a group practice. Audited.
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * M-12 (audit 2026-06-21) — reserved tenant prefixes that only the
 * platform team may assign. Prevents an admin from re-binding a user
 * into the platform tenant or a system-internal namespace.
 */
export const RESERVED_PREFIXES: ReadonlyArray<string> = [
  "platform_",
  "system_",
  "internal_",
];

/**
 * M-12 — strict tenant id format. Firestore doc IDs cannot contain
 * `/` (path injection) and we reject everything outside a small
 * alphanumeric + hyphen + underscore window so log/metric scrapers
 * stay parseable. Max 64 chars matches the Auth uid budget.
 */
const TENANT_ID_PATTERN = /^[a-zA-Z0-9_-]{1,64}$/;

export function isValidTenantId(value: string): boolean {
  return TENANT_ID_PATTERN.test(value);
}

/**
 * Assign a tenant_id claim and mirror the assignment into Firestore for
 * auditability. Idempotent — re-running with the same args is a no-op
 * relative to claims, only the mirror doc bumps `assigned_at`. The
 * M-12 fix also writes a dedicated `admin_actions/{auto}` row so the
 * SIEM can stream every privileged reassignment without scanning the
 * per-user mirror docs.
 */
async function applyClaim(
  uid: string,
  tenantId: string,
  assignedBy: string,
): Promise<void> {
  const user = await admin.auth().getUser(uid);
  const existing = (user.customClaims ?? {}) as Record<string, unknown>;
  const prevTenant = (existing.tenant_id as string | undefined) ?? null;
  const next = { ...existing, tenant_id: tenantId };
  await admin.auth().setCustomUserClaims(uid, next);
  const db = admin.firestore();
  await db.doc(`users/${uid}/tenant_assignment/current`).set(
    {
      tenant_id: tenantId,
      assigned_at: admin.firestore.FieldValue.serverTimestamp(),
      assigned_by: assignedBy,
    },
    { merge: false },
  );
  // M-12 dedicated admin escalation log so the SIEM streams every
  // reassignment without scanning per-user mirror docs.
  await db.collection("admin_actions").add({
    action: "tenant_reassign",
    target_uid: uid,
    prev_tenant_id: prevTenant,
    next_tenant_id: tenantId,
    actor_uid: assignedBy,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Auth onCreate — newly registered users get tenant_id = uid by
 * default (solo-practice). Group practices can override via
 * adminSetTenantClaim later; this default keeps the door closed.
 */
export const assignTenantOnCreate = functions.auth.user().onCreate(
  async (user) => {
    try {
      await applyClaim(user.uid, user.uid, "auth.onCreate");
      functions.logger.info("tenant_claim_assigned", {
        uid: user.uid,
        tenant_id: user.uid,
        source: "auth.onCreate",
      });
    } catch (e) {
      functions.logger.error("tenant_claim_assign_failed", {
        uid: user.uid,
        error: String(e).slice(0, 200),
      });
      throw e;
    }
  },
);

/**
 * HTTPS callable for platform admins. Caller must already carry
 * `is_platform_admin: true` on their token (only platform team has
 * this; assigned manually via Firebase console or out-of-band).
 */
export const adminSetTenantClaim = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Sign-in required.",
      );
    }
    const callerClaims = (context.auth.token ?? {}) as Record<string, unknown>;
    if (callerClaims["is_platform_admin"] !== true) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Platform admin role required.",
      );
    }
    const uid = typeof data?.uid === "string" ? data.uid : "";
    const tenantId = typeof data?.tenant_id === "string" ? data.tenant_id : "";
    if (uid.length === 0 || tenantId.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "uid + tenant_id required.",
      );
    }
    // M-12 — strict format for both ids so neither value can carry
    // a path separator into the doc write that follows.
    if (!isValidTenantId(uid) || !isValidTenantId(tenantId)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "uid and tenant_id must match ^[A-Za-z0-9_-]{1,64}$.",
      );
    }
    // M-12 — reserved prefixes are platform-only. Even a verified
    // platform admin must NOT bind a normal customer uid into a
    // system tenant namespace via this callable; that path goes
    // through the manual console out-of-band.
    const lower = tenantId.toLowerCase();
    if (RESERVED_PREFIXES.some((p) => lower.startsWith(p))) {
      functions.logger.warn("adminSetTenantClaim.reserved_prefix_denied", {
        actor: context.auth.uid,
        target_uid: uid,
        tenant_id: tenantId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "Reserved tenant prefix; use the platform console.",
      );
    }
    await applyClaim(uid, tenantId, context.auth.uid);
    functions.logger.info("tenant_claim_reassigned", {
      uid,
      tenant_id: tenantId,
      assigned_by: context.auth.uid,
    });
    return { ok: true, uid, tenant_id: tenantId };
  },
);
