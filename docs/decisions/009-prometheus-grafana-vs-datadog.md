# 009 - Prometheus And Grafana Vs Datadog

## Status

Draft

## Decision

Use Prometheus, Grafana, and Alertmanager for this project. Document Datadog as a strong production option for funded teams that want managed observability.

## Business Context

The business needs visibility into application health, cluster health, resource usage, and alerts. The decision must balance cash cost, engineering time, vendor lock-in, and learning value.

## Options Considered

| Option | Strength | Weakness |
|---|---|---|
| Prometheus, Grafana, Alertmanager | Low direct cost, Kubernetes-native, open source, strong learning value | Requires setup, tuning, storage planning, and alert maintenance |
| Datadog | Managed observability, faster setup, logs/metrics/traces in one platform | Higher usage-based vendor cost and less low-level learning |

## Why This Choice

Prometheus and Grafana fit this project because the goal is to show Kubernetes monitoring knowledge. Prometheus collects metrics and fires alerts through Alertmanager. Grafana visualizes application and cluster health.

Datadog would reduce operational burden in a real funded startup, but it would hide much of the monitoring design this project needs to demonstrate.

## Trade-Offs

- Prometheus and Grafana require more operational ownership.
- Datadog costs more but saves engineering time.
- Open-source monitoring needs careful alert tuning to avoid noise.

## Cost Impact

Prometheus and Grafana reduce direct cash cost, but require engineering time. Datadog increases vendor cost, but can reduce operational time for small teams.

## Risk Impact

Prometheus and Grafana reduce silent failure risk by exposing app and cluster health. The remaining risk is poor alert design or unmonitored failure paths.

## When To Choose Differently

Choose Datadog if the company has paying customers, limited DevOps capacity, and needs faster production visibility across logs, metrics, traces, and incidents.

## Interview Explanation

I chose Prometheus and Grafana because the project is Kubernetes-native and cost-aware. They show how metrics are collected, visualized, and alerted on. Datadog is a good business option for funded production teams because it reduces observability maintenance, but it adds vendor cost and hides some of the platform learning this project is meant to show.

