# Retest evidence — F-010 (iOS Hand-off NSUserActivity leaks patient initials)

**Finding ID:** PSY-2026Q3-F-010
**Original severity:** Medium (CVSS 5.0, CWE-359)
**Status flip:** `fixed_pending_retest` → `fixed_verified`
**Retest performed by:** mobile-wg (placeholder)
**Retest date (UTC):** YYYY-MM-DDTHH:MM:SSZ
**Skill panel:** apple-hig-expert + senior-security + healthcare-phi-compliance

---

## 1. Original vulnerability

> The iOS Hand-off `NSUserActivity` title broadcast patient initials so a paired Apple Watch could surface "JD - session" on its locked glance. Bystander disclosure surface; HIPAA §164.312(d) physical safeguards weakness.

## 2. Fix shipped

- **Commit:** Sprint 27 close.
- **Code references:**
  - `ios/Runner/Handoff/SessionHandoffActivity.swift` — `userActivity.title = "Continue session"` hardcoded; patient context attached as a non-broadcastable userInfo payload
  - `ios/Runner/Info.plist` (Sprint 32 P1) — `NSUserActivityTypes` array declares `com.psyclinicai.session.continue` only

## 3. Retest steps

```bash
# 3.1 — Build the iOS app to a test device + paired Apple Watch.
flutter build ios --release --no-codesign
xcrun simctl boot 'iPhone 15 Pro'
xcrun simctl install booted build/ios/iphoneos/Runner.app

# 3.2 — Trigger a session continuation from inside the app.
# Capture the userActivity payload via Console.app filter:
log stream --predicate 'subsystem == "com.apple.UserActivity"' > f010-useractivity.log

# 3.3 — Grep for any patient PII patterns (initials, mrn, dob).
grep -E '\b[A-Z]{1,3}\b|\bMRN-?[0-9]+\b|\b[0-9]{4}-[0-9]{2}-[0-9]{2}\b' \
    f010-useractivity.log | head -5
# Expected: 0 lines.

# 3.4 — Confirm the title broadcast is literally "Continue session".
grep -c 'Continue session' f010-useractivity.log
# Expected: >=1.

# 3.5 — Apple Watch glance screenshot of the Hand-off notification
# file: f010-watch-glance.png (must show "Continue session", not initials).
```

## 4. Evidence artefacts

- `f010-useractivity.log`
- `f010-grep-pii.txt`
- `f010-grep-title.txt`
- `f010-watch-glance.png`

## 5. Sign-off

- [ ] **apple-hig-expert:** Hand-off title matches Apple's "concise, non-personalised" guidance.
- [ ] **senior-security:** No patient-PII tokens in the broadcasted activity.
- [ ] **healthcare-phi-compliance:** HIPAA §164.312(d) bystander disclosure surface mitigated.
- [ ] **ciso-advisor:** `findings.csv` row F-010 flipped to `fixed_verified`.

## 6. Audit trail row

```
F-010,YYYY-MM-DD,mobile-wg-002,fixed_pending_retest,fixed_verified
```
