import 'package:flutter/material.dart';

import '../../services/ai_scribe/ai_scribe_client.dart';
import '../../services/ai_scribe/soap_section_catalog.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/clinician/scribe` — Ambient Clinical Scribe entry point.
///
/// MVP slice (PILAR 1 / PR-3):
///   1. Paste / upload a session transcript.
///   2. Tap **Draft SOAP** → posts to `aiScribeDraftSoap`.
///   3. Review the four SOAP sections in tabs; every required field
///      is highlighted; the clinician edits inline.
///   4. Sign + finalise wires to the encounter persistence path
///      (lands in PR-4 of the next sprint — Sprint 31).
///
/// Real-time audio capture is intentionally **not** in this PR — that
/// is Sprint 31 (PILAR 1 Phase 2), once the `record` package + chunked
/// upload + Whisper proxy land.
class AiScribeScreen extends StatefulWidget {
  const AiScribeScreen({
    super.key,
    required this.client,
    required this.tenantId,
    this.initialSessionId,
    this.initialPatientId,
  });

  final AiScribeClient client;
  final String tenantId;
  final String? initialSessionId;
  final String? initialPatientId;

  @override
  State<AiScribeScreen> createState() => _AiScribeScreenState();
}

class _AiScribeScreenState extends State<AiScribeScreen> {
  late final TextEditingController _transcript;
  late final TextEditingController _sessionId;
  late final TextEditingController _patientId;
  AiScribeDraft? _draft;
  String? _error;
  bool _drafting = false;

  @override
  void initState() {
    super.initState();
    _transcript = TextEditingController();
    _sessionId = TextEditingController(text: widget.initialSessionId ?? '');
    _patientId = TextEditingController(text: widget.initialPatientId ?? '');
  }

  @override
  void dispose() {
    _transcript.dispose();
    _sessionId.dispose();
    _patientId.dispose();
    super.dispose();
  }

  Future<void> _onDraft() async {
    if (_drafting) return;
    final transcript = _transcript.text.trim();
    final sessionId = _sessionId.text.trim();
    if (transcript.isEmpty || sessionId.isEmpty) {
      setState(() {
        _error = 'Session id + transcript are required.';
      });
      return;
    }
    setState(() {
      _drafting = true;
      _error = null;
    });
    try {
      final draft = await widget.client.draftSoap(
        tenantId: widget.tenantId,
        sessionId: sessionId,
        transcript: transcript,
        patientId: _patientId.text.trim().isEmpty
            ? null
            : _patientId.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _draft = draft;
        _drafting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _drafting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/clinician/scribe',
      title: 'Ambient Clinical Scribe',
      subtitle:
          'Paste a session transcript, draft a SOAP note, review every '
          'cited claim before signing.',
      breadcrumbs: const [
        Crumb('Clinician', '/dashboard'),
        Crumb('Scribe', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IntakeCard(
            theme: theme,
            cs: cs,
            transcript: _transcript,
            sessionId: _sessionId,
            patientId: _patientId,
            drafting: _drafting,
            onDraft: _onDraft,
            error: _error,
          ),
          const SizedBox(height: PsySpacing.xl),
          if (_draft != null)
            _DraftReview(theme: theme, cs: cs, draft: _draft!)
          else
            _EmptyState(theme: theme, cs: cs),
        ],
      ),
    );
  }
}

class _IntakeCard extends StatelessWidget {
  const _IntakeCard({
    required this.theme,
    required this.cs,
    required this.transcript,
    required this.sessionId,
    required this.patientId,
    required this.drafting,
    required this.onDraft,
    required this.error,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final TextEditingController transcript;
  final TextEditingController sessionId;
  final TextEditingController patientId;
  final bool drafting;
  final VoidCallback onDraft;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Session intake', style: theme.textTheme.titleMedium),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: sessionId,
                  decoration: const InputDecoration(
                    labelText: 'Session id',
                    hintText: 'e.g. sess_2026-06-30T14:00',
                  ),
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: TextField(
                  controller: patientId,
                  decoration: const InputDecoration(
                    labelText: 'Patient id (optional — gates consent)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          TextField(
            controller: transcript,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Session transcript',
              hintText:
                  'Paste the full session transcript here. Live audio '
                  'capture lands in Sprint 31.',
              border: OutlineInputBorder(),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],
          const SizedBox(height: PsySpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: drafting ? null : onDraft,
              icon: drafting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(drafting ? 'Drafting…' : 'Draft SOAP'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PsySpacing.xl),
        child: Column(
          children: [
            Icon(Icons.description_outlined, size: 48, color: cs.outline),
            const SizedBox(height: PsySpacing.md),
            Text('No draft yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: PsySpacing.xs),
            Text(
              'Paste a transcript above and tap Draft SOAP. Every claim '
              'the assistant emits will cite the transcript span it came '
              'from, so you can verify before you sign.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftReview extends StatelessWidget {
  const _DraftReview({
    required this.theme,
    required this.cs,
    required this.draft,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final AiScribeDraft draft;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: SoapSectionCatalog.sections.length,
      child: PsyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('SOAP draft', style: theme.textTheme.titleMedium),
                const SizedBox(width: PsySpacing.md),
                PsyBadge(
                  label: 'Schema v${draft.schemaVersion} · ${draft.provider}',
                ),
                const Spacer(),
                if (draft.phiRedactions > 0)
                  PsyBadge(
                    label: '${draft.phiRedactions} PHI redacted',
                    tone: PsyBadgeTone.info,
                  ),
              ],
            ),
            const SizedBox(height: PsySpacing.md),
            TabBar(
              isScrollable: true,
              labelColor: cs.primary,
              tabs: [
                for (final spec in SoapSectionCatalog.sections)
                  Tab(text: spec.title),
              ],
            ),
            SizedBox(
              height: 460,
              child: TabBarView(
                children: [
                  for (final spec in SoapSectionCatalog.sections)
                    _SectionEditor(
                      theme: theme,
                      cs: cs,
                      spec: spec,
                      draft: draft,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionEditor extends StatefulWidget {
  const _SectionEditor({
    required this.theme,
    required this.cs,
    required this.spec,
    required this.draft,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final SoapSectionSpec spec;
  final AiScribeDraft draft;

  @override
  State<_SectionEditor> createState() => _SectionEditorState();
}

class _SectionEditorState extends State<_SectionEditor> {
  /// One controller per SOAP field, keyed by field key. Living in state
  /// means clinician edits survive tab switches + theme rebuilds — the
  /// prior inline `TextEditingController(text: …)` inside `build()`
  /// allocated a fresh controller on every rebuild and silently
  /// discarded typing.
  late final Map<String, TextEditingController> _controllers = {
    for (final field in widget.spec.fields)
      field.key: TextEditingController(
        text: widget.draft.stringField(widget.spec.section, field.key),
      ),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.cs;
    final spec = widget.spec;
    return ListView(
      padding: const EdgeInsets.only(top: PsySpacing.md),
      children: [
        Text(spec.purpose, style: theme.textTheme.bodySmall),
        const SizedBox(height: PsySpacing.md),
        for (final field in spec.fields) ...[
          Row(
            children: [
              Text(field.label, style: theme.textTheme.labelLarge),
              const SizedBox(width: PsySpacing.sm),
              if (field.required)
                const PsyBadge(label: 'required', tone: PsyBadgeTone.warning),
              if (field.citationRequired) ...[
                const SizedBox(width: PsySpacing.xs),
                const PsyBadge(label: 'cited', tone: PsyBadgeTone.info),
              ],
            ],
          ),
          const SizedBox(height: PsySpacing.xs),
          TextField(
            controller: _controllers[field.key],
            maxLines: field.kind == SoapFieldKind.longText ? 4 : 6,
            decoration: InputDecoration(
              hintText: field.placeholder,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
        ],
        Padding(
          padding: const EdgeInsets.only(top: PsySpacing.md),
          child: Text(
            'Regulatory anchors: ${spec.regulatoryRefs.join(" · ")}',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
          ),
        ),
      ],
    );
  }
}
