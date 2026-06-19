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
 * Assign a tenant_id claim and mirror the assignment into Firestore for
 * auditability. Idempotent — re-running with the same args is a no-op
 * relative to claims, only the mirror doc bumps `assigned_at`.
 */
async function applyClaim(
  uid: string,
  tenantId: string,
  assignedBy: string,
): Promise<void> {
  const user = await admin.auth().getUser(uid);
  const existing = (user.customClaims ?? {}) as Record<string, unknown>;
  const next = { ...existing, tenant_id: tenantId };
  await admin.auth().setCustomUserClaims(uid, next);
  await admin
    .firestore()
    .doc(`users/${uid}/tenant_assignment/current`)
    .set(
      {
        tenant_id: tenantId,
        assigned_at: admin.firestore.FieldValue.serverTimestamp(),
        assigned_by: assignedBy,
      },
      { merge: false },
    );
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
    await applyClaim(uid, tenantId, context.auth.uid);
    functions.logger.info("tenant_claim_reassigned", {
      uid,
      tenant_id: tenantId,
      assigned_by: context.auth.uid,
    });
    return { ok: true, uid, tenant_id: tenantId };
  },
);
