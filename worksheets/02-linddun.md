# LINDDUN Worksheet (Privacy)

LINDDUN is a privacy-focused complement to STRIDE. Use when handling personal data is core to the system.

| Letter | Category |
|--------|----------|
| L | Linkability |
| I | Identifiability |
| N | Non-repudiation (when undesired for the user) |
| D | Detectability |
| D | Disclosure of information |
| U | Unawareness |
| N | Non-compliance |

## Scope

- System / component:
- Personal data handled (categories):
- Lawful basis (for GDPR contexts):
- Data subjects (users, customers, employees):

## Per-component analysis

For each component handling personal data, evaluate the seven properties.

### Linkability
Can two records that should be unlinkable be associated? E.g., pseudonyms that share a stable identifier across contexts.

### Identifiability
Can a person be re-identified from "anonymized" data? Quasi-identifiers (zip + birth date + gender) are a classic example.

### Non-repudiation (privacy sense)
Can a user plausibly deny an action when they should be able to? Some systems over-log, eliminating the user's ability to refute claims about them.

### Detectability
Can an observer detect that a record exists, even without seeing its contents? Existence alone may be sensitive (healthcare, dating apps).

### Disclosure
Standard confidentiality breach, data accessed by the wrong party.

### Unawareness
Does the user understand what data is collected, how it's used, with whom it's shared? Dark patterns and complex consent UIs fail here.

### Non-compliance
Does the system meet applicable regulations (GDPR, CCPA, HIPAA, sector-specific)?

## Threat entries

```
ID:           LINDDUN-003
Category:     Identifiability
Data:         User location history (anonymized)
Description:  Location traces are unique enough that 4 points re-identify
              95% of users. "Anonymized" claim is misleading.
Risk:         High
Mitigation:
  - Reduce precision (geographic + temporal)
  - Aggregate before storage
  - Add differential privacy if querying is needed
Compliance impact: GDPR Article 4 (still personal data despite "anonymization")
Owner:        data-platform
Status:       Open
```

## Mitigation patterns

- Data minimization: collect less to begin with
- Pseudonymization with rotated identifiers
- Aggregation / k-anonymity / l-diversity
- Differential privacy
- Encryption with split keys / customer-held keys
- Retention limits and automated deletion
- Granular consent and clear notice

## Pitfalls

- Assuming "anonymized" means "no longer personal data", almost always wrong under GDPR.
- Treating LINDDUN as a legal exercise instead of an engineering one. The threats are technical; the regulations make them mandatory to address.
- Skipping the Unawareness category because it's about UX. UX is part of privacy.
