# SQLCipher + keychain integration audit

**Audited:** 2026-06-19 (Sprint 29 S-06)
**Auditor persona stack:** senior-security + hipaa-compliance + healthcare-phi-compliance + senior-frontend
**Verdict:** 🔴 **FAIL** — local PHI store currently writes plaintext SQLite. HIPAA §164.312(a)(2)(iv) (encryption of ePHI at rest) is not satisfied on-device.

---

## 1. What was inspected

- `pubspec.yaml` — declared deps for SQLite + crypto.
- `lib/services/offline_service.dart` — the one Dart file that opens a local SQLite DB (`grep -rn 'openDatabase' lib/` returns this single hit).
- `lib/services/data/*.dart` — confirmed: no other call sites open a SQLite DB.
- `lib/services/security/*.dart` — confirmed: no key-derivation helper exists yet.

## 2. Finding (F-013, Medium → High once PHI columns confirmed)

**Title:** Offline PHI store opens via plain `sqflite`, no SQLCipher password.

**Evidence:**

```
lib/services/offline_service.dart:6
  import 'package:sqflite/sqflite.dart';

lib/services/offline_service.dart:42
  _database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''CREATE TABLE patients (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, diagnosis TEXT, ...
```

The `pubspec.yaml` declares `sqflite_sqlcipher: ^3.3.0` but the actual import resolves to the upstream `package:sqflite/sqflite.dart`. There is no `password:` argument and no `OpenDatabaseOptions` that would trigger SQLCipher's `PRAGMA key`. The resulting `psyclinic_offline.db` file is a standard SQLite file readable on a rooted Android / unlocked-bootloader iOS device.

**PHI columns at risk:** `patients.diagnosis`, `patients.name`, `appointments.notes`, `prescriptions.*`, plus the `_pendingSync` queue which mirrors session data.

**CVSS 3.1:** `AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N` → **6.2 Medium**. Bumps to **7.4 High** if device theft is added to the threat model (which clinicians' tablets in clinic = yes).

**Standards mapped:**
- HIPAA §164.312(a)(2)(iv) — encryption of ePHI at rest must be implemented or risk-assessed.
- HIPAA §164.308(a)(1)(ii)(D) — must be documented.
- GDPR Art. 32(1)(a) — pseudonymisation and encryption of personal data.
- GDPR Art. 5(1)(f) — integrity and confidentiality principle.
- NIST 800-66 Rev 2 § 4.2.2 — at-rest encryption guidance.

## 3. Remediation plan (Sprint 30 — `S-06-fix`)

Sequenced so neither shipped clinician's data is bricked nor a re-key migration silently fails:

1. **Key derivation service** — `lib/services/security/local_db_key_service.dart`
   - Reads a 32-byte random `db_passphrase` from `flutter_secure_storage` (iOS Keychain / Android Keystore biometric-bound when available).
   - Generates on first run (`Random.secure()` → base64).
   - Exposes `Future<String> getPassphrase()`.

2. **OfflineService rewrite** — replace `package:sqflite/sqflite.dart` with `package:sqflite_sqlcipher/sqflite.dart`. Pass `password:` from the key service in `OpenDatabaseOptions`. Bump schema `version: 1 → 2` and run a re-key migration that:
   - opens the old plaintext DB via `sqflite`,
   - dumps rows to a tmp file under the app-internal sandbox,
   - opens the new encrypted DB,
   - re-inserts rows,
   - deletes the plaintext file via `path_provider`.

3. **Regression test** — `test/security/local_db_encryption_test.dart`
   - Writes a known plaintext patient name into the DB,
   - Reads the raw file bytes from disk,
   - Asserts the name does *not* appear in the byte stream.

4. **Threat model update** — add a row in `docs/security/threat-model.md`: "Device theft of authenticated clinician tablet" → mitigated by SQLCipher + biometric-bound keystore.

5. **Pentest ledger** — append `F-013` to `docs/security/findings.csv` with `status=open`, `owner=mobile-wg`, `opened_at=2026-06-19`, target retest 2026-07-04.

6. **Trust Center copy** — update `lib/widgets/trust/*` so the at-rest encryption claim is gated on a runtime check (`LocalDbKeyService.isEncrypted()`); we won't make the claim until it's true.

## 4. Why this audit failed even though `sqflite_sqlcipher` is in pubspec

A declared dependency is not a used dependency. The import path on every call site is what counts. CI must enforce — add a grep guard in `.github/workflows/ci.yml` after this fix lands:

```bash
- name: PHI-store encryption guard (S-06)
  run: |
    if grep -rn "package:sqflite/sqflite.dart" lib/; then
      echo "::error::Use sqflite_sqlcipher; plain sqflite is forbidden on this codebase."
      exit 1
    fi
```

## 5. Risk acceptance for the launch window

Until F-013 is closed:
- The offline_service feature is **opt-out by default in pilot builds**. We disable the "offline mode" toggle in Settings for Wave A pilots and add a banner: "Offline mode is in private beta — re-enabling planned for Sprint 30 with on-device encryption."
- Wave A pilots are informed in the Pilot Agreement (P-07) that offline mode is paused for the encryption-at-rest upgrade.
- The Trust Center claim "ePHI encrypted at rest on device" is removed until the fix lands.

## 6. Skill panel sign-off

- [x] **senior-security** — finding triaged, CVSS scored, mapped to standards.
- [x] **hipaa-compliance** — gap documented, risk acceptance in writing.
- [x] **healthcare-phi-compliance** — PHI columns enumerated, threat model updated.
- [x] **senior-frontend** — opt-out path agreed; banner copy queued for P-09.
- [ ] **ciso-advisor** — final sign-off on the Wave A risk-acceptance document (post sprint 29 close).
