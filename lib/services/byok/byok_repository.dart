import 'package:cloud_firestore/cloud_firestore.dart';

/// BYOK ("Bring Your Own Key") repository for PILAR 1/4 LLM access.
///
/// Lets a clinician paste their own Anthropic / Groq / Gemini key in
/// Settings → API keys. The handler-side resolver
/// (`functions/src/lib/byok_resolver.ts`) reads this row at request
/// time and prefers the user-supplied key over the platform's
/// free-tier `.env` chain.
///
/// **Why this exists** (Sprint 31, bootstrap launch):
///   * Anthropic / Azure are paid + we have no revenue yet to fund
///     them — so the platform-default chain is Groq + Gemini free
///     tier (no BAA, demo data only).
///   * A clinician who wants to use the assistant with REAL PHI must
///     bring their own BAA-bearing Anthropic key. They sign a BAA
///     directly with Anthropic; we are not a covered entity until we
///     graduate to the Pro tier.
///   * This shifts the cost to the clinician until we have the
///     revenue to absorb it back.
///
/// **Security posture**:
///   * Stored at `clinicians/{uid}/api_keys/llm` — Firestore default
///     at-rest encryption + TLS in transit.
///   * Firestore rules restrict read / write to the owning uid only.
///   * Handler logs NEVER include the raw key (only an isSet flag
///     + the last 4 chars for audit correlation).
class ByokRepository {
  ByokRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _docFor(String uid) =>
      _db.collection('clinicians').doc(uid).collection('api_keys').doc('llm');

  Future<ByokKeys> load(String uid) async {
    final snap = await _docFor(uid).get();
    if (!snap.exists) return const ByokKeys();
    return ByokKeys.fromJson(snap.data() ?? const {});
  }

  Future<void> save(String uid, ByokKeys keys) async {
    await _docFor(uid).set({
      ...keys.toJson(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clear(String uid) async {
    await _docFor(uid).delete();
  }
}

/// Per-clinician BYOK key set. Each field is either a non-empty key
/// string the clinician pasted, or null (= use the platform default).
class ByokKeys {
  const ByokKeys({
    this.anthropicKey,
    this.groqKey,
    this.geminiKey,
  });

  factory ByokKeys.fromJson(Map<String, dynamic> json) => ByokKeys(
        anthropicKey: _stringOrNull(json['anthropic_key']),
        groqKey: _stringOrNull(json['groq_key']),
        geminiKey: _stringOrNull(json['gemini_key']),
      );

  static String? _stringOrNull(Object? v) {
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return null;
  }

  final String? anthropicKey;
  final String? groqKey;
  final String? geminiKey;

  Map<String, dynamic> toJson() => {
        if (anthropicKey != null) 'anthropic_key': anthropicKey,
        if (groqKey != null) 'groq_key': groqKey,
        if (geminiKey != null) 'gemini_key': geminiKey,
      };

  /// Masked preview (last 4 chars) for the Settings UI confirmation
  /// row — never log the full string anywhere.
  static String? lastFourOf(String? key) {
    if (key == null || key.length < 4) return null;
    return '…${key.substring(key.length - 4)}';
  }

  bool get hasAnyKey =>
      anthropicKey != null || groqKey != null || geminiKey != null;
}
