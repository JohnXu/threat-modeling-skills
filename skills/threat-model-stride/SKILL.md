---
name: threat-model-stride
description: Use when doing per-component threat analysis of a system, service, or architecture diagram, evaluating spoofing, tampering, repudiation, information disclosure, denial of service, or elevation-of-privilege risks, or when asked to "run STRIDE" or "threat model this component".
---

# STRIDE Worksheet

## Overview

STRIDE is a per-component threat enumeration framework. For each element in a system, walk six threat categories and identify concrete threats.

| Letter | Category | Property violated |
|--------|----------|-------------------|
| S | Spoofing | Authentication |
| T | Tampering | Integrity |
| R | Repudiation | Non-repudiation |
| I | Information Disclosure | Confidentiality |
| D | Denial of Service | Availability |
| E | Elevation of Privilege | Authorization |

## When to Use

- Fast, ongoing analysis of a component, service, or feature during normal development.
- A data flow diagram (DFD) already exists, or can be sketched quickly, listing processes, data stores, external entities, and flows.
- Not the right tool for privacy-specific analysis (use `threat-model-linddun`) or business-risk-driven, end-to-end reviews (use `threat-model-pasta`).

## Scope (fill in before starting)

- System or component:
- Boundary (what's in scope, what's not):
- Data classifications handled:

## Component table

For each major component (process, data store, external entity, data flow), mark which categories apply:

| Component | Type | S | T | R | I | D | E |
|-----------|------|---|---|---|---|---|---|
| | Process / Store / Flow / External | | | | | | |

## Threat entry template

For each relevant cell, write at least one concrete threat entry:

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

Repeat for every component × every applicable category.

## Pitfalls

- Treating STRIDE as a checkbox: "S, done" without thinking through specific spoofing vectors. Force at least one concrete threat per marked cell.
- Stopping at obvious threats. Value comes from "what would a creative attacker do here that we haven't seen yet".
- Assigning everything to "the security team" instead of the component owner. Threats need owner accountability.
- Modeling a perfect attacker. Use a realistic attacker profile: capabilities, motivations, access.

## Output

A backlog of threats, each with: identifier, description, controls in place, gaps, mitigation plan, owner. Mitigation plan items become engineering work items.
