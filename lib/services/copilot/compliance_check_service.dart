import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key_storage.dart';

/// Audit-readiness checker for a generated progress note.
///
/// Scores a note against the payer/auditor "golden thread" rubric distilled
/// from CMS, Optum, Centene and county behavioral-health documentation
/// standards (2025–2026). It is **decision-support** — it flags likely audit
/// gaps for the clinician to fix; it does not guarantee reimbursement.
///
/// Background: a 2023 HHS-OIG audit found ~$580M of $1B in psychotherapy
/// payments were *improper for documentation reasons* (missing time, missing
/// signatures) — not fraud. This checker targets exactly those gaps.
///
/// Two tiers, mirroring [RiskSignalService]:
///  - [check] — Tier 1: deterministic, offline, free heuristics over the note
///    text. Instant, recall-biased (flags for review).
///  - [deepCheck] — Tier 2: optional Claude semantic review (BYOK) for the
///    judgement calls (functional impairment, intervention↔goal linkage,
///    medical-necessity narrative). Returns the Tier-1 report unchanged on
///    no-key / error.
class ComplianceCheckService {
  ComplianceCheckService({ApiKeyStorage? keyStorage, http.Client? client})
    : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
      _client = client ?? http.Client();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;

  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  // The rubric: id → (label, keywords, fix when missing).
  static final List<_Rule> _rules = [
    _Rule(
      id: 'diagnosis',
      label: 'Diagnosis documented',
      patterns: [
        RegExp(r'\b[fF]\d{2}(\.\d+)?\b'), // ICD-10 F-code
        RegExp(r'diagnos', caseSensitive: false),
      ],
      fix: 'State a specific DSM-5/ICD-10 diagnosis (highest specificity).',
    ),
    _Rule(
      id: 'functional_impairment',
      label: 'Functional impairment',
      patterns: [
        RegExp(
          r'\b(function|impair|unable to|difficulty|work|job|relationship|self-care|daily|sleep|appetite|concentrat)',
          caseSensitive: false,
        ),
      ],
      fix:
          'Document how symptoms impair daily functioning (work, relationships, '
          'self-care) — the most under-documented audit signal.',
    ),
    _Rule(
      id: 'intervention',
      label: 'Named intervention',
      patterns: [
        RegExp(
          r'\b(CBT|DBT|EMDR|exposure|cognitive|behavioral activation|motivational|mindfulness|psychoeducation|restructur|interpersonal|ACT|schema|IFS|grounding|relapse prevention|safety plan)',
          caseSensitive: false,
        ),
      ],
      fix:
          'Name the specific technique used (e.g. cognitive restructuring, '
          'exposure) — not just "provided therapy".',
    ),
    _Rule(
      id: 'response',
      label: 'Client response to intervention',
      patterns: [
        RegExp(
          r'\b(responded|response|engaged|tolerated|reported|able to|identified|practiced|insight)',
          caseSensitive: false,
        ),
      ],
      fix: 'Document how the client responded to the intervention.',
    ),
    _Rule(
      id: 'goal_linkage',
      label: 'Treatment-plan goal linkage',
      patterns: [
        RegExp(
          r'\b(goal|objective|treatment plan|progress toward|target)',
          caseSensitive: false,
        ),
      ],
      fix:
          'Reference at least one treatment-plan goal and progress toward it — '
          'not just the diagnosis (the "golden thread").',
    ),
    _Rule(
      id: 'risk',
      label: 'Risk / safety addressed',
      patterns: [
        RegExp(
          r'\b(risk|safety|suicid|self-harm|self harm|SI/HI|homicid|no acute|denied)',
          caseSensitive: false,
        ),
      ],
      fix:
          'Address risk explicitly, even if absent (e.g. "No SI/HI, no acute '
          'safety concerns").',
    ),
    _Rule(
      id: 'time',
      label: 'Time documented (start/stop)',
      patterns: [
        RegExp(r'\d{1,2}:\d{2}'), // clock time
        RegExp(
          r'\b(start|stop|started|ended|duration|\d+\s*min)',
          caseSensitive: false,
        ),
      ],
      fix:
          'Document exact start & stop times (e.g. "10:02–10:55"), not just '
          'duration — CPT 90837 (53+ min) is the most-audited code.',
    ),
    _Rule(
      id: 'plan',
      label: 'Plan / next steps',
      patterns: [
        RegExp(
          r'\b(plan|next session|next appointment|homework|follow-up|follow up|referral|frequency)',
          caseSensitive: false,
        ),
      ],
      fix: 'State the plan: next session, frequency, homework, or referrals.',
    ),
  ];

  /// Tier 1 — synchronous, offline. [durationMinutes] (if known) refines the
  /// time/CPT check; [hasActivePlan] downgrades goal-linkage when absent.
  ComplianceReport check(
    String note, {
    int? durationMinutes,
    bool hasActivePlan = false,
  }) {
    final text = note;
    final checks = <ComplianceCheck>[];
    for (final r in _rules) {
      final hit = r.patterns.any((p) => p.hasMatch(text));
      var status = hit ? CheckStatus.pass : CheckStatus.warn;
      // Goal linkage is a hard fail when no plan exists at all.
      if (r.id == 'goal_linkage' && !hit && !hasActivePlan) {
        status = CheckStatus.fail;
      }
      checks.add(
        ComplianceCheck(
          id: r.id,
          label: r.label,
          status: status,
          fix: status == CheckStatus.pass ? null : r.fix,
        ),
      );
    }

    // CPT/time alignment hint when a duration is known.
    if (durationMinutes != null && durationMinutes >= 53) {
      final t = checks.firstWhere((c) => c.id == 'time');
      // 90837 — needs explicit justification for the extended session.
      if (!RegExp(
        r'\b(medically necessary|due to|because|severity|trauma|crisis|complex)',
        caseSensitive: false,
      ).hasMatch(text)) {
        t.status = CheckStatus.warn;
        t.fix =
            '53+ min (90837) is the most-audited code — add a one-line reason '
            'the extended session was medically necessary.';
      }
    }

    return ComplianceReport(checks: checks, source: ComplianceSource.heuristic);
  }

  /// Tier 2 — Claude semantic review. Falls back to [base] on no-key/error.
  Future<ComplianceReport> deepCheck(
    String note, {
    required ComplianceReport base,
  }) async {
    String? key;
    try {
      key = await _keyStorage.getAnthropicKey();
    } catch (_) {
      return base;
    }
    if (key == null || key.isEmpty) return base;

    const system =
        'You are a behavioral-health documentation auditor. Evaluate the '
        'progress note against the payer "golden thread" rubric: diagnosis, '
        'functional_impairment, intervention, response, goal_linkage, risk, '
        'time, plan. For each, return status pass|warn|fail and, when not pass, '
        'a one-sentence concrete fix. Decision-support, not a guarantee. '
        'Respond STRICT JSON only: {"checks":[{"id":"...","status":"pass|warn|'
        'fail","fix":"..."}],"summary":"<=15 words"}';

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 700,
      'temperature': 0.0,
      'system': system,
      'messages': [
        {'role': 'user', 'content': note},
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
          .timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) return base;

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = (decoded['content'] as List<dynamic>? ?? const [])
          .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
          .join('\n')
          .trim();
      final parsed = _parse(content);
      return parsed ?? base;
    } catch (_) {
      return base;
    }
  }

  ComplianceReport? _parse(String content) {
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final json =
          jsonDecode(content.substring(start, end + 1)) as Map<String, dynamic>;
      final list = json['checks'] as List<dynamic>? ?? const [];
      final byId = {for (final r in _rules) r.id: r.label};
      final checks = list
          .map((e) => e as Map<String, dynamic>)
          .where((m) => byId.containsKey(m['id']))
          .map(
            (m) => ComplianceCheck(
              id: m['id'] as String,
              label: byId[m['id']]!,
              status: _status(m['status'] as String? ?? ''),
              fix: (m['fix'] as String?)?.trim(),
            ),
          )
          .toList();
      if (checks.isEmpty) return null;
      return ComplianceReport(
        checks: checks,
        source: ComplianceSource.ai,
        summary: (json['summary'] as String?)?.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  static CheckStatus _status(String s) => switch (s.trim()) {
    'pass' => CheckStatus.pass,
    'fail' => CheckStatus.fail,
    _ => CheckStatus.warn,
  };

  void dispose() => _client.close();
}

class _Rule {
  _Rule({
    required this.id,
    required this.label,
    required this.patterns,
    required this.fix,
  });
  final String id;
  final String label;
  final List<RegExp> patterns;
  final String fix;
}

enum CheckStatus { pass, warn, fail }

enum ComplianceSource { heuristic, ai }

class ComplianceCheck {
  ComplianceCheck({
    required this.id,
    required this.label,
    required this.status,
    this.fix,
  });
  final String id;
  final String label;
  CheckStatus status;
  String? fix;
}

class ComplianceReport {
  ComplianceReport({required this.checks, required this.source, this.summary});
  final List<ComplianceCheck> checks;
  final ComplianceSource source;
  final String? summary;

  int get passCount => checks.where((c) => c.status == CheckStatus.pass).length;
  int get failCount => checks.where((c) => c.status == CheckStatus.fail).length;
  int get toFixCount =>
      checks.where((c) => c.status != CheckStatus.pass).length;

  /// 0–100 readiness score (fail counts double against the total).
  int get score {
    if (checks.isEmpty) return 0;
    final penalty = checks.fold<double>(0, (sum, c) {
      return sum +
          switch (c.status) {
            CheckStatus.pass => 0,
            CheckStatus.warn => 1,
            CheckStatus.fail => 2,
          };
    });
    final maxPenalty = checks.length * 2;
    return (100 * (1 - penalty / maxPenalty)).round();
  }
}
