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

## Use as agent skills

Each worksheet is also packaged as an [Agent Skill](https://agentskills.io/specification) under [`skills/`](skills/), a `SKILL.md` per methodology that a coding agent (Claude Code, GitHub Copilot CLI, Codex, Gemini CLI, and other harnesses that read `~/.agents/skills/`) can discover and apply automatically when a matching task comes up.

| Skill | Triggers on |
|-------|-------------|
| [threat-model-stride](skills/threat-model-stride/SKILL.md) | Per-component threat analysis, "run STRIDE" |
| [threat-model-linddun](skills/threat-model-linddun/SKILL.md) | Privacy analysis for systems handling personal data, "run LINDDUN" |
| [threat-model-pasta](skills/threat-model-pasta/SKILL.md) | Full business-risk-driven review, compliance/M&A diligence, "run PASTA" |
| [threat-model-attack-tree](skills/threat-model-attack-tree/SKILL.md) | Decomposing how an attacker reaches one specific goal |
| [threat-model-dfd](skills/threat-model-dfd/SKILL.md) | Building/updating a data flow diagram before other analysis |
| [threat-model-trust-boundary](skills/threat-model-trust-boundary/SKILL.md) | Documenting a specific trust-level crossing |
| [threat-model-abuse-case](skills/threat-model-abuse-case/SKILL.md) | Attacker's-eye mirror of a feature's use cases |

### Install


Common command in IDE, follow IDE install step, select target skills (select), select AI target tool
```Windows IDE
npx skills add https://github.com/JohnXu/threat-modeling-skills
```

Requires Node.js (used only to run `npx degit`, which fetches a folder without cloning git history). Installs into `~/.agents/skills` by default, without touching any other skills already installed there.

macOS/Linux:

```bash
npx --yes degit JohnXu/threat-modeling-skills/scripts /tmp/tms-scripts --force
bash /tmp/tms-scripts/install-skills.sh
```

Windows (PowerShell):

```powershell
npx --yes degit JohnXu/threat-modeling-skills/scripts $env:TEMP\tms-scripts --force
& "$env:TEMP\tms-scripts\install-skills.ps1"
```

To install only specific skills, pass their names as arguments (`install-skills.sh threat-model-stride threat-model-linddun`, or `-Skills threat-model-stride,threat-model-linddun` on PowerShell). Use `--dir` / `-Dir` to install somewhere other than `~/.agents/skills` (e.g. `~/.claude/skills` for Claude-only setups).

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

## More

Part of a catalog of single-file browser tools and plain-language references, all MIT licensed and dependency-free: [0xelitesystem.github.io](https://0xelitesystem.github.io/). Built by [elitesystem.ai](https://elitesystem.ai).

## License

MIT. See [LICENSE](LICENSE).
