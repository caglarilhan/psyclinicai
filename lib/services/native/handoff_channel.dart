import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Apple Hand-off bridge — `psyclinicai/handoff` MethodChannel.
///
/// Two directions:
///   • Dart → iOS: `publish({route, title?, ctxHash?})` registers an
///     NSUserActivity that nearby clinician devices can pick up.
///     `clear()` invalidates it.
///   • iOS → Dart: `onContinuation` is invoked when iOS asks the app
///     to resume a hand-off from another device. Subscribe via
///     [onContinuation] and `Navigator.pushNamed(route)`.
///
/// PHI never crosses the wire — only opaque route strings + a hashed
/// session id. On non-iOS / non-macOS this class is a no-op.
class HandoffChannel {
  HandoffChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('psyclinicai/handoff') {
    _channel.setMethodCallHandler(_handleIncoming);
  }

  final MethodChannel _channel;
  final _continuations = StreamController<HandoffContinuation>.broadcast();

  /// Fires every time iOS hands an activity to this app from another
  /// device. Receivers should validate `route` against an allow-list
  /// before navigating.
  Stream<HandoffContinuation> get onContinuation => _continuations.stream;

  bool get _supported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  Future<bool> publish({
    required String route,
    String? title,
    String? ctxHash,
  }) async {
    if (!_supported) return false;
    if (!route.startsWith('/')) {
      throw ArgumentError.value(route, 'route', 'must start with "/"');
    }
    try {
      final ok = await _channel.invokeMethod<bool>('publish', {
        'route': route,
        if (title != null) 'title': title,
        if (ctxHash != null) 'ctxHash': ctxHash,
      });
      return ok ?? false;
    } on PlatformException catch (e, st) {
      debugPrint('Handoff.publish failed: ${e.code} ${e.message}\n$st');
      return false;
    }
  }

  Future<void> clear() async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('clear');
    } on PlatformException catch (e) {
      debugPrint('Handoff.clear failed: ${e.code} ${e.message}');
    }
  }

  Future<dynamic> _handleIncoming(MethodCall call) async {
    if (call.method != 'onContinuation') return null;
    final args = call.arguments;
    if (args is! Map) return null;
    final route = args['route'];
    if (route is! String || !route.startsWith('/')) return null;
    _continuations.add(
      HandoffContinuation(
        route: route,
        ctxHash: (args['ctxHash'] as String?) ?? '',
      ),
    );
    return null;
  }

  void dispose() {
    unawaited(_continuations.close());
  }
}

class HandoffContinuation {
  const HandoffContinuation({required this.route, required this.ctxHash});
  final String route;
  final String ctxHash;
}
