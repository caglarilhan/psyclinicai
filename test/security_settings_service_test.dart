import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/security_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SecuritySettingsService.setTestInstance(SharedPreferences.getInstance);
  });

  tearDown(SecuritySettingsService.resetTestInstance);

  group('SecuritySettingsService', () {
    test('isMfaEnrolled defaults to false', () async {
      final s = SecuritySettingsService.instance;
      expect(await s.isMfaEnrolled('user-1'), isFalse);
    });

    test('mark + read round-trip persists the enrolment flag', () async {
      final s = SecuritySettingsService.instance;
      await s.markMfaEnrolled('user-1');
      expect(await s.isMfaEnrolled('user-1'), isTrue);
    });

    test('reset clears the enrolment flag', () async {
      final s = SecuritySettingsService.instance;
      await s.markMfaEnrolled('user-1');
      await s.resetMfa('user-1');
      expect(await s.isMfaEnrolled('user-1'), isFalse);
    });

    test('flags are scoped per uid', () async {
      final s = SecuritySettingsService.instance;
      await s.markMfaEnrolled('user-a');
      expect(await s.isMfaEnrolled('user-a'), isTrue);
      expect(await s.isMfaEnrolled('user-b'), isFalse);
    });

    test('empty uid is a no-op (defensive)', () async {
      final s = SecuritySettingsService.instance;
      await s.markMfaEnrolled('');
      expect(await s.isMfaEnrolled(''), isFalse);
    });
  });
}
