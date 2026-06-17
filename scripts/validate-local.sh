#!/usr/bin/env bash
set -euo pipefail

echo "Building backend image..."
docker build -t taskapp-backend:local -f app/taskapp_backend/Dockerfile app/taskapp_backend

echo "Building frontend image..."
docker build -t taskapp-frontend:local -f app/taskapp_frontend/Dockerfile app/taskapp_frontend

echo "Rendering Helm chart..."
helm template taskapp helm/taskapp -f helm/taskapp/values-dev.yaml >/tmp/taskapp-rendered.yaml

echo "Local validation passed."

