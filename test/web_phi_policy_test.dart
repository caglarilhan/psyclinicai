import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/web_phi_policy.dart';

void main() {
  group('isLocalCacheAllowed', () {
    test('true on native (isWeb=false)', () {
      expect(isLocalCacheAllowed(isWeb: false), isTrue);
    });

    test('false on web (isWeb=true)', () {
      expect(isLocalCacheAllowed(isWeb: true), isFalse,
          reason: 'localStorage is plain-text — PHI must not land there');
    });
  });

  group('resolveWebPhiPolicy', () {
    test('returns the matching enum value', () {
      expect(resolveWebPhiPolicy(isWeb: false), WebPhiPolicy.nativeAllowed);
      expect(resolveWebPhiPolicy(isWeb: true), WebPhiPolicy.webDenied);
    });
  });

  group('webPhiPolicyMessage', () {
    test('web message warns about no local cache', () {
      final msg = webPhiPolicyMessage(WebPhiPolicy.webDenied);
      expect(msg.toLowerCase(), contains('web build'));
      expect(msg.toLowerCase(), contains('not cache'));
    });

    test('native message explains the keystore behaviour', () {
      final msg = webPhiPolicyMessage(WebPhiPolicy.nativeAllowed);
      expect(msg.toLowerCase(), contains('keystore'));
    });
  });
}
