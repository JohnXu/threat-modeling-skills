---
name: threat-model-abuse-case
description: Use when a feature's legitimate use cases exist (user stories) and need an attacker's-eye mirror — how the feature could be abused, defrauded, or misused — especially in agile teams writing user stories for new features like signup, login, password reset, payments, or admin tools.
---

# Abuse Case Worksheet

## Overview

Use cases describe how legitimate users use the system. Abuse cases describe how attackers use it. Both belong in design documents.

## When to Use

- A new feature has use cases / user stories and needs an attacker's-eye counterpart before or during implementation.
- Agile teams that already write user stories and want a lightweight, symmetric process rather than a full STRIDE/PASTA pass.
- Sprint review for new or changed features.

## Procedure

1. Start from the use cases.
2. For each, ask: "How could a hostile actor pervert this?"
3. Document the abuse case symmetrically with the use case.

## Template

```
Use case: User submits a refund request

Abuse cases:
  - Attacker submits refund requests for transactions they didn't make
  - Legitimate user submits duplicate refund requests to receive double payment
  - Attacker uses refund flow to test stolen credit card numbers
  - Insider creates fake transaction + refund to extract funds
  - Attacker abuses refund email notifications to send phishing to victim addresses
```

For each abuse case:

```
Abuse case ID:
Description:
Attacker profile (who, capability, motivation):
Preconditions:
Steps:
Impact:
Likelihood:
Existing controls:
Gaps:
Mitigation plan:
```

## Patterns by feature type

### User registration
- Mass account creation (bots)
- Email verification bypass (race conditions, predictable codes)
- Account takeover via signup with existing email
- Use of registration as an oracle (does this email have an account?)

### Login
- Credential stuffing
- Password spraying
- MFA fatigue / push bombing
- Account lockout DoS (rate limit attacker can use against legitimate users)

### Password reset
- Reset token reuse / prediction
- Reset to any address attacker controls
- Reset enumeration (which emails are registered)
- Reset-then-MFA-bypass (does reset bypass MFA?)

### Search
- Resource exhaustion (expensive queries)
- Information disclosure (search returning data the user shouldn't see)
- Injection if results are passed to other systems

### File upload
- Malware delivery to other users
- Storage exhaustion
- Path traversal / overwrite
- Server-side processing exploits (image parsing RCE, document macros)

### Comments / messaging
- XSS via stored content
- CSRF via embedded tags
- Phishing via link-injection
- Harassment / abuse of other users

### Payments
- Race conditions in checkout (apply discount, change cart, complete)
- Refund fraud
- Card testing
- Account-credit abuse (apply credit twice, transfer to attacker account)

### Admin features
- Privilege escalation via mass-assignment
- Audit log tampering / disabling
- Backdoor user creation
- Ambient admin sessions used by attacker who phished an admin

## Pitfalls

- "Who would do that?" — wrong question. Document the abuse case and decide on mitigation; if you decide not to mitigate, it's an accepted risk, not a non-issue.
- Limiting abuse cases to external attackers. Insiders and compromised accounts behave differently and produce different abuse cases.
- One pass and done. Add abuse cases to sprint review for new features.

## Output

For every significant use case, an abuse-case document with mitigations in the design and tests in the test suite.
