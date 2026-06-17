# 010 - Infrastructure Folder Ownership

## Status

Draft

## Decision

Use separate folders for separate operational responsibilities. Terraform creates prerequisites only, kOps creates and manages the Kubernetes cluster, Helm packages the app, Argo CD syncs the app, and scripts only automate repeatable local commands.

## Business Context

The project needs enough structure to support growth without becoming confusing. Mixed responsibilities increase handover cost and make failures harder to debug.

## Folder Ownership

| Folder | Owner Purpose |
|---|---|
| `Terraform/` | AWS prerequisites such as the kOps state bucket |
| `kops/` | Kubernetes cluster definition and cluster lifecycle |
| `helm/` | Application packaging |
| `argocd/` | GitOps application sync |
| `policies/` | Kyverno security guardrails |
| `monitoring/` | Prometheus, Grafana, and alerting config |
| `k8s/` | Raw cluster bootstrap or test manifests |
| `scripts/` | Helper commands only |
| `docs/` | Decisions, evidence, architecture, and runbooks |

## Why This Choice

This prevents Terraform and kOps from trying to own the same infrastructure. It also makes the repo easier for another engineer to understand.

## Trade-Offs

More folders require discipline. The benefit is lower confusion when the project grows.

## When To Choose Differently

If this were a small app with no cluster provisioning, most folders could be removed and the repo could keep only app, helm, argocd, policies, monitoring, and docs.

## Interview Explanation

I separated the folders by operational ownership. Terraform handles prerequisites, kOps owns the Kubernetes cluster, Helm packages the app, Argo CD handles sync, and Kyverno handles admission policy. This lowers operational confusion and makes the system easier to hand over.

