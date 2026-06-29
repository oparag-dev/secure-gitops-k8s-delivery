#!/usr/bin/env bash

set -euo pipefail

BOOTSTRAP_DIR="terraform/bootstrap/backend"
ROOT_DIR="terraform/root"

BOOTSTRAP_TFVARS="prod.tfvars"
ROOT_TFVARS="prod.tfvars"

BOOTSTRAP_PLAN="bootstrap.tfplan"
ROOT_PLAN="root.tfplan"
ROOT_PLAN_TEXT="root-plan.txt"

BACKEND_BUCKET="taskapp-terraform-state-opara"

BLOCKED_TERMS=(
  "novara"
  "capstone-project"
  "opara-kops-state"
)

echo "Starting TaskApp Terraform deployment..."

if ! command -v terraform >/dev/null 2>&1; then
  echo "Error: Terraform is not installed."
  exit 1
fi

if [ ! -d "$BOOTSTRAP_DIR" ]; then
  echo "Error: $BOOTSTRAP_DIR does not exist."
  exit 1
fi

if [ ! -d "$ROOT_DIR" ]; then
  echo "Error: $ROOT_DIR does not exist."
  exit 1
fi

if [ ! -f "$BOOTSTRAP_DIR/$BOOTSTRAP_TFVARS" ]; then
  echo "Error: $BOOTSTRAP_DIR/$BOOTSTRAP_TFVARS does not exist."
  exit 1
fi

if [ ! -f "$ROOT_DIR/$ROOT_TFVARS" ]; then
  echo "Error: $ROOT_DIR/$ROOT_TFVARS does not exist."
  echo "Create terraform/root/prod.tfvars before deploying root infrastructure."
  exit 1
fi

echo
echo "Stage 1: Bootstrap Terraform remote state backend"
echo "------------------------------------------------"

terraform -chdir="$BOOTSTRAP_DIR" fmt -recursive
terraform -chdir="$BOOTSTRAP_DIR" init
terraform -chdir="$BOOTSTRAP_DIR" validate
terraform -chdir="$BOOTSTRAP_DIR" plan -var-file="$BOOTSTRAP_TFVARS" -out="$BOOTSTRAP_PLAN"

echo
read -r -p "Apply backend bootstrap plan? Type yes to continue: " APPLY_BOOTSTRAP

if [ "$APPLY_BOOTSTRAP" = "yes" ]; then
  terraform -chdir="$BOOTSTRAP_DIR" apply "$BOOTSTRAP_PLAN"
else
  echo "Skipped backend bootstrap apply."
fi

echo
echo "Stage 2: Deploy main Terraform root infrastructure"
echo "--------------------------------------------------"

terraform -chdir="$ROOT_DIR" fmt -recursive
terraform -chdir="$ROOT_DIR" init
terraform -chdir="$ROOT_DIR" validate
terraform -chdir="$ROOT_DIR" plan -var-file="$ROOT_TFVARS" -out="$ROOT_PLAN"

terraform -chdir="$ROOT_DIR" show -no-color "$ROOT_PLAN" > "$ROOT_DIR/$ROOT_PLAN_TEXT"

if [ ! -s "$ROOT_DIR/$ROOT_PLAN_TEXT" ]; then
  echo "ERROR: Root plan text was not created."
  echo "Aborting because safety checks cannot run."
  exit 1
fi

echo
echo "Running safety checks on Terraform root plan..."

for term in "${BLOCKED_TERMS[@]}"; do
  if grep -qi "$term" "$ROOT_DIR/$ROOT_PLAN_TEXT"; then
    echo "ERROR: Root plan contains blocked old project value: $term"
    echo "Fix Terraform variables before applying."
    exit 1
  fi
done

if grep -qi "$BACKEND_BUCKET" "$ROOT_DIR/$ROOT_PLAN_TEXT"; then
  echo "ERROR: Root plan references the Terraform backend bucket: $BACKEND_BUCKET"
  echo "terraform/root must not manage the backend state bucket."
  exit 1
fi

if grep -A30 -B10 'from_port[[:space:]]*=[[:space:]]*22' "$ROOT_DIR/$ROOT_PLAN_TEXT" | grep -q '0.0.0.0/0'; then
  echo "ERROR: Root plan exposes SSH on port 22 to 0.0.0.0/0."
  echo "Fix security group rules before applying."
  exit 1
fi

echo "Safety checks passed."

echo
echo "Review the main Terraform plan carefully."
read -r -p "Apply main Terraform infrastructure? Type yes to continue: " APPLY_ROOT

if [ "$APPLY_ROOT" != "yes" ]; then
  echo "Main Terraform apply cancelled."
  exit 0
fi

terraform -chdir="$ROOT_DIR" apply "$ROOT_PLAN"

echo
echo "TaskApp Terraform deployment complete."
echo
echo "Root outputs:"
terraform -chdir="$ROOT_DIR" output