import 'package:flutter/foundation.dart';

import '../../config/build_config.dart';

/// Paid plans. Mirrors the landing pricing tiers (Solo / Practice / Group),
/// plus a [free] tier for trial / BYOK use.
enum SubscriptionTier { free, solo, practice, group }

extension SubscriptionTierX on SubscriptionTier {
  String get label => switch (this) {
        SubscriptionTier.free => 'Free / Trial',
        SubscriptionTier.solo => 'Solo',
        SubscriptionTier.practice => 'Practice',
        SubscriptionTier.group => 'Group',
      };

  /// Clinician seats the tier allows.
  int get seats => switch (this) {
        SubscriptionTier.free => 1,
        SubscriptionTier.solo => 1,
        SubscriptionTier.practice => 5,
        SubscriptionTier.group => 9999,
      };

  bool get isPaid => this != SubscriptionTier.free;
}

/// Tracks the signed-in clinician's subscription and answers feature-gating
/// questions. Status is fed from Stripe (via the webhook → Firestore) once the
/// backend is configured; until then it stays [free] and gating is permissive
/// in demo mode so local/pilot use is never blocked.
class SubscriptionService extends ChangeNotifier {
  SubscriptionTier _tier = SubscriptionTier.free;
  bool _active = false;

  SubscriptionTier get tier => _tier;

  /// True when the subscription is in good standing (paid + not lapsed).
  bool get isActive => _active && _tier.isPaid;

  /// Updates from the authoritative store (Stripe status synced to Firestore).
  void applyStatus({required SubscriptionTier tier, required bool active}) {
    if (_tier == tier && _active == active) return;
    _tier = tier;
    _active = active;
    notifyListeners();
  }

  void reset() => applyStatus(tier: SubscriptionTier.free, active: false);

  /// Whether a paid feature (AI scribe, Denial Shield) is available.
  ///
  /// In demo mode everything is unlocked (BYOK / pilot). Once a real backend is
  /// configured, paid features require an active subscription.
  bool get canUsePaidFeatures =>
      BuildConfig.isDemo || !BuildConfig.billingConfigured || isActive;

  /// Whether [seatCount] clinicians fit the current tier.
  bool allowsSeats(int seatCount) => seatCount <= _tier.seats;

  /// Maps a Stripe Price ID to a tier (configured per Stripe account).
  static SubscriptionTier tierFromPriceId(
    String priceId, {
    required Map<String, SubscriptionTier> priceMap,
  }) =>
      priceMap[priceId] ?? SubscriptionTier.free;

  /// Maps a Stripe subscription status string to active/not.
  static bool isActiveStatus(String stripeStatus) =>
      stripeStatus == 'active' || stripeStatus == 'trialing';
}
