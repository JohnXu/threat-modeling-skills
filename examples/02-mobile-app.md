# Worked Example: Mobile Application

Native iOS and Android client for the same SaaS as Example 1, talking to the same REST API.

## What's different from web

- Client runs on user-controlled hardware. The binary is reverse-engineerable.
- Local storage on the device. Data persists across sessions, including secrets if you're not careful.
- Multiple OS versions to support; security guarantees vary.
- App store distribution adds a supply-chain consideration (account compromise leading to malicious update).
- Push notifications add an external dependency (APNs, FCM).
- Biometric and secure enclave integrations are useful but inconsistently implemented.

## DFD additions

```
External:
  - Mobile users
  - APNs (Apple)
  - FCM (Google)
  - App stores (distribution)

New processes:
  - Mobile client (iOS, Android)

New stores:
  - Device keychain / Keystore
  - App sandbox storage
  - Optional: SQLite database on device (offline mode)

New trust boundaries:
  - User device ↔ network ↔ server
  - App sandbox ↔ rest of device (other apps, OS)
  - Authenticated app session ↔ unauthenticated reinstall
```

## Mobile-specific threats

### Local data
- **Threat:** Sensitive data in plaintext in app sandbox, accessible to attacker with device access (jailbroken/rooted, lost device).
  - Mitigation: encrypt at rest using OS-provided keystore. For high-sensitivity items, require biometric to decrypt.
- **Threat:** Backup of app data exposes sensitive content.
  - Mitigation: mark sensitive containers as not-backed-up (`NSURLIsExcludedFromBackupKey`, `android:allowBackup="false"` per file).

### Authentication
- **Threat:** Long-lived session tokens stored on device, attacker with device access uses them.
  - Mitigation: short-lived access tokens, refresh tokens stored in keychain with biometric requirement, server-side revocation on suspicious activity.
- **Threat:** "Remember me" implemented as plaintext credentials.
  - Mitigation: token-based, never store passwords on device.

### Transport
- **Threat:** User on hostile network with custom CA installed; MITM possible.
  - Mitigation: certificate pinning for the API endpoint. Decision: pin to public key or to certificate? Public key is safer for rotation.
- **Threat:** Pinning bypassed via Frida / Objection.
  - Mitigation: detection helps but isn't a barrier; the real defense is server-side authentication that doesn't rely on TLS alone.

### Code & binary
- **Threat:** Binary reversed; API endpoints, secret keys, business logic exposed.
  - Mitigation: assume reversal. Don't put secrets in the binary. API authentication via per-user tokens, not embedded API keys. Sensitive logic on the server.
- **Threat:** Repackaged malicious version distributed outside app stores.
  - Mitigation: assume some users will install. Server-side controls must withstand a hostile client.

### Push
- **Threat:** Push notifications contain sensitive content displayed on lock screen.
  - Mitigation: don't put sensitive content in push payloads; use silent push to prompt the app to fetch.
- **Threat:** Push token leakage allows attacker to push to victim devices.
  - Mitigation: tokens scoped, treated as credentials, rotated.

### App store
- **Threat:** Developer account compromise leads to malicious update reaching all users.
  - Mitigation: hardware-key MFA on developer accounts, separate accounts for upload vs management, code signing reviewed.

## Top mitigations from this exercise

1. Use OS keystore with biometric requirement for refresh tokens.
2. Implement certificate pinning with key-based pins; have a rotation plan.
3. Audit app for any embedded secrets; remove all.
4. Push payloads contain no sensitive data.
5. Hardware-key MFA on app store developer accounts.
6. Server-side trust assumes hostile client.

## Pitfalls noticed

- A debug log was leaving session tokens in the device console accessible via plug-in tools.
- Crash reporting service was capturing user PII in stack traces (fixed with redaction filter).
- The "biometric login" actually didn't gate the API token, only the UI — bypassable by extracting the token.
