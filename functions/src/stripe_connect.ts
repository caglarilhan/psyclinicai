/**
 * Stripe Connect Express onboarding for clinician tenants.
 *
 * Two endpoints:
 *   POST /stripeConnectOnboard — create (or refresh) the Express
 *     account for the caller's tenant + return a hosted account link.
 *   POST /stripeConnectWebhook — sync `account.updated` events into
 *     `tenants/{tenantId}/private/stripe_connect` so the Settings
 *     panel shows accurate requirements + charges/payouts flags.
 *
 * Sprint 21 release-blocker closure (rapor 12 cpo-advisor finding).
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {applyCors, authorizeUid} from "./lib/auth";
import {env} from "./lib/env";
import {stripeClient} from "./lib/stripe";

interface OnboardBody {
  tenantId: string;
  refreshUrl: string;
  returnUrl: string;
  /** ISO 3166-1 alpha-2; defaults to DE for the EU baseline. */
  country?: string;
}

export const stripeConnectOnboard = functions.https.onRequest(
  async (req, res) => {
    if (applyCors(req, res)) return;
    const uid = await authorizeUid(req, "stripeConnectOnboard");
    if (!uid) {
      res.status(401).json({error: "unauthorized"});
      return;
    }

    let body: OnboardBody;
    try {
      body = req.body as OnboardBody;
      if (!body || typeof body.tenantId !== "string" ||
          typeof body.refreshUrl !== "string" ||
          typeof body.returnUrl !== "string") {
        throw new Error("missing fields");
      }
    } catch (e) {
      res.status(400).json({error: "bad_request", detail: String(e)});
      return;
    }

    const stripe = stripeClient();
    const db = admin.firestore();
    const docRef = db
      .collection("tenants")
      .doc(body.tenantId)
      .collection("private")
      .doc("stripe_connect");
    const snap = await docRef.get();
    let accountId = snap.exists ?
      (snap.data()?.account_id as string | undefined) :
      undefined;

    if (!accountId) {
      const account = await stripe.accounts.create({
        type: "express",
        country: body.country ?? "DE",
        capabilities: {
          card_payments: {requested: true},
          transfers: {requested: true},
        },
        metadata: {tenant_id: body.tenantId, created_by_uid: uid},
      });
      accountId = account.id;
      await docRef.set(
        {
          tenant_id: body.tenantId,
          account_id: accountId,
          status: "pending",
          requirements_due: [],
          charges_enabled: false,
          payouts_enabled: false,
          last_sync_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
    }

    const link = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: body.refreshUrl,
      return_url: body.returnUrl,
      type: "account_onboarding",
    });

    res.json({accountId, url: link.url, expiresAt: link.expires_at});
  }
);

export const stripeConnectWebhook = functions.https.onRequest(
  async (req, res) => {
    const stripe = stripeClient();
    const signature = req.headers["stripe-signature"];
    const secret = env.STRIPE_CONNECT_WEBHOOK_SECRET;
    if (!signature || !secret) {
      res.status(400).json({error: "missing_signature_or_secret"});
      return;
    }

    let event;
    try {
      event = stripe.webhooks.constructEvent(
        (req as unknown as {rawBody: Buffer}).rawBody,
        signature as string,
        secret
      );
    } catch (e) {
      functions.logger.error("stripeConnectWebhook.invalid", {
        error: String(e),
      });
      res.status(400).json({error: "invalid_signature"});
      return;
    }

    if (event.type !== "account.updated") {
      res.json({ignored: true});
      return;
    }

    const account = event.data.object as {
      id: string;
      charges_enabled?: boolean;
      payouts_enabled?: boolean;
      requirements?: {
        currently_due?: string[];
        eventually_due?: string[];
      };
      metadata?: Record<string, string>;
    };
    const tenantId = account.metadata?.tenant_id;
    if (!tenantId) {
      res.json({ignored_no_tenant: true});
      return;
    }

    const requirements = [
      ...(account.requirements?.currently_due ?? []),
      ...(account.requirements?.eventually_due ?? []),
    ];
    const status = account.charges_enabled && account.payouts_enabled ?
      "enabled" :
      requirements.length > 0 ?
        "restricted" :
        "pending";

    // Sprint 29 B-09 — idempotency: Stripe retries up to ~3 d. A racing
    // replay must not double-write tenant state. Atomic check via
    // processed_webhooks/{event.id}.
    const processedRef = admin
      .firestore()
      .collection("processed_webhooks")
      .doc(event.id);
    const tenantRef = admin
      .firestore()
      .collection("tenants")
      .doc(tenantId)
      .collection("private")
      .doc("stripe_connect");

    const result = await admin.firestore().runTransaction(async (tx) => {
      const seen = await tx.get(processedRef);
      if (seen.exists) {
        return "duplicate";
      }
      tx.set(processedRef, {
        event_id: event.id,
        event_type: event.type,
        tenant_id: tenantId,
        processed_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      tx.set(
        tenantRef,
        {
          tenant_id: tenantId,
          account_id: account.id,
          status,
          requirements_due: requirements,
          charges_enabled: account.charges_enabled ?? false,
          payouts_enabled: account.payouts_enabled ?? false,
          last_sync_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      return "applied";
    });

    if (result === "duplicate") {
      functions.logger.info("stripeConnectWebhook.duplicate", {
        eventId: event.id,
      });
    }
    res.json({synced: tenantId, status, idempotency: result});
  }
);
