# PASTA Worksheet (Process for Attack Simulation and Threat Analysis)

PASTA is heavier-weight than STRIDE/LINDDUN. Useful for high-stakes systems where business impact analysis matters and you have time to do it well. Seven stages.

## Stage 1: Define business objectives

- What does the system do for the business?
- What revenue / cost / regulatory consequences flow from it?
- Which stakeholders care about its security?

## Stage 2: Define technical scope

- Architecture diagram with components, data flows, trust boundaries.
- Inventory of: hardware, OS, frameworks, libraries, third-party services, data stores.
- Network topology relevant to attack paths.

## Stage 3: Application decomposition

- Use cases (what users do).
- Data flows for each use case.
- Authentication / authorization paths.
- Trust boundaries — where data crosses from less trusted to more trusted contexts.

## Stage 4: Threat analysis

- Threat actor profiles relevant to the system: cybercriminals, nation-states, insiders, hacktivists, competitors.
- For each, list capabilities, motivations, and likely TTPs (MITRE ATT&CK is useful here).
- Threat intelligence: what attacks have hit similar systems recently?

## Stage 5: Vulnerability and weakness analysis

- Known vulnerabilities in stack components (CVE scans).
- Custom code review findings (SAST, manual).
- Configuration weaknesses (CIS benchmarks, cloud baselines).
- Cross-reference with the threat actor capabilities — which vulnerabilities are reachable for which actors?

## Stage 6: Attack modeling

- Attack trees: for each high-value asset, decompose how an attacker could reach it.
- Or kill chains: mapping each step of an attack against your defenses.
- Identify chokepoints — single defenses where multiple attack paths converge. These are high-value to harden.

## Stage 7: Risk and impact analysis

- For each modeled attack: likelihood, impact, residual risk after current controls.
- Prioritize mitigations by risk reduction per unit of effort.
- Document accepted risks with sign-off.

## When to use PASTA vs STRIDE

- STRIDE: per-component, fast, good for ongoing dev work.
- PASTA: end-to-end, slow, good for major system reviews, compliance, M&A diligence, or after a serious incident.

## Output

A document including: business context, attack scenarios with likelihood and impact, prioritized mitigations, residual risk register.

## Pitfalls

- Stopping after Stage 3 because Stage 4-7 are hard. The value is in the back half.
- Generic threat actors. "Nation state" is unhelpful; specify which one and why they'd target you.
- Treating attack trees as exhaustive. They're representative, not complete.
