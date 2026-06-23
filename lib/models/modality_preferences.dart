/// Per-clinician modality enablement.
///
/// Drives the session-screen modality picker — only enabled
/// modalities show up. The default for a new clinician is
/// `standard` only (Free tier). Enabling CBT/DBT/EMDR requires the
/// `pro` tier; the toggle is shown but gated by [tier].
///
/// Persisted by `ModalityPreferencesRepository` (SharedPreferences).
library;

import '../services/data/modality_session_repository.dart' show ModalityKind;

enum ModalityTier {
  free('free'),
  pro('pro');

  const ModalityTier(this.id);
  final String id;

  static ModalityTier fromId(String? id) =>
      ModalityTier.values.firstWhere((t) => t.id == id, orElse: () => free);
}

class ModalityPreferences {
  ModalityPreferences({
    required this.clinicianId,
    required this.enabled,
    this.tier = ModalityTier.free,
  });

  factory ModalityPreferences.defaults(String clinicianId) =>
      ModalityPreferences(clinicianId: clinicianId, enabled: const {});

  factory ModalityPreferences.fromJson(Map<String, dynamic> json) {
    final raw = json['enabled'];
    final set = <ModalityKind>{};
    if (raw is List) {
      for (final v in raw) {
        if (v is String) {
          final k = ModalityKind.fromId(v);
          if (k != null) set.add(k);
        }
      }
    }
    return ModalityPreferences(
      clinicianId: json['clinicianId'] as String? ?? '',
      enabled: set,
      tier: ModalityTier.fromId(json['tier'] as String?),
    );
  }

  final String clinicianId;

  /// Which modalities the clinician opted into (independent of tier
  /// gate). The picker still respects [tier] — a Free clinician who
  /// flipped CBT on years ago doesn't get CBT until they upgrade.
  final Set<ModalityKind> enabled;

  /// Subscription tier — gates which modalities can actually be
  /// surfaced. Free = Standard only. Pro = whatever's [enabled].
  final ModalityTier tier;

  /// Effective set surfaced in the picker — intersect [enabled]
  /// with what the tier allows. Standard is always available.
  Set<ModalityKind> get effective {
    if (tier == ModalityTier.free) return const {};
    return enabled;
  }

  bool isEnabled(ModalityKind k) =>
      tier == ModalityTier.pro && enabled.contains(k);

  ModalityPreferences copyWith({
    Set<ModalityKind>? enabled,
    ModalityTier? tier,
  }) => ModalityPreferences(
    clinicianId: clinicianId,
    enabled: enabled ?? this.enabled,
    tier: tier ?? this.tier,
  );

  ModalityPreferences toggle(ModalityKind k) {
    final next = {...enabled};
    if (next.contains(k)) {
      next.remove(k);
    } else {
      next.add(k);
    }
    return copyWith(enabled: next);
  }

  Map<String, dynamic> toJson() => {
    'clinicianId': clinicianId,
    'enabled': enabled.map((k) => k.id).toList(),
    'tier': tier.id,
  };
}
