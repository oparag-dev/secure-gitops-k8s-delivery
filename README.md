# Secure GitOps Kubernetes Delivery - Build Pack

Drop these files into the root of `secure-gitops-k8s-delivery`.

This pack starts the project with:

- GitHub Actions CI security pipeline
- Backend and frontend Dockerfiles
- Helm chart for TaskApp
- Argo CD application manifest
- Kyverno policy guardrails
- Prometheus/Grafana monitoring values
- Business decision records

## First Build Order

1. Add these files to the repo.
2. Commit them.
3. Add GitHub secrets:
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
4. Push to GitHub.
5. Confirm the CI workflow runs.
6. Fix app test or build failures before moving to Argo CD.

## Important

The Dockerfiles assume this structure:

```text
app/
  taskapp_backend/
  taskapp_frontend/
```

If your backend port or startup command differs, update:

- `app/taskapp_backend/Dockerfile`
- `helm/taskapp/values.yaml`

If your frontend build command differs, update:

- `app/taskapp_frontend/Dockerfile`
- `.github/workflows/ci.yml`

