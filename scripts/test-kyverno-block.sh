#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f k8s/test-bad-pod.yaml

