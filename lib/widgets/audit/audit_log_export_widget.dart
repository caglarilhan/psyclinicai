import 'package:flutter/material.dart';
import '../../services/audit_log_service.dart';
import '../../utils/theme.dart';

class AuditLogExportWidget extends StatefulWidget {
  const AuditLogExportWidget({super.key});

  @override
  State<AuditLogExportWidget> createState() => _AuditLogExportWidgetState();
}

class _AuditLogExportWidgetState extends State<AuditLogExportWidget> {
  bool _busy = false;
  String? _csv;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.file_download, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Audit Log Dışa Aktarım', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _export,
              icon: _busy ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.save_alt),
              label: Text(_busy ? 'Hazırlanıyor...' : 'CSV Olarak Dışa Aktar'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          if (_csv != null) Expanded(child: SingleChildScrollView(child: SelectableText(_csv!))),
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final csv = await AuditLogService().exportAsCsv(limit: 2000);
      setState(() => _csv = csv);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}


