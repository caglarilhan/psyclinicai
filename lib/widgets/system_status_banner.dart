/// Thin in-app banner that surfaces non-operational subsystems
/// from [SystemStatusService]. Hidden whenever every system is
/// green so the layout shape is preserved on the happy path.
///
/// Cmd+K → "Status" still opens the full public board; this banner
/// is the inline notice clinicians cannot miss while signing notes.
library;

import 'package:flutter/material.dart';

import '../services/data/system_status_service.dart';

class SystemStatusBanner extends StatelessWidget {
  const SystemStatusBanner({super.key, this.service});

  /// Override for tests; production wires the global singleton.
  final SystemStatusService? service;

  @override
  Widget build(BuildContext context) {
    final svc = service ?? SystemStatusService.instance;
    return ValueListenableBuilder<List<SystemStatus>>(
      valueListenable: svc.statusListenable,
      builder: (context, _, _) {
        final nonOk = svc.nonOperational;
        if (nonOk.isEmpty) return const SizedBox.shrink();
        final worst = svc.overallSeverity;
        return _Banner(severity: worst, items: nonOk);
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.severity, required this.items});

  final StatusSeverity severity;
  final List<SystemStatus> items;

  Color _bg(ColorScheme cs) => switch (severity) {
    StatusSeverity.operational => cs.surface,
    StatusSeverity.degraded => const Color(0xFFFFF7ED),
    StatusSeverity.down => const Color(0xFFFEE2E2),
  };

  Color _fg(ColorScheme cs) => switch (severity) {
    StatusSeverity.operational => cs.onSurface,
    StatusSeverity.degraded => const Color(0xFFB45309),
    StatusSeverity.down => const Color(0xFFB91C1C),
  };

  IconData get _icon => switch (severity) {
    StatusSeverity.operational => Icons.check_circle_outline,
    StatusSeverity.degraded => Icons.warning_amber_rounded,
    StatusSeverity.down => Icons.error_outline,
  };

  String _summary() {
    if (items.length == 1) {
      final s = items.first;
      return '${s.system.label}: ${s.severity.label}'
          '${s.message != null ? ' — ${s.message}' : ''}';
    }
    return '${items.length} subsystems impacted: '
        '${items.map((s) => s.system.label).join(', ')}.';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = _fg(cs);
    return Semantics(
      liveRegion: true,
      label: 'System status: ${severity.label}. ${_summary()}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _bg(cs),
          border: Border(bottom: BorderSide(color: fg.withValues(alpha: 0.25))),
        ),
        child: Row(
          children: [
            Icon(_icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _summary(),
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/status'),
              child: Text(
                'View status',
                style: TextStyle(color: fg, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
