import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable snapshot of PILAR-level activation milestones for a
/// single clinic. Consumed by the dashboard [SetupChecklist] so
/// clinicians see their onboarding progress at a glance.
class OnboardingSignals {
  const OnboardingSignals({
    required this.hasSoapDraft,
    required this.hasMbcDispatch,
    required this.hasNoShowPrediction,
    required this.hasTpPlan,
  });

  const OnboardingSignals.empty()
    : hasSoapDraft = false,
      hasMbcDispatch = false,
      hasNoShowPrediction = false,
      hasTpPlan = false;

  final bool hasSoapDraft;
  final bool hasMbcDispatch;
  final bool hasNoShowPrediction;
  final bool hasTpPlan;

  int get completed =>
      (hasSoapDraft ? 1 : 0) +
      (hasMbcDispatch ? 1 : 0) +
      (hasNoShowPrediction ? 1 : 0) +
      (hasTpPlan ? 1 : 0);

  bool get allPillarsTouched => completed == 4;

  OnboardingSignals copyWith({
    bool? hasSoapDraft,
    bool? hasMbcDispatch,
    bool? hasNoShowPrediction,
    bool? hasTpPlan,
  }) => OnboardingSignals(
    hasSoapDraft: hasSoapDraft ?? this.hasSoapDraft,
    hasMbcDispatch: hasMbcDispatch ?? this.hasMbcDispatch,
    hasNoShowPrediction: hasNoShowPrediction ?? this.hasNoShowPrediction,
    hasTpPlan: hasTpPlan ?? this.hasTpPlan,
  );
}

/// Read-only stream over 4 PILAR audit collections. Each is queried
/// with `.limit(1)` so first-touch detection costs a single document
/// read on the client. Firestore rules already scope every collection
/// to the owning clinic.
class OnboardingSignalsRepository {
  OnboardingSignalsRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// The four collections we watch — kept as a constant so callers
  /// know exactly which paths this repository touches. Matches the
  /// Firestore rules deployed in Sprint 30 PR-C
  /// (`chore/pilars-firestore-rules`).
  static const List<String> watchedCollections = [
    'ai_scribe_drafts',
    'mbc_dispatch',
    'noshow_predictions',
    'tp_drafted_plans',
  ];

  Stream<OnboardingSignals> watchAll(String clinicId) {
    final controller = StreamController<OnboardingSignals>();
    var current = const OnboardingSignals.empty();
    // Emit the empty baseline immediately so consumers can render an
    // "in progress" state without waiting for the first Firestore
    // roundtrip.
    controller.add(current);

    Stream<bool> nonEmpty(String collection) =>
        _db
            .collection(collection)
            .where('clinic_id', isEqualTo: clinicId)
            .limit(1)
            .snapshots()
            .map((s) => s.docs.isNotEmpty);

    final subs = <StreamSubscription<bool>>[
      nonEmpty(watchedCollections[0]).listen((v) {
        current = current.copyWith(hasSoapDraft: v);
        if (!controller.isClosed) controller.add(current);
      }),
      nonEmpty(watchedCollections[1]).listen((v) {
        current = current.copyWith(hasMbcDispatch: v);
        if (!controller.isClosed) controller.add(current);
      }),
      nonEmpty(watchedCollections[2]).listen((v) {
        current = current.copyWith(hasNoShowPrediction: v);
        if (!controller.isClosed) controller.add(current);
      }),
      nonEmpty(watchedCollections[3]).listen((v) {
        current = current.copyWith(hasTpPlan: v);
        if (!controller.isClosed) controller.add(current);
      }),
    ];

    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };

    return controller.stream;
  }
}
