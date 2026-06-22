import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/native/live_activity_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveActivityChannel', () {
    test('returns a no-op handle on non-iOS / web', () async {
      // The Flutter test host is macOS (Platform.isIOS == false), so the
      // channel must short-circuit to a no-op rather than touching the
      // missing native plugin.
      final channel = LiveActivityChannel();
      final handle = await channel.start(
        sessionTitle: 'Session in progress',
        modality: 'In-person',
        clinician: 'Dr. Smith',
      );
      expect(handle.isActive, isFalse);
      // No-op handle methods should be safe to call.
      await handle.update(elapsed: const Duration(minutes: 1));
      await handle.end();
    });
  });
}
