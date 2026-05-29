import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key_storage.dart';
import 'copilot_endpoint.dart';
import 'prompt_safety.dart';

/// Generates structured therapy notes (SOAP / DAP / BIRP) from a session
/// transcript using Anthropic Claude Haiku 3.5.
///
/// Uses raw HTTP for full control over the request shape and to avoid
/// dependency drift in third-party packages. Cost ~$0.001 per 5-minute session.
class SoapGeneratorService {
  SoapGeneratorService({ApiKeyStorage? keyStorage, http.Client? client})
      : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;

  static const String _model = 'claude-haiku-4-5-20251001';

  Future<SoapNote> generate({
    required String transcript,
    required SoapFormat format,
    String? clientName,
    String? clientPresenting,
    String? clinicianRole,
    List<String> treatmentGoals = const [],
    Modality modality = Modality.general,
  }) async {
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const SoapGeneratorException(
        SoapGeneratorErrorCode.noApiKey,
        'No Anthropic API key configured. Add one under Settings → API Keys.',
      );
    }

    final system =
        _systemPrompt(format, clinicianRole) + _modalityGuidance(modality);
    final user = _userPrompt(
      transcript: transcript,
      clientName: clientName,
      presenting: clientPresenting,
      treatmentGoals: treatmentGoals,
    );

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 1500,
      'temperature': 0.2,
      'system': system,
      'messages': [
        {'role': 'user', 'content': user}
      ],
    });

    http.Response resp;
    try {
      resp = await _client
          .post(
            CopilotEndpoint.uri,
            headers: CopilotEndpoint.headers(key),
            body: body,
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw SoapGeneratorException(
        SoapGeneratorErrorCode.network,
        'Network error reaching Anthropic. $e',
      );
    }

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw const SoapGeneratorException(
        SoapGeneratorErrorCode.unauthorized,
        'Anthropic rejected the API key. Verify it in Settings → API Keys.',
      );
    }
    if (resp.statusCode == 429) {
      throw const SoapGeneratorException(
        SoapGeneratorErrorCode.rateLimit,
        'Rate limit hit. Wait a moment and retry.',
      );
    }
    if (resp.statusCode >= 500) {
      throw SoapGeneratorException(
        SoapGeneratorErrorCode.server,
        'Anthropic server error ${resp.statusCode}.',
      );
    }
    if (resp.statusCode != 200) {
      throw SoapGeneratorException(
        SoapGeneratorErrorCode.unknown,
        'Unexpected response ${resp.statusCode}: ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = (decoded['content'] as List<dynamic>? ?? const [])
        .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
        .join('\n')
        .trim();

    if (content.isEmpty) {
      throw const SoapGeneratorException(
        SoapGeneratorErrorCode.empty,
        'Anthropic returned an empty response.',
      );
    }

    return SoapNote.parse(content, format: format);
  }

  String _systemPrompt(SoapFormat format, String? clinicianRole) {
    final role = clinicianRole ?? 'licensed mental health clinician';
    switch (format) {
      case SoapFormat.soap:
        return '''
You are an experienced $role drafting a SOAP progress note from a session
transcript. Output ONLY four labelled sections, in plain markdown, with these
exact headings and order:

## S — Subjective
(Client's reported experience, mood, presenting concerns. 3-5 concise bullets.)

## O — Objective
(Therapist's observations: affect, behavior, engagement, mental status. 3-5 bullets.)

## A — Assessment
(Clinical impression, working diagnosis with DSM-5 / ICD-11 codes when supported
by the transcript, risk level (low/moderate/high), progress vs. treatment plan.)

## P — Plan
(Interventions used, homework assigned, next appointment, referrals,
medication considerations. 3-5 bullets.)

Rules:
- Do NOT invent details not present in the transcript.
- If risk indicators (suicidal ideation, self-harm, homicidal ideation,
  substance use) appear, flag them explicitly in **Assessment** with a
  marker.
- Maintain HIPAA-appropriate clinical tone. No PHI beyond what the transcript
  contains.
- Keep total length under 350 words.
''';
      case SoapFormat.dap:
        return '''
You are an experienced $role drafting a DAP (Data, Assessment, Plan) progress
note from a session transcript. Output ONLY three labelled sections in plain
markdown:

## D — Data
(Both subjective report and objective observations. 5-7 bullets.)

## A — Assessment
(Clinical impression, DSM-5/ICD-11 codes if supported, risk level, treatment
progress.)

## P — Plan
(Interventions, homework, next steps. 3-5 bullets.)

Rules: do not invent details. Flag risk indicators with a marker. Total under 300 words.
''';
      case SoapFormat.birp:
        return '''
You are an experienced $role drafting a BIRP (Behavior, Intervention, Response,
Plan) note from a session transcript. Output ONLY four labelled sections:

## B — Behavior
## I — Intervention
## R — Response
## P — Plan

3-5 bullets per section. Do not invent details. Flag risk with a marker. Under 350 words.
''';
      case SoapFormat.girp:
        return '''
You are an experienced $role drafting a GIRP (Goal, Intervention, Response,
Plan) note from a session transcript. Output ONLY four labelled sections:

## G — Goal
(The treatment-plan goal/objective this session addressed — the golden thread.)

## I — Intervention
(Specific techniques used and why they were appropriate.)

## R — Response
(Client's response to the interventions, observable engagement and progress.)

## P — Plan
(Homework, next session focus, frequency, referrals, medication considerations.)

3-5 bullets per section. Do not invent details. Flag risk with a marker. Under 350 words.
''';
      case SoapFormat.psychiatry:
        return '''
You are an experienced psychiatric prescriber drafting a medication-management
+ psychotherapy progress note from a session transcript. Output ONLY these
labelled sections in plain markdown:

## Interval history
(Since last visit: symptom course, adherence, side effects, stressors.)

## Mental Status Exam
(Appearance, behavior, speech, mood/affect, thought process/content, perception,
cognition, insight/judgment. Note "no SI/HI" explicitly if applicable.)

## Assessment
(Diagnosis with DSM-5/ICD-10 codes, risk level, response to current regimen,
progress vs. treatment plan.)

## Plan
(Medication decisions WITH rationale — start/continue/adjust/discontinue + dose,
target symptoms, expected effects; labs/monitoring; psychotherapy element if
provided; follow-up interval.)

Rules:
- Do NOT invent medications, doses, or details not present in the transcript.
- Flag risk (SI/HI/self-harm/substance) explicitly in **Assessment**.
- If both an E/M service and psychotherapy occurred, make both clearly
  documented and separable. Keep under 400 words.
''';
    }
  }

  String _modalityGuidance(Modality modality) {
    final m = switch (modality) {
      Modality.general => '',
      Modality.cbt =>
        'Frame interventions in CBT terms (cognitive restructuring, thought '
            'records, behavioral experiments, homework).',
      Modality.dbt =>
        'Frame interventions in DBT terms (skills: mindfulness, distress '
            'tolerance, emotion regulation, interpersonal effectiveness; diary card).',
      Modality.emdr =>
        'Frame interventions in EMDR terms (phase, target, SUDS/VOC, bilateral '
            'stimulation, installation) without inventing details.',
      Modality.ifs =>
        'Frame interventions in IFS terms (parts, Self-energy, unburdening) '
            'without inventing details.',
      Modality.act =>
        'Frame interventions in ACT terms (values, defusion, acceptance, '
            'committed action, present-moment).',
      Modality.ocdErp =>
        'Frame interventions in ERP terms for OCD (hierarchy, exposure, '
            'response prevention, SUDS) without inventing details.',
      Modality.schema =>
        'Frame in Schema Therapy terms (early maladaptive schemas, schema '
            'modes such as vulnerable child / punitive parent / healthy adult, '
            'mode work, limited reparenting) without inventing details.',
      Modality.psychodynamic =>
        'Frame in psychodynamic terms (defense mechanisms, transference/'
            'countertransference, recurring relational patterns, insight) '
            'without inventing details.',
    };
    return m.isEmpty ? '' : '\n\nModality: $m';
  }

  String _userPrompt({
    required String transcript,
    String? clientName,
    String? presenting,
    List<String> treatmentGoals = const [],
  }) {
    final header = StringBuffer();
    if (clientName != null && clientName.isNotEmpty) {
      header.writeln('Client: ${PromptSafety.sanitize(clientName)}');
    }
    if (presenting != null && presenting.isNotEmpty) {
      header.writeln(
          'Presenting concern: ${PromptSafety.sanitize(presenting)}');
    }
    if (treatmentGoals.isNotEmpty) {
      header.writeln('Active treatment-plan goals (reference progress toward '
          'these in the Assessment — the "golden thread"):');
      for (final g in treatmentGoals) {
        header.writeln('- $g');
      }
    }
    if (header.isNotEmpty) header.writeln('---');
    header.writeln('Session transcript (raw, may contain ASR errors):');
    header.writeln();
    header.writeln(PromptSafety.fence('transcript', transcript));
    return header.toString();
  }

  void dispose() => _client.close();
}

enum SoapFormat { soap, dap, birp, girp, psychiatry }

extension SoapFormatX on SoapFormat {
  String get label => switch (this) {
        SoapFormat.soap => 'SOAP',
        SoapFormat.dap => 'DAP',
        SoapFormat.birp => 'BIRP',
        SoapFormat.girp => 'GIRP',
        SoapFormat.psychiatry => 'Psychiatry',
      };
}

/// Therapeutic modality the note should be tailored to. `general` adds no
/// extra guidance.
enum Modality {
  general,
  cbt,
  dbt,
  emdr,
  ifs,
  act,
  ocdErp,
  schema,
  psychodynamic,
}

extension ModalityX on Modality {
  String get label => switch (this) {
        Modality.general => 'General',
        Modality.cbt => 'CBT',
        Modality.dbt => 'DBT',
        Modality.emdr => 'EMDR',
        Modality.ifs => 'IFS',
        Modality.act => 'ACT',
        Modality.ocdErp => 'OCD / ERP',
        Modality.schema => 'Schema',
        Modality.psychodynamic => 'Psychodynamic',
      };
}

class SoapNote {

  factory SoapNote.parse(String content, {required SoapFormat format}) {
    final hasRiskFlag = content.toLowerCase().contains('risk') &&
        (content.contains('high') || content.contains('moderate'));
    return SoapNote(
      rawMarkdown: content,
      format: format,
      generatedAt: DateTime.now(),
      flaggedRisk: hasRiskFlag,
    );
  }
  SoapNote({
    required this.rawMarkdown,
    required this.format,
    required this.generatedAt,
    this.flaggedRisk = false,
  });

  final String rawMarkdown;
  final SoapFormat format;
  final DateTime generatedAt;
  final bool flaggedRisk;
}

enum SoapGeneratorErrorCode {
  noApiKey,
  unauthorized,
  rateLimit,
  server,
  network,
  empty,
  unknown,
}

class SoapGeneratorException implements Exception {
  const SoapGeneratorException(this.code, this.message);
  final SoapGeneratorErrorCode code;
  final String message;

  @override
  String toString() => 'SoapGeneratorException($code): $message';
}
