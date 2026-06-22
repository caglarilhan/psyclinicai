import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/native/handoff_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HandoffChannel', () {
    test('publish rejects a route that does not start with /', () async {
      final channel = HandoffChannel();
      expect(
        () => channel.publish(route: 'no-leading-slash'),
        throwsArgumentError,
      );
      channel.dispose();
    });

    test(
      'onContinuation stream is broadcast-safe with multiple listeners',
      () async {
        final channel = HandoffChannel();
        final a = channel.onContinuation.listen((_) {});
        final b = channel.onContinuation.listen((_) {});
        await a.cancel();
        await b.cancel();
        channel.dispose();
      },
    );
  });
}
