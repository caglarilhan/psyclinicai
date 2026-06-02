/// Builds a ZIP bundle for a DSAR export. The bundle carries two
/// files:
///
/// - `patient-export.json` — the pretty-printed JSON produced by
///   [buildPatientExport].
/// - `README.txt` — generation metadata + a short security note so the
///   recipient knows the archive holds PHI and should sit on
///   encrypted storage.
///
/// **Encryption note:** Sprint 8 ships a deflate-compressed ZIP plus
/// a transport step over `share_plus` / native file pickers (which use
/// platform-level encryption-at-rest). Sprint 9 plans an AES-256 layer
/// inside the archive via `pointycastle`; the README warns the
/// recipient about today's scope so they don't assume archive-level
/// password protection.
///
/// Returns `null` when the bundle would be effectively empty (no
/// patient records). Caller surfaces that as an empty-state banner.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

Uint8List? buildPatientExportZip({
  required String patientId,
  required Map<String, dynamic> bundle,
  required DateTime generatedAt,
}) {
  final jsonText = const JsonEncoder.withIndent('  ').convert(bundle);
  if (jsonText.length < 30) {
    // The smallest meaningful bundle still has schema_version + ids;
    // anything shorter is an empty record set.
    return null;
  }

  final archive = Archive();
  final jsonBytes = utf8.encode(jsonText);
  archive.addFile(ArchiveFile(
    'patient-export.json',
    jsonBytes.length,
    jsonBytes,
  ));
  final readme = _readme(patientId, generatedAt, jsonBytes.length);
  final readmeBytes = utf8.encode(readme);
  archive.addFile(ArchiveFile('README.txt', readmeBytes.length, readmeBytes));

  final out = ZipEncoder().encode(archive);
  if (out == null) return null;
  return Uint8List.fromList(out);
}

/// Stable filename — date is generation date in local time, NOT the
/// patient's DOB.
String buildExportFileName(String patientId, DateTime generatedAt) {
  final y = generatedAt.year.toString().padLeft(4, '0');
  final m = generatedAt.month.toString().padLeft(2, '0');
  final d = generatedAt.day.toString().padLeft(2, '0');
  return 'psyclinicai-export-$patientId-$y$m$d.zip';
}

String _readme(String patientId, DateTime generatedAt, int payloadBytes) {
  final stamp = generatedAt.toUtc().toIso8601String();
  return '''
PsyClinicAI — Patient Data Export
==================================

This archive is the response to a patient subject-access request
under GDPR Articles 15 (right of access) and 20 (right to data
portability). It contains every record the platform holds for the
patient identifier below at the moment of export.

Patient identifier : $patientId
Generated at (UTC) : $stamp
Payload size       : $payloadBytes bytes (JSON)

Contents
--------

1. patient-export.json
   Pretty-printed JSON in the PsyClinicAI DSAR schema. Includes the
   intake form, the latest consent record, the active safety plan,
   the clinician profile fingerprint, and every session note.

2. README.txt
   This file.

Security note
-------------

The archive itself is NOT password-protected. Transport this file
over an encrypted channel (HTTPS / Signal / encrypted email) and
store it only on disks that are encrypted at rest (FileVault,
BitLocker, LUKS, hardware-encrypted USB). Delete the file once the
patient has acknowledged receipt — keeping a second copy increases
the exposure surface without a clinical reason.

A future release will add AES-256 password protection inside the
ZIP. Until then this archive is a hand-off envelope, not a vault.
''';
}
