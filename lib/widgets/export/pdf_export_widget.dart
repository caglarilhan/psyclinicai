import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/pdf_export_service.dart';
import '../../models/medication_models.dart';
import '../../models/session_models.dart';
import '../../models/patient_models.dart';

class PdfExportWidget extends StatefulWidget {
  final Patient patient;
  final List<Session>? sessions;
  final List<DrugInteraction>? interactions;
  final List<Prescription>? prescriptions;
  final String exportType;

  const PdfExportWidget({
    super.key,
    required this.patient,
    this.sessions,
    this.interactions,
    this.prescriptions,
    required this.exportType,
  });

  @override
  State<PdfExportWidget> createState() => _PdfExportWidgetState();
}

class _PdfExportWidgetState extends State<PdfExportWidget> {
  final PdfExportService _pdfService = PdfExportService();
  String _selectedTemplate = 'session_report';
  String? _customNotes;
  bool _isExporting = false;
  String? _exportStatus;
  File? _exportedFile;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = widget.exportType;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildTemplateSelection(),
            const SizedBox(height: 20),
            _buildCustomNotesField(),
            const SizedBox(height: 20),
            _buildExportButton(),
            if (_exportStatus != null) ...[
              const SizedBox(height: 15),
              _buildStatusIndicator(),
            ],
            if (_exportedFile != null) ...[
              const SizedBox(height: 15),
              _buildFileActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.picture_as_pdf,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PDF Export',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Export ${widget.exportType.replaceAll('_', ' ')} for ${widget.patient.fullName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateSelection() {
    final templates = _pdfService.getAvailableTemplates();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Template',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedTemplate,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Template',
            hintText: 'Choose export template',
          ),
          items: templates.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTemplate = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCustomNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Notes',
            hintText: 'Add any additional notes or comments...',
          ),
          onChanged: (value) {
            setState(() {
              _customNotes = value.isEmpty ? null : value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : _exportToPdf,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.file_download),
        label: Text(_isExporting ? 'Exporting...' : 'Export to PDF'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isSuccess = _exportStatus!.contains('success');
    final isError = _exportStatus!.contains('error');
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green[50]
            : isError
                ? Colors.red[50]
                : Colors.blue[50],
        border: Border.all(
          color: isSuccess
              ? Colors.green[300]!
              : isError
                  ? Colors.red[300]!
                  : Colors.blue[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle
                : isError
                    ? Icons.error
                    : Icons.info,
            color: isSuccess
                ? Colors.green[600]
                : isError
                    ? Colors.red[600]
                    : Colors.blue[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _exportStatus!,
              style: TextStyle(
                color: isSuccess
                    ? Colors.green[800]
                    : isError
                        ? Colors.red[800]
                        : Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileActions() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.file_present,
                color: Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Successful!',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'File: ${_exportedFile!.path.split('/').last}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openFile,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    side: BorderSide(color: Colors.green[300]!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareFile,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Preparing export...';
      _exportedFile = null;
    });

    try {
      File? exportedFile;
      
      switch (_selectedTemplate) {
        case 'session_report':
          if (widget.sessions != null && widget.sessions!.isNotEmpty) {
            exportedFile = await _pdfService.exportSessionReport(
              session: widget.sessions!.first,
              patient: widget.patient,
              template: _selectedTemplate,
              customNotes: _customNotes,
            );
          } else {
            throw Exception('No sessions available for export');
          }
          break;
          
        case 'medication_interaction':
          if (widget.interactions != null && widget.interactions!.isNotEmpty) {
            exportedFile = await _pdfService.exportInteractionReport(
              interactions: widget.interactions!,
              patient: widget.patient,
              template: _selectedTemplate,
              additionalNotes: _customNotes,
            );
          } else {
            throw Exception('No interactions available for export');
          }
          break;
          
        case 'prescription':
          if (widget.prescriptions != null && widget.prescriptions!.isNotEmpty) {
            exportedFile = await _pdfService.exportPrescriptionReport(
              prescription: widget.prescriptions!.first,
              patient: widget.patient,
              template: _selectedTemplate,
              interactions: widget.interactions,
            );
          } else {
            throw Exception('No prescriptions available for export');
          }
          break;
          
        default:
          throw Exception('Unsupported template type');
      }

      if (exportedFile != null) {
        setState(() {
          _exportedFile = exportedFile;
          _exportStatus = 'Export completed successfully!';
        });
      } else {
        throw Exception('Failed to generate PDF');
      }
    } catch (e) {
      setState(() {
        _exportStatus = 'Export failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _openFile() async {
    if (_exportedFile != null) {
      try {
        await FilePicker.platform.clearTemporaryFiles();
        // Note: In a real app, you might want to use a PDF viewer
        // For now, we'll just show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File ready: ${_exportedFile!.path}'),
            backgroundColor: Colors.green[600],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Future<void> _shareFile() async {
    if (_exportedFile != null) {
      try {
        await Share.shareXFiles(
          [XFile(_exportedFile!.path)],
          text: '${widget.exportType.replaceAll('_', ' ')} for ${widget.patient.fullName}',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share file: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}
