/**
 * `noshowPredict` — clinician-only POST that scores a scheduled
 * appointment, picks the risk tier, and returns the recovery playbook
 * the dashboard renders. PILAR 3 / PR-2.
 *
 * Contract:
 *   POST /noshowPredict
 *   Body: {
 *     tenantId, appointmentId, patientId,
 *     features: { [feature_key]: number | boolean }
 *   }
 *   Reply: {
 *     probability, tier, modelVersion,
 *     playbook: {
 *       confirmCadenceHours, smsConfirmHours, callConfirmHours,
 *       depositRequired, waitlistOfferOnCancel, estUsdSavedPerSlot
 *     }
 *   }
 *
 * Safety posture:
 *   - Clinician-only auth (`authorizeClinicianUid`).
 *   - N24 + N25 (`clinician-dashboard-read`).
 *   - Catalog whitelist: any feature key the catalog doesn't pin is
 *     rejected with 400. No quiet fallthrough.
 *   - Audit row stores feature KEYS only, not their values — keeps
 *     the audit log out of PHI scope.
 *   - No PHI in the reply.
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {applyCors, authorizeClinicianUid} from "./lib/auth";
import {
  NOSHOW_FEATURES,
  NoShowRiskTier,
  playbookForTier,
  tierForProbability,
} from "./lib/noshow_feature_catalog";
import {
  modelMetadata,
  predictNoShowProbability,
  PredictInput,
} from "./lib/noshow_model";
import {applyRateLimit, applySecurityHeaders} from "./lib/security_chain";

interface PredictBody {
  tenantId: string;
  appointmentId: string;
  patientId: string;
  features: PredictInput;
}

export const noshowPredict = functions
  .runWith({memory: "256MB", timeoutSeconds: 30})
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
    applySecurityHeaders(res);
    if (applyCors(req, res)) return;
    if (applyRateLimit(req, res, "clinician-dashboard-read")) return;
    if (req.method !== "POST") {
      res.status(405).json({error: "post_only"});
      return;
    }

    const uid = await authorizeClinicianUid(req, "noshowPredict");
    if (!uid) {
      res.status(401).json({error: "unauthorized"});
      return;
    }

    let body: PredictBody;
    try {
      body = req.body as PredictBody;
      if (
        !body ||
        typeof body.tenantId !== "string" ||
        typeof body.appointmentId !== "string" ||
        typeof body.patientId !== "string" ||
        !body.features ||
        typeof body.features !== "object"
      ) {
        throw new Error(
          "missing tenantId / appointmentId / patientId / features",
        );
      }
    } catch (e) {
      res.status(400).json({error: "bad_request", detail: String(e)});
      return;
    }

    const allowed = new Set(NOSHOW_FEATURES.map((f) => f.key));
    for (const k of Object.keys(body.features)) {
      if (!allowed.has(k)) {
        res.status(400).json({error: "unknown_feature", key: k});
        return;
      }
    }

    let probability: number;
    try {
      probability = predictNoShowProbability(body.features);
    } catch (e) {
      res.status(400).json({error: "predict_failed", detail: String(e)});
      return;
    }

    const tier: NoShowRiskTier = tierForProbability(probability);
    const playbook = playbookForTier(tier);
    const meta = modelMetadata();

    await admin
      .firestore()
      .collection("noshow_predictions")
      .add({
        tenant_id: body.tenantId,
        clinic_id: uid,
        appointment_id: body.appointmentId,
        patient_id: body.patientId,
        probability,
        tier,
        model_version: meta.version,
        features_used: Object.keys(body.features),
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

    res.json({
      probability,
      tier,
      modelVersion: meta.version,
      playbook: {
        confirmCadenceHours: [...playbook.confirmCadenceHours],
        smsConfirmHours: playbook.smsConfirmHours,
        callConfirmHours: playbook.callConfirmHours,
        depositRequired: playbook.depositRequired,
        waitlistOfferOnCancel: playbook.waitlistOfferOnCancel,
        estUsdSavedPerSlot: playbook.estUsdSavedPerSlot,
      },
    });
  });
