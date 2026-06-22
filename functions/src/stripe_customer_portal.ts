/**
 * Sprint 33 P2 — Stripe Customer Portal redirect endpoint.
 *
 * Clinician taps "Manage subscription" in Settings → Billing. We mint
 * a Customer-Portal session via Stripe and return the URL; the app
 * opens it in an external browser (Stripe Portal is the only place
 * card-edits live so we stay outside the PCI scope).
 *
 * Skill-panel coverage: senior-backend (handler), finance-billing-ops
 * (Stripe Portal product config), senior-frontend (redirect UX).
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {applyCors, authorizeUid} from "./lib/auth";
import {stripeClient} from "./lib/stripe";

interface PortalRequest {
  returnUrl?: string;
}

/**
 * Pure helper — validates the return URL against an explicit allow-list
 * so an attacker cannot redirect the post-portal user to a phishing
 * domain. Exported for unit tests.
 */
export function isAllowedReturnUrl(input: string | undefined): boolean {
  if (!input) return false;
  try {
    const u = new URL(input);
    const allowed = new Set([
      "psyclinicai.web.app",
      "psyclinicai.com",
      "www.psyclinicai.com",
      "localhost", // dev only — Cloud Run rejects http: anyway
    ]);
    if (!allowed.has(u.hostname)) return false;
    if (u.protocol !== "https:" && u.hostname !== "localhost") {
      return false;
    }
    return true;
  } catch (_e) {
    return false;
  }
}

export const stripeCustomerPortalSession = functions
  .runWith({minInstances: 0, memory: "256MB", timeoutSeconds: 20})
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
    if (applyCors(req, res)) return;
    const uid = await authorizeUid(req, "stripeCustomerPortalSession");
    if (!uid) {
      res.status(401).json({error: "unauthenticated"});
      return;
    }
    const body = (req.body ?? {}) as PortalRequest;
    const returnUrl = body.returnUrl ?? "https://psyclinicai.web.app/settings";
    if (!isAllowedReturnUrl(returnUrl)) {
      res.status(400).json({error: "return_url_not_allowed"});
      return;
    }

    const tenantId = uid; // solo-practice invariant.
    const stripeSubDoc = await admin
      .firestore()
      .doc(`tenants/${tenantId}/private/stripe_subscription`)
      .get();
    const customerId =
      (stripeSubDoc.data() ?? {}).customer_id ??
      (stripeSubDoc.data() ?? {}).subscription_id;
    if (typeof customerId !== "string" || customerId.length === 0) {
      res.status(404).json({error: "no_stripe_customer"});
      return;
    }

    try {
      const stripe = stripeClient();
      const session = await stripe.billingPortal.sessions.create({
        customer: customerId,
        return_url: returnUrl,
      });
      res.json({url: session.url});
    } catch (e) {
      functions.logger.error("stripe_customer_portal.create_failed", {
        error: String(e).slice(0, 200),
      });
      res.status(502).json({error: "portal_session_failed"});
    }
  });
