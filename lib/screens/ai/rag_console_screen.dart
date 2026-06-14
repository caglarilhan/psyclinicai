import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;

import '../../services/ai/rag_client.dart';
import '../../services/ai/rag_service.dart';
import '../../utils/theme.dart';
import '../../widgets/app_shell.dart';

/// Clinical RAG console — query the shared evidence hub for guideline-grounded
/// answers with citations. Decision-support only; never autonomous treatment
/// advice. PHI must not be typed here — use the analyze flow with a structured
/// patient context when patient data is involved.
class RagConsoleScreen extends StatefulWidget {
  const RagConsoleScreen({super.key});

  @override
  State<RagConsoleScreen> createState() => _RagConsoleScreenState();
}

class _RagConsoleScreenState extends State<RagConsoleScreen> {
  final TextEditingController _question = TextEditingController();
  String _region = 'EU';
  bool _busy = false;
  RagResult? _result;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final q = _question.text.trim();
    if (q.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _result = null;
    });
    final svc = context.read<RagService>();
    final r = await svc.query(question: q, region: _region);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.read<RagService>();
    return AppShell(
      routeName: '/ai/rag',
      title: 'Clinical RAG console',
      subtitle:
          'Guideline-grounded answers with citations. Decision-support only.',
      primaryAction: FilledButton.icon(
        onPressed: _busy || !svc.isEnabled ? null : _ask,
        icon: const Icon(Icons.search),
        label: const Text('Ask hub'),
      ),
      child: !svc.isEnabled
          ? const _DisabledNotice()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _QuestionForm(
                  controller: _question,
                  region: _region,
                  busy: _busy,
                  onRegionChanged: (r) => setState(() => _region = r),
                  onSubmit: _ask,
                ),
                const SizedBox(height: 24),
                if (_busy) const _BusyState(),
                if (!_busy && _result != null) _ResultView(result: _result!),
                if (!_busy && _result == null) const _EmptyState(),
              ],
            ),
    );
  }
}

class _QuestionForm extends StatelessWidget {
  const _QuestionForm({
    required this.controller,
    required this.region,
    required this.busy,
    required this.onRegionChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String region;
  final bool busy;
  final ValueChanged<String> onRegionChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              minLines: 3,
              enabled: !busy,
              onSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                labelText: 'Clinical question',
                helperText:
                    'Do not include patient identifiers. Use the analyze flow for PHI.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Region:'),
                const SizedBox(width: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'EU', label: Text('EU')),
                    ButtonSegment(value: 'US', label: Text('US')),
                  ],
                  selected: {region},
                  onSelectionChanged:
                      busy ? null : (s) => onRegionChanged(s.first),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BusyState extends StatelessWidget {
  const _BusyState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.menu_book_outlined,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'Ask the hub a clinical question to see grounded evidence.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _DisabledNotice extends StatelessWidget {
  const _DisabledNotice();
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinical RAG hub is not configured for this build.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pass RAG_BASE_URL and RAG_API_KEY at build time to enable. '
                    'See deployment/README for the operator runbook.',
                    style: TextStyle(color: AppColors.textSecondary),
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

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});
  final RagResult result;

  @override
  Widget build(BuildContext context) {
    if (result.isError) {
      return Card(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.errorMessage ?? 'Unknown error',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final ans = result.answer!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AnswerCard(answer: ans),
        const SizedBox(height: 16),
        _CitationsList(citations: ans.citations),
        const SizedBox(height: 12),
        _MetaRow(answer: ans),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer});
  final RagAnswer answer;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Answer',
                    style: Theme.of(context).textTheme.titleMedium),
                if (answer.phiDetected) ...[
                  const SizedBox(width: 12),
                  Chip(
                    label: const Text('PHI flagged'),
                    backgroundColor:
                        AppColors.warning.withValues(alpha: 0.18),
                    side: BorderSide.none,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(answer.answer),
          ],
        ),
      ),
    );
  }
}

class _CitationsList extends StatelessWidget {
  const _CitationsList({required this.citations});
  final List<RagCitation> citations;
  @override
  Widget build(BuildContext context) {
    if (citations.isEmpty) {
      return const Card(
        color: AppColors.surface,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No citations returned for this answer.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Citations (${citations.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...citations.map((c) => _CitationTile(c: c)),
          ],
        ),
      ),
    );
  }
}

class _CitationTile extends StatelessWidget {
  const _CitationTile({required this.c});
  final RagCitation c;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(c.country,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${c.source} · ${c.docType}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text('score ${c.score.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.snippet,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                if (c.url.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _open(c.url),
                    child: Text(c.url,
                        style: const TextStyle(
                            color: AppColors.accent, fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.answer});
  final RagAnswer answer;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Model: ${answer.modelUsed} · ${answer.requestMs} ms',
            style: const TextStyle(
                color: AppColors.textTertiary, fontSize: 12)),
        SelectableText('Audit ${answer.auditId}',
            style: const TextStyle(
                color: AppColors.textTertiary, fontSize: 12)),
      ],
    );
  }
}
