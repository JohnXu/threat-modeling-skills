---
name: threat-model-trust-boundary
description: Use when identifying or documenting where data crosses between differing trust levels (internet/perimeter, tenant/tenant, app/DB, standard user/admin, your code/third-party libraries), and what authentication, authorization, validation, and encryption apply at each crossing.
---

# Trust Boundary Worksheet

## Overview

A trust boundary is a line where the trust level of data changes. Most security failures happen at boundaries — data trusted on one side enters the other side without re-validation.

## When to Use

- A DFD (see `threat-model-dfd`) has identified boundaries that need detailed, per-boundary documentation.
- Reviewing whether authentication/authorization/validation/encryption is actually enforced consistently at a specific crossing.
- Auditing multi-tenant isolation, admin vs standard user separation, or third-party data sharing.

## Common trust boundaries

- Internet <-> your perimeter
- DMZ <-> internal network
- Application server <-> database
- Tenant A's data <-> tenant B's data (in multi-tenant systems)
- Production <-> non-production
- User mode <-> kernel mode (for OS-level threat models)
- Authenticated <-> unauthenticated user
- Standard user <-> admin user
- Your code <-> third-party libraries
- Your infrastructure <-> vendor SaaS holding your data

## Per-boundary worksheet

For each trust boundary in scope:

```
Boundary name:
What trust level on each side:
  Side A (lower trust):
  Side B (higher trust):

What crosses the boundary:
  - Data flow 1 (direction, content)
  - Data flow 2
  - ...

Authentication at boundary:
  - Method
  - Strength
  - Failure modes

Authorization at boundary:
  - Granularity (per-action, per-resource, role-based, attribute-based)
  - Where enforced (gateway, application, database)

Input validation at boundary:
  - Schema / type checking
  - Business rule validation
  - Encoding for downstream context

Encryption:
  - In transit
  - Algorithm and protocol version
  - Certificate validation

Logging:
  - What's logged on cross
  - Retention
  - Anomaly detection

Threats specific to this boundary:
  - Spoofing of identity from lower side
  - Tampering with data in transit
  - Information disclosure (data echoed back unsafely)
  - Privilege escalation through trusted path
```

## Patterns for common boundaries

### Internet <-> perimeter
- TLS termination at WAF/LB
- Authentication at API gateway
- Rate limiting per IP and per user
- Bot management
- Geo-blocking where appropriate

### App server <-> database
- Per-app credentials, not shared
- Network ACL: only app servers can reach DB
- Least-privilege DB user (no DDL, no SUPER)
- Connection encryption
- Query parameterization (boundary input validation)

### Tenant <-> tenant
- Row-level security or schema-per-tenant
- Tenant ID validation on every query
- Encryption keys scoped per tenant where data sensitivity warrants
- Test cases for cross-tenant access attempts

### Standard user <-> admin
- Step-up authentication for admin actions
- Separate authentication context (session re-issued on role change)
- Audit log for every admin action
- Time-bounded admin sessions

## Pitfalls

- "Internal network is trusted" — modern thinking is zero trust; treat internal flows the way you'd treat external.
- Boundary defined but not enforced consistently. Adding a control on one path while leaving another path open is common.
- Boundary missed entirely — third-party SaaS holding your data is a boundary even if your network diagram doesn't show it as one.

## Output

Per-boundary documentation, threats associated with each boundary, and mitigations to put in place where gaps exist.
