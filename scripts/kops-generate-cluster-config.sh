#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="k8s.oparatechstack.com"
KOPS_STATE_STORE="s3://taskapp-kops-state-opara"
DNS_ZONE="oparatechstack.com"

ZONES="eu-west-3a,eu-west-3b,eu-west-3c"
NODE_COUNT="3"
NODE_SIZE="t3.small"
CONTROL_PLANE_SIZE="t3.small"

OUTPUT_FILE="kops/cluster.yaml"

echo "Generating kOps cluster config..."
echo "Cluster name: $CLUSTER_NAME"
echo "State store: $KOPS_STATE_STORE"
echo "DNS zone: $DNS_ZONE"
echo "Zones: $ZONES"

if ! command -v kops >/dev/null 2>&1; then
  echo "Error: kops is not installed."
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: AWS CLI is not installed."
  exit 1
fi

if ! aws s3 ls "$KOPS_STATE_STORE" >/dev/null 2>&1; then
  echo "Error: kOps state bucket does not exist or is not accessible: $KOPS_STATE_STORE"
  echo "Apply Terraform root first."
  exit 1
fi

kops create cluster \
  --name "$CLUSTER_NAME" \
  --state "$KOPS_STATE_STORE" \
  --cloud aws \
  --zones "$ZONES" \
  --networking calico \
  --node-count "$NODE_COUNT" \
  --node-size "$NODE_SIZE" \
  --control-plane-size "$CONTROL_PLANE_SIZE" \
  --dns-zone "$DNS_ZONE" \
  --dry-run \
  -o yaml > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"
echo "Review it before creating the cluster."
