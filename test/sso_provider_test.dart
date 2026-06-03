import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/sso_provider.dart';

void main() {
  group('SsoProvider', () {
    test('fromId fallback is workspace', () {
      expect(SsoProvider.fromId('unknown'), SsoProvider.workspace);
      expect(SsoProvider.fromId('okta'), SsoProvider.okta);
    });

    test('default protocols map provider buckets', () {
      expect(SsoProvider.workspace.defaultProtocol, SsoProtocol.saml);
      expect(SsoProvider.okta.defaultProtocol, SsoProtocol.oidc);
    });
  });

  group('SsoConfiguration', () {
    SsoConfiguration base() => SsoConfiguration(
          tenantId: 't-1',
          provider: SsoProvider.workspace,
          protocol: SsoProtocol.saml,
          idpEntityId: 'https://accounts.google.com/o/saml2?idpid=ABC',
          acsUrl: 'https://psyclinicai.com/saml/acs',
          metadataUrl:
              'https://accounts.google.com/o/saml2/idp-meta?idpid=ABC',
        );

    test('hasBeenTested false until lastTestAt set', () {
      expect(base().hasBeenTested, isFalse);
      final tested = base().copyWith(
        lastTestAt: DateTime.utc(2026, 6, 3),
        lastTestOk: true,
      );
      expect(tested.hasBeenTested, isTrue);
      expect(tested.lastTestOk, isTrue);
    });

    test('copyWith only overrides supplied fields', () {
      final c = base().copyWith(requireSso: true);
      expect(c.requireSso, isTrue);
      expect(c.jitProvisioning, isFalse);
      expect(c.idpEntityId, base().idpEntityId);
    });

    test('JSON round-trip preserves fields', () {
      final c = base().copyWith(
        jitProvisioning: true,
        requireSso: true,
        lastTestAt: DateTime.utc(2026, 6, 3),
        lastTestOk: true,
      );
      final restored = SsoConfiguration.fromJson(c.toJson());
      expect(restored.provider, SsoProvider.workspace);
      expect(restored.protocol, SsoProtocol.saml);
      expect(restored.requireSso, isTrue);
      expect(restored.jitProvisioning, isTrue);
      expect(restored.lastTestOk, isTrue);
    });
  });
}
