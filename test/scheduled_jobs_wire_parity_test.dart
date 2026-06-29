/// P4 wire-up parity test.
///
/// Source of truth = `lib/services/ops/scheduled_job_catalog.dart`.
/// Runtime registry mirror = `functions/src/scheduled/scheduled_jobs.ts`.
///
/// Tests assert (a) every catalog id appears in the TS registry,
/// (b) the catalog cadenceLabel string is preserved in TS, and
/// (c) every job is `idempotent: true` per the catalog (the runner
/// retry policy depends on it).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/scheduled_job_catalog.dart';

void main() {
  group('P4 wire-up parity — O10 catalog ↔ TS scheduled_jobs registry', () {
    final tsFile = File('functions/src/scheduled/scheduled_jobs.ts');

    test('TS registry file exists', () {
      expect(tsFile.existsSync(), isTrue);
    });

    test('every catalog job id appears in TS registry', () {
      final ts = tsFile.readAsStringSync();
      for (final r in ScheduledJobCatalog.records) {
        expect(
          ts.contains("id: '${r.id}'"),
          isTrue,
          reason:
              '${r.id}: missing in functions/src/scheduled/scheduled_jobs.ts — drift',
        );
      }
    });

    test('every catalog cadenceLabel is preserved verbatim in TS', () {
      final ts = tsFile.readAsStringSync();
      for (final r in ScheduledJobCatalog.records) {
        expect(
          ts.contains("cadenceLabel: '${r.cadenceLabel}'"),
          isTrue,
          reason:
              '${r.id}: cadenceLabel "${r.cadenceLabel}" not found verbatim in TS — drift',
        );
      }
    });

    test('catalog has exactly the same number of jobs as TS expects (8)', () {
      expect(
        ScheduledJobCatalog.records.length,
        8,
        reason:
            'TS registry pins 8 jobs (functions/src/__tests__/scheduled_jobs.test.ts "registry has exactly 8 jobs"); catalog must match',
      );
    });

    test('every catalog job is idempotent (runner contract)', () {
      for (final r in ScheduledJobCatalog.records) {
        expect(
          r.idempotent,
          isTrue,
          reason:
              '${r.id}: O10 catalog mandates every scheduled job be idempotent; TS runner retries safely only when this holds',
        );
      }
    });
  });
}
