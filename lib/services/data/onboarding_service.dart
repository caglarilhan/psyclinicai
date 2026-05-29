import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'firebase_bootstrap.dart';
import 'firestore_schema.dart';

/// Tracks whether a clinician has finished the first-run onboarding
/// wizard. Persists locally (SharedPreferences) for instant reads and
/// best-effort to Firestore so the flag survives across devices.
class OnboardingService {
  OnboardingService._();
  static final OnboardingService instance = OnboardingService._();

  static const _localPrefix = 'psy_onboarded_';

  String _keyFor(String uid) => '$_localPrefix$uid';

  /// True if this clinician has completed (or skipped) the wizard.
  Future<bool> isOnboarded(String uid) async {
    if (uid.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getBool(_keyFor(uid)) ?? false;
    if (local) return true;
    // Fall back to Firestore (cross-device sync).
    if (!PsyFirebase.isReady) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .doc(FirestoreSchema.clinicPath(uid))
          .get();
      final remote = doc.data()?['onboardingCompleted'] as bool? ?? false;
      if (remote) {
        await prefs.setBool(_keyFor(uid), true);
        return true;
      }
    } catch (_) {
      // Network / rules — treat as not onboarded; wizard will run again.
    }
    return false;
  }

  /// Persist the completed flag both locally and to Firestore.
  Future<void> markCompleted(String uid) async {
    if (uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFor(uid), true);
    if (PsyFirebase.isReady) {
      try {
        await FirebaseFirestore.instance
            .doc(FirestoreSchema.clinicPath(uid))
            .set({
              'onboardingCompleted': true,
              'onboardingCompletedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } catch (_) {
        // Best-effort; the local flag is enough to stop re-prompting.
      }
    }
  }

  /// Convenience that resolves the current user's uid before checking.
  Future<bool> isCurrentUserOnboarded() async {
    final uid = FirebaseAuthService.instance.profile?.userId;
    if (uid == null) return false;
    return isOnboarded(uid);
  }
}
