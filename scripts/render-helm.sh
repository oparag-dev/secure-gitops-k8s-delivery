#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"

helm template taskapp helm/taskapp -f "helm/taskapp/values-${ENVIRONMENT}.yaml"

