import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/ropa_registry.dart';

/// Sprint 10 Hafta 1 — every artefact path declared by the RoPA must
/// resolve to a real file on disk. A broken `tiaReference` or
/// `dpiaReference` would let an auditor follow a link into the void.
void main() {
  group('RoPA artefact parity', () {
    test('every dpiaReference points at a real file', () {
      for (final a in RopaRegistry.activities) {
        final ref = a.dpiaReference;
        if (ref == null) continue;
        expect(
          File(ref).existsSync(),
          isTrue,
          reason:
              'Activity ${a.id} declares dpiaReference=$ref but the '
              'file does not exist on disk.',
        );
      }
    });

    test('every cross-border tiaReference points at a real file', () {
      for (final a in RopaRegistry.activities) {
        for (final r in a.crossBorderRecipients) {
          expect(
            File(r.tiaReference).existsSync(),
            isTrue,
            reason:
                'Activity ${a.id}: ${r.name} declares '
                'tiaReference=${r.tiaReference} but the file does '
                'not exist on disk.',
          );
        }
      }
    });

    test('artefact files carry a Next review date for the DPO', () {
      const paths = [
        'docs/compliance/DPIA_AI_ASSISTANCE.md',
        'docs/compliance/TIA_ANTHROPIC.md',
        'docs/compliance/TIA_STRIPE.md',
      ];
      for (final p in paths) {
        final body = File(p).readAsStringSync();
        expect(body, contains('Next review'),
            reason: '$p missing a Next review line');
        expect(body, contains('dpo@psyclinicai.com'),
            reason: '$p missing the DPO contact');
      }
    });
  });
}
