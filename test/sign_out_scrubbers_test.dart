import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/auth/sign_out_scrubbers.dart';

void main() {
  group('SignOutScrubbers registry', () {
    tearDown(SignOutScrubbers.clearForTest);

    test('debugCount reflects registrations + removals', () {
      expect(SignOutScrubbers.debugCount, 0);
      final remove1 = SignOutScrubbers.register(() {});
      final remove2 = SignOutScrubbers.register(() async {});
      expect(SignOutScrubbers.debugCount, 2);
      remove1();
      expect(SignOutScrubbers.debugCount, 1);
      remove2();
      expect(SignOutScrubbers.debugCount, 0);
    });

    test('runAll invokes every registered scrubber in order', () async {
      final calls = <String>[];
      SignOutScrubbers.register(() => calls.add('a'));
      SignOutScrubbers.register(() async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        calls.add('b');
      });
      SignOutScrubbers.register(() => calls.add('c'));
      await SignOutScrubbers.runAll();
      expect(calls, ['a', 'b', 'c']);
    });

    test('a throwing scrubber does not block subsequent ones', () async {
      final calls = <String>[];
      SignOutScrubbers.register(() => calls.add('before'));
      SignOutScrubbers.register(() => throw StateError('boom'));
      SignOutScrubbers.register(() => calls.add('after'));
      // runAll must complete — sign-out cannot hang on a bad cleaner.
      await SignOutScrubbers.runAll();
      expect(calls, ['before', 'after']);
    });

    test('runAll is safe with an empty registry', () async {
      await SignOutScrubbers.runAll();
      expect(SignOutScrubbers.debugCount, 0);
    });

    test('register returns a removal function that is idempotent', () {
      final remove = SignOutScrubbers.register(() {});
      expect(SignOutScrubbers.debugCount, 1);
      remove();
      remove(); // second call should not throw nor underflow
      expect(SignOutScrubbers.debugCount, 0);
    });

    test(
        'runAll iterates a snapshot — a scrubber that registers '
        'another during runAll does not infinite-loop', () async {
      var calls = 0;
      SignOutScrubbers.register(() {
        calls++;
        if (calls < 5) SignOutScrubbers.register(() => calls++);
      });
      await SignOutScrubbers.runAll();
      // Original scrubber ran exactly once because runAll iterates a
      // List.from snapshot taken at the start.
      expect(calls, 1);
    });
  });
}
