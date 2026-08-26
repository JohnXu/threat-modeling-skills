# Worked Example: Infrastructure-as-Code Pipeline

Terraform-based pipeline deploying AWS infrastructure for multiple environments.

## System summary

- Terraform code in a git repo.
- PRs reviewed; merge to main triggers a pipeline.
- Pipeline runs `terraform plan` then (after approval) `terraform apply`.
- State stored in S3 with DynamoDB locking.
- Per-environment state files (dev, staging, prod).

## DFD

```
External:
  - Engineers (write code, review PRs)
  - SREs (approve production applies)
  - Internal CI service

Processes:
  - Git host (e.g., GitHub Enterprise)
  - CI runner (containers)
  - Terraform planning + applying
  - AWS APIs

Stores:
  - Terraform state files (S3)
  - State lock (DynamoDB)
  - CI artifacts (logs, plans)

Trust boundaries:
  - Engineer laptops <-> Git host
  - Git host <-> CI service
  - CI runner <-> AWS
  - Per-environment isolation
```

## IaC-specific threats

### Code path
- **Malicious PR merged:** attacker commits Terraform that creates a backdoor (overpermissive IAM, public S3 bucket, attacker-controlled VPC peering).
  - Mitigation: branch protection requiring 2 reviewers for prod-touching code, mandatory plan output review, automated policy checks on every PR (OPA / Sentinel / tfsec / checkov).
- **Module supply chain:** Terraform module from public registry compromised.
  - Mitigation: pin modules to specific commits / hashes, mirror modules internally, review module contents on update.

### Pipeline path
- **CI runner credentials abuse:** runner has long-lived AWS keys with apply rights; compromised runner can do anything.
  - Mitigation: OIDC-based short-lived credentials, scoped per environment, no long-lived keys in CI.
- **Plan vs apply divergence:** plan reviewed; apply runs different code (race condition, second commit during approval window).
  - Mitigation: plan and apply use same git SHA; lock environment during the apply window.
- **Approval bypass:** production apply triggered without proper approval.
  - Mitigation: required-reviewer enforcement at pipeline level, not just at PR level. Approval audit log.

### State path
- **State file disclosure:** state contains secrets and full resource inventory.
  - Mitigation: state bucket private, encrypted at rest with customer KMS key, access via least-privilege role, versioning enabled.
- **State manipulation:** attacker modifies state to control resource references.
  - Mitigation: tight write access, server-side state versioning, periodic state file integrity checks against actual AWS resources (drift detection).
- **Locking bypass:** concurrent operations corrupt state.
  - Mitigation: DynamoDB locking enforced, monitor for stale locks.

### Cross-environment
- **Dev-to-prod credential reuse:** same AWS account or shared credentials across envs allow lateral pivot.
  - Mitigation: separate AWS accounts per environment, separate IAM trust chains, no cross-account roles unless explicitly necessary.

### Secret handling
- **Secrets in code:** developers hardcode credentials in `*.tf` files.
  - Mitigation: pre-commit hooks (gitleaks, trufflehog), branch protection, secrets retrieved at apply time from a secret manager.
- **Secrets in plan output:** plan output prints secret values.
  - Mitigation: mark secret variables with `sensitive = true` in Terraform, redact CI logs.
- **Secrets in state:** Terraform state stores resource attributes including some secrets.
  - Mitigation: state bucket protections (above), avoid storing high-sensitivity secrets in TF-managed resources, use AWS Secrets Manager separately.

## Top mitigations from this exercise

1. OIDC federation from CI to AWS, eliminating long-lived keys.
2. OPA / tfsec / checkov on every PR with merge-blocking violations.
3. Mandatory 2-reviewer approval for prod-touching changes.
4. Per-environment AWS accounts with no cross-trust.
5. State bucket private, KMS-encrypted, versioned, audit-logged.
6. Pre-commit secret scanning.
7. Drift detection running periodically against state.

## Pitfalls noticed

- A "fix" PR was used to slip in an unrelated IAM change that opened a backdoor; mitigated by stricter review process and OPA rule limiting IAM changes per PR.
- Plan output in CI logs included credential resource attributes; CI log access was broader than apply access. Fixed by redaction.
- Modules were pinned to a tag; attacker could move the tag. Switched to commit-SHA pinning.
