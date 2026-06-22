import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/passkey.dart';

/// Outcome surfaced to the UI layer for an enrolment / authentication.
enum PasskeyOutcome {
  ok,
  unsupportedPlatform,
  userCancelled,
  challengeExpired,
  networkError,
  serverRejected,
  busy,
}

/// Pluggable backend the [PasskeyService] talks to. The default is
/// `_NoopPasskeyBackend` so non-web platforms (or tests) get a clean,
/// deterministic "not supported" answer instead of an interop crash.
///
/// The web implementation that drives `navigator.credentials.create`
/// + `navigator.credentials.get` will live in
/// `lib/services/auth/passkey_service_web.dart` (conditional import
/// once the WebAuthn JS interop layer lands).
abstract class PasskeyBackend {
  bool get isPlatformSupported;

  /// `POST /passkeyRegisterOptions` → `navigator.credentials.create` →
  /// `POST /passkeyRegisterVerify`. On success the credential summary
  /// (public-key portion only) is returned for local persistence.
  Future<PasskeyEnrolmentResult> enrol({required String deviceLabel});

  /// `POST /passkeyAuthOptions` → `navigator.credentials.get` →
  /// `POST /passkeyAuthVerify`. Returns the credential id used.
  Future<PasskeyAssertionResult> authenticate();
}

class PasskeyEnrolmentResult {
  const PasskeyEnrolmentResult({required this.outcome, this.credential});
  final PasskeyOutcome outcome;
  final PasskeyCredential? credential;
}

class PasskeyAssertionResult {
  const PasskeyAssertionResult({required this.outcome, this.credentialId});
  final PasskeyOutcome outcome;
  final String? credentialId;
}

class _NoopPasskeyBackend implements PasskeyBackend {
  const _NoopPasskeyBackend();

  @override
  bool get isPlatformSupported => false;

  @override
  Future<PasskeyEnrolmentResult> enrol({required String deviceLabel}) async {
    return const PasskeyEnrolmentResult(
      outcome: PasskeyOutcome.unsupportedPlatform,
    );
  }

  @override
  Future<PasskeyAssertionResult> authenticate() async {
    return const PasskeyAssertionResult(
      outcome: PasskeyOutcome.unsupportedPlatform,
    );
  }
}

/// View-model glue between [PasskeyBackend] and the enrolment screen.
class PasskeyService extends ChangeNotifier {
  PasskeyService({
    required PasskeyRepository repository,
    required String uid,
    PasskeyBackend? backend,
  }) : _repository = repository,
       _uid = uid,
       _backend = backend ?? const _NoopPasskeyBackend();

  final PasskeyRepository _repository;
  final String _uid;
  final PasskeyBackend _backend;

  List<PasskeyCredential> _credentials = const [];
  List<PasskeyCredential> get credentials => _credentials;
  bool get isPlatformSupported => _backend.isPlatformSupported;

  bool _busy = false;
  bool get isBusy => _busy;

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> refresh() async {
    _credentials = await _repository.listForUser(_uid);
    notifyListeners();
  }

  Future<PasskeyOutcome> enrol({required String deviceLabel}) async {
    if (_busy) return PasskeyOutcome.busy;
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      final res = await _backend.enrol(deviceLabel: deviceLabel);
      if (res.outcome == PasskeyOutcome.ok && res.credential != null) {
        await _repository.add(_uid, res.credential!);
        _credentials = await _repository.listForUser(_uid);
      } else {
        _lastError = res.outcome.name;
      }
      return res.outcome;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> revoke(String credentialId) async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      await _repository.revoke(_uid, credentialId);
      _credentials = await _repository.listForUser(_uid);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
