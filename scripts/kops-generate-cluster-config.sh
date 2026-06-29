#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="k8s.oparatechstack.com"
KOPS_STATE_STORE="s3://taskapp-kops-state-opara"
DNS_ZONE="oparatechstack.com"

VPC_ID="vpc-074f7558181ad3b28"
NETWORK_CIDR="10.0.0.0/16"

ZONES="eu-west-3a,eu-west-3b,eu-west-3c"

PRIVATE_SUBNET_IDS="subnet-0b11a0d7d14e38962,subnet-0246109b2359e3b90,subnet-0643ee627157f1e42"
PUBLIC_SUBNET_IDS="subnet-0bae92662870cd721,subnet-052905b7848163143,subnet-0cdc937d1b9ac742a"

NODE_COUNT="3"
NODE_SIZE="t3.small"
CONTROL_PLANE_SIZE="t3.small"

OUTPUT_FILE="kops/cluster.yaml"

echo "Generating kOps cluster config only..."
echo "No AWS cluster resources will be created."
echo "Cluster name: $CLUSTER_NAME"
echo "State store: $KOPS_STATE_STORE"
echo "DNS zone: $DNS_ZONE"
echo "VPC ID: $VPC_ID"
echo "Network CIDR: $NETWORK_CIDR"
echo "Zones: $ZONES"
echo "Private subnets: $PRIVATE_SUBNET_IDS"
echo "Public utility subnets: $PUBLIC_SUBNET_IDS"

if ! command -v kops >/dev/null 2>&1; then
  echo "Error: kops is not installed."
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: AWS CLI is not installed."
  exit 1
fi

mkdir -p kops

if ! aws s3 ls "$KOPS_STATE_STORE" >/dev/null 2>&1; then
  echo "Error: kOps state bucket does not exist or is not accessible."
  echo "Expected: $KOPS_STATE_STORE"
  echo "Run Terraform root apply first."
  exit 1
fi

kops create cluster \
  --name "$CLUSTER_NAME" \
  --state "$KOPS_STATE_STORE" \
  --cloud aws \
  --zones "$ZONES" \
  --network-id "$VPC_ID" \
  --network-cidr "$NETWORK_CIDR" \
  --subnets "$PRIVATE_SUBNET_IDS" \
  --utility-subnets "$PUBLIC_SUBNET_IDS" \
  --topology private \
  --networking calico \
  --node-count "$NODE_COUNT" \
  --node-size "$NODE_SIZE" \
  --control-plane-size "$CONTROL_PLANE_SIZE" \
  --dns-zone "$DNS_ZONE" \
  --dry-run \
  -o yaml > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"
echo "Review it before creating the real cluster."
