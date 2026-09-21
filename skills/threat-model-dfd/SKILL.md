---
name: threat-model-dfd
description: Use before any STRIDE/LINDDUN/PASTA analysis when a system's data flows, processes, data stores, external entities, and trust boundaries haven't been diagrammed yet, or when asked to build or update a data flow diagram.
---

# Data Flow Diagram (DFD) Template

## Overview

A DFD is the foundation document for most threat modeling. Get this right and STRIDE/LINDDUN become tractable.

## When to Use

- Starting any threat modeling exercise where the components and data flows aren't yet documented.
- Before running `threat-model-stride`, `threat-model-linddun`, or `threat-model-pasta` on a system.
- Architecture has changed and the existing DFD is stale.

## Notation

- **External entity** (rectangle): people or systems outside your control that interact with your system.
- **Process** (circle / rounded rectangle): something that transforms data — a service, function, container.
- **Data store** (open-ended rectangle / parallel lines): databases, queues, file systems, caches.
- **Data flow** (arrow): data moving between elements, labeled with what's flowing.
- **Trust boundary** (dashed line): where the trust level changes. Crossing a boundary often introduces threats. See `threat-model-trust-boundary` for a dedicated per-boundary worksheet.

## Procedure

1. Start with external entities and the system at a high level (Level 0 / context diagram).
2. Decompose the system into its major processes (Level 1).
3. For complex processes, decompose further (Level 2+) until each leaf is a single, well-understood unit.
4. Add trust boundaries:
   - Internet vs your perimeter
   - Internal network vs application servers
   - Application servers vs database
   - Production vs non-production
   - Tenant boundaries in multi-tenant systems
5. Label every flow with: data type, sensitivity, authentication used, transport security.

## Worksheet template

### Context (Level 0)

```
External entities:
  - End users
  - Admin users
  - Third-party API: Stripe
  - Third-party API: SendGrid
  - Internal users (employees)

System:
  - <Your application name>

Major flows:
  - End users  ->  app: HTTPS requests, credentials, user data
  - App  ->  end users: HTTPS responses, session cookies
  - App  ->  Stripe: API calls (charge, refund), customer PII
  - SendGrid  ->  app: webhook callbacks
  - Admins  ->  app: HTTPS, MFA-required
```

### Level 1

For each major process from Level 0, list:

```
Process name:
Inputs (with source):
Outputs (with destination):
Data stores accessed (read/write):
Trust boundaries crossed:
Authentication required:
Authorization checks:
```

### Trust boundaries

For each boundary, document:

```
Boundary name:
Trust differential (what's higher vs lower):
Crossings (which flows cross it):
Controls at the boundary:
  - Authentication
  - Authorization
  - Input validation
  - Encryption
Threats specific to crossings (feed into STRIDE).
```

## What to look for

- Flows missing labels — undocumented data movement is a smell.
- Trust boundaries that are crossed without authentication / encryption.
- Data stores accessed by many processes without clear ownership.
- External entities with high access — third-party SaaS that holds copies of your data.
- "Magic" flows — diagrams with arrows pointing into clouds labeled "infrastructure".

## Maintenance

- DFD is a living document. Update on architecture changes.
- Versioned alongside the architecture, in the same repo.
- Reviewed at design time for new features.

## Pitfalls

- Decomposing too far on day one — produces diagrams nobody reads.
- Decomposing too little — Level 0 alone doesn't surface real threats.
- Missing operator / admin paths — these are often where compromise actually starts.
- Missing batch / async flows — queues and scheduled jobs hide threats.

## Output

A diagram (any tool: draw.io, OmniGraffle, text-based with Mermaid) plus written documentation per the templates above. The DFD feeds STRIDE/LINDDUN/PASTA.
