#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="terraform/root"
ROOT_TFVARS="prod.tfvars"

DESTROY_PLAN="destroy.tfplan"
DESTROY_PLAN_TEXT="destroy-plan.txt"

BACKEND_BUCKET="taskapp-terraform-state-opara"

echo "Starting TaskApp Terraform destroy workflow..."

if ! command -v terraform >/dev/null 2>&1; then
  echo "Error: Terraform is not installed."
  exit 1
fi

if [ ! -d "$ROOT_DIR" ]; then
  echo "Error: $ROOT_DIR does not exist."
  exit 1
fi

if [ ! -f "$ROOT_DIR/$ROOT_TFVARS" ]; then
  echo "Error: $ROOT_DIR/$ROOT_TFVARS does not exist."
  echo "Destroy requires the same variable file used for deployment."
  exit 1
fi

echo
echo "This script destroys terraform/root infrastructure only."
echo "It does NOT destroy the Terraform backend bucket:"
echo "$BACKEND_BUCKET"
echo

terraform -chdir="$ROOT_DIR" fmt -recursive
terraform -chdir="$ROOT_DIR" init
terraform -chdir="$ROOT_DIR" validate

echo
echo "Creating destroy plan..."
terraform -chdir="$ROOT_DIR" plan -destroy -var-file="$ROOT_TFVARS" -out="$DESTROY_PLAN"

terraform -chdir="$ROOT_DIR" show -no-color "$DESTROY_PLAN" > "$DESTROY_PLAN_TEXT"

echo
echo "Running backend protection check..."

if grep -qi "$BACKEND_BUCKET" "$ROOT_DIR/$DESTROY_PLAN_TEXT"; then
  echo "ERROR: Destroy plan includes the Terraform backend bucket:"
  echo "$BACKEND_BUCKET"
  echo
  echo "Aborting. terraform/root must not manage the backend bucket."
  exit 1
fi

echo "Backend bucket protection passed."

echo
echo "WARNING:"
echo "This will destroy Terraform-managed infrastructure in terraform/root."
echo "This will NOT destroy $BACKEND_BUCKET."
echo
echo "Review the destroy plan carefully."
echo

read -r -p "Type DESTROY_ROOT to continue: " CONFIRM

if [ "$CONFIRM" != "DESTROY_ROOT" ]; then
  echo "Destroy cancelled."
  exit 0
fi

terraform -chdir="$ROOT_DIR" apply "$DESTROY_PLAN"

echo
echo "TaskApp Terraform root infrastructure destroyed."
echo "Terraform backend bucket was not destroyed."