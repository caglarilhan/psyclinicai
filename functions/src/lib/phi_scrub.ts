/**
 * Server-side PHI scrubber for AI-bound Cloud Functions.
 *
 * Closes audit finding KRİTİK-4 (2026-06-21): the Dart-side
 * `PhiRedactor` is only invoked from `ai_diagnosis_service.dart`; the
 * other 13 copilot services send raw transcripts (with names, emails,
 * phone numbers, SSN, MRN) to Anthropic. Server-side scrub is the only
 * place a forgetful caller can be defended against.
 *
 * Conservative posture: never reject a request because of a candidate
 * PHI hit (false positives would block legitimate clinical text);
 * instead, **scrub the payload before egress and log the redaction
 * count**. The proxy keeps the request flow but the bytes that leave
 * the perimeter are minimum-necessary.
 *
 * Regulator framing: HIPAA §164.514(b) safe-harbor de-identification
 * (best-effort baseline); HIPAA §164.502(b) minimum-necessary;
 * GDPR Art. 5(1)(c) data minimisation.
 */

export interface PhiScrubReport {
  text: string;
  removed: Record<string, number>;
  totalRemoved: number;
}

// Mirrors lib/utils/phi_redaction.dart so client + server use the same
// detector set. Keep them in sync when adding patterns.
const EMAIL = /\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b/g;
const PHONE_E164 = /\+\d{8,15}\b/g;
const PHONE_US = /(?:\(\d{3}\)\s*\d{3}[-.\s]?\d{4}|\b\d{3}[-.\s]\d{3}[-.\s]?\d{4})\b/g;
const SSN = /\b\d{3}-\d{2}-\d{4}\b/g;
const KVNR = /\b[A-Z]\d{9}\b/g;
const MRN = /\b(?:MRN|Patient\s*#|Member\s*ID)[:\s-]*[A-Z0-9-]{3,}\b/gi;
const NPI = /\b(?:NPI\s*[:#-]?\s*)?\d{10}\b/gi;
const IPV4 = /\b(?:\d{1,3}\.){3}\d{1,3}\b/g;

interface Pattern {
  label: string;
  rx: RegExp;
  token: string;
}

const PATTERNS: Pattern[] = [
  {label: "email", rx: EMAIL, token: "[EMAIL]"},
  {label: "phone_e164", rx: PHONE_E164, token: "[PHONE]"},
  {label: "phone_us", rx: PHONE_US, token: "[PHONE]"},
  {label: "ssn", rx: SSN, token: "[SSN]"},
  {label: "kvnr", rx: KVNR, token: "[KVNR]"},
  {label: "mrn", rx: MRN, token: "[MRN]"},
  {label: "npi", rx: NPI, token: "[NPI]"},
  {label: "ip_v4", rx: IPV4, token: "[IP]"},
];

function scrubOne(text: string): PhiScrubReport {
  const removed: Record<string, number> = {};
  let cur = text;
  for (const p of PATTERNS) {
    let count = 0;
    cur = cur.replace(p.rx, () => {
      count++;
      return p.token;
    });
    if (count > 0) removed[p.label] = (removed[p.label] ?? 0) + count;
  }
  const totalRemoved = Object.values(removed).reduce((a, b) => a + b, 0);
  return {text: cur, removed, totalRemoved};
}

/**
 * Walk every string in a JSON-shaped value and apply the scrub. The
 * Anthropic relay body is arbitrary JSON (the caller decides whether
 * it sends `messages: [{role,content}]` or a wrapped prompt), so we
 * descend recursively and aggregate the removal counts.
 *
 * Non-string leaves (numbers, booleans, null) pass through untouched.
 * Returns the scrubbed clone — the input is not mutated, so the caller
 * can keep their original for retry or audit comparison.
 */
export function scrubPhiInPayload(input: unknown): {
  payload: unknown;
  removed: Record<string, number>;
  totalRemoved: number;
} {
  const aggregated: Record<string, number> = {};

  function walk(node: unknown): unknown {
    if (typeof node === "string") {
      const r = scrubOne(node);
      for (const [k, v] of Object.entries(r.removed)) {
        aggregated[k] = (aggregated[k] ?? 0) + v;
      }
      return r.text;
    }
    if (Array.isArray(node)) {
      return node.map(walk);
    }
    if (node && typeof node === "object") {
      const out: Record<string, unknown> = {};
      for (const [k, v] of Object.entries(node as Record<string, unknown>)) {
        out[k] = walk(v);
      }
      return out;
    }
    return node;
  }

  const cloned = walk(input);
  const totalRemoved = Object.values(aggregated).reduce((a, b) => a + b, 0);
  return {payload: cloned, removed: aggregated, totalRemoved};
}

/**
 * Re-export the one-string scrub for callers that already have the
 * payload as a single transcript string (e.g. an existing prompt).
 */
export {scrubOne as scrubPhiInString};
