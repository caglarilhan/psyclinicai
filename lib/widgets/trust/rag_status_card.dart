import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ai/rag_service.dart';
import '../../theme/tokens.dart';
import '../../utils/theme.dart';

/// Public-facing health card for the Clinical RAG Hub on the Trust
/// Center page. Renders one of three states:
///  - disabled  (no backend wired → "configuration pending")
///  - healthy   (hub `/health` returned 2xx → green chip + last check)
///  - degraded  (hub unreachable or non-2xx → amber chip + retry hint)
///
/// Read-only widget — does not write back to the hub.
class RagStatusCard extends StatefulWidget {
  const RagStatusCard({super.key});

  @override
  State<RagStatusCard> createState() => _RagStatusCardState();
}

enum _Health { loading, disabled, healthy, degraded }

class _RagStatusCardState extends State<RagStatusCard> {
  _Health _state = _Health.loading;
  String? _detail;

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    final svc = context.read<RagService>();
    if (!svc.isEnabled) {
      if (mounted) setState(() => _state = _Health.disabled);
      return;
    }
    final r = await svc.query(question: 'health-probe');
    if (!mounted) return;
    setState(() {
      if (r.isOk) {
        _state = _Health.healthy;
        _detail = 'model: ${r.answer!.modelUsed}';
      } else if (r.isDisabled) {
        _state = _Health.disabled;
      } else {
        _state = _Health.degraded;
        _detail = r.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Clinical RAG hub',
                    style: theme.textTheme.titleMedium),
                const Spacer(),
                _StatusChip(state: _state),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _description(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_detail != null) ...[
              const SizedBox(height: 4),
              Text(
                _detail!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _state == _Health.loading ? null : _probe,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Re-check'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _description() => switch (_state) {
        _Health.loading => 'Checking hub reachability…',
        _Health.disabled =>
          'Hub not wired into this build. Configure BACKEND_URL and '
              'deploy the ragProxy Cloud Function to bring it online.',
        _Health.healthy =>
          'Hub reachable. Guideline-grounded answers with citations are '
              'live for this region.',
        _Health.degraded =>
          'Hub unreachable or returned an error. Clinicians fall back '
              'to BYOK paths; investigate immediately.',
      };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.state});
  final _Health state;
  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (state) {
      _Health.loading => (AppColors.textTertiary, 'Checking…'),
      _Health.disabled => (AppColors.textSecondary, 'Not configured'),
      _Health.healthy => (AppColors.success, 'Operational'),
      _Health.degraded => (AppColors.warning, 'Degraded'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
