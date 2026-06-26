import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/status_page_component_registry.dart';

void main() {
  group('StatusPageComponentRegistry — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(StatusPageComponentRegistry.components, isNotEmpty);
    });

    test('every component has a unique id', () {
      final ids = StatusPageComponentRegistry.components
          .map((c) => c.id)
          .toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final c in StatusPageComponentRegistry.components) {
        expect(StatusPageComponentRegistry.byId(c.id), same(c));
      }
      expect(StatusPageComponentRegistry.byId('does-not-exist'), isNull);
    });

    test('every component has populated fields + https healthcheck', () {
      for (final c in StatusPageComponentRegistry.components) {
        expect(c.publicLabel, isNotEmpty, reason: c.id);
        expect(c.publicHealthcheckUrl, startsWith('https://'), reason: c.id);
        expect(c.vendorSubprocessorId, isNotEmpty, reason: c.id);
        expect(c.sloId, isNotEmpty, reason: c.id);
      }
    });

    test('every vendorSubprocessorId resolves to a known vendor', () {
      for (final c in StatusPageComponentRegistry.components) {
        expect(
          knownVendorIds,
          contains(c.vendorSubprocessorId),
          reason:
              '${c.id}: vendor `${c.vendorSubprocessorId}` not in known '
              'SubprocessorRegistry id set — fix parity (N6).',
        );
      }
    });

    test('every sloId resolves to a known SLO', () {
      for (final c in StatusPageComponentRegistry.components) {
        expect(
          knownSloIds,
          contains(c.sloId),
          reason:
              '${c.id}: sloId `${c.sloId}` not in known SloCatalog id set '
              '— fix parity (N1, PR #119).',
        );
      }
    });

    test('byGroup returns the right slice for each group', () {
      for (final g in StatusComponentGroup.values) {
        final slice = StatusPageComponentRegistry.byGroup(g);
        for (final c in slice) {
          expect(c.group, g);
        }
      }
    });

    test('payment + telehealth components surface to the public', () {
      final paymentSlice = StatusPageComponentRegistry.byGroup(
        StatusComponentGroup.payment,
      );
      final telehealthSlice = StatusPageComponentRegistry.byGroup(
        StatusComponentGroup.telehealth,
      );
      expect(
        paymentSlice,
        isNotEmpty,
        reason: 'payment must surface to customers',
      );
      expect(
        telehealthSlice,
        isNotEmpty,
        reason: 'telehealth must surface to customers',
      );
    });

    test('web app + patient portal + RAG hub are degradeOnVendorOutage', () {
      const surfaces = [
        'web-app-flutter',
        'patient-portal-pwa',
        'rag-hub-fastapi',
      ];
      for (final id in surfaces) {
        final c = StatusPageComponentRegistry.byId(id)!;
        expect(
          c.degradeOnVendorOutage,
          isTrue,
          reason:
              '$id: vendor outage MUST auto-degrade the surface (it is '
              'the customer-touching layer)',
        );
      }
    });

    test(
      'audit-log-mirror does NOT auto-degrade on Firebase outage (queue covers)',
      () {
        final mirror = StatusPageComponentRegistry.byId('audit-log-mirror')!;
        expect(
          mirror.degradeOnVendorOutage,
          isFalse,
          reason:
              'mirror failure is operational; writes still queue + flush '
              'when Firebase comes back. Do not alarm customers.',
        );
      },
    );

    test('no healthcheck URL embeds a token or query parameter', () {
      for (final c in StatusPageComponentRegistry.components) {
        expect(
          c.publicHealthcheckUrl,
          isNot(contains('?')),
          reason: '${c.id}: healthcheck URL must not embed query params',
        );
        expect(
          c.publicHealthcheckUrl,
          isNot(contains('token=')),
          reason: '${c.id}: healthcheck URL must not embed a token',
        );
      }
    });
  });

  group('parity sets are non-empty (drift guard)', () {
    test('knownVendorIds covers the N6 catalog (11 vendors as of 2026-06)', () {
      expect(knownVendorIds.length, 11);
    });

    test('knownSloIds covers the N1 catalog (6 SLOs as of 2026-06)', () {
      expect(knownSloIds.length, 6);
    });
  });
}
