# STRIDE Worksheet

STRIDE is a per-component threat enumeration framework. For each element in your system, walk the six categories and identify threats.

| Letter | Category | Property violated |
|--------|----------|-------------------|
| S | Spoofing | Authentication |
| T | Tampering | Integrity |
| R | Repudiation | Non-repudiation |
| I | Information Disclosure | Confidentiality |
| D | Denial of Service | Availability |
| E | Elevation of Privilege | Authorization |

## Scope

- System or component:
- Boundary (what's in scope, what's not):
- Data classifications handled:

## Component table

For each major component (process, data store, external entity, data flow), fill out:

| Component | Type | S | T | R | I | D | E |
|-----------|------|---|---|---|---|---|---|
| | Process / Store / Flow / External | | | | | | |

For each cell marked relevant, document:

## Threat entries

```
ID:           STRIDE-001
Category:     Spoofing
Component:    Auth service
Description:  Attacker presents forged JWT to bypass authentication.
Likelihood:   Medium
Impact:       High
Existing controls:
  - Asymmetric signature verification
  - Token expiry enforcement
Gaps:
  - No mutual TLS between services
Mitigation plan:
  - Add mTLS for auth service ingress (Q3)
Owner:        platform-team
Status:       Open
```

## Repeat for every component × every applicable category.

## Pitfalls

- Treating STRIDE as a checkbox: "S, done" without thinking through specific spoofing vectors. Force yourself to write at least one concrete threat per cell.
- Stopping at obvious threats. The valuable findings come from "what would a creative attacker do here that we haven't seen yet".
- Assigning everything to "the security team", threats need component-owner accountability.
- Modeling perfect attackers. Use a realistic attacker profile: capabilities, motivations, access.

## Output

A backlog of threats, each with: identifier, description, controls in place, gaps, mitigation plan, owner. The mitigation plan items become engineering work items.
