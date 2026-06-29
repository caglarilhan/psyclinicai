import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/subprocessor_registry.dart';
import 'package:psyclinicai/services/compliance/vendor_sla_catalog.dart';

void main() {
  group('VendorSlaCatalog — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(VendorSlaCatalog.entries, isNotEmpty);
    });

    test('every subprocessorId is unique', () {
      final ids = VendorSlaCatalog.entries
          .map((r) => r.subprocessorId)
          .toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('bySubprocessorId resolves every entry', () {
      for (final r in VendorSlaCatalog.entries) {
        expect(VendorSlaCatalog.bySubprocessorId(r.subprocessorId), same(r));
      }
      expect(VendorSlaCatalog.bySubprocessorId('does-not-exist'), isNull);
    });

    test(
      'parity with SubprocessorRegistry — every subprocessor has a pinned SLA',
      () {
        final subprocessors = SubprocessorRegistry.entries
            .map((s) => s.id)
            .toSet();
        final slaIds = VendorSlaCatalog.entries
            .map((s) => s.subprocessorId)
            .toSet();
        for (final id in subprocessors) {
          expect(
            slaIds,
            contains(id),
            reason:
                'subprocessor `$id` exists in the registry but has no SLA '
                'row in vendor_sla_catalog — add one before shipping.',
          );
        }
        for (final id in slaIds) {
          expect(
            subprocessors,
            contains(id),
            reason:
                'SLA row `$id` does not match any subprocessor — either '
                'remove the row or re-add the subprocessor.',
          );
        }
      },
    );

    test('every entry has all fields populated', () {
      for (final r in VendorSlaCatalog.entries) {
        expect(r.slaPercentString, isNotEmpty, reason: r.subprocessorId);
        expect(r.statusUrl, startsWith('https://'), reason: r.subprocessorId);
        expect(r.slaDocUrl, startsWith('https://'), reason: r.subprocessorId);
        expect(r.measurementWindowDays, greaterThan(0));
        expect(r.notificationSlaHours, greaterThan(0));
      }
    });

    test('slaPercent is in (0, 1]', () {
      for (final r in VendorSlaCatalog.entries) {
        expect(r.slaPercent, greaterThan(0), reason: r.subprocessorId);
        expect(r.slaPercent, lessThanOrEqualTo(1.0), reason: r.subprocessorId);
      }
    });

    test(
      'requestWithinWindow vendors declare a positive window; other policies '
      'declare 0',
      () {
        for (final r in VendorSlaCatalog.entries) {
          if (r.outageCreditPolicy == OutageCreditPolicy.requestWithinWindow) {
            expect(
              r.outageCreditRequestWindowDays,
              greaterThan(0),
              reason:
                  '${r.subprocessorId}: requestWithinWindow needs a '
                  'positive window in days',
            );
          } else {
            expect(
              r.outageCreditRequestWindowDays,
              0,
              reason:
                  '${r.subprocessorId}: ${r.outageCreditPolicy.name} should '
                  'leave outageCreditRequestWindowDays at 0',
            );
          }
        }
      },
    );

    test('payment + auth + identity vendors meet ≥ 99.9%', () {
      const criticalIds = ['firebase-auth', 'stripe'];
      for (final id in criticalIds) {
        final r = VendorSlaCatalog.bySubprocessorId(id)!;
        expect(
          r.slaPercent,
          greaterThanOrEqualTo(0.999),
          reason: '$id is a critical-path vendor; SLA must be ≥ 99.9%',
        );
      }
    });
  });

  group('allowedDowntimeMinutes', () {
    test('99.9% over 30 days ≈ 43 minutes', () {
      final r = VendorSlaCatalog.bySubprocessorId('hetzner')!;
      // 30 * 24 * 60 = 43200; 43200 * 0.001 = 43.2 → 43 min
      expect(allowedDowntimeMinutes(r), 43);
    });

    test('99.95% over 30 days ≈ 22 minutes', () {
      final r = VendorSlaCatalog.bySubprocessorId('firebase-auth')!;
      // 43200 * 0.0005 = 21.6 → 22 min
      expect(allowedDowntimeMinutes(r), 22);
    });

    test('99.99% over 30 days ≈ 4 minutes', () {
      final r = VendorSlaCatalog.bySubprocessorId('stripe')!;
      // 43200 * 0.0001 = 4.32 → 4 min
      expect(allowedDowntimeMinutes(r), 4);
    });
  });
}
