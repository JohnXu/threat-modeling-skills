# threat-modeling-worksheets

Seven worksheets covering the methodologies people actually use for threat modeling, plus five worked examples that show what the output looks like for real systems.

## Worksheet structure

Every worksheet has three parts:

1. **Scope and when to use**, what kind of system or analysis the methodology fits
2. **Template**, the actual worksheet, fillable
3. **Pitfalls**, failure modes the worksheet doesn't prevent

## Worked example structure

Every example has four parts:

1. **System description and DFD**, the system being modeled, with data flows
2. **Threats**, applied to the methodology in question
3. **Top mitigations**, ordered, with effort and impact estimates
4. **Pitfalls noticed**, what was hard, what got missed in the first pass

## Contents

### Worksheets

| # | Worksheet | Best for |
|---|-----------|----------|
| 01 | [STRIDE](worksheets/01-stride.md) | Per-component analysis of generic systems |
| 02 | [LINDDUN](worksheets/02-linddun.md) | Privacy-focused threats, especially for systems handling PII |
| 03 | [PASTA](worksheets/03-pasta.md) | Risk-driven, business-aligned threat modeling |
| 04 | [Attack tree](worksheets/04-attack-tree.md) | Decomposing a single high-impact attacker goal |
| 05 | [Data flow diagram](worksheets/05-data-flow-diagram.md) | Building the input most other methodologies need |
| 06 | [Trust boundary](worksheets/06-trust-boundary.md) | Identifying where data crosses authority levels |
| 07 | [Abuse case](worksheets/07-abuse-case.md) | Use-case mirror; useful in agile teams that already write user stories |

### Worked examples

| # | Example | System type |
|---|---------|-------------|
| 01 | [Web app](examples/01-web-app.md) | Standard web application with user accounts and a database |
| 02 | [Mobile app](examples/02-mobile-app.md) | Mobile client with offline data and a backend API |
| 03 | [ML pipeline](examples/03-ml-pipeline.md) | Training and serving pipeline for a production model |
| 04 | [IaC pipeline](examples/04-iac-pipeline.md) | Terraform/Pulumi pipeline deploying cloud infrastructure |
| 05 | [IoT device](examples/05-iot-device.md) | Connected device with cloud control plane |

## Intended use

Pick a methodology that matches the question you have. STRIDE for "what can go wrong with this component"; attack trees for "how could someone achieve this specific bad outcome"; LINDDUN if privacy is the point; PASTA if you need leadership to fund mitigations.

The worked examples are not templates to copy, they're examples of completed output, included so you know what "done" looks like for each methodology before you start.

## Contributing

If you've used a methodology not covered here in production work, open a PR with a worksheet and at least one worked example. Worked examples are valued more than worksheets; methodologies have plenty of papers, applied examples are scarcer.

## Related repositories

Part of a 10-repo security audit set.

Browser-based audit tools:
- [iam-policy-analyzer](https://github.com/0xelitesystem/iam-policy-analyzer)
- [terraform-security-linter](https://github.com/0xelitesystem/terraform-security-linter)
- [kubernetes-manifest-security-scanner](https://github.com/0xelitesystem/kubernetes-manifest-security-scanner)
- [session-cookie-auditor](https://github.com/0xelitesystem/session-cookie-auditor)
- [regex-redos-checker](https://github.com/0xelitesystem/regex-redos-checker)

Reference collections:
- [incident-response-runbooks](https://github.com/0xelitesystem/incident-response-runbooks)
- [ai-llm-security-audit](https://github.com/0xelitesystem/ai-llm-security-audit)
- [api-security-audit-checklist](https://github.com/0xelitesystem/api-security-audit-checklist)
- [secrets-leak-response-runbook](https://github.com/0xelitesystem/secrets-leak-response-runbook)

## License

MIT. See [LICENSE](LICENSE).
