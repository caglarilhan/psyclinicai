/// N26 — Sub-Resource Integrity (SRI) catalog (pinned helper).
///
/// **Why this exists**: Flutter web ships a small set of third-party
/// scripts/stylesheets from CDNs (Google Fonts, Firebase SDK, status
/// page widget). Without SRI hash + crossorigin, a compromised CDN
/// can swap the asset and run JS in our origin. OWASP ASVS V14.4.4
/// + W3C Subresource Integrity Recommendation require an integrity
/// attribute on every cross-origin script/style. This catalog pins
/// the canonical URL + SHA-384 hash + crossorigin policy for each
/// external resource the index.html template + Cloud Functions
/// HTML emitters must reference.
///
/// This catalog pins per external resource:
///   1. Stable resource id + plain description.
///   2. Canonical absolute URL (immutable + version-pinned).
///   3. SHA-384 hash (RFC 6234) — exact integrity value.
///   4. Crossorigin policy ("anonymous" or "use-credentials").
///   5. Whether the resource is script (executes JS) or style
///      (CSS only).
///   6. Regulatory anchor.
///
/// **Distinct from**:
///   * `SecurityHeadersCatalog` (N24) — response-side hardening;
///     N26 pins the integrity attribute of cross-origin includes.
///   * `SubprocessorRegistry` — vendor list; N26 is the per-asset
///     hash for the assets the vendor serves.
///   * `EncryptionKeyRotationSchedule` (N20) — key lifecycle; N26
///     is asset-integrity verification.
///
/// **Out of scope** (separate PRs):
///   * index.html template generator.
///   * Hash rotation job (rebuild + commit on vendor SDK upgrade).
///   * CSP nonce + hash interaction.
library;

/// Asset class.
enum SriAssetKind {
  /// JavaScript — executes in our origin if loaded.
  script,

  /// CSS — can still exfil via background-image:url(...).
  style,
}

class SubresourceIntegrityRecord {
  const SubresourceIntegrityRecord({
    required this.id,
    required this.description,
    required this.url,
    required this.integrityHash,
    required this.crossorigin,
    required this.kind,
    required this.regulatoryRefs,
  });

  final String id;
  final String description;

  /// Canonical absolute URL — version-pinned (no "latest" / no
  /// floating tag).
  final String url;

  /// SHA-384 integrity value, format: "sha384-BASE64". Tests pin
  /// the format.
  final String integrityHash;

  /// "anonymous" (default for CDN assets) or "use-credentials"
  /// (rare; only when CORS allow-credentials is set).
  final String crossorigin;

  final SriAssetKind kind;

  final List<String> regulatoryRefs;
}

class SubresourceIntegrityCatalog {
  const SubresourceIntegrityCatalog._();

  /// YYYY-MM stamp — drives the security "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned SRI table. Append-only. Hashes are sample values that
  /// MUST be regenerated on every vendor SDK upgrade (out of scope
  /// rotation job).
  static const List<SubresourceIntegrityRecord> records = [
    SubresourceIntegrityRecord(
      id: 'firebase-app-compat',
      description:
          'Firebase compat JS SDK (auth + firestore bootstrap shim). Loaded by Flutter web index.html.',
      url: 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js',
      integrityHash:
          'sha384-PLACEHOLDER_REGEN_ON_SDK_UPGRADE_FIREBASE_APP_COMPAT_10_7_1',
      crossorigin: 'anonymous',
      kind: SriAssetKind.script,
      regulatoryRefs: [
        'OWASP ASVS V14.4.4',
        'W3C Subresource Integrity Recommendation',
        'RFC 6234 SHA-384',
      ],
    ),
    SubresourceIntegrityRecord(
      id: 'firebase-auth-compat',
      description: 'Firebase Auth compat module.',
      url: 'https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js',
      integrityHash:
          'sha384-PLACEHOLDER_REGEN_ON_SDK_UPGRADE_FIREBASE_AUTH_COMPAT_10_7_1',
      crossorigin: 'anonymous',
      kind: SriAssetKind.script,
      regulatoryRefs: [
        'OWASP ASVS V14.4.4',
        'HIPAA §164.312(d) person/entity authentication',
      ],
    ),
    SubresourceIntegrityRecord(
      id: 'firebase-firestore-compat',
      description: 'Firebase Firestore compat module — clinical data IO.',
      url:
          'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore-compat.js',
      integrityHash:
          'sha384-PLACEHOLDER_REGEN_ON_SDK_UPGRADE_FIREBASE_FIRESTORE_COMPAT_10_7_1',
      crossorigin: 'anonymous',
      kind: SriAssetKind.script,
      regulatoryRefs: [
        'OWASP ASVS V14.4.4',
        'HIPAA §164.312(a)(1) access control',
        'HIPAA §164.502(b) minimum necessary',
      ],
    ),
    SubresourceIntegrityRecord(
      id: 'google-fonts-inter',
      description:
          'Inter typeface stylesheet from Google Fonts CDN. Loaded by Flutter web index.html.',
      url:
          'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap',
      integrityHash:
          'sha384-PLACEHOLDER_REGEN_ON_FONT_UPGRADE_GOOGLE_FONTS_INTER_400_700',
      crossorigin: 'anonymous',
      kind: SriAssetKind.style,
      regulatoryRefs: [
        'OWASP ASVS V14.4.4',
        'W3C Subresource Integrity Recommendation',
      ],
    ),
  ];

  static SubresourceIntegrityRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static List<SubresourceIntegrityRecord> byKind(SriAssetKind k) {
    return records.where((r) => r.kind == k).toList();
  }
}

/// True when the URL is in our pinned SRI catalog (Cloud Functions
/// HTML emitter / index.html validator hook).
bool isPinnedExternalAsset(String url) {
  for (final r in SubresourceIntegrityCatalog.records) {
    if (r.url == url) return true;
  }
  return false;
}
