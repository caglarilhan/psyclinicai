import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/audit_log_entry.dart';
import 'package:psyclinicai/utils/audit_log_exporter.dart';

void main() {
  AuditLogEntry entry({
    String id = 'a1',
    String kind = 'read',
    String action = 'Opened patient chart',
    String actor = 'demo@psyclinicai.com',
    String entity = 'patient demo-1 chart',
    String? ip = '92.184.10.20',
    AuditResult result = AuditResult.success,
    DateTime? ts,
  }) => AuditLogEntry(
    id: id,
    kind: kind,
    action: action,
    actor: actor,
    entity: entity,
    timestampUtc: (ts ?? DateTime.utc(2026, 6, 1, 12)),
    result: result,
    userId: 'u1',
    ip: ip,
    device: 'macOS · Safari',
    hash: 'a1f2…7c4d',
  );

  group('AuditLogEntry round-trip', () {
    test('toJson + fromJson preserve every field', () {
      final e = entry();
      final back = AuditLogEntry.fromJson(e.toJson());
      expect(back.id, e.id);
      expect(back.kind, e.kind);
      expect(back.actor, e.actor);
      expect(back.entity, e.entity);
      expect(back.timestampUtc, e.timestampUtc);
      expect(back.result, e.result);
      expect(back.ip, e.ip);
      expect(back.hash, e.hash);
    });

    test('fromJson defaults unknown result to success', () {
      final back = AuditLogEntry.fromJson({
        'id': 'x',
        'kind': 'k',
        'action': 'a',
        'actor': 'a',
        'entity': 'e',
        'timestamp_utc': '2026-06-01T00:00:00.000Z',
        'result': 'rate_limited',
      });
      expect(back.result, AuditResult.success);
    });
  });

  group('retention filter', () {
    final now = DateTime.utc(2026, 6, 1, 12);
    final recent = entry(id: 'r', ts: now.subtract(const Duration(days: 30)));
    final yearOld = entry(id: 'y', ts: now.subtract(const Duration(days: 365)));
    final ancient = entry(
      id: 'old',
      ts: now.subtract(const Duration(days: 365 * 7)),
    );

    test('filterByRetention keeps rows inside the window', () {
      final kept = filterByRetention(
        [recent, yearOld, ancient],
        window: hipaaRetention,
        now: now,
      ).map((e) => e.id).toList();
      expect(kept, containsAll(['r', 'y']));
      expect(kept, isNot(contains('old')));
    });

    test('findExpiredEntries returns only rows older than the window', () {
      final expired = findExpiredEntries(
        [recent, yearOld, ancient],
        window: hipaaRetention,
        now: now,
      ).map((e) => e.id).toList();
      expect(expired, ['old']);
    });

    test('hipaaRetention is the 6-year HIPAA minimum', () {
      expect(hipaaRetention.inDays, 365 * 6);
    });
  });

  group('redactForSiem', () {
    test('masks the local part of an email-shaped actor', () {
      final r = redactForSiem(entry(actor: 'jane.doe@example.com'));
      expect(r.actor, 'j***@example.com');
    });

    test('leaves non-email actors untouched', () {
      final r = redactForSiem(entry(actor: 'service-bot'));
      expect(r.actor, 'service-bot');
    });

    test('truncates the entity to 24 chars with an ellipsis', () {
      final long =
          'patient demo-1 chart — '
          'long context that should be cut';
      final r = redactForSiem(entry(entity: long));
      expect(r.entity.length, lessThanOrEqualTo(25));
      expect(r.entity.endsWith('…'), isTrue);
    });

    test('redacts the last two octets of an IPv4 address', () {
      final r = redactForSiem(entry(ip: '92.184.10.20'));
      expect(r.ip, '92.184.··.··');
    });

    test('leaves a null ip null', () {
      final r = redactForSiem(entry(ip: null));
      expect(r.ip, isNull);
    });
  });

  group('toJsonLines', () {
    test('emits one JSON object per line', () {
      final out = toJsonLines([entry(id: 'a'), entry(id: 'b')]);
      final lines = out.split('\n');
      expect(lines, hasLength(2));
      for (final l in lines) {
        final m = jsonDecode(l) as Map<String, dynamic>;
        expect(m['id'], isNotNull);
      }
    });

    test('omits keys that are null on the model', () {
      final e = AuditLogEntry(
        id: 'a',
        kind: 'read',
        action: 'X',
        actor: 'a@b.com',
        entity: 'e',
        timestampUtc: DateTime.utc(2026, 6, 1),
        result: AuditResult.success,
        // no userId / ip / device / hash
      );
      final m = jsonDecode(toJsonLines([e])) as Map<String, dynamic>;
      expect(m.containsKey('user_id'), isFalse);
      expect(m.containsKey('ip'), isFalse);
      expect(m.containsKey('device'), isFalse);
      expect(m.containsKey('hash'), isFalse);
    });
  });

  group('toSyslogRfc5424', () {
    test('emits the canonical syslog framing per row', () {
      final out = toSyslogRfc5424([entry(id: 'a1')]);
      expect(out, startsWith('<13>1 2026-06-01T12:00:00.000Z'));
      expect(out, contains('psyclinicai'));
      expect(out, contains('audit'));
      expect(out, contains('[audit@53595'));
      expect(out, contains('id="a1"'));
      expect(out, contains('result="success"'));
    });

    test('escapes embedded quotes and brackets in structured data', () {
      final tricky = entry(id: 'a"]\\bad');
      final out = toSyslogRfc5424([tricky]);
      expect(out, contains(r'id="a\"\]\\bad"'));
    });
  });

  group('toCsv', () {
    test('emits header + one row per entry', () {
      final csv = toCsv([entry(id: 'a'), entry(id: 'b')]);
      final lines = csv.split('\n');
      expect(lines, hasLength(3));
      expect(lines.first, startsWith('id,timestamp_utc,kind,action'));
    });

    test('quotes values containing commas', () {
      final csv = toCsv([entry(entity: 'patient, family')]);
      expect(csv, contains('"patient, family"'));
    });

    test('escapes embedded double quotes', () {
      final csv = toCsv([entry(action: 'Opened "demo" chart')]);
      expect(csv, contains('"Opened ""demo"" chart"'));
    });
  });
}
