/// Format and filter audit-log rows for shipping out of the platform.
///
/// Three concerns live here, kept as pure functions so SIEM, PDF, and
/// retention jobs share one source of truth:
///
/// 1. **Retention** ([filterByRetention]): drops rows older than the
///    configured window. HIPAA requires 6 years, KVKK requires "as long
///    as necessary"; we expose the window so the caller picks per
///    tenancy.
/// 2. **PHI redaction** ([redactForSiem]): scrubs the email-shaped actor
///    + free-text entity before they leave the BAA boundary.
/// 3. **Wire format** ([toJsonLines], [toSyslogRfc5424], [toCsv]): writes
///    the rows in the format the destination accepts. JSONL is preferred
///    for Splunk / Datadog; syslog for ELK; CSV for compliance review.
///
/// Pure — no I/O. Callers wrap these in a file writer or HTTP post.
library;

import 'dart:convert';

import '../models/audit_log_entry.dart';

/// HIPAA §164.316(b)(2)(i) — six year minimum retention.
const Duration hipaaRetention = Duration(days: 365 * 6);

/// Returns the subset of [entries] whose [AuditLogEntry.timestampUtc] is
/// no older than [window] before [now]. Pass `now` from the caller so the
/// function stays deterministic in tests.
Iterable<AuditLogEntry> filterByRetention(
  Iterable<AuditLogEntry> entries, {
  required Duration window,
  required DateTime now,
}) {
  final cutoff = now.toUtc().subtract(window);
  return entries.where((e) => !e.timestampUtc.toUtc().isBefore(cutoff));
}

/// Returns the entries that are PAST the [window] and therefore eligible
/// for purge. Caller is expected to soft-delete + record the purge in the
/// log so the purge itself is auditable.
Iterable<AuditLogEntry> findExpiredEntries(
  Iterable<AuditLogEntry> entries, {
  required Duration window,
  required DateTime now,
}) {
  final cutoff = now.toUtc().subtract(window);
  return entries.where((e) => e.timestampUtc.toUtc().isBefore(cutoff));
}

/// Returns a copy of [e] with email-shaped actors masked and the free-text
/// entity reduced to its first 24 characters (preserves the leading
/// keyword like "chart" without exposing trailing PHI).
AuditLogEntry redactForSiem(AuditLogEntry e) {
  return AuditLogEntry(
    id: e.id,
    kind: e.kind,
    action: e.action,
    actor: _redactEmail(e.actor),
    entity: _truncate(e.entity, 24),
    timestampUtc: e.timestampUtc,
    result: e.result,
    userId: e.userId,
    ip: _redactIp(e.ip),
    device: e.device,
    hash: e.hash,
  );
}

String _redactEmail(String s) {
  final at = s.indexOf('@');
  if (at <= 1) return s; // not an email
  final localFirst = s[0];
  final domain = s.substring(at);
  return '$localFirst***$domain';
}

String? _redactIp(String? ip) {
  if (ip == null) return null;
  if (ip.isEmpty) return ip;
  final parts = ip.split('.');
  if (parts.length != 4) return ip;
  return '${parts[0]}.${parts[1]}.··.··';
}

String _truncate(String s, int max) {
  if (s.length <= max) return s;
  return '${s.substring(0, max)}…';
}

/// One JSON object per line — the format Splunk / Datadog / Elastic
/// ingestors expect on a tailed file or stdout pipe.
///
/// L-4 fix (audit 2026-06-21): the previous implementation could
/// ship raw `actor` (email) into SIEM if the caller forgot to call
/// [redactForSiem] first. JSON-lines is the most common SIEM path,
/// so it now redacts UNCONDITIONALLY before serialising. Callers
/// that need raw values (in-app debug view, internal audit screen)
/// use [toJsonLinesRaw] explicitly.
String toJsonLines(Iterable<AuditLogEntry> entries) =>
    entries.map((e) => jsonEncode(redactForSiem(e).toJson())).join('\n');

/// Raw JSON-lines variant — does NOT redact. Production export paths
/// (SIEM, customer DSAR download) MUST use [toJsonLines]; this is
/// only for internal debug screens that stay inside the tenancy
/// boundary.
String toJsonLinesRaw(Iterable<AuditLogEntry> entries) =>
    entries.map((e) => jsonEncode(e.toJson())).join('\n');

/// RFC 5424 syslog with structured-data, one row per entry.
///
/// Format: `<PRI>1 TIMESTAMP HOSTNAME APP-NAME PROCID MSGID SD MSG`
/// PRI = 13 (facility=1 user, severity=5 notice).
///
/// L-4 fix — actor + ip are scrubbed before emission, same rationale
/// as [toJsonLines]. Raw export available via [toSyslogRfc5424Raw]
/// for in-tenancy debug only.
String toSyslogRfc5424(
  Iterable<AuditLogEntry> entries, {
  String hostname = 'psyclinicai',
  String appName = 'audit',
}) =>
    toSyslogRfc5424Raw(
      entries.map(redactForSiem),
      hostname: hostname,
      appName: appName,
    );

String toSyslogRfc5424Raw(
  Iterable<AuditLogEntry> entries, {
  String hostname = 'psyclinicai',
  String appName = 'audit',
}) {
  final lines = <String>[];
  for (final e in entries) {
    final ts = e.timestampUtc.toUtc().toIso8601String();
    final sd = '[audit@53595 '
        'id="${_escapeSd(e.id)}" '
        'kind="${_escapeSd(e.kind)}" '
        'actor="${_escapeSd(e.actor)}" '
        'result="${e.result.name}"]';
    final msg = '${e.action} on ${e.entity}';
    lines.add('<13>1 $ts $hostname $appName - ${e.id} $sd $msg');
  }
  return lines.join('\n');
}

String _escapeSd(String s) =>
    s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll(']', '\\]');

/// RFC 4180 CSV (header + rows). Quoted only when a field contains a
/// comma, newline, or quote. Useful for compliance teams who diff in
/// Excel.
String toCsv(Iterable<AuditLogEntry> entries) {
  const columns = [
    'id',
    'timestamp_utc',
    'kind',
    'action',
    'actor',
    'entity',
    'result',
    'user_id',
    'ip',
    'device',
    'hash',
  ];
  String quote(String? v) {
    final s = v ?? '';
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  final rows = <String>[columns.join(',')];
  for (final e in entries.map(redactForSiem)) {
    rows.add([
      quote(e.id),
      quote(e.timestampUtc.toUtc().toIso8601String()),
      quote(e.kind),
      quote(e.action),
      quote(e.actor),
      quote(e.entity),
      quote(e.result.name),
      quote(e.userId),
      quote(e.ip),
      quote(e.device),
      quote(e.hash),
    ].join(','));
  }
  return rows.join('\n');
}
