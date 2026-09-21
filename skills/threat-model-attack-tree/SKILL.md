---
name: threat-model-attack-tree
description: Use when decomposing how an attacker could achieve one specific high-value goal (e.g., "attacker reads plaintext credit card numbers"), identifying chokepoints across attack paths, communicating risk to non-security stakeholders, or scoping a penetration test.
---

# Attack Tree Worksheet

## Overview

An attack tree starts with an attacker goal at the root and decomposes into how that goal can be achieved. Use AND/OR nodes to show whether all sub-steps or any one of them suffice.

## When to Use

- Visualizing all paths to a critical asset.
- Identifying chokepoints where multiple paths converge.
- Communicating risk to non-security stakeholders.
- Driving penetration testing scope.
- Not a substitute for a full component review — pair with `threat-model-stride` or `threat-model-pasta` for that.

## Procedure

1. Pick the goal. Make it specific: "Attacker reads customer credit card numbers" not "Attacker compromises the system".
2. Decompose into immediate sub-goals connected by OR (any one works) or AND (all required).
3. Continue decomposing each leaf until you reach concrete actions.
4. Annotate leaves with: difficulty (low/med/high), prerequisites, current defenses.

## Template

```
GOAL: Attacker reads customer credit card numbers in plaintext

  OR
  ├── Compromise the database directly
  │     OR
  │     ├── Exploit unpatched DB vulnerability
  │     ├── Use leaked DB credentials
  │     └── Pivot from compromised application server
  │
  ├── Read CCs in transit
  │     AND
  │     ├── MITM the connection
  │     └── Defeat TLS (cert error, weak cipher, key leak)
  │
  ├── Compromise application server with read access
  │     OR
  │     ├── Web app vulnerability (SQLi, RCE)
  │     └── Compromised admin credentials
  │
  ├── Steal backup containing CCs
  │     OR
  │     ├── Compromise backup storage
  │     ├── Compromise vendor backup service
  │     └── Insider exfiltration of backup
  │
  └── Compromise payment processor side
        (out of scope for our system)
```

## Annotations

For each leaf, capture:

- Difficulty: low / medium / high (relative to a defined attacker profile)
- Prerequisites: what does the attacker need first? (Credentials, internal access, time)
- Detection: would current monitoring catch this attempt?
- Existing defenses: what's already in place?
- Mitigation gaps: what would close this path?

## Identify chokepoints

Look for nodes that appear under multiple paths or have many descendants. Hardening these has outsized impact.

In the example above: "DB credentials" appears in two paths (direct compromise and pivoting). Vault-managed dynamic credentials with short TTL closes both.

## Pitfalls

- Trees that go forever. Stop when leaves represent concrete tools/techniques an attacker could plausibly attempt.
- Imaginary attacks. Stay grounded in real TTPs from incident reports and ATT&CK.
- Too narrow. Include physical, social, and supply-chain branches where relevant.
- Single-tree-per-system. Big systems benefit from separate trees per high-value asset or per attacker profile.

## Output

The tree itself, plus a list of high-priority mitigations targeting chokepoints and the easiest paths.
