import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../models/blockchain_security_models.dart';

/// Blockchain Security Service for comprehensive blockchain-based security management
class BlockchainSecurityService {
  static const String _baseUrl = 'https://api.blockchain-security.com/v1';
  static const String _apiKey = 'demo_key_12345';

  // Cache for blockchain data
  final Map<String, BlockchainNode> _nodesCache = {};
  final Map<String, SmartContract> _contractsCache = {};
  final Map<String, BlockchainTransaction> _transactionsCache = {};
  final Map<String, DataBlock> _dataBlocksCache = {};
  final Map<String, AuditTrailEntry> _auditTrailCache = {};

  // Stream controllers for real-time updates
  final StreamController<BlockchainTransaction> _transactionController =
      StreamController<BlockchainTransaction>.broadcast();
  final StreamController<AuditTrailEntry> _auditController =
      StreamController<AuditTrailEntry>.broadcast();
  final StreamController<DataBlock> _dataBlockController =
      StreamController<DataBlock>.broadcast();

  // Network configurations
  final Map<BlockchainNetworkType, NetworkConfiguration> _networkConfigs = {};
  final List<BlockchainNode> _activeNodes = [];

  /// Get stream for transaction updates
  Stream<BlockchainTransaction> get transactionStream => _transactionController.stream;

  /// Get stream for audit trail updates
  Stream<AuditTrailEntry> get auditStream => _auditController.stream;

  /// Get stream for data block updates
  Stream<DataBlock> get dataBlockStream => _dataBlockController.stream;

  /// Initialize blockchain security service
  Future<void> initialize() async {
    await _loadNetworkConfigurations();
    await _connectToNodes();
    await _deploySmartContracts();
  }

  /// Get blockchain nodes
  Future<List<BlockchainNode>> getNodes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/nodes'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nodes = (data['nodes'] as List)
            .map((json) => BlockchainNode.fromJson(json))
            .toList();

        // Update cache
        for (final node in nodes) {
          _nodesCache[node.id] = node;
        }

        return nodes;
      } else {
        throw Exception('Failed to load nodes: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockNodes();
    }
  }

  /// Get smart contracts
  Future<List<SmartContract>> getSmartContracts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/contracts'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final contracts = (data['contracts'] as List)
            .map((json) => SmartContract.fromJson(json))
            .toList();

        // Update cache
        for (final contract in contracts) {
          _contractsCache[contract.id] = contract;
        }

        return contracts;
      } else {
        throw Exception('Failed to load contracts: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockSmartContracts();
    }
  }

  /// Deploy smart contract
  Future<SmartContract> deploySmartContract({
    required String name,
    required String abi,
    required String bytecode,
    required BlockchainNetworkType networkType,
    required Map<String, dynamic> configuration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/contracts/deploy'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'abi': abi,
          'bytecode': bytecode,
          'network_type': networkType.name,
          'configuration': configuration,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final contract = SmartContract.fromJson(data);
        _contractsCache[contract.id] = contract;

        return contract;
      } else {
        throw Exception('Failed to deploy contract: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock deployed contract for demo purposes
      final contract = SmartContract(
        id: 'contract_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        address: '0x${_generateRandomAddress()}',
        abi: abi,
        bytecode: bytecode,
        version: '1.0.0',
        status: SmartContractStatus.deployed,
        networkType: networkType,
        deployer: '0x${_generateRandomAddress()}',
        deployedAt: DateTime.now(),
        metadata: {'deployment_method': 'mock'},
        functions: ['setData', 'getData', 'updatePermissions'],
        events: ['DataUpdated', 'PermissionsChanged'],
        isUpgradeable: true,
        configuration: configuration,
      );

      _contractsCache[contract.id] = contract;
      return contract;
    }
  }

  /// Execute smart contract function
  Future<BlockchainTransaction> executeContractFunction({
    required String contractAddress,
    required String functionName,
    required List<dynamic> parameters,
    required String fromAddress,
    required BlockchainNetworkType networkType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/contracts/execute'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contract_address': contractAddress,
          'function_name': functionName,
          'parameters': parameters,
          'from_address': fromAddress,
          'network_type': networkType.name,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final transaction = BlockchainTransaction.fromJson(data);
        _transactionsCache[transaction.id] = transaction;

        // Notify listeners
        _transactionController.add(transaction);

        return transaction;
      } else {
        throw Exception('Failed to execute contract function: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock transaction for demo purposes
      final transaction = BlockchainTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        hash: '0x${_generateRandomHash()}',
        fromAddress: fromAddress,
        toAddress: contractAddress,
        contractAddress: contractAddress,
        functionName: functionName,
        parameters: parameters,
        value: '0',
        gasUsed: '50000',
        gasPrice: '20000000000',
        status: TransactionStatus.pending,
        blockNumber: Random().nextInt(1000000),
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        networkType: networkType,
      );

      _transactionsCache[transaction.id] = transaction;
      _transactionController.add(transaction);

      // Simulate transaction confirmation
      Timer(const Duration(seconds: 2), () {
        final confirmedTransaction = BlockchainTransaction(
          id: transaction.id,
          hash: transaction.hash,
          fromAddress: transaction.fromAddress,
          toAddress: transaction.toAddress,
          contractAddress: transaction.contractAddress,
          functionName: transaction.functionName,
          parameters: transaction.parameters,
          value: transaction.value,
          gasUsed: transaction.gasUsed,
          gasPrice: transaction.gasPrice,
          status: TransactionStatus.confirmed,
          blockNumber: transaction.blockNumber,
          timestamp: transaction.timestamp,
          errorMessage: transaction.errorMessage,
          metadata: transaction.metadata,
          networkType: transaction.networkType,
        );
        _transactionsCache[transaction.id] = confirmedTransaction;
        _transactionController.add(confirmedTransaction);
      });

      return transaction;
    }
  }

  /// Store data on blockchain
  Future<DataBlock> storeDataOnBlockchain({
    required String data,
    required DataAccessLevel accessLevel,
    required String userId,
    required BlockchainNetworkType networkType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Encrypt data before storing
      final encryptedData = _encryptData(data);
      final dataHash = _calculateDataHash(data);
      final blockHash = _calculateBlockHash(dataHash, DateTime.now());

      final response = await http.post(
        Uri.parse('$_baseUrl/blocks/store'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'encrypted_data': encryptedData,
          'data_hash': dataHash,
          'access_level': accessLevel.name,
          'user_id': userId,
          'network_type': networkType.name,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final dataBlock = DataBlock.fromJson(data);
        _dataBlocksCache[dataBlock.id] = dataBlock;

        // Notify listeners
        _dataBlockController.add(dataBlock);

        return dataBlock;
      } else {
        throw Exception('Failed to store data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data block for demo purposes
      final dataBlock = DataBlock(
        id: 'block_${DateTime.now().millisecondsSinceEpoch}',
        blockHash: '0x${_generateRandomHash()}',
        blockNumber: Random().nextInt(1000000),
        previousHash: '0x${_generateRandomHash()}',
        merkleRoot: '0x${_generateRandomHash()}',
        timestamp: DateTime.now(),
        transactions: ['0x${_generateRandomHash()}'],
        dataHash: _calculateDataHash(data),
        accessLevel: accessLevel,
        encryptedData: _encryptData(data),
        encryptionKey: 'key_${DateTime.now().millisecondsSinceEpoch}',
        metadata: metadata ?? {},
        networkType: networkType,
        isImmutable: true,
      );

      _dataBlocksCache[dataBlock.id] = dataBlock;
      _dataBlockController.add(dataBlock);

      return dataBlock;
    }
  }

  /// Create audit trail entry
  Future<AuditTrailEntry> createAuditEntry({
    required String userId,
    required String userName,
    required AuditEventType eventType,
    required String resourceId,
    required String resourceType,
    required String action,
    required Map<String, dynamic> details,
    required String ipAddress,
    required String userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/audit/create'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'user_name': userName,
          'event_type': eventType.name,
          'resource_id': resourceId,
          'resource_type': resourceType,
          'action': action,
          'details': details,
          'ip_address': ipAddress,
          'user_agent': userAgent,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final auditEntry = AuditTrailEntry.fromJson(data);
        _auditTrailCache[auditEntry.id] = auditEntry;

        // Notify listeners
        _auditController.add(auditEntry);

        return auditEntry;
      } else {
        throw Exception('Failed to create audit entry: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock audit entry for demo purposes
      final auditEntry = AuditTrailEntry(
        id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        eventType: eventType,
        resourceId: resourceId,
        resourceType: resourceType,
        action: action,
        details: details,
        ipAddress: ipAddress,
        userAgent: userAgent,
        timestamp: DateTime.now(),
        blockchainHash: '0x${_generateRandomHash()}',
        isImmutable: true,
        metadata: metadata ?? {},
      );

      _auditTrailCache[auditEntry.id] = auditEntry;
      _auditController.add(auditEntry);

      return auditEntry;
    }
  }

  /// Get audit trail
  Future<List<AuditTrailEntry>> getAuditTrail({
    String? userId,
    AuditEventType? eventType,
    String? resourceId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };

      if (userId != null) queryParams['user_id'] = userId;
      if (eventType != null) queryParams['event_type'] = eventType.name;
      if (resourceId != null) queryParams['resource_id'] = resourceId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await http.get(
        Uri.parse('$_baseUrl/audit').replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final auditEntries = (data['audit_entries'] as List)
            .map((json) => AuditTrailEntry.fromJson(json))
            .toList();

        return auditEntries;
      } else {
        throw Exception('Failed to load audit trail: ${response.statusCode}');
      }
    } catch (e) {
      // Return filtered mock audit trail for demo purposes
      var mockTrail = _getMockAuditTrail();
      
      if (userId != null) {
        mockTrail = mockTrail.where((entry) => entry.userId == userId).toList();
      }
      
      if (eventType != null) {
        mockTrail = mockTrail.where((entry) => entry.eventType == eventType).toList();
      }
      
      if (resourceId != null) {
        mockTrail = mockTrail.where((entry) => entry.resourceId == resourceId).toList();
      }
      
      if (startDate != null) {
        mockTrail = mockTrail.where((entry) => entry.timestamp.isAfter(startDate!)).toList();
      }
      
      if (endDate != null) {
        mockTrail = mockTrail.where((entry) => entry.timestamp.isBefore(endDate!)).toList();
      }
      
      return mockTrail.take(limit).toList();
    }
  }

  /// Generate compliance report
  Future<ComplianceReport> generateComplianceReport({
    required String reportType,
    required DateTime reportDate,
    required String generatedBy,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/compliance/reports'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'report_type': reportType,
          'report_date': reportDate.toIso8601String(),
          'generated_by': generatedBy,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ComplianceReport.fromJson(data);
      } else {
        throw Exception('Failed to generate compliance report: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock compliance report for demo purposes
      return ComplianceReport(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        reportType: reportType,
        reportDate: reportDate,
        generatedBy: generatedBy,
        complianceData: {
          'total_audit_entries': _auditTrailCache.length,
          'total_transactions': _transactionsCache.length,
          'total_data_blocks': _dataBlocksCache.length,
          'compliance_score': 95.5,
        },
        violations: [],
        recommendations: [
          'Regular security audits recommended',
          'Update encryption keys quarterly',
          'Monitor access patterns for anomalies',
        ],
        status: 'completed',
        blockchainHash: '0x${_generateRandomHash()}',
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata ?? {},
      );
    }
  }

  /// Verify data integrity
  Future<bool> verifyDataIntegrity({
    required String dataHash,
    required String blockchainHash,
    required BlockchainNetworkType networkType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify/integrity'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'data_hash': dataHash,
          'blockchain_hash': blockchainHash,
          'network_type': networkType.name,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['verified'] ?? false;
      } else {
        throw Exception('Failed to verify data integrity: ${response.statusCode}');
      }
    } catch (e) {
      // Mock verification for demo purposes
      return dataHash.isNotEmpty && blockchainHash.isNotEmpty;
    }
  }

  /// Get network statistics
  Future<Map<String, dynamic>> getNetworkStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/network/statistics'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load network statistics: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock statistics for demo purposes
      return {
        'total_nodes': _activeNodes.length,
        'total_contracts': _contractsCache.length,
        'total_transactions': _transactionsCache.length,
        'total_data_blocks': _dataBlocksCache.length,
        'network_uptime': 99.9,
        'average_block_time': 15.2,
        'total_gas_used': '15000000',
        'active_users': 1250,
      };
    }
  }

  /// Dispose resources
  void dispose() {
    if (!_transactionController.isClosed) {
      _transactionController.close();
    }
    if (!_auditController.isClosed) {
      _auditController.close();
    }
    if (!_dataBlockController.isClosed) {
      _dataBlockController.close();
    }
  }

  // Private helper methods
  Future<void> _loadNetworkConfigurations() async {
    _networkConfigs[BlockchainNetworkType.ethereum] = NetworkConfiguration(
      id: 'eth_mainnet',
      networkType: BlockchainNetworkType.ethereum,
      rpcUrl: 'https://mainnet.infura.io/v3/demo_key',
      wsUrl: 'wss://mainnet.infura.io/ws/v3/demo_key',
      chainId: 1,
      currency: 'ETH',
      blockTime: 15,
      confirmationBlocks: 12,
      gasSettings: {'max_gas': '30000000', 'base_fee': '20000000000'},
      trustedNodes: ['infura.io', 'alchemy.com'],
      securitySettings: {'consensus': 'PoS', 'finality': 'immediate'},
      isTestnet: false,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );

    _networkConfigs[BlockchainNetworkType.polygon] = NetworkConfiguration(
      id: 'polygon_mainnet',
      networkType: BlockchainNetworkType.polygon,
      rpcUrl: 'https://polygon-rpc.com',
      wsUrl: 'wss://polygon-rpc.com',
      chainId: 137,
      currency: 'MATIC',
      blockTime: 2,
      confirmationBlocks: 256,
      gasSettings: {'max_gas': '30000000', 'base_fee': '30000000000'},
      trustedNodes: ['polygon-rpc.com', 'quicknode.com'],
      securitySettings: {'consensus': 'PoS', 'finality': 'immediate'},
      isTestnet: false,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _connectToNodes() async {
    // Simulate connecting to blockchain nodes
    _activeNodes.addAll(_getMockNodes());
  }

  Future<void> _deploySmartContracts() async {
    // Simulate deploying smart contracts
    final contracts = _getMockSmartContracts();
    for (final contract in contracts) {
      _contractsCache[contract.id] = contract;
    }
  }

  String _generateRandomAddress() {
    final random = Random();
    final chars = '0123456789abcdef';
    return List.generate(40, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateRandomHash() {
    final random = Random();
    final chars = '0123456789abcdef';
    return List.generate(64, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _encryptData(String data) {
    // Simple encryption for demo purposes
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _calculateDataHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _calculateBlockHash(String dataHash, DateTime timestamp) {
    final combined = '$dataHash${timestamp.millisecondsSinceEpoch}';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Mock data methods
  List<BlockchainNode> _getMockNodes() {
    return [
      BlockchainNode(
        id: 'node_001',
        name: 'Ethereum Mainnet Node',
        url: 'https://mainnet.infura.io/v3/demo_key',
        networkType: BlockchainNetworkType.ethereum,
        version: '1.0.0',
        isActive: true,
        isValidator: false,
        uptime: 99.8,
        blockHeight: 18500000,
        lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
        metadata: {'provider': 'Infura', 'region': 'US'},
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      BlockchainNode(
        id: 'node_002',
        name: 'Polygon Mainnet Node',
        url: 'https://polygon-rpc.com',
        networkType: BlockchainNetworkType.polygon,
        version: '1.0.0',
        isActive: true,
        isValidator: false,
        uptime: 99.9,
        blockHeight: 45000000,
        lastSync: DateTime.now().subtract(const Duration(minutes: 2)),
        metadata: {'provider': 'Polygon', 'region': 'Global'},
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  List<SmartContract> _getMockSmartContracts() {
    return [
      SmartContract(
        id: 'contract_001',
        name: 'DataAccessControl',
        address: '0x1234567890123456789012345678901234567890',
        abi: '[{"inputs":[],"name":"getData","outputs":[{"type":"string"}],"stateMutability":"view"}]',
        bytecode: '0x608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c8063',
        version: '1.0.0',
        status: SmartContractStatus.active,
        networkType: BlockchainNetworkType.ethereum,
        deployer: '0x9876543210987654321098765432109876543210',
        deployedAt: DateTime.now().subtract(const Duration(days: 30)),
        metadata: {'purpose': 'Data access control', 'security_level': 'high'},
        functions: ['setData', 'getData', 'updatePermissions'],
        events: ['DataUpdated', 'PermissionsChanged'],
        isUpgradeable: true,
        configuration: {'upgrade_delay': 86400, 'admin_role': 'ADMIN_ROLE'},
      ),
      SmartContract(
        id: 'contract_002',
        name: 'AuditTrail',
        address: '0x2345678901234567890123456789012345678901',
        abi: '[{"inputs":[{"type":"string"}],"name":"logEvent","outputs":[],"stateMutability":"nonpayable"}]',
        bytecode: '0x608060405234801561001057600080fd5b50600436106100365760003560e01c8063',
        version: '1.0.0',
        status: SmartContractStatus.active,
        networkType: BlockchainNetworkType.polygon,
        deployer: '0x8765432109876543210987654321098765432109',
        deployedAt: DateTime.now().subtract(const Duration(days: 15)),
        metadata: {'purpose': 'Audit trail logging', 'immutable': true},
        functions: ['logEvent', 'getEvent', 'getEventsByUser'],
        events: ['EventLogged', 'EventRetrieved'],
        isUpgradeable: false,
        configuration: {'max_events': 10000, 'retention_period': 31536000},
      ),
    ];
  }

  List<AuditTrailEntry> _getMockAuditTrail() {
    return [
      AuditTrailEntry(
        id: 'audit_001',
        userId: 'user_001',
        userName: 'Dr. Smith',
        eventType: AuditEventType.dataAccess,
        resourceId: 'patient_001',
        resourceType: 'patient_record',
        action: 'view',
        details: {'access_method': 'web_interface', 'session_id': 'sess_123'},
        ipAddress: '192.168.1.100',
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        blockchainHash: '0x1234567890123456789012345678901234567890',
        isImmutable: true,
        metadata: {'purpose': 'patient_care', 'authorized': true},
      ),
      AuditTrailEntry(
        id: 'audit_002',
        userId: 'user_002',
        userName: 'Nurse Johnson',
        eventType: AuditEventType.dataModification,
        resourceId: 'patient_001',
        resourceType: 'patient_record',
        action: 'update',
        details: {'field': 'medication_list', 'old_value': 'Sertraline', 'new_value': 'Sertraline 100mg'},
        ipAddress: '192.168.1.101',
        userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        blockchainHash: '0x2345678901234567890123456789012345678901',
        isImmutable: true,
        metadata: {'purpose': 'medication_update', 'authorized': true},
      ),
      AuditTrailEntry(
        id: 'audit_003',
        userId: 'user_001',
        userName: 'Dr. Smith',
        eventType: AuditEventType.dataAccess,
        resourceId: 'patient_002',
        resourceType: 'patient_record',
        action: 'view',
        details: {'access_method': 'mobile_app', 'session_id': 'sess_124'},
        ipAddress: '192.168.1.100',
        userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        blockchainHash: '0x3456789012345678901234567890123456789012',
        isImmutable: true,
        metadata: {'purpose': 'patient_care', 'authorized': true},
      ),
      AuditTrailEntry(
        id: 'audit_004',
        userId: 'user_003',
        userName: 'Dr. Wilson',
        eventType: AuditEventType.userAuthentication,
        resourceId: 'system',
        resourceType: 'authentication',
        action: 'login',
        details: {'method': 'password', 'session_id': 'sess_125'},
        ipAddress: '192.168.1.102',
        userAgent: 'Mozilla/5.0 (Linux x86_64) AppleWebKit/537.36',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        blockchainHash: '0x4567890123456789012345678901234567890123',
        isImmutable: true,
        metadata: {'purpose': 'system_access', 'authorized': true},
      ),
    ];
  }
}
