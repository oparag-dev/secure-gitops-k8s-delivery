#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="k8s.oparatechstack.com"
KOPS_STATE_STORE="s3://taskapp-kops-state-opara"
DNS_ZONE="oparatechstack.com"

MY_IP="$(curl -s https://checkip.amazonaws.com | tr -d '\n')"
ADMIN_CIDR="${MY_IP}/32"

VPC_ID="vpc-0deca127104c85401"
NETWORK_CIDR="10.0.0.0/16"

ZONES="eu-west-3a,eu-west-3b"

PRIVATE_SUBNET_IDS="subnet-0614d8bc109a19977,subnet-0719174ebf90528df"
PUBLIC_SUBNET_IDS="subnet-0ece7927b1d60ff55,subnet-040efa02f32932c6c"

NODE_COUNT="2"
NODE_SIZE="t3.small"
CONTROL_PLANE_SIZE="t3.medium"

OUTPUT_FILE="kops/cluster.yaml"

echo "Generating kOps cluster config only..."
echo "No AWS cluster resources will be created."
echo "Cluster name: $CLUSTER_NAME"
echo "State store: $KOPS_STATE_STORE"
echo "DNS zone: $DNS_ZONE"
echo "Admin CIDR: $ADMIN_CIDR"
echo "VPC ID: $VPC_ID"
echo "Network CIDR: $NETWORK_CIDR"
echo "Zones: $ZONES"
echo "Private subnets: $PRIVATE_SUBNET_IDS"
echo "Public utility subnets: $PUBLIC_SUBNET_IDS"
echo "Node count: $NODE_COUNT"
echo "Node size: $NODE_SIZE"
echo "Control plane size: $CONTROL_PLANE_SIZE"

if ! command -v kops >/dev/null 2>&1; then
  echo "Error: kops is not installed."
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: AWS CLI is not installed."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is not installed."
  exit 1
fi

if [[ -z "$MY_IP" ]]; then
  echo "Error: could not detect public IP."
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
  --ssh-access "$ADMIN_CIDR" \
  --admin-access "$ADMIN_CIDR" \
  --dns-zone "$DNS_ZONE" \
  --dry-run \
  -o yaml > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"
echo "Review it before creating the real cluster."