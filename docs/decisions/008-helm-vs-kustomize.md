# 008 - Helm Vs Kustomize

## Status

Draft

## Decision

Use Helm for TaskApp packaging and Argo CD deployment. Keep the chart simple and values-driven.

## Business Context

The business needs repeatable releases across environments without rewriting Kubernetes YAML. The release process should support image tag updates, resource controls, probes, monitoring configuration, and future dev/staging/prod differences.

## Options Considered

| Option | Strength | Weakness |
|---|---|---|
| Helm | Strong application packaging, values files, repeatable releases | Can become hard to maintain if over-templated |
| Kustomize | Plain YAML, lower learning curve, clean overlays | Less suited to app packaging and release-style configuration |

## Why This Choice

Helm fits this project because the pipeline builds images, tags them, and deploys the app through Argo CD. Helm gives one package for the backend, frontend, services, probes, resource limits, and optional ServiceMonitor.

Kustomize would reduce operational cost for a small app with simple overlays. Helm reduces operational cost as the release process grows.

## Trade-Offs

- Helm adds templating.
- Bad Helm charts can become confusing.
- The chart must stay simple to avoid unnecessary complexity.

## Cost Impact

Helm has no direct platform cost. The operational cost is learning and maintaining the chart. It reduces release-management cost when environments and configuration differences increase.

## Risk Impact

Helm reduces deployment inconsistency. The remaining risk is chart complexity and poor review of values changes.

## When To Choose Differently

Choose Kustomize if the app has only simple manifests and the main need is environment overlays on plain YAML.

## Interview Explanation

I chose Helm because this project needs a repeatable application package for GitOps deployment. It lets me control image tags, resources, probes, and environment settings through values files. Kustomize is simpler for small overlays, but Helm fits better when the app needs release packaging and repeatable deployment.

