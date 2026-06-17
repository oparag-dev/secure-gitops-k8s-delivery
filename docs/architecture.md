# Secure GitOps Kubernetes Delivery Architecture

## Purpose

This project builds a secure Kubernetes delivery workflow for TaskApp. The goal is to reduce deployment risk, improve release traceability, enforce runtime security controls, and provide operational visibility.

## Flow

```text
Developer
  -> GitHub repo
  -> GitHub Actions
  -> Gitleaks secret scan
  -> Backend and frontend tests
  -> Checkov config scan
  -> Trivy repo scan
  -> Docker image build
  -> Trivy image scan
  -> Docker Hub push with Git SHA tag
  -> Helm chart image tag update
  -> Argo CD sync
  -> Kubernetes API server
  -> Kyverno admission control
  -> TaskApp deployment
  -> Prometheus metrics
  -> Grafana dashboards
  -> Alertmanager alerts
```

## Business Value

- Faster release flow through CI and GitOps.
- Lower deployment risk through scans and policy enforcement.
- Better rollback control through Git SHA image tags.
- Better runtime visibility through metrics, dashboards, and alerts.
- Clearer engineering judgment through decision records.

## Core Rule

Each tool must reduce a business risk. If a tool does not reduce delivery risk, reliability risk, security risk, cost risk, or operational risk, it should not be added.

