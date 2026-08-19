# Worked Example: IoT Device

A consumer IoT device, network-connected sensor with cloud-hosted backend.

## System summary

- Device: ARM SoC running Linux, 802.11 Wi-Fi, sensor hardware, no display.
- Backend: cloud APIs receiving telemetry, sending firmware updates.
- Mobile app: user pairing, settings, control.
- Cloud-to-cloud integrations (e.g., voice assistants).

## DFD

```
External:
  - End user (with mobile app and physical access to device)
  - Voice assistant cloud (Alexa, Google)
  - Network attacker (LAN co-resident, internet attacker)
  - Device manufacturer (firmware author)

Processes:
  - Device firmware
  - Cloud telemetry service
  - Cloud command service
  - Firmware update service
  - Mobile app

Stores:
  - On-device flash (firmware, config, credentials)
  - Cloud telemetry database
  - Cloud user database
  - Firmware artifact storage

Trust boundaries:
  - Device <-> cloud
  - Mobile app <-> device (during pairing)
  - LAN <-> device
  - Voice assistant <-> device control API
  - User <-> physical device
```

## IoT-specific threats

### Device at rest (physical attack)
- **Threat:** Attacker with physical access reads firmware via JTAG / UART / chip-off.
  - Mitigation: secure boot, encrypted flash, fuses blown disabling debug interfaces in production.
- **Threat:** Per-device secrets extracted from one device used to impersonate others.
  - Mitigation: each device has unique secrets provisioned at manufacture, derived via HSM. No shared device secrets.

### Device firmware integrity
- **Threat:** Malicious firmware update.
  - Mitigation: signed firmware images, signature verification before install, anti-rollback (versioned, refuse downgrades to vulnerable versions).
- **Threat:** Update server compromise allows malicious update to all devices.
  - Mitigation: signing keys held offline / in HSM, separate from update server. Revocation procedure for compromised signing keys.
- **Threat:** Attacker on LAN intercepts update.
  - Mitigation: TLS to update server with cert validation, plus image signature.

### Pairing
- **Threat:** Attacker on LAN during initial pairing claims the device for themselves.
  - Mitigation: physical-presence requirement (button press), short pairing window, encrypted pairing exchange.
- **Threat:** Device factory-reset by attacker, then re-paired to attacker's account.
  - Mitigation: previous owner notified on re-pairing; for high-value devices, pairing requires online attestation.

### Network
- **Threat:** Telemetry intercepted; reveals usage patterns.
  - Mitigation: TLS for all device-to-cloud communication.
- **Threat:** Cloud command channel abused; attacker sends commands as the user.
  - Mitigation: each command authenticated and authorized; rate-limited; sensitive commands (firmware update, factory reset) require additional confirmation.
- **Threat:** Device compromised, used as botnet node.
  - Mitigation: sandboxed application code, immutable system partition, automatic patching, anomaly detection on outbound traffic.

### Cloud
- **Threat:** Cloud database compromise exposes user data and device control.
  - Mitigation: encryption at rest, separation of telemetry from PII, separate keys per tenant where applicable.
- **Threat:** Attacker registers fake devices to consume cloud resources.
  - Mitigation: device attestation at registration; rate limit per IP / account.

### Lifecycle
- **Threat:** End-of-life device on user's network with unpatched vulnerabilities.
  - Mitigation: published EOL policy with security update commitment timeline; ability to push final-update-then-disable for critical issues.
- **Threat:** Resold device; previous owner's data leaked or current owner controlled by previous.
  - Mitigation: factory reset procedure that wipes all user data and de-pairs cloud account.

### Voice assistant integration
- **Threat:** Voice assistant cloud compromise / abuse used to control devices.
  - Mitigation: scoped tokens for assistant integration; user can revoke; assistant cannot perform sensitive operations (firmware, factory reset).

## Top mitigations from this exercise

1. Per-device unique secrets, secure boot, fused-off debug.
2. Signed firmware with offline-held signing keys; anti-rollback.
3. TLS with proper cert validation everywhere.
4. Physical-presence pairing.
5. EOL policy published; update mechanism that survives long-tail support.
6. Factory reset that fully de-pairs and wipes.
7. Anomaly detection on cloud and device-egress traffic.

## Pitfalls noticed

- A debug UART was supposed to be disabled in production but was active on early production batches.
- Pairing protocol was secure against external network attackers but not against an attacker with the user's mobile-app token (who could pair a malicious device into the user's account).
- Firmware update mechanism didn't validate the device's certificate, only the server's. An attacker with cloud access could push firmware to specific devices.
- "End of life" wasn't formally defined; some devices were still in the field 8 years post-launch with no update path.
