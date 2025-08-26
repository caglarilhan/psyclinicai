import 'package:json_annotation/json_annotation.dart';

part 'blockchain_security_models.g.dart';

/// Blockchain Network Type
enum BlockchainNetworkType {
  @JsonValue('ethereum') ethereum,
  @JsonValue('polygon') polygon,
  @JsonValue('binance_smart_chain') binanceSmartChain,
  @JsonValue('solana') solana,
  @JsonValue('private') private,
  @JsonValue('hybrid') hybrid,
}

/// Smart Contract Status
enum SmartContractStatus {
  @JsonValue('deployed') deployed,
  @JsonValue('active') active,
  @JsonValue('paused') paused,
  @JsonValue('upgraded') upgraded,
  @JsonValue('deprecated') deprecated,
  @JsonValue('error') error,
}

/// Transaction Status
enum TransactionStatus {
  @JsonValue('pending') pending,
  @JsonValue('confirmed') confirmed,
  @JsonValue('failed') failed,
  @JsonValue('reverted') reverted,
  @JsonValue('expired') expired,
}

/// Data Access Level
enum DataAccessLevel {
  @JsonValue('public') public,
  @JsonValue('private') private,
  @JsonValue('restricted') restricted,
  @JsonValue('encrypted') encrypted,
  @JsonValue('anonymized') anonymized,
}

/// Audit Event Type
enum AuditEventType {
  @JsonValue('data_access') dataAccess,
  @JsonValue('data_modification') dataModification,
  @JsonValue('user_authentication') userAuthentication,
  @JsonValue('permission_change') permissionChange,
  @JsonValue('contract_execution') contractExecution,
  @JsonValue('system_configuration') systemConfiguration,
}

/// Blockchain Node
@JsonSerializable()
class BlockchainNode {
  final String id;
  final String name;
  final String url;
  final BlockchainNetworkType networkType;
  final String version;
  final bool isActive;
  final bool isValidator;
  final double uptime;
  final int blockHeight;
  final DateTime lastSync;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BlockchainNode({
    required this.id,
    required this.name,
    required this.url,
    required this.networkType,
    required this.version,
    required this.isActive,
    required this.isValidator,
    required this.uptime,
    required this.blockHeight,
    required this.lastSync,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlockchainNode.fromJson(Map<String, dynamic> json) =>
      _$BlockchainNodeFromJson(json);

  Map<String, dynamic> toJson() => _$BlockchainNodeToJson(this);
}

/// Smart Contract
@JsonSerializable()
class SmartContract {
  final String id;
  final String name;
  final String address;
  final String abi;
  final String bytecode;
  final String version;
  final SmartContractStatus status;
  final BlockchainNetworkType networkType;
  final String deployer;
  final DateTime deployedAt;
  final DateTime? upgradedAt;
  final Map<String, dynamic> metadata;
  final List<String> functions;
  final List<String> events;
  final bool isUpgradeable;
  final String? proxyAddress;
  final Map<String, dynamic> configuration;

  const SmartContract({
    required this.id,
    required this.name,
    required this.address,
    required this.abi,
    required this.bytecode,
    required this.version,
    required this.status,
    required this.networkType,
    required this.deployer,
    required this.deployedAt,
    this.upgradedAt,
    required this.metadata,
    required this.functions,
    required this.events,
    required this.isUpgradeable,
    this.proxyAddress,
    required this.configuration,
  });

  factory SmartContract.fromJson(Map<String, dynamic> json) =>
      _$SmartContractFromJson(json);

  Map<String, dynamic> toJson() => _$SmartContractToJson(this);
}

/// Blockchain Transaction
@JsonSerializable()
class BlockchainTransaction {
  final String id;
  final String hash;
  final String fromAddress;
  final String toAddress;
  final String contractAddress;
  final String functionName;
  final List<dynamic> parameters;
  final String value;
  final String gasUsed;
  final String gasPrice;
  final TransactionStatus status;
  final int blockNumber;
  final DateTime timestamp;
  final String? errorMessage;
  final Map<String, dynamic> metadata;
  final BlockchainNetworkType networkType;

  const BlockchainTransaction({
    required this.id,
    required this.hash,
    required this.fromAddress,
    required this.toAddress,
    required this.contractAddress,
    required this.functionName,
    required this.parameters,
    required this.value,
    required this.gasUsed,
    required this.gasPrice,
    required this.status,
    required this.blockNumber,
    required this.timestamp,
    this.errorMessage,
    required this.metadata,
    required this.networkType,
  });

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) =>
      _$BlockchainTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$BlockchainTransactionToJson(this);
}

/// Data Block
@JsonSerializable()
class DataBlock {
  final String id;
  final String blockHash;
  final int blockNumber;
  final String previousHash;
  final String merkleRoot;
  final DateTime timestamp;
  final List<String> transactions;
  final String dataHash;
  final DataAccessLevel accessLevel;
  final String encryptedData;
  final String encryptionKey;
  final Map<String, dynamic> metadata;
  final BlockchainNetworkType networkType;
  final bool isImmutable;

  const DataBlock({
    required this.id,
    required this.blockHash,
    required this.blockNumber,
    required this.previousHash,
    required this.merkleRoot,
    required this.timestamp,
    required this.transactions,
    required this.dataHash,
    required this.accessLevel,
    required this.encryptedData,
    required this.encryptionKey,
    required this.metadata,
    required this.networkType,
    required this.isImmutable,
  });

  factory DataBlock.fromJson(Map<String, dynamic> json) =>
      _$DataBlockFromJson(json);

  Map<String, dynamic> toJson() => _$DataBlockToJson(this);
}

/// Audit Trail Entry
@JsonSerializable()
class AuditTrailEntry {
  final String id;
  final String userId;
  final String userName;
  final AuditEventType eventType;
  final String resourceId;
  final String resourceType;
  final String action;
  final Map<String, dynamic> details;
  final String ipAddress;
  final String userAgent;
  final DateTime timestamp;
  final String blockchainHash;
  final bool isImmutable;
  final Map<String, dynamic> metadata;

  const AuditTrailEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.eventType,
    required this.resourceId,
    required this.resourceType,
    required this.action,
    required this.details,
    required this.ipAddress,
    required this.userAgent,
    required this.timestamp,
    required this.blockchainHash,
    required this.isImmutable,
    required this.metadata,
  });

  factory AuditTrailEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditTrailEntryFromJson(json);

  Map<String, dynamic> toJson() => _$AuditTrailEntryToJson(this);
}

/// Permission Contract
@JsonSerializable()
class PermissionContract {
  final String id;
  final String contractAddress;
  final String owner;
  final List<String> administrators;
  final Map<String, List<String>> rolePermissions;
  final Map<String, List<String>> userRoles;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> configuration;
  final BlockchainNetworkType networkType;

  const PermissionContract({
    required this.id,
    required this.contractAddress,
    required this.owner,
    required this.administrators,
    required this.rolePermissions,
    required this.userRoles,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.configuration,
    required this.networkType,
  });

  factory PermissionContract.fromJson(Map<String, dynamic> json) =>
      _$PermissionContractFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionContractToJson(this);
}

/// Encryption Key
@JsonSerializable()
class EncryptionKey {
  final String id;
  final String keyId;
  final String encryptedKey;
  final String algorithm;
  final int keySize;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String keyVersion;
  final Map<String, dynamic> metadata;
  final BlockchainNetworkType networkType;

  const EncryptionKey({
    required this.id,
    required this.keyId,
    required this.encryptedKey,
    required this.algorithm,
    required this.keySize,
    required this.createdAt,
    this.expiresAt,
    required this.isActive,
    required this.keyVersion,
    required this.metadata,
    required this.networkType,
  });

  factory EncryptionKey.fromJson(Map<String, dynamic> json) =>
      _$EncryptionKeyFromJson(json);

  Map<String, dynamic> toJson() => _$EncryptionKeyToJson(this);
}

/// Data Access Log
@JsonSerializable()
class DataAccessLog {
  final String id;
  final String userId;
  final String dataId;
  final String dataType;
  final DataAccessLevel accessLevel;
  final String accessMethod;
  final DateTime accessTime;
  final String purpose;
  final bool isAuthorized;
  final String? authorizationMethod;
  final Map<String, dynamic> metadata;
  final String blockchainHash;

  const DataAccessLog({
    required this.id,
    required this.userId,
    required this.dataId,
    required this.dataType,
    required this.accessLevel,
    required this.accessMethod,
    required this.accessTime,
    required this.purpose,
    required this.isAuthorized,
    this.authorizationMethod,
    required this.metadata,
    required this.blockchainHash,
  });

  factory DataAccessLog.fromJson(Map<String, dynamic> json) =>
      _$DataAccessLogFromJson(json);

  Map<String, dynamic> toJson() => _$DataAccessLogToJson(this);
}

/// Compliance Report
@JsonSerializable()
class ComplianceReport {
  final String id;
  final String reportType;
  final DateTime reportDate;
  final String generatedBy;
  final Map<String, dynamic> complianceData;
  final List<String> violations;
  final List<String> recommendations;
  final String status;
  final String blockchainHash;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const ComplianceReport({
    required this.id,
    required this.reportType,
    required this.reportDate,
    required this.generatedBy,
    required this.complianceData,
    required this.violations,
    required this.recommendations,
    required this.status,
    required this.blockchainHash,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory ComplianceReport.fromJson(Map<String, dynamic> json) =>
      _$ComplianceReportFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceReportToJson(this);
}

/// Network Configuration
@JsonSerializable()
class NetworkConfiguration {
  final String id;
  final BlockchainNetworkType networkType;
  final String rpcUrl;
  final String wsUrl;
  final int chainId;
  final String currency;
  final int blockTime;
  final int confirmationBlocks;
  final Map<String, dynamic> gasSettings;
  final List<String> trustedNodes;
  final Map<String, dynamic> securitySettings;
  final bool isTestnet;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NetworkConfiguration({
    required this.id,
    required this.networkType,
    required this.rpcUrl,
    required this.wsUrl,
    required this.chainId,
    required this.currency,
    required this.blockTime,
    required this.confirmationBlocks,
    required this.gasSettings,
    required this.trustedNodes,
    required this.securitySettings,
    required this.isTestnet,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NetworkConfiguration.fromJson(Map<String, dynamic> json) =>
      _$NetworkConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkConfigurationToJson(this);
}
