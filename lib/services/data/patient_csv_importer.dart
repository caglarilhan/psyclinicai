/// Bulk patient CSV import — the clinic-onboarding critical path
/// (rapor 12 ux-researcher-designer + cpo-advisor findings). Pure
/// parser + validator; the wizard UI uses the result to render a
/// dry-run table before committing rows to Firestore.
class CsvImportRow {
  CsvImportRow({
    required this.lineNumber,
    required this.values,
    this.errors = const [],
  });

  final int lineNumber;
  final Map<String, String> values;
  final List<String> errors;

  bool get isValid => errors.isEmpty;
}

class CsvImportResult {
  const CsvImportResult({required this.rows, required this.headers});

  final List<CsvImportRow> rows;
  final List<String> headers;

  int get validRowCount => rows.where((r) => r.isValid).length;
  int get errorRowCount => rows.where((r) => !r.isValid).length;
  bool get isClean => errorRowCount == 0 && rows.isNotEmpty;
}

class PatientCsvImporter {
  PatientCsvImporter({
    this.requiredColumns = const ['name', 'dob'],
    this.maxRows = 5000,
  });

  final List<String> requiredColumns;
  final int maxRows;

  CsvImportResult parse(String raw) {
    final lines = _splitLines(raw);
    if (lines.isEmpty) {
      return const CsvImportResult(rows: [], headers: []);
    }
    final headers = _parseLine(
      lines.first,
    ).map((h) => h.trim().toLowerCase()).toList();
    if (headers.isEmpty) {
      return const CsvImportResult(rows: [], headers: []);
    }

    final rows = <CsvImportRow>[];
    for (var i = 1; i < lines.length && rows.length < maxRows; i++) {
      final raw = lines[i];
      if (raw.trim().isEmpty) continue;
      final cells = _parseLine(raw);
      final values = <String, String>{};
      for (var c = 0; c < headers.length; c++) {
        values[headers[c]] = c < cells.length ? cells[c].trim() : '';
      }
      rows.add(
        CsvImportRow(
          lineNumber: i + 1,
          values: values,
          errors: _validate(values),
        ),
      );
    }
    return CsvImportResult(rows: rows, headers: headers);
  }

  List<String> _validate(Map<String, String> v) {
    final out = <String>[];
    for (final col in requiredColumns) {
      if ((v[col] ?? '').isEmpty) {
        out.add('Missing required column "$col"');
      }
    }
    final dob = v['dob'];
    if (dob != null && dob.isNotEmpty && !_looksLikeDate(dob)) {
      out.add('DOB "$dob" not in YYYY-MM-DD or DD.MM.YYYY format');
    }
    return out;
  }

  bool _looksLikeDate(String s) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s) ||
        RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(s);
  }

  List<String> _splitLines(String raw) =>
      raw.replaceAll('\r\n', '\n').split('\n');

  List<String> _parseLine(String line) {
    final out = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buf.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          buf.write(ch);
        }
      } else {
        if (ch == ',') {
          out.add(buf.toString());
          buf.clear();
        } else if (ch == '"') {
          inQuotes = true;
        } else {
          buf.write(ch);
        }
      }
    }
    out.add(buf.toString());
    return out;
  }
}
