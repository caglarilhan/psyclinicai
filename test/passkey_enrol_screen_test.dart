import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/passkey.dart';
import 'package:psyclinicai/screens/auth/passkey_enrol_screen.dart';
import 'package:psyclinicai/services/auth/passkey_service.dart';

class _FakeBackend implements PasskeyBackend {
  _FakeBackend({this.supported = true, this.outcome = PasskeyOutcome.ok});
  bool supported;
  PasskeyOutcome outcome;

  @override
  bool get isPlatformSupported => supported;

  @override
  Future<PasskeyEnrolmentResult> enrol({required String deviceLabel}) async {
    if (outcome != PasskeyOutcome.ok) {
      return PasskeyEnrolmentResult(outcome: outcome);
    }
    return PasskeyEnrolmentResult(
      outcome: PasskeyOutcome.ok,
      credential: PasskeyCredential(
        credentialId: 'cred-${DateTime.now().microsecondsSinceEpoch}',
        publicKey: 'pub-key',
        signCount: 0,
        deviceLabel: deviceLabel,
      ),
    );
  }

  @override
  Future<PasskeyAssertionResult> authenticate() async =>
      const PasskeyAssertionResult(outcome: PasskeyOutcome.unsupportedPlatform);
}

PasskeyService makeService({
  PasskeyOutcome outcome = PasskeyOutcome.ok,
  bool supported = true,
}) {
  return PasskeyService(
    repository: InMemoryPasskeyRepository(),
    uid: 'u-1',
    backend: _FakeBackend(supported: supported, outcome: outcome),
  );
}

Future<void> _pumpMobile(WidgetTester tester, Widget w) async {
  // Force mobile breakpoint so AppShell uses its single-column layout
  // (no side-nav rail) — keeps test surface deterministic.
  tester.view.physicalSize = const Size(390 * 2, 844 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: w));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty state surfaces the "No passkeys yet" hint', (
    tester,
  ) async {
    final service = makeService();
    await _pumpMobile(tester, PasskeyEnrolScreen(service: service));
    expect(find.textContaining('No passkeys yet'), findsOneWidget);
    expect(find.text('Add a passkey'), findsOneWidget);
  });

  testWidgets('Add a passkey persists the credential and clears the field', (
    tester,
  ) async {
    final service = makeService();
    await _pumpMobile(tester, PasskeyEnrolScreen(service: service));

    await tester.enterText(find.byType(TextField), 'MacBook Touch ID');
    await tester.tap(find.text('Add a passkey'));
    await tester.pumpAndSettle();

    expect(find.text('MacBook Touch ID'), findsAtLeastNWidgets(1));
    expect(find.text('Passkey added.'), findsOneWidget);
  });

  testWidgets('Unsupported platform disables the Add button', (tester) async {
    final service = makeService(supported: false);
    await _pumpMobile(tester, PasskeyEnrolScreen(service: service));
    final btn = tester.widget<FilledButton>(
      find.byKey(const Key('passkey_add_button')),
    );
    expect(btn.onPressed, isNull);
    expect(
      find.textContaining('Open this page on a supported browser'),
      findsOneWidget,
    );
  });

  testWidgets('Remove revokes the credential', (tester) async {
    final service = makeService();
    await service.enrol(deviceLabel: 'Phone');
    await _pumpMobile(tester, PasskeyEnrolScreen(service: service));
    expect(find.text('Phone'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Revoked'), findsOneWidget);
  });
}
