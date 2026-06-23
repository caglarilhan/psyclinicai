/// Coverage for `ModalityPreferences` JSON + toggle semantics, plus
/// the SharedPreferences-backed repository (per-clinician scoping,
/// corrupt-record drop, upsert idempotence by clinician id).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/modality_preferences.dart';
import 'package:psyclinicai/services/data/modality_preferences_repository.dart';
import 'package:psyclinicai/services/data/modality_session_repository.dart'
    show ModalityKind;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ModalityPreferences', () {
    test('defaults are free tier with empty enabled set', () {
      final p = ModalityPreferences.defaults('c1');
      expect(p.clinicianId, 'c1');
      expect(p.tier, ModalityTier.free);
      expect(p.enabled, isEmpty);
      expect(p.isEnabled(ModalityKind.cbt), isFalse);
    });

    test('isEnabled requires both Pro tier AND the modality opt-in', () {
      final base = ModalityPreferences(
        clinicianId: 'c1',
        enabled: {ModalityKind.cbt, ModalityKind.dbt},
      );
      // Free + enabled → still not surfaced.
      expect(base.isEnabled(ModalityKind.cbt), isFalse);
      // Pro + enabled → surfaced.
      final pro = base.copyWith(tier: ModalityTier.pro);
      expect(pro.isEnabled(ModalityKind.cbt), isTrue);
      expect(pro.isEnabled(ModalityKind.dbt), isTrue);
      // Pro + NOT in enabled → still not surfaced.
      expect(pro.isEnabled(ModalityKind.emdr), isFalse);
    });

    test('toggle adds and removes a modality', () {
      var p = ModalityPreferences.defaults('c1');
      p = p.toggle(ModalityKind.cbt);
      expect(p.enabled, {ModalityKind.cbt});
      p = p.toggle(ModalityKind.cbt);
      expect(p.enabled, isEmpty);
    });

    test('JSON round-trip preserves clinicianId / enabled / tier', () {
      final p = ModalityPreferences(
        clinicianId: 'c1',
        enabled: {ModalityKind.cbt, ModalityKind.emdr},
        tier: ModalityTier.pro,
      );
      final restored = ModalityPreferences.fromJson(p.toJson());
      expect(restored.clinicianId, 'c1');
      expect(restored.enabled, {ModalityKind.cbt, ModalityKind.emdr});
      expect(restored.tier, ModalityTier.pro);
    });

    test('effective set is empty on Free, matches enabled on Pro', () {
      final free = ModalityPreferences(
        clinicianId: 'c1',
        enabled: {ModalityKind.cbt},
      );
      expect(free.effective, isEmpty);
      final pro = free.copyWith(tier: ModalityTier.pro);
      expect(pro.effective, {ModalityKind.cbt});
    });
  });

  group('ModalityPreferencesRepository', () {
    test('save then read for the same clinician round-trips', () async {
      final repo = ModalityPreferencesRepository(storageKey: 'pref_test_rt');
      await repo.initialize();
      final p = ModalityPreferences(
        clinicianId: 'c1',
        enabled: {ModalityKind.cbt, ModalityKind.dbt},
        tier: ModalityTier.pro,
      );
      await repo.save(p);
      final fresh = ModalityPreferencesRepository(storageKey: 'pref_test_rt');
      await fresh.initialize();
      final back = fresh.forClinician('c1');
      expect(back.tier, ModalityTier.pro);
      expect(back.enabled, {ModalityKind.cbt, ModalityKind.dbt});
    });

    test('forClinician returns defaults when no record exists', () async {
      final repo = ModalityPreferencesRepository(
        storageKey: 'pref_test_default',
      );
      await repo.initialize();
      final p = repo.forClinician('new-clinician');
      expect(p.tier, ModalityTier.free);
      expect(p.enabled, isEmpty);
    });

    test('save is idempotent by clinicianId (one row per clinician)', () async {
      final repo = ModalityPreferencesRepository(storageKey: 'pref_test_idem');
      await repo.initialize();
      await repo.save(
        ModalityPreferences(
          clinicianId: 'c1',
          enabled: {ModalityKind.cbt},
          tier: ModalityTier.pro,
        ),
      );
      await repo.save(
        ModalityPreferences(
          clinicianId: 'c1',
          enabled: {ModalityKind.cbt, ModalityKind.dbt},
          tier: ModalityTier.pro,
        ),
      );
      final p = repo.forClinician('c1');
      expect(p.enabled, {ModalityKind.cbt, ModalityKind.dbt});
    });

    test('initialize drops corrupt records but keeps valid ones', () async {
      SharedPreferences.setMockInitialValues({
        'pref_test_corrupt': <String>[
          '{"clinicianId":"good","enabled":["cbt"],"tier":"pro"}',
          'not valid json',
        ],
      });
      final repo = ModalityPreferencesRepository(
        storageKey: 'pref_test_corrupt',
      );
      await repo.initialize();
      final good = repo.forClinician('good');
      expect(good.tier, ModalityTier.pro);
      expect(good.enabled, {ModalityKind.cbt});
    });
  });
}
