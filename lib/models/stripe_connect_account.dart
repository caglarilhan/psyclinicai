/// Tenant-scoped Stripe Connect account state surfaced on
/// `/settings/payments`. Mirrors the relevant fields from a Stripe
/// `Account` object (Express variant) plus the per-tenant audit
/// metadata we need locally.
enum StripeConnectStatus {
  none,
  pending,
  restricted,
  enabled,
  disabled;

  static StripeConnectStatus fromId(String id) {
    return values.firstWhere(
      (s) => s.name == id,
      orElse: () => StripeConnectStatus.none,
    );
  }
}

class StripeConnectAccount {
  const StripeConnectAccount({
    required this.tenantId,
    required this.status,
    this.accountId,
    this.requirementsDue = const [],
    this.lastSyncAt,
    this.dashboardUrl,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
  });

  final String tenantId;
  final StripeConnectStatus status;
  final String? accountId;
  final List<String> requirementsDue;
  final DateTime? lastSyncAt;
  final String? dashboardUrl;
  final bool chargesEnabled;
  final bool payoutsEnabled;

  bool get isReady =>
      status == StripeConnectStatus.enabled &&
      chargesEnabled &&
      payoutsEnabled;

  bool get hasBlockingRequirements => requirementsDue.isNotEmpty;

  StripeConnectAccount copyWith({
    StripeConnectStatus? status,
    String? accountId,
    List<String>? requirementsDue,
    DateTime? lastSyncAt,
    String? dashboardUrl,
    bool? chargesEnabled,
    bool? payoutsEnabled,
  }) =>
      StripeConnectAccount(
        tenantId: tenantId,
        status: status ?? this.status,
        accountId: accountId ?? this.accountId,
        requirementsDue: requirementsDue ?? this.requirementsDue,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        dashboardUrl: dashboardUrl ?? this.dashboardUrl,
        chargesEnabled: chargesEnabled ?? this.chargesEnabled,
        payoutsEnabled: payoutsEnabled ?? this.payoutsEnabled,
      );

  Map<String, dynamic> toJson() => {
        'tenant_id': tenantId,
        'status': status.name,
        if (accountId != null) 'account_id': accountId,
        'requirements_due': requirementsDue,
        if (lastSyncAt != null)
          'last_sync_at': lastSyncAt!.toUtc().toIso8601String(),
        if (dashboardUrl != null) 'dashboard_url': dashboardUrl,
        'charges_enabled': chargesEnabled,
        'payouts_enabled': payoutsEnabled,
      };

  factory StripeConnectAccount.fromJson(Map<String, dynamic> json) {
    return StripeConnectAccount(
      tenantId: json['tenant_id'] as String,
      status: StripeConnectStatus.fromId(
          json['status'] as String? ?? 'none'),
      accountId: json['account_id'] as String?,
      requirementsDue: (json['requirements_due'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      dashboardUrl: json['dashboard_url'] as String?,
      chargesEnabled: json['charges_enabled'] as bool? ?? false,
      payoutsEnabled: json['payouts_enabled'] as bool? ?? false,
    );
  }

  factory StripeConnectAccount.demo(String tenantId) => StripeConnectAccount(
        tenantId: tenantId,
        status: StripeConnectStatus.restricted,
        accountId: 'acct_demo_${tenantId.substring(0, 4).toUpperCase()}',
        requirementsDue: const [
          'external_account',
          'individual.id_number',
          'tos_acceptance.date',
        ],
        lastSyncAt: DateTime.utc(2026, 6, 2, 8, 30),
        dashboardUrl: 'https://connect.stripe.com/express/demo',
        chargesEnabled: false,
        payoutsEnabled: false,
      );
}
