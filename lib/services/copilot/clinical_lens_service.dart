import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/clinical_lens.dart';
import 'api_key_storage.dart';
import 'soap_generator_service.dart' show Modality, ModalityX;

/// Extracts the selected modality's own clinical constructs from a session
/// transcript (the "clinical depth" engine). Each modality has a fixed set of
/// constructs — Schema pulls triggered schemas + active modes, CBT pulls
/// automatic thoughts + distortions, Psychodynamic pulls defenses +
/// transference, and so on — so the output speaks the clinician's framework
/// rather than a flat summary.
///
/// BYOK Claude (mirrors the SOAP generator pattern). Decision-support — only
/// surfaces what the transcript supports; it does not invent clinical material.
class ClinicalLensService {
  ClinicalLensService({ApiKeyStorage? keyStorage, http.Client? client})
      : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;

  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  /// The constructs each modality extracts — the section titles of the lens.
  /// Every [Modality] is covered so the UI never falls back to a flat note.
  static const Map<Modality, List<String>> _constructs = {
    Modality.general: [
      'Themes',
      'Interventions used',
      'Client response',
    ],
    Modality.cbt: [
      'Automatic thoughts',
      'Cognitive distortions',
      'Behavioral targets / homework',
    ],
    Modality.dbt: [
      'Skills used',
      'Target behaviors',
      'Diary-card observations',
    ],
    Modality.emdr: [
      'Targets',
      'Phase / SUDS / VOC',
      'Processing observations',
    ],
    Modality.ifs: [
      'Parts identified',
      'Self-energy / unburdening',
      'Protector dynamics',
    ],
    Modality.act: [
      'Values touched',
      'Defusion / acceptance work',
      'Committed action',
    ],
    Modality.ocdErp: [
      'Obsessions / compulsions',
      'Exposure hierarchy',
      'Response prevention',
    ],
    Modality.schema: [
      'Triggered schemas',
      'Active modes',
      'Mode work / interventions',
    ],
    Modality.psychodynamic: [
      'Defense mechanisms',
      'Transference / countertransference',
      'Recurring relational patterns',
    ],
  };

  /// The construct labels for [modality] (the lens sections). Pure + testable.
  static List<String> constructsFor(Modality modality) =>
      _constructs[modality] ?? _constructs[Modality.general]!;

  /// Extracts the lens for [modality] from [transcript]. Throws
  /// [ClinicalLensException] (noKey set) when no key is configured.
  Future<ClinicalLens> extract({
    required String transcript,
    required Modality modality,
  }) async {
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const ClinicalLensException(
        'No Anthropic API key configured. Add one under Settings → API Keys.',
        noKey: true,
      );
    }

    final labels = constructsFor(modality);
    final system =
        'You are a ${modality.label} clinician reviewing a session transcript. '
        'Extract ONLY these constructs, grounded strictly in the transcript — '
        'do not invent or infer beyond what was said: ${labels.join('; ')}. '
        'Each item must be a short, concrete phrase. Omit a construct if the '
        'transcript offers nothing for it. Decision-support, not a diagnosis. '
        'Respond STRICT JSON only: {"sections":[{"title":"<one of the '
        'constructs>","items":["...","..."]}]}';

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 800,
      'temperature': 0.2,
      'system': system,
      'messages': [
        {'role': 'user', 'content': transcript}
      ],
    });

    try {
      final resp = await _client
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': key,
              'anthropic-version': _anthropicVersion,
              'anthropic-dangerous-direct-browser-access': 'true',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 40));
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw const ClinicalLensException(
            'Anthropic rejected the API key. Verify it in Settings → API Keys.');
      }
      if (resp.statusCode != 200) {
        throw ClinicalLensException(
            'Anthropic error ${resp.statusCode}. Try again shortly.');
      }
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = (decoded['content'] as List<dynamic>? ?? const [])
          .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
          .join('\n')
          .trim();
      final lens = parse(content, modality);
      if (lens == null) {
        throw const ClinicalLensException(
            'Could not parse the clinical lens. Try again.');
      }
      return lens;
    } on ClinicalLensException {
      rethrow;
    } catch (e) {
      throw ClinicalLensException('Network error reaching Anthropic. $e');
    }
  }

  /// Parses the model's JSON into a [ClinicalLens]. Pure + testable; keeps only
  /// sections whose title is one of the modality's constructs.
  ClinicalLens? parse(String content, Modality modality) {
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final j =
          jsonDecode(content.substring(start, end + 1)) as Map<String, dynamic>;
      final allowed = constructsFor(modality).toSet();
      final raw = j['sections'] as List<dynamic>? ?? const [];
      final sections = <LensSection>[];
      for (final e in raw) {
        if (e is! Map<String, dynamic>) continue;
        final title = (e['title'] as String?)?.trim() ?? '';
        if (!allowed.contains(title)) continue;
        final items = (e['items'] as List<dynamic>? ?? const [])
            .map((x) => x.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (items.isEmpty) continue;
        sections.add(LensSection(title: title, items: items));
      }
      if (sections.isEmpty) return null;
      return ClinicalLens(modalityLabel: modality.label, sections: sections);
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}

class ClinicalLensException implements Exception {
  const ClinicalLensException(this.message, {this.noKey = false});
  final String message;
  final bool noKey;

  @override
  String toString() => 'ClinicalLensException: $message';
}
