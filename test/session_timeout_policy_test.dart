import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/session_timeout_policy.dart';

void main() {
  group('SessionTimeoutCatalog — coverage + invariants', () {
    test('every SessionContext has exactly one pinned policy', () {
      final ctxs = SessionTimeoutCatalog.policies.map((p) => p.context).toSet();
      expect(
        ctxs,
        equals(SessionContext.values.toSet()),
        reason:
            'context/catalog parity broken — adding a SessionContext '
            'requires adding its policy here',
      );
      expect(
        SessionTimeoutCatalog.policies.length,
        SessionContext.values.length,
        reason: 'duplicate policy for a context',
      );
    });

    test('forContext resolves every enum value', () {
      for (final c in SessionContext.values) {
        expect(SessionTimeoutCatalog.forContext(c).context, c);
      }
    });

    test('every policy has floor ≤ default ≤ ceiling', () {
      for (final p in SessionTimeoutCatalog.policies) {
        expect(
          p.floorSeconds,
          lessThanOrEqualTo(p.defaultSeconds),
          reason: '${p.context.name}: floor > default',
        );
        expect(
          p.defaultSeconds,
          lessThanOrEqualTo(p.ceilingSeconds),
          reason: '${p.context.name}: default > ceiling',
        );
      }
    });

    test('every policy cites at least one regulatory anchor', () {
      for (final p in SessionTimeoutCatalog.policies) {
        expect(p.regulatoryRefs, isNotEmpty, reason: p.context.name);
      }
    });

    test('kiosk has the shortest default (compliance floor)', () {
      final kiosk = SessionTimeoutCatalog.forContext(SessionContext.kiosk);
      for (final p in SessionTimeoutCatalog.policies) {
        if (p.context == SessionContext.kiosk) continue;
        expect(
          kiosk.defaultSeconds,
          lessThanOrEqualTo(p.defaultSeconds),
          reason: 'kiosk must auto-lock at least as fast as ${p.context.name}',
        );
      }
    });

    test(
      'kiosk + admin require full sign-in to resume (no PIN-only shortcut)',
      () {
        for (final ctx in [SessionContext.kiosk, SessionContext.admin]) {
          expect(
            SessionTimeoutCatalog.forContext(ctx).requireReauth,
            ReauthMethod.fullSignIn,
            reason: '${ctx.name}: PIN alone is insufficient — elevated context',
          );
        }
      },
    );

    test('no policy lets the user idle for more than 30 minutes', () {
      const hardCap = 1800;
      for (final p in SessionTimeoutCatalog.policies) {
        expect(
          p.ceilingSeconds,
          lessThanOrEqualTo(hardCap),
          reason: '${p.context.name}: ceiling > 30 min violates HIPAA floor',
        );
      }
    });

    test('every policy mentions HIPAA §164.312(a)(2)(iii)', () {
      for (final p in SessionTimeoutCatalog.policies) {
        final blob = p.regulatoryRefs.join(' | ');
        expect(
          blob,
          contains('164.312'),
          reason:
              '${p.context.name}: must cite the HIPAA automatic-logoff '
              'rule (§164.312(a)(2)(iii))',
        );
      }
    });
  });

  group('clampToPolicy', () {
    test('clamps below floor to floor (kiosk)', () {
      expect(clampToPolicy(SessionContext.kiosk, 10), 30);
    });

    test('clamps above ceiling to ceiling (kiosk)', () {
      expect(clampToPolicy(SessionContext.kiosk, 9999), 120);
    });

    test('returns the requested value when within range', () {
      expect(clampToPolicy(SessionContext.activeClinicSession, 600), 600);
    });

    test('floor exactly returns itself', () {
      final p = SessionTimeoutCatalog.forContext(SessionContext.admin);
      expect(
        clampToPolicy(SessionContext.admin, p.floorSeconds),
        p.floorSeconds,
      );
    });

    test('ceiling exactly returns itself', () {
      final p = SessionTimeoutCatalog.forContext(SessionContext.telehealth);
      expect(
        clampToPolicy(SessionContext.telehealth, p.ceilingSeconds),
        p.ceilingSeconds,
      );
    });
  });
}
