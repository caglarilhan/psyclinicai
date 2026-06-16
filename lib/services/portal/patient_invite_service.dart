/// Patient self-service invite — single-use, 24h TTL.
///
/// Sprint 27 / F-012 close. The old behaviour kept invite links live
/// for seven days and let the same link sign in any number of times,
/// failing OWASP ASVS V2.3.1. The new model:
///   - issue: write `invites/{id}` with `expires_at = now + 24h`,
///     `consumed_at = null`.
///   - consume (first tap): a transactional read-modify-write that
///     refuses if `now > expires_at` or `consumed_at != null`. On
///     success, sets `consumed_at = now`.
///   - second tap: returns [InviteCheckResult.consumed] →
///     `/portal/invite-used` landing.
library;

/// Outcome of a `consume` attempt — pattern-matched by the UI so we
/// can render distinct copy ("expired vs. already used").
enum InviteCheckResult {
  /// First valid tap — caller has just claimed the invite.
  valid,

  /// `now > expires_at`. UI shows "this link has expired".
  expired,

  /// `consumed_at != null`. UI shows "already used" + "request a new link".
  consumed,

  /// Doc does not exist — could be a typo or revoked invite.
  notFound;

  bool get isUsable => this == InviteCheckResult.valid;
}

/// Plain-data view of the invite doc — the parts our check cares
/// about. Construct from a Firestore snapshot at the call site.
class InviteState {
  const InviteState({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    required this.consumedAt,
  });

  final String id;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? consumedAt;
}

/// Pure decision helper — given an invite state and the current
/// time, return the [InviteCheckResult] **without** writing.
/// The caller wraps this inside a transaction that flips
/// `consumed_at` only when the result is [InviteCheckResult.valid].
InviteCheckResult checkInvite({
  required InviteState? state,
  required DateTime now,
}) {
  if (state == null) return InviteCheckResult.notFound;
  if (state.consumedAt != null) return InviteCheckResult.consumed;
  if (!now.isBefore(state.expiresAt)) return InviteCheckResult.expired;
  return InviteCheckResult.valid;
}

/// Build the `expires_at` value for a freshly issued invite.
DateTime defaultExpiry(DateTime issuedAt) =>
    issuedAt.add(const Duration(hours: 24));
