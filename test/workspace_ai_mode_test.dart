import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/workspace_ai_mode.dart';

void main() {
  group('WorkspaceAiMode.fromId', () {
    test('round-trips every value', () {
      for (final m in WorkspaceAiMode.values) {
        expect(WorkspaceAiMode.fromId(m.name), m);
      }
    });

    test('defaults to byok when the id is unknown / null (fail-closed)',
        () {
      // BYOK is the strictest mode, so an unknown value falls back to
      // it instead of accidentally enabling the platform-key path.
      expect(WorkspaceAiMode.fromId(null), WorkspaceAiMode.byok);
      expect(WorkspaceAiMode.fromId('garbage'), WorkspaceAiMode.byok);
    });
  });

  group('isAiDisabled', () {
    test('true only when the mode is disabled', () {
      expect(isAiDisabled(WorkspaceAiMode.disabled), isTrue);
      expect(isAiDisabled(WorkspaceAiMode.byok), isFalse);
      expect(isAiDisabled(WorkspaceAiMode.platform), isFalse);
    });
  });

  group('requiresByokKey', () {
    test('true for the byok mode, false otherwise', () {
      expect(requiresByokKey(WorkspaceAiMode.byok), isTrue);
      expect(requiresByokKey(WorkspaceAiMode.platform), isFalse);
      expect(requiresByokKey(WorkspaceAiMode.disabled), isFalse);
    });
  });
}
