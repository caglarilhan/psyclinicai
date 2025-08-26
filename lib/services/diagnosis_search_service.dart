import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/diagnosis_search_models.dart';

class AutoDiagnosisSuggestion {
  final String query;
  final List<String> suggestions;
  final DxSystem system;
  final DateTime generatedAt;

  const AutoDiagnosisSuggestion({
    required this.query,
    required this.suggestions,
    required this.system,
    required this.generatedAt,
  });
}

class DiagnosisSearchService {
  static const String _baseUrl = 'https://api.diagnosis.psyclinicai.com/v1';
  static const String _apiKey = 'diag_key_12345';

  final List<DxEntry> _catalog = [];
  final Map<String, RegionalDxConfig> _regionalConfigs = {};
  RegionalDxConfig? _currentRegion;

  final StreamController<DxEntry> _entryStreamController =
      StreamController<DxEntry>.broadcast();
  final StreamController<AutoDiagnosisSuggestion> _suggestionStreamController =
      StreamController<AutoDiagnosisSuggestion>.broadcast();

  Stream<DxEntry> get entryStream => _entryStreamController.stream;
  Stream<AutoDiagnosisSuggestion> get suggestionStream => _suggestionStreamController.stream;

  Future<void> initialize() async {
    await _loadRegionalConfigs();
    await _loadMockCatalog();
  }

  Future<void> _loadRegionalConfigs() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/regions'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        for (final d in data) {
          final cfg = RegionalDxConfig.fromJson(d);
          _regionalConfigs[cfg.region] = cfg;
        }
      } else {
        throw Exception('Regions error');
      }
    } catch (_) {
      // Fallback mock regional configs
      _regionalConfigs['US'] = RegionalDxConfig(
        region: 'US',
        defaultSystem: DxSystem.dsm5tr,
        language: 'en',
        codeMappings: {'6B00.0': 'F32.0'},
        metadata: {},
      );
      _regionalConfigs['EU'] = RegionalDxConfig(
        region: 'EU',
        defaultSystem: DxSystem.icd11,
        language: 'en',
        codeMappings: {'6B00.0': 'F32.0'},
        metadata: {},
      );
      _regionalConfigs['TR'] = RegionalDxConfig(
        region: 'TR',
        defaultSystem: DxSystem.icd10,
        language: 'tr',
        codeMappings: {'6B00.0': 'F32.0'},
        metadata: {},
      );
      _regionalConfigs['CA'] = RegionalDxConfig(
        region: 'CA',
        defaultSystem: DxSystem.icd11,
        language: 'en-fr',
        codeMappings: {'6B00.0': 'F32.0'},
        metadata: {},
      );
    }
    _currentRegion = _regionalConfigs['US'];
  }

  Future<void> setRegion(String region) async {
    _currentRegion = _regionalConfigs[region] ?? _currentRegion;
  }

  RegionalDxConfig? getCurrentRegion() => _currentRegion;

  Future<List<DxEntry>> search(DxSearchFilters filters) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/search'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(filters.toJson()),
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        return data.map((e) => DxEntry.fromJson(e)).toList();
      } else {
        throw Exception('search error');
      }
    } catch (_) {
      final q = (filters.query ?? '').toLowerCase().trim();
      final list = _catalog.where((e) {
        if (e.system != filters.system) return false;
        if (filters.minSeverity != null && e.typicalSeverity.index < filters.minSeverity!.index) return false;
        if (q.isEmpty) return true;
        final hay = <String>{
          e.title.toLowerCase(),
          e.description.toLowerCase(),
          e.code.toLowerCase(),
          ...e.synonyms.map((s) => s.toLowerCase()),
        };
        return hay.any((s) => s.contains(q));
      }).take(filters.limit).toList();
      for (final it in list) _entryStreamController.add(it);
      return list;
    }
  }

  Future<AutoDiagnosisSuggestion> suggest(String query, DxSystem system) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/suggest?q=${Uri.encodeQueryComponent(query)}&system=${system.name}'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      if (res.statusCode == 200) {
        final data = AutoDiagnosisSuggestion(
          query: query,
          suggestions: List<String>.from((json.decode(res.body)['suggestions'] ?? []) as List),
          system: system,
          generatedAt: DateTime.now(),
        );
        _suggestionStreamController.add(data);
        return data;
      } else {
        throw Exception('suggest error');
      }
    } catch (_) {
      final q = query.toLowerCase();
      final set = <String>{};
      for (final e in _catalog.where((e) => e.system == system)) {
        if (e.title.toLowerCase().startsWith(q)) set.add('${e.code} ${e.title}');
        for (final s in e.synonyms) {
          if (s.toLowerCase().startsWith(q)) set.add('${e.code} $s');
        }
      }
      final sugg = AutoDiagnosisSuggestion(
        query: query,
        suggestions: set.take(10).toList(),
        system: system,
        generatedAt: DateTime.now(),
      );
      _suggestionStreamController.add(sugg);
      return sugg;
    }
  }

  // Mock catalog covering common depressive/anxiety codes (DSM/ICD)
  Future<void> _loadMockCatalog() async {
    if (_catalog.isNotEmpty) return;
    _catalog.addAll([
      DxEntry(
        id: 'dsm_6B00_0',
        system: DxSystem.dsm5tr,
        code: '6B00.0',
        title: 'Depresif dönem (hafif)',
        description: 'Hafif düzeyde depresif belirtiler.',
        synonyms: ['depresyon hafif', 'major depresyon hafif'],
        typicalSeverity: DxSeverity.medium,
        metadata: {},
      ),
      DxEntry(
        id: 'dsm_6B00_1',
        system: DxSystem.dsm5tr,
        code: '6B00.1',
        title: 'Depresif dönem (orta)',
        description: 'Orta düzeyde depresif belirtiler.',
        synonyms: ['depresyon orta'],
        typicalSeverity: DxSeverity.high,
        metadata: {},
      ),
      DxEntry(
        id: 'dsm_6B01_0',
        system: DxSystem.dsm5tr,
        code: '6B01.0',
        title: 'Anksiyete bozukluğu',
        description: 'Yaygın anksiyete belirtileri.',
        synonyms: ['kaygı', 'genel anksiyete'],
        typicalSeverity: DxSeverity.medium,
        metadata: {},
      ),
      DxEntry(
        id: 'icd_F32_0',
        system: DxSystem.icd10,
        code: 'F32.0',
        title: 'Depresif epizod, hafif',
        description: 'ICD-10 hafif depresif epizod.',
        synonyms: ['F32 hafif'],
        typicalSeverity: DxSeverity.medium,
        metadata: {},
      ),
      DxEntry(
        id: 'icd_11_6A70',
        system: DxSystem.icd11,
        code: '6A70',
        title: 'Genelleşmiş anksiyete bozukluğu',
        description: 'ICD-11 GAD tanımı.',
        synonyms: ['GAD', 'genelleşmiş anksiyete'],
        typicalSeverity: DxSeverity.medium,
        metadata: {},
      ),
    ]);
  }

  void dispose() {
    if (!_entryStreamController.isClosed) _entryStreamController.close();
    if (!_suggestionStreamController.isClosed) _suggestionStreamController.close();
  }
}
