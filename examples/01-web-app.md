# Worked Example: Web Application (SaaS B2B)

A multi-tenant SaaS application with web UI and REST API. Tenants are companies; their employees are users.

## System summary

- React SPA frontend hosted on CloudFront.
- REST API in containers behind an ALB.
- PostgreSQL primary + read replicas.
- Redis for sessions and caching.
- Stripe for billing.
- SendGrid for email.
- Auth0 for SSO.

## DFD (text form)

```
External:
  - End users (employees of tenant orgs)
  - Tenant admins
  - Internal staff (support, engineering)
  - Stripe (incoming webhooks, outgoing API)
  - SendGrid (outgoing API)
  - Auth0 (OIDC)

Processes:
  - Frontend (CloudFront → React SPA)
  - API gateway (ALB)
  - API service (containers)
  - Background workers (queue consumers)

Stores:
  - Postgres primary (tenant data)
  - Postgres replicas (read scaling)
  - Redis (sessions, rate-limit counters, cache)
  - S3 (uploaded files, exports)

Trust boundaries:
  - Internet ↔ CloudFront/ALB
  - ALB ↔ API service (VPC)
  - API service ↔ data stores (private subnet)
  - Tenant A ↔ Tenant B (within shared infrastructure)
  - Standard user ↔ tenant admin
  - Tenant admin ↔ internal staff
```

## Threats (selected high-priority via STRIDE)

### Spoofing
- **Auth0 token forgery:** mitigated by Auth0's signing + verification.
- **Internal staff impersonating users for "support":** mitigated by SCIM-managed admin roles + audit of impersonation events.

### Tampering
- **Mass assignment on profile/billing endpoints:** DTO allowlists, reviewed in code review and in tests.
- **Tampering of Stripe webhooks:** signature verification on every webhook.

### Repudiation
- **Tenant admin disputes deletion of records:** immutable audit log, exports for tenant admins.

### Information Disclosure
- **Cross-tenant data leakage via BOLA:** RLS in Postgres + tenant_id check in application + automated cross-tenant tests.
- **Leaked S3 export URLs:** signed URLs, 1-hour TTL, server-side encryption.

### Denial of Service
- **Expensive search endpoint:** per-tenant rate limit, query timeout, complexity scoring.
- **Email-based account-creation flooding:** captcha + rate limit + email validation.

### Elevation of Privilege
- **Tenant admin escalating to internal staff:** strict RBAC, internal role only assignable from internal IDP.
- **User escalating to tenant admin:** invitation flow with tenant-admin approval, no self-promotion.

## Privacy (LINDDUN highlights)

- **Data subject requests:** GDPR right-to-erasure handled by tenant-scoped delete with cascade.
- **Linkability across tenants:** users with the same email in two tenants are kept as separate accounts; tenant boundary is the privacy boundary.
- **Data export:** tenant admins can export their tenant's data; supports access requests.

## Top mitigations from this exercise

1. Add automated cross-tenant access tests (BOLA regression).
2. Migrate to short-lived database credentials via Vault.
3. Implement query complexity scoring on the search endpoint.
4. Deploy SCIM for internal staff RBAC sync.
5. Add signed URL audit log for S3 exports.

## Pitfalls noticed

- Admin-only endpoints initially missed in cross-tenant tests (test only ran as standard user).
- Webhook signature verification was correct but the secret was checked into the repo for staging (fixed).
- Audit log was append-only at app level but writeable directly via DBA credentials. Considered moving to write-only-via-API store.
