/// Waitlist + beta-signup writes — single repository so the screens
/// don't reach Firestore directly.
///
/// KRİTİK-10 fix (audit 2026-06-21): three screens
/// (`landing_screen`, `beta_waitlist_screen`,
/// `e_prescription_screen`) were calling
/// `FirebaseFirestore.instance.collection('landing_waitlist').add(...)`
/// inline. That left no test seam, no audit centralisation, and no
/// place to put the rate-limit + idempotency hardening the security
/// backlog (L-11) asked for. This repository becomes that place: one
/// override-able instance, one set of telemetry hooks, one set of
/// rules to mirror in Firestore. The screens shrink to `await
/// WaitlistRepository.instance.recordLanding(email, source: '...')`.
///
/// Today's implementation keeps the previous best-effort semantics —
/// if Firebase isn't bootstrapped or rules deny, the call returns a
/// `WaitlistOutcome.skipped` / `.denied` instead of throwing so the
/// UI's success-snackbar flow is unchanged. Future enhancements
/// (App Check, debounce, server-side hCaptcha) plug in here.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_bootstrap.dart';

enum WaitlistOutcome {
  /// Write succeeded — row is live in Firestore.
  saved,

  /// Firebase wasn't ready (placeholder config) — skipped without
  /// raising so the UI ack still fires.
  skipped,

  /// Firestore rule denied or network failed — caller may decide
  /// whether to surface this to the user. Today the landing flow
  /// hides denials (still shows the success snackbar) for the
  /// "best-effort capture" stance documented in the legacy code.
  denied,
}

class WaitlistRepository {
  WaitlistRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  /// Default production singleton — uses the live Firestore handle
  /// only when [PsyFirebase.isReady]. Tests should construct their
  /// own instance with a fake Firestore (or pass `firestore` in the
  /// named arg) to capture writes without touching the network.
  static WaitlistRepository instance = WaitlistRepository();

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? _resolveDb() {
    if (_firestore != null) return _firestore;
    if (!PsyFirebase.isReady) return null;
    return FirebaseFirestore.instance;
  }

  /// Persist a landing-page waitlist signup. [source] tags which CTA
  /// captured the email (hero, exit-intent, pricing-row, …) so
  /// dashboards can split funnel conversion per surface.
  Future<WaitlistOutcome> recordLanding({
    required String email,
    required String source,
    Map<String, Object?> extra = const {},
  }) async {
    final db = _resolveDb();
    if (db == null) return WaitlistOutcome.skipped;
    try {
      await db.collection('landing_waitlist').add({
        'email': email.trim().toLowerCase(),
        'source': source,
        'createdAt': FieldValue.serverTimestamp(),
        ...extra,
      });
      return WaitlistOutcome.saved;
    } catch (_) {
      return WaitlistOutcome.denied;
    }
  }

  /// Persist a beta-program signup. Separate collection from the
  /// landing waitlist because the beta funnel carries additional
  /// fields (role, country, modality) that the public landing form
  /// does not ask for.
  Future<WaitlistOutcome> recordBetaSignup({
    required String email,
    Map<String, Object?> extra = const {},
  }) async {
    final db = _resolveDb();
    if (db == null) return WaitlistOutcome.skipped;
    try {
      await db.collection('beta_signups').add({
        'email': email.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        ...extra,
      });
      return WaitlistOutcome.saved;
    } catch (_) {
      return WaitlistOutcome.denied;
    }
  }
}
