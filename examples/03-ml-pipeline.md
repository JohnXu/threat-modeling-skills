# Worked Example: ML Training and Inference Pipeline

A pipeline that ingests data, trains a model, and serves predictions via API.

## System summary

- Training data ingested from internal sources + customer uploads.
- Stored in S3 / data warehouse.
- Training runs on GPU clusters (managed Kubernetes).
- Models published to a model registry.
- Inference service loads models, serves via HTTPS.
- Customers query the inference API for predictions.

## DFD

```
External:
  - Internal data sources
  - Customer-uploaded data
  - End users of inference API

Processes:
  - Ingestion pipeline
  - Training jobs
  - Model registry
  - Inference service

Stores:
  - Raw data lake (S3)
  - Curated training datasets
  - Model artifacts (registry)
  - Inference logs

Trust boundaries:
  - Customer ↔ ingestion
  - Training environment ↔ inference environment
  - Model registry ↔ inference (consume artifacts)
```

## ML-specific threats

### Training data integrity
- **Data poisoning:** an attacker with write access to training data injects examples that cause specific misbehavior.
  - Mitigation: limit who can write to training data, version control with reviews, automated validation (schema, distribution checks, outlier flags).
- **Label flipping:** if labels come from human annotation, a hostile annotator skews the model.
  - Mitigation: redundant labeling, agreement scoring, periodic review.

### Model integrity
- **Compromised model artifact:** model file replaced in registry with a backdoored version.
  - Mitigation: signing of artifacts at training time, signature verification at inference load time, registry write access restricted, audit log on every push.
- **Pickle deserialization:** loading a pickle file executes code.
  - Mitigation: prefer safetensors. If pickle is required, load in an isolated environment.

### Privacy in training data
- **Memorization:** model regurgitates verbatim training records, especially rare ones (PII, secrets).
  - Mitigation: scrub PII from training data, deduplicate (heavy duplicates increase memorization), differential privacy where the utility tradeoff is acceptable.
- **Membership inference:** attacker determines whether a record was in the training set.
  - Mitigation: regularization, ensembling, DP-SGD for sensitive applications.

### Inference service
- **Model extraction:** attacker queries the model enough times to train a clone.
  - Mitigation: rate limits, anomaly detection on query patterns, query result rounding for sensitive predictions.
- **Adversarial examples:** crafted inputs that produce attacker-chosen outputs.
  - Mitigation: depends on stakes; adversarial training, input distribution monitoring.
- **Prompt injection (for LLM-based systems):** see ai-llm-security-audit collection.

### Operational
- **GPU runaway costs:** misconfigured training job consumes large amounts of resource.
  - Mitigation: budget alerts, max-runtime, max-cost-per-job.
- **Data exfiltration via training jobs:** training pods have access to data; an attacker who runs a job can exfiltrate.
  - Mitigation: egress restrictions on training pods, audit of training job submissions.

## Top mitigations from this exercise

1. Sign all model artifacts at publish time; verify at load time.
2. Restrict training data write access; require code review for dataset updates.
3. Move model artifacts to safetensors format.
4. Implement query rate limits and anomaly detection on inference API.
5. PII scrubbing pass on training data ingestion.
6. Egress restrictions on training pods.
7. Per-job cost caps.

## Pitfalls noticed

- Training data permissions were "anyone in eng" rather than per-dataset; mitigated by introducing dataset-level RBAC.
- Inference service was loading models from a path attacker-controlled in URL parameters (path traversal possible). Fixed by allowlisting.
- A test model with deliberately-toxic outputs was indistinguishable in the registry from production models. Added flags and load-time refusal of test models in prod.
