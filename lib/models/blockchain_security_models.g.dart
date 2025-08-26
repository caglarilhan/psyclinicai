// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blockchain_security_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockchainNode _$BlockchainNodeFromJson(Map<String, dynamic> json) =>
    BlockchainNode(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      networkType: $enumDecode(
        _$BlockchainNetworkTypeEnumMap,
        json['networkType'],
      ),
      version: json['version'] as String,
      isActive: json['isActive'] as bool,
      isValidator: json['isValidator'] as bool,
      uptime: (json['uptime'] as num).toDouble(),
      blockHeight: (json['blockHeight'] as num).toInt(),
      lastSync: DateTime.parse(json['lastSync'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BlockchainNodeToJson(BlockchainNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'networkType': _$BlockchainNetworkTypeEnumMap[instance.networkType]!,
      'version': instance.version,
      'isActive': instance.isActive,
      'isValidator': instance.isValidator,
      'uptime': instance.uptime,
      'blockHeight': instance.blockHeight,
      'lastSync': instance.lastSync.toIso8601String(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$BlockchainNetworkTypeEnumMap = {
  BlockchainNetworkType.ethereum: 'ethereum',
  BlockchainNetworkType.polygon: 'polygon',
  BlockchainNetworkType.binanceSmartChain: 'binance_smart_chain',
  BlockchainNetworkType.solana: 'solana',
  BlockchainNetworkType.private: 'private',
  BlockchainNetworkType.hybrid: 'hybrid',
};

SmartContract _$SmartContractFromJson(
  Map<String, dynamic> json,
) => SmartContract(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  abi: json['abi'] as String,
  bytecode: json['bytecode'] as String,
  version: json['version'] as String,
  status: $enumDecode(_$SmartContractStatusEnumMap, json['status']),
  networkType: $enumDecode(_$BlockchainNetworkTypeEnumMap, json['networkType']),
  deployer: json['deployer'] as String,
  deployedAt: DateTime.parse(json['deployedAt'] as String),
  upgradedAt: json['upgradedAt'] == null
      ? null
      : DateTime.parse(json['upgradedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
  functions: (json['functions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  events: (json['events'] as List<dynamic>).map((e) => e as String).toList(),
  isUpgradeable: json['isUpgradeable'] as bool,
  proxyAddress: json['proxyAddress'] as String?,
  configuration: json['configuration'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SmartContractToJson(SmartContract instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'abi': instance.abi,
      'bytecode': instance.bytecode,
      'version': instance.version,
      'status': _$SmartContractStatusEnumMap[instance.status]!,
      'networkType': _$BlockchainNetworkTypeEnumMap[instance.networkType]!,
      'deployer': instance.deployer,
      'deployedAt': instance.deployedAt.toIso8601String(),
      'upgradedAt': instance.upgradedAt?.toIso8601String(),
      'metadata': instance.metadata,
      'functions': instance.functions,
      'events': instance.events,
      'isUpgradeable': instance.isUpgradeable,
      'proxyAddress': instance.proxyAddress,
      'configuration': instance.configuration,
    };

const _$SmartContractStatusEnumMap = {
  SmartContractStatus.deployed: 'deployed',
  SmartContractStatus.active: 'active',
  SmartContractStatus.paused: 'paused',
  SmartContractStatus.upgraded: 'upgraded',
  SmartContractStatus.deprecated: 'deprecated',
  SmartContractStatus.error: 'error',
};

BlockchainTransaction _$BlockchainTransactionFromJson(
  Map<String, dynamic> json,
) => BlockchainTransaction(
  id: json['id'] as String,
  hash: json['hash'] as String,
  fromAddress: json['fromAddress'] as String,
  toAddress: json['toAddress'] as String,
  contractAddress: json['contractAddress'] as String,
  functionName: json['functionName'] as String,
  parameters: json['parameters'] as List<dynamic>,
  value: json['value'] as String,
  gasUsed: json['gasUsed'] as String,
  gasPrice: json['gasPrice'] as String,
  status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
  blockNumber: (json['blockNumber'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  errorMessage: json['errorMessage'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>,
  networkType: $enumDecode(_$BlockchainNetworkTypeEnumMap, json['networkType']),
);

Map<String, dynamic> _$BlockchainTransactionToJson(
  BlockchainTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'hash': instance.hash,
  'fromAddress': instance.fromAddress,
  'toAddress': instance.toAddress,
  'contractAddress': instance.contractAddress,
  'functionName': instance.functionName,
  'parameters': instance.parameters,
  'value': instance.value,
  'gasUsed': instance.gasUsed,
  'gasPrice': instance.gasPrice,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'blockNumber': instance.blockNumber,
  'timestamp': instance.timestamp.toIso8601String(),
  'errorMessage': instance.errorMessage,
  'metadata': instance.metadata,
  'networkType': _$BlockchainNetworkTypeEnumMap[instance.networkType]!,
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.confirmed: 'confirmed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.reverted: 'reverted',
  TransactionStatus.expired: 'expired',
};

DataBlock _$DataBlockFromJson(Map<String, dynamic> json) => DataBlock(
  id: json['id'] as String,
  blockHash: json['blockHash'] as String,
  blockNumber: (json['blockNumber'] as num).toInt(),
  previousHash: json['previousHash'] as String,
  merkleRoot: json['merkleRoot'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  transactions: (json['transactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dataHash: json['dataHash'] as String,
  accessLevel: $enumDecode(_$DataAccessLevelEnumMap, json['accessLevel']),
  encryptedData: json['encryptedData'] as String,
  encryptionKey: json['encryptionKey'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
  networkType: $enumDecode(_$BlockchainNetworkTypeEnumMap, json['networkType']),
  isImmutable: json['isImmutable'] as bool,
);

Map<String, dynamic> _$DataBlockToJson(DataBlock instance) => <String, dynamic>{
  'id': instance.id,
  'blockHash': instance.blockHash,
  'blockNumber': instance.blockNumber,
  'previousHash': instance.previousHash,
  'merkleRoot': instance.merkleRoot,
  'timestamp': instance.timestamp.toIso8601String(),
  'transactions': instance.transactions,
  'dataHash': instance.dataHash,
  'accessLevel': _$DataAccessLevelEnumMap[instance.accessLevel]!,
  'encryptedData': instance.encryptedData,
  'encryptionKey': instance.encryptionKey,
  'metadata': instance.metadata,
  'networkType': _$BlockchainNetworkTypeEnumMap[instance.networkType]!,
  'isImmutable': instance.isImmutable,
};

const _$DataAccessLevelEnumMap = {
  DataAccessLevel.public: 'public',
  DataAccessLevel.private: 'private',
  DataAccessLevel.restricted: 'restricted',
  DataAccessLevel.encrypted: 'encrypted',
  DataAccessLevel.anonymized: 'anonymized',
};

AuditTrailEntry _$AuditTrailEntryFromJson(Map<String, dynamic> json) =>
    AuditTrailEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      eventType: $enumDecode(_$AuditEventTypeEnumMap, json['eventType']),
      resourceId: json['resourceId'] as String,
      resourceType: json['resourceType'] as String,
      action: json['action'] as String,
      details: json['details'] as Map<String, dynamic>,
      ipAddress: json['ipAddress'] as String,
      userAgent: json['userAgent'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      blockchainHash: json['blockchainHash'] as String,
      isImmutable: json['isImmutable'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AuditTrailEntryToJson(AuditTrailEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'eventType': _$AuditEventTypeEnumMap[instance.eventType]!,
      'resourceId': instance.resourceId,
      'resourceType': instance.resourceType,
      'action': instance.action,
      'details': instance.details,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'timestamp': instance.timestamp.toIso8601String(),
      'blockchainHash': instance.blockchainHash,
      'isImmutable': instance.isImmutable,
      'metadata': instance.metadata,
    };

const _$AuditEventTypeEnumMap = {
  AuditEventType.dataAccess: 'data_access',
  AuditEventType.dataModification: 'data_modification',
  AuditEventType.userAuthentication: 'user_authentication',
  AuditEventType.permissionChange: 'permission_change',
  AuditEventType.contractExecution: 'contract_execution',
  AuditEventType.systemConfiguration: 'system_configuration',
};

PermissionContract _$PermissionContractFromJson(Map<String, dynamic> json) =>
    PermissionContract(
      id: json['id'] as String,
      contractAddress: json['contractAddress'] as String,
      owner: json['owner'] as String,
      administrators: (json['administrators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rolePermissions: (json['rolePermissions'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      userRoles: (json['userRoles'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      configuration: json['configuration'] as Map<String, dynamic>,
      networkType: $enumDecode(
        _$BlockchainNetworkTypeEnumMap,
        json['networkType'],
      ),
    );

Map<String, dynamic> _$PermissionContractToJson(PermissionContract instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contractAddress': instance.contractAddress,
      'owner': instance.owner,
      'administrators': instance.administrators,
      'rolePermissions': instance.rolePermissions,
      'userRoles': instance.userRoles,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'configuration': instance.configuration,
      'networkType': _$BlockchainNetworkTypeEnumMap[instance.networkType]!,
    };

EncryptionKey _$EncryptionKeyFromJson(Map<String, dynamic> json) =>
    EncryptionKey(
      id: json['id'] as String,
      keyId: json['keyId'] as String,
      encryptedKey: json['encryptedKey'] as String,
      algorithm: json['algorithm'] as String,
      keySize: (json['keySize'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool,
      keyVersion: json['keyVersion'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      networkType: $enumDecode(
        _$BlockchainNetworkTypeEnumMap,
        json['networkType'],
      ),
    );

Map<String, dynamic> _$EncryptionKeyToJson(EncryptionKey instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyId': instance.keyId,
      'encryptedKey': instance.encryptedKey,
      'algorithm': instance.algorithm,
      'keySize': instance.keySize,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isActive': instance.isActive,
      'keyVersion': instance.keyVersion,
      'metadata': instance.metadata,
      'networkType': _$BlockchainNetworkTypeEnumMap[instance.networkType]!,
    };

DataAccessLog _$DataAccessLogFromJson(Map<String, dynamic> json) =>
    DataAccessLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dataId: json['dataId'] as String,
      dataType: json['dataType'] as String,
      accessLevel: $enumDecode(_$DataAccessLevelEnumMap, json['accessLevel']),
      accessMethod: json['accessMethod'] as String,
      accessTime: DateTime.parse(json['accessTime'] as String),
      purpose: json['purpose'] as String,
      isAuthorized: json['isAuthorized'] as bool,
      authorizationMethod: json['authorizationMethod'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
      blockchainHash: json['blockchainHash'] as String,
    );

Map<String, dynamic> _$DataAccessLogToJson(DataAccessLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'dataId': instance.dataId,
      'dataType': instance.dataType,
      'accessLevel': _$DataAccessLevelEnumMap[instance.accessLevel]!,
      'accessMethod': instance.accessMethod,
      'accessTime': instance.accessTime.toIso8601String(),
      'purpose': instance.purpose,
      'isAuthorized': instance.isAuthorized,
      'authorizationMethod': instance.authorizationMethod,
      'metadata': instance.metadata,
      'blockchainHash': instance.blockchainHash,
    };

ComplianceReport _$ComplianceReportFromJson(Map<String, dynamic> json) =>
    ComplianceReport(
      id: json['id'] as String,
      reportType: json['reportType'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      generatedBy: json['generatedBy'] as String,
      complianceData: json['complianceData'] as Map<String, dynamic>,
      violations: (json['violations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      blockchainHash: json['blockchainHash'] as String,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ComplianceReportToJson(ComplianceReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportType': instance.reportType,
      'reportDate': instance.reportDate.toIso8601String(),
      'generatedBy': instance.generatedBy,
      'complianceData': instance.complianceData,
      'violations': instance.violations,
      'recommendations': instance.recommendations,
      'status': instance.status,
      'blockchainHash': instance.blockchainHash,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

NetworkConfiguration _$NetworkConfigurationFromJson(
  Map<String, dynamic> json,
) => NetworkConfiguration(
  id: json['id'] as String,
  networkType: $enumDecode(_$BlockchainNetworkTypeEnumMap, json['networkType']),
  rpcUrl: json['rpcUrl'] as String,
  wsUrl: json['wsUrl'] as String,
  chainId: (json['chainId'] as num).toInt(),
  currency: json['currency'] as String,
  blockTime: (json['blockTime'] as num).toInt(),
  confirmationBlocks: (json['confirmationBlocks'] as num).toInt(),
  gasSettings: json['gasSettings'] as Map<String, dynamic>,
  trustedNodes: (json['trustedNodes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  securitySettings: json['securitySettings'] as Map<String, dynamic>,
  isTestnet: json['isTestnet'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$NetworkConfigurationToJson(
  NetworkConfiguration instance,
) => <String, dynamic>{
  'id': instance.id,
  'networkType': _$BlockchainNetworkTypeEnumMap[instance.networkType]!,
  'rpcUrl': instance.rpcUrl,
  'wsUrl': instance.wsUrl,
  'chainId': instance.chainId,
  'currency': instance.currency,
  'blockTime': instance.blockTime,
  'confirmationBlocks': instance.confirmationBlocks,
  'gasSettings': instance.gasSettings,
  'trustedNodes': instance.trustedNodes,
  'securitySettings': instance.securitySettings,
  'isTestnet': instance.isTestnet,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
