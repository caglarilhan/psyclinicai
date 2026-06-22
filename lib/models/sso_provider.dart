/// SAML/OIDC provider config persisted per tenant. Sprint 25 surface
/// for the SSO step in the enterprise sales path.
enum SsoProvider {
  workspace('workspace', 'Google Workspace', SsoProtocol.saml),
  azureAd('azure_ad', 'Microsoft Entra ID (Azure AD)', SsoProtocol.saml),
  okta('okta', 'Okta', SsoProtocol.oidc),
  auth0('auth0', 'Auth0', SsoProtocol.oidc),
  keycloak('keycloak', 'Keycloak (self-hosted)', SsoProtocol.oidc),
  oneLogin('onelogin', 'OneLogin', SsoProtocol.saml);

  const SsoProvider(this.id, this.label, this.defaultProtocol);
  final String id;
  final String label;
  final SsoProtocol defaultProtocol;

  static SsoProvider fromId(String id) =>
      values.firstWhere((p) => p.id == id, orElse: () => SsoProvider.workspace);
}

enum SsoProtocol { saml, oidc }

class SsoConfiguration {
  factory SsoConfiguration.fromJson(Map<String, dynamic> json) =>
      SsoConfiguration(
        tenantId: json['tenant_id'] as String,
        provider: SsoProvider.fromId(json['provider'] as String? ?? ''),
        protocol: SsoProtocol.values.firstWhere(
          (p) => p.name == json['protocol'],
          orElse: () => SsoProtocol.saml,
        ),
        idpEntityId: json['idp_entity_id'] as String,
        acsUrl: json['acs_url'] as String,
        metadataUrl: json['metadata_url'] as String?,
        jitProvisioning: json['jit_provisioning'] as bool? ?? false,
        requireSso: json['require_sso'] as bool? ?? false,
        lastTestAt: json['last_test_at'] != null
            ? DateTime.parse(json['last_test_at'] as String)
            : null,
        lastTestOk: json['last_test_ok'] as bool? ?? false,
      );
  const SsoConfiguration({
    required this.tenantId,
    required this.provider,
    required this.protocol,
    required this.idpEntityId,
    required this.acsUrl,
    this.metadataUrl,
    this.jitProvisioning = false,
    this.requireSso = false,
    this.lastTestAt,
    this.lastTestOk = false,
  });

  final String tenantId;
  final SsoProvider provider;
  final SsoProtocol protocol;
  final String idpEntityId;
  final String acsUrl;
  final String? metadataUrl;
  final bool jitProvisioning;
  final bool requireSso;
  final DateTime? lastTestAt;
  final bool lastTestOk;

  bool get hasBeenTested => lastTestAt != null;

  SsoConfiguration copyWith({
    bool? jitProvisioning,
    bool? requireSso,
    DateTime? lastTestAt,
    bool? lastTestOk,
  }) => SsoConfiguration(
    tenantId: tenantId,
    provider: provider,
    protocol: protocol,
    idpEntityId: idpEntityId,
    acsUrl: acsUrl,
    metadataUrl: metadataUrl,
    jitProvisioning: jitProvisioning ?? this.jitProvisioning,
    requireSso: requireSso ?? this.requireSso,
    lastTestAt: lastTestAt ?? this.lastTestAt,
    lastTestOk: lastTestOk ?? this.lastTestOk,
  );

  Map<String, dynamic> toJson() => {
    'tenant_id': tenantId,
    'provider': provider.id,
    'protocol': protocol.name,
    'idp_entity_id': idpEntityId,
    'acs_url': acsUrl,
    if (metadataUrl != null) 'metadata_url': metadataUrl,
    'jit_provisioning': jitProvisioning,
    'require_sso': requireSso,
    if (lastTestAt != null)
      'last_test_at': lastTestAt!.toUtc().toIso8601String(),
    'last_test_ok': lastTestOk,
  };
}
