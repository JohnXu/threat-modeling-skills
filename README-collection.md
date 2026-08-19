# About this collection

Threat modeling worksheets and worked examples. Worksheets give you the structure; the worked examples show how the structure plays out on concrete systems.

## Worksheets

1. STRIDE
2. LINDDUN (privacy)
3. PASTA
4. Attack Tree
5. Data Flow Diagram template
6. Trust Boundary worksheet
7. Abuse Case worksheet

## Worked examples

1. Web Application (B2B SaaS)
2. Mobile Application
3. ML Training and Inference Pipeline
4. Infrastructure-as-Code Pipeline
5. IoT Device

## How to use

For a focused review: pick the worksheet that fits the question (privacy -> LINDDUN, attacker reasoning -> attack tree, new feature -> abuse case).

For a full system review: start with the DFD worksheet, layer STRIDE on each component, layer LINDDUN if personal data is in scope, then attack-tree the highest-value assets.

The worked examples show finished outputs and the kind of findings the process produces. They are illustrative, not prescriptive, your system's threats are specific to your system.

## Threat modeling as a practice

- Once is not enough. Threat models go stale as architecture evolves.
- The output is action items, not a document. If no engineering work follows, the exercise wasn't useful.
- Involve engineering, not just security. Engineers know the actual implementation; security knows the attacker mindset. Both are required.
- Keep the level of detail proportional to the stakes. Not every system needs a full PASTA.
