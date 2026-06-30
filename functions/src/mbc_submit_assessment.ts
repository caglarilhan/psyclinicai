/**
 * `mbcSubmitAssessment` — PUBLIC (no-auth) POST that accepts a
 * patient's MBC submission. PILAR 2 / PR-2.
 *
 * Contract:
 *   POST /mbcSubmitAssessment
 *   Body: { token: string, answers: number[] }
 *   Reply (2xx):
 *     {
 *       score, maxScore, severity, alarmTriggered,
 *       clinicianAction, scaleId
 *     }
 *
 * Safety posture:
 *   - Anonymous endpoint — no Authorization header expected.
 *     Replay defence: server checks the dispatch row has not been
 *     consumed (`submitted_at == null`); a second submit on the same
 *     token returns 409 conflict.
 *   - Brute-force defence: token is 256 bits + N25 rate limit
 *     bucket `public-unauthenticated` keyed on IP.
 *   - Token sha256 stored, not the raw — leak-resilient.
 *   - Expiry enforced: a token past `expires_at` returns 410 gone.
 *   - The response carries no PHI beyond the score itself (which the
 *     patient already knows — they just filled it in).
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {applyCors} from "./lib/auth";
import {applyRateLimit, applySecurityHeaders} from "./lib/security_chain";
import {hashToken} from "./mbc_dispatch_link";
import {canScore, scoreScale} from "./lib/mbc_scoring";

interface SubmitBody {
  token: string;
  answers: number[];
}

export const mbcSubmitAssessment = functions
  .runWith({memory: "256MB", timeoutSeconds: 30})
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
    applySecurityHeaders(res);
    if (applyCors(req, res)) return;
    if (applyRateLimit(req, res, "public-unauthenticated")) return;
    if (req.method !== "POST") {
      res.status(405).json({error: "post_only"});
      return;
    }

    let body: SubmitBody;
    try {
      body = req.body as SubmitBody;
      if (
        !body ||
        typeof body.token !== "string" ||
        !Array.isArray(body.answers)
      ) {
        throw new Error("missing token / answers");
      }
    } catch (e) {
      res.status(400).json({error: "bad_request", detail: String(e)});
      return;
    }

    const db = admin.firestore();
    const tokenHash = hashToken(body.token);

    // Atomic consume — single transaction guarantees no two parallel
    // submits both succeed against the same token.
    let dispatchData: {
      id: string;
      tenant_id: string;
      patient_id: string;
      scale_id: string;
    };
    try {
      dispatchData = await db.runTransaction(async (tx) => {
        const snap = await db
          .collection("mbc_dispatch")
          .where("token_hash", "==", tokenHash)
          .limit(1)
          .get();
        if (snap.empty) {
          throw new HandlerError(404, "token_not_found");
        }
        const doc = snap.docs[0];
        const data = doc.data();
        const expiresMs =
          (data.expires_at as admin.firestore.Timestamp | undefined)
            ?.toMillis() ?? 0;
        if (Date.now() > expiresMs) {
          throw new HandlerError(410, "token_expired");
        }
        if (data.submitted_at) {
          throw new HandlerError(409, "already_submitted");
        }
        if (typeof data.scale_id !== "string" || !canScore(data.scale_id)) {
          throw new HandlerError(500, "corrupt_dispatch");
        }
        tx.update(doc.ref, {
          submitted_at: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
          id: doc.id,
          tenant_id: data.tenant_id as string,
          patient_id: data.patient_id as string,
          scale_id: data.scale_id as string,
        };
      });
    } catch (e) {
      if (e instanceof HandlerError) {
        res.status(e.status).json({error: e.code});
        return;
      }
      functions.logger.error("mbcSubmitAssessment.tx_error", {
        error: String(e),
      });
      res.status(500).json({error: "internal_error"});
      return;
    }

    let score;
    try {
      score = scoreScale(dispatchData.scale_id, body.answers);
    } catch (e) {
      res.status(400).json({error: "bad_answers", detail: String(e)});
      return;
    }

    await db.collection("mbc_submissions").add({
      tenant_id: dispatchData.tenant_id,
      patient_id: dispatchData.patient_id,
      scale_id: dispatchData.scale_id,
      dispatch_id: dispatchData.id,
      score: score.score,
      max_score: score.maxScore,
      severity: score.severity,
      alarm_triggered: score.alarmTriggered,
      item_count: body.answers.length,
      answers: body.answers,
      submitted_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      scaleId: dispatchData.scale_id,
      score: score.score,
      maxScore: score.maxScore,
      severity: score.severity,
      alarmTriggered: score.alarmTriggered,
      clinicianAction: score.clinicianAction,
    });
  });

class HandlerError extends Error {
  constructor(public status: number, public code: string) {
    super(code);
  }
}
