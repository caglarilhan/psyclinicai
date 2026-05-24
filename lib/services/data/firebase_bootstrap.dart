import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'auth_service.dart';

/// Initialises Firebase + auth service.
///
/// Gracefully degrades: if `firebase_options.dart` still contains the
/// placeholder values, `Firebase.initializeApp` throws — we catch and
/// continue in offline mode so the demo build remains usable on routes
/// that do not require auth (landing, settings/api_keys, in-memory demo).
class PsyFirebase {
  PsyFirebase._();

  static bool _ready = false;
  static String? _initError;

  /// True once Firebase + auth have been initialised successfully.
  static bool get isReady => _ready;

  /// Initialisation error, if any. Used by the UI to surface a banner.
  static String? get initError => _initError;

  static Future<void> bootstrap() async {
    if (_ready) return;
    try {
      final hasPlaceholder = DefaultFirebaseOptions.currentPlatform.apiKey
          .startsWith('TODO');
      if (hasPlaceholder) {
        _initError =
            'Firebase not configured yet. Run `flutterfire configure`.';
        if (kDebugMode) {
          debugPrint('[PsyFirebase] $_initError');
        }
        return;
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAuthService.instance.initialize();
      _ready = true;
    } catch (e, stack) {
      _initError = 'Firebase init failed: $e';
      if (kDebugMode) {
        debugPrint('[PsyFirebase] $_initError\n$stack');
      }
    }
  }
}
